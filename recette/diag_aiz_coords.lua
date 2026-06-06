local zm = CTLDZoneManager.getInstance()
local result = {}
for name, z in pairs(zm._troopZones) do
    if z.isAIPickup or z.isAIDropoff then
        local c = z.center or {}
        result[#result+1] = string.format("%s | cargo=%s | r=%.0fm | x=%.0f z=%.0f",
            name, tostring(z.aiCargoType), z.radius or 0,
            c.x or 0, c.z or 0)
    end
end
table.sort(result)
return table.concat(result, "\n")
