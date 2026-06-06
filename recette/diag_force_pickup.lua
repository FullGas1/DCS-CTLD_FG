local u = Unit.getByName("heliai_mt10a")
if not u then return "UNIT NOT FOUND" end
local cm  = CTLDCoreManager.getInstance()
local tm  = CTLDTroopManager.getInstance()
local result = {}
table.insert(result, "before: hasTroops=" .. tostring(tm:hasTroops("heliai_mt10a")))
table.insert(result, "_aiTeams[2]_count=" .. tostring(cm._aiTeams and cm._aiTeams[2] and #cm._aiTeams[2] or 0))
-- Force onAILand
local fakeEv = { id = world.event.S_EVENT_LAND, initiator = u }
local ok, err = pcall(cm.onAILand, cm, fakeEv)
if not ok then
    table.insert(result, "ERROR: " .. tostring(err))
else
    table.insert(result, "after: hasTroops=" .. tostring(tm:hasTroops("heliai_mt10a")))
    local list = tm:getInTransit("heliai_mt10a") or {}
    local total = 0
    for _, grp in ipairs(list) do total = total + (grp.unitTotal or 0) end
    table.insert(result, "inTransit_count=" .. #list .. " soldiers=" .. total)
end
return table.concat(result, " | ")
