-- ============================================================
-- CTLD_crate.lua
-- CTLDCrate entity + CTLDCrateManager singleton
--
-- Dependencies: CTLDConfig (ctld.gs), CTLDUtils, EventDispatcher
--
-- Crate lifecycle states:
--   spawned  : on ground, freshly created (never moved)
--   loaded   : inside / attached to a transport
--   falling  : in air, descending (drop or parachute)
--   landed   : on ground after a transport cycle
--   unpacked : contents deployed (terminal state)
--
-- spawnMethod values:
--   crate_spawn   : spawned from F10 menu (logistics pool)
--   vehicle_pack  : result of packing a vehicle
--   mission_maker : pre-placed by mission maker (detected via INIT-B)
--
-- NOTE: Feature A (virtual parachute) stubs are present but
--       not implemented. Search "Feature A" to locate them.
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDCrate  (entity)
-- ============================================================

CTLDCrate = class()

CTLDCrate.STATE = {
    SPAWNED  = "spawned",
    LOADED   = "loaded",
    FALLING  = "falling",
    LANDED   = "landed",
    UNPACKED = "unpacked",
}

CTLDCrate.SPAWN_METHOD = {
    CRATE_SPAWN   = "crate_spawn",
    VEHICLE_PACK  = "vehicle_pack",
    MISSION_MAKER = "mission_maker",
    MENU_CTLD     = "menu_ctld",
}

--- Constructor.
-- @param data table:
--   crateName (string)          DCS unitName of the StaticObject
--   descriptor (table)          CTLD crate descriptor (from spawnableCrates)
--   spawnMethod (string)        CTLDCrate.SPAWN_METHOD.*
--   position (vec3)
--   coalition (number)          coalition.side.*
--   heading (number|nil)        radians, defaults to 0
--   spawnedBy (string|nil)      player name if spawned via menu
--   dcsStatic (StaticObject|nil)
function CTLDCrate:init(data)
    self.crateName    = data.crateName
    self.descriptor   = data.descriptor
    self.state        = CTLDCrate.STATE.SPAWNED
    self.spawnMethod  = data.spawnMethod
    self.spawnedBy    = data.spawnedBy or nil
    self.spawnTime    = timer.getAbsTime()
    self.position     = data.position
    self.heading      = data.heading or 0
    self.coalition    = data.coalition
    self.loadedBy     = nil
    self.loadTime     = nil
    self.dcsStatic    = data.dcsStatic or nil
    self.modelKey     = data.modelKey  or "load"
    self.hasMoved     = false
    self.canBeUnpacked = true
    -- Feature A: virtual parachute
    self.isParachuting          = false
    self.parachuteStartAltitude = nil
    self.estimatedLandingTime   = nil
    -- Feature B: virtual slingload
    self.inTransitOnSlingload   = false
    self.timestamp              = timer.getAbsTime()
end

--- Load the crate into a transport unit.
-- @param transport Unit
function CTLDCrate:load(transport)
    self.state    = CTLDCrate.STATE.LOADED
    self.loadedBy = transport
    self.loadTime = timer.getAbsTime()
    self.hasMoved = true
end

--- Unload the crate to the ground (transport is landed).
-- @param position vec3
function CTLDCrate:unload(position)
    self.state    = CTLDCrate.STATE.LANDED
    self.position = position
    self.loadedBy = nil
    self.loadTime = nil
end

--- Drop the crate in flight (transitions to falling).
-- @param position vec3  current air position at drop time
function CTLDCrate:drop(position)
    self.state    = CTLDCrate.STATE.FALLING
    self.position = position
    self.loadedBy = nil
    self.loadTime = nil
end

--- [Feature A stub] Start virtual parachute descent.
-- @param altitude number  current altitude AGL (metres)
function CTLDCrate:startParachute(altitude)
    -- TODO Feature A: implement parachute physics (descent rate, lateral drift)
    self.state                   = CTLDCrate.STATE.FALLING
    self.isParachuting           = true
    self.parachuteStartAltitude  = altitude
end

--- Crate touches the ground (after falling or parachuting).
-- @param position vec3
function CTLDCrate:land(position)
    self.state         = CTLDCrate.STATE.LANDED
    self.position      = position
    self.isParachuting = false
end

--- Mark crate as unpacked (contents deployed).
function CTLDCrate:unpack()
    self.state = CTLDCrate.STATE.UNPACKED
end

--- Destroy the associated DCS static object.
function CTLDCrate:destroy()
    if self.dcsStatic and self.dcsStatic:isExist() then
        self.dcsStatic:destroy()
    end
    self.dcsStatic = nil
end

--- Returns true if the crate is on the ground and interactable.
function CTLDCrate:isOnGround()
    return self.state == CTLDCrate.STATE.SPAWNED
        or self.state == CTLDCrate.STATE.LANDED
end

--- Returns true if the crate is currently in a transport.
function CTLDCrate:isLoaded()
    return self.state == CTLDCrate.STATE.LOADED
end

--- Returns true if this crate can be unpacked.
-- A crate loaded at least once (hasMoved=true) satisfies forceCrateToBeMoved,
-- regardless of how far the transport has physically travelled.
-- @param forceCrateToBeMoved boolean  value from ctld.gs("forceCrateToBeMoved")
function CTLDCrate:canUnpack(forceCrateToBeMoved)
    if not self:isOnGround()  then return false end
    if not self.canBeUnpacked then return false end
    if forceCrateToBeMoved and not self.hasMoved then return false end
    return true
end

-- ============================================================
-- CTLDCrateManager  (singleton)
-- ============================================================

CTLDCrateManager = class()

local _cmInstance = nil

function CTLDCrateManager.getInstance()
    if _cmInstance == nil then
        _cmInstance = setmetatable({}, CTLDCrateManager)
        _cmInstance.crates            = {}   -- [crateName] = CTLDCrate
        _cmInstance._parachuteEffect  = CTLDNullParachuteEffect:new()
        _cmInstance._hoverStatus      = {}   -- [unitName] = secondsRemaining
        _cmInstance._nativeLoadDist   = {}   -- [crateName] = dist at DCS-native load time
        local pm = CTLDPlayerManager.getInstance()
        pm:registerMenuSection({ key = "crates", manager = _cmInstance, method = "buildMenuSection",  configKey = "enableCrates",    order = 40 })
        pm:registerMenuSection({ key = "smoke",  manager = _cmInstance, method = "buildSmokeSection", configKey = "enableSmokeDrop", order = 80 })
        -- Refresh "Load Crate" submenu for all players near a crate when it appears or disappears.
        local ed = EventDispatcher.getInstance()
        ed:subscribe("OnCrateSpawned", function(payload)
            CTLDCrateManager.getInstance():_refreshNearbyPlayers(payload.position)
        end)
        ed:subscribe("OnCrateCleared", function(payload)
            CTLDCrateManager.getInstance():_refreshNearbyPlayers(payload.position)
        end)
        -- Feature B: start hover-slingload polling (1s tick)
        timer.scheduleFunction(function()
            CTLDCrateManager.getInstance():checkHoverStatus()
        end, {}, timer.getTime() + 1)
    end
    return _cmInstance
end

--- Refresh the "Load Crate" submenu for all players within 200 m of a position.
-- Called on OnCrateSpawned and OnCrateCleared so every nearby transport sees
-- the current list regardless of who triggered the action.
-- @param position vec3  reference point (crate position)
function CTLDCrateManager:_refreshNearbyPlayers(position)
    if not position then return end
    local pm = CTLDPlayerManager.getInstance()
    for unitName in pairs(pm._players) do
        local unit = Unit.getByName(unitName)
        if unit and unit:isExist() then
            local dist = ctld.utils.getDistance("_refreshNearbyPlayers", unit:getPoint(), position)
            if dist <= 300 then
                self:refreshLoadCrateSectionForUnit(unitName)
                self:refreshUnpackSectionForUnit(unitName)
            end
        end
    end
end

--- Refresh the "Load Crate" submenu for a single player looked up by unit name.
-- @param unitName string
function CTLDCrateManager:refreshLoadCrateSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshLoadCrateSection(playerObj) end
end

