-- Diagnostic: véhicules BLUE dans/autour de AIZ_depot_B_P_V_10
CTLDCoreManager.getInstance():_initAITransports()
local zm  = CTLDZoneManager.getInstance()
local zone = zm._troopZones["AIZ_depot_B_P_V_10"]
if not zone then return "AIZ_depot_B_P_V_10 NOT LOADED" end

local zc = zone:getCenter()
local r  = zone.radius or 500
local result = { string.format("Zone r=%.0fm", r) }

local groups = coalition.getGroups(coalition.side.BLUE, Group.Category.GROUND) or {}
local found = {}
for _, grp in ipairs(groups) do
    for _, u in ipairs(grp:getUnits() or {}) do
        if u:isExist() then
            local pt   = u:getPoint()
            local dist = math.sqrt((pt.x-zc.x)^2 + (pt.z-zc.z)^2)
            if dist <= r * 3 then
                table.insert(found, string.format("%s(%s) d=%.0f %s",
                    u:getName(), u:getTypeName(), dist,
                    dist <= r and "IN" or "near"))
            end
        end
    end
end
if #found == 0 then table.insert(result, "NO BLUE ground units within 3x radius") end
for _, s in ipairs(found) do table.insert(result, s) end
return table.concat(result, " | ")
