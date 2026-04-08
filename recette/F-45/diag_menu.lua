---@diagnostic disable
-- F-45 DIAG: Test missionCommands direct call
-- Bypasses all CTLD code to isolate if DCS accepts the call

local players = coalition.getPlayers(coalition.side.BLUE) or {}
local unit = players[1]
if not unit then
    trigger.action.outText("DIAG SKIP: no BLUE player", 10)
    return
end

local groupId = unit:getGroup():getID()
local unitName = unit:getName()

env.info("[DIAG] unit=" .. unitName .. " groupId=" .. tostring(groupId))
env.info("[DIAG] missionCommands type=" .. type(missionCommands))
env.info("[DIAG] addSubMenuForGroup type=" .. type(missionCommands.addSubMenuForGroup))

-- Direct call, no wrapper
local ok, err = pcall(function()
    missionCommands.addSubMenuForGroup(groupId, "DIAG Root", nil)
    missionCommands.addCommandForGroup(groupId, "DIAG Item 1", {"DIAG Root"}, function() end, {})
    missionCommands.addCommandForGroup(groupId, "DIAG Item 2", {"DIAG Root"}, function() end, {})
end)

if ok then
    trigger.action.outText("DIAG OK: groupId=" .. tostring(groupId) .. " unit=" .. unitName .. "\nCheck * menu for 'DIAG Root'", 30)
    env.info("[DIAG] missionCommands calls succeeded")
else
    trigger.action.outText("DIAG ERROR: " .. tostring(err), 30)
    env.info("[DIAG] ERROR: " .. tostring(err))
end