--- Rebuild the "Load Crate" dynamic submenu for playerObj.
-- Groups available crates within 50 m by descriptor type with count.
-- Called on land, crate spawn, crate cleared, and after each load action.
-- @param playerObj CTLDPlayer
function CTLDCrateManager:refreshLoadCrateSection(playerObj)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local cratesSub = ctld.tr("Crate Commands")
    local loadSub   = ctld.tr("Load Crate")

    menu:clearBranch({ root, cratesSub, loadSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, cratesSub, loadSub },
            ctld.tr("Land to load crates"), function() end, {})
        menu:refresh()
        return
    end

    -- Group nearby crates (50 m) by descriptor type
    local nearby = self:getCratesInRange(transport:getPoint(), 50)
    local byType = {}   -- [desc] = { count, descriptor }
    for _, crate in ipairs(nearby) do
        local desc = crate.descriptor and crate.descriptor.desc or "Unknown"
        if not byType[desc] then
            byType[desc] = { count = 0, descriptor = crate.descriptor }
        end
        byType[desc].count = byType[desc].count + 1
    end

    if not next(byType) then
        menu:addCommand({ root, cratesSub, loadSub },
            ctld.tr("No crates within 50m"), function() end, {})
    else
        for desc, data in pairs(byType) do
            local label = string.format("%s (%d)", desc, data.count)
            menu:addCommand({ root, cratesSub, loadSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    if ctld.utils.inAir(t) then
                        trigger.action.outTextForGroup(t:getGroup():getID(),
                            ctld.tr("You must land before you can load a crate!"), 10)
                        return
                    end
                    local limits   = ctld.gs("internalCargoLimits") or {}
                    local capacity = limits[t:getTypeName()] or 1
                    local onboard  = 0
                    local mgr = CTLDCrateManager.getInstance()
                    for _, c in pairs(mgr.crates) do
                        if c:isLoaded() and c.loadedBy == t then onboard = onboard + 1 end
                    end
                    if onboard >= capacity then
                        trigger.action.outTextForGroup(t:getGroup():getID(),
                            ctld.tr("Maximum number of crates are on board!"), 10)
                        return
                    end
                    local candidates = mgr:getCratesInRange(t:getPoint(), 50)
                    local best, bestDist = nil, math.huge
                    for _, c in ipairs(candidates) do
                        if c.descriptor and c.descriptor.desc == arg.crateDesc then
                            local d = ctld.utils.getDistance("loadCrate", t:getPoint(), c.position)
                            if d < bestDist then bestDist = d; best = c end
                        end
                    end
                    if not best then
                        trigger.action.outTextForGroup(t:getGroup():getID(),
                            ctld.tr("No crates within 50m to load!"), 10)
                        mgr:refreshLoadCrateSectionForUnit(arg.unitName)
                        return
                    end
                    mgr:loadCrate(best.crateName, t)
                    trigger.action.outTextForGroup(t:getGroup():getID(),
                        ctld.tr("Loaded %1 crate!", best.descriptor.desc), 10)
                end,
                { unitName = playerObj.unitName, crateDesc = desc })
        end
    end
    menu:refresh()
end

--- Refresh the "Unpack Crate" submenu for a single player by unit name.
-- @param unitName string
function CTLDCrateManager:refreshUnpackSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshUnpackSection(playerObj) end
end

--- Rebuild the "Unpack Crate" dynamic submenu for playerObj.
-- Lists assembleable crate sets (count >= cratesRequired) within 300 m.
-- Each entry spawns the vehicle at unpack time.
-- Called on land, crate spawn, crate cleared.
-- @param playerObj CTLDPlayer
function CTLDCrateManager:refreshUnpackSection(playerObj)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local cratesSub = ctld.tr("Crate Commands")
    local unpackSub = ctld.tr("Unpack Crate")

    menu:clearBranch({ root, cratesSub, unpackSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, cratesSub, unpackSub },
            ctld.tr("Land to unpack crates"), function() end, {})
        menu:refresh()
        return
    end

    local nearby = self:getCratesInRange(transport:getPoint(), 300)

    -- FOB sentinel (unit = "FOB"): handled by CTLDFOBManager, not spawned as vehicles.
    local FOB_SENTINELS = { ["FOB"] = true }

    -- Group ground crates by descriptor.unit (hasMoved not checked here — checked at click time)
    -- FOB sentinels are excluded from this table.
    local byUnit    = {}   -- [unitType] = { count, descriptor }
    local unitOrder = {}
    local fobCount  = 0
    for _, crate in ipairs(nearby) do
        if crate:isOnGround() and crate.canBeUnpacked
            and crate.descriptor and crate.descriptor.unit
        then
            local ut = crate.descriptor.unit
            if FOB_SENTINELS[ut] then
                fobCount = fobCount + 1
            else
                if not byUnit[ut] then
                    byUnit[ut] = { count = 0, descriptor = crate.descriptor }
                    table.insert(unitOrder, ut)
                end
                byUnit[ut].count = byUnit[ut].count + 1
            end
        end
    end

    local hasAny = false

    -- Standard vehicle unpack entries (non-FOB)
    for _, ut in ipairs(unitOrder) do
        local info     = byUnit[ut]
        local required = info.descriptor.cratesRequired or 1
        if info.count >= required then
            hasAny = true
            local label = string.format("%s (%d/%d)", info.descriptor.desc, info.count, required)
            menu:addCommand({ root, cratesSub, unpackSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    local gid = t:getGroup():getID()
                    if ctld.utils.inAir(t) then
                        trigger.action.outTextForGroup(gid,
                            ctld.tr("You must land before unpacking crates!"), 10)
                        return
                    end
                    local mgr   = CTLDCrateManager.getInstance()
                    local nearC = mgr:getCratesInRange(t:getPoint(), 300)
                    -- Collect crates: forceCrateToBeMoved does not apply to unpack
                    local toUnpack = {}
                    for _, c in ipairs(nearC) do
                        if c:isOnGround() and c.canBeUnpacked
                            and c.descriptor
                            and c.descriptor.unit == arg.unitType
                        then
                            table.insert(toUnpack, c)
                            if #toUnpack >= arg.cratesRequired then break end
                        end
                    end
                    if #toUnpack < arg.cratesRequired then
                        trigger.action.outTextForGroup(gid,
                            ctld.tr("Not enough crates nearby to unpack!"), 10)
                        mgr:refreshUnpackSectionForUnit(arg.unitName)
                        return
                    end
                    -- Delegate to AA assembly manager if this crate belongs to an AA template.
                    -- CTLDCrateAssemblyManager handles repair/rearm/assembly with correct
                    -- DCS type names and its own 100m offset + 50m radius placement.
                    local aaMgr = CTLDCrateAssemblyManager.getInstance()
                    if aaMgr:tryUnpackOrRepair(t, toUnpack[1], mgr.crates) then
                        -- AA manager consumed the action — also destroy the other collected crates
                        -- (tryUnpackOrRepair only destroys what it assembles internally).
                        -- Note: for single-crate AA parts tryUnpackOrRepair already handles destruction.
                        return
                    end

                    -- Standard (non-AA) path: unpack crates, spawn vehicle ≥ 50 m away.
                    for _, c in ipairs(toUnpack) do
                        mgr:unpackCrate(c.crateName, t)
                    end
                    local MIN_UNPACK_DIST = 50
                    local safeDist = math.max(
                        MIN_UNPACK_DIST,
                        (ctld.utils.getSecureDistanceFromUnit(arg.unitName) or 10) + 5)
                    local spawnInfo = ctld.utils.getSpawnObjectPositions(t, 1, safeDist)
                    local spawnPos  = spawnInfo.positions[1]
                    local desc = arg.descriptor
                    if desc and desc.unit and spawnPos then
                        local coa = arg.coalition
                        local cId = (coa == coalition.side.RED) and country.id.RUSSIA or country.id.USA
                        mgr:_spawnUnpacked(desc, spawnPos, coa, cId)
                    end
                    trigger.action.outTextForGroup(gid,
                        ctld.tr("%1 unpacked successfully!", arg.descriptor.desc), 10)
                end,
                {
                    unitName       = playerObj.unitName,
                    groupId        = playerObj.groupId,
                    coalition      = playerObj.coalition,
                    unitType       = ut,
                    cratesRequired = required,
                    descriptor     = info.descriptor,
                })
        end
    end

    -- FOB unpack entry: delegate to CTLDFOBManager (handles its own crate counting & guards)
    if fobCount > 0 then
        hasAny = true
        local fobDesc     = CTLDCrateManager.getInstance():findDescriptorByUnitType("FOB")
        local fobRequired = (fobDesc and fobDesc.cratesRequired) or 3
        local fobLabel    = string.format("%s (%d/%d)", ctld.tr("Build FOB"), fobCount, fobRequired)
        menu:addCommand({ root, cratesSub, unpackSub }, fobLabel,
            function(arg)
                local t = Unit.getByName(arg.unitName)
                if not (t and t:isExist()) then return end
                CTLDFOBManager.getInstance():unpackFOBCrates(t, arg.unitName)
            end,
            { unitName = playerObj.unitName })
    end

    if not hasAny then
        menu:addCommand({ root, cratesSub, unpackSub },
            ctld.tr("No complete crate sets nearby"), function() end, {})
    end
    menu:refresh()
end

--- Replace the parachute visual effect handler.
-- @param effect CTLDParachuteEffect
function CTLDCrateManager:setParachuteEffect(effect)
    self._parachuteEffect = effect
end

-- ============================================================
-- Feature B — Virtual Slingload
-- ============================================================

--- Return the first slingloaded crate for a given transport, or nil.
-- @param transport Unit
-- @return CTLDCrate or nil
function CTLDCrateManager:_getSlingloadedCrate(transport)
    for _, crate in pairs(self.crates) do
        if crate.inTransitOnSlingload and crate.loadedBy == transport then
            return crate
        end
    end
    return nil
end

--- Polling tick (1 s). Called by the timer loop started in getInstance().
-- For each active player with canSlingload=true and in-air transport:
--   1. Overspeed check: if speed > maxSlingloadSpeed → crate lost.
--   2. Hover pickup: find nearest eligible ground crate, count down hoverTime,
--      then hook it (load + destroy DCS static + publish OnCrateLoaded).
function CTLDCrateManager:checkHoverStatus()
    -- Reschedule unconditionally
    timer.scheduleFunction(function()
        CTLDCrateManager.getInstance():checkHoverStatus()
    end, {}, timer.getTime() + 1)

    -- DCS-native cargo detection (always, independent of slingload config)
    self:_checkNativeDCSCargo()

    if ctld.gs("enableHoverSlingload") ~= true then return end

    local unitActions = ctld.gs("unitActions")        or {}
    local cargoLimits = ctld.gs("internalCargoLimits") or {}
    local maxDist     = ctld.gs("maxDistanceFromCrate") or 5.5
    local minH        = ctld.gs("minimumHoverHeight")   or 7.5
    local maxH        = ctld.gs("maximumHoverHeight")   or 12.0
    local hoverTime   = ctld.gs("hoverTime")            or 10
    local maxSpeed    = ctld.gs("maxSlingloadSpeed")    or 50

    local players = CTLDPlayerManager.getInstance()._players

    for unitName, playerObj in pairs(players) do
        local acts = unitActions[playerObj.typeName]
        if acts and acts.canSlingload then
            local transport = Unit.getByName(unitName)
            if transport and transport:isExist() and ctld.utils.inAir(transport) then

                -- 1. Overspeed check
                local vel   = transport:getVelocity()
                local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z)
                if speed > maxSpeed then
                    local lost = self:_getSlingloadedCrate(transport)
                    if lost then
                        lost.inTransitOnSlingload = false
                        lost:destroy()
                        self:_unregister(lost.crateName)
                        self:_publish("OnCrateLost", {
                            crate     = lost,
                            crateName = lost.crateName,
                            coalition = lost.coalition,
                            transport = transport,
                            trigger   = "slingload_overspeed",
                            timestamp = timer.getAbsTime(),
                        })
                        trigger.action.outTextForGroup(playerObj.groupId,
                            string.format(ctld.tr("Too fast! Slingloaded crate lost: %s"), lost.descriptor.desc), 10)
                        CTLDPlayerManager.getInstance():refreshForUnit(unitName)
                    end
                    self._hoverStatus[unitName] = nil

                else
                    -- 2. Hover pickup (only if below capacity)
                    local count = 0
                    for _, c in pairs(self.crates) do
                        if c.inTransitOnSlingload and c.loadedBy == transport then
                            count = count + 1
                        end
                    end
                    local capacity = cargoLimits[playerObj.typeName] or 1

                    if count < capacity then
                        local transportPos  = transport:getPoint()
                        local nearestCrate  = nil
                        local nearestDist   = math.huge
                        local warnTooLow    = false
                        local warnTooHigh   = false

                        for _, crate in pairs(self.crates) do
                            if crate:isOnGround()
                                and crate.descriptor
                                and crate.descriptor.unit ~= "FOB"
                            then
                                local cratePos = (crate.dcsStatic and crate.dcsStatic:isExist())
                                    and crate.dcsStatic:getPoint()
                                    or  crate.position
                                local dist = ctld.utils.getDistance("checkHoverStatus", transportPos, cratePos)
                                if dist < maxDist then
                                    local heightDiff = transportPos.y - cratePos.y
                                    if heightDiff >= minH and heightDiff <= maxH then
                                        if dist < nearestDist then
                                            nearestCrate = crate
                                            nearestDist  = dist
                                        end
                                    elseif heightDiff < minH then
                                        warnTooLow = true
                                    else
                                        warnTooHigh = true
                                    end
                                end
                            end
                        end

                        if nearestCrate then
                            if self._hoverStatus[unitName] == nil then
                                self._hoverStatus[unitName] = hoverTime
                            end
                            self._hoverStatus[unitName] = self._hoverStatus[unitName] - 1
                            if self._hoverStatus[unitName] > 0 then
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(
                                        ctld.tr("Hovering above %s crate.\n\nHold hover for %d seconds!\n\nIf the countdown stops you're too far away!"),
                                        nearestCrate.descriptor.desc,
                                        self._hoverStatus[unitName]), 10, true)
                            else
                                self._hoverStatus[unitName] = nil
                                nearestCrate.inTransitOnSlingload = true
                                nearestCrate:load(transport)
                                if nearestCrate.dcsStatic and nearestCrate.dcsStatic:isExist() then
                                    nearestCrate.dcsStatic:destroy()
                                    nearestCrate.dcsStatic = nil
                                end
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(ctld.tr("Slingloaded %s crate!"), nearestCrate.descriptor.desc), 10)
                                self:_publish("OnCrateLoaded", {
                                    crate           = nearestCrate,
                                    crateName       = nearestCrate.crateName,
                                    carrierUnitName = transport:getName(),
                                    coalition       = nearestCrate.coalition,
                                    descriptor      = nearestCrate.descriptor,
                                    trigger         = "slingload",
                                    timestamp       = timer.getAbsTime(),
                                })
                                CTLDPlayerManager.getInstance():refreshForUnit(unitName)
                            end
                        else
                            if warnTooLow then
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(ctld.tr("Too low to hook crate.\n\nHold hover for %d seconds"), hoverTime), 5, true)
                            elseif warnTooHigh then
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(ctld.tr("Too high to hook crate.\n\nHold hover for %d seconds"), hoverTime), 5, true)
                            end
                            self._hoverStatus[unitName] = nil
                        end
                    else
                        self._hoverStatus[unitName] = nil
                    end
                end

            else
                -- Not in air: reset hover counter
                self._hoverStatus[unitName] = nil
            end
        end
    end
