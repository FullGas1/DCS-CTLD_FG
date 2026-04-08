---@diagnostic disable
-- F-45 : Build + refresh() visible dans F10 DCS — FOB absent (disabled)
-- REQUIRES: DCS mission running, group "h1-1" must exist
trigger.action.outText("F-45: Build menu + refresh() — check F10 manually", 10)

local unit = Unit.getByName("h1-1")
if not unit then
    trigger.action.outText("F-45 SKIP: unit 'h1-1' not found", 10)
    env.info("[F-45] SKIP: h1-1 not found")
    return
end
local groupId = unit:getGroup():getID()
local mgr     = ctld.MenuManager:getInstance()
local menu    = mgr:createMenuForGroup(groupId)

menu:addSubMenu({}, "CTLD Commands", { order=100 })
menu:addSubMenu({"CTLD Commands"}, "Troops",        { order=10 })
menu:addSubMenu({"CTLD Commands"}, "Crates",        { order=20 })
menu:addSubMenu({"CTLD Commands"}, "Pack Vehicles", { order=30 })
menu:addSubMenu({"CTLD Commands"}, "FOB",           { order=40, enabled=false })
menu:refresh()

trigger.action.outText(
    "F-45 VISUAL CHECK:\nF10 → CTLD Commands must show:\n  Troops / Crates / Pack Vehicles\n  FOB must NOT appear.", 20)
env.info("[F-45] Menu built. Awaiting visual confirmation.")
