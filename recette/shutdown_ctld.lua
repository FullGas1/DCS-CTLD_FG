---@diagnostic disable
-- shutdown_ctld.lua
-- Cancel all CTLD long-running timer loops before re-injecting CTLD_Next.lua.
--
-- Usage (Witchcraft):
--   1. node bridge.js "recette/shutdown_ctld.lua"
--   2. node bridge.js "CTLD_Next.lua"
--   3. (wait 5s)
--   4. node bridge.js "recette/enable_debug.lua"
--   5. node bridge.js "recette/scenarios/your_scenario.lua"
--
-- This prevents zombie timer loops from accumulating across re-injections.
-- Safe to call even if ctld.scheduler is not yet initialised (guard below).

if ctld and ctld.scheduler then
    ctld.scheduler.cancelAll()
    trigger.action.outText("[CTLD] scheduler: all loops cancelled — safe to re-inject", 10)
    return "[CTLD] shutdown OK"
else
    return "[CTLD] shutdown: ctld.scheduler not found (CTLD not loaded?)"
end
