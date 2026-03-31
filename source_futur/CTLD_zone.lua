-- ============================================================
-- CTLD_zone.lua
-- CTLDTroopZone entity + CTLDZoneManager singleton
--
-- Dependencies : CTLDConfig (ctld.gs), CTLDUtils
--
-- Zone naming convention (EVO-10):
--   Separator : "_"  (forbidden inside any field value)
--   PKZ_name_smoke_limit_active_side   pickup zone  (troops only)
--   DOZ_name_smoke_side                drop-off zone
--   WPZ_name_smoke_active_side         waypoint zone
--   EXZ_name_smoke                     extract zone  (flag = NAME_FLG)
--   LGZ_name_side                      logistic zone
--
--   smoke  : -1(none) 0(green) 1(red) 2(white) 3(orange) 4(blue)
--   limit  : -1(unlimited) or integer >= 1        [PKZ only]
--   active : 0 | 1                                [PKZ, WPZ]
--   side   : 0(both) | 1(red) | 2(blue)
--
-- Legacy fallback: zones whose names do not match any prefix
-- are loaded from ctld.gs("pickupZones") / dropOffZones /
-- wpZones / logisticUnits config tables.
--
-- EVO-09 : pickupZones handle troops only (no vehicle loading).
-- EVO-11a: logistic zones are DCS trigger zones, no static anchor.
-- EVO-11b: unpack is allowed everywhere, including logistic zones.
-- EVO-12 : if ctld.gs("debug")==true, logs are mirrored to
--          ctld.gs("ctldLogPath").."CTLD.log"
-- ============================================================

-- ============================================================
-- Module-level logging (available before any instance)
-- ============================================================

-- Logger: delegated to ctld.utils (shared across all CTLD modules).
-- ctld.utils.initLog() is called once in CTLDZoneManager:init().
local _ctldLog = ctld.utils.log

-- ============================================================
-- CTLDTroopZone
-- ============================================================

CTLDTroopZone = {}
CTLDTroopZone.__index = CTLDTroopZone

--- Constructor.
-- @param data table with fields:
--   dcsName, zoneName, zoneType, coalition, center (vec3),
--   radius, verticies (nil=circular), active, smoke, limit, flagName
function CTLDTroopZone:new(data)
    local o = setmetatable({}, CTLDTroopZone)
    o.dcsName   = data.dcsName
    o.zoneName  = data.zoneName
    o.zoneType  = data.zoneType   -- "pickup"|"drop"|"waypoint"|"extract"|"logistic"
    o.coalition = data.coalition  -- 0=both 1=red 2=blue
    o.center    = data.center     -- vec3 {x,y,z}
    o.radius    = data.radius     -- number, circular zones
    o.verticies = data.verticies  -- table|nil, polygonal zones (mission coords)
    o.active    = data.active     -- bool
    o.smoke     = data.smoke      -- trigger.smokeColor.* or -1
    o.limit     = data.limit      -- number, -1=unlimited (PKZ)
    o.flagName  = data.flagName   -- string (EXZ) or nil
    return o
end

--- Returns true if point is inside the zone.
-- Circular : distance <= radius.
-- Polygonal : Jordan ray-casting on verticies.
function CTLDTroopZone:isInZone(point)
    if self.verticies and #self.verticies >= 3 then
        return CTLDTroopZone._raycast(point, self.verticies)
    end
    return CTLDUtils.getDistance(point, self.center) <= self.radius
end

