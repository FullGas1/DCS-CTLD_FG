-- ============================================================
-- CTLD_troop.lua
-- CTLDTroopGroup entity + CTLDTroopManager singleton
--
-- Dependencies: CTLDConfig (ctld.gs), CTLDUtils, CTLDObjectRegistry, CTLDZoneManager
-- DCS API: coalition.addGroup, Group, Unit, land, trigger.action, missionCommands
--
-- TroopGroup lifecycle states:
--   loaded    : troops onboard a transport (loaded from a pickup zone)
--   deployed  : troops on the ground as a live DCS group
--   extracted : troops onboard a transport (picked up from field)
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDTroopGroup  (entity)
-- ============================================================

CTLDTroopGroup = class()

CTLDTroopGroup.STATE = {
    LOADED    = "loaded",
    DEPLOYED  = "deployed",
    EXTRACTED = "extracted",
}

--- Constructor.
-- @param data table:
--   templateKey  (string|nil)  CTLDObjectRegistry key (nil for extracted groups without template)
--   templateName (string)      display name
--   unitTotal    (number)      total unit count
--   weight       (number)      total cargo weight (kg)
--   hasJtac      (boolean)
--   coalitionId  (number)      coalition.side.*
--   countryId    (number)      DCS country id
--   state        (string|nil)  CTLDTroopGroup.STATE.* — defaults to LOADED
function CTLDTroopGroup:init(data)
    self.templateKey  = data.templateKey
    self.templateName = data.templateName
    self.unitTotal    = data.unitTotal
    self.weight       = data.weight
    self.hasJtac      = data.hasJtac or false
    self.coalitionId  = data.coalitionId
    self.countryId    = data.countryId
    self.state        = data.state or CTLDTroopGroup.STATE.LOADED
    self.dcsGroup     = nil
    self.loadTime     = timer.getAbsTime()
end

--- Transition to DEPLOYED: record the spawned DCS group.
-- @param dcsGroup Group|nil  spawned DCS group (nil for EXZ silent drops)
function CTLDTroopGroup:deploy(dcsGroup)
    self.state    = CTLDTroopGroup.STATE.DEPLOYED
    self.dcsGroup = dcsGroup
end

--- Transition to EXTRACTED: troops boarded back from field into transport.
function CTLDTroopGroup:extract()
    self.state    = CTLDTroopGroup.STATE.EXTRACTED
    self.dcsGroup = nil
end

--- Returns true if troops are onboard the transport (LOADED or EXTRACTED).
function CTLDTroopGroup:isInTransit()
    return self.state == CTLDTroopGroup.STATE.LOADED
        or self.state == CTLDTroopGroup.STATE.EXTRACTED
end

-- ============================================================
-- CTLDTroopManager  (singleton)
-- ============================================================

CTLDTroopManager = class()

CTLDTroopManager._instance = nil

-- ============================================================
-- Unit types per role per coalition
-- ============================================================

CTLDTroopManager._UNIT_TYPES = {
    inf    = { [1] = "Infantry AK",        [2] = "Soldier M4 GRG"    },
    mg     = { [1] = "Paratrooper AKS-74", [2] = "Soldier M249"      },
    at     = { [1] = "Paratrooper RPG-16", [2] = "Paratrooper RPG-16"},
    aa     = { [1] = "SA-18 Igla manpad",  [2] = "Soldier stinger"   },
    mortar = { [1] = "2B11 mortar",        [2] = "2B11 mortar"       },
    jtac   = { [1] = "Infantry AK",        [2] = "Soldier M4 GRG"    },  -- same model, name prefix = "JTAC"
}

-- Average weight (kg) per soldier per role: base 84 + kit 20 + equipment
CTLDTroopManager._ROLE_WEIGHTS = {
    inf    = 109,   -- 84+20+5
    mg     = 114,   -- 84+20+10
    at     = 112,   -- 84+20+7.6 (rounded)
    aa     = 122,   -- 84+20+18
    mortar = 130,   -- 84+20+26
    jtac   = 124,   -- 84+20+15+5
}

-- Processing order matches ctld.generateTroopTypes in source
CTLDTroopManager._ROLE_ORDER = { "aa", "inf", "mg", "at", "mortar", "jtac" }

-- ============================================================
-- Singleton
-- ============================================================

function CTLDTroopManager.getInstance()
    if CTLDTroopManager._instance == nil then
        CTLDTroopManager._instance = setmetatable({}, CTLDTroopManager)
        CTLDTroopManager._instance:init()
    end
    return CTLDTroopManager._instance
end

-- ============================================================
-- Init
-- ============================================================

function CTLDTroopManager:init()
    self._inTransit        = {}              -- [unitName] = CTLDTroopGroup (LOADED or EXTRACTED)
    self._droppedGroups    = { [1]={}, [2]={} }  -- [coalition] = { groupName, ... }
    self._parachuteEffect  = CTLDNullParachuteEffect:new()
    self._templates        = {}              -- mutable runtime list (standard + custom)
    self:_registerTemplates()
    self:_loadUserConfig()
    self._templateCount = #self._templates
    CTLDPlayerManager.getInstance():registerMenuSection({
        key    = "troops",
        manager = self,
        method  = "buildMenuSection",
        order   = 20,
    })
    ctld.utils.log("INFO", "CTLDTroopManager initialized — %d templates registered",
        self._templateCount)
    return self
end

--- Replace the parachute visual effect handler.
-- @param effect CTLDParachuteEffect
function CTLDTroopManager:setParachuteEffect(effect)
    self._parachuteEffect = effect
end

-- ============================================================
-- Template registration → CTLDObjectRegistry entries
-- ============================================================

local function _sanitizeKey(name)
    return (name:gsub("[^%w]", "_"))
end

-- Populates self._templates from config and registers each standard template.
-- Mutates source objects (adds _dbKey, total, hasJtac, custom, disabled) — consistent with legacy.
function CTLDTroopManager:_registerTemplates()
    local cfgTemplates = ctld.gs("loadableGroups") or {}
    for _, tmpl in ipairs(cfgTemplates) do
        tmpl.custom   = false
        tmpl.disabled = false
        table.insert(self._templates, tmpl)
        self:_registerOneTemplate(tmpl)
    end
end

