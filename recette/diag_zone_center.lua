-- Compare stored zone center vs trigger.misc.getZone + unit position
local u = Unit.getByName("heliai_mt10a")
local zm = CTLDZoneManager.getInstance()
local zone = zm._troopZones["AIZ_depot_B_P_T_10"]
local trig = trigger.misc.getZone("AIZ_depot_B_P_T_10")
local result = {}

if zone then
    local c = zone.center or {}
    table.insert(result, string.format("zone.center x=%.1f y=%.1f z=%.1f r=%.0f",
        c.x or 0, c.y or 0, c.z or 0, zone.radius or 0))
    table.insert(result, "zone.active=" .. tostring(zone.active))
    table.insert(result, "zone.isAIPickup=" .. tostring(zone.isAIPickup))
end
if trig then
    local p = trig.point or {}
    table.insert(result, string.format("trig.point x=%.1f y=%.1f z=%.1f r=%.0f",
        p.x or 0, p.y or 0, p.z or 0, trig.radius or 0))
end
if u and u:isExist() then
    local pt = u:getPoint()
    table.insert(result, string.format("unit.pos x=%.1f y=%.1f z=%.1f inAir=%s",
        pt.x, pt.y, pt.z, tostring(u:inAir())))
    if zone then
        local c = zone.center or {}
        local dx = pt.x - (c.x or 0)
        local dz = pt.z - (c.z or 0)
        local dist = math.sqrt(dx*dx + dz*dz)
        table.insert(result, string.format("dist_to_center=%.1fm (r=%.0f)", dist, zone.radius or 0))
        table.insert(result, "isInZone=" .. tostring(zone:isInZone(pt)))
    end
end
return table.concat(result, " | ")
