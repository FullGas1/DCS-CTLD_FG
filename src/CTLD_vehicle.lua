-- ============================================================
-- CTLD_vehicle.lua
-- CTLDVehicle entity + CTLDVehicleSpawner singleton
--
-- Vehicle lifecycle:
--   WAITING   — spawned on the ground, awaiting pick-up
--   LOADED    — loaded into a transport (DCS unit destroyed / bbox-tracked)
--   DELIVERED — unloaded from transport (DCS unit respawned)
--
-- Load methods:
--   "menu_ctld"  — virtual load via CTLD F10 menu: unit destroyed on load,
--                  respawned on unload using the original group / unit names
--   "dcs_native" — detected via bounding-box overlap with a C-130 / Il-76
--                  (vehicleTransportEnabled list)
--
-- Unload methods:
--   "menu_ctld"  — virtual unload: unit respawned near transport
--   "dcs_native" — bbox exit while transport is on the ground
--   "parachute"  — bbox exit while transport is airborne
--
-- Spawn position for spawnVehicleForTransport / unloadVehicle:
--   Uses the transport's own bounding box to compute a collision-free offset
--   (same logic as ctld.getSecureDistanceFromUnit), then places the unit in the
--   front sector (±45 ° of heading) of the transport.
--
-- Group / unit naming:
--   spawnVehicleForTransport assigns  groupName = "CTLD_VEH_<type>_<id>"
--   and                               unitName  = same as groupName
--   These names are preserved in spawnData and reused verbatim on unload so
--   that the unit re-appears under its original name on the F10 map.
--
-- Events published:
--   OnVehicleSpawnedForTransport  — vehicle spawned by spawnVehicleForTransport
--   OnVehicleLoaded               — vehicle loaded into a transport
--   OnVehicleUnloaded             — vehicle unloaded / dropped from a transport
--   OnVehicleDead                 — tracked vehicle destroyed (combat / accident)
--
-- Dependencies: class (lib/class.lua), ctld.utils, ctld.gs,
--               EventDispatcher, CTLDDCSEventBridge
-- DCS API: coalition, Group, Unit, land.getHeight, timer,
--          Unit:getTransformation, Unit:getDesc
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDVehicle  (entity)
-- ============================================================

CTLDVehicle = class()

--- Valid states (class-level constants).
CTLDVehicle.STATE = {
    WAITING   = "WAITING",
    LOADED    = "LOADED",
    DELIVERED = "DELIVERED",
}

--- Constructor.
-- @param data table
--   Required: id (string), vehicleType (string), spawner (DCS Unit),
--             logisticZone (CTLDLogisticZone|nil), countryId (number),
--             coalitionId (number), spawnData (table — see below)
--   spawnData:  { groupName, unitName, vehicleType, countryId, coalitionId }
--   Optional:   unit (DCS Unit)   — the live DCS unit when in WAITING state
function CTLDVehicle:init(data)
    self.id           = data.id
    self.vehicleType  = data.vehicleType
    self.state        = CTLDVehicle.STATE.WAITING
    self.unit         = data.unit         or nil
    self.spawner      = data.spawner      or nil
    self.logisticZone = data.logisticZone or nil
    self.spawnData    = data.spawnData           -- preserved for respawn on unload
    self.spawnTime    = timer.getTime()
    self.loadTime     = nil
    self.loadMethod   = nil
    self.loadTransportName = nil
end

--- Transition to a new state.  No validation — callers are responsible.
-- @param newState string  CTLDVehicle.STATE.*
function CTLDVehicle:setState(newState)
    self.state = newState
end

--- Returns the current state string.
function CTLDVehicle:getState()
    return self.state
end


-- ============================================================
-- CTLDVehicleSpawner  (singleton)
-- ============================================================

CTLDVehicleSpawner = class()
CTLDVehicleSpawner._instance = nil

function CTLDVehicleSpawner.getInstance()
    if not CTLDVehicleSpawner._instance then
        local o = setmetatable({}, CTLDVehicleSpawner)
        o:init()
        CTLDVehicleSpawner._instance = o
    end
    return CTLDVehicleSpawner._instance
end

function CTLDVehicleSpawner:init()
    self._vehicles        = {}   -- id         → CTLDVehicle
    self._unitToVehicle   = {}   -- unitName   → vehicleId   (reverse lookup)
    self._vehicleCount    = 0
    self._parachuteEffect = CTLDNullParachuteEffect:new()
    -- nativeTracked: transportName → { vehicleId, wasInBbox }
    -- populated by _checkNativeLoading to avoid re-firing on same entry
    self._nativeTracked = {}

    local ok, bridge = pcall(CTLDDCSEventBridge.getInstance)
    if ok and bridge then
        bridge:register(self, world.event.S_EVENT_DEAD, "onDead")
    end

    -- Start periodic native-load detection (1 s cadence)
    timer.scheduleFunction(function(_, t)
        local inst = CTLDVehicleSpawner._instance
        if inst then inst:_checkNativeLoading() end
        return t + 1
    end, nil, timer.getTime() + 1)

    CTLDPlayerManager.getInstance():registerMenuSection({
        key     = "vehicles",
        manager = self,
        method  = "buildMenuSection",
        order   = 30,
    })

    -- Pack menu refresh: detect inAir→landed transition every 3 s
    self._prevInAir = {}
    timer.scheduleFunction(function(_, t)
        local inst = CTLDVehicleSpawner._instance
        if inst then inst:_checkPackingLanding() end
        return t + 3
    end, nil, timer.getTime() + 3)

    -- Hover hint: notify player to land when hovering in slingload window above a WAITING vehicle
    self._hoverHintSent = {}  -- unitName → last hint time
    timer.scheduleFunction(function(_, t)
        local inst = CTLDVehicleSpawner._instance
        if inst then inst:_checkVehicleHoverHint() end
        return t + 5
    end, nil, timer.getTime() + 5)

    -- Auto-refresh Pack Vehicle menu when ground units appear or disappear nearby
    local ed = EventDispatcher.getInstance()
    ed:subscribe("OnGroundUnitSpawned", function(payload)
        if payload and payload.position then
            CTLDVehicleSpawner.getInstance():_refreshNearbyPackPlayers(payload.position)
        end
    end)
    ed:subscribe("OnGroundUnitRemoved", function(payload)
        if payload and payload.position then
            CTLDVehicleSpawner.getInstance():_refreshNearbyPackPlayers(payload.position)
        end
    end)
    -- Request Vehicle also triggers a pack-menu refresh (vehicle appears on ground)
    ed:subscribe("OnVehicleSpawnedForTransport", function(payload)
        if payload and payload.position then
            CTLDVehicleSpawner.getInstance():_refreshNearbyPackPlayers(payload.position)
        end
    end)

    -- Load / Unload vehicle: refresh both submenus for the transport player
    ed:subscribe("OnVehicleLoaded", function(payload)
        local t = payload and payload.transportUnitObject
        if t then
            local tName = t:getName()
            local inst  = CTLDVehicleSpawner.getInstance()
            inst:refreshLoadSectionForUnit(tName)
            inst:refreshUnloadSectionForUnit(tName)
        end
    end)
    ed:subscribe("OnVehicleUnloaded", function(payload)
        local t = payload and payload.transportUnitObject
        if t then
            local tName = t:getName()
            local inst  = CTLDVehicleSpawner.getInstance()
            inst:refreshLoadSectionForUnit(tName)
            inst:refreshUnloadSectionForUnit(tName)
        end
    end)

    ctld.utils.log("INFO", "CTLDVehicleSpawner: init complete")
