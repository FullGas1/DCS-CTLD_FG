-- Standalone step-4 check for MT-10b: AttackNearestEnemyOnLos
-- Reads CTLD.log, finds last line with "AttackNearestEnemyOnLos",
-- verifies it comes from _assignPostSpawnTask (not template setup).
local cfg = CTLDConfig.get()
pcall(ctld.utils.closeLog)
local logPath = (cfg.settings["ctldLogPath"] or "") .. "CTLD.log"
local f = io.open(logPath, "r")
pcall(ctld.utils.reopenLogAppend)
if not f then return "FAIL: CTLD.log not found at " .. logPath end

local lastMatch = nil
for line in f:lines() do
    if string.find(line, "AttackNearestEnemyOnLos", 1, true) then
        lastMatch = line
    end
end
f:close()

if not lastMatch then
    return "FAIL: 'AttackNearestEnemyOnLos' not found in log"
end
if not string.find(lastMatch, "_assignPostSpawnTask", 1, true) then
    return "FAIL: found line does not come from _assignPostSpawnTask: " .. lastMatch
end
-- Check coordinates present (pattern mode, not plain)
local hasCoords = string.find(lastMatch, "%d+%.%d") ~= nil
if not hasCoords then
    return "FAIL: no coordinates in line: " .. lastMatch
end
return "PASS MT-10b: " .. lastMatch