end

--- Return true if world-space point `pt` is inside the bounding box of `unitPos`.
-- unitPos : result of unit:getPosition() = { p=Vec3, x=Vec3, y=Vec3, z=Vec3 }
-- bbox    : { min=Vec3, max=Vec3 } in local coords (from unit:getDesc().box)
-- margin  : extra metres added on every face (default 0)
local function _pointInBBox(unitPos, bbox, pt, margin)
    margin = margin or 0
    local dx = pt.x - unitPos.p.x
    local dy = pt.y - unitPos.p.y
    local dz = pt.z - unitPos.p.z
    local lx = dx * unitPos.x.x + dy * unitPos.x.y + dz * unitPos.x.z
    local ly = dx * unitPos.y.x + dy * unitPos.y.y + dz * unitPos.y.z
    local lz = dx * unitPos.z.x + dy * unitPos.z.y + dz * unitPos.z.z
    return lx >= (bbox.min.x - margin) and lx <= (bbox.max.x + margin)
       and ly >= (bbox.min.y - margin) and ly <= (bbox.max.y + margin)
       and lz >= (bbox.min.z - margin) and lz <= (bbox.max.z + margin)
end

--- Detect DCS-native cargo load/unload via bounding-box containment (1 s tick).
-- Called from checkHoverStatus() unconditionally.
--
-- No S_EVENT_CARGO_LOADED / S_EVENT_CARGO_UNLOADED exists in the DCS API.
-- Detection is purely positional:
--   LOAD  : crate.dcsStatic:getPoint() is inside the transport's 3-D bounding box.
--           Works while the aircraft is still on the ground (before takeoff),
--           so CTLD marks the crate as taken before any other transport sees it.
--   UNLOAD: crate state is LOADED (via dcs_native, so dcsStatic still exists),
--           and the static's current position is now OUTSIDE the transport's bbox.
--
-- CTLD-managed loads call crate:destroy() → dcsStatic = nil: those crates are
-- silently skipped here (outer check `dcsStatic and dcsStatic:isExist()`).
function CTLDCrateManager:_checkNativeDCSCargo()
    local dynamicUnits = ctld.gs("dynamicCargoUnits") or {}
    if #dynamicUnits == 0 then return end

    -- Build candidate transport list (ALL dynamic transports, ground OR air).
    -- We pre-fetch position and bbox so we don't call getPosition()/getDesc()
    -- more than once per transport per tick.
    local pm         = CTLDPlayerManager.getInstance()
    local transports = {}   -- array of { transport, unitName, playerObj, unitPos, bbox }
    for unitName, playerObj in pairs(pm._players) do
        local transport = Unit.getByName(unitName)
        if transport and transport:isExist() and self:_isDynamicCapable(transport) then
            local desc = transport:getDesc()
            if desc and desc.box then
                transports[#transports + 1] = {
                    transport = transport,
                    unitName  = unitName,
                    playerObj = playerObj,
                    unitPos   = transport:getPosition(),
                    bbox      = desc.box,
                }
            end
        end
    end

    for _, crate in pairs(self.crates) do
        local dcsStatic = crate.dcsStatic
        if dcsStatic and dcsStatic:isExist() then
            local cratePos = dcsStatic:getPoint()

            -- ── LOAD detection ─────────────────────────────────────────────
            -- ── LOAD detection ─────────────────────────────────────────────
            -- Crate is on ground AND its static is inside a transport's bbox.
            -- 0.5 m margin to account for attachment offsets.
            if crate:isOnGround() then
                for _, entry in ipairs(transports) do
                    if _pointInBBox(entry.unitPos, entry.bbox, cratePos, 0.5) then
                        local ap = entry.transport:getPoint()
                        local dx = cratePos.x - ap.x
                        local dy = cratePos.y - ap.y
                        local dz = cratePos.z - ap.z
                        -- Memorize attach distance for drift-based unload detection.
                        self._nativeLoadDist[crate.crateName] =
                            math.sqrt(dx*dx + dy*dy + dz*dz)
                        crate:load(entry.transport)
                        self:_publish("OnCrateLoaded", {
                            crate           = crate,
                            crateName       = crate.crateName,
                            carrierUnitName = entry.unitName,
                            coalition       = crate.coalition,
                            descriptor      = crate.descriptor,
                            method          = "dcs_native",
                            timestamp       = timer.getAbsTime(),
                        })
                        pm:refreshForUnit(entry.unitName)
                        self:refreshUnpackSectionForUnit(entry.unitName)
                        ctld.utils.log("INFO",
                            "CTLDCrateManager: DCS native LOAD — crate=%s carrier=%s dist=%.2f",
                            crate.crateName, entry.unitName,
                            self._nativeLoadDist[crate.crateName])
                        break
                    end
                end

            -- ── UNLOAD detection ───────────────────────────────────────────
            -- Crate is LOADED and dcsStatic is still alive → DCS-native path.
            -- (CTLD-managed loads destroy the static → dcsStatic = nil, never reach here.)
            -- Detect unload by distance drift: when dist > baseline + 3 m the crate
            -- has been set down and the aircraft has moved away.
            -- This avoids bbox margin false-negatives when aircraft hovers just above
            -- the dropped crate (bbox overlap would prevent detection).
            elseif crate:isLoaded() then
                local transport = crate.loadedBy
                if not transport or not transport:isExist() then
                    -- Transport destroyed while crate was natively loaded: reset.
                    self._nativeLoadDist[crate.crateName] = nil
                    crate.position = cratePos
                    crate.state    = CTLDCrate.STATE.LANDED
                    crate.loadedBy = nil
                    crate.loadTime = nil
                    ctld.utils.log("INFO",
                        "CTLDCrateManager: DCS native UNLOAD (transport lost) — crate=%s",
                        crate.crateName)
                else
                    local tp   = transport:getPoint()
                    local dx   = cratePos.x - tp.x
                    local dy   = cratePos.y - tp.y
                    local dz   = cratePos.z - tp.z
                    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                    local baseline = self._nativeLoadDist[crate.crateName] or 0
                    if dist > baseline + 3 then
                        local carrierName = transport:getName()
                        local playerObj   = pm:getPlayer(carrierName)
                        self._nativeLoadDist[crate.crateName] = nil
                        crate.position = cratePos
                        crate.state    = CTLDCrate.STATE.LANDED
                        crate.loadedBy = nil
                        crate.loadTime = nil
                        self:_publish("OnCrateUnloaded", {
                            crate      = crate,
                            crateName  = crate.crateName,
                            coalition  = crate.coalition,
                            descriptor = crate.descriptor,
                            method     = "dcs_native",
                            timestamp  = timer.getAbsTime(),
                        })
                        if playerObj then
                            pm:refreshForUnit(carrierName)
                            self:refreshUnpackSectionForUnit(carrierName)
                            self:refreshLoadCrateSection(playerObj)
                            self:refreshRequestEquipmentSection(playerObj)
                        end
                        ctld.utils.log("INFO",
                            "CTLDCrateManager: DCS native UNLOAD — crate=%s dist=%.2f baseline=%.2f",
                            crate.crateName, dist, baseline)
                    end
                end
            end
        end
    end
