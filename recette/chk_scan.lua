-- recette/chk_scan.lua
-- Check current RECON scan state for player
local units = coalition.getPlayers(coalition.side.BLUE) or {}
local playerUnit = units[1]
if not playerUnit or not playerUnit:isExist() then
    trigger.action.outText("[CHK] No BLUE player found", 10)
    return "NO PLAYER"
end
local playerName = playerUnit:getName()
local rmgr = CTLDReconManager.getInstance()
local s = rmgr._activeScans[playerName]

if not s then
    trigger.action.outText("[CHK] No active scan for player: " .. playerName, 15)
    return "NO SCAN"
end

local lines = { "[CHK] Scan for: " .. playerName }
lines[#lines+1] = "  targets: " .. #s.targets
for _, t in ipairs(s.targets) do
    lines[#lines+1] = string.format("  [%s] %s markId=%s", t.layer and t.layer.layerId or "?", t.unitType or "?", tostring(t.markId))
end
local msg = table.concat(lines, "\n")
trigger.action.outText(msg, 30)
env.info(msg)
return msg