-- Computes total/hasJtac, assigns _dbKey, and inserts a GROUND descriptor into CTLDObjectRegistry.
-- Safe to call at init or at runtime (createLoadableGroup).
function CTLDTroopManager:_registerOneTemplate(tmpl)
    local total   = 0
    local hasJtac = false
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = tmpl[role] or 0
        total   = total + n
        if role == "jtac" and n > 0 then hasJtac = true end
    end
    tmpl.total   = total
    tmpl.hasJtac = hasJtac

    -- Build the units array (no dx/dz: circle formation computes them at spawn time)
    local units = {}
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n      = tmpl[role] or 0
        local isJtac = (role == "jtac")
        for _ = 1, n do
            local capturedRole = role
            table.insert(units, {
                namePrefix = isJtac and "JTAC" or string.upper(capturedRole),
                unitType   = (function(r)
                    return function(cid)
                        return CTLDTroopManager._UNIT_TYPES[r][cid]
                            or CTLDTroopManager._UNIT_TYPES[r][2]
                    end
                end)(capturedRole),
            })
        end
    end

    local key   = "troop_" .. _sanitizeKey(tmpl.name)
    tmpl._dbKey = key

    CTLDObjectRegistry._db[key] = {
        groupType  = "GROUND",
        namePrefix = "TroopGrp_" .. _sanitizeKey(tmpl.name),
        task       = "Ground Nothing",
        category   = Unit.Category.GROUND_UNIT,
        formation  = { type = "circle" },
        units      = units,
    }

    ctld.utils.log("INFO", "_registerOneTemplate: '%s' → key='%s' (%d units)",
        tmpl.name, key, total)
end

-- Applies ctld_config_user.customLoadableGroups and ctld_config_user.disableLoadableGroups.
function CTLDTroopManager:_loadUserConfig()
    local cfg = (type(ctld_config_user) == "table") and ctld_config_user or {}

    local customs = cfg.customLoadableGroups
    if type(customs) == "table" then
        for _, entry in ipairs(customs) do
            local ok, err = self:createLoadableGroup(entry)
            if not ok then
                ctld.utils.log("WARN", "_loadUserConfig: skipped custom group — %s", err)
            end
        end
    end

    local disables = cfg.disableLoadableGroups
    if type(disables) == "table" then
        for _, name in ipairs(disables) do
            local ok, err = self:disableLoadableGroup(name)
            if not ok then
                ctld.utils.log("WARN", "_loadUserConfig: could not disable '%s' — %s", name, err)
            end
        end
    end
end

-- ============================================================
-- Public API — LoadableGroup management
-- ============================================================

-- Returns the template entry with this name, or nil.
function CTLDTroopManager:_findTemplate(name)
    for _, tmpl in ipairs(self._templates) do
        if tmpl.name == name then return tmpl end
    end
    return nil
end

-- Creates and registers a custom loadable group template.
-- @param config table  { name, composition={inf,mg,at,aa,mortar,jtac}, side }
-- @return boolean, string|nil
function CTLDTroopManager:createLoadableGroup(config)
    if type(config) ~= "table" then
        return false, "config must be a table"
    end
    if not config.name or config.name == "" then
        return false, "name is required"
    end
    if type(config.composition) ~= "table" then
        return false, "composition is required"
    end

    local comp = config.composition
    local inf    = comp.inf    or 0
    local mg     = comp.mg     or 0
    local at     = comp.at     or 0
    local aa     = comp.aa     or 0
    local mortar = comp.mortar or 0
    local jtac   = comp.jtac   or 0
    local total  = inf + mg + at + aa + mortar + jtac

    if total == 0 then
        return false, "composition must have at least 1 soldier"
    end

    if self:_findTemplate(config.name) then
        ctld.utils.log("WARN", "createLoadableGroup: '%s' already exists, skipping", config.name)
        return false, "template name already exists"
    end

    local tmpl = {
        name     = config.name,
        inf      = inf,  mg = mg,  at = at,  aa = aa,  mortar = mortar,  jtac = jtac,
        side     = config.side,
        custom   = true,
        disabled = false,
    }
    table.insert(self._templates, tmpl)
    self:_registerOneTemplate(tmpl)

    ctld.utils.log("INFO", "createLoadableGroup: '%s' (%d soldiers, side=%s)",
        tmpl.name, tmpl.total, tostring(tmpl.side or "both"))
    return true
end

-- Removes a template (standard or custom).
-- @param name string
-- @return boolean, string|nil
function CTLDTroopManager:removeLoadableGroup(name)
    for i, tmpl in ipairs(self._templates) do
        if tmpl.name == name then
            CTLDObjectRegistry._db[tmpl._dbKey] = nil
            table.remove(self._templates, i)
            ctld.utils.log("INFO", "removeLoadableGroup: '%s' removed", name)
            return true
        end
    end
    return false, "template not found: " .. tostring(name)
end

-- Edits a custom template's composition and/or side restriction.
-- Standard templates cannot be edited (use createLoadableGroup instead).
-- @param name   string
-- @param config table  { composition={...}, side }
-- @return boolean, string|nil
function CTLDTroopManager:editLoadableGroup(name, config)
    local tmpl = self:_findTemplate(name)
    if not tmpl then
        return false, "template not found: " .. tostring(name)
    end
    if not tmpl.custom then
        return false, "cannot edit standard template '" .. name .. "' — create a custom one instead"
    end
    if type(config) ~= "table" then
        return false, "config must be a table"
    end

    if type(config.composition) == "table" then
        local comp = config.composition
        local inf    = comp.inf    or 0
        local mg     = comp.mg     or 0
        local at     = comp.at     or 0
        local aa     = comp.aa     or 0
        local mortar = comp.mortar or 0
        local jtac   = comp.jtac   or 0
        if inf + mg + at + aa + mortar + jtac == 0 then
            return false, "composition must have at least 1 soldier"
        end
        tmpl.inf = inf; tmpl.mg = mg; tmpl.at = at
        tmpl.aa  = aa;  tmpl.mortar = mortar; tmpl.jtac = jtac
    end

    if config.side ~= nil then
        tmpl.side = config.side
    end

    -- Re-register to update ObjectRegistry and recompute total/hasJtac
    self:_registerOneTemplate(tmpl)

    ctld.utils.log("INFO", "editLoadableGroup: '%s' updated (%d soldiers, side=%s)",
        tmpl.name, tmpl.total, tostring(tmpl.side or "both"))
    return true
end

-- Hides a template from the F10 menu without removing it.
-- @param name string
-- @return boolean, string|nil
function CTLDTroopManager:disableLoadableGroup(name)
    local tmpl = self:_findTemplate(name)
    if not tmpl then return false, "template not found: " .. tostring(name) end
    tmpl.disabled = true
    ctld.utils.log("INFO", "disableLoadableGroup: '%s' hidden from menu", name)
    return true
