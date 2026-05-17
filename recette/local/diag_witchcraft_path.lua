ctld.debug = true

local testFile = "c:/temp/witchcraft_test.txt"
local f = io.open(testFile, "w")
if f then
    f:write("WITCHCRAFT TEST " .. os.date() .. "\n")
    f:write("CTLDTroopManager = " .. tostring(CTLDTroopManager) .. "\n")
    f:write("getInstance = " .. tostring(CTLDTroopManager.getInstance) .. "\n")
    local tm = CTLDTroopManager.getInstance()
    f:write("tm = " .. tostring(tm) .. "\n")
    if tm then
        f:write("tm._inTransit = " .. tostring(type(tm._inTransit)) .. "\n")
        f:write("tm:hasTroops = " .. tostring(type(tm.hasTroops)) .. "\n")
    end
    f:close()
    trigger.action.outText("[ok] wrote test file", 30)
else
    trigger.action.outText("[FAIL] cannot open " .. testFile, 30)
end