---@diagnostic disable
-- F-46 : Double refresh() idempotent — menu looks identical after second refresh
-- REQUIRES: F-45 executed first (menu already built for h1-1)
trigger.action.outText("F-46: Double refresh() idempotent", 10)

local unit = Unit.getByName("h1-1")
if not unit then
    trigger.action.outText("F-46 SKIP: unit 'h1-1' not found", 10)
    env.info("[F-46] SKIP: h1-1 not found")
    return
end
local groupId = unit:getGroup():getID()
local menu    = ctld.MenuManager:getInstance():getMenuByGroupId(groupId)
if not menu then
    trigger.action.outText("F-46 SKIP: no menu for h1-1 — run F-45 first", 10)
    env.info("[F-46] SKIP: no menu found, run F-45 first")
    return
end

menu:refresh()
trigger.action.outText("F-46 VISUAL CHECK:\nSecond refresh() done.\nMenu must look identical to F-45.", 15)
env.info("[F-46] Second refresh complete. Awaiting visual confirmation.")
