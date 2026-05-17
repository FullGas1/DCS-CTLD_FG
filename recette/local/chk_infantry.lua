-- recette/chk_infantry.lua
local g = Group.getByName("RECON_TEST_infantry")
if not g or not g:isExist() then
    trigger.action.outText("[CHK] RECON_TEST_infantry group: DOES NOT EXIST", 15)
    return "GROUP MISSING"
end
local units = g:getUnits()
local lines = { "[CHK] infantry group exists, units: " .. #units }
for _, u in ipairs(units) do
    lines[#lines+1] = string.format("  %s life=%.0f pos=%.0f,%.0f",
        u:getName(), u:getLife(), u:getPoint().x, u:getPoint().z)
end
local msg = table.concat(lines, "\n")
trigger.action.outText(msg, 20)
return msg
