local u = Unit.getByName("heliai_mt10a")
if not u then return "UNIT NOT FOUND" end
local tm = CTLDTroopManager.getInstance()
local cm = CTLDCoreManager.getInstance()
local typeName = u:getTypeName()
local teams = cm._aiTeams[2] or {}
local result = { "typeName=" .. typeName .. " teams=" .. #teams }
for i, t in ipairs(teams) do
    local w = tm:_weightForGroup(t)
    local canEmb = tm:_canEmbark(typeName, "heliai_mt10a", t.total, w)
    table.insert(result, string.format("tmpl[%d]='%s' total=%d w=%d canEmb=%s",
        i, t.name or "?", t.total or 0, w or 0, tostring(canEmb)))
end
-- caps
local caps = (ctld.gs("capabilitiesByType") or {})[typeName] or {}
table.insert(result, "maxSoldiers=" .. tostring(caps.maxSoldiers)
    .. " maxWeight=" .. tostring(caps.maxLoadWeight))
return table.concat(result, " | ")