end

-- Restores a previously disabled template in the F10 menu.
-- @param name string
-- @return boolean, string|nil
function CTLDTroopManager:enableLoadableGroup(name)
    local tmpl = self:_findTemplate(name)
    if not tmpl then return false, "template not found: " .. tostring(name) end
    tmpl.disabled = false
    ctld.utils.log("INFO", "enableLoadableGroup: '%s' restored to menu", name)
    return true
end

-- ============================================================
-- Public API — cargo queries
-- ============================================================

-- Returns the CTLDTroopGroup in transit for unitName, or nil.
function CTLDTroopManager:getInTransit(unitName)
    return self._inTransit[unitName]
end

-- Returns true if unitName has troops onboard.
function CTLDTroopManager:hasTroops(unitName)
    return self._inTransit[unitName] ~= nil
end

-- Returns troop cargo weight (kg) for unitName, or 0.
function CTLDTroopManager:getWeight(unitName)
    local group = self._inTransit[unitName]
    return group and group.weight or 0
end

-- Updates DCS internal cargo weight for this transport (troops weight only).
-- NOTE: temporary — CTLDPlayerManager will aggregate all cargo sources when built.
function CTLDTroopManager:_updateWeight(unitName)
    trigger.action.setUnitInternalCargo(unitName, self:getWeight(unitName))
end

-- ============================================================
-- loadFromZone
-- ============================================================

-- Loads a troop template onto unit from the PKZ zone the unit is currently in.
-- @param unit      DCS Unit object
-- @param zone      CtldZone (zoneType == "pickup")
-- @param template  entry from ctld.gs("loadableGroups") (must have _dbKey, total, hasJtac set)
-- @return bool
function CTLDTroopManager:loadFromZone(unit, zone, template)
    local unitName  = unit:getName()
    local coalition = unit:getCoalition()
    local typeName  = unit:getTypeName()

    -- Already has troops?
    if self:hasTroops(unitName) then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("You already have troops onboard."), 10)
        return false
    end

    -- Zone coalition check
    if zone.coalition ~= 0 and zone.coalition ~= coalition then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("This pickup zone is not available to your coalition."), 10)
        return false
    end

    -- Zone active check
    if not zone.active then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("This pickup zone is not active."), 10)
        return false
    end

    -- Zone limit check (0 = depleted; -1 = unlimited)
    if zone.limit == 0 then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("This pickup zone is empty."), 10)
        return false
    end

    -- Transport capacity check
    local limit = self:_transportLimit(typeName)
    if template.total > limit then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("Group too large for this aircraft (capacity: %1 troops).", limit), 10)
        return false
    end

    -- Global infantry limit check per coalition
    local limits = ctld.gs("nbLimitSpawnedTroops") or { 0, 0 }
    if limits[1] ~= 0 or limits[2] ~= 0 then
        local inGame = self:_countDroppedTroops(coalition)
        if inGame + template.total > (limits[coalition] or 0) then
            trigger.action.outTextForGroup(unit:getGroup():getID(),
                ctld.tr("Infantry coalition limit reached, cannot load more troops."), 10)
            return false
        end
    end

    -- Compute weight from role counts
    local weight = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = template[role] or 0
        weight  = weight + n * (CTLDTroopManager._ROLE_WEIGHTS[role] or 109)
    end

    -- Store transit group entity
    self._inTransit[unitName] = CTLDTroopGroup:new({
        templateKey  = template._dbKey,
        templateName = template.name,
        unitTotal    = template.total,
        weight       = weight,
        hasJtac      = template.hasJtac or false,
        coalitionId  = coalition,
        countryId    = unit:getCountry(),
    })

    -- Decrement zone limit and update DCS flag
    if zone.limit > 0 then
        zone.limit = zone.limit - 1
        if zone.flagName then
            trigger.action.setUserFlag(zone.flagName, zone.limit)
        end
    end

    self:_updateWeight(unitName)

    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("Loaded: %1 (%2 troops).", template.name, template.total), 10)

    ctld.utils.log("INFO", "loadFromZone: '%s' loaded '%s' (%d units, %.0f kg)",
        unitName, template.name, template.total, weight)
    return true
end

-- ============================================================
-- deploy (fast-rope or combat drop)
-- ============================================================

