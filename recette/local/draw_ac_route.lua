-- Draw the Su-25 orbit triangle on the F10 map (session hotfix).
local BATUMI = { x = -356437, z = 618211 }
local NM1    = 1852
local alt    = 500
local color  = { 0.95, 0.77, 0.06, 0.8 }  -- yellow

local wps = {
    { x = BATUMI.x,        z = BATUMI.z + NM1 },
    { x = BATUMI.x - NM1,  z = BATUMI.z - NM1 },
    { x = BATUMI.x + NM1,  z = BATUMI.z - NM1 },
}
for i = 1, 3 do
    local j = (i % 3) + 1
    trigger.action.lineToAll(-1, 90000 + i,
        { x = wps[i].x, y = alt, z = wps[i].z },
        { x = wps[j].x, y = alt, z = wps[j].z },
        color, 2, true, "")
end
return "Su-25 orbit triangle drawn (marks 90001-90003)"
