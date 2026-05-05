-- reset_menu_full.lua — wipe internal menu state + force DCS rebuild
local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "no player" end
local gid = u:getGroup():getID()
local pn  = u:getName()

-- 1. Kill broken scan/autorefresh
local rmgr = CTLDReconManager.getInstance()
local s = rmgr._activeScans[pn]
if s then
    if s.refreshTimer then pcall(timer.removeFunction, s.refreshTimer) end
    rmgr._activeScans[pn] = nil
end

-- 2. Wipe internal ctld.Menu object for this group entirely, then rebuild from managers
local mmgr = ctld.MenuManager:getInstance()
mmgr.menus[gid] = nil   -- drop the stale internal tree

-- 3. Re-register the group (triggers full menu creation as if player just connected)
local core = CTLDCoreManager.getInstance()
local ok, err = pcall(function() core:buildMenuForGroup(u:getGroup()) end)
ctld.logInfo("[reset_menu_full] buildMenuForGroup ok=%s err=%s", tostring(ok), tostring(err))

trigger.action.outTextForGroup(gid, "Menu CTLD reconstruit - appuie sur *", 15)
return string.format("ok=%s err=%s", tostring(ok), tostring(err))
