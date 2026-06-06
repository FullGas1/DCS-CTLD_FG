---@diagnostic disable
-- Diag MT-12 : trace bbox + position theorique de spawn rear sector
local u = Unit.getByName("heliai_mt12")
if not u or not u:isExist() then return "heliai_mt12 NOT FOUND" end

local vs = CTLDVehicleSpawner.getInstance()
local r  = {}

local pt = u:getPoint()
r[#r+1] = "heliPos=(" .. math.floor(pt.x) .. "," .. math.floor(pt.z) .. ")"
r[#r+1] = "inAir=" .. tostring(u:inAir())

-- Bounding box
local okB, box = pcall(function() return u:getDesc().box end)
if okB and box then
    local hL = math.max(math.abs(box.max.x), math.abs(box.min.x))
    local hW = math.max(math.abs(box.max.z), math.abs(box.min.z))
    local diag = math.sqrt(hL * hL + hW * hW)
    r[#r+1] = string.format("bbox maxX=%.1f minX=%.1f maxZ=%.1f minZ=%.1f diag=%.1f offset=%.1f",
        box.max.x, box.min.x, box.max.z, box.min.z, diag, diag + 10)
else
    r[#r+1] = "bbox UNAVAILABLE"
end

-- Vehicles loaded
local loaded = vs:findLoadedVehicles(u)
r[#r+1] = "loadedVehicles=" .. #loaded
for i, veh in ipairs(loaded) do
    r[#r+1] = "  [" .. i .. "] id=" .. veh.id .. " type=" .. tostring(veh.vehicleType)
              .. " state=" .. tostring(veh:getState()) .. " method=" .. tostring(veh.loadMethod)
end

-- Compute expected rear-sector spawn (no actual spawn)
if #loaded > 0 then
    local hdg = ctld.utils.getHeadingInRadians("diag", u, true)
    local offset = 40
    if okB and box then
        local hL = math.max(math.abs(box.max.x), math.abs(box.min.x))
        local hW = math.max(math.abs(box.max.z), math.abs(box.min.z))
        offset = math.sqrt(hL * hL + hW * hW) + 10
    end
    local rearHdg = hdg + math.pi
    local sx = pt.x + math.cos(rearHdg) * offset
    local sz = pt.z + math.sin(rearHdg) * offset
    r[#r+1] = string.format("hdg=%.2frad(%.0fdeg) rearHdg=%.2frad offset=%.1fm",
        hdg, math.deg(hdg), rearHdg, offset)
    r[#r+1] = string.format("expectedSpawn=(%.0f,%.0f) delta=(%.0f,%.0f)",
        sx, sz, sx - pt.x, sz - pt.z)
end

return table.concat(r, " | ")
