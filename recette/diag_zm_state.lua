local zm = CTLDZoneManager.getInstance()
local result = {}
local count = 0
for k in pairs(zm._troopZones) do
    count = count + 1
    if string.find(k, "AIZ", 1, true) or string.find(k, "WPZ", 1, true) then
        table.insert(result, k)
    end
end
table.insert(result, "total_zones=" .. count)
table.sort(result)
return table.concat(result, " | ")
