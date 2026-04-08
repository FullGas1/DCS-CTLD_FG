---@diagnostic disable
-- F-45 DIAG3: global menu (no groupId) — appears for ALL players

pcall(function() missionCommands.removeItem({"DIAG Global"}) end)

local path = missionCommands.addSubMenu("DIAG Global", nil)
missionCommands.addCommand("DIAG Global Cmd", {"DIAG Global"}, function() env.info("[DIAG3] triggered") end, {})

env.info("[DIAG3] global addSubMenu returned: " .. tostring(path))
trigger.action.outText("DIAG3: global menu created.\nCheck \\ F10 for 'DIAG Global'", 40)