-- Deploys troops from unit into combat (fast-rope if conditions met, else ground drop).
-- If inside an EXZ zone: troops are counted only (flag increment), no DCS group spawned.
-- @param unit  DCS Unit object
-- @return bool
function CTLDTroopManager:deploy(unit)
    local unitName = unit:getName()
    local group    = self._inTransit[unitName]

    if not group then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("No troops onboard."), 10)
        return false
    end

    local canFastRope = self:_safeToFastRope(unit)
    local onGround    = not self:_isInAir(unit)

    if not canFastRope and not onGround then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("Too high or too fast to drop troops! Hover below %1 ft or land.",
                math.floor((ctld.gs("fastRopeMaximumHeight") or 18.28) * 3.2808399)), 10)
        return false
    end

    local pt  = unit:getPoint()
    local hdg = ctld.utils.getHeadingInRadians("TroopManager.deploy", unit, true)

    -- EXZ zone check (extract zone: count troops silently, no DCS group spawn)
    local exzZone = CTLDZoneManager.getInstance():isUnitInZone(unitName, "extract")
    if exzZone then
        local current = trigger.misc.getUserFlag(exzZone.objectiveFlag) or 0
        trigger.action.setUserFlag(exzZone.objectiveFlag, current + group.unitTotal)
        group:deploy(nil)
        ctld.utils.log("INFO", "deploy: %d troops sent to EXZ '%s' (flag %s = %d)",
            group.unitTotal, exzZone.zoneName, exzZone.objectiveFlag, current + group.unitTotal)
    else
        -- Compute circle radius: safe distance from aircraft + config offset
        local safeR   = ctld.utils.getSecureDistanceFromUnit(unitName) or 10
        local circleR = safeR + (ctld.gs("spawnDistanceInCircle") or 10)

        local dcsGroup = CTLDObjectRegistry.spawnObject(
            group.templateKey,
            group.coalitionId,
            group.countryId,
            pt.x, pt.z, hdg,
            { circleRadius = circleR }
        )

        if not dcsGroup then
            ctld.utils.log("ERROR", "deploy: spawnObject failed for key '%s'", group.templateKey)
            return false
        end

        group:deploy(dcsGroup)
        table.insert(self._droppedGroups[group.coalitionId], dcsGroup:getName())

        if group.hasJtac then
            -- Signal: CTLDJtacManager will handle laser attribution when built
            ctld.utils.log("INFO", "deploy: JTAC group dropped — '%s'", dcsGroup:getName())
        end

        -- WPZ check: if deploy point is inside a waypoint zone, march troops to zone center
        local wpzZone = CTLDZoneManager.getInstance():getWaypointZoneAt(pt, group.coalitionId)
        if wpzZone then
            local dest    = wpzZone:getCenter()
            local wpFrom  = ctld.utils.buildWP("TroopManager.deploy.WPZ", pt,   'Off Road', 50)
            local wpDest  = ctld.utils.buildWP("TroopManager.deploy.WPZ", dest, 'Off Road', 50)
            if wpFrom and wpDest then
                local mission = {
                    id = 'Mission',
                    params = { route = { points = { wpFrom, wpDest } } },
                }
                local grpName = dcsGroup:getName()
                -- Delay 2 s: DCS group controller may be empty immediately after spawn
                timer.scheduleFunction(function(arg)
                    local grp = Group.getByName(arg.grpName)
                    if not grp or not grp:isExist() then return end
                    local ctrl = grp:getController()
                    ctrl:setOption(AI.Option.Ground.id.ALARM_STATE,
                                   AI.Option.Ground.val.ALARM_STATE.AUTO)
                    ctrl:setOption(AI.Option.Ground.id.ROE,
                                   AI.Option.Ground.val.ROE.OPEN_FIRE)
                    ctrl:setTask(arg.mission)
                end, { grpName = grpName, mission = mission }, timer.getTime() + 2)
                ctld.utils.log("INFO",
                    "deploy: WPZ '%s' — group '%s' ordered to march to zone center",
                    wpzZone.zoneName, grpName)
            end
        end
    end

    -- Confirm message
    local method = (canFastRope and self:_isInAir(unit)) and "fast-ropped" or "dropped"
    local dest   = exzZone
        and ctld.tr("into %1", exzZone.zoneName)
        or  ctld.tr("into combat")
    trigger.action.outTextForCoalition(group.coalitionId,
        ctld.tr("%1 %2 [%3] from %4 %5.",
            self:_callsign(unit), method, group.templateName, unit:getTypeName(), dest), 10)

    self._inTransit[unitName] = nil
    self:_updateWeight(unitName)
    return true
end

-- ============================================================
-- returnToBase (PKZ zone: troops returned to zone pool)
-- ============================================================

-- Returns troops to the pickup zone the unit is currently in.
-- Increments zone.limit and updates the DCS flag.
-- @param unit  DCS Unit object
-- @param zone  CtldZone (zoneType == "pickup")
-- @return bool
function CTLDTroopManager:returnToBase(unit, zone)
    local unitName  = unit:getName()
    local group     = self._inTransit[unitName]
    local coalition = unit:getCoalition()

    if not group then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("No troops onboard."), 10)
        return false
    end

    -- Increment zone limit (troops return to pool)
    if zone.limit >= 0 then
        zone.limit = zone.limit + group.unitTotal
        if zone.flagName then
            trigger.action.setUserFlag(zone.flagName, zone.limit)
        end
    end

    ctld.utils.log("INFO", "returnToBase: '%s' returned [%s] to PKZ '%s'",
        unitName, group.templateName, zone.zoneName)

    self._inTransit[unitName] = nil
    self:_updateWeight(unitName)

    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("Dropped troops back to base."), 10)
    return true
end

-- ============================================================
-- extract
-- ============================================================

-- Extracts the nearest friendly dropped troop group (unit must be on the ground).
-- @param unit  DCS Unit object
-- @return bool
function CTLDTroopManager:extract(unit)
    local unitName  = unit:getName()
    local coalition = unit:getCoalition()
    local typeName  = unit:getTypeName()

    if self:hasTroops(unitName) then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("You already have troops onboard."), 10)
        return false
    end

    if self:_isInAir(unit) then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("You must land to extract troops."), 10)
        return false
    end

    local nearest = self:_findNearestDropped(unit, coalition)
    if not nearest then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("No extractable troops nearby!"), 10)
        return false
    end

    local groupSize = #nearest.group:getUnits()
    local limit     = self:_transportLimit(typeName)
    if groupSize > limit then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("Group too large to fit (%1 troops, limit %2 for %3).",
                groupSize, limit, typeName), 10)
        return false
    end

    local country = nearest.group:getUnit(1):getCountry()
    local weight  = groupSize * 130  -- 130 kg/soldier extraction estimate
    local hasJtac = nearest.groupName:lower():find("jtac") ~= nil

    self._inTransit[unitName] = CTLDTroopGroup:new({
        templateKey  = nil,   -- extracted group has no template descriptor
        templateName = nearest.groupName,
        unitTotal    = groupSize,
        weight       = weight,
        hasJtac      = hasJtac,
        coalitionId  = coalition,
        countryId    = country,
        state        = CTLDTroopGroup.STATE.EXTRACTED,
    })

    self:_removeFromDropped(coalition, nearest.groupName)
    nearest.group:destroy()

    self:_updateWeight(unitName)

    trigger.action.outTextForCoalition(coalition,
        ctld.tr("%1 extracted [%2] from combat.",
            self:_callsign(unit), nearest.groupName), 10)

    ctld.utils.log("INFO", "extract: '%s' extracted group '%s' (%d units)",
        unitName, nearest.groupName, groupSize)
    return true
end

-- ============================================================
-- Menu building
-- ============================================================