end

-- ============================================================
-- Helpers (module-local)
-- ============================================================

--- Secure spawn offset in metres, derived from the transport's bounding box.
-- Mirrors ctld.getSecureDistanceFromUnit but works directly from a DCS Unit.
-- Falls back to 30 m if desc.box is unavailable.
local function _secureOffset(transport)
    local ok, box = pcall(function() return transport:getDesc().box end)
    if ok and box then
        return math.max(math.abs(box.max.x), math.abs(box.min.x)) + 5
    end
    return 30
end

--- Compute a spawn position in the front sector (±45 °) of transport.
-- @param transport DCS Unit
-- @return vec3
local function _computeSpawnPosition(transport)
    local hdg    = ctld.utils.getHeadingInRadians("CTLDVehicleSpawner._computeSpawnPosition",
                       transport, true)
    local offset = _secureOffset(transport)
    local angle  = ctld.utils.RandomReal("CTLDVehicleSpawner._computeSpawnPosition",
                       hdg - math.pi / 4, hdg + math.pi / 4)
    local pos    = transport:getPoint()
    local px     = pos.x + math.cos(angle) * offset
    local pz     = pos.z + math.sin(angle) * offset
    local py     = land.getHeight({ x = px, y = pz })
    return { x = px, y = py, z = pz }
end

--- True if a unit type name appears in the vehicleTransportEnabled config list.
local function _isNativeCargoCapable(unit)
    local typeLower = string.lower(unit:getTypeName())
    local list      = ctld.gs("vehicleTransportEnabled") or {}
    for _, name in ipairs(list) do
        if string.find(typeLower, string.lower(name), 1, true) then
            return true
        end
    end
    return false
end

-- ============================================================
-- spawnVehicleForTransport
-- ============================================================

--- Spawn a vehicle on the ground near a transport, in the front sector.
-- Creates a CTLDVehicle in WAITING state and publishes OnVehicleSpawnedForTransport.
--
-- @param vehicleType  string        DCS type name (e.g. "M1045 HMMWV TOW")
-- @param spawner      DCS Unit      transport aircraft requesting the vehicle
-- @param logisticZone table|nil     CTLDLogisticZone from which the request is made
-- @return CTLDVehicle or nil on spawn failure
function CTLDVehicleSpawner:spawnVehicleForTransport(vehicleType, spawner, logisticZone)
    self._vehicleCount = self._vehicleCount + 1
    local id       = string.format("veh_%d", self._vehicleCount)
    local baseName = string.format("CTLD_VEH_%s_%s", vehicleType, id)
    -- Replace characters that DCS does not accept in group/unit names
    baseName = baseName:gsub("[%s/\\]", "_")

    local spawnPos   = _computeSpawnPosition(spawner)
    local countryId  = spawner:getCountry()
    local spawnHdg   = ctld.utils.getHeadingInRadians(
                           "CTLDVehicleSpawner:spawnVehicleForTransport", spawner, true)

    local groupData = {
        visible  = true,
        hidden   = false,
        category = Group.Category.GROUND,
        country  = countryId,
        name     = baseName,
        task     = {},
        units    = {
            {
                type           = vehicleType,
                name           = baseName,
                x              = spawnPos.x,
                y              = spawnPos.z,   -- dynAdd: y == world Z
                heading        = spawnHdg,
                skill          = "Random",
                playerCanDrive = false,
            }
        },
    }

    local result = ctld.utils.dynAdd("CTLDVehicleSpawner:spawnVehicleForTransport", groupData)
    if not result then
        ctld.utils.log("ERROR",
            "CTLDVehicleSpawner: dynAdd failed for vehicle type=" .. tostring(vehicleType))
        return nil
    end

    local spawnedGroup = Group.getByName(result.name)
    local spawnedUnit  = spawnedGroup and spawnedGroup:getUnit(1) or nil

    local spawnData = {
        groupName   = baseName,
        unitName    = baseName,
        vehicleType = vehicleType,
        countryId   = countryId,
        coalitionId = spawner:getCoalition(),
    }

    local vehicle = CTLDVehicle:new({
        id           = id,
        vehicleType  = vehicleType,
        unit         = spawnedUnit,
        spawner      = spawner,
        logisticZone = logisticZone,
        spawnData    = spawnData,
    })

    self._vehicles[id] = vehicle
    if spawnedUnit then
        self._unitToVehicle[spawnedUnit:getName()] = id
    end

    EventDispatcher.getInstance():publish("OnVehicleSpawnedForTransport", {
        vehicleId    = id,
        vehicle      = spawnedUnit,
        vehicleType  = vehicleType,
        spawner      = spawner,
        logisticZone = logisticZone,
        spawnMethod  = "request_vehicle",
        position     = spawnPos,
        timestamp    = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner: spawned %s id=%s at (%.0f,%.0f,%.0f)",
        vehicleType, id, spawnPos.x, spawnPos.y, spawnPos.z))

    return vehicle