end

--- Release the slingloaded crate safely (transport at or near ground, AGL ≤ maximumHoverHeight).
-- Refuses if transport AGL > maximumHoverHeight with an informational message.
-- Transitions crate: loaded → landed. Spawns at a position offset ahead of the transport.
-- Publishes OnCrateUnloaded(trigger="slingload_release").
-- @param transport    Unit
-- @param playerObj    table   {groupId, unitName}
function CTLDCrateManager:releaseSlingload(transport, playerObj)
    local crate = self:_getSlingloadedCrate(transport)
    if not crate then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No slingloaded crate on board."), 8)
        return
    end

    local pos      = transport:getPoint()
    local groundH  = land.getHeight({ x = pos.x, y = pos.z })
    local agl      = pos.y - groundH
    local maxRelH  = ctld.gs("maximumHoverHeight") or 12.0

    if agl > maxRelH then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Too high to release slingload. Descend below %dm AGL (current: %dm AGL)."),
                math.floor(maxRelH), math.floor(agl)), 8)
        return
    end

    -- Spawn position: directly below transport on terrain
    local spawnPos = { x = pos.x, y = groundH, z = pos.z }
    crate.inTransitOnSlingload = false
    -- unloadCrate: transitions state, respawns static, publishes OnCrateUnloaded + OnCrateSpawned
    self:unloadCrate(crate.crateName, spawnPos, "slingload_release")
    trigger.action.outTextForGroup(playerObj.groupId,
        string.format(ctld.tr("%s crate safely released."), crate.descriptor.desc), 10)
    CTLDPlayerManager.getInstance():refreshForUnit(playerObj.unitName)
end

--- Cut the slingload (emergency drop, any altitude).
-- AGL > 40m → crate is destroyed (too high, impact damage).
-- AGL ≤ 40m → crate lands at a position computed from transport inertia (no parachute delay).
-- Publishes OnCrateUnloaded(trigger="slingload_cut") or OnCrateLost(trigger="slingload_cut_impact").
-- @param transport    Unit
-- @param playerObj    table   {groupId, unitName}
function CTLDCrateManager:cutSlingload(transport, playerObj)
    local crate = self:_getSlingloadedCrate(transport)
    if not crate then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No slingloaded crate on board."), 8)
        return
    end

    local pos      = transport:getPoint()
    local groundH  = land.getHeight({ x = pos.x, y = pos.z })
    local agl      = pos.y - groundH

    crate.inTransitOnSlingload = false

    if agl > 40.0 then
        -- Too high: crate destroyed on impact
        local lostPos = crate.position
        crate:destroy()
        self:_unregister(crate.crateName)
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Too high! %s crate destroyed on impact."), crate.descriptor.desc), 10)
        self:_publish("OnCrateLost", {
            crate     = crate,
            crateName = crate.crateName,
            coalition = crate.coalition,
            transport = transport,
            trigger   = "slingload_cut_impact",
            timestamp = timer.getAbsTime(),
        })
        self:_publish("OnCrateCleared", {
            crateName  = crate.crateName,
            position   = lostPos,
            coalition  = crate.coalition,
            descriptor = crate.descriptor,
            reason     = "destroyed",
            timestamp  = timer.getAbsTime(),
        })
    else
        -- Drop with inertia drift (reuses FA calcDropPosition, descentRate=0 → immediate land)
        local landPos, _ = ctld.utils.calcDropPosition(transport, 0)
        crate:land(landPos)
        -- TODO: re-spawn DCS static at landPos (requires coalition.addStaticObject — pending Hoggit verification)
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("%s crate dropped below you."), crate.descriptor.desc), 10)
        self:_publish("OnCrateUnloaded", {
            crate           = crate,
            crateName       = crate.crateName,
            position        = landPos,
            coalition       = crate.coalition,
            method          = "slingload_cut",
            trigger         = "slingload_cut",
            timestamp       = timer.getAbsTime(),
        })
        -- Crate landed: notify nearby players it is loadable.
        self:_publish("OnCrateSpawned", {
            crate      = crate,
            crateName  = crate.crateName,
            position   = landPos,
            coalition  = crate.coalition,
            descriptor = crate.descriptor,
            spawnedBy  = nil,
            spawnMethod = "slingload_cut",
            timestamp  = timer.getAbsTime(),
        })
    end
    CTLDPlayerManager.getInstance():refreshForUnit(playerObj.unitName)
end

-- ============================================================
-- Internal helpers
-- ============================================================

local _log = ctld.utils.log

function CTLDCrateManager:_register(crate)
    self.crates[crate.crateName] = crate
end

function CTLDCrateManager:_unregister(crateName)
    self.crates[crateName] = nil
end

function CTLDCrateManager:_publish(eventName, payload)
    EventDispatcher.getInstance():publish(eventName, payload)
end

-- ============================================================
-- Public API
-- ============================================================

--- Return true if the unit type is listed in dynamicCargoUnits (native DCS cargo system).
-- @param unit DCS Unit
-- @return bool
function CTLDCrateManager:_isDynamicCapable(unit)
    local typeLower = string.lower(unit:getTypeName())
    for _, name in ipairs(ctld.gs("dynamicCargoUnits") or {}) do
        if string.find(typeLower, string.lower(name), 1, true) then
            return true
        end
    end
    return false
end

--- Resolve the spawnableCratesModels key for a given transport unit.
-- Returns "dynamic" if the unit is in dynamicCargoUnits and slingLoad is off,
-- "sling" if slingLoad is enabled, "load" otherwise.
-- @param unit DCS Unit
-- @return string  "load" | "sling" | "dynamic"
function CTLDCrateManager:_crateModelKey(unit)
    if ctld.gs("slingLoad") then return "sling" end
    if self:_isDynamicCapable(unit) then return "dynamic" end
    return "load"
end

--- Spawn a new crate from the F10 menu or as the result of packing a vehicle.
-- Uses coalition.addStaticObject (Hoggit: DCS_func_addStaticObject).
-- @param descriptor  table         CTLD crate descriptor (from spawnableCrates)
-- @param position    vec3
-- @param coalitionId number        coalition.side.*
-- @param spawnedBy   string|nil    player/trigger name
-- @param spawnMethod string        CTLDCrate.SPAWN_METHOD.*
-- @param countryId   number|nil    DCS country id; if nil, derived from coalition
-- @param modelKey    string|nil    key in spawnableCratesModels ("load"|"sling"|"dynamic"); auto if nil
-- @return CTLDCrate or nil
--- Create one DCS static cargo object and return its name and handle.
-- Shared by spawnCrate (new crate) and _spawnStatic (crate returning to ground).
-- @param weight      number   cargo mass in kg
-- @param position    vec3     world position {x, y, z}
-- @param coalitionId number   coalition.side.*
-- @param countryId   number|nil  DCS country id; derived from coalitionId if nil
-- @param modelKey    string|nil  key in spawnableCratesModels; auto if nil
-- @param label       string|nil  human-readable content name (e.g. "FOB Crate")
--                               shown in the DCS cargo interface and F10 list.
--                               Sanitised: spaces→_, special chars stripped.
-- @return string name, StaticObject|nil  (nil if dynAddStatic failed)
function CTLDCrateManager:_spawnStatic(weight, position, coalitionId, countryId, modelKey, label)
    local models = ctld.gs("spawnableCratesModels") or {}
    local key    = modelKey or (ctld.gs("slingLoad") and "sling" or "load")
    local model  = models[key] or models["load"] or {}

    local cId = countryId
    if not cId then
        cId = (coalitionId == coalition.side.RED) and country.id.RUSSIA or country.id.USA
    end

    local uid  = ctld.utils.getNextUniqId()
    local name
    if label and label ~= "" then
        -- Sanitise: keep alphanumeric, dash, underscore; replace spaces with _
        local safe = label:gsub("%s+", "_"):gsub("[^%w%-%_]", "")
        name = string.format("CTLD_%s_%d", safe, uid)
    else
        name = string.format("CTLD_Crate_%d", uid)
    end
    local data = {
        name     = name,
        x        = position.x,
        y        = position.z,   -- dynAddStatic maps y → DCS world-Z axis
        heading  = 0,
        type     = model.type     or "ammo_cargo",
        canCargo = model.canCargo or false,
        mass     = weight,
        country  = cId,
        dead     = false,
    }
    if model.shape_name then data.shape_name = model.shape_name end

    local ok, err = pcall(function() ctld.utils.dynAddStatic("CTLDCrateManager:_spawnStatic", data) end)
    if not ok then
        _log("CTLDCrateManager:_spawnStatic - dynAddStatic failed: " .. tostring(err), "WARNING")
        return name, nil
    end
    return name, StaticObject.getByName(name)
