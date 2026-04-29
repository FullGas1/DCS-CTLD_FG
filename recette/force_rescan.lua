-- recette/force_rescan.lua
-- Stop current scan (remove all marks) then re-scan immediately.
-- Use after patching config (icon sizes, reconEnabled, radius).

local units = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = units[1]
if not pu or not pu:isExist() then
    return "ABORT: no BLUE player"
end
local playerName = pu:getName()
local rmgr = CTLDReconManager.getInstance()

-- Stop: remove marks + clear scan entry
local s = rmgr._activeScans[playerName]
if s then
    if s.refreshTimer then
        pcall(timer.removeFunction, s.refreshTimer)
        s.refreshTimer = nil
    end
    pcall(function() rmgr:_removeAllMarks(s) end)
    rmgr._activeScans[playerName] = nil
end

-- Re-scan immediately (reconEnabled=true already set by patch_session_config)
pcall(function() rmgr:scan(pu, playerName) end)

local s2 = rmgr._activeScans[playerName]
local cnt = s2 and #s2.targets or 0
trigger.action.outText(string.format("[RECON] Rescan done: %d targets detected", cnt), 15)
ctld.logInfo(string.format("force_rescan: %d targets", cnt))
if s2 then
    for _, t in ipairs(s2.targets) do
        ctld.logInfo(string.format("  [%s] %s markId=%s", t.layer and t.layer.layerId or "?", t.unitType or "?", tostring(t.markId)))
    end
end
return "RESCAN OK — " .. cnt .. " targets"
