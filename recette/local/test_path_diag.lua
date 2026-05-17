-- Diagnostic: ctldLogPath + io.open direct
ctld.debug = true
local cfg = CTLDConfig.get()

local diagPath = cfg.settings["ctldLogPath"] or "(nil)"
local diagDebug = cfg.settings["debug"]

trigger.action.outText("[DIAG] ctldLogPath=" .. tostring(diagPath) .. " debug=" .. tostring(diagDebug), 30)

-- Test io.open direct
local testPath = "recette/test_direct.txt"
local f = io.open(testPath, "w")
if f then
    f:write("direct write OK\n")
    f:close()
    trigger.action.outText("[DIAG] io.open(" .. testPath .. ") OK", 30)
else
    trigger.action.outText("[DIAG] io.open(" .. testPath .. ") FAILED", 30)
end

-- Test avec chemin absolu
local absPath = "C:/temp/ctld_test.txt"
local f2 = io.open(absPath, "w")
if f2 then
    f2:write("abs path OK\n")
    f2:close()
    trigger.action.outText("[DIAG] io.open(abs) OK", 30)
else
    trigger.action.outText("[DIAG] io.open(abs) FAILED", 30)
end