-- Builds the "Troop Transport" F10 sub-menu for a player.
-- Load entries are paginated at PAGE_SIZE items per DCS submenu level.
-- @param unit        DCS Unit object
-- @param groupId     DCS group id for missionCommands
-- @param parentPath  missionCommands parent path
function CTLDTroopManager:buildMenu(unit, groupId, parentPath)
    local unitName  = unit:getName()
    local typeName  = unit:getTypeName()
    local coalition = unit:getCoalition()

    local troopPath = missionCommands.addSubMenuForGroup(groupId,
        ctld.tr("Troop Transport"), parentPath)

    -- "Unload / Extract Troops" (always present)
    missionCommands.addCommandForGroup(groupId,
        ctld.tr("Unload / Extract Troops"), troopPath,
        function()
            local u = Unit.getByName(unitName)
            if u then CTLDTroopManager.getInstance():_menuUnloadOrExtract(u) end
        end)

    -- Transport capacity for this aircraft type
    local limit = self:_transportLimit(typeName)

    -- Filter applicable templates (not disabled + side + capacity)
    local entries = {}
    for _, tmpl in ipairs(self._templates) do
        local sideOk = (tmpl.side == nil or tmpl.side == coalition)
        local sizeOk = (tmpl.total <= limit)
        if not tmpl.disabled and sideOk and sizeOk then
            table.insert(entries, tmpl)
        end
    end

    -- Paginated "Load X" entries (9 items per page, slot 0 = Unload already used)
    local PAGE_SIZE = 9
    local menuPath  = troopPath
    local itemNb    = 0

    for i, tmpl in ipairs(entries) do
        if itemNb == PAGE_SIZE and i < #entries then
            menuPath = missionCommands.addSubMenuForGroup(groupId,
                ctld.tr("Next page"), menuPath)
            itemNb = 0
        end
        local capturedTmpl = tmpl
        missionCommands.addCommandForGroup(groupId,
            ctld.tr("Load ") .. tmpl.name, menuPath,
            function()
                local u = Unit.getByName(unitName)
                if not u then return end
                local zone = CTLDZoneManager.getInstance():isUnitInZone(unitName, "pickup")
                if not zone then
                    trigger.action.outTextForGroup(u:getGroup():getID(),
                        ctld.tr("You must be in a pickup zone to load troops."), 10)
                    return
                end
                CTLDTroopManager.getInstance():loadFromZone(u, zone, capturedTmpl)
            end)
        itemNb = itemNb + 1
    end

    -- "Check Cargo"
    missionCommands.addCommandForGroup(groupId,
        ctld.tr("Check Cargo"), troopPath,
        function()
            local u = Unit.getByName(unitName)
            if u then CTLDTroopManager.getInstance():_menuCheckCargo(u) end
        end)
end

-- ============================================================
-- Polling / cleanup (called by CTLDCore)
-- ============================================================

-- Removes dead/empty groups from _droppedGroups.
function CTLDTroopManager:cleanupDeadGroups()
    for coa = 1, 2 do
        local alive = {}
        for _, name in ipairs(self._droppedGroups[coa]) do
            local g = Group.getByName(name)
            if g and g:isExist() and #g:getUnits() > 0 then
                table.insert(alive, name)
            end
        end
        self._droppedGroups[coa] = alive
    end
end

-- Removes entries for destroyed transports from _inTransit.
function CTLDTroopManager:cleanupDeadTransports()
    for unitName, _ in pairs(self._inTransit) do
        local u = Unit.getByName(unitName)
        if not u or not u:isExist() then
            self._inTransit[unitName] = nil
            ctld.utils.log("INFO", "cleanupDeadTransports: removed stale entry for '%s'", unitName)
        end
    end
end

-- ============================================================
-- Private helpers
-- ============================================================

-- Returns the maximum number of troops this aircraft type can carry.
function CTLDTroopManager:_transportLimit(typeName)
    local byType = ctld.gs("transportLimitByType")
    if byType and byType[typeName] then return byType[typeName] end
    return ctld.gs("numberOfTroops") or 10
end

-- Returns true if unit is in the air (AGL > 2 m).
function CTLDTroopManager:_isInAir(unit)
    local pt   = unit:getPoint()
    local gndH = land.getHeight({ x = pt.x, z = pt.z })
    return (pt.y - gndH) > 2.0
end

-- Returns true if fast-rope conditions are met.
function CTLDTroopManager:_safeToFastRope(unit)
    if not ctld.gs("enableFastRopeInsertion") then return false end
    local maxH   = (ctld.gs("fastRopeMaximumHeight") or 18.28) + 3.0
    local pt     = unit:getPoint()
    local gndH   = land.getHeight({ x = pt.x, z = pt.z })
    local altAGL = pt.y - gndH
    local vel    = unit:getVelocity()
    local speed  = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
    return altAGL <= maxH and speed < 2.2
end

-- Returns total alive unit count for all dropped groups of given coalition.
function CTLDTroopManager:_countDroppedTroops(coalition)
    local count = 0
    for _, name in ipairs(self._droppedGroups[coalition]) do
        local g = Group.getByName(name)
        if g and g:isExist() then
            count = count + #g:getUnits()
        end
    end
    return count
end

-- Returns { groupName, group, distM } for the nearest dropped group within maxExtractDistance, or nil.
function CTLDTroopManager:_findNearestDropped(unit, coalition)
    local pt      = unit:getPoint()
    local maxDist = ctld.gs("maxExtractDistance") or 125
    local best, bestDist = nil, maxDist

    for _, name in ipairs(self._droppedGroups[coalition]) do
        local g = Group.getByName(name)
        if g and g:isExist() and #g:getUnits() > 0 then
            local leader = g:getUnit(1)
            if leader then
                local gpt  = leader:getPoint()
                local dist = math.sqrt((pt.x - gpt.x)^2 + (pt.z - gpt.z)^2)
                if dist < bestDist then
                    bestDist = dist
                    best = { groupName = name, group = g, distM = dist }
                end
            end
        end
    end
    return best
end

-- Removes a group name from the coalition's dropped list.
function CTLDTroopManager:_removeFromDropped(coalition, groupName)
    local list = self._droppedGroups[coalition]
    for i, name in ipairs(list) do
        if name == groupName then
            table.remove(list, i)
            return
        end
    end
end

-- Returns a display name for the unit (player name or callsign).
function CTLDTroopManager:_callsign(unit)
    local player = unit:getPlayerName()
    return (player and player ~= "") and player or unit:getTypeName()
end

-- ============================================================
-- Menu action handlers
-- ============================================================

-- "Unload / Extract Troops" button:
--   On ground + nearest dropped group + no troops → extract
--   Has troops + in PKZ                           → returnToBase
--   Has troops + not in PKZ                       → deploy
function CTLDTroopManager:_menuUnloadOrExtract(unit)
    local unitName  = unit:getName()
    local coalition = unit:getCoalition()
    local zm        = CTLDZoneManager.getInstance()
    local inAir     = self:_isInAir(unit)

    -- Ground + extractable group nearby + no troops onboard → extract
    if not inAir and not self:hasTroops(unitName) then
        local nearest = self:_findNearestDropped(unit, coalition)
        if nearest then
            self:extract(unit)
            return
        end
    end

    -- Has troops: return to base if in PKZ, otherwise deploy
    if self:hasTroops(unitName) then
        local pkzZone = zm:isUnitInZone(unitName, "pickup")
        if pkzZone then
            self:returnToBase(unit, pkzZone)
        else
            self:deploy(unit)
        end
        return
    end

    -- No troops, not in air, no nearby group
    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("No troops onboard and no extractable troops nearby."), 10)
