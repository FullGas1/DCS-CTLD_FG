-- recette/test_mark.lua
-- Place a visible test mark near the player + one at Batumi
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = players[1]

-- Remove previous test marks
for i = 90001, 90030 do pcall(trigger.action.removeMark, i) end

local BATUMI = { x = -356437, z = 618211 }
local NM1 = 1852

-- Test 1: mark right at player position
if pu and pu:isExist() then
    local p = pu:getPoint()
    trigger.action.markToAll(90001, "TEST: PLAYER POS", { x=p.x, y=0, z=p.z }, false, "")
end

-- Test 2: mark at Batumi center
trigger.action.markToAll(90002, "TEST: BATUMI CENTER", { x=BATUMI.x, y=0, z=BATUMI.z }, false, "")

-- Test 3: 3 triangle WPs (same as loopingTriangleRoute)
local wps = {
    { x=BATUMI.x,       z=BATUMI.z+NM1 },
    { x=BATUMI.x-NM1,   z=BATUMI.z-NM1 },
    { x=BATUMI.x+NM1,   z=BATUMI.z-NM1 },
}
for i, wp in ipairs(wps) do
    trigger.action.markToAll(90002+i, "WP"..i.." x="..math.floor(wp.x).." z="..math.floor(wp.z), { x=wp.x, y=0, z=wp.z }, false, "")
end

-- Test 4: ship position
local shipX = BATUMI.x + 556
local shipZ = BATUMI.z - 3500
trigger.action.markToAll(90010, "SHIP POS x="..math.floor(shipX).." z="..math.floor(shipZ), { x=shipX, y=0, z=shipZ }, false, "")

-- Lines between WPs
trigger.action.lineToAll(-1, 90011,
    {x=wps[1].x, y=0, z=wps[1].z}, {x=wps[2].x, y=0, z=wps[2].z},
    {0,1,1,1}, 3, false, "")
trigger.action.lineToAll(-1, 90012,
    {x=wps[2].x, y=0, z=wps[2].z}, {x=wps[3].x, y=0, z=wps[3].z},
    {0,1,1,1}, 3, false, "")
trigger.action.lineToAll(-1, 90013,
    {x=wps[3].x, y=0, z=wps[3].z}, {x=wps[1].x, y=0, z=wps[1].z},
    {0,1,1,1}, 3, false, "")

trigger.action.outText("[TEST] Marks placed: player pos, Batumi center, 3 WPs, ship pos, triangle lines", 20)
return "TEST MARKS PLACED"