--- Ray-casting (Jordan curve theorem) for polygonal zones.
-- verticies[i].x / .y are mission-file coordinates (mission Y = world Z).
function CTLDTroopZone._raycast(point, verts)
    local px, pz = point.x, point.z
    local inside = false
    local n = #verts
    local j = n
    for i = 1, n do
        local xi = verts[i].x
        local zi = verts[i].y  -- mission Y = world Z
        local xj = verts[j].x
        local zj = verts[j].y
        if ((zi > pz) ~= (zj > pz)) and
           (px < (xj - xi) * (pz - zi) / (zj - zi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

function CTLDTroopZone:getCenter()
    return self.center
end

function CTLDTroopZone:activate()
    self.active = true
end

function CTLDTroopZone:deactivate()
    self.active = false
end

-- ============================================================
-- CTLDZoneManager
-- ============================================================

CTLDZoneManager = {}
CTLDZoneManager.__index = CTLDZoneManager

local _zmInstance = nil

--- Zone type string constants.
CTLDZoneManager.TYPE = {
    PICKUP   = "pickup",
    DROP     = "drop",
    WAYPOINT = "waypoint",
    EXTRACT  = "extract",
    LOGISTIC = "logistic",
}

-- DCS name prefix → zone type
local _PREFIX_MAP = {
    PKZ = "pickup",
    DOZ = "drop",
    WPZ = "waypoint",
    EXZ = "extract",
    LGZ = "logistic",
}

-- Schema per prefix: total field count + ordered field names
local _SCHEMA = {
    PKZ = { count = 6, fields = { "prefix","name","smoke","limit","active","side" } },
    DOZ = { count = 4, fields = { "prefix","name","smoke","side" } },
    WPZ = { count = 5, fields = { "prefix","name","smoke","active","side" } },
    EXZ = { count = 3, fields = { "prefix","name","smoke" } },
    LGZ = { count = 3, fields = { "prefix","name","side" } },
}

local _SMOKE_COLOR = {
    [0] = trigger.smokeColor.Green,
    [1] = trigger.smokeColor.Red,
    [2] = trigger.smokeColor.White,
    [3] = trigger.smokeColor.Orange,
    [4] = trigger.smokeColor.Blue,
}

local _SMOKE_STRING = {
    green="0", red="1", white="2", orange="3", blue="4"
}

function CTLDZoneManager.getInstance()
    if _zmInstance == nil then
        _zmInstance = setmetatable({}, CTLDZoneManager)
        _zmInstance._zones = {}
        for _, t in pairs(CTLDZoneManager.TYPE) do
            _zmInstance._zones[t] = {}
        end
    end
    return _zmInstance
end

-- ============================================================
-- Helpers
-- ============================================================

local function _splitByUnderscore(str)
    local parts = {}
    for p in string.gmatch(str, "[^_]+") do
        table.insert(parts, p)
    end
    return parts
end

local function _parseSmoke(raw)
    local v = tonumber(raw)
    if v == nil then return -1 end
    return _SMOKE_COLOR[v] or -1
end

local function _buildCenter(zd)
    local x = zd.x
    local z = zd.y  -- mission Y = world Z
    local y = land.getHeight({ x = x, y = z })
    return { x = x, y = y, z = z }
end

-- ============================================================
-- Validation
-- ============================================================

--- Scans env.mission.triggers.zones, validates structured names,
-- emits a single merged report via trigger.action.outText and DCS log.
function CTLDZoneManager:validateZoneNames()
    local errors = {}
    local namesByPrefix = {}
    for prefix in pairs(_PREFIX_MAP) do
        namesByPrefix[prefix] = {}
    end

    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then
        _ctldLog("WARN", "validateZoneNames: env.mission.triggers.zones not accessible")
        return
    end

    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        local prefix = string.match(name, "^(%u+)_")
        if prefix and _PREFIX_MAP[prefix] then
            local schema = _SCHEMA[prefix]
            local parts  = _splitByUnderscore(name)

            -- field count
            if #parts ~= schema.count then
                table.insert(errors, string.format(
                    "  ERROR %-40s expected %d fields (%s), got %d",
                    name, schema.count, table.concat(schema.fields, "_"), #parts))
            else
                local parsed = {}
                for i, field in ipairs(schema.fields) do
                    parsed[field] = parts[i]
                end

                -- smoke
                if parsed.smoke then
                    local v = tonumber(parsed.smoke)
                    if v == nil or v < -1 or v > 4 then
                        table.insert(errors, string.format(
                            "  ERROR %-40s 'smoke' must be -1..4, got '%s'", name, parsed.smoke))
                    end
                end
                -- limit (PKZ)
                if parsed.limit then
                    local v = tonumber(parsed.limit)
                    if v == nil or (v ~= -1 and v < 1) then
                        table.insert(errors, string.format(
                            "  ERROR %-40s 'limit' must be -1 or >=1, got '%s'", name, parsed.limit))
                    end
                end
                -- active (PKZ, WPZ)
                if parsed.active then
                    if parsed.active ~= "0" and parsed.active ~= "1" then
                        table.insert(errors, string.format(
                            "  ERROR %-40s 'active' must be 0 or 1, got '%s'", name, parsed.active))
                    end
                end
                -- side
                if parsed.side then
                    if parsed.side ~= "0" and parsed.side ~= "1" and parsed.side ~= "2" then
                        table.insert(errors, string.format(
                            "  ERROR %-40s 'side' must be 0, 1 or 2, got '%s'", name, parsed.side))
                    end
                end
                -- uniqueness of zoneName within prefix
                local zoneName = parsed.name
                if zoneName then
                    if namesByPrefix[prefix][zoneName] then
                        local hint = (prefix == "EXZ")
                            and string.format(" (flag conflict: %s_FLG)", string.upper(zoneName))
                            or ""
                        table.insert(errors, string.format(
                            "  ERROR %-40s duplicate name '%s' for prefix %s%s",
                            name, zoneName, prefix, hint))
                    else
                        namesByPrefix[prefix][zoneName] = name
                    end
                end
            end
        end
    end

    if #errors > 0 then
        local report = "[CTLD] Zone name validation report — " .. #errors .. " issue(s):\n"
                     .. table.concat(errors, "\n")
        trigger.action.outText(report, 30)
        _ctldLog("WARN", report)
    else
        _ctldLog("INFO", "validateZoneNames: all structured zone names OK")
    end
end

-- ============================================================
-- Discovery (structured names)
-- ============================================================

--- Scans env.mission.triggers.zones and registers all zones
-- whose names match a known prefix schema.
function CTLDZoneManager:discoverZones()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then
        _ctldLog("WARN", "discoverZones: env.mission.triggers.zones not accessible")
        return
    end

    for _, zd in pairs(env.mission.triggers.zones) do
        local name   = zd.name or ""
        local prefix = string.match(name, "^(%u+)_")
        if prefix and _PREFIX_MAP[prefix] then
            local schema = _SCHEMA[prefix]
            local parts  = _splitByUnderscore(name)
            if #parts == schema.count then
                local parsed = {}
                for i, field in ipairs(schema.fields) do
                    parsed[field] = parts[i]
                end

                local zoneType  = _PREFIX_MAP[prefix]
                local center    = _buildCenter(zd)
                local coalition = tonumber(parsed.side or "0") or 0
                local active    = (parsed.active == nil or parsed.active == "1")
                local smoke     = _parseSmoke(parsed.smoke or "-1")
                local limit     = tonumber(parsed.limit or "-1") or -1
                local flagName  = (zoneType == "extract")
                                  and (string.upper(parsed.name) .. "_FLG")
                                  or nil

                local zone = CTLDTroopZone:new({
                    dcsName   = name,
                    zoneName  = parsed.name,
                    zoneType  = zoneType,
                    coalition = coalition,
                    center    = center,
                    radius    = zd.radius or 0,
                    verticies = zd.verticies or nil,
                    active    = active,
                    smoke     = smoke,
                    limit     = limit,
                    flagName  = flagName,
                })

                self._zones[zoneType][parsed.name] = zone

                -- Initialise EXZ flag in DCS
                if zoneType == "extract" and flagName then
                    trigger.action.setUserFlag(flagName, 0)
                end

                -- Start smoke scheduler if needed
                if smoke >= 0 then
                    self:_scheduleSmoke(zone)
                end

                _ctldLog("INFO", "discoverZones: [%s] '%s' coalition=%d active=%s",
                    prefix, parsed.name, coalition, tostring(active))
            end
        end
    end
end

-- ============================================================
-- Legacy fallback
-- ============================================================

local function _legacySmoke(raw)
    local n = tonumber(_SMOKE_STRING[raw] or "-1") or -1
    return _SMOKE_COLOR[n] or -1
end

--- Loads zones from legacy config tables for missions that do not
-- use the structured naming convention. Zones already registered
-- by discoverZones() are not overwritten.
function CTLDZoneManager:_loadLegacyZones()

    -- pickupZones
    local pickupZones = ctld.gs("pickupZones") or {}
    for _, zd in pairs(pickupZones) do
        local trigZone = trigger.misc.getZone(zd[1])
        if trigZone and not self._zones["pickup"][zd[1]] then
            local zone = CTLDTroopZone:new({
                dcsName   = zd[1], zoneName  = zd[1], zoneType  = "pickup",
                coalition = zd[5] or 0,
                center    = { x=trigZone.point.x, y=trigZone.point.y, z=trigZone.point.z },
                radius    = trigZone.radius, verticies = nil,
                active    = (zd[4] == "yes" or zd[4] == 1),
                smoke     = _legacySmoke(zd[2]), limit = zd[3] or -1, flagName = nil,
            })
            self._zones["pickup"][zd[1]] = zone
            _ctldLog("INFO", "_loadLegacyZones: pickup '%s'", zd[1])
        end
    end

    -- dropOffZones
    local dropOffZones = ctld.gs("dropOffZones") or {}
    for _, zd in pairs(dropOffZones) do
        local trigZone = trigger.misc.getZone(zd[1])
        if trigZone and not self._zones["drop"][zd[1]] then
            local zone = CTLDTroopZone:new({
                dcsName=zd[1], zoneName=zd[1], zoneType="drop",
                coalition=zd[3] or 0,
                center={x=trigZone.point.x, y=trigZone.point.y, z=trigZone.point.z},
                radius=trigZone.radius, verticies=nil,
                active=true, smoke=_legacySmoke(zd[2]), limit=-1, flagName=nil,
            })
            self._zones["drop"][zd[1]] = zone
            _ctldLog("INFO", "_loadLegacyZones: drop '%s'", zd[1])
        end
    end

    -- wpZones
    local wpZones = ctld.gs("wpZones") or {}
    for _, zd in pairs(wpZones) do
        local trigZone = trigger.misc.getZone(zd[1])
        if trigZone and not self._zones["waypoint"][zd[1]] then
            local zone = CTLDTroopZone:new({
                dcsName=zd[1], zoneName=zd[1], zoneType="waypoint",
                coalition=zd[4] or 0,
                center={x=trigZone.point.x, y=trigZone.point.y, z=trigZone.point.z},
                radius=trigZone.radius, verticies=nil,
                active=(zd[3]=="yes" or zd[3]==1),
                smoke=_legacySmoke(zd[2]), limit=-1, flagName=nil,
            })
            self._zones["waypoint"][zd[1]] = zone
            _ctldLog("INFO", "_loadLegacyZones: waypoint '%s'", zd[1])
        end
    end

    -- logisticUnits (unit/static name based)
    local logisticUnits = ctld.gs("logisticUnits") or {}
    local maxDist = ctld.gs("maximumDistanceLogistic") or 500
    for _, unitName in pairs(logisticUnits) do
        if not self._zones["logistic"][unitName] then
            local obj = StaticObject.getByName(unitName) or Unit.getByName(unitName)
            if obj then
                local zone = CTLDTroopZone:new({
                    dcsName=unitName, zoneName=unitName, zoneType="logistic",
                    coalition=obj:getCoalition(),
                    center=obj:getPoint(),
                    radius=maxDist, verticies=nil,
                    active=true, smoke=-1, limit=-1, flagName=nil,
                })
                self._zones["logistic"][unitName] = zone
                _ctldLog("INFO", "_loadLegacyZones: logistic unit '%s'", unitName)
            end
        end
    end
end

-- ============================================================
-- Smoke scheduler
-- ============================================================

function CTLDZoneManager:_scheduleSmoke(zone)
    local zoneType = zone.zoneType
    local zoneName = zone.zoneName

    local function refresh()
        local z = self._zones[zoneType] and self._zones[zoneType][zoneName]
        if z == nil then return end  -- zone removed → stop scheduler
        if z.active and ctld.gs("disableAllSmoke") ~= true and z.smoke >= 0 then
            trigger.action.smoke(z.center, z.smoke)
        end
        timer.scheduleFunction(refresh, nil, timer.getTime() + 300)
    end

    refresh()
end

-- ============================================================
-- FOB dynamic registration
-- ============================================================

--- Called when a FOB is deployed. Registers it as a logistic zone.
function CTLDZoneManager:registerFOBAsLogistic(fobName, point, radius, coalition)
    local zone = CTLDTroopZone:new({
        dcsName   = fobName,
        zoneName  = fobName,
        zoneType  = "logistic",
        coalition = coalition,
        center    = point,
        radius    = radius or 150,
        verticies = nil,
        active    = true,
        smoke     = -1,
        limit     = -1,
        flagName  = nil,
    })
    self._zones["logistic"][fobName] = zone
    _ctldLog("INFO", "registerFOBAsLogistic: '%s' r=%dm", fobName, radius or 150)
end

--- Removes a runtime logistic zone (e.g. FOB destroyed).
function CTLDZoneManager:unregisterLogistic(zoneName)
    if self._zones["logistic"][zoneName] then
        self._zones["logistic"][zoneName] = nil
        _ctldLog("INFO", "unregisterLogistic: '%s'", zoneName)
    end
end

-- ============================================================
-- Query API
-- ============================================================

--- Returns all active zones of given type matching coalition.
function CTLDZoneManager:getZonesForCoalition(coalition, zoneType)
    local result = {}
    local pool = zoneType and { self._zones[zoneType] } or self._zones
    if zoneType then pool = { self._zones[zoneType] } end
    for _, zones in pairs(pool) do
        for _, zone in pairs(zones or {}) do
            if zone.active and (zone.coalition == coalition or zone.coalition == 0) then
                table.insert(result, zone)
            end
        end
    end
    return result
end

--- Returns zone by zoneName. Optionally filtered by zoneType.
function CTLDZoneManager:getZoneByName(zoneName, zoneType)
    if zoneType then
        return self._zones[zoneType] and self._zones[zoneType][zoneName]
    end
    for _, zones in pairs(self._zones) do
        if zones[zoneName] then return zones[zoneName] end
    end
    return nil
end

--- Returns the nearest active zone of given type for the coalition.
function CTLDZoneManager:getNearestZone(point, coalition, zoneType)
    local nearest, nearestDist = nil, math.huge
    local pool = self._zones[zoneType] or {}
    for _, zone in pairs(pool) do
        if zone.active and (zone.coalition == coalition or zone.coalition == 0) then
            local d = CTLDUtils.getDistance(point, zone.center)
            if d < nearestDist then
                nearest, nearestDist = zone, d
            end
        end
    end
    return nearest
end

--- Returns the zone containing the unit, or nil. Optionally filtered by zoneType.
function CTLDZoneManager:isUnitInZone(unitName, zoneType)
    local unit = Unit.getByName(unitName) or StaticObject.getByName(unitName)
    if not unit then return nil end
    local point     = unit:getPoint()
    local coalition = unit:getCoalition()
    local pool = zoneType and (self._zones[zoneType] or {}) or {}
    if not zoneType then
        for _, zones in pairs(self._zones) do
            for k, z in pairs(zones) do pool[k] = z end
        end
    end
    for _, zone in pairs(pool) do
        if zone.active and (zone.coalition == coalition or zone.coalition == 0) then
            if zone:isInZone(point) then return zone end
        end
    end
    return nil
end

--- Increments or decrements the pickup zone group counter.
function CTLDZoneManager:updateZoneCounter(zoneName, diff)
    local zone = self._zones["pickup"] and self._zones["pickup"][zoneName]
    if zone and zone.limit ~= nil then
        zone.limit = math.max(0, zone.limit + diff)
    end
end

--- Activate / deactivate a zone by name.
function CTLDZoneManager:setZoneActive(zoneName, zoneType, active)
    local zone = self:getZoneByName(zoneName, zoneType)
    if zone then
        if active then zone:activate() else zone:deactivate() end
    end
end

-- ============================================================
-- Counting helper
-- ============================================================

function CTLDZoneManager:_count(zoneType)
    local n = 0
    for _ in pairs(self._zones[zoneType] or {}) do n = n + 1 end
    return n
end

-- ============================================================
-- Init
-- ============================================================

function CTLDZoneManager:init()
    ctld.utils.initLog()
    self:validateZoneNames()
    self:discoverZones()
    self:_loadLegacyZones()
    _ctldLog("INFO",
        "CTLDZoneManager ready — pickup:%d drop:%d waypoint:%d extract:%d logistic:%d",
        self:_count("pickup"), self:_count("drop"), self:_count("waypoint"),
        self:_count("extract"), self:_count("logistic"))
end
