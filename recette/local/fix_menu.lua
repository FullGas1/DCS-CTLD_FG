-- recette/fix_menu.lua — diagnose and force menu rebuild for BLUE player
local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "ABORT: no BLUE player" end
local pn = u:getName()
local gid = u:getGroup():getID()

ctld.logInfo("[fix_menu] player=%s  group=%d", pn, gid)

-- Kill any broken autorefresh
local rmgr = CTLDReconManager.getInstance()
local s = rmgr._activeScans[pn]
if s then
    if s.refreshTimer then pcall(timer.removeFunction, s.refreshTimer) end
    rmgr._activeScans[pn] = nil
    ctld.logInfo("[fix_menu] killed broken scan")
end

-- Check MenuManager
local mmgr = ctld.MenuManager:getInstance()
local menu  = mmgr and mmgr:getMenuByUnitName(pn)
ctld.logInfo("[fix_menu] MenuManager=%s  menu=%s", tostring(mmgr ~= nil), tostring(menu ~= nil))

if menu then
    local ok, err = pcall(function() menu:refresh() end)
    ctld.logInfo("[fix_menu] menu:refresh ok=%s err=%s", tostring(ok), tostring(err))
    return "menu refresh: " .. tostring(ok)
end

-- No menu found — try to rebuild it via CTLDCoreManager
local core = CTLDCoreManager and CTLDCoreManager.getInstance and CTLDCoreManager.getInstance()
if core then
    local ok2, err2 = pcall(function() core:buildMenuForUnit(u) end)
    ctld.logInfo("[fix_menu] buildMenuForUnit ok=%s err=%s", tostring(ok2), tostring(err2))
    return "buildMenuForUnit: " .. tostring(ok2) .. " " .. tostring(err2)
end

return "no menu, no core manager — CTLD may not be running"
