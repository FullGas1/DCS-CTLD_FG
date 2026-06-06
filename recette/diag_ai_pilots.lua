-- diag_ai_pilots.lua — vérifie transportPilotNames et état AI
local names = ctld.gs("transportPilotNames") or {}
local result = "transportPilotNames (" .. #names .. "): " .. table.concat(names, ", ")

local u = Unit.getByName("heliai_troops")
if u then
    result = result .. " | unit exists, inAir=" .. tostring(u:inAir())
    result = result .. " | playerName=" .. tostring(u:getPlayerName())
else
    result = result .. " | unit NOT found"
end

return result
