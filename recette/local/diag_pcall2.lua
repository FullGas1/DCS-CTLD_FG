ctld.debug = true

local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/diag.log", "a")
f:write("\n=== PCALL TEST " .. os.date() .. " ===\n")

f:write("CTLDTroopManager type: " .. type(CTLDTroopManager) .. "\n")
f:write("CTLDTroopManager.getInstance: " .. tostring(CTLDTroopManager.getInstance) .. "\n")

local ok, res = pcall(CTLDTroopManager.getInstance)
f:write("pcall ok=" .. tostring(ok) .. " res=" .. tostring(res) .. "\n")
if not ok then f:write("ERROR: " .. tostring(res) .. "\n") end

if ok and res then
    f:write("Instance has onUnitDead: " .. tostring(type(res.onUnitDead)) .. "\n")
    f:write("Instance has _inTransit: " .. tostring(type(res._inTransit)) .. "\n")
end

f:write("ctld.utils.log: " .. tostring(ctld.utils.log) .. "\n")
local logOk, logErr = pcall(ctld.utils.log, "INFO", "[pcalftest] test log")
f:write("ctld.utils.log ok=" .. tostring(logOk) .. " err=" .. tostring(logErr) .. "\n")

f:close()
trigger.action.outText("[pcal] see diag.log", 30)