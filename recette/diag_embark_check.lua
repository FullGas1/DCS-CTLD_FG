-- Simulate embark check for heliai_mt10b + Standard Group
local grp = Group.getByName("heliai_mt10b")
if not grp then return "heliai_mt10b not found" end
local u = grp:getUnit(1)
if not u then return "no unit" end

local tm       = CTLDTroopManager.getInstance()
local zm       = CTLDZoneManager.getInstance()
local typeName = u:getTypeName()
local unitName = u:getName()
local pt       = u:getPoint()

-- Find Standard Group template
local tmpl = nil
for _, t in ipairs(tm._templates) do
    if t.name == "Standard Group" then tmpl = t; break end
end
if not tmpl then return "Standard Group template not found" end

local w      = tm:_weightForGroup(tmpl)
local canEmb = tm:_canEmbark(typeName, unitName, tmpl.total, w)

local zP     = zm._troopZones["AIZ_depot_B_P_T_10"]
local stockOk = zP and (zP.pickMaxStock == 0 or zP.pickCurrentStock >= tmpl.total)

local pickZone = zm:getAIPickupZoneAt(pt, u:getCoalition())

return string.format(
    "type=%s canEmb=%s weight=%.0fkg total=%d stock=%s/%s stockOk=%s pickZoneAtPos=%s",
    typeName, tostring(canEmb), w, tmpl.total,
    tostring(zP and zP.pickCurrentStock), tostring(zP and zP.pickMaxStock),
    tostring(stockOk),
    tostring(pickZone and pickZone.zoneName))
