-- Check CTLDDCSEventBridge has S_EVENT_LAND handler registered for CTLDCoreManager:onAILand
local bridge = CTLDDCSEventBridge.getInstance()
local result = {}

local landId = world.event.S_EVENT_LAND
local handlers = bridge._handlers[landId] or {}
table.insert(result, "S_EVENT_LAND handlers=" .. #handlers)
for i, h in ipairs(handlers) do
    local tname = type(h.target) == "table" and (tostring(h.target) or "?") or tostring(h.target)
    table.insert(result, i .. ": method=" .. tostring(h.method) .. " target=" .. tname)
end

-- Also verify unit is in air or on ground
local u = Unit.getByName("heliai_mt10a")
if u and u:isExist() then
    table.insert(result, "unit_inAir=" .. tostring(u:inAir()))
end

return table.concat(result, " | ")
