local pm = CTLDPlayerManager.getInstance()
local result = {}
for unitName, p in pairs(pm._players) do
    table.insert(result, string.format("%s: canCarryVehicles=%s isTransport=%s",
        unitName, tostring(p.canCarryVehicles), tostring(p.isTransport)))
end
if #result == 0 then return "no players registered" end
return table.concat(result, " | ")