end

function CTLDTroopManager:_menuCheckCargo(unit)
    local unitName = unit:getName()
    local group    = self._inTransit[unitName]
    local msg
    if group then
        msg = ctld.tr("Cargo: [%1] — %2 troops, %3 kg",
            group.templateName, group.unitTotal, math.floor(group.weight))
    else
        msg = ctld.tr("No troops onboard.")
    end
    trigger.action.outTextForGroup(unit:getGroup():getID(), msg, 10)
end

-- ============================================================
-- Feature A — Virtual parachute
-- ============================================================

--- Parachute troops currently loaded on a transport.
-- Altitude AGL is checked at call time. If below parachuteMinAltitudeTroops,
-- a message is sent to the group and nothing happens.
-- Each unit in the group gets its own independent landing position.
-- The DCS ground group is spawned with all unit positions after descentTime.
-- Publishes OnTroopsDeployed (trigger="parachute") immediately,
-- and OnTroopsParachuteLanded after descentTime.
-- @param transport  Unit    DCS transport unit
-- @param playerObj  table   CTLDPlayer-like {groupId, unitName}
function CTLDTroopManager:parachuteTroops(transport, playerObj)
    local dropPos     = transport:getPoint()
    local groundUnder = land.getHeight({ x = dropPos.x, y = dropPos.z })
    local altAGL      = dropPos.y - groundUnder
    local minAlt      = ctld.gs("parachuteMinAltitudeTroops") or 50

    if altAGL < minAlt then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Altitude too low for parachute drop. Minimum: %dm AGL (current: %dm AGL)"),
                math.floor(minAlt), math.floor(altAGL)), 10)
        return
    end

    local troopGroup = self._inTransit[playerObj.unitName]
    if not troopGroup then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No troops onboard."), 8)
        return
    end

    local descentRate = ctld.gs("parachuteDescentRateTroops") or 5
    local unitDefs    = {}
    local landPositions = {}

    -- Resolve unit type from template registry (fallback to generic infantry)
    local template    = troopGroup.templateKey and CTLDObjectRegistry._db[troopGroup.templateKey]
    local unitCount   = troopGroup.unitTotal or 1
    local unitType    = (template and template.units and template.units[1] and template.units[1].type)
                        or "Soldier AK"

    -- Compute one landing position per unit
    local firstDescentTime = nil
    for i = 1, unitCount do
        local landPos, descentTime = ctld.utils.calcDropPosition(transport, descentRate)
        table.insert(landPositions, landPos)
        unitDefs[i] = {
            type    = unitType,
            name    = troopGroup.templateName .. "_unit" .. i,
            x       = landPos.x,
            y       = landPos.z,   -- DCS ground group: position.y = world Z axis
            heading = math.random(0, 360) * math.pi / 180,
        }
        if i == 1 then firstDescentTime = descentTime end
    end

    local descentTime = firstDescentTime or
        select(2, ctld.utils.calcDropPosition(transport, descentRate))

    -- Unload from transport cargo
    self._inTransit[playerObj.unitName] = nil

    local dropData = {
        type          = "troop",
        unitName      = troopGroup.templateName,
        dropPosition  = dropPos,
        landPositions = landPositions,
        altitude      = altAGL,
        descentTime   = descentTime,
        transport     = transport,
        player        = playerObj.unitName,
    }
    self._parachuteEffect:onStart(dropData)

    EventDispatcher.getInstance():publish("OnTroopsDeployed", {
        troops          = troopGroup,
        carrierUnitName = transport:getName(),
        player          = playerObj.unitName,
        trigger         = "parachute",
        destination     = { type = "combat", troopZone = nil },
        timestamp       = timer.getAbsTime(),
    })

    -- Capture for timer closure
    local _troopGroup   = troopGroup
    local _unitDefs     = unitDefs
    local _landPositions = landPositions
    local _dropData     = dropData
    local _coalition    = playerObj.coalition or 2

    timer.scheduleFunction(function()
        local country = coalition.getCountryCoalition and coalition.getCountryCoalition(_coalition) or _coalition
        local spawnedGroup = coalition.addGroup(country, Group.Category.GROUND, {
            name  = _troopGroup.templateName,
            task  = "Ground Nothing",
            units = _unitDefs,
        })

        local grp = Group.getByName(_troopGroup.templateName)
        if grp then
            table.insert(self._droppedGroups[_coalition] or {}, _troopGroup.templateName)
        end

        self._parachuteEffect:onLanded(_dropData)

        EventDispatcher.getInstance():publish("OnTroopsParachuteLanded", {
            troops        = _troopGroup,
            spawnedGroup  = spawnedGroup,
            positions     = _landPositions,
            transport     = transport:getName(),
            player        = playerObj.unitName,
            startAltitude = altAGL,
            timestamp     = timer.getAbsTime(),
        })
    end, {}, timer.getTime() + descentTime)
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Build the "Troop Commands" F10 submenu for a player.
-- Added only when the unit type has troops capability in unitActions.
-- Per-zone load commands are generated from TRZ zones matching player coalition.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDTroopManager:buildMenuSection(playerObj, menu)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.troops) then return end

    local root     = ctld.tr("CTLD")
    local troopSub = ctld.tr("Troop Commands")
    menu:addSubMenu({ root }, troopSub, { order = 20 })

    -- Unload / Extract always available
    menu:addCommand({ root, troopSub }, ctld.tr("Unload / Extract Troops"),
        function(arg)
            CTLDTroopManager.getInstance():unloadTroops(arg.unitName)
        end,
        { unitName = playerObj.unitName })

    -- Filter templates applicable to this aircraft and coalition
    local limit = self:_transportLimit(playerObj.typeName)
    local validTmpls = {}
    for _, tmpl in ipairs(self._templates) do
        local sideOk = (tmpl.side == nil or tmpl.side == playerObj.coalition)
        local sizeOk = (tmpl.total <= limit)
        if not tmpl.disabled and sideOk and sizeOk then
            table.insert(validTmpls, tmpl)
        end
    end

    -- One sub-menu per pickup-capable zone, listing available templates
    local zones = CTLDZoneManager.getInstance():getTroopZonesForCoalition(playerObj.coalition)
    for _, zone in ipairs(zones) do
        if zone:hasPickup() then
            local zName    = zone.zoneName
            local zoneSub  = string.format(ctld.tr("Load from %s"), zName)
            menu:addSubMenu({ root, troopSub }, zoneSub)
            for _, tmpl in ipairs(validTmpls) do
                local capturedTmpl  = tmpl
                local capturedZName = zName
                menu:addCommand({ root, troopSub, zoneSub },
                    ctld.tr("Load ") .. tmpl.name,
                    function(arg)
                        local u = Unit.getByName(arg.unitName)
                        if not u then return end
                        local z = CTLDZoneManager.getInstance():getTroopZone(arg.zoneName)
                        if not z then
                            trigger.action.outTextForGroup(u:getGroup():getID(),
                                ctld.tr("Zone not found."), 10)
                            return
                        end
                        CTLDTroopManager.getInstance():loadFromZone(u, z, arg.tmpl)
                    end,
                    { unitName = playerObj.unitName, zoneName = capturedZName, tmpl = capturedTmpl })
            end
        end
    end

    -- Check troops onboard
    menu:addCommand({ root, troopSub }, ctld.tr("Check Troops Onboard"),
        function(arg)
            local u = Unit.getByName(arg.unitName)
            if not u then return end
            local tm    = CTLDTroopManager.getInstance()
            local group = tm._inTransit[arg.unitName]
            if group then
                trigger.action.outTextForGroup(u:getGroup():getID(),
                    ctld.tr("Onboard: %1 (%2 troops)", group.templateName, group.unitTotal), 10)
            else
                trigger.action.outTextForGroup(u:getGroup():getID(),
                    ctld.tr("No troops onboard."), 10)
            end
        end,
        { unitName = playerObj.unitName })

    -- Parachute Troops: only if canParachute=true for this unit type
    local acts2 = (ctld.gs("unitActions") or {})[playerObj.typeName]
    if acts2 and acts2.canParachute then
        menu:addCommand({ root, troopSub }, ctld.tr("Parachute Troops"),
            function(arg)
                local transport = Unit.getByName(arg.unitName)
                if not transport then return end
                CTLDTroopManager.getInstance():parachuteTroops(transport, arg)
            end,
            { unitName = playerObj.unitName, groupId = playerObj.groupId,
              coalition = playerObj.coalition })
    end
