-- diag_vehicle_load_conditions.lua
-- Run this when heliai_vehicle is ON the AIZ_depot (just landed).
-- Shows exactly why findLoadableVehicles returns 0 vehicles.

local unitName = "heliai_vehicle"
local u = Unit.getByName(unitName)
if not u or not u:isExist() then
    return "ERROR: unit '" .. unitName .. "' not found or dead"
end

local tTypeName = u:getTypeName()
local tCoa      = u:getCoalition()
local tPos      = u:getPoint()
local caps      = (ctld.gs("capabilitiesByType") or {})[tTypeName]

local lines = {}
lines[#lines+1] = string.format("transport: %s | type=%s | coa=%d | canTransportWholeVehicle=%s",
    unitName, tostring(tTypeName), tCoa, tostring(caps and caps.canTransportWholeVehicle))
lines[#lines+1] = string.format("inTransportPilotNames=%s",
    tostring(ctld.gs("transportPilotNames") and ctld.gs("transportPilotNames")[unitName] or "NO"))

local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
lines[#lines+1] = "maxDist=" .. maxDist

local loadableBlue = caps and caps.loadableVehiclesBLUE or {}
lines[#lines+1] = "loadableVehiclesBLUE=" .. table.concat(loadableBlue, ",")

local ok, vs = pcall(CTLDVehicleSpawner.getInstance)
if not ok or not vs then
    return table.concat(lines, "\n") .. "\nERROR: CTLDVehicleSpawner not available"
end

local vCount = 0
for id, veh in pairs(vs._vehicles) do
    vCount = vCount + 1
    local dist = -1
    if veh.unit and veh.unit:isExist() then
        dist = ctld.utils.getDistance("diag", tPos, veh.unit:getPoint())
    end
    local typeOk = vs:_isTypeLoadable(veh.vehicleType, tTypeName, tCoa)
    local coaOk  = not (veh.spawnData and veh.spawnData.coalitionId ~= tCoa)
    lines[#lines+1] = string.format("  veh %s | type=%s | state=%s | coa_ok=%s | typeOk=%s | dist=%.0fm | unitExist=%s",
        tostring(id),
        tostring(veh.vehicleType),
        tostring(veh:getState()),
        tostring(coaOk),
        tostring(typeOk),
        dist,
        tostring(veh.unit and veh.unit:isExist() or false))
end
if vCount == 0 then
    lines[#lines+1] = "  (no vehicles registered in CTLDVehicleSpawner)"
end

-- Zone check
local zm = CTLDZoneManager.getInstance()
local zone = zm:getAIPickupZoneAt(tPos)
if zone then
    lines[#lines+1] = string.format("AIZ pickup zone at landing: %s | aiCargoType=%s | doVeh=%s",
        tostring(zone.zoneName), tostring(zone.aiCargoType),
        tostring(zone.aiCargoType == "V" or zone.aiCargoType == "TV"))
else
    lines[#lines+1] = "NO AIZ pickup zone detected at landing position"
end

return table.concat(lines, "\n")
