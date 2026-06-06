local zm = CTLDZoneManager.getInstance()
local results = {}
for k, z in pairs(zm._troopZones) do
    if z.isAIPickup then
        table.insert(results, string.format("'%s' maxStock=%s curStock=%s cargoType=%s",
            k, tostring(z.pickMaxStock), tostring(z.pickCurrentStock), tostring(z.aiCargoType)))
    end
end
return #results > 0 and table.concat(results, " | ") or "no AIPickup zones"
