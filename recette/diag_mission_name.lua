-- Diagnostic: inventaire complet zones + groupes utiles pour MT-07 à MT-10
local result = {}

-- Zones trigger contenant AIZ, WPZ
local zones = {}
if env.mission and env.mission.triggers and env.mission.triggers.zones then
    for _, zd in pairs(env.mission.triggers.zones) do
        local n = zd.name or ""
        if string.find(string.lower(n), "aiz", 1, true)
        or string.find(string.lower(n), "wpz", 1, true) then
            table.insert(zones, n .. "(r=" .. tostring(math.floor(zd.radius or 0)) .. ")")
        end
    end
end
table.sort(zones)
table.insert(result, "ZONES: " .. (#zones > 0 and table.concat(zones, " | ") or "NONE"))

-- Groupes commençant par "heliai" ou contenant "mt10" ou "enemy"
local grpNames = {}
for _, coa in ipairs({1, 2}) do
    local grps = coalition.getGroups(coa) or {}
    for _, g in ipairs(grps) do
        local n = g:getName()
        if string.find(string.lower(n), "heliai", 1, true)
        or string.find(string.lower(n), "mt10", 1, true)
        or string.find(string.lower(n), "enemy", 1, true)
        or string.find(string.lower(n), "hummer", 1, true)
        or string.find(string.lower(n), "veh", 1, true) then
            table.insert(grpNames, n)
        end
    end
end
table.sort(grpNames)
table.insert(result, "GROUPS: " .. (#grpNames > 0 and table.concat(grpNames, " | ") or "NONE"))

return table.concat(result, "\n")
