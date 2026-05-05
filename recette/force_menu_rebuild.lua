-- recette/force_menu_rebuild.lua
-- Force complete DCS menu rebuild for BLUE player by destroying and recreating
-- the CTLD root submenu via missionCommands directly.
local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "no player" end
local pn  = u:getName()
local gid = u:getGroup():getID()

-- Kill broken scan first
local rmgr = CTLDReconManager.getInstance()
local s = rmgr._activeScans[pn]
if s then
    if s.refreshTimer then pcall(timer.removeFunction, s.refreshTimer) end
    rmgr._activeScans[pn] = nil
end

-- Remove CTLD top-level entry from DCS (clears the whole subtree)
pcall(function() missionCommands.removeItemForGroup(gid, { "CTLD" }) end)

-- Now call the standard CTLD refresh which will re-add everything
local mmgr = ctld.MenuManager:getInstance()
local res  = mmgr:refreshMenuForGroup(gid)
ctld.logInfo("[force_menu_rebuild] result: %s", tostring(res and res.refreshedCount))

return string.format("menu rebuilt: %d items for group %d", res and res.refreshedCount or 0, gid)
