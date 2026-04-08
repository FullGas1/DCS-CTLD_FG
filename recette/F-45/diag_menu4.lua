---@diagnostic disable
-- F-45 DIAG4: missionCommands via timer (1s delay)

trigger.action.outText("DIAG4: scheduling menu in 1s...", 10)

timer.scheduleFunction(function()
    pcall(function() missionCommands.removeItem({"DIAG Timer"}) end)
    local path = missionCommands.addSubMenu("DIAG Timer", nil)
    missionCommands.addCommand("DIAG Timer Cmd", {"DIAG Timer"}, function() env.info("[DIAG4] triggered") end, {})
    env.info("[DIAG4] addSubMenu returned: " .. tostring(path))
    trigger.action.outText("DIAG4: menu scheduled+created. Check \\ F10 NOW.", 40)
end, {}, timer.getTime() + 1)