end

function CTLDCrateManager:spawnCrate(descriptor, position, coalitionId, spawnedBy, spawnMethod, countryId, modelKey)
    if not (descriptor and position) then
        _log("CTLDCrateManager:spawnCrate - missing descriptor or position", "WARNING")
        return nil
    end

    local crateName, dcsStatic = self:_spawnStatic(
        descriptor.weight, position, coalitionId, countryId, modelKey, descriptor.desc)
    if not dcsStatic then return nil end

    local models  = ctld.gs("spawnableCratesModels") or {}
    local usedKey = modelKey or (ctld.gs("slingLoad") and "sling" or "load")
    local crate = CTLDCrate:new({
        crateName   = crateName,
        descriptor  = descriptor,
        spawnMethod = spawnMethod or CTLDCrate.SPAWN_METHOD.CRATE_SPAWN,
        position    = position,
        heading     = 0,
        coalition   = coalitionId,
        spawnedBy   = spawnedBy,
        dcsStatic   = dcsStatic,
        modelKey    = (models[usedKey] and usedKey) or "load",
    })
    self:_register(crate)

    self:_publish("OnCrateSpawned", {
        crate       = crate,
        crateName   = crateName,
        descriptor  = descriptor,
        position    = position,
        coalition   = coalitionId,
        spawnedBy   = spawnedBy,
        spawnMethod = crate.spawnMethod,
        timestamp   = timer.getAbsTime(),
    })

    return crate
end

--- Recreate the DCS static for a crate returning to ground (static was destroyed on load).
-- Generates a new unique name, re-indexes self.crates, updates crate.crateName/dcsStatic.
-- @param crate    CTLDCrate
-- @param position vec3
-- @return bool
function CTLDCrateManager:_respawnStatic(crate, position)
    local label = crate.descriptor and crate.descriptor.desc or nil
    local newName, dcsStatic = self:_spawnStatic(
        crate.descriptor.weight, position, crate.coalition, nil, crate.modelKey, label)
    if not dcsStatic then return false end

    self.crates[crate.crateName] = nil
    crate.crateName = newName
    crate.dcsStatic = dcsStatic
    self.crates[newName] = crate
    return true
end

--- Spawn N crates in a straight line from a transport unit.
-- The axis direction is chosen randomly within the front sector for standard
-- units, or within the rear sector for native-cargo-capable units, so that
-- successive multi-crate spawns land at different angles and do not overlap.
--   Front sector : [-45°, +45°]  relative to unit heading (axisOffsetDeg 315..45)
--   Rear  sector : [135°, 225°]  relative to unit heading (axisOffsetDeg 135..225)
--
-- @param descriptors  table   ordered list of descriptor tables (one per crate)
-- @param transport    Unit    the requesting/packing transport unit
-- @param coalitionId  number  coalition.side.*
-- @param spawnedBy    string  unit name for attribution
-- @param spawnMethod  string  CTLDCrate.SPAWN_METHOD.*
-- @return number spawned count, table spawnInfo {positions, clock, distance}
function CTLDCrateManager:spawnCratesAligned(descriptors, transport, coalitionId, spawnedBy, spawnMethod)
    -- Detect native-cargo-capable transport (UH-1H, CH-47, Mi-8, etc.)
    local isDynamic = self:_isDynamicCapable(transport)
    local modelKey  = self:_crateModelKey(transport)

    -- Random axis within the appropriate sector (degrees relative to unit forward)
    local axisOffsetDeg
    if isDynamic then
        axisOffsetDeg = ctld.utils.RandomReal("spawnCratesAligned", 135, 225)  -- rear sector
    else
        -- Front sector wraps: pick randomly in [-45, +45], then normalise to [0, 360)
        local raw = ctld.utils.RandomReal("spawnCratesAligned", -45, 45)
        axisOffsetDeg = (raw + 360) % 360
    end

    local safeDist  = (ctld.utils.getSecureDistanceFromUnit(transport:getName()) or 10) + 5
    local spacing   = (ctld.gs and ctld.gs("crateSpacing")) or 5
    local n         = #descriptors
    local spawnInfo = ctld.utils.getSpawnObjectPositions(transport, n, safeDist, spacing, axisOffsetDeg)
    local spawned   = 0
    for i, descriptor in ipairs(descriptors) do
        local pos = spawnInfo.positions[i]
        if descriptor and pos then
            if self:spawnCrate(descriptor, pos, coalitionId, spawnedBy, spawnMethod, nil, modelKey) then
                spawned = spawned + 1
            end
        end
    end
    return spawned, spawnInfo
end

--- Register a crate pre-placed by the mission maker (called from INIT-B).
-- @param obj  StaticObject  DCS cargo static (already filtered: isExist + Category==6 + Cargos==true)
-- @param desc table         result of obj:getDesc()
function CTLDCrateManager:registerMMCrate(obj, desc)
    local crateName = obj:getName()

    if self.crates[crateName] then
        _log("CTLDCrateManager:registerMMCrate - already registered: " .. crateName, "WARNING")
        return
    end

    local typeName   = desc.typeName
    local descriptor = self:findDescriptorByTypeName(typeName)

    if descriptor == nil then
        _log("CTLDCrateManager:registerMMCrate - unknown cargo type '"
            .. tostring(typeName) .. "' (" .. crateName .. ") — skipped", "WARNING")
        return
    end

    local crate = CTLDCrate:new({
        crateName   = crateName,
        descriptor  = descriptor,
        spawnMethod = CTLDCrate.SPAWN_METHOD.MISSION_MAKER,
        spawnedBy   = nil,
        position    = obj:getPoint(),
        heading     = 0,
        coalition   = obj:getCoalition(),
        dcsStatic   = obj,
    })

    self:_register(crate)
    _log("CTLDCrateManager:registerMMCrate - registered '" .. crateName
        .. "' type='" .. tostring(typeName) .. "'", "INFO")

    self:_publish("OnMMCrateDetected", {
        crate       = crate,
        crateName   = crateName,
        descriptor  = descriptor,
        position    = crate.position,
        coalition   = crate.coalition,
        timestamp   = timer.getAbsTime(),
    })
end

--- Get a crate by its DCS unit name.
-- @param crateName string
-- @return CTLDCrate or nil
function CTLDCrateManager:getCrateByName(crateName)
    return self.crates[crateName]
end

--- Get all crates on the ground within a radius of a position.
-- @param position vec3
-- @param radius   number  metres
-- @return table of CTLDCrate
function CTLDCrateManager:getCratesInRange(position, radius)
    local result = {}
    for _, crate in pairs(self.crates) do
        if crate:isOnGround() then
            -- Prefer live DCS static position: covers crates moved by native DCS
            -- cargo system (dropped at a different location than original spawn).
            local cratePos = crate.position
            if crate.dcsStatic and crate.dcsStatic:isExist() then
                cratePos = crate.dcsStatic:getPoint()
            end
            if ctld.utils.getDistance("CTLDCrateManager:getCratesInRange", position, cratePos) <= radius then
                table.insert(result, crate)
            end
        end
    end
    return result
end

--- Load a crate into a transport unit.
-- Transitions crate: spawned|landed → loaded.
-- Publishes OnCrateLoaded.
-- @param crateName string
-- @param transport Unit
function CTLDCrateManager:loadCrate(crateName, transport)
    local crate = self.crates[crateName]
    if not crate then
        _log("CTLDCrateManager:loadCrate - crate not found: " .. tostring(crateName), "WARNING")
        return
    end
    if not crate:isOnGround() then
        _log("CTLDCrateManager:loadCrate - crate not on ground: " .. crateName, "WARNING")
        return
    end
    local pos = crate.position   -- capture before state change
    crate:load(transport)
    crate:destroy()              -- remove DCS static from ground
    self:_publish("OnCrateLoaded", {
        crate           = crate,
        crateName       = crateName,
        carrierUnitName = transport:getName(),
        coalition       = crate.coalition,
        descriptor      = crate.descriptor,
        timestamp       = timer.getAbsTime(),
    })
    self:_publish("OnCrateCleared", {
        crateName  = crateName,
        position   = pos,
        coalition  = crate.coalition,
        descriptor = crate.descriptor,
        reason     = "loaded",
        timestamp  = timer.getAbsTime(),
    })
end

--- Unload a crate to the ground (transport has landed).
-- Transitions crate: loaded → landed.
-- Publishes OnCrateUnloaded.
-- @param crateName string
-- @param position  vec3
-- @param method    string  "menu_ctld" | "dcs_native_unload"
function CTLDCrateManager:unloadCrate(crateName, position, method)
    local crate = self.crates[crateName]
    if not crate then return end
    crate:unload(position)
    -- Recreate DCS static on the ground (was destroyed when loaded)
    self:_respawnStatic(crate, position)
    -- Use the updated crateName (may have changed in _respawnStatic)
    local newName = crate.crateName
    self:_publish("OnCrateUnloaded", {
        crate           = crate,
        crateName       = newName,
        position        = position,
        coalition       = crate.coalition,
        method          = method or "menu_ctld",
        timestamp       = timer.getAbsTime(),
    })
    -- Crate returned to ground: notify nearby players it is loadable again.
    self:_publish("OnCrateSpawned", {
        crate      = crate,
        crateName  = newName,
        position   = position,
        coalition  = crate.coalition,
        descriptor = crate.descriptor,
        spawnedBy  = nil,
        spawnMethod = "unload",
        timestamp  = timer.getAbsTime(),
    })
