-- Diagnostic: Sol_g-6-1 dans CTLDVehicleSpawner + findLoadableVehicles depuis AIZ_depot_B_P_V_10
CTLDCoreManager.getInstance():_initAITransports()
local vs  = CTLDVehicleSpawner.getInstance()
local result = {}

local byId = vs._vehicleById or {}
local count = 0
local solFound = false
for id, v in pairs(byId) do
    count = count + 1
    if string.find(string.lower(id), "sol_g", 1, true) then
        solFound = true
        table.insert(result, "FOUND: " .. id .. " type=" .. tostring(v.vehicleType) .. " state=" .. tostring(v.state))
    end
end
table.insert(result, "total_registered=" .. count)
if not solFound then table.insert(result, "Sol_g-6-1 NOT in _vehicleById") end

local zm = CTLDZoneManager.getInstance()
local zone = zm._troopZones["AIZ_depot_B_P_V_10"]
if zone then
    local fakeUnit = { getPoint = function() return zone:getCenter() end,
                       getCoalition = function() return coalition.side.BLUE end,
                       getTypeName = function() return "UH-1H" end,
                       getName = function() return "heliai_vehicle" end }
    local loadable = vs:findLoadableVehicles(fakeUnit)
    table.insert(result, "findLoadableVehicles=" .. #loadable)
end
return table.concat(result, " | ")
