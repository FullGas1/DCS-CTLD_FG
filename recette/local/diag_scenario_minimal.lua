ctld.debug = true

local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/diag.log", "a")
f:write("\n=== SCENARIO MINIMAL " .. os.date() .. " ===\n")

f:write("L40: coalition.getPlayers...\n")
f:flush()

local playerUnit = nil
do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    f:write("  units count = " .. #units .. "\n")
    f:flush()
    if #units > 0 then playerUnit = units[1] end
end

f:write("L47: playerUnit check...\n")
f:flush()

if not playerUnit or not playerUnit:isExist() then
    f:write("  ABORT: no BLUE player\n")
    f:close()
    return
end

local playerName = playerUnit:getName()
f:write("  playerName = " .. tostring(playerName) .. "\n")
f:flush()

-- Simulate the STEP 1 block exactly
f:write("L57: TEST_TMPL_NAME = Test2JTAC\n")
f:flush()

local TEST_TMPL_NAME = "Test2JTAC"

f:write("L58: cleanupAll() calling getInstance()...\n")
f:flush()

local tm = CTLDTroopManager.getInstance()
f:write("  getInstance returned tm = " .. tostring(tm) .. "\n")
f:flush()

local jm = CTLDJTACManager.getInstance()
f:write("  JTACManager.get returned jm = " .. tostring(jm) .. "\n")
f:flush()

f:write("SUCCESS - all checks passed\n")
f:close()
trigger.action.outText("[scenario_minimal] PASSED — see diag.log", 30)