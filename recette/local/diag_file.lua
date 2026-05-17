ctld.debug = true

local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/diag.log", "a")
f:write("\n=== DIAG " .. os.date() .. " ===\n")

f:write("ctld = " .. tostring(ctld) .. "\n")
f:write("CTLDTroopManager = " .. tostring(CTLDTroopManager) .. "\n")
f:write("CTLDJTACManager = " .. tostring(CTLDJTACManager) .. "\n")
f:write("CTLDObjectRegistry = " .. tostring(CTLDObjectRegistry) .. "\n")
f:write("trigger = " .. tostring(trigger) .. "\n")
f:write("world = " .. tostring(world) .. "\n")

if ctld then
    f:write("ctld.utils = " .. tostring(ctld.utils) .. "\n")
end

f:close()
trigger.action.outText("[diag] See recette/diag.log", 30)