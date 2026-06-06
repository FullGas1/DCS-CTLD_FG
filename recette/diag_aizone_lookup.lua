local u = Unit.getByName("heliai_mt10a")
if not u then return "UNIT NOT FOUND" end
local pt  = u:getPoint()
local coa = u:getCoalition()
local zm  = CTLDZoneManager.getInstance()
local results = {}
table.insert(results, "unit.coalition=" .. tostring(coa) .. " inAir=" .. tostring(u:inAir()))
local count = 0
for k, zone in pairs(zm._troopZones) do
    count = count + 1
    local c1 = zone.active == true
    local c2 = zone:hasAIPickup()
    local c3 = (coa == 0 or zone.coalition == 0 or zone.coalition == coa)
    local c4 = zone:isInZone(pt)
    if c2 then  -- only report AIPickup zones
        table.insert(results, string.format("zone=%s active=%s hasAIPickup=%s coalOK=%s(zc=%s) inZone=%s",
            k, tostring(c1), tostring(c2), tostring(c3), tostring(zone.coalition), tostring(c4)))
    end
end
table.insert(results, "total_zones=" .. count)
return table.concat(results, " | ")