end

-- ============================================================
-- Public ctld.* API — LoadableGroup wrappers
-- ============================================================

--- Create a custom loadable group template.
-- @param config table  { name, composition={inf,mg,at,aa,mortar,jtac}, side }
-- @return boolean, string|nil
function ctld.createLoadableGroup(config)
    return CTLDTroopManager.getInstance():createLoadableGroup(config)
end

--- Remove a loadable group template (standard or custom).
-- @param name string
-- @return boolean, string|nil
function ctld.removeLoadableGroup(name)
    return CTLDTroopManager.getInstance():removeLoadableGroup(name)
end

--- Edit a custom loadable group template.
-- Standard templates are refused.
-- @param name   string
-- @param config table  { composition={...}, side }
-- @return boolean, string|nil
function ctld.editLoadableGroup(name, config)
    return CTLDTroopManager.getInstance():editLoadableGroup(name, config)
end

--- Hide a template from the F10 menu.
-- @param name string
-- @return boolean, string|nil
function ctld.disableLoadableGroup(name)
    return CTLDTroopManager.getInstance():disableLoadableGroup(name)
end

--- Restore a disabled template in the F10 menu.
-- @param name string
-- @return boolean, string|nil
function ctld.enableLoadableGroup(name)
    return CTLDTroopManager.getInstance():enableLoadableGroup(name)
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Resolve a count or composition table to the closest available template.
-- integer → template whose total is nearest; table {inf,mg,...} → sum totals then match.
-- @param coalitionId number  (unused — templates are coalition-agnostic)
-- @param number      number|table
-- @return table|nil  template
function CTLDTroopManager:_resolveTemplateForLegacy(coalitionId, number)
    if #self._templates == 0 then return nil end
    if type(number) == "table" then
        local total = 0
        for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
            total = total + (number[role] or 0)
        end
        number = total
    end
    local n = tonumber(number) or 1
    local best, bestDelta = nil, math.huge
    for _, tmpl in ipairs(self._templates) do
        if not tmpl.disabled then
            local delta = math.abs((tmpl.total or 0) - n)
            if delta < bestDelta then bestDelta = delta; best = tmpl end
        end
    end
    return best
end

