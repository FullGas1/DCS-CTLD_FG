-- patch_register_heliai_vehicle.lua
-- Enregistre heliai_vehicle dans transportPilotNames pour tester onAILand sans le scénario complet.
local names = ctld.gs("transportPilotNames")
if names then
    names["heliai_vehicle"] = true
else
    return "ERROR: transportPilotNames introuvable"
end

-- Vérifie aussi la zone AIZ
local zm = CTLDZoneManager.getInstance()
local found = {}
for name, z in pairs(zm._troopZones) do
    if z.isAIPickup then
        found[#found+1] = string.format("%s r=%.0f aiCargo=%s", name, z.radius or 0, tostring(z.aiCargoType))
    end
end

return "heliai_vehicle enregistré. AIZ pickup zones: " .. (next(found) and table.concat(found, " | ") or "AUCUNE")
