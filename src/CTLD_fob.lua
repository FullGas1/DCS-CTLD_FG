-- ============================================================
-- CTLD_fob.lua
-- CTLDFOB entity + CTLDFOBManager singleton
--
-- FOB lifecycle:
--   1. Player collects FOB crates near a logistics zone.
--   2. Player flies to the target area and calls unpackFOBCrates().
--   3. FOB crates are destroyed; buildTimeFOB seconds later fobScene
--      spawns (outpost + watchtower) at 100 m / 12 o'clock of the transport.
--   4. CTLDZoneManager registers the FOB position as a logistic zone.
--   5. CTLDBeaconManager drops an infinite-battery FOB beacon.
--   6. If troopPickupAtFOB, the FOB is also tracked as a troop-pickup point.
--   7. S_EVENT_DEAD on any scene object triggers integrity check;
--      if alive fraction < (1 - fobDestructionThreshold) → FOB destroyed.
--
-- Events published:
--   OnFOBDeployed   — when the scene completes and the FOB is fully active
--   OnFOBDestroyed  — when integrity threshold is breached
--
-- Dependencies: class (lib/class.lua), CTLDUtils (ctld.utils),
--               CTLDConfig (ctld.gs), EventDispatcher,
--               CTLDCrateManager, CTLDZoneManager, CTLDBeaconManager,
--               CTLDSceneManager, CTLDDCSEventBridge
-- DCS API: Unit.getByName, land.getHeight, timer, trigger.action
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDFOB  (entity)
-- ============================================================

CTLDFOB = class()

--- Constructor.
-- @param data table
--   Required: fobId, name, coalitionId, position (vec3), countryId
--   Optional: sceneObjects (array of DCS StaticObject), beacon (CTLDBeacon)
function CTLDFOB:init(data)
    self.fobId        = data.fobId
    self.name         = data.name
    self.coalitionId  = data.coalitionId
    self.countryId    = data.countryId
    self.position     = data.position       -- centroid vec3
    self.sceneObjects = data.sceneObjects or {}
    self.beacon       = data.beacon or nil
    self.spawnTime    = timer.getAbsTime()
end

--- True if at least one scene object is still alive.
function CTLDFOB:isAlive()
    for _, obj in ipairs(self.sceneObjects) do
        if obj and obj:isExist() then return true end
    end
    return false
end

--- Alive fraction of scene objects (0.0–1.0). Returns 0 if no objects tracked.
function CTLDFOB:getIntegrityPercent()
    local total = #self.sceneObjects
    if total == 0 then return 0 end
    local alive = 0
    for _, obj in ipairs(self.sceneObjects) do
        if obj and obj:isExist() then alive = alive + 1 end
    end
    return alive / total
end


-- ============================================================
-- CTLDFOBManager  (singleton)
-- ============================================================

CTLDFOBManager = class()
CTLDFOBManager._instance = nil

function CTLDFOBManager.getInstance()
    if not CTLDFOBManager._instance then
        local o = setmetatable({}, CTLDFOBManager)
        o:init()
        CTLDFOBManager._instance = o
    end
    return CTLDFOBManager._instance
end

function CTLDFOBManager:init()
    self._fobs        = {}   -- fobId  → CTLDFOB
    self._fobCount    = 0
    self._objectToFOB = {}   -- DCS object name → fobId  (reverse lookup for onDead)

    local ok, bridge = pcall(CTLDDCSEventBridge.getInstance)
    if ok and bridge then
        bridge:register(self, world.event.S_EVENT_DEAD, "onDead")
    end

    CTLDPlayerManager.getInstance():registerMenuSection({
        key       = "fobs",
        manager   = self,
        method    = "buildMenuSection",
        configKey = "enabledFOBBuilding",
        order     = 60,
    })

    ctld.utils.log("INFO", "CTLDFOBManager: init complete")
end

-- ============================================================
-- Helpers
-- ============================================================

--- Compute the centroid 100 m at 12 o'clock from a transport unit.
local function _computeCentroid(transport)
    local pt  = transport:getPoint()
    local hdg = ctld.utils.getHeadingInRadians("CTLDFOBManager._computeCentroid", transport, true)
    local fx  = pt.x + math.cos(hdg) * 100
    local fz  = pt.z + math.sin(hdg) * 100
    return { x = fx, y = land.getHeight({ x = fx, y = fz }), z = fz }
end

