---@diagnostic disable
local transport = coalition.getPlayers(coalition.side.BLUE)
transport = transport and transport[1]
if not transport then return "no BLUE player" end
local pos = transport:getPoint()
local cId = transport:getCoalition()
local inAir = ctld.utils.inAir(transport)

local zm = CTLDZoneManager.getInstance()
local inZone  = zm:getLogisticZoneAtPoint(pos, cId) ~= nil
local minDist = ctld.gs("fobMinDistanceFromZones") or 500
local tooClose, closestDist = false, 9999
for _, zone in ipairs(zm:getLogisticZonesForCoalition(cId)) do
    local d = ctld.utils.getDistance("diag", pos, zone:getCenter())
    if d < closestDist then closestDist = d end
    if d < minDist then tooClose = true end
end

local cm = CTLDCrateManager.getInstance()
local fobDesc  = cm:findDescriptorByUnitType("FOB")
local required = (fobDesc and fobDesc.cratesRequired) or 3
local collected = 0
for _, c in ipairs(cm:getCratesInRange(pos, 750)) do
    if c.coalition == cId and c.descriptor and c.descriptor.unit == "FOB" then
        collected = collected + 1
    end
end

return string.format("inAir=%s | inZone=%s | tooClose=%s (closest=%.0fm min=%dm) | crates=%d/%d",
    tostring(inAir), tostring(inZone), tostring(tooClose),
    closestDist, minDist, collected, required)
