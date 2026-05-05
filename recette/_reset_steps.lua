---@diagnostic disable
-- Reset all Witchcraft scenario step counters (_G["_..._STEP"] globals).
-- Inject this when a scenario has crashed mid-run and needs a clean restart.
-- Does NOT reset DCS state (groups, statics, etc.) — only the Lua step counters.

local cleared = {}
for k in pairs(_G) do
    if type(k) == "string" and string.match(k, "^_.*_STEP$") then
        _G[k] = nil
        cleared[#cleared + 1] = k
    end
end

local msg = "[RESET_STEPS] Cleared " .. #cleared .. " step counter(s)"
if #cleared > 0 then
    msg = msg .. ": " .. table.concat(cleared, ", ")
end
trigger.action.outText(msg, 30)
env.info(msg)
return msg
