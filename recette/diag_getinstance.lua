ctld.debug = true

local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/diag.log", "a")
f:write("\n=== GETINSTANCE DIAG " .. os.date() .. " ===\n")

f:write("CTLDTroopManager type = " .. type(CTLDTroopManager) .. "\n")
f:write("rawget(CTLDTroopManager, 'getInstance') = " .. tostring(rawget(CTLDTroopManager, 'getInstance')) .. "\n")
f:write("rawget(CTLDTroopManager, '_instance') = " .. tostring(rawget(CTLDTroopManager, '_instance')) .. "\n")
f:write("CTLDTroopManager.getInstance = " .. tostring(CTLDTroopManager.getInstance) .. "\n")

-- List all keys in CTLDTroopManager
local keys = {}
for k, v in pairs(CTLDTroopManager) do
    table.insert(keys, tostring(k))
end
table.sort(keys)
f:write("CTLDTroopManager keys (#=" .. #keys .. "): " .. table.concat(keys, ", ") .. "\n")

-- Try calling getInstance
local ok, res = pcall(CTLDTroopManager.getInstance)
f:write("pcall getInstance: ok=" .. tostring(ok) .. " res=" .. tostring(res) .. "\n")
if not ok then f:write("  ERROR: " .. tostring(res) .. "\n") end

-- If getInstance is nil, try calling init directly
if not ok then
    f:write("Trying CTLDTroopManager.init directly...\n")
    local ok2, res2 = pcall(function() local o = setmetatable({}, CTLDTroopManager); o:init(); return o end)
    f:write("  ok2=" .. tostring(ok2) .. " res2=" .. tostring(res2) .. "\n")
end

f:close()
trigger.action.outText("[DIAG] getInstance check done — see diag.log", 30)