end

--- Register an externally-spawned JTAC vehicle (from unpack or Request JTAC Equipment)
-- into the CTLDVehicleSpawner registry so that load/unload can track it.
-- @param groupName   string   DCS group name of the spawned unit
-- @param vehicleType string   DCS type name
-- @param spawner     DCS Unit transport that requested it (or nil for unpack)
-- @param logisticZone table|nil
-- @return CTLDVehicle or nil
function CTLDVehicleSpawner:registerJTACVehicle(groupName, vehicleType, spawner, logisticZone)
    self._vehicleCount = self._vehicleCount + 1
    local id      = string.format("veh_%d", self._vehicleCount)
    local g       = Group.getByName(groupName)
    local unit    = g and g:getUnit(1) or nil
    local coa     = unit and unit:getCoalition() or (spawner and spawner:getCoalition() or 2)
    local country = unit and unit:getCountry()   or (spawner and spawner:getCountry()   or 2)

    local spawnData = {
        groupName   = groupName,
        unitName    = groupName,
        vehicleType = vehicleType,
        countryId   = country,
        coalitionId = coa,
    }

    local vehicle = CTLDVehicle:new({
        id           = id,
        vehicleType  = vehicleType,
        unit         = unit,
        spawner      = spawner,
        logisticZone = logisticZone,
        spawnData    = spawnData,
    })

    self._vehicles[id] = vehicle
    if unit then
        self._unitToVehicle[unit:getName()] = id
    end

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner:registerJTACVehicle — %s id=%s group=%s",
        vehicleType, id, groupName))
    return vehicle
end

--- Spawn a JTAC vehicle near a transport (Request JTAC Equipment menu action).
-- Delegates spawn to spawnVehicleForTransport then starts JTAC lasing.
-- @param vehicleType  string        DCS type name from JTAC_unitTypeNames
-- @param spawner      DCS Unit      requesting transport
-- @param logisticZone CTLDLogisticZone
-- @return CTLDVehicle or nil
function CTLDVehicleSpawner:spawnJTACVehicleForTransport(vehicleType, spawner, logisticZone)
    local vehicle = self:spawnVehicleForTransport(vehicleType, spawner, logisticZone)
    if not vehicle then return nil end
    -- Register as JTAC and start lasing
    CTLDJTACManager.get():startLase(vehicle.spawnData.groupName)
    return vehicle
end

-- ============================================================
-- loadVehicle
-- ============================================================

--- Load a vehicle into a transport.
-- The DCS unit is destroyed from the map.  spawnData is preserved for respawn.
-- Publishes OnVehicleLoaded.
--
-- @param vehicle   CTLDVehicle
-- @param transport DCS Unit
-- @param player    string|nil  player name
-- @param method    string      "menu_ctld" | "dcs_native"
function CTLDVehicleSpawner:loadVehicle(vehicle, transport, player, method)
    if vehicle:getState() ~= CTLDVehicle.STATE.WAITING then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:loadVehicle — vehicle "
            .. vehicle.id .. " not in WAITING state")
        return
    end

    local unitPos = vehicle.unit and vehicle.unit:getPoint() or transport:getPoint()

    -- Suspend JTAC lasing if this vehicle is a registered JTAC (any load method).
    -- For menu_ctld: unit is about to be destroyed so lasing must stop immediately.
    -- For dcs_native: unit stays alive inside aircraft but lasing from inside a soute is nonsensical.
    local groupName = vehicle.spawnData and vehicle.spawnData.groupName
    if groupName then
        CTLDJTACManager.get():setJTACInTransit(groupName,
            { unitName = transport:getName(), playerName = player })
    end

    if method == "dcs_native" then
        -- DCS manages the unit physically (linked inside aircraft) — do not destroy it.
        -- Remove from reverse lookup so onDead doesn't misfire if DCS sends a stale event.
        if vehicle.unit then
            self._unitToVehicle[vehicle.unit:getName()] = nil
        end
    else
        -- Virtual load: destroy the DCS unit from the map.
        if vehicle.unit and vehicle.unit:isExist() then
            vehicle.unit:destroy()
            EventDispatcher.getInstance():publish("OnGroundUnitRemoved", {
                vehicleType = vehicle.vehicleType,
                position    = unitPos,
                reason      = "loaded",
                timestamp   = timer.getAbsTime(),
            })
        end
        if vehicle.unit then
            self._unitToVehicle[vehicle.unit:getName()] = nil
        end
        vehicle.unit = nil
    end

    vehicle.loadMethod        = method
    vehicle.loadTransportName = transport:getName()
    vehicle.loadTime          = timer.getTime()
    vehicle:setState(CTLDVehicle.STATE.LOADED)

    EventDispatcher.getInstance():publish("OnVehicleLoaded", {
        vehicleId            = vehicle.id,
        ctldVehicleObject    = vehicle,
        dcsUnitObject        = method == "dcs_native" and vehicle.unit or nil,
        vehicleType          = vehicle.vehicleType,
        transportUnitObject  = transport,
        player               = player,
        method               = method,
        spawnMethod          = "request_vehicle",
        position             = unitPos,
        transportPosition    = transport:getPoint(),
        timestamp            = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner: loaded %s id=%s method=%s into %s",
        vehicle.vehicleType, vehicle.id, method, transport:getName()))
end

-- ============================================================
-- unloadVehicle
-- ============================================================

