-- Dump all registered CTLDCrates with their DCS static existence status
local mgr   = CTLDCrateManager.getInstance()
local lines = {}
local count = 0
for name, crate in pairs(mgr.crates) do
    count = count + 1
    local state    = crate.state or "?"
    local hasStatic = crate.dcsStatic ~= nil
    local exists   = hasStatic and crate.dcsStatic:isExist() or false
    local staticByName = StaticObject.getByName(name)
    local existsByName = staticByName ~= nil and staticByName:isExist() or false
    table.insert(lines, string.format(
        "[CRATE] name=%s state=%s hasRef=%s isExist=%s getByName=%s",
        name, state, tostring(hasStatic), tostring(exists), tostring(existsByName)))
end
if count == 0 then
    ctld.utils.log("INFO", "[CRATE DIAG] No crates registered")
    trigger.action.outText("[CRATE DIAG] No crates registered", 10)
else
    for _, l in ipairs(lines) do ctld.utils.log("INFO", l) end
    trigger.action.outText(string.format("[CRATE DIAG] %d crate(s) - see CTLD.log", count), 10)
end