end

--- Unpack a crate (contents deployed).
-- Transitions crate: spawned|landed → unpacked.
-- Publishes OnCrateUnpacked.
-- Spawn logic is delegated to the relevant manager based on descriptor type.
-- @param crateName string
-- @param unpacker  Unit  player unit requesting unpack
function CTLDCrateManager:unpackCrate(crateName, unpacker)
    local crate = self.crates[crateName]
    if not crate then return end
    if not crate:isOnGround() then
        _log("CTLDCrateManager:unpackCrate - crate not on ground: " .. crateName, "WARNING")
        return
    end
    local pos = crate.position   -- capture before state change
    crate:unpack()
    self:_publish("OnCrateUnpacked", {
        crate           = crate,
        crateName       = crateName,
        descriptor      = crate.descriptor,
        position        = pos,
        coalition       = crate.coalition,
        carrierUnitName = unpacker and unpacker:getName() or nil,
        timestamp       = timer.getAbsTime(),
    })
    self:_publish("OnCrateCleared", {
        crateName  = crateName,
        position   = pos,
        coalition  = crate.coalition,
        descriptor = crate.descriptor,
        reason     = "unpacked",
        timestamp  = timer.getAbsTime(),
    })
    crate:destroy()
    self:_unregister(crateName)
end

--- Destroy and remove a crate from the registry.
-- @param crateName string
function CTLDCrateManager:destroyCrate(crateName)
    local crate = self.crates[crateName]
    if not crate then return end
    local pos  = crate.position
    local coal = crate.coalition
    local desc = crate.descriptor
    crate:destroy()
    self:_unregister(crateName)
    self:_publish("OnCrateCleared", {
        crateName  = crateName,
        position   = pos,
        coalition  = coal,
        descriptor = desc,
        reason     = "destroyed",
        timestamp  = timer.getAbsTime(),
    })
end

--- Find a CTLD descriptor by the DCS unit field (vehicle typeName for pack lookup).
-- Searches ctld.gs("spawnableCrates") for an entry whose unit field matches exactly.
-- @param typeName string  DCS typeName (e.g. "M-1 Abrams")
-- @return descriptor table or nil
function CTLDCrateManager:findDescriptorByUnitType(typeName)
    if not typeName then return nil end
    local spawnableCrates = ctld.gs("spawnableCrates")
    if not spawnableCrates then return nil end
    for _, category in pairs(spawnableCrates) do
        for _, descriptor in ipairs(category) do
            if descriptor.unit == typeName then
                return descriptor
            end
        end
    end
    return nil
end

--- Find a CTLD descriptor matching a DCS typeName.
-- Searches ctld.gs("spawnableCrates") for a matching unit or type field.
-- @param typeName string  DCS typeName (e.g. "M92_Ammo_Pallet")
-- @return descriptor table or nil
function CTLDCrateManager:findDescriptorByTypeName(typeName)
    if not typeName then return nil end
    local spawnableCrates = ctld.gs("spawnableCrates")
    if not spawnableCrates then return nil end
    for _, category in pairs(spawnableCrates) do
        for _, descriptor in ipairs(category) do
            if descriptor.unit == typeName or descriptor.type == typeName then
                return descriptor
            end
        end
    end
    return nil
end

--- Check if enough crates of the same type are assembled nearby to unpack.
-- Searches for crates with the same descriptor.unit within radius, including crate itself.
-- @param crate   CTLDCrate  reference crate
-- @param radius  number     search radius in metres (default 100)
-- @return boolean, table    ready flag + list of assembled crates (length == cratesRequired)
function CTLDCrateManager:checkAssemblyReady(crate, radius)
    radius = radius or 100
    local required = (crate.descriptor and crate.descriptor.cratesRequired) or 1
    if required <= 1 then
        return true, { crate }
    end

    local function _livePos(c)
        if c.dcsStatic and c.dcsStatic:isExist() then return c.dcsStatic:getPoint() end
        return c.position
    end
    local refPos = _livePos(crate)

    local assembled = {}
    for _, c in pairs(self.crates) do
        if c:isOnGround()
            and c.descriptor
            and c.descriptor.unit == crate.descriptor.unit
            and ctld.utils.getDistance("CTLDCrateManager:checkAssemblyReady", refPos, _livePos(c)) <= radius
        then
            table.insert(assembled, c)
            if #assembled == required then
                return true, assembled
            end
        end
    end
    return false, assembled
end

--- Drop a crate from a transport in flight.
-- Below maxDropHeight → crate lands safely.
-- Above maxDropHeight → crate is destroyed (impact damage).
-- Publishes OnCrateUnloaded (method="drop") on safe landing,
-- or OnCrateDestroyed (reason="drop_impact") on destruction.
-- @param crateName     string
-- @param altitudeAGL   number  metres above ground level at drop time
function CTLDCrateManager:dropCrate(crateName, altitudeAGL)
    local crate = self.crates[crateName]
    if not crate then return end
    if not crate:isLoaded() then
        _log("CTLDCrateManager:dropCrate - crate not loaded: " .. tostring(crateName), "WARNING")
        return
    end

    local maxDropHeight = ctld.gs("maxDropHeight") or 7.5

    if altitudeAGL <= maxDropHeight then
        -- Safe drop: crate lands at current position
        local pos = crate.position
        crate:land(pos)
        self:_publish("OnCrateUnloaded", {
            crate           = crate,
            crateName       = crateName,
            position        = pos,
            coalition       = crate.coalition,
            method          = "drop",
            timestamp       = timer.getAbsTime(),
        })
    else
        -- Too high: crate destroyed on impact
        _log("CTLDCrateManager:dropCrate - destroyed on impact (alt=" .. tostring(altitudeAGL) .. "m): " .. crateName, "INFO")
        self:_publish("OnCrateDestroyed", {
            crate     = crate,
            crateName = crateName,
            coalition = crate.coalition,
            reason    = "drop_impact",
            timestamp = timer.getAbsTime(),
        })
        crate:destroy()
        self:_unregister(crateName)
    end
end

--- S_EVENT_BIRTH handler: register cargo statics that spawn via late activation.
-- Registered in CTLDDCSEventBridge by CTLDCoreManager.
function CTLDCrateManager:onBirth(event)
    local obj = event.initiator
    if not (obj and obj.isExist and obj:isExist()) then return end
    if Object.getCategory(obj) ~= 6 then return end
    local desc = obj:getDesc()
    if not (desc and desc.attributes and desc.attributes.Cargos == true) then return end
    local unitName = obj:getName()
    -- Skip CTLD-managed crates: S_EVENT_BIRTH may fire before _register() is called
    -- (synchronous dispatch in some DCS versions), so the prefix check is more reliable
    -- than getCrateByName() alone.
    if string.sub(unitName, 1, 5) == "CTLD_" then return end
    if self:getCrateByName(unitName) then return end   -- already registered
    self:registerMMCrate(obj, desc)
end

--- Spawn the DCS object described by a crate descriptor and activate its post-spawn role.
-- Uniform path for all standard (non-AA, non-FOB) unpack outcomes:
--   build unitDef (ctld.utils.buildGroupUnitDef)
--   → spawn       (ctld.utils.spawnFromDescriptor)
--   → post-spawn  (_dispatchPostSpawn)
-- JTAC_dropEnabled is checked here for air JTAC descriptors.
-- @param desc  table  crate descriptor { unit, spawnAs, isJTAC, … }
-- @param pos   vec3   world spawn position
-- @param coa   number coalition.side.*
-- @param cId   number country.id.*
function CTLDCrateManager:_spawnUnpacked(desc, pos, coa, cId)
    if not (desc and desc.unit and pos) then return end

    local spawnAs = desc.spawnAs or "GROUND"
    local isAir   = spawnAs ~= "GROUND" and spawnAs ~= "STATIC"

    if isAir and ctld.gs("JTAC_dropEnabled") == false then
        ctld.utils.log("INFO", "CTLDCrateManager:_spawnUnpacked — JTAC_dropEnabled=false, skipped")
        return
    end

    local gid   = ctld.utils.getNextUniqId()
    local uid   = ctld.utils.getNextUniqId()
    local gname = isAir
        and string.format("CTLD_AIR_%d", gid)
        or  string.format("CTLD_UNP_%d", uid)

    local unitDef = ctld.utils.buildGroupUnitDef(desc, pos, gname, gid, uid)
    local ok, err = ctld.utils.spawnFromDescriptor(desc, cId, unitDef)
    if not ok then
        local errStr = type(err) == "table" and ctld.utils.p(err) or tostring(err)
        ctld.utils.log("WARNING", "CTLDCrateManager:_spawnUnpacked — spawn failed: " .. errStr)
        return
    end

    if not isAir then
        EventDispatcher.getInstance():publish("OnGroundUnitSpawned", {
            vehicleType = desc.unit,
            position    = pos,
            coalitionId = coa,
            timestamp   = timer.getAbsTime(),
        })
    end

    self:_dispatchPostSpawn(desc, gname)
end

--- Activate post-spawn role behaviors for an unpacked crate.
-- Called after successful spawn regardless of unit type.
-- Add new role activations here as new crate types are introduced.
-- @param desc   table  crate descriptor
-- @param gname  string spawned DCS group name
function CTLDCrateManager:_dispatchPostSpawn(desc, gname)
    if desc.isJTAC then
        CTLDJTACManager.get():startLase(gname)
    end
end