--- Unload a vehicle from a transport.
-- For menu_ctld / parachute: respawns DCS unit near transport via dynAdd.
-- For dcs_native: DCS has already placed the unit on the ground — just refresh the ref.
-- Publishes OnVehicleUnloaded.
--
-- @param vehicle   CTLDVehicle
-- @param transport DCS Unit
-- @param player    string|nil
-- @param method    string      "menu_ctld" | "dcs_native" | "parachute"
function CTLDVehicleSpawner:unloadVehicle(vehicle, transport, player, method)
    if vehicle:getState() ~= CTLDVehicle.STATE.LOADED then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:unloadVehicle — vehicle "
            .. vehicle.id .. " not in LOADED state")
        return
    end

    local sd       = vehicle.spawnData
    local spawnPos = _computeSpawnPosition(transport)
    local unloadedUnit

    if method == "dcs_native" then
        -- DCS has already placed the unit on the ground — recover the live ref.
        local g = Group.getByName(sd.groupName)
        unloadedUnit = g and g:getUnit(1) or nil
    else
        -- Virtual unload: respawn unit near transport.
        local spawnHdg = ctld.utils.getHeadingInRadians(
                             "CTLDVehicleSpawner:unloadVehicle", transport, true)
        local groupData = {
            visible  = true,
            hidden   = false,
            category = Group.Category.GROUND,
            country  = sd.countryId,
            name     = sd.groupName,
            task     = {},
            units    = {
                {
                    type           = sd.vehicleType,
                    name           = sd.unitName,
                    x              = spawnPos.x,
                    y              = spawnPos.z,
                    heading        = spawnHdg,
                    skill          = "Random",
                    playerCanDrive = false,
                }
            },
        }
        local result = ctld.utils.dynAdd("CTLDVehicleSpawner:unloadVehicle", groupData)
        if not result then
            ctld.utils.log("ERROR", "CTLDVehicleSpawner:unloadVehicle — dynAdd failed for id="
                .. vehicle.id)
            return
        end
        local respawnedGroup = Group.getByName(result.name)
        unloadedUnit = respawnedGroup and respawnedGroup:getUnit(1) or nil
    end

    vehicle.unit = unloadedUnit
    -- Vehicle is physically back on the ground — return to WAITING so it can be re-loaded.
    -- DELIVERED is reserved for parachute delivery (_parachuteVehicle).
    vehicle:setState(CTLDVehicle.STATE.WAITING)

    -- Re-register reverse lookup
    if unloadedUnit then
        self._unitToVehicle[unloadedUnit:getName()] = vehicle.id
    end

    -- Resume JTAC lasing if this vehicle is a registered JTAC.
    local groupName = sd and sd.groupName
    if groupName then
        CTLDJTACManager.get():resumeJTAC(groupName)
    end

    EventDispatcher.getInstance():publish("OnVehicleUnloaded", {
        vehicleId            = vehicle.id,
        ctldVehicleObject    = vehicle,
        dcsUnitObject        = unloadedUnit,
        vehicleType          = vehicle.vehicleType,
        transportUnitObject  = transport,
        player               = player,
        method               = method,
        spawnMethod          = "request_vehicle",
        position             = spawnPos,
        timestamp            = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner: unloaded %s id=%s method=%s from %s",
        vehicle.vehicleType, vehicle.id, method, transport:getName()))
end

-- ============================================================
-- Bbox helpers (_worldToLocal, _isInBbox)
-- ============================================================

--- Convert a world-frame point to the local frame of a DCS unit.
-- @param worldPoint vec3  { x, y, z } in world coordinates
-- @param transform  table Unit:getTransformation() result
--                   { p={x,y,z}, x={x,y,z}, y={x,y,z}, z={x,y,z} }
-- @return vec3  local-frame coordinates
function CTLDVehicleSpawner:_worldToLocal(worldPoint, transform)
    local dx = worldPoint.x - transform.p.x
    local dy = worldPoint.y - transform.p.y
    local dz = worldPoint.z - transform.p.z
    return {
        x = dx * transform.x.x + dy * transform.x.y + dz * transform.x.z,
        y = dx * transform.y.x + dy * transform.y.y + dz * transform.y.z,
        z = dx * transform.z.x + dy * transform.z.y + dz * transform.z.z,
    }
end

--- True if a local-frame point lies within a DCS bounding box.
-- @param localPoint vec3  result of _worldToLocal
-- @param box        table desc.box  { min={x,y,z}, max={x,y,z} }
-- @return boolean
function CTLDVehicleSpawner:_isInBbox(localPoint, box)
    return  localPoint.x >= box.min.x and localPoint.x <= box.max.x
        and localPoint.y >= box.min.y and localPoint.y <= box.max.y
        and localPoint.z >= box.min.z and localPoint.z <= box.max.z
end

-- ============================================================
-- _checkNativeLoading  (periodic, every 1 s)
-- ============================================================

--- Periodic check for DCS-native C-130 / Il-76 bbox load / unload detection.
-- For every transport in vehicleTransportEnabled that exists on the map:
--   • WAITING vehicle enters bbox  → loadVehicle (method="dcs_native")
--   • LOADED  vehicle exits  bbox  → unloadVehicle (method depends on inAir flag)
function CTLDVehicleSpawner:_checkNativeLoading()
    local vehicleTransports = ctld.gs("vehicleTransportEnabled") or {}
    if #vehicleTransports == 0 then return end

    -- Collect all active WAITING vehicles with live units
    local waitingVehicles = {}
    for id, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.WAITING
            and veh.unit and veh.unit:isExist() then
            waitingVehicles[id] = veh
        end
    end

    -- Collect all LOADED vehicles tracked via dcs_native
    local nativeLoaded = {}
    for id, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.LOADED
            and veh.loadMethod == "dcs_native" then
            nativeLoaded[id] = veh
        end
    end

    if not next(waitingVehicles) and not next(nativeLoaded) then return end

    -- Iterate transports currently known as player units (via CTLDPlayerTracker)
    -- and check each capable-transport unit that we can find by name
    -- Simple approach: scan all groups of both coalitions for matching type
    for _, side in ipairs({ coalition.side.BLUE, coalition.side.RED }) do
        local groups = coalition.getGroups(side, Group.Category.AIRPLANE) or {}
        for _, grp in ipairs(groups) do
            local units = grp:getUnits() or {}
            for _, transport in ipairs(units) do
                if transport:isExist() and _isNativeCargoCapable(transport) then
                    local ok, transform = pcall(function()
                        return transport:getTransformation()
                    end)
                    local ok2, box
                    if ok and transform then
                        ok2, box = pcall(function()
                            return transport:getDesc().box
                        end)
                    end

                    if ok and transform and ok2 and box then
                        local tName = transport:getName()

                        -- Check WAITING vehicles for bbox entry
                        for id, veh in pairs(waitingVehicles) do
                            local uPos = veh.unit:getPoint()
                            local lp   = self:_worldToLocal(uPos, transform)
                            if self:_isInBbox(lp, box) then
                                -- Vehicle entered bbox → load
                                self:loadVehicle(veh, transport, nil, "dcs_native")
                                -- Track transport for exit detection
                                self._nativeTracked[tName] = self._nativeTracked[tName] or {}
                                self._nativeTracked[tName][id] = true
                                waitingVehicles[id] = nil  -- prevent double-fire
                            end
                        end

                        -- Check LOADED (native) vehicles for bbox exit
                        for id, veh in pairs(nativeLoaded) do
                            if veh.loadTransportName == tName then
                                -- Vehicle is LOADED but we can't query its position (unit destroyed)
                                -- Use the tracked entry: if transport still alive, consider still loaded
                                -- Exit is detected by the transport being gone or in a different state
                                -- NOTE: When DCS ejects cargo the unit reappears; we detect the
                                -- re-appearance via the unit's new existence on next tick.
                                -- For parachute / ground exit we check if the spawned unit exists again.
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- onDead  (S_EVENT_DEAD handler)
-- ============================================================

