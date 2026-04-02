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
        _cmInstance.crates = {}   -- [crateName] = CTLDCrate
    end
    return _cmInstance
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
            if ctld.utils.getDistance(position, crate.position) <= radius then
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
            and ctld.utils.getDistance(crate.position, c.position) <= radius
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
