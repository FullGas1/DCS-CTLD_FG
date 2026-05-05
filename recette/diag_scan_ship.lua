-- recette/diag_scan_ship.lua
-- Trace exactly why Speedboat is excluded from scan.
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = players[1]
if not pu then return "NO PLAYER" end
local rmgr = CTLDReconManager.getInstance()

-- 1. Enemy names list
local enemyNames = rmgr:_getEnemyUnitNames(pu:getCoalition())
ctld.logInfo(string.format("enemy names count=%d", #enemyNames))
local speedFound = false
for _, n in ipairs(enemyNames) do
    if n == "RECON_TEST_ship_1" then speedFound = true end
end
ctld.logInfo("Speedboat in enemy list: " .. tostring(speedFound))

-- 2. LOS via ctld.utils.getUnitsLOS (same call as _scanLOS)
local losData = ctld.utils.getUnitsLOS(
    "diag_scan_ship",
    { pu:getName() },
    180,
    enemyNames,
    180,
    12000)

ctld.logInfo(string.format("LOS results count=%d", #losData))
local speedInLOS = false
if losData then
    for _, entry in ipairs(losData) do
        if entry.vis then
            for _, u in ipairs(entry.vis) do
                local n = u:getName()
                local t = u:getTypeName()
                ctld.logInfo("  visible: " .. n .. " type=" .. t)
                if n == "RECON_TEST_ship_1" then speedInLOS = true end
            end
        end
    end
end
ctld.logInfo("Speedboat in LOS results: " .. tostring(speedInLOS))

-- 3. Check _matchLayer for Speedboat
local enabledLayers = rmgr:_enabledLayers(pu:getName())
ctld.logInfo("enabled layers: " .. #enabledLayers)
local su = Unit.getByName("RECON_TEST_ship_1")
if su then
    local layer = rmgr:_matchLayer(su, enabledLayers)
    ctld.logInfo("Speedboat matched layer: " .. tostring(layer and layer.layerId))
end

trigger.action.outText(string.format("[DIAG] speed_in_enemy=%s speed_in_LOS=%s", tostring(speedFound), tostring(speedInLOS)), 20)
return "DONE"
