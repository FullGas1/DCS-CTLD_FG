---@diagnostic disable
-- F-45 DIAG2: log return values of missionCommands calls

local players = coalition.getPlayers(coalition.side.BLUE) or {}
local unit = players[1]
if not unit then
    trigger.action.outText("DIAG2 SKIP: no BLUE player", 10)
    return
end

local groupId = unit:getGroup():getID()
env.info("[DIAG2] groupId=" .. tostring(groupId) .. " type=" .. type(groupId))

-- Check if removeItem works (clears any stale entries)
pcall(function() missionCommands.removeItemForGroup(groupId, {"DIAG Root"}) end)

local path = missionCommands.addSubMenuForGroup(groupId, "DIAG Root", nil)
env.info("[DIAG2] addSubMenuForGroup returned: " .. tostring(path))

local cmd = missionCommands.addCommandForGroup(groupId, "DIAG Cmd", {"DIAG Root"}, function() env.info("[DIAG2] cmd triggered") end, {})
env.info("[DIAG2] addCommandForGroup returned: " .. tostring(cmd))

-- Show results on screen
local pathStr = type(path) == "table" and table.concat(path, "/") or tostring(path)
trigger.action.outText("DIAG2: groupId=" .. tostring(groupId) .. "\npath=" .. pathStr .. "\nCheck \\ F10 for 'DIAG Root'", 40)