--- Handle S_EVENT_DEAD: if the dead unit is a tracked vehicle, publish OnVehicleDead.
function CTLDVehicleSpawner:onDead(event)
    if not event or not event.initiator then return end
    local ok, unitName = pcall(function() return event.initiator:getName() end)
    if not ok then return end

    local vehicleId = self._unitToVehicle[unitName]
    if not vehicleId then return end

    local vehicle = self._vehicles[vehicleId]
    if not vehicle then return end

    local pos = vehicle.unit and vehicle.unit:getPoint() or { x = 0, y = 0, z = 0 }
    local spawnedAt = vehicle.spawnTime or 0

    self._vehicles[vehicleId]           = nil
    self._unitToVehicle[unitName]        = nil

    EventDispatcher.getInstance():publish("OnVehicleDead", {
        vehicleId     = vehicleId,
        vehicle       = event.initiator,
        vehicleType   = vehicle.vehicleType,
        coalition     = vehicle.spawnData and vehicle.spawnData.coalitionId or nil,
        position      = pos,
        durationAlive = timer.getTime() - spawnedAt,
        timestamp     = timer.getAbsTime(),
    })
    EventDispatcher.getInstance():publish("OnGroundUnitRemoved", {
        vehicleType = vehicle.vehicleType,
        position    = pos,
        reason      = "dead",
        timestamp   = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner: vehicle %s (%s) dead",
        vehicleId, vehicle.vehicleType))
end

-- ============================================================
-- Feature A — Virtual parachute
-- ============================================================

--- Replace the parachute visual effect handler.
-- @param effect CTLDParachuteEffect
function CTLDVehicleSpawner:setParachuteEffect(effect)
    self._parachuteEffect = effect
end

--- Parachute a vehicle currently loaded on a transport.
-- Altitude AGL is checked at call time. If below parachuteMinAltitudeVehicles,
-- a message is sent and nothing happens.
-- Computes landing position, unloads the vehicle from the transport,
-- fires OnVehicleParachuting, then after descentTime spawns the vehicle
-- at the computed position and fires OnVehicleParachuteLanded.
-- @param transport  Unit    DCS transport unit
-- @param vehicleId  number  vehicle ID to drop (first loaded vehicle if nil)
-- @param playerObj  table   CTLDPlayer-like {groupId, unitName, coalition}
function CTLDVehicleSpawner:parachuteVehicle(transport, vehicleId, playerObj)
    local dropPos     = transport:getPoint()
    local groundUnder = land.getHeight({ x = dropPos.x, y = dropPos.z })
    local altAGL      = dropPos.y - groundUnder
    local minAlt      = ctld.gs("parachuteMinAltitudeVehicles") or 30

    if altAGL < minAlt then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Altitude too low for parachute drop. Minimum: %dm AGL (current: %dm AGL)"),
                math.floor(minAlt), math.floor(altAGL)), 10)
        return
    end

    -- Resolve vehicle: use provided vehicleId or find first vehicle loaded on this transport
    local vehicle
    if vehicleId then
        vehicle = self._vehicles[vehicleId]
    else
        for _, v in pairs(self._vehicles) do
            if v.state == CTLDVehicle.STATE.LOADED and v.loadTransportName == transport:getName() then
                vehicle = v
                break
            end
        end
    end

    if not vehicle then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No vehicle loaded."), 8)
        return
    end

    local descentRate = ctld.gs("parachuteDescentRateVehicles") or 8
    local landPos, descentTime = ctld.utils.calcDropPosition(transport, descentRate)

    -- Unload from transport (mark as delivered — will be re-spawned at landing position)
    local spawnData = vehicle.spawnData
    vehicle:setState(CTLDVehicle.STATE.DELIVERED)

    local dropData = {
        type          = "vehicle",
        unitName      = vehicle.vehicleType,
        dropPosition  = dropPos,
        landPositions = { landPos },
        altitude      = altAGL,
        descentTime   = descentTime,
        transport     = transport,
        player        = playerObj.unitName,
    }
    self._parachuteEffect:onStart(dropData)

    EventDispatcher.getInstance():publish("OnVehicleParachuting", {
        vehicle              = vehicle,
        transport            = transport:getName(),
        player               = playerObj.unitName,
        altitude             = altAGL,
        dropPosition         = dropPos,
        estimatedLandingPos  = landPos,
        estimatedLandingTime = timer.getAbsTime() + descentTime,
        timestamp            = timer.getAbsTime(),
    })

    local _vehicle   = vehicle
    local _landPos   = landPos
    local _dropData  = dropData
    local _spawnData = spawnData
    timer.scheduleFunction(function()
        -- Spawn vehicle at computed landing position
        local spawnPos = { x = _landPos.x, y = _landPos.y, z = _landPos.z }
        if _spawnData then
            self:spawnVehicleAt(_spawnData, spawnPos)
        end

        self._parachuteEffect:onLanded(_dropData)

        EventDispatcher.getInstance():publish("OnVehicleParachuteLanded", {
            vehicle       = _vehicle,
            position      = _landPos,
            transport     = transport:getName(),
            player        = playerObj.unitName,
            startAltitude = altAGL,
            timestamp     = timer.getAbsTime(),
        })
    end, {}, timer.getTime() + descentTime)
