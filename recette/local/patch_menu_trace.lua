-- recette/patch_menu_trace.lua
-- Temporarily trace missionCommands calls to confirm DCS API is called.
local _origAddSub = missionCommands.addSubMenuForGroup
local _origAddCmd = missionCommands.addCommandForGroup
local _origRemove = missionCommands.removeItemForGroup
local traceCount  = 0

missionCommands.addSubMenuForGroup = function(gid, name, path)
    traceCount = traceCount + 1
    ctld.logInfo("[mcsTrace] addSubMenuForGroup gid=%d name=%s path=%s", gid, tostring(name), tostring(path))
    return _origAddSub(gid, name, path)
end
missionCommands.addCommandForGroup = function(gid, name, path, fn, arg)
    traceCount = traceCount + 1
    ctld.logInfo("[mcsTrace] addCommandForGroup gid=%d name=%s", gid, tostring(name))
    return _origAddCmd(gid, name, path, fn, arg)
end
missionCommands.removeItemForGroup = function(gid, path)
    ctld.logInfo("[mcsTrace] removeItemForGroup gid=%d path=%s", gid, tostring(path))
    return _origRemove(gid, path)
end

-- Now trigger rebuild
local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "no player" end
local gid = u:getGroup():getID()
pcall(function() missionCommands.removeItemForGroup(gid, { "CTLD" }) end)
local mmgr = ctld.MenuManager:getInstance()
mmgr:refreshMenuForGroup(gid)

-- Restore after 2s
timer.scheduleFunction(function()
    missionCommands.addSubMenuForGroup = _origAddSub
    missionCommands.addCommandForGroup = _origAddCmd
    missionCommands.removeItemForGroup = _origRemove
    ctld.logInfo("[mcsTrace] restored — total calls traced: %d", traceCount)
end, nil, timer.getTime() + 2)

return "tracing missionCommands for 2s — check CTLD.log"
