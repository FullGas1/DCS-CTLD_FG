---@diagnostic disable
-- ============================================================
-- _diag_init.lua — Debug launcher : remplace le trigger mission
-- Injecter via Witchcraft AU LIEU du trigger normal.
-- Active debug=true AVANT le dofile → toutes les traces init
-- atterrissent dans CTLD.log (lisible par Claude via Witchcraft).
-- ============================================================

-- 1. Activer debug avant tout
ctld = ctld or {}
ctld.debug = true   -- hint pré-config : initLog() ouvrira CTLD.log

-- 2. Reset complet si CTLD déjà chargé (re-injection)
local function _resetSingleton(name)
    local g = _G[name]
    if g then g._instance = nil end
end
_resetSingleton("CTLDConfig")
_resetSingleton("EventDispatcher")
_resetSingleton("CTLDDCSEventBridge")
_resetSingleton("CTLDPlayerTracker")
_resetSingleton("CTLDPlayerManager")
_resetSingleton("CTLDZoneManager")
_resetSingleton("CTLDTroopManager")
_resetSingleton("CTLDCrateManager")
_resetSingleton("CTLDVehicleSpawner")
_resetSingleton("CTLDFOBManager")
_resetSingleton("CTLDBeaconManager")
_resetSingleton("CTLDReconManager")
_resetSingleton("CTLDJTACManager")
_resetSingleton("CTLDCrateAssemblyManager")
_resetSingleton("CTLDCoreManager")
if ctld.MenuManager then ctld.MenuManager._instance = nil end
if ctld.utils and ctld.utils.closeLog then ctld.utils.closeLog() end

-- 3. Purge CTLD.log
do
    local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log", "w")
    if f then f:close() end
end

-- 4. Charger CTLD_Next.lua — ctld.initialize() s'exécute en fin de fichier
--    debug=true étant déjà positionné, initLog() ouvrira CTLD.log
--    et TOUTES les traces init y seront écrites.
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/CTLD_Next.lua")
