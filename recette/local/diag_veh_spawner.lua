---@diagnostic disable
-- Diagnostic : état CTLDVehicleSpawner._vehicles
local spawner = CTLDVehicleSpawner.getInstance()
local player  = nil
do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    if #units > 0 then player = units[1] end
end
local pPos = player and player:getPoint() or {x=0,y=0,z=0}

local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
ctld.utils.log("INFO", string.format("Player pos: x=%.0f z=%.0f  maxDist=%d", pPos.x, pPos.z, maxDist))

local count = 0
for id, v in pairs(spawner._vehicles) do
    count = count + 1
    local state = v:getState()
    local unitOk = v.unit ~= nil and pcall(function() return v.unit:isExist() end)
    local uPos   = nil
    if v.unit then pcall(function() uPos = v.unit:getPoint() end) end
    local dist   = uPos and ctld.utils.getDistance("diag", pPos, uPos) or -1
    ctld.utils.log("INFO", string.format("  veh id=%s type=%s state=%s dist=%.0f unitOk=%s",
        id, v.vehicleType, state, dist, tostring(unitOk)))
end
ctld.utils.log("INFO", "Total vehicles in spawner: " .. count)