--- Spawn a deployable troop group at a DCS trigger zone (MM DO SCRIPT).
-- @param side        string         "red" | "blue"
-- @param number      number|table   troop count or composition {inf=N,mg=N,...}
-- @param triggerName string         DCS trigger zone name
-- @param radius      number         random spread radius in metres (0 = at center)
-- @return boolean
function CTLDTroopManager:spawnGroupAtTrigger(side, number, triggerName, radius)
    local trig = trigger.misc.getZone(triggerName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDTroopManager:spawnGroupAtTrigger — zone not found: %s", tostring(triggerName))
        return false
    end
    local p2 = { x = trig.point.x, y = trig.point.z }
    local pt = { x = p2.x, y = land.getHeight(p2), z = p2.y }
    return self:spawnGroupAtPoint(side, number, pt, radius)
end

--- Spawn a deployable troop group at a Vec3 point (MM DO SCRIPT).
-- The closest template by unit count is used; group is registered as droppable.
-- @param side    string         "red" | "blue"
-- @param number  number|table   troop count or composition table
-- @param point   table          vec3 {x, y, z}
-- @param radius  number         random spread radius in metres
-- @return boolean
function CTLDTroopManager:spawnGroupAtPoint(side, number, point, radius)
    local coalitionId = (side == "red") and coalition.side.RED or coalition.side.BLUE
    local countryId   = (coalitionId == coalition.side.RED) and country.id.RUSSIA or country.id.USA
    radius = math.max(0, radius or 0)

    local tmpl = self:_resolveTemplateForLegacy(coalitionId, number)
    if not tmpl then
        ctld.utils.log("ERROR", "CTLDTroopManager:spawnGroupAtPoint — no template available")
        return false
    end

    local dcsGroup = CTLDObjectRegistry.spawnObject(
        tmpl._dbKey, coalitionId, countryId,
        point.x, point.z, 0,
        { circleRadius = radius }
    )
    if not dcsGroup then
        ctld.utils.log("ERROR", "CTLDTroopManager:spawnGroupAtPoint — spawnObject failed for key '%s'", tostring(tmpl._dbKey))
        return false
    end
    table.insert(self._droppedGroups[coalitionId], dcsGroup:getName())
    ctld.utils.log("INFO", "CTLDTroopManager:spawnGroupAtPoint — '%s' spawned (%s, %d units)",
        dcsGroup:getName(), side, tmpl.total)
    return true
end

--- Pre-load a named transport with troops, replacing any existing cargo.
-- Uses the template closest to number for the transport's coalition.
-- @param unitName string         DCS unit name of the transport
-- @param number   number|table   troop count or composition
-- @param troops   boolean        legacy param (ignored — always loads infantry template)
-- @return boolean
function CTLDTroopManager:preLoadTransport(unitName, number, troops)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDTroopManager:preLoadTransport — unit not found: %s", tostring(unitName))
        return false
    end
    local coalitionId = unit:getCoalition()
    local tmpl = self:_resolveTemplateForLegacy(coalitionId, number)
    if not tmpl then
        ctld.utils.log("ERROR", "CTLDTroopManager:preLoadTransport — no template for '%s'", unitName)
        return false
    end
    local weight = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        weight = weight + (tmpl[role] or 0) * (CTLDTroopManager._ROLE_WEIGHTS[role] or 109)
    end
    self._inTransit[unitName] = CTLDTroopGroup:new({
        templateKey  = tmpl._dbKey,
        templateName = tmpl.name,
        unitTotal    = tmpl.total,
        weight       = weight,
        hasJtac      = tmpl.hasJtac or false,
        coalitionId  = coalitionId,
        countryId    = unit:getCountry(),
    })
    self:_updateWeight(unitName)
    ctld.utils.log("INFO", "CTLDTroopManager:preLoadTransport — '%s' loaded [%s]", unitName, tmpl.name)
    return true
end

--- Force-deploy all troops from a named transport.
-- @param unitName string  DCS unit name
-- @return boolean
function CTLDTroopManager:unloadTransport(unitName)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDTroopManager:unloadTransport — unit not found: %s", tostring(unitName))
        return false
    end
    if not self:hasTroops(unitName) then return false end
    return self:deploy(unit)
end

--- Force-load troops into a named transport from the nearest active pickup zone.
-- Uses the first available template. No-op if no pickup zone found.
-- @param unitName string  DCS unit name
-- @return boolean
function CTLDTroopManager:loadTransport(unitName)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDTroopManager:loadTransport — unit not found: %s", tostring(unitName))
        return false
    end
    local zone = CTLDZoneManager.getInstance():getTroopZoneForUnit(unitName)
    if not zone or not zone:hasPickup() then
        ctld.utils.log("WARN", "CTLDTroopManager:loadTransport — no pickup zone for '%s'", unitName)
        return false
    end
    local tmpl = self._templates[1]
    if not tmpl then return false end
    return self:loadFromZone(unit, zone, tmpl)
end

--- Unload troops from a named AI transport when an enemy is detected within distance.
-- No-op for player-controlled units. Requires CTLDJTACDetector (LOS check).
-- @param unitName string  DCS unit name
-- @param distance number  detection radius in metres
-- @return boolean  true if troops were unloaded
function CTLDTroopManager:unloadInProximityToEnemy(unitName, distance)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then return false end
    local player = unit:getPlayerName()
    if player and player ~= "" then return false end  -- AI only
    if not self:hasTroops(unitName) then return false end
    local enemy = CTLDJTACDetector.findNearestVisibleEnemy(unit, "all", distance)
    if not enemy then return false end
    return self:deploy(unit)
end

--- Start a recurring watcher counting dropped groups in a zone, writing DCS flags.
-- Reschedules every 5 seconds. Call once from a DO SCRIPT trigger.
-- @param zoneName string          DCS trigger zone name
-- @param blueFlag number|string   flag for BLUE group count (nil = skip)
-- @param redFlag  number|string   flag for RED group count (nil = skip)
function CTLDTroopManager:startGroupCountWatcher(zoneName, blueFlag, redFlag)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDTroopManager:startGroupCountWatcher — zone not found: %s", tostring(zoneName))
        return
    end
    local center = { x = trig.point.x, y = trig.point.y, z = trig.point.z }
    local radius = trig.radius
    local self_ref = self
    local function _tick()
        local blueCount, redCount = 0, 0
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.BLUE] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() and #g:getUnits() > 0 then
                local u = g:getUnit(1)
                if u and ctld.utils.getDistance("groupWatcher", u:getPoint(), center) <= radius then
                    blueCount = blueCount + 1
                end
            end
        end
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.RED] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() and #g:getUnits() > 0 then
                local u = g:getUnit(1)
                if u and ctld.utils.getDistance("groupWatcher", u:getPoint(), center) <= radius then
                    redCount = redCount + 1
                end
            end
        end
        if blueFlag then trigger.action.setUserFlag(blueFlag, blueCount) end
        if redFlag  then trigger.action.setUserFlag(redFlag,  redCount)  end
        timer.scheduleFunction(function()
            self_ref:startGroupCountWatcher(zoneName, blueFlag, redFlag)
        end, nil, timer.getTime() + 5)
    end
    _tick()
end

--- Start a recurring watcher counting dropped units in a zone, writing DCS flags.
-- @param zoneName string          DCS trigger zone name
-- @param blueFlag number|string   flag for BLUE unit count (nil = skip)
-- @param redFlag  number|string   flag for RED unit count (nil = skip)
function CTLDTroopManager:startUnitCountWatcher(zoneName, blueFlag, redFlag)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDTroopManager:startUnitCountWatcher — zone not found: %s", tostring(zoneName))
        return
    end
    local center = { x = trig.point.x, y = trig.point.y, z = trig.point.z }
    local radius = trig.radius
    local self_ref = self
    local function _tick()
        local blueCount, redCount = 0, 0
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.BLUE] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() then
                for _, u in ipairs(g:getUnits()) do
                    if u:isExist() and ctld.utils.getDistance("unitWatcher", u:getPoint(), center) <= radius then
                        blueCount = blueCount + 1
                    end
                end
            end
        end
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.RED] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() then
                for _, u in ipairs(g:getUnits()) do
                    if u:isExist() and ctld.utils.getDistance("unitWatcher", u:getPoint(), center) <= radius then
                        redCount = redCount + 1
                    end
                end
            end
        end
        if blueFlag then trigger.action.setUserFlag(blueFlag, blueCount) end
        if redFlag  then trigger.action.setUserFlag(redFlag,  redCount)  end
        timer.scheduleFunction(function()
            self_ref:startUnitCountWatcher(zoneName, blueFlag, redFlag)
        end, nil, timer.getTime() + 5)
    end
    _tick()
end
