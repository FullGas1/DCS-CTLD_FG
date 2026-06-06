-- Force-call onAILand for heliai_mt10a + log zone lookup result
local u = Unit.getByName("heliai_mt10a")
if not u then return "UNIT NOT FOUND" end

local cm = CTLDCoreManager.getInstance()
local zm = CTLDZoneManager.getInstance()
local pt = u:getPoint()
local coa = u:getCoalition()

local result = {}
table.insert(result, "inAir=" .. tostring(u:inAir()))
table.insert(result, "_aiPilotNames[heliai_mt10a]=" .. tostring(cm._aiPilotNames["heliai_mt10a"]))

local dropZone = zm:getAIDropoffZoneAt(pt, coa)
local pickZone = zm:getAIPickupZoneAt(pt, coa)
table.insert(result, "dropZone=" .. tostring(dropZone and dropZone.dcsZoneName or "nil"))
table.insert(result, "pickZone=" .. tostring(pickZone and pickZone.dcsZoneName or "nil"))

-- Force call onAILand directly
local fakeEv = { id = world.event.S_EVENT_LAND, initiator = u }
local ok, err = pcall(cm.onAILand, cm, fakeEv)
if not ok then
    table.insert(result, "onAILand ERROR: " .. tostring(err))
else
    table.insert(result, "onAILand called OK")
end

return table.concat(result, " | ")
