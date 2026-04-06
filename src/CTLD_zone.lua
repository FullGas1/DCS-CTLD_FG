-- ============================================================
-- CTLD_zone.lua
-- CTLDTroopZone + CTLDLogisticZone entities + CTLDZoneManager singleton
--
-- Dependencies : class (lib/class.lua), CTLDUtils (ctld.utils),
--                CTLDConfig (ctld.gs), EventDispatcher
-- DCS API      : env.mission.triggers.zones, trigger.misc.getZone,
--                trigger.action.smoke, trigger.action.setUserFlag,
--                trigger.misc.getUserFlag, land.getHeight,
--                Unit.getByName, StaticObject.getByName
--
-- Zone naming conventions:
--
--   TRZ  (TroopZone) — troops pickup / extract / mixed
--     TRZ_zoneName_[R|B|N]_[pickMaxStock]_[flag]_[dropMaxTarget]
--     Position-based parsing: R|B|N first, then number = stock,
--     then string = flag, then number = target.
--     0 stock = unlimited pickup.
--
--   LGZ  (LogisticZone) — crate/vehicle services
--     LGZ_name_[R|B|N]
--
-- Legacy fallback: missions using the old PKZ/DOZ/WPZ/EXZ prefix
-- or the ctld.gs config tables (pickupZones, dropOffZones, wpZones,
-- logisticUnits) are loaded after TRZ/LGZ discovery; existing entries
-- are never overwritten.
--
-- Events published:
--   OnZoneSmokeRefreshed  — every smokeRefreshInterval seconds
--   OnLogisticZoneUpdated — at init + on dynamic unit death
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDTroopZone  (entity)
-- ============================================================

CTLDTroopZone = class()

--- Constructor.
-- @param data table
--   Required : dcsName, zoneName, coalition, center (vec3), radius
--   Optional : verticies, pickMaxStock, objectiveFlag, objectiveTarget,
--              smoke (trigger.smokeColor.* or -1), active
function CTLDTroopZone:init(data)
    self.dcsName          = data.dcsName
    self.zoneName         = data.zoneName
    self.coalition        = data.coalition  or 0
    self.center           = data.center
    self.radius           = data.radius     or 0
    self.verticies        = data.verticies  or nil

    -- Pickup stock (nil = this zone has no pickup function)
    self.pickMaxStock     = data.pickMaxStock    -- nil | number  (0 = unlimited)
    self.pickCurrentStock = (data.pickMaxStock ~= nil and data.pickMaxStock ~= 0)
                            and data.pickMaxStock or 0

    -- Extract objective (nil = this zone has no extract function)
    self.objectiveFlag    = data.objectiveFlag   -- nil | string
    self.objectiveTarget  = data.objectiveTarget -- nil | number

    self.smoke  = (data.smoke ~= nil) and data.smoke or -1
    self.active = (data.active ~= nil) and data.active or true
end

--- True if this zone acts as a pickup zone (troops can board here).
function CTLDTroopZone:hasPickup()
    return self.pickMaxStock ~= nil
end

--- True if this zone acts as an extract / objective zone.
function CTLDTroopZone:hasExtract()
    return self.objectiveFlag ~= nil
end

--- True if point is inside the zone (circular or polygonal).
function CTLDTroopZone:isInZone(point)
    if self.verticies and #self.verticies >= 3 then
        return CTLDTroopZone._raycast(point, self.verticies)
    end
    return ctld.utils.getDistance("CTLDTroopZone:isInZone", point, self.center) <= self.radius
end

