-- diag_zone_distance.lua
-- Compare la position du heli avec le centre des AIZ zones
local u = Unit.getByName("heliai_vehicle")
if not u then return "heliai_vehicle introuvable" end
local hp = u:getPoint()

local zm = CTLDZoneManager.getInstance()
local lines = { string.format("heli pos: x=%.0f z=%.0f", hp.x, hp.z) }
for name, z in pairs(zm._troopZones) do
    if z.isAIPickup then
        local c = z.center or {}
        local dx = hp.x - (c.x or 0)
        local dz = hp.z - (c.z or 0)
        local dist = math.sqrt(dx*dx + dz*dz)
        lines[#lines+1] = string.format("%s | center x=%.0f z=%.0f | r=%.0f | dist_heli=%.0f | inZone=%s",
            name, c.x or 0, c.z or 0, z.radius or 0, dist, tostring(dist <= (z.radius or 0)))
    end
end
return table.concat(lines, "\n")
