-- Add a direct world event handler to catch ALL S_EVENT_LAND and log them
local handler = {}
function handler:onEvent(e)
    if e.id == world.event.S_EVENT_LAND then
        local name = e.initiator and e.initiator:getName() or "nil"
        ctld.utils.log("INFO", "[DIAG_LAND] S_EVENT_LAND caught: unit=" .. name)
        trigger.action.outText("[DIAG_LAND] LAND: " .. name, 30)
    end
end
world.addEventHandler(handler)
return "land event handler added"
