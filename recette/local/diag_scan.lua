-- recette/diag_scan.lua — debug scan() step by step, output via ctld.logInfo → CTLD.log
local units = coalition.getPlayers(coalition.side.BLUE) or {}
local playerUnit = #units > 0 and units[1] or nil
if not playerUnit then return "ABORT: no BLUE player" end
local playerName = playerUnit:getPlayerName() or playerUnit:getName()
local rmgr = CTLDReconManager.getInstance()

local function L(msg)
    ctld.logInfo("[DIAG] " .. msg)
end

L("=== diag_scan START ===")
L("playerName=" .. playerName)
L("reconEnabled=" .. tostring(ctld.gs("reconEnabled")))

-- Altitude
local pos = playerUnit:getPoint()
local ground = land.getHeight({ x = pos.x, y = pos.z })
local agl = pos.y - ground
L("AGL=" .. string.format("%.2f", agl) .. "  reconMinAltitude=" .. tostring(ctld.gs("reconMinAltitude")))

-- Layers
local allLayers = rmgr:_getPlayerLayers(playerName)
local enabledCount = 0
for _, l in ipairs(allLayers) do
    L("  layer " .. l.layerId .. " enabled=" .. tostring(l.enabled))
    if l.enabled then enabledCount = enabledCount + 1 end
end
L("enabledLayers total=" .. enabledCount)

-- Enemy units
local enemies = rmgr:_getEnemyUnitNames(playerUnit:getCoalition())
L("enemies found=" .. #enemies)
for i, n in ipairs(enemies) do
    if i <= 5 then L("  enemy[" .. i .. "]=" .. n) end
end

-- Patch altitude to 0 and call scan
L("--- calling scan() ---")
CTLDConfig.get().settings["reconMinAltitude"] = 0

local ok, err = pcall(function()
    rmgr:scan(playerUnit, playerName)
end)
CTLDConfig.get().settings["reconMinAltitude"] = 50

L("scan() ok=" .. tostring(ok) .. " err=" .. tostring(err))
local scan = rmgr._activeScans[playerName]
L("_activeScans[playerName] set=" .. tostring(scan ~= nil))
if scan then
    L("  targets=" .. #scan.targets .. "  autoRefresh=" .. tostring(scan.autoRefresh))
end
L("=== diag_scan END ===")

-- cleanup
if scan then
    if scan.refreshTimer then timer.removeFunction(scan.refreshTimer) end
    rmgr._activeScans[playerName] = nil
end

return string.format("done: scan ok=%s | check CTLD.log for [DIAG]", tostring(ok))
