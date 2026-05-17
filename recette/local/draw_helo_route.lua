-- Draw Mi-8MT orbit triangle + diag
local BATUMI = { x = -356437, z = 618211 }
local NM1    = 1852
local alt    = 300
local color  = { 0.90, 0.49, 0.13, 0.8 }  -- orange

-- Clear previous route marks
for i = 90001, 90010 do pcall(trigger.action.removeMark, i) end

local wps = {
    { x = BATUMI.x,        z = BATUMI.z + NM1 },
    { x = BATUMI.x - NM1,  z = BATUMI.z - NM1 },
    { x = BATUMI.x + NM1,  z = BATUMI.z - NM1 },
}
local ok_count = 0
for i = 1, 3 do
    local j = (i % 3) + 1
    local ok, err = pcall(trigger.action.lineToAll, -1, 90000 + i,
        { x = wps[i].x, y = alt, z = wps[i].z },
        { x = wps[j].x, y = alt, z = wps[j].z },
        color, 2, true, "")
    if ok then ok_count = ok_count + 1
    else return "lineToAll ERROR: " .. tostring(err) end
end

-- Check if Mi-8MT group exists
local g = Group.getByName("RECON_TEST_helo")
local gExists = g and g:isExist()

return string.format("Mi-8MT orbit drawn (%d lines) — group exists=%s", ok_count, tostring(gExists))