--- Cleanup: destroy all tracked crates.
-- Called on mission end or full reset.
function CTLDCrateManager:cleanup()
    for crateName, _ in pairs(self.crates) do
        self:destroyCrate(crateName)
    end
    self.crates = {}
end

-- ============================================================
-- F10 Menu sections
-- ============================================================

--- Parachute all crates loaded by a transport.
-- Altitude AGL is checked at call time. If below parachuteMinAltitudeCrates, a message
-- is sent to the player's group and nothing else happens.
-- For each loaded crate: computes an independent landing position, schedules a timer
-- to land it after descent, fires events.
-- Publishes OnCrateParachuting immediately (per crate) and OnCrateParachuteLanded
-- after descentTime (per crate).
-- @param transport    Unit    DCS transport unit
-- @param playerObj    table   CTLDPlayer-like {groupId, unitName}
function CTLDCrateManager:parachuteCrates(transport, playerObj)
    local dropPos     = transport:getPoint()
    local groundUnder = land.getHeight({ x = dropPos.x, y = dropPos.z })
    local altAGL      = dropPos.y - groundUnder
    local minAlt      = ctld.gs("parachuteMinAltitudeCrates") or 30

    if altAGL < minAlt then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Altitude too low for parachute drop. Minimum: %dm AGL (current: %dm AGL)"),
                math.floor(minAlt), math.floor(altAGL)), 10)
        return
    end

    local descentRate = ctld.gs("parachuteDescentRateCrates") or 5
    local loaded      = {}
    for _, crate in pairs(self.crates) do
        if crate:isLoaded() and crate.loadedBy == transport then
            table.insert(loaded, crate)
        end
    end

    if #loaded == 0 then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No crates loaded."), 8)
        return
    end

    for _, crate in ipairs(loaded) do
        local landPos, descentTime = ctld.utils.calcDropPosition(transport, descentRate)
        crate:startParachute(altAGL)
        crate.estimatedLandingTime = timer.getAbsTime() + descentTime

        local dropData = {
            type          = "crate",
            unitName      = crate.crateName,
            dropPosition  = dropPos,
            landPositions = { landPos },
            altitude      = altAGL,
            descentTime   = descentTime,
            transport     = transport,
            player        = playerObj.unitName,
        }
        self._parachuteEffect:onStart(dropData)

        self:_publish("OnCrateParachuting", {
            crate           = crate,
            crateName       = crate.crateName,
            descriptor      = crate.descriptor,
            dropPosition    = dropPos,
            landingPosition = landPos,
            altitude        = altAGL,
            descentTime     = descentTime,
            carrierUnitName = transport:getName(),
            player          = playerObj.unitName,
            timestamp       = timer.getAbsTime(),
        })

        -- Capture loop variables for the timer closure
        local _crate    = crate
        local _landPos  = landPos
        local _dropData = dropData
        timer.scheduleFunction(function()
            _crate:land(_landPos)
            self._parachuteEffect:onLanded(_dropData)
            self:_publish("OnCrateParachuteLanded", {
                crate           = _crate,
                crateName       = _crate.crateName,
                descriptor      = _crate.descriptor,
                position        = _landPos,
                coalition       = _crate.coalition,
                startAltitude   = altAGL,
                carrierUnitName = transport:getName(),
                player          = playerObj.unitName,
                timestamp       = timer.getAbsTime(),
            })
        end, {}, timer.getTime() + descentTime)
    end
end

--- Returns true if the unit type name is a JTAC-type unit.
-- Used to filter JTAC crates from the Request Equipment menu when JTAC_dropEnabled = false.
-- Matches known JTAC unit type names (case-insensitive substring).
local _jtacUnitTypes = { "hummer", "skp-11", "jtac" }
function CTLDCrateManager:_isJTACUnitType(unitType)
    if not unitType then return false end
    local lower = string.lower(unitType)
    for _, t in ipairs(_jtacUnitTypes) do
        if string.find(lower, t, 1, true) then return true end
    end
    return false
end

--- Build "Request Equipment" + "Crate Commands" F10 submenus for a player.
-- Requires enableCrates = true (configKey gate) AND unitActions.crates = true.
-- Sub-entries:
--   Request Equipment → per LGZ → per category → per crate (filtered by coalition + JTAC flag)
--   Crate Commands → Load/Drop/Unpack/List
--                  → List FOBs         if enabledFOBBuilding
--                  → Pack Vehicle (container, populated dynamically) if enablePackingVehicles
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
--- Rebuild the "Request Equipment" submenu branch for playerObj.
-- Shows only logistic zones where the player is currently located (cratesPickup).
-- Called on build, land, and takeoff.
-- @param playerObj CTLDPlayer
function CTLDCrateManager:refreshRequestEquipmentSection(playerObj)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root     = ctld.tr("CTLD")
    local spawnSub = ctld.tr("Request Equipment")
    menu:clearBranch({ root, spawnSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, spawnSub }, ctld.tr("Land near logistics to request equipment"),
            function() end, {})
        menu:refresh()
        return
    end

    local zm      = CTLDZoneManager.getInstance()
    local lgZones = zm:getLogisticZonesAtPoint(transport:getPoint(), playerObj.coalition, "cratesPickup")

    if not next(lgZones) then
        menu:addCommand({ root, spawnSub }, ctld.tr("No logistics in range"),
            function() end, {})
        menu:refresh()
        return
    end

    local jtacOk       = ctld.gs("JTAC_dropEnabled") == true
    local spawnableCrates = ctld.gs("spawnableCrates") or {}

    for _, lgz in ipairs(lgZones) do
        local lgzName = lgz.name
        menu:addSubMenu({ root, spawnSub }, lgzName)
        for category, crates in pairs(spawnableCrates) do
            menu:addSubMenu({ root, spawnSub, lgzName }, category)
            for _, crate in ipairs(crates) do
                local sideOk    = (crate.side == nil) or (crate.side == playerObj.coalition)
                local crateJtac = self:_isJTACUnitType(crate.unit)
                if sideOk and (not crateJtac or jtacOk) then
                    menu:addCommand({ root, spawnSub, lgzName, category }, crate.desc,
                        function(arg)
                            local t = Unit.getByName(arg.unitName)
                            if not (t and t:isExist()) then return end
                            if ctld.utils.inAir(t) then
                                trigger.action.outTextForGroup(t:getGroup():getID(),
                                    ctld.tr("You must be landed to request a crate."), 10)
                                return
                            end
                            -- Verify unit is still within the selected zone
                            local selZone = CTLDZoneManager.getInstance():getLogisticZone(arg.zoneName)
                            if not (selZone and selZone.active and selZone:isAlive()
                                    and selZone:isInZone(t:getPoint())) then
                                trigger.action.outTextForGroup(t:getGroup():getID(),
                                    ctld.tr("You are not close enough to friendly logistics to get a crate!"), 10)
                                return
                            end
                            local safeDist = (ctld.utils.getSecureDistanceFromUnit(arg.unitName) or 10) + 5
                            local mgr      = CTLDCrateManager.getInstance()
                            local gid      = t:getGroup():getID()

                            if arg.multiple then
                                local descriptors = {}
                                for _, weight in ipairs(arg.multiple) do
                                    local d = mgr:findDescriptorByWeight(weight)
                                    if d then table.insert(descriptors, d) end
                                end
                                local spawned, spawnInfo = mgr:spawnCratesAligned(
                                    descriptors, t, arg.coalition, arg.unitName,
                                    CTLDCrate.SPAWN_METHOD.MENU_CTLD)
                                if spawned > 0 then
                                    trigger.action.outTextForGroup(gid,
                                        ctld.tr("%1 crates have been brought out at your %2 o'clock",
                                            spawned, spawnInfo.clock), 20)
                                end
                            else
                                local mKey      = mgr:_crateModelKey(t)
                                local spawnInfo = ctld.utils.getSpawnObjectPositions(t, 1, safeDist)
                                local pos       = spawnInfo.positions[1]
                                local descriptor = mgr:findDescriptorByTypeName(arg.unit)
                                if descriptor then
                                    local spawned = mgr:spawnCrate(descriptor, pos, arg.coalition, arg.unitName,
                                        CTLDCrate.SPAWN_METHOD.MENU_CTLD, nil, mKey)
                                    if spawned then
                                        trigger.action.outTextForGroup(gid,
                                            ctld.tr("A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock ",
                                                descriptor.desc, descriptor.weight, spawnInfo.clock), 20)
                                    end
                                end
                            end
                        end,
                        { unit      = crate.unit,
                          multiple  = crate.multiple,
                          zoneName  = lgzName,
                          unitName  = playerObj.unitName,
                          coalition = playerObj.coalition })
                end
            end
        end
    end
    menu:refresh()
end

