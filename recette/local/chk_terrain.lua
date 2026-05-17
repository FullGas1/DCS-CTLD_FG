-- recette/chk_terrain.lua
-- Probe land height westward from Batumi to find sea (height == 0)
local bx, bz = -356437, 618211
local results = {}
for km = 1, 10 do
    local z = bz - km * 1000
    local h = land.getHeight({ x = bx, y = z })
    local isSurf = land.getSurfaceType({ x = bx, y = z })
    -- SurfaceType: 1=LAND, 2=SHALLOW_WATER, 3=WATER, 4=ROAD, 5=RUNWAY
    results[#results+1] = string.format("  -%dkm z=%.0f h=%.1f surf=%d", km, z, h, isSurf)
end
local msg = table.concat(results, "\n")
ctld.logInfo("chk_terrain (west of Batumi):\n" .. msg)
trigger.action.outText("Terrain west of Batumi:\n" .. msg, 30)
return "DONE"
