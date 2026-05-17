-- Check if player transport is in a logistics zone
local zm = CTLDZoneManager.getInstance()
local players = CTLDPlayerManager.getInstance()._players
local found = false
for unitName, playerObj in pairs(players) do
    local unit = Unit.getByName(unitName)
    if unit and unit:isExist() then
        local pos  = unit:getPoint()
        local zone = zm:getLogisticZoneAtPoint(pos, playerObj.coalition)
        local msg  = string.format("[LGZ CHECK] %s (coa=%s) -> %s",
            unitName,
            tostring(playerObj.coalition),
            zone and ("IN ZONE: " .. tostring(zone.name)) or "NOT IN ANY LGZ")
        ctld.utils.log("INFO", msg)
        trigger.action.outText(msg, 15)
        found = true
    end
end
if not found then
    local msg = "[LGZ CHECK] No active player found"
    ctld.utils.log("INFO", msg)
    trigger.action.outText(msg, 10)
end