end

--- Low-level ground unit factory.
-- Calls ctld.utils.spawnFromDescriptor (GROUND) and publishes OnGroundUnitSpawned so that
-- nearby Pack Vehicle menus refresh automatically.
-- @param spawnData  table  { vehicleType, groupName, unitName, coalitionId, country }
-- @param position   vec3   world position {x, y, z}
function CTLDVehicleSpawner:_spawnGroundUnit(spawnData, position)
    if not spawnData then return end
    local cId     = spawnData.country or spawnData.coalitionId or 2
    local unitDef = {
        name    = spawnData.groupName or (spawnData.vehicleType .. "_spawn_" .. timer.getAbsTime()),
        task    = "Ground Nothing",
        units   = {{
            type    = spawnData.vehicleType,
            name    = spawnData.unitName or spawnData.vehicleType,
            x       = position.x,
            y       = position.z,
            heading = 0,
        }},
    }
    local ok, err = ctld.utils.spawnFromDescriptor(nil, cId, unitDef)
    if not ok then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:_spawnGroundUnit - spawnFromDescriptor failed: " .. tostring(err))
        return
    end
    EventDispatcher.getInstance():publish("OnGroundUnitSpawned", {
        vehicleType = spawnData.vehicleType,
        position    = position,
        coalitionId = spawnData.coalitionId or 2,
        timestamp   = timer.getAbsTime(),
    })
end

--- Spawn a vehicle at an explicit world position (used by unpack and parachute drop).
-- @param spawnData  table   vehicle spawn descriptor
-- @param position   vec3    world position {x, y, z}
function CTLDVehicleSpawner:spawnVehicleAt(spawnData, position)
    self:_spawnGroundUnit(spawnData, position)
end

--- Refresh Pack Vehicle and Load Vehicle menus for all players within
-- maximumDistancePackableUnitsSearch of a position.
-- @param position vec3
function CTLDVehicleSpawner:_refreshNearbyPackPlayers(position)
    if not position then return end
    local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
    local pm      = CTLDPlayerManager.getInstance()
    for unitName in pairs(pm._players) do
        local unit = Unit.getByName(unitName)
        if unit and unit:isExist() then
            if ctld.utils.getDistance("_refreshNearbyPackPlayers", unit:getPoint(), position) <= maxDist then
                self:refreshPackSectionForUnit(unitName)
                self:refreshLoadSectionForUnit(unitName)
            end
        end
    end
end

-- ============================================================
-- F10 Menu section
-- ============================================================

-- ============================================================
-- Pack Vehicle
-- ============================================================

--- Detect inAir→landed transition for each player and refresh their menu.
-- Mirrors ctld.updatePackMenuOnlanding; called every 3 s from init timer.
function CTLDVehicleSpawner:_checkPackingLanding()
    if ctld.gs("enablePackingVehicles") ~= true then return end
    local players = CTLDPlayerManager.getInstance()._players
    for unitName, _ in pairs(players) do
        local unit = Unit.getByName(unitName)
        if unit and unit:isExist() then
            local inAirNow = ctld.utils.inAir(unit)
            if self._prevInAir[unitName] == true and not inAirNow then
                CTLDPlayerManager.getInstance():refreshForUnit(unitName)
            end
            self._prevInAir[unitName] = inAirNow
        else
            self._prevInAir[unitName] = nil
        end
    end
end

--- Periodic hint: send "Land to load vehicles" when a canCarryVehicles player hovers
-- between 3 m and maximumHoverHeight above a WAITING vehicle.
-- Called every 5 s; per-player cooldown of 30 s.
function CTLDVehicleSpawner:_checkVehicleHoverHint()
    local now      = timer.getTime()
    local cooldown = 30
    local minH     = 3.0
    local maxH     = ctld.gs("maximumHoverHeight") or 12.0
    local maxDist  = ctld.gs("maximumDistancePackableUnitsSearch") or 200
    local players  = CTLDPlayerManager.getInstance()._players

    for unitName, playerObj in pairs(players) do
        if playerObj.canCarryVehicles then
            local unit = Unit.getByName(unitName)
            if unit and unit:isExist() and ctld.utils.inAir(unit) then
                local lastHint = self._hoverHintSent[unitName] or 0
                if (now - lastHint) >= cooldown then
                    local tPos = unit:getPoint()
                    for _, veh in pairs(self._vehicles) do
                        if veh:getState() == CTLDVehicle.STATE.WAITING
                            and veh.unit and veh.unit:isExist() then
                            local vPos  = veh.unit:getPoint()
                            local dist2d = ctld.utils.getDistance(
                                "CTLDVehicleSpawner:_checkVehicleHoverHint", tPos, vPos)
                            local altDiff = tPos.y - vPos.y
                            if dist2d <= maxDist and altDiff >= minH and altDiff <= maxH then
                                self._hoverHintSent[unitName] = now
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    ctld.tr("Land to load vehicles"), 8)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

--- Return packable vehicles within maximumDistancePackableUnitsSearch of a transport.
-- Searches ground units of the same coalition; matches DCS typeName against spawnableCrates[*].unit.
-- @param transport DCS Unit
-- @return table  array of { unitName (string), descriptor (table) }
function CTLDVehicleSpawner:findPackableVehicles(transport)
    local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
    local coa     = transport:getCoalition()
    local tPos    = transport:getPoint()
    local result  = {}

    local groups = coalition.getGroups(coa, Group.Category.GROUND) or {}
    for _, grp in ipairs(groups) do
        for _, unit in ipairs(grp:getUnits() or {}) do
            if unit:isExist() then
                local dist = ctld.utils.getDistance(
                    "CTLDVehicleSpawner:findPackableVehicles", tPos, unit:getPoint())
                if dist <= maxDist then
                    local descriptor = CTLDCrateManager.getInstance()
                        :findDescriptorByUnitType(unit:getTypeName())
                    if descriptor then
                        table.insert(result, { unitName = unit:getName(), descriptor = descriptor })
                    end
                end
            end
        end
    end
    return result
