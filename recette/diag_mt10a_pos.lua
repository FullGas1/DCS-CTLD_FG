local u = Unit.getByName("heliai_mt10a")
if not u then return "UNIT NOT FOUND" end
local uPt = u:getPoint()
local dcsZ = trigger.misc.getZone("AIZ_depot_B_P_T_10")
if not dcsZ then return "ZONE NOT FOUND" end
local zPt = dcsZ.point
local dist = math.sqrt((uPt.x-zPt.x)^2 + (uPt.z-zPt.z)^2)
return string.format("heli→AIZ_P dist=%.0fm zone_r=%.0fm inAir=%s",
    dist, dcsZ.radius, tostring(u:inAir()))
