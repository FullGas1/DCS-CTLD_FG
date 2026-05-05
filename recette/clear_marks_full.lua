-- recette/clear_marks_full.lua
-- Nuclear option: remove ALL marks in a wide range + stop active RECON scan.
local rmgr = CTLDReconManager.getInstance()

-- Stop all active scans and remove their marks
for key, s in pairs(rmgr._activeScans or {}) do
    if s then
        if s.refreshTimer then
            pcall(timer.removeFunction, s.refreshTimer)
            s.refreshTimer = nil
        end
        if s.targets then
            for _, t in ipairs(s.targets) do
                if t.markId then
                    pcall(function() CTLDReconRenderer.removeIcon(t.markId) end)
                    t.markId = nil
                end
            end
        end
        rmgr._activeScans[key] = nil
    end
end

-- Remove route debug marks
for i = 90001, 90030 do pcall(trigger.action.removeMark, i) end

-- Sweep all markIds in the range CTLD typically uses (1–2000 × 10 = up to 20000)
for id = 1, 20000 do
    pcall(trigger.action.removeMark, id)
end

trigger.action.outText("[CLEANUP] All marks cleared.", 10)
ctld.logInfo("clear_marks_full: all marks and scans cleared")
return "CLEARED"