end

--- Pack a vehicle back into crate(s).
-- Destroys the vehicle DCS unit and spawns cratesRequired static crates near the transport.
-- Front sector (heli) or rear sector (C-130/Il-76, dynamic cargo capable).
-- Publishes OnVehiclePacked and refreshes the player menu.
-- @param transportUnitName  string
-- @param packableUnitName   string
-- @param playerObj          table  { groupId, unitName, coalition }
function CTLDVehicleSpawner:packVehicle(transportUnitName, packableUnitName, playerObj)
    local transport = Unit.getByName(transportUnitName)
    if not (transport and transport:isExist()) then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:packVehicle - transport not found: "
            .. tostring(transportUnitName))
        return
    end

    local packableUnit = Unit.getByName(packableUnitName)
    if not (packableUnit and packableUnit:isExist()) then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("Vehicle no longer exists."), 8)
        return
    end

    local descriptor = CTLDCrateManager.getInstance()
        :findDescriptorByUnitType(packableUnit:getTypeName())
    if not descriptor then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("Cannot pack this vehicle type."), 8)
        return
    end

    local isDynamic    = _isNativeCargoCapable(transport)
    local hdg          = ctld.utils.getHeadingInRadians("CTLDVehicleSpawner:packVehicle", transport, true)
    local offset       = _secureOffset(transport)
    local cratesReq    = descriptor.cratesRequired or 1
    local modelKey     = isDynamic and "dynamic" or "load"
    local coa          = transport:getCoalition()
    local cId          = transport:getCountry()
    local tPos         = transport:getPoint()
    local packPos      = packableUnit:getPoint()   -- capture before destroy

    -- Silently deregister JTAC before destroy to prevent false OnJTACDead event.
    local packGroup = packableUnit:getGroup()
    if packGroup then
        CTLDJTACManager.get():deregisterJTAC(packGroup:getName())
    end

    packableUnit:destroy()
    EventDispatcher.getInstance():publish("OnGroundUnitRemoved", {
        vehicleType = packableUnit:getTypeName(),
        position    = packPos,
        reason      = "packed",
        timestamp   = timer.getAbsTime(),
    })

    -- Spawn crates in a straight line; spawnCratesAligned picks a random axis
    -- within the front sector (standard) or rear sector (native-cargo-capable).
    local descriptors = {}
    for _ = 1, cratesReq do table.insert(descriptors, descriptor) end
    CTLDCrateManager.getInstance():spawnCratesAligned(
        descriptors, transport, coa,
        playerObj and playerObj.unitName or nil,
        CTLDCrate.SPAWN_METHOD.VEHICLE_PACK)

    trigger.action.outTextForGroup(playerObj.groupId,
        string.format(ctld.tr("%s packed into %d crate(s)."), descriptor.desc, cratesReq), 10)

    EventDispatcher.getInstance():publish("OnVehiclePacked", {
        vehicleType  = packableUnit:getTypeName(),
        descriptor   = descriptor,
        transport    = transportUnitName,
        player       = playerObj and playerObj.unitName or nil,
        cratesSpawned = cratesReq,
        timestamp    = timer.getAbsTime(),
    })

    CTLDPlayerManager.getInstance():refreshForUnit(transportUnitName)
end

--- Refresh the "Pack Vehicle" submenu for a single player by unit name.
-- @param unitName string
function CTLDVehicleSpawner:refreshPackSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshPackSection(playerObj) end
end

--- Rebuild the "Pack Vehicle" dynamic submenu for playerObj.
-- Scans for packable ground vehicles within maximumDistancePackableUnitsSearch.
-- Called on menu build, on land, and after vehicle spawn (unpack).
-- @param playerObj CTLDPlayer
function CTLDVehicleSpawner:refreshPackSection(playerObj)
    if ctld.gs("enablePackingVehicles") ~= true then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local cratesSub = ctld.tr("Crate Commands")
    local packSub   = ctld.tr("Pack Vehicle")

    menu:clearBranch({ root, cratesSub, packSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, cratesSub, packSub },
            ctld.tr("Land to pack vehicles"), function() end, {})
        menu:refresh()
        return
    end

    local packable = self:findPackableVehicles(transport)
    if #packable == 0 then
        menu:addCommand({ root, cratesSub, packSub },
            ctld.tr("No packable vehicles nearby"), function() end, {})
    else
        for _, v in ipairs(packable) do
            menu:addCommand({ root, cratesSub, packSub }, v.descriptor.desc,
                function(arg)
                    CTLDVehicleSpawner.getInstance():packVehicle(
                        arg.transportName, arg.packableUnitName, arg)
                end,
                { transportName    = playerObj.unitName,
                  packableUnitName = v.unitName,
                  groupId          = playerObj.groupId,
                  unitName         = playerObj.unitName,
                  coalition        = playerObj.coalition })
        end
    end
    menu:refresh()
end

-- ============================================================
-- GAP-1 — Load / Unload vehicle via menu
-- ============================================================

--- Return loadable (WAITING) vehicles within maximumDistancePackableUnitsSearch of a transport.
-- Performs a lazy unit-reference resolution for vehicles registered before their DCS group
-- was fully available (coalition.addGroup has a 1-frame delay before Group.getByName works).
-- @param transport DCS Unit
-- @return table  array of CTLDVehicle
function CTLDVehicleSpawner:findLoadableVehicles(transport)
    local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
    local tPos    = transport:getPoint()
    local result  = {}
    for id, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.WAITING then
            -- Lazy resolve: unit ref may be nil if registered before DCS group was ready.
            if not veh.unit and veh.spawnData and veh.spawnData.groupName then
                local g = Group.getByName(veh.spawnData.groupName)
                local u = g and g:getUnit(1) or nil
                if u and u:isExist() then
                    veh.unit = u
                    self._unitToVehicle[u:getName()] = id
                end
            end
            if veh.unit and veh.unit:isExist() then
                local dist = ctld.utils.getDistance(
                    "CTLDVehicleSpawner:findLoadableVehicles", tPos, veh.unit:getPoint())
                if dist <= maxDist then
                    table.insert(result, veh)
                end
            end
        end
    end
    return result
