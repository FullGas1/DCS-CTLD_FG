-- Check player + reset counter
local units = coalition.getPlayers(coalition.side.BLUE) or {}
local playerUnit = #units > 0 and units[1] or nil
if playerUnit and playerUnit:isExist() then
    trigger.action.outText("[TFC] Player OK: " .. playerUnit:getName(), 30)
else
    trigger.action.outText("[TFC] WARNING: no BLUE player slot occupied!", 30)
end
_G["_TFC_STEP"] = 1
trigger.action.outText("[TFC] counter reset to 1 (for fresh start)", 30)
return "check done"