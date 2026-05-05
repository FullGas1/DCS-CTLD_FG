ctld.debug = true

local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/diag.log", "a")
f:write("\n=== SCENARIO DIAG " .. os.date() .. " ===\n")

f:write("CTLDTroopManager type = " .. type(CTLDTroopManager) .. "\n")
f:write("CTLDTroopManager.getInstance = " .. tostring(CTLDTroopManager.getInstance) .. "\n")
f:write("CTLDTroopManager._instance = " .. tostring(CTLDTroopManager._instance) .. "\n")
f:write("CTLDTroopManager.init = " .. tostring(CTLDTroopManager.init) .. "\n")

local okTM, tm = pcall(CTLDTroopManager.getInstance)
f:write("getInstance() ok=" .. tostring(okTM) .. " tm=" .. tostring(tm) .. "\n")

local okJM, jm = pcall(CTLDJTACManager.get)
f:write("JTACManager.get() ok=" .. tostring(okJM) .. " jm=" .. tostring(jm) .. "\n")

local okOR, ort = pcall(CTLDObjectRegistry.getInstance)
f:write("ObjectRegistry.getInstance() ok=" .. tostring(okOR) .. " ort=" .. tostring(ort) .. "\n")

f:close()
trigger.action.outText("[SCENARIO-DIAG] See diag.log", 30)