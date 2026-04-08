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
    self.hasMoved     = false
    self.canBeUnpacked = true
    -- Feature A: virtual parachute (not implemented)
    self.isParachuting          = false
    self.parachuteStartAltitude = nil
    self.estimatedLandingTime   = nil
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
        local pm = CTLDPlayerManager.getInstance()
        pm:registerMenuSection({ key = "crates", manager = _cmInstance, method = "buildMenuSection",  configKey = "enableCrates",    order = 40 })
        pm:registerMenuSection({ key = "smoke",  manager = _cmInstance, method = "buildSmokeSection", configKey = "enableSmokeDrop", order = 80 })
    end
    return _cmInstance
end

--- Replace the parachute visual effect handler.
-- @param effect CTLDParachuteEffect
function CTLDCrateManager:setParachuteEffect(effect)
    self._parachuteEffect = effect
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

--- Spawn a new crate from the F10 menu or as the result of packing a vehicle.
-- @param descriptor  table    CTLD crate descriptor (from spawnableCrates)
-- @param position    vec3
-- @param coalition   number   coalition.side.*
-- @param spawnedBy   string|nil  player name
-- @param spawnMethod string   CTLDCrate.SPAWN_METHOD.*
-- @return CTLDCrate or nil
function CTLDCrateManager:spawnCrate(descriptor, position, coalition, spawnedBy, spawnMethod)
    -- TODO: DCS API for static spawn (coalition.addStaticObject) must be verified on Hoggit
    --       before this method can be implemented.
    --       See: https://wiki.hoggitworld.com/view/DCS_func_addStaticObject
    _log("CTLDCrateManager:spawnCrate - not yet implemented (DCS spawn API pending verification)", "WARNING")
    return nil
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
            if ctld.utils.getDistance("CTLDCrateManager:getCratesInRange", position, crate.position) <= radius then
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
    crate:load(transport)
    self:_publish("OnCrateLoaded", {
        crate           = crate,
        crateName       = crateName,
        carrierUnitName = transport:getName(),
        coalition       = crate.coalition,
        descriptor      = crate.descriptor,
        timestamp       = timer.getAbsTime(),
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
    self:_publish("OnCrateUnloaded", {
        crate           = crate,
        crateName       = crateName,
        position        = position,
        coalition       = crate.coalition,
        method          = method or "menu_ctld",
        timestamp       = timer.getAbsTime(),
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
    crate:unpack()
    self:_publish("OnCrateUnpacked", {
        crate           = crate,
        crateName       = crateName,
        descriptor      = crate.descriptor,
        position        = crate.position,
        coalition       = crate.coalition,
        carrierUnitName = unpacker and unpacker:getName() or nil,
        timestamp       = timer.getAbsTime(),
    })
    crate:destroy()
    self:_unregister(crateName)
end

--- Destroy and remove a crate from the registry.
-- @param crateName string
function CTLDCrateManager:destroyCrate(crateName)
    local crate = self.crates[crateName]
    if not crate then return end
    crate:destroy()
    self:_unregister(crateName)
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

    local assembled = {}
    for _, c in pairs(self.crates) do
        if c:isOnGround()
            and c.descriptor
            and c.descriptor.unit == crate.descriptor.unit
            and ctld.utils.getDistance("CTLDCrateManager:checkAssemblyReady", crate.position, c.position) <= radius
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
    if self:getCrateByName(unitName) then return end   -- already registered (CTLD-spawned)
    self:registerMMCrate(obj, desc)
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
-- Used to filter JTAC crates from the Spawn Crates menu when JTAC_dropEnabled = false.
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

--- Build "Spawn Crates" + "Crate Commands" F10 submenus for a player.
-- Requires enableCrates = true (configKey gate) AND unitActions.crates = true.
-- Sub-entries:
--   Spawn Crates → per LGZ → per category → per crate (filtered by coalition + JTAC flag)
--   Crate Commands → Load/Drop/Unpack/List
--                  → List FOBs         if enabledFOBBuilding
--                  → Pack Vehicle (container, populated dynamically) if enablePackingVehicles
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDCrateManager:buildMenuSection(playerObj, menu)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local root      = ctld.tr("CTLD")
    local jtacOk    = ctld.gs("JTAC_dropEnabled") == true
    local spawnSub  = ctld.tr("Spawn Crates")
    menu:addSubMenu({ root }, spawnSub, { order = 40 })

    -- Spawn Crates: per LGZ × per category × per crate
    local lgZones        = CTLDZoneManager.getInstance():getLogisticZonesForCoalition(playerObj.coalition)
    local spawnableCrates = ctld.gs("spawnableCrates") or {}

    for _, lgz in ipairs(lgZones) do
        local lgzName = lgz.name
        menu:addSubMenu({ root, spawnSub }, lgzName)
        for category, crates in pairs(spawnableCrates) do
            menu:addSubMenu({ root, spawnSub, lgzName }, category)
            for _, crate in ipairs(crates) do
                local sideOk   = (crate.side == nil) or (crate.side == playerObj.coalition)
                local crateJtac = self:_isJTACUnitType(crate.unit)
                if sideOk and (not crateJtac or jtacOk) then
                    menu:addCommand({ root, spawnSub, lgzName, category }, crate.desc,
                        function(arg)
                            CTLDCrateManager.getInstance():spawnCrate(
                                self:findDescriptorByTypeName(arg.unit),
                                CTLDZoneManager.getInstance():getLogisticZone(arg.zoneName),
                                arg.coalition, arg.unitName, "menu_ctld")
                        end,
                        { unit = crate.unit, weight = crate.weight,
                          zoneName = lgzName, unitName = playerObj.unitName,
                          coalition = playerObj.coalition })
                end
            end
        end
    end

    -- Crate Commands
    local cratesSub = ctld.tr("Crate Commands")
    menu:addSubMenu({ root }, cratesSub, { order = 50 })

    menu:addCommand({ root, cratesSub }, ctld.tr("Load Nearby Crate(s)"),
        function(arg) ctld.utils.log("INFO", "Load Nearby Crate(s) for " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName })

    menu:addCommand({ root, cratesSub }, ctld.tr("Drop Crate(s)"),
        function(arg) ctld.utils.log("INFO", "Drop Crate(s) for " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName })

    menu:addCommand({ root, cratesSub }, ctld.tr("Unpack Any Crate"),
        function(arg) ctld.utils.log("INFO", "Unpack Any Crate for " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName })

    menu:addCommand({ root, cratesSub }, ctld.tr("List Nearby Crates"),
        function(arg) ctld.utils.log("INFO", "List Nearby Crates for " .. tostring(arg.unitName)) end,
        { unitName = playerObj.unitName })

    if ctld.gs("enabledFOBBuilding") == true then
        menu:addCommand({ root, cratesSub }, ctld.tr("List FOBs"),
            function(arg) ctld.utils.log("INFO", "List FOBs for group " .. tostring(arg.groupId)) end,
            { groupId = playerObj.groupId })
    end

    if ctld.gs("enablePackingVehicles") == true then
        -- Empty container populated dynamically via clearBranch + refresh on proximity scan
        menu:addSubMenu({ root, cratesSub }, ctld.tr("Pack Vehicle"), { order = 99 })
    end

    -- Parachute Crates: only if canParachute=true for this unit type
    local acts2 = (ctld.gs("unitActions") or {})[playerObj.typeName]
    if acts2 and acts2.canParachute then
        menu:addCommand({ root, cratesSub }, ctld.tr("Parachute Crates"),
            function(arg)
                local transport = Unit.getByName(arg.unitName)
                if not transport then return end
                CTLDCrateManager.getInstance():parachuteCrates(transport, arg)
            end,
            { unitName = playerObj.unitName, groupId = playerObj.groupId })
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