--- Jordan ray-casting for polygonal zones.
-- verticies[i].x / .y are mission-file coordinates (mission Y = world Z).
function CTLDTroopZone._raycast(point, verts)
    local px, pz = point.x, point.z
    local inside = false
    local n = #verts
    local j = n
    for i = 1, n do
        local xi, zi = verts[i].x, verts[i].y
        local xj, zj = verts[j].x, verts[j].y
        if ((zi > pz) ~= (zj > pz)) and
           (px < (xj - xi) * (pz - zi) / (zj - zi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

--- Consume n troops from pickup stock. Returns true on success.
-- Unlimited stock (pickMaxStock == 0) always succeeds.
-- @param n number   troops to consume
-- @return boolean
function CTLDTroopZone:consumeStock(n)
    if not self:hasPickup() then return false end
    if self.pickMaxStock == 0 then return true end  -- unlimited
    if self.pickCurrentStock < n then return false end
    self.pickCurrentStock = self.pickCurrentStock - n
    return true
end

--- Restore n troops to pickup stock (capped at pickMaxStock).
-- No-op for unlimited or non-pickup zones.
-- @param n number
function CTLDTroopZone:restoreStock(n)
    if not self:hasPickup() or self.pickMaxStock == 0 then return end
    self.pickCurrentStock = math.min(self.pickMaxStock, self.pickCurrentStock + n)
end

--- Increment the objective flag by soldierCount and check win condition.
-- @param soldierCount number
-- @return boolean incremented, number valueBefore, number valueAfter
function CTLDTroopZone:incrementObjective(soldierCount)
    if not self.objectiveFlag then return false, 0, 0 end
    local before = trigger.misc.getUserFlag(self.objectiveFlag)
    local after  = before + soldierCount
    trigger.action.setUserFlag(self.objectiveFlag, after)
    if self.objectiveTarget and after >= self.objectiveTarget then
        ctld.utils.log("INFO", "CTLDTroopZone: objective '%s' COMPLETE (%d/%d)",
            self.objectiveFlag, after, self.objectiveTarget)
    end
    return true, before, after
end

function CTLDTroopZone:getCenter() return self.center end
function CTLDTroopZone:activate()   self.active = true  end
function CTLDTroopZone:deactivate() self.active = false end


-- ============================================================
-- CTLDLogisticZone  (entity)
-- ============================================================

CTLDLogisticZone = class()

--- Constructor.
-- @param data table
--   Required : name, coalition, center (vec3), radius
--   Optional : linkedUnit (Unit — dynamic zone follows this unit),
--              active, services table
function CTLDLogisticZone:init(data)
    self.name        = data.name
    self.coalition   = data.coalition or 0
    self._center     = data.center
    self.radius      = data.radius   or 200
    self._linkedUnit = data.linkedUnit or nil
    self.active      = (data.active ~= nil) and data.active or true
    self.services    = data.services or {
        cratesPickup  = true,
        cratesDropoff = true,
        vehicleSpawn  = true,
    }
end

--- Return current center. Dynamic zones follow their linked unit.
function CTLDLogisticZone:getCenter()
    if self._linkedUnit and self._linkedUnit:isExist() then
        return self._linkedUnit:getPoint()
    end
    return self._center
end

--- True if this zone is anchored to a moving DCS unit.
function CTLDLogisticZone:isDynamic()
    return self._linkedUnit ~= nil
end

--- True if the linked unit is still alive (always true for static zones).
function CTLDLogisticZone:isAlive()
    if not self._linkedUnit then return true end
    return self._linkedUnit:isExist()
end

--- True if point is inside the zone (circular only — logistic zones are always circular).
function CTLDLogisticZone:isInZone(point)
    return ctld.utils.getDistance("CTLDLogisticZone:isInZone", point, self:getCenter()) <= self.radius
end

function CTLDLogisticZone:activate()   self.active = true  end
function CTLDLogisticZone:deactivate() self.active = false end


-- ============================================================
-- CTLDZoneManager  (singleton)
-- ============================================================

CTLDZoneManager = class()
CTLDZoneManager._instance = nil

local _TROOP_SMOKE_COLOR = {
    [0] = trigger.smokeColor.Green,
    [1] = trigger.smokeColor.Red,
    [2] = trigger.smokeColor.White,
    [3] = trigger.smokeColor.Orange,
    [4] = trigger.smokeColor.Blue,
}
-- Legacy smoke string to number
local _LEGACY_SMOKE_STR = { green=0, red=1, white=2, orange=3, blue=4 }

--- Return (or create) the singleton instance.
-- Triggers full init (discovery + legacy load + smoke schedule + bridge registration).
function CTLDZoneManager.getInstance()
    if not CTLDZoneManager._instance then
        local o = setmetatable({}, CTLDZoneManager)
        o:init()
        CTLDZoneManager._instance = o
    end
    return CTLDZoneManager._instance
end

function CTLDZoneManager:init()
    self._troopZones    = {}   -- zoneName -> CTLDTroopZone
    self._logisticZones = {}   -- name     -> CTLDLogisticZone

    -- Register S_EVENT_DEAD for dynamic logistic zone tracking
    local ok, bridge = pcall(CTLDDCSEventBridge.getInstance)
    if ok and bridge then
        bridge:register(self, world.event.S_EVENT_DEAD, "onDead")
    end

    self:_validateZoneNames()
    self:_discoverTRZ()
    self:_discoverLGZ()
    self:_loadLegacyZones()
    self:_scheduleSmoke()

    -- Publish initial state
    self:_publishLogisticZoneUpdated({}, {})

    ctld.utils.log("INFO",
        "CTLDZoneManager ready — troop:%d logistic:%d",
        self:_count(self._troopZones), self:_count(self._logisticZones))
end

-- ============================================================
-- Helpers
-- ============================================================

local function _split(str, sep)
    local parts = {}
    for p in string.gmatch(str, "[^" .. sep .. "]+") do
        parts[#parts + 1] = p
    end
    return parts
end

local function _buildCenter(zd)
    local x = zd.x
    local z = zd.y   -- mission-file Y = world Z
    local y = land.getHeight({ x = x, y = z })
    return { x = x, y = y, z = z }
end

function CTLDZoneManager:_count(tbl)
    local n = 0
    for _ in pairs(tbl) do n = n + 1 end
    return n
end

-- ============================================================
-- TRZ parser
-- ============================================================

-- Parse TRZ_zoneName_[R|B|N]_[pickMaxStock]_[flag]_[dropMaxTarget]
-- Returns a table on success, nil + error string on failure.
function CTLDZoneManager:_parseTRZ(name)
    local parts = _split(name, "_")
    if parts[1] ~= "TRZ" then return nil, "not a TRZ" end
    local zoneName = parts[2]
    if not zoneName then return nil, "missing zoneName" end

    local coalitionId = 0
    local stock, flag, target = nil, nil, nil
    local i = 3

    -- 1. Optional coalition R|B|N
    if parts[i] == "R" or parts[i] == "B" or parts[i] == "N" then
        if     parts[i] == "R" then coalitionId = coalition.side.RED
        elseif parts[i] == "B" then coalitionId = coalition.side.BLUE
        else                        coalitionId = coalition.side.NEUTRAL end
        i = i + 1
    end

    -- 2. Optional pickMaxStock (number before flag)
    if parts[i] and tonumber(parts[i]) then
        stock = tonumber(parts[i])
        i = i + 1
    end

    -- 3. Optional objectiveFlag (string, not a number)
    if parts[i] and not tonumber(parts[i]) then
        flag = parts[i]
        i = i + 1
    end

    -- 4. Optional dropMaxTarget (number after flag)
    if parts[i] and tonumber(parts[i]) then
        target = tonumber(parts[i])
    end

    return {
        zoneName       = zoneName,
        coalition      = coalitionId,
        pickMaxStock   = stock,
        objectiveFlag  = flag,
        objectiveTarget= target,
    }
end

-- Parse LGZ_name_[R|B|N]
function CTLDZoneManager:_parseLGZ(name)
    local parts = _split(name, "_")
    if parts[1] ~= "LGZ" then return nil end
    local lgzName     = parts[2]
    local coalitionId = 0
    if     parts[3] == "R" then coalitionId = coalition.side.RED
    elseif parts[3] == "B" then coalitionId = coalition.side.BLUE
    elseif parts[3] == "N" then coalitionId = coalition.side.NEUTRAL end
    return { name = lgzName, coalition = coalitionId }
end

-- ============================================================
-- Discovery
-- ============================================================

function CTLDZoneManager:_discoverTRZ()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then
        ctld.utils.log("WARN", "CTLDZoneManager: env.mission.triggers.zones not accessible")
        return
    end
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "TRZ_" then
            local parsed, err = self:_parseTRZ(name)
            if not parsed then
                ctld.utils.log("WARN", "CTLDZoneManager: cannot parse TRZ '%s': %s", name, tostring(err))
            elseif not self._troopZones[parsed.zoneName] then
                local zone = CTLDTroopZone:new({
                    dcsName        = name,
                    zoneName       = parsed.zoneName,
                    coalition      = parsed.coalition,
                    center         = _buildCenter(zd),
                    radius         = zd.radius or 500,
                    verticies      = zd.verticies or nil,
                    pickMaxStock   = parsed.pickMaxStock,
                    objectiveFlag  = parsed.objectiveFlag,
                    objectiveTarget= parsed.objectiveTarget,
                    smoke          = ctld.gs("troopZoneSmokeColor") and
                                     ctld.gs("troopZoneSmokeColor")[parsed.coalition] or -1,
                    active         = true,
                })
                if zone.objectiveFlag then
                    trigger.action.setUserFlag(zone.objectiveFlag, 0)
                end
                self._troopZones[parsed.zoneName] = zone
                ctld.utils.log("INFO",
                    "CTLDZoneManager: TRZ '%s' coalition=%d stock=%s flag=%s target=%s",
                    parsed.zoneName, parsed.coalition,
                    tostring(parsed.pickMaxStock), tostring(parsed.objectiveFlag),
                    tostring(parsed.objectiveTarget))
            end
        end
    end
end

function CTLDZoneManager:_discoverLGZ()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then return end
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "LGZ_" then
            local parsed = self:_parseLGZ(name)
            if parsed and not self._logisticZones[parsed.name] then
                local zone = CTLDLogisticZone:new({
                    name      = parsed.name,
                    coalition = parsed.coalition,
                    center    = _buildCenter(zd),
                    radius    = ctld.gs("dynamicZoneRadius") or 200,
                    active    = true,
                })
                self._logisticZones[parsed.name] = zone
                ctld.utils.log("INFO", "CTLDZoneManager: LGZ '%s' coalition=%d",
                    parsed.name, parsed.coalition)
            end
        end
    end
end

-- ============================================================
-- Legacy fallback
-- ============================================================

function CTLDZoneManager:_loadLegacyZones()

    -- pickupZones → CTLDTroopZone (pickup only)
    for _, zd in pairs(ctld.gs("pickupZones") or {}) do
        local trig = trigger.misc.getZone(zd[1])
        if trig and not self._troopZones[zd[1]] then
            local smoke = -1
            if zd[2] then
                local n = tonumber(_LEGACY_SMOKE_STR[zd[2]] or zd[2])
                smoke = _TROOP_SMOKE_COLOR[n] or -1
            end
            local stock = (zd[3] == -1 or zd[3] == nil) and 0 or tonumber(zd[3])
            self._troopZones[zd[1]] = CTLDTroopZone:new({
                dcsName      = zd[1], zoneName = zd[1],
                coalition    = tonumber(zd[5]) or 0,
                center       = { x=trig.point.x, y=trig.point.y, z=trig.point.z },
                radius       = trig.radius,
                pickMaxStock = stock,
                smoke        = smoke,
                active       = (zd[4] == "yes" or zd[4] == 1),
            })
        end
    end

    -- dropOffZones → CTLDTroopZone (no pickup, no flag — RTB marker)
    for _, zd in pairs(ctld.gs("dropOffZones") or {}) do
        local trig = trigger.misc.getZone(zd[1])
        if trig and not self._troopZones[zd[1]] then
            local smoke = -1
            if zd[2] then
                local n = tonumber(_LEGACY_SMOKE_STR[zd[2]] or zd[2])
                smoke = _TROOP_SMOKE_COLOR[n] or -1
            end
            self._troopZones[zd[1]] = CTLDTroopZone:new({
                dcsName = zd[1], zoneName = zd[1],
                coalition = tonumber(zd[3]) or 0,
                center    = { x=trig.point.x, y=trig.point.y, z=trig.point.z },
                radius    = trig.radius,
                smoke     = smoke, active = true,
            })
        end
    end

    -- wpZones → CTLDTroopZone (waypoint marker)
    for _, zd in pairs(ctld.gs("wpZones") or {}) do
        local trig = trigger.misc.getZone(zd[1])
        if trig and not self._troopZones[zd[1]] then
            local smoke = -1
            if zd[2] then
                local n = tonumber(_LEGACY_SMOKE_STR[zd[2]] or zd[2])
                smoke = _TROOP_SMOKE_COLOR[n] or -1
            end
            self._troopZones[zd[1]] = CTLDTroopZone:new({
                dcsName = zd[1], zoneName = zd[1],
                coalition = tonumber(zd[4]) or 0,
                center    = { x=trig.point.x, y=trig.point.y, z=trig.point.z },
                radius    = trig.radius,
                smoke     = smoke,
                active    = (zd[3] == "yes" or zd[3] == 1),
            })
        end
    end

    -- logisticUnits → CTLDLogisticZone (dynamic, linked to unit/static)
    local maxDist = ctld.gs("maximumDistanceLogistic") or 500
    local added, removed = {}, {}
    for _, unitName in pairs(ctld.gs("logisticUnits") or {}) do
        if not self._logisticZones[unitName] then
            local obj = StaticObject.getByName(unitName) or Unit.getByName(unitName)
            if obj then
                local coal = obj:getCoalition()
                self._logisticZones[unitName] = CTLDLogisticZone:new({
                    name        = unitName,
                    coalition   = coal,
                    center      = obj:getPoint(),
                    radius      = maxDist,
                    linkedUnit  = obj,
                    active      = true,
                })
                added[#added + 1] = { unitName = unitName, coalition = coal }
                ctld.utils.log("INFO", "CTLDZoneManager: logistic unit '%s'", unitName)
            else
                ctld.utils.log("WARN",
                    "CTLDZoneManager: logisticUnits '%s' not found in mission", unitName)
            end
        end
    end
    if #added > 0 then
        self:_publishLogisticZoneUpdated(added, removed)
    end
end

-- ============================================================
-- Smoke scheduler
-- ============================================================

function CTLDZoneManager:_scheduleSmoke()
    local interval = ctld.gs("smokeRefreshInterval") or 300
    local self_ref = self

    local function refresh()
        if ctld.gs("disableAllSmoke") == true then
            timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
            return
        end

        local tZoneData, lZoneData = {}, {}

        -- Smoke troop zones
        for _, zone in pairs(self_ref._troopZones) do
            if zone.active and zone.smoke and zone.smoke >= 0 then
                trigger.action.smoke(zone.center, zone.smoke)
                tZoneData[#tZoneData + 1] = {
                    fullName        = zone.dcsName,
                    zoneName        = zone.zoneName,
                    coalition       = zone.coalition,
                    position        = zone.center,
                    radius          = zone.radius,
                    hasPickup       = zone:hasPickup(),
                    hasExtract      = zone:hasExtract(),
                    pickMaxStock    = zone.pickMaxStock,
                    pickCurrentStock= zone.pickCurrentStock,
                    objectiveFlag   = zone.objectiveFlag,
                    objectiveTarget = zone.objectiveTarget,
                    objectiveCurrent= zone.objectiveFlag
                                      and trigger.misc.getUserFlag(zone.objectiveFlag) or nil,
                    smokeColor      = zone.smoke,
                }
            end
        end

        -- Smoke logistic zones (optional per config)
        for _, zone in pairs(self_ref._logisticZones) do
            if zone.active then
                local smokeColors = ctld.gs("logisticZoneSmokeColor")
                local color = smokeColors and smokeColors[zone.coalition]
                if color then
                    trigger.action.smoke(zone:getCenter(), color)
                end
                lZoneData[#lZoneData + 1] = {
                    name       = zone.name,
                    coalition  = zone.coalition,
                    position   = zone:getCenter(),
                    radius     = zone.radius,
                    type       = zone:isDynamic() and "dynamic" or "static",
                    linkedUnit = zone._linkedUnit,
                    smokeColor = color,
                }
            end
        end

        EventDispatcher.getInstance():publish("OnZoneSmokeRefreshed", {
            troopZones    = tZoneData,
            logisticZones = lZoneData,
            timestamp     = timer.getAbsTime(),
            refreshInterval = interval,
        })

        timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
    end

    timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
end

-- ============================================================
-- Events
-- ============================================================

function CTLDZoneManager:_publishLogisticZoneUpdated(added, removed)
    local zones = {}
    for _, zone in pairs(self._logisticZones) do
        zones[#zones + 1] = {
            name       = zone.name,
            type       = "logistic",
            linkedUnit = zone._linkedUnit,
            position   = zone:getCenter(),
            coalition  = zone.coalition,
            radius     = zone.radius,
            services   = zone.services,
        }
    end
    EventDispatcher.getInstance():publish("OnLogisticZoneUpdated", {
        zones        = zones,
        unitsAdded   = added,
        unitsRemoved = removed,
        timestamp    = timer.getAbsTime(),
    })
end

--- S_EVENT_DEAD: remove dynamic logistic zones whose linked unit died.
function CTLDZoneManager:onDead(event)
    local unit = event.initiator
    if not unit then return end
    local unitName = unit:getName()
    local zone = self._logisticZones[unitName]
    if zone and zone:isDynamic() then
        self._logisticZones[unitName] = nil
        ctld.utils.log("INFO", "CTLDZoneManager: dynamic logistic zone '%s' removed (unit dead)", unitName)
        self:_publishLogisticZoneUpdated({}, { { unitName = unitName, coalition = zone.coalition, reason = "dead" } })
    end
end

-- ============================================================
-- Dynamic registration (FOB, external callers)
-- ============================================================

--- Register a deployed FOB as a logistic zone.
-- @param fobName   string
-- @param point     vec3
-- @param radius    number  (default 150)
-- @param coalitionId number
function CTLDZoneManager:registerFOBAsLogistic(fobName, point, radius, coalitionId)
    local zone = CTLDLogisticZone:new({
        name      = fobName,
        coalition = coalitionId or 0,
        center    = point,
        radius    = radius or 150,
        active    = true,
    })
    self._logisticZones[fobName] = zone
    ctld.utils.log("INFO", "CTLDZoneManager: FOB logistic zone '%s' r=%dm", fobName, radius or 150)
    self:_publishLogisticZoneUpdated({ { unitName = fobName, coalition = coalitionId } }, {})
end

--- Remove a logistic zone (e.g. FOB destroyed).
function CTLDZoneManager:unregisterLogistic(name)
    local zone = self._logisticZones[name]
    if zone then
        self._logisticZones[name] = nil
        ctld.utils.log("INFO", "CTLDZoneManager: logistic zone '%s' unregistered", name)
        self:_publishLogisticZoneUpdated({}, { { unitName = name, coalition = zone.coalition, reason = "removed" } })
    end
end

-- ============================================================
-- Query API — TroopZones
-- ============================================================

--- Return CTLDTroopZone by zoneName, or nil.
function CTLDZoneManager:getTroopZone(zoneName)
    return self._troopZones[zoneName]
end

--- Return all active troop zones matching coalition (0 = both).
-- @param coalition  number   coalition.side.*
-- @return table of CTLDTroopZone
function CTLDZoneManager:getTroopZonesForCoalition(coalition)
    local result = {}
    for _, zone in pairs(self._troopZones) do
        if zone.active and (zone.coalition == coalition or zone.coalition == 0) then
            result[#result + 1] = zone
        end
    end
    return result
end

--- Return the troop zone containing point, or nil.
-- @param point     vec3
-- @param coalition number  (0 = accept all)
-- @return CTLDTroopZone or nil
function CTLDZoneManager:getTroopZoneAtPoint(point, coalition)
    for _, zone in pairs(self._troopZones) do
        if zone.active and (coalition == 0 or zone.coalition == 0 or zone.coalition == coalition) then
            if zone:isInZone(point) then return zone end
        end
    end
    return nil
end

--- Return the troop zone containing unitName, or nil.
-- @param unitName  string
-- @return CTLDTroopZone or nil
function CTLDZoneManager:getTroopZoneForUnit(unitName)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then return nil end
    return self:getTroopZoneAtPoint(unit:getPoint(), unit:getCoalition())
end

-- ============================================================
-- Query API — LogisticZones
-- ============================================================

--- Return CTLDLogisticZone by name, or nil.
function CTLDZoneManager:getLogisticZone(name)
    return self._logisticZones[name]
end

--- Return all active logistic zones matching coalition.
function CTLDZoneManager:getLogisticZonesForCoalition(coalition)
    local result = {}
    for _, zone in pairs(self._logisticZones) do
        if zone.active and zone:isAlive()
           and (zone.coalition == coalition or zone.coalition == 0) then
            result[#result + 1] = zone
        end
    end
    return result
end

--- Return the logistic zone containing point, or nil.
-- @param point     vec3
-- @param coalition number
-- @return CTLDLogisticZone or nil
function CTLDZoneManager:getLogisticZoneAtPoint(point, coalition)
    for _, zone in pairs(self._logisticZones) do
        if zone.active and zone:isAlive()
           and (coalition == 0 or zone.coalition == 0 or zone.coalition == coalition) then
            if zone:isInZone(point) then return zone end
        end
    end
    return nil
end

--- Return the logistic zone containing unitName, or nil.
function CTLDZoneManager:getLogisticZoneForUnit(unitName)
    local unit = Unit.getByName(unitName) or StaticObject.getByName(unitName)
    if not unit or not unit:isExist() then return nil end
    return self:getLogisticZoneAtPoint(unit:getPoint(), unit:getCoalition())
end

-- ============================================================
-- Misc helpers
-- ============================================================

--- Activate / deactivate a troop zone.
function CTLDZoneManager:setTroopZoneActive(zoneName, active)
    local zone = self._troopZones[zoneName]
    if zone then
        if active then zone:activate() else zone:deactivate() end
    end
end

-- ============================================================
-- Zone name validation (developer tool — reports to DCS log + screen)
-- ============================================================

function CTLDZoneManager:_validateZoneNames()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then return end
    local errors = {}
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "TRZ_" then
            local parsed, err = self:_parseTRZ(name)
            if not parsed then
                errors[#errors + 1] = "  TRZ ERROR '" .. name .. "': " .. tostring(err)
            end
        elseif string.sub(name, 1, 4) == "LGZ_" then
            local parsed = self:_parseLGZ(name)
            if not parsed then
                errors[#errors + 1] = "  LGZ ERROR '" .. name .. "': parse failed"
            end
        end
    end
    if #errors > 0 then
        local report = "[CTLD] Zone validation — " .. #errors .. " issue(s):\n"
                    .. table.concat(errors, "\n")
        trigger.action.outText(report, 30)
        ctld.utils.log("WARN", report)
    else
        ctld.utils.log("INFO", "CTLDZoneManager: all zone names valid")
    end
end
