-- Diagnostic: lister les zones DCS trigger du .miz contenant "AIZ" ou "aiz"
local found = {}
if env.mission and env.mission.triggers and env.mission.triggers.zones then
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.find(string.lower(name), "aiz", 1, true) then
            table.insert(found, name .. " r=" .. tostring(math.floor(zd.radius or 0)))
        end
    end
end
table.sort(found)
if #found == 0 then return "NO AIZ zones found in .miz" end
return table.concat(found, " | ")
