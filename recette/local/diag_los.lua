-- recette/diag_los.lua
-- Test LOS between player and infantry unit manually.
local units = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = units[1]
if not pu or not pu:isExist() then return "NO PLAYER" end

local infUnit = Unit.getByName("RECON_TEST_inf_1")
if not infUnit or not infUnit:isExist() then
    trigger.action.outText("[LOS] Infantry unit not found!", 10)
    return "NO INF"
end

local p1 = pu:getPoint()
local p2 = infUnit:getPoint()
local dist = math.sqrt((p1.x-p2.x)^2 + (p1.z-p2.z)^2)

-- LOS with altoffset=180 (as in _scanLOS)
local pt1 = { x=p1.x, y=p1.y+180, z=p1.z }
local pt2 = { x=p2.x, y=p2.y+180, z=p2.z }
local isVis = land.isVisible(pt1, pt2)

-- LOS without altoffset
local pt1b = { x=p1.x, y=p1.y, z=p1.z }
local pt2b = { x=p2.x, y=p2.y, z=p2.z }
local isVisRaw = land.isVisible(pt1b, pt2b)

local msg = string.format("[LOS] player y=%.1f inf y=%.1f dist=%.0fm\n  +180: visible=%s\n  raw:  visible=%s",
    p1.y, p2.y, dist, tostring(isVis), tostring(isVisRaw))
trigger.action.outText(msg, 25)
ctld.logInfo(msg)

-- Also check isActive
ctld.logInfo(string.format("[LOS] inf isActive=%s isExist=%s cat=%s",
    tostring(infUnit:isActive()), tostring(infUnit:isExist()), tostring(Object.getCategory(infUnit))))

-- List RED units found by getUnitsListNamesByCategory
local names = ctld.utils.getUnitsListNamesByCategory("diag_los", coalition.side.RED, {Group.Category.GROUND})
local found = false
for _, n in ipairs(names) do
    if n == "RECON_TEST_inf_1" then found = true end
end
ctld.logInfo(string.format("[LOS] RED ground units count=%d, inf_found=%s", #names, tostring(found)))
return msg