function CTLDCrateManager:buildMenuSection(playerObj, menu)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local root     = ctld.tr("CTLD")
    local spawnSub = ctld.tr("Request Equipment")
    menu:addSubMenu({ root }, spawnSub, { order = 40 })
    self:refreshRequestEquipmentSection(playerObj)

    -- Crate Commands
    local cratesSub = ctld.tr("Crate Commands")
    menu:addSubMenu({ root }, cratesSub, { order = 50 })

    local loadSub = ctld.tr("Load Crate")
    menu:addSubMenu({ root, cratesSub }, loadSub, { order = 10 })
    self:refreshLoadCrateSection(playerObj)

    menu:addCommand({ root, cratesSub }, ctld.tr("Drop Crate(s)"),
        function(arg)
            local t = Unit.getByName(arg.unitName)
            if not (t and t:isExist()) then return end
            local gid = t:getGroup():getID()
            if ctld.utils.inAir(t) then
                trigger.action.outTextForGroup(gid,
                    ctld.tr("You must land before dropping crates!"), 10)
                return
            end
            -- Collect all crates loaded on this transport
            local mgr     = CTLDCrateManager.getInstance()
            local loaded  = {}
            for _, c in pairs(mgr.crates) do
                if c:isLoaded() and c.loadedBy and c.loadedBy:getName() == t:getName() then
                    table.insert(loaded, c)
                end
            end
            if #loaded == 0 then
                trigger.action.outTextForGroup(gid,
                    ctld.tr("No crates on board to drop."), 10)
                return
            end
            -- Compute aligned drop positions (one per crate)
            local safeDist  = (ctld.utils.getSecureDistanceFromUnit(arg.unitName) or 10) + 5
            local spacing   = (ctld.gs and ctld.gs("crateSpacing")) or 5
            local typeLower = string.lower(t:getTypeName())
            local vList     = (ctld.gs and ctld.gs("vehicleTransportEnabled")) or {}
            local isDynamic = false
            for _, name in ipairs(vList) do
                if string.find(typeLower, string.lower(name), 1, true) then
                    isDynamic = true; break
                end
            end
            local axis
            if isDynamic then
                axis = ctld.utils.RandomReal("dropCrates", 135, 225)
            else
                axis = (ctld.utils.RandomReal("dropCrates", -45, 45) + 360) % 360
            end
            local spawnInfo = ctld.utils.getSpawnObjectPositions(t, #loaded, safeDist, spacing, axis)
            for i, c in ipairs(loaded) do
                local pos = spawnInfo.positions[i]
                if pos then
                    local groundY = land.getHeight({ x = pos.x, y = pos.z })
                    mgr:unloadCrate(c.crateName, { x = pos.x, y = groundY, z = pos.z }, "drop")
                end
            end
            trigger.action.outTextForGroup(gid,
                ctld.tr("%1 crate(s) dropped at your %2 o'clock", #loaded, spawnInfo.clock), 10)
        end,
        { unitName = playerObj.unitName })

    local unpackSub = ctld.tr("Unpack Crate")
    menu:addSubMenu({ root, cratesSub }, unpackSub, { order = 20 })
    self:refreshUnpackSection(playerObj)

    menu:addCommand({ root, cratesSub }, ctld.tr("List Nearby Crates"),
        function(arg)
            local t = Unit.getByName(arg.unitName)
            if not (t and t:isExist()) then return end
            local gid  = t:getGroup():getID()
            local mgr  = CTLDCrateManager.getInstance()
            local nearby = mgr:getCratesInRange(t:getPoint(), 300)

            -- Group by descriptor.unit (or desc for crates with no vehicle)
            local byUnit    = {}   -- [key] = { desc, count, required }
            local unitOrder = {}
            for _, c in ipairs(nearby) do
                if c.descriptor then
                    local key      = c.descriptor.unit or c.descriptor.desc or "?"
                    local desc     = c.descriptor.desc or key
                    local required = c.descriptor.cratesRequired or 1
                    if not byUnit[key] then
                        byUnit[key] = { desc = desc, count = 0, required = required }
                        table.insert(unitOrder, key)
                    end
                    byUnit[key].count = byUnit[key].count + 1
                end
            end

            if #unitOrder == 0 then
                trigger.action.outTextForGroup(gid,
                    ctld.tr("No crates within 300m."), 10)
                return
            end

            local lines = { ctld.tr("Crates within 300m:") }
            for _, key in ipairs(unitOrder) do
                local info = byUnit[key]
                if info.count >= info.required then
                    table.insert(lines, ctld.tr("  %1: %2/%3 — READY", info.desc, info.count, info.required))
                else
                    table.insert(lines, ctld.tr("  %1: %2/%3 — incomplete", info.desc, info.count, info.required))
                end
            end
            trigger.action.outTextForGroup(gid, table.concat(lines, "\n"), 15)
        end,
        { unitName = playerObj.unitName })

    if ctld.gs("enablePackingVehicles") == true then
        local packSub   = ctld.tr("Pack Vehicle")
        menu:addSubMenu({ root, cratesSub }, packSub, { order = 99 })
        CTLDVehicleSpawner.getInstance():refreshPackSection(playerObj)
    end

    -- Parachute Crates: only if canParachute=true for this unit type
    if actions.canParachute then
        menu:addCommand({ root, cratesSub }, ctld.tr("Parachute Crates"),
            function(arg)
                local transport = Unit.getByName(arg.unitName)
                if not transport then return end
                CTLDCrateManager.getInstance():parachuteCrates(transport, arg)
            end,
            { unitName = playerObj.unitName, groupId = playerObj.groupId })
    end

    -- Release / Cut Slingload: only if canSlingload=true AND transport currently in air
    if actions.canSlingload then
        local transport = Unit.getByName(playerObj.unitName)
        if transport and transport:isExist() and ctld.utils.inAir(transport) then
            menu:addCommand({ root, cratesSub }, ctld.tr("Release Slingload"),
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not t then return end
                    CTLDCrateManager.getInstance():releaseSlingload(t, arg)
                end,
                { unitName = playerObj.unitName, groupId = playerObj.groupId })

            menu:addCommand({ root, cratesSub }, ctld.tr("Cut Slingload"),
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not t then return end
                    CTLDCrateManager.getInstance():cutSlingload(t, arg)
                end,
                { unitName = playerObj.unitName, groupId = playerObj.groupId })
        end
    end
end

--- Build "Smoke" F10 submenu for a player.
-- Requires enableSmokeDrop = true (configKey gate) AND isTransport.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDCrateManager:buildSmokeSection(playerObj, menu)
    if not playerObj.isTransport then return end

    local root     = ctld.tr("CTLD")
    local smokeSub = ctld.tr("Smoke")
    menu:addSubMenu({ root }, smokeSub, { order = 80 })

    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Red Smoke"),
        function(arg) ctld.utils.log("INFO", "Drop Red Smoke " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName, color = "red" })

    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Blue Smoke"),
        function(arg) ctld.utils.log("INFO", "Drop Blue Smoke " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName, color = "blue" })

    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Orange Smoke"),
        function(arg) ctld.utils.log("INFO", "Drop Orange Smoke " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName, color = "orange" })

    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Green Smoke"),
        function(arg) ctld.utils.log("INFO", "Drop Green Smoke " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName, color = "green" })
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Find a crate descriptor by weight number.
-- Searches all spawnableCrates categories for a descriptor whose weight matches.
-- @param weight number
-- @return table|nil  descriptor
function CTLDCrateManager:findDescriptorByWeight(weight)
    if not weight then return nil end
    local spawnableCrates = ctld.gs("spawnableCrates")
    if not spawnableCrates then return nil end
    for _, category in pairs(spawnableCrates) do
        for _, descriptor in ipairs(category) do
            if descriptor.weight == weight then return descriptor end
        end
    end
    return nil
end

--- Spawn a crate at a DCS trigger zone (MM DO SCRIPT).
-- @param side   string   "red" | "blue"
-- @param weight number   crate weight (lookup key in spawnableCrates)
-- @param zone   string   DCS trigger zone name
-- @return CTLDCrate|nil
function CTLDCrateManager:spawnCrateAtZone(side, weight, zone)
    local trig = trigger.misc.getZone(zone)
    if not trig then
        ctld.utils.log("ERROR", "CTLDCrateManager:spawnCrateAtZone — zone not found: %s", tostring(zone))
        return nil
    end
    local descriptor = self:findDescriptorByWeight(weight)
    if not descriptor then
        ctld.utils.log("ERROR", "CTLDCrateManager:spawnCrateAtZone — no descriptor for weight=%s", tostring(weight))
        return nil
    end
    local p2  = { x = trig.point.x, y = trig.point.z }
    local pt  = { x = p2.x, y = land.getHeight(p2), z = p2.y }
    local cId = (side == "red") and coalition.side.RED or coalition.side.BLUE
    return self:spawnCrate(descriptor, pt, cId, nil, CTLDCrate.SPAWN_METHOD.MISSION_MAKER)
end

--- Spawn a crate at a Vec3 point (MM DO SCRIPT).
-- @param side   string   "red" | "blue"
-- @param weight number   crate weight
-- @param point  table    vec3 {x, y, z}
-- @param hdg    number   heading in degrees
-- @return CTLDCrate|nil
function CTLDCrateManager:spawnCrateAtPoint(side, weight, point, hdg)
    local descriptor = self:findDescriptorByWeight(weight)
    if not descriptor then
        ctld.utils.log("ERROR", "CTLDCrateManager:spawnCrateAtPoint — no descriptor for weight=%s", tostring(weight))
        return nil
    end
    local cId = (side == "red") and coalition.side.RED or coalition.side.BLUE
    return self:spawnCrate(descriptor, point, cId, nil, CTLDCrate.SPAWN_METHOD.MISSION_MAKER)
end

--- Start a recurring watcher that counts crates in a DCS zone and sets a DCS flag.
-- Reschedules every 5 seconds. Call once from a DO SCRIPT trigger.
-- @param zoneName   string          DCS trigger zone name
-- @param flagNumber number|string   DCS user flag to set to crate count
function CTLDCrateManager:startCrateCountWatcher(zoneName, flagNumber)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDCrateManager:startCrateCountWatcher — zone not found: %s", tostring(zoneName))
        return
    end
    local center = { x = trig.point.x, y = trig.point.y, z = trig.point.z }
    local radius = trig.radius
    local self_ref = self
    local function _tick()
        local count = 0
        for _, crate in pairs(self_ref.crates) do
            if crate:isOnGround() then
                if ctld.utils.getDistance("crateWatcher", crate.position, center) <= radius then
                    count = count + 1
                end
            end
        end
        trigger.action.setUserFlag(flagNumber, count)
        timer.scheduleFunction(function()
            self_ref:startCrateCountWatcher(zoneName, flagNumber)
        end, nil, timer.getTime() + 5)
    end
    _tick()
end
