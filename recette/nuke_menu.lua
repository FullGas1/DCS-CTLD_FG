-- nuke_menu.lua — effacer TOUT le menu DCS du groupe puis reconstruire
local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "no player" end
local gid = u:getGroup():getID()

-- Nuke entire group menu (nil path = root)
pcall(function() missionCommands.removeItemForGroup(gid, nil) end)

-- Rebuild from scratch
local mmgr = ctld.MenuManager:getInstance()
local res = mmgr:refreshMenuForGroup(gid)

trigger.action.outTextForGroup(gid, "Menu CTLD recharge - appuie sur *", 15)
return string.format("nuked + rebuilt: %d items", res and res.refreshedCount or 0)
