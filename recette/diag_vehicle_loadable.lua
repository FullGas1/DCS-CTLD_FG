-- Diagnostic findLoadableVehicles pour heliai_vehicle
local unit = Unit.getByName("heliai_vehicle")
if not unit then return "heliai_vehicle introuvable" end

local ok, vs = pcall(CTLDVehicleSpawner.getInstance)
if not ok then return "CTLDVehicleSpawner indisponible" end

local typeName = unit:getTypeName()
local caps = (ctld.gs("capabilitiesByType") or {})[typeName] or {}
local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200

local result = string.format("heli=%s caps.canTransportWholeVehicle=%s maxDist=%s | vehicles: ",
    typeName, tostring(caps.canTransportWholeVehicle), tostring(maxDist))

local details = {}
for id, veh in pairs(vs._vehicles) do
    local state = veh:getState()
    local dist = "?"
    if veh.unit and veh.unit:isExist() then
        dist = math.floor(ctld.utils.getDistance("diag", unit:getPoint(), veh.unit:getPoint()))
    end
    local typeOk = vs:_isTypeLoadable(veh.vehicleType, typeName, unit:getCoalition())
    details[#details+1] = string.format("id=%s type=%s state=%s dist=%sm typeOk=%s",
        tostring(id), tostring(veh.vehicleType), tostring(state), tostring(dist), tostring(typeOk))
end
if #details == 0 then return result .. "AUCUN" end
return result .. table.concat(details, " | ")
