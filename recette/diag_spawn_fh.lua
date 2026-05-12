---@diagnostic disable
-- Diag: spawn fh3 type in front of helicopter using exact mission descriptor params
local transport = coalition.getPlayers(coalition.side.BLUE)
transport = transport and transport[1]
if not transport then return "FAIL: no BLUE player" end

local pt  = transport:getPoint()
local hdg = ctld.utils.getHeadingInRadians("diag", transport, true)
local nx  = pt.x + math.cos(hdg) * 20
local nz  = pt.z + math.sin(hdg) * 20

-- Attempt 1: addStaticObject with shape_name (exact mission descriptor)
local ok1, obj1 = pcall(coalition.addStaticObject, transport:getCountry(), {
    name          = "diag_fh_test_A",
    type          = "Carrier LSO Personell 2",
    shape_name    = "carrier_lso2_usa",
    x             = nx,
    y             = nz,
    heading       = hdg,
    start_time    = 0,
    transportable = { randomTransportable = false },
})
local r1 = "A(Static+shape): ok=" .. tostring(ok1) .. " obj=" .. tostring(obj1 ~= nil)

-- Attempt 2: addGroup as Infantry group
local countryId = transport:getCountry()
local coalId    = transport:getCoalition()
local ok2, grp2 = pcall(coalition.addGroup, countryId, Group.Category.GROUND, {
    name  = "diag_fh_grp_B",
    task  = "Ground Nothing",
    units = {
        { name = "diag_fh_unit_B1", type = "Carrier LSO Personell 2",
          x = nx + 3, y = nz, heading = hdg, skill = "Average", },
    },
    x = nx + 3, y = nz,
})
local r2 = "B(addGroup): ok=" .. tostring(ok2) .. " grp=" .. tostring(grp2 ~= nil)

return r1 .. " | " .. r2
