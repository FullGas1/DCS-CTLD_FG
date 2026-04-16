---@diagnostic disable
-- Re-initialize CTLD with new build and check troop menu readiness
local logPath = "C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log"
local results = {}

-- 1. Reset singletons
local function resetSingleton(name)
    local g = _G[name]
    if g then g._instance = nil end
end
resetSingleton("CTLDConfig")
resetSingleton("EventDispatcher")
resetSingleton("CTLDDCSEventBridge")
resetSingleton("CTLDPlayerTracker")
resetSingleton("CTLDPlayerManager")
resetSingleton("CTLDZoneManager")
resetSingleton("CTLDTroopManager")
resetSingleton("CTLDCrateManager")
resetSingleton("CTLDVehicleSpawner")
resetSingleton("CTLDFOBManager")
resetSingleton("CTLDBeaconManager")
resetSingleton("CTLDReconManager")
resetSingleton("CTLDJTACManager")
resetSingleton("CTLDCrateAssemblyManager")
resetSingleton("CTLDCoreManager")
if ctld and ctld.MenuManager then ctld.MenuManager._instance = nil end
if ctld and ctld.utils and ctld.utils.closeLog then ctld.utils.closeLog() end

-- 2. Clear log
do
    local f = io.open(logPath, "w")
    if f then f:close() end
end

-- 3. Re-load CTLD_Next.lua
ctld = ctld or {}
ctld.debug = true
local ok, err = pcall(dofile, "C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/CTLD_Next.lua")
if not ok then
    table.insert(results, "dofile ERROR: " .. tostring(err))
    -- Write error to log
    local f = io.open(logPath, "a")
    if f then
        f:write("[_diag_reinit] dofile ERROR: " .. tostring(err) .. "\n")
        f:close()
    end
    return table.concat(results, "\n")
end

table.insert(results, "dofile OK")

-- 4. Check unitActions
local ua = ctld.gs("unitActions")
table.insert(results, "unitActions type=" .. tostring(type(ua)))
if type(ua) == "table" then
    local found = false
    for k, v in pairs(ua) do
        if k == "UH-1H" then found = true; break end
    end
    table.insert(results, "UH-1H in unitActions: " .. tostring(found))
end

return table.concat(results, "\n")
