---@diagnostic disable
local jtacMgr = CTLDJTACManager and CTLDJTACManager.get() or nil
if not jtacMgr then return "no jtacMgr" end
local lines = {}
local n = 0
for k, v in pairs(jtacMgr.jtacs) do
    n = n + 1
    local t = type(v)
    local hasSL = (t == "table") and (type(v.stopLase) == "function") and "YES" or "NO"
    local mt = getmetatable(v)
    local mtname = mt and tostring(mt) or "nil"
    lines[n] = string.format("key='%s' type=%s stopLase=%s mt=%s", tostring(k), t, hasSL, mtname)
end
local msg = "jtacMgr.jtacs count=" .. n
for _, l in ipairs(lines) do msg = msg .. "\n  " .. l end
trigger.action.outText(msg, 60)
env.info(msg)
return msg
