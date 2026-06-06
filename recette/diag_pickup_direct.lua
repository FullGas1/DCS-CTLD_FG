local u = Unit.getByName("heliai_mt10a")
if not u then return "UNIT NOT FOUND" end
local pt  = u:getPoint()
local coa = u:getCoalition()
local zm  = CTLDZoneManager.getInstance()

-- Direct API call
local apiResult = zm:getAIPickupZoneAt(pt, coa)

-- Manual iteration (same logic)
local manualResult = nil
local manualR = math.huge
for _, zone in pairs(zm._troopZones) do
    if zone.active and zone:hasAIPickup()
    and (coa == 0 or zone.coalition == 0 or zone.coalition == coa)
    and zone:isInZone(pt) then
        local r = zone.radius or math.huge
        if r < manualR then manualResult = zone; manualR = r end
    end
end

return string.format("pt=(%.1f,%.1f,%.1f) coa=%d | apiResult=%s | manualResult=%s",
    pt.x, pt.y, pt.z, coa,
    tostring(apiResult and apiResult.dcsName or "nil"),
    tostring(manualResult and manualResult.dcsName or "nil"))