end

--- Return vehicles currently LOADED on a transport (by unit name).
-- @param transport DCS Unit
-- @return table  array of CTLDVehicle
function CTLDVehicleSpawner:findLoadedVehicles(transport)
    local tName  = transport:getName()
    local result = {}
    for _, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.LOADED
            and veh.loadTransportName == tName then
            table.insert(result, veh)
        end
    end
    return result
end

--- Rebuild the "Load / Extract Vehicles" dynamic submenu for playerObj.
-- Transport must be landed; lists nearby WAITING vehicles.
-- @param playerObj CTLDPlayer
function CTLDVehicleSpawner:refreshLoadSection(playerObj)
    if not playerObj.canCarryVehicles then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root    = ctld.tr("CTLD")
    local vehSub  = ctld.tr("Vehicle Commands")
    local loadSub = ctld.tr("Load / Extract Vehicles")

    menu:clearBranch({ root, vehSub, loadSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, vehSub, loadSub },
            ctld.tr("Land to load vehicles"), function() end, {})
        menu:refresh()
        return
    end

    local loadable = self:findLoadableVehicles(transport)
    if #loadable == 0 then
        menu:addCommand({ root, vehSub, loadSub },
            ctld.tr("No vehicles nearby"), function() end, {})
    else
        for _, veh in ipairs(loadable) do
            local desc  = CTLDCrateManager.getInstance():findDescriptorByUnitType(veh.vehicleType)
            local label = desc and desc.desc or veh.vehicleType
            menu:addCommand({ root, vehSub, loadSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    local v = CTLDVehicleSpawner.getInstance()._vehicles[arg.vehicleId]
                    if not v or v:getState() ~= CTLDVehicle.STATE.WAITING then
                        trigger.action.outTextForGroup(arg.groupId,
                            ctld.tr("Vehicle no longer available."), 8)
                        return
                    end
                    CTLDVehicleSpawner.getInstance():loadVehicle(v, t, arg.unitName, "menu_ctld")
                    CTLDPlayerManager.getInstance():refreshForUnit(arg.unitName)
                end,
                { unitName  = playerObj.unitName,
                  groupId   = playerObj.groupId,
                  vehicleId = veh.id,
                  coalition = playerObj.coalition })
        end
    end
    menu:refresh()
end

--- Rebuild the "Unload Vehicles" dynamic submenu for playerObj.
-- Transport must be landed; lists vehicles currently LOADED on this transport.
-- @param playerObj CTLDPlayer
function CTLDVehicleSpawner:refreshUnloadSection(playerObj)
    if not playerObj.canCarryVehicles then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local vehSub    = ctld.tr("Vehicle Commands")
    local unloadSub = ctld.tr("Unload Vehicles")

    menu:clearBranch({ root, vehSub, unloadSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, vehSub, unloadSub },
            ctld.tr("Land to unload vehicles"), function() end, {})
        menu:refresh()
        return
    end

    local loaded = self:findLoadedVehicles(transport)
    if #loaded == 0 then
        menu:addCommand({ root, vehSub, unloadSub },
            ctld.tr("No vehicle loaded."), function() end, {})
    else
        for _, veh in ipairs(loaded) do
            local desc  = CTLDCrateManager.getInstance():findDescriptorByUnitType(veh.vehicleType)
            local label = desc and desc.desc or veh.vehicleType
            menu:addCommand({ root, vehSub, unloadSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    local v = CTLDVehicleSpawner.getInstance()._vehicles[arg.vehicleId]
                    if not v or v:getState() ~= CTLDVehicle.STATE.LOADED then
                        trigger.action.outTextForGroup(arg.groupId,
                            ctld.tr("Vehicle no longer loaded."), 8)
                        return
                    end
                    CTLDVehicleSpawner.getInstance():unloadVehicle(v, t, arg.unitName, "menu_ctld")
                    CTLDPlayerManager.getInstance():refreshForUnit(arg.unitName)
                end,
                { unitName  = playerObj.unitName,
                  groupId   = playerObj.groupId,
                  vehicleId = veh.id,
                  coalition = playerObj.coalition })
        end
    end
    menu:refresh()
end

--- Refresh the "Load / Extract Vehicles" submenu for a player by unit name.
-- @param unitName string
function CTLDVehicleSpawner:refreshLoadSectionForUnit(unitName)
    ctld.utils.log("INFO", string.format("CTLDVehicleSpawner:refreshLoadSectionForUnit unitName=%s", unitName))
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshLoadSection(playerObj) end
end

--- Refresh the "Unload Vehicles" submenu for a player by unit name.
-- @param unitName string
function CTLDVehicleSpawner:refreshUnloadSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshUnloadSection(playerObj) end
end

--- Build the "Vehicle Commands" F10 submenu for a player.
-- Added only when the unit can carry vehicles (canCarryVehicles = true).
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDVehicleSpawner:buildMenuSection(playerObj, menu)
    if not playerObj.canCarryVehicles then return end

    local root   = ctld.tr("CTLD")
    local vehSub = ctld.tr("Vehicle Commands")
    menu:addSubMenu({ root }, vehSub, { order = 30 })

    -- Dynamic load submenu (rebuilt by refreshLoadSection)
    menu:addSubMenu({ root, vehSub }, ctld.tr("Load / Extract Vehicles"))
    self:refreshLoadSection(playerObj)

    -- Dynamic unload submenu (rebuilt by refreshUnloadSection)
    menu:addSubMenu({ root, vehSub }, ctld.tr("Unload Vehicles"))
    self:refreshUnloadSection(playerObj)

    -- Parachute Vehicle: only if canParachute=true for this unit type
    local acts = (ctld.gs("unitActions") or {})[playerObj.typeName]
    if acts and acts.canParachute then
        menu:addCommand({ root, vehSub }, ctld.tr("Parachute Vehicle"),
            function(arg)
                local transport = Unit.getByName(arg.unitName)
                if not transport then return end
                CTLDVehicleSpawner.getInstance():parachuteVehicle(transport, nil, arg)
            end,
            { unitName = playerObj.unitName, groupId = playerObj.groupId,
              coalition = playerObj.coalition })
    end
end