--- Collect FOB crates on the ground within radius metres of position.
-- The FOB sentinel value is unit = "FOB" (set in spawnableCrates descriptor).
-- Returns { crates=[], total }.
local function _collectFOBCrates(position, coalitionId, radius)
    local cm     = CTLDCrateManager.getInstance()
    local nearby = cm:getCratesInRange(position, radius)
    local result = { crates = {}, total = 0 }

    for _, crate in ipairs(nearby) do
        if crate.coalition == coalitionId then
            local unit = crate.descriptor and crate.descriptor.unit
            if unit == "FOB" then
                result.total = result.total + 1
                result.crates[#result.crates + 1] = crate
            end
        end
    end

    return result
end

--- True if position is inside any active logistic zone for coalitionId.
local function _isInLogisticZone(position, coalitionId)
    local zm = CTLDZoneManager.getInstance()
    return zm:getLogisticZoneAtPoint(position, coalitionId) ~= nil
end

--- True if position is closer than fobMinDistanceFromZones to any logistic zone.
local function _isTooCloseToZone(position, coalitionId)
    local minDist = ctld.gs("fobMinDistanceFromZones") or 500
    local zm      = CTLDZoneManager.getInstance()
    for _, zone in ipairs(zm:getLogisticZonesForCoalition(coalitionId)) do
        if ctld.utils.getDistance("_isTooCloseToZone", position, zone:getCenter()) < minDist then
            return true
        end
    end
    return false
end

-- ============================================================
-- Core action: unpack FOB crates → schedule build
-- ============================================================

--- Called from F10 menu when a player attempts to unpack FOB crates.
-- @param transport DCS Unit
-- @param player    string  player name (display only)
function CTLDFOBManager:unpackFOBCrates(transport, player)
    if not ctld.gs("enabledFOBBuilding") then return end

    local gid = transport:getGroup():getID()

    -- Guard: airborne
    if ctld.utils.inAir(transport) then
        trigger.action.outTextForGroup(gid,
            ctld.tr("You must be on the ground to deploy a FOB."), 10)
        return
    end

    local pos         = transport:getPoint()
    local coalitionId = transport:getCoalition()

    -- Guard: not enough crates (checked first for clearer feedback)
    local fobDesc    = CTLDCrateManager.getInstance():findDescriptorByUnitType("FOB")
    local required   = (fobDesc and fobDesc.cratesRequired) or 3
    local collected  = _collectFOBCrates(pos, coalitionId, 750)
    if collected.total < required then
        trigger.action.outTextForGroup(gid,
            ctld.tr("FOB needs %1 crate(s) within 750 m - only %2 found.",
                required, collected.total), 15)
        return
    end

    -- Guard: inside existing logistic zone
    if _isInLogisticZone(pos, coalitionId) then
        trigger.action.outTextForGroup(gid,
            ctld.tr("You can't deploy a FOB here! Take it to where it's needed."), 20)
        return
    end

    -- Guard: too close to another zone
    if _isTooCloseToZone(pos, coalitionId) then
        local minDist = ctld.gs("fobMinDistanceFromZones") or 500
        trigger.action.outTextForGroup(gid,
            ctld.tr("FOB deployment blocked: move at least %1 m away from existing logistic zone.",
                minDist), 20)
        return
    end

    -- Destroy crates
    local cm          = CTLDCrateManager.getInstance()
    local cratesUsed  = {}
    for _, crate in ipairs(collected.crates) do
        cratesUsed[#cratesUsed + 1] = {
            crateName  = crate.crateName,
            descriptor = crate.descriptor,
        }
        cm:destroyCrate(crate.crateName)
    end

    -- Pre-compute centroid (100 m / 12 o'clock from transport NOW, not after buildTime)
    local centroid    = _computeCentroid(transport)
    local buildTime   = ctld.gs("buildTimeFOB") or 120
    local countryId   = transport:getCountry()
    local transName   = transport:getName()
    local self_ref    = self

    -- Visual feedback
    trigger.action.outTextForCoalition(coalitionId,
        ctld.tr("%1 started building a FOB (%2 crate(s)). Ready in %3 seconds.",
            player, #cratesUsed, buildTime), 10)

    -- Schedule scene spawn
    timer.scheduleFunction(function()
        local transport2 = Unit.getByName(transName)
        if not transport2 or not transport2:isExist() then
            -- Transport left; use a minimal proxy (coalition/country from cache)
            -- The scene will use params.centroid for positioning.
            transport2 = transport  -- stale ref — only coalition/country are read by scene engine
        end

        CTLDSceneManager.getInstance():playScene(
            transport2,
            "fobScene",
            { player = player, centroid = centroid },
            function(scene)
                self_ref:_onFOBBuilt(scene, transName, player, centroid, coalitionId, countryId, cratesUsed)
            end
        )
    end, nil, timer.getTime() + buildTime)
end

-- ============================================================
-- Post-scene callback
-- ============================================================

--- Called by fobScene's onComplete when all steps have finished.
function CTLDFOBManager:_onFOBBuilt(scene, transportName, player, centroid, coalitionId, countryId, cratesUsed)
    self._fobCount = self._fobCount + 1
    local fobId    = string.format("fob_%03d", self._fobCount)
    local fobName  = string.format("Deployed FOB #%d", self._fobCount)

    -- Collect spawned DCS objects from the scene
    local sceneObjects = scene._spawnedObjs or {}

    -- Build CTLDFOB entity
    local fob = CTLDFOB:new({
        fobId        = fobId,
        name         = fobName,
        coalitionId  = coalitionId,
        countryId    = countryId,
        position     = centroid,
        sceneObjects = sceneObjects,
    })

    -- Register reverse-lookup for onDead integrity tracking
    for _, obj in ipairs(sceneObjects) do
        if obj and obj:isExist() then
            self._objectToFOB[obj:getName()] = fobId
        end
    end

    self._fobs[fobId] = fob

    -- Register as logistic zone
    local logRadius = ctld.gs("fobLogisticZoneRadius") or 150
    CTLDZoneManager.getInstance():registerFOBAsLogistic(fobName, centroid, logRadius, coalitionId)

    -- Drop FOB beacon (infinite battery).
    -- Beacon is placed in the open space between container and watchtower:
    -- 20 m at 158° from the scene heading (same direction as watchtower step,
    -- but short enough to stay clear of both buildings).
    local transport = Unit.getByName(transportName)
    if transport and transport:isExist() and CTLDBeaconManager then
        local hdg        = scene._refHdgRad or 0
        local angleRad   = hdg + math.rad(158)
        local leftRad    = hdg - math.pi / 2   -- perpendicular left from heli heading
        local beaconPos  = {
            x = centroid.x + math.cos(angleRad) * 20 + math.cos(leftRad) * 7,
            y = centroid.y,
            z = centroid.z + math.sin(angleRad) * 20 + math.sin(leftRad) * 7,
        }
        local beacon = CTLDBeaconManager.getInstance():dropBeacon(transport, player, true, beaconPos)
        fob.beacon = beacon
    end

    -- Troop pickup at FOB
    if ctld.gs("troopPickupAtFOB") then
        fob._troopPickup = true
    end

    ctld.utils.log("INFO",
        "CTLDFOBManager: FOB '%s' deployed at (%.0f, %.0f) by '%s'",
        fobName, centroid.x, centroid.z, player)

    EventDispatcher.getInstance():publish("OnFOBDeployed", {
        fob = {
            fobId      = fobId,
            name       = fobName,
            coalitionId= coalitionId,
        },
        cratesUsed       = cratesUsed,
        totalCratesUsed  = #cratesUsed,
        position         = centroid,
        sceneObjects     = sceneObjects,
        logisticZone     = {
            name   = fobName,
            radius = logRadius,
            type   = "static",
        },
        player    = player,
        timestamp = timer.getAbsTime(),
    })
end

-- ============================================================
-- S_EVENT_DEAD — integrity check
-- ============================================================

function CTLDFOBManager:onDead(event)
    local obj = event.initiator
    if not obj then return end
    local objName = obj:getName()

    local fobId = self._objectToFOB[objName]
    if not fobId then return end

    local fob = self._fobs[fobId]
    if not fob then return end

    local threshold = ctld.gs("fobDestructionThreshold") or 0.5
    local integrity = fob:getIntegrityPercent()

    ctld.utils.log("INFO",
        "CTLDFOBManager: FOB '%s' scene object '%s' dead — integrity %.0f%%",
        fob.name, objName, integrity * 100)

    if integrity < (1 - threshold) then
        -- Killer info is not reliably available from S_EVENT_DEAD alone.
        local killerUnit      = nil
        local killerCoalition = nil
        self:_destroyFOB(fob, killerUnit, killerCoalition, integrity)
    end
end

--- Cleanup a destroyed FOB: remove logistic zone, publish event, unregister.
function CTLDFOBManager:_destroyFOB(fob, killerUnit, killerCoalition, integrityPercent)
    local objectsTotal     = #fob.sceneObjects
    local objectsDestroyed = objectsTotal - math.floor(integrityPercent * objectsTotal + 0.5)
    local durationAlive    = timer.getAbsTime() - fob.spawnTime

    -- Remove logistic zone
    CTLDZoneManager.getInstance():unregisterLogistic(fob.name)

    -- Clean reverse-lookup
    for _, obj in ipairs(fob.sceneObjects) do
        if obj then self._objectToFOB[obj:getName()] = nil end
    end

    -- Remove from registry
    self._fobs[fob.fobId] = nil

    ctld.utils.log("INFO",
        "CTLDFOBManager: FOB '%s' destroyed (%.0f%% integrity, alive %.0fs)",
        fob.name, (integrityPercent or 0) * 100, durationAlive)

    EventDispatcher.getInstance():publish("OnFOBDestroyed", {
        fob = {
            fobId      = fob.fobId,
            name       = fob.name,
            coalitionId= fob.coalitionId,
        },
        position = fob.position,
        destruction = {
            killerUnit         = killerUnit,
            killerCoalition    = killerCoalition,
            objectsDestroyed   = objectsDestroyed,
            objectsTotal       = objectsTotal,
            destructionThreshold = ctld.gs("fobDestructionThreshold") or 0.5,
            integrityPercent   = integrityPercent or 0,
        },
        logisticZone = { name = fob.name, wasActive = true },
        durationAlive = durationAlive,
        timestamp     = timer.getAbsTime(),
    })
end

-- ============================================================
-- Query API
-- ============================================================

--- Return all active FOBs for a coalition.
-- @param coalitionId number  coalition.side.*
-- @return table  array of CTLDFOB
function CTLDFOBManager:getFOBsForCoalition(coalitionId)
    local result = {}
    for _, fob in pairs(self._fobs) do
        if fob.coalitionId == coalitionId then
            result[#result + 1] = fob
        end
    end
    return result
end

--- True if point is within fobTroopPickupRadius of any troop-pickup FOB.
-- @param point       vec3
-- @param coalitionId number
-- @return boolean
function CTLDFOBManager:isInFOBTroopZone(point, coalitionId)
    local radius = ctld.gs("fobTroopPickupRadius") or 150
    for _, fob in pairs(self._fobs) do
        if fob.coalitionId == coalitionId and fob._troopPickup and fob:isAlive() then
            if ctld.utils.getDistance(point, fob.position) <= radius then
                return true
            end
        end
    end
    return false
end

--- Display active (alive) FOB positions to the transport's group.
-- Shows: name, coords, integrity%, beacon freqs if present.
-- Destroyed FOBs are silently omitted.
-- @param transport DCS Unit
function CTLDFOBManager:listFOBs(transport)
    local coalitionId = transport:getCoalition()
    local gid         = transport:getGroup():getID()
    local all         = self:getFOBsForCoalition(coalitionId)

    -- Keep only alive FOBs
    local fobs = {}
    for _, fob in ipairs(all) do
        if fob:isAlive() then fobs[#fobs + 1] = fob end
    end

    if #fobs == 0 then
        trigger.action.outTextForGroup(gid, ctld.tr("No active FOBs."), 15)
        return
    end

    local lines = { ctld.tr("FOB Positions:") }
    for _, fob in ipairs(fobs) do
        local lat, lon = coord.LOtoLL(fob.position)
        local latLon   = ctld.utils.tostringLL(
            "CTLDFOBManager:listFOBs", lat, lon, 3, ctld.gs("location_DMS") or false)
        local integrity = string.format("%.0f%%", fob:getIntegrityPercent() * 100)
        local line      = string.format("  %s — %s — %s", fob.name or fob.fobId, latLon, integrity)
        if fob.beacon then
            line = line .. string.format(
                "\n    VHF %.1f kHz / UHF %.1f MHz / FM %.1f MHz",
                fob.beacon.vhf / 1000,
                fob.beacon.uhf / 1000000,
                fob.beacon.fm  / 1000000)
        end
        lines[#lines + 1] = line
    end
    trigger.action.outTextForGroup(gid, table.concat(lines, "\n"), 20)
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Build the "FOBs List" F10 submenu (CTLD > FOBs List).
-- Registered with CTLDPlayerManager, gated by enabledFOBBuilding.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDFOBManager:buildMenuSection(playerObj, menu)
    local root   = ctld.tr("CTLD")
    local fobSub = ctld.tr("FOBs List")
    menu:addSubMenu({ root }, fobSub, { order = 60 })

    menu:addCommand({ root, fobSub }, ctld.tr("List active FOBs"),
        function(arg)
            local t = Unit.getByName(arg.unitName)
            if not (t and t:isExist()) then return end
            CTLDFOBManager.getInstance():listFOBs(t)
        end,
        { unitName = playerObj.unitName })
end
