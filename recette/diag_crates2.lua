-- Verify isOnGround result for each registered crate
local mgr   = CTLDCrateManager.getInstance()
local lines = {}
local count = 0
for name, crate in pairs(mgr.crates) do
    count = count + 1
    local state     = crate.state or "?"
    local exists    = crate.dcsStatic and crate.dcsStatic:isExist() or false
    local onGround  = crate:isOnGround()
    table.insert(lines, string.format(
        "[CRATE2] name=%s state=%s isExist=%s isOnGround=%s",
        name, state, tostring(exists), tostring(onGround)))
end
if count == 0 then
    ctld.utils.log("INFO", "[CRATE2 DIAG] No crates registered")
else
    for _, l in ipairs(lines) do ctld.utils.log("INFO", l) end
end
trigger.action.outText(string.format("[CRATE2 DIAG] %d crate(s) - see CTLD.log", count), 10)
