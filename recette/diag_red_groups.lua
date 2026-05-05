-- recette/diag_red_groups.lua
-- List all RED groups by category, find BDK-775 and RECON_TEST_ship_1
local cats = {
    {Group.Category.GROUND,     "GROUND"},
    {Group.Category.AIRPLANE,   "AIRPLANE"},
    {Group.Category.HELICOPTER, "HELICOPTER"},
    {Group.Category.SHIP,       "SHIP"},
}
local found = {}
for _, entry in ipairs(cats) do
    local cat, catName = entry[1], entry[2]
    local grps = coalition.getGroups(coalition.side.RED, cat) or {}
    for _, g in ipairs(grps) do
        for _, u in ipairs(g:getUnits()) do
            local uName = u:getName()
            local uType = u:getTypeName()
            if uType == "BDK-775" or uName == "BDK-775" or uName == "RECON_TEST_ship_1" then
                found[#found+1] = string.format("[%s] group=%s unit=%s type=%s",
                    catName, g:getName(), uName, uType)
            end
        end
    end
end
if #found == 0 then
    ctld.logInfo("diag_red_groups: neither BDK-775 nor RECON_TEST_ship_1 found in any RED group?!")
else
    for _, f in ipairs(found) do ctld.logInfo("diag_red_groups: " .. f) end
end

-- Also check: what are the unitNames returned by _getEnemyUnitNames?
local rmgr = CTLDReconManager.getInstance()
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = players[1]
if pu then
    local names = rmgr:_getEnemyUnitNames(pu:getCoalition())
    ctld.logInfo(string.format("diag_red_groups: _getEnemyUnitNames returned %d names", #names))
    for _, n in ipairs(names) do
        local u = Unit.getByName(n)
        if u then
            local t = u:getTypeName()
            if t == "BDK-775" or t == "Speedboat" or n == "RECON_TEST_ship_1" then
                ctld.logInfo("  NOTABLE: " .. n .. " type=" .. t)
            end
        end
    end
end
trigger.action.outText("[DIAG] Check CTLD.log for group/unit details", 10)
return "DONE"
