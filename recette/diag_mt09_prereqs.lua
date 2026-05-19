-- diag_mt09_prereqs.lua
local lines = {}

-- Heli
local u = Unit.getByName("heliai_full")
lines[#lines+1] = "heliai_full: " .. (u and u:isExist() and ("exist type=" .. u:getTypeName() .. " player=" .. tostring(u:getPlayerName())) or "NOT FOUND")

-- Vehicles registered (INIT-D)
local ok, vs = pcall(CTLDVehicleSpawner.getInstance)
if ok and vs then
    local vcount = 0
    for id, veh in pairs(vs._vehicles) do
        vcount = vcount + 1
        local dist = "?"
        if u and u:isExist() and veh.unit and veh.unit:isExist() then
            dist = string.format("%.0fm", ctld.utils.getDistance("diag", u:getPoint(), veh.unit:getPoint()))
        end
        lines[#lines+1] = string.format("  veh %s type=%s state=%s dist=%s", tostring(id), tostring(veh.vehicleType), tostring(veh:getState()), dist)
    end
    if vcount == 0 then lines[#lines+1] = "  (no vehicles in CTLDVehicleSpawner)" end
end

return table.concat(lines, "\n")
