-- Vérifie le résultat du filtre poids après atterrissage
local u = Unit.getByName("heliai_vehicle")
if not u or not u:isExist() then return "heliai_vehicle introuvable" end

local ok, vs = pcall(CTLDVehicleSpawner.getInstance)
if not ok or not vs then return "CTLDVehicleSpawner indisponible" end

local loaded = vs:findLoadedVehicles(u)
local typeName = u:getTypeName()
local caps = (ctld.gs("capabilitiesByType") or {})[typeName] or {}
local weights = ctld.gs("groundVehicleWeights") or {}

local lines = {}
lines[#lines+1] = string.format("transport=%s maxVehicleWeight=%s", typeName, tostring(caps.maxVehicleWeight))
lines[#lines+1] = string.format("vehicles loaded on heli: %d", #loaded)
for _, v in ipairs(loaded) do
    lines[#lines+1] = "  LOADED: " .. tostring(v.vehicleType) .. " weight=" .. tostring(weights[v.vehicleType])
end
if #loaded == 0 then
    lines[#lines+1] = "  (none) — weight gate applied or no vehicle in range"
end
return table.concat(lines, "\n")
