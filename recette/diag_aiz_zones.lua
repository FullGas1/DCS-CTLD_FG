-- Diagnostic: scan 8 directions from AIZ_mt10d for LOS-clear corridor at 1000m
local zm = CTLDZoneManager.getInstance()
local aizZone = zm._troopZones["AIZ_mt10d_B_D_G"]
if not aizZone then return "AIZ_mt10d_B_D_G not found" end

local A = aizZone:getCenter()
local offsetA = { x = A.x, y = A.y + 2, z = A.z }

local dirList = {
    {"N",0}, {"NE",45}, {"E",90}, {"SE",135},
    {"S",180}, {"SW",225}, {"W",270}, {"NW",315}
}
local results = {}

for _, d in ipairs(dirList) do
    local name, deg = d[1], d[2]
    local rad = math.rad(deg)
    local dist = 1000
    local Bx = A.x + math.sin(rad) * dist
    local Bz = A.z + math.cos(rad) * dist
    local By = land.getHeight({ x = Bx, y = Bz })
    local offsetB = { x = Bx, y = By + 2, z = Bz }
    local los = land.isVisible(offsetA, offsetB)
    local maxH = 0
    for i = 1, 9 do
        local t = i / 10
        local h = land.getHeight({ x = A.x + (Bx-A.x)*t, y = A.z + (Bz-A.z)*t })
        if h > maxH then maxH = h end
    end
    table.insert(results, string.format("%s:%s(max%.0fm)", name, tostring(los), maxH))
end

return string.format("AIZ y=%.1f | ", A.y) .. table.concat(results, " ")
