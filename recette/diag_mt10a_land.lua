-- Simulate S_EVENT_LAND for heliai_mt10a to test onAILand handler
local unit = Unit.getByName("heliai_mt10a")
if not unit then return "UNIT heliai_mt10a NOT FOUND" end
local cm = CTLDCoreManager.getInstance()
local fakeEvent = { id = world.event.S_EVENT_LAND, initiator = unit }
local ok, err = pcall(function() cm:onEvent(fakeEvent) end)
if not ok then return "onEvent ERROR: " .. tostring(err) end
return "onEvent called OK — check screen+log for pickup msg"
