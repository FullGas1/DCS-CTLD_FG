---@diagnostic disable
-- Diag: verify ctld.utils.spawnAs covers all 5 former direct call patterns.
-- Each test spawns a real DCS object 20-50 m ahead of the helicopter and checks
-- the returned object is non-nil, then destroys it immediately.

local transport = coalition.getPlayers(coalition.side.BLUE)
transport = transport and transport[1]
if not transport then return "FAIL: no BLUE player" end

local pt      = transport:getPoint()
local hdg     = ctld.utils.getHeadingInRadians("diag", transport, true)
local cId     = transport:getCountry()
local results = {}

local function pos(dist)
    local nx = pt.x + math.cos(hdg) * dist
    local nz = pt.z + math.sin(hdg) * dist
    return nx, nz, land.getHeight({x=nx, y=nz})
end

-- ── 1. Former: coalition.addStaticObject (dynAddStatic path) ───────────────
-- spawnAs("STATIC", ...)
do
    local nx, nz = pos(20)
    local ok, obj = ctld.utils.spawnAs("STATIC", cId, {
        name = "diag_iso_static_1", type = "Sandbag_09",
        x = nx, y = nz, heading = 0, start_time = 0,
        transportable = { randomTransportable = false },
    })
    if ok and obj then
        pcall(function() obj:destroy() end)
        table.insert(results, "1-STATIC(string): OK")
    else
        table.insert(results, "1-STATIC(string): FAIL ok=" .. tostring(ok))
    end
end

-- ── 2. Former: coalition.addStaticObject with shape_name (fobScene path) ───
do
    local nx, nz = pos(25)
    local ok, obj = ctld.utils.spawnAs("STATIC", cId, {
        name = "diag_iso_static_2", type = "Carrier LSO Personell 2",
        shape_name = "carrier_lso2_usa",
        x = nx, y = nz, heading = 0, start_time = 0,
        transportable = { randomTransportable = false },
    })
    if ok and obj then
        pcall(function() obj:destroy() end)
        table.insert(results, "2-STATIC(shape): OK")
    else
        table.insert(results, "2-STATIC(shape): FAIL ok=" .. tostring(ok))
    end
end

-- ── 3. Former: coalition.addGroup GROUND string (troop path) ───────────────
do
    local nx, nz = pos(30)
    local ok, grp = ctld.utils.spawnAs("GROUND", cId, {
        name = "diag_iso_grp_GROUND", task = "Ground Nothing",
        units = {{ name = "diag_iso_u1", type = "Soldier M4",
                   x = nx, y = nz, heading = 0, skill = "Average" }},
    })
    if ok and grp then
        pcall(function() grp:destroy() end)
        table.insert(results, "3-GROUND(string): OK")
    else
        table.insert(results, "3-GROUND(string): FAIL ok=" .. tostring(ok))
    end
end

-- ── 4. Former: coalition.addGroup integer (objectRegistry path) ────────────
-- desc.category = Group.Category.GROUND = 2
do
    local nx, nz = pos(37)
    local ok, grp = ctld.utils.spawnAs(Group.Category.GROUND, cId, {
        name = "diag_iso_grp_int", task = "Ground Nothing",
        units = {{ name = "diag_iso_u2", type = "Soldier M4",
                   x = nx, y = nz, heading = 0, skill = "Average" }},
    })
    if ok and grp then
        pcall(function() grp:destroy() end)
        table.insert(results, "4-GROUND(int=2): OK")
    else
        table.insert(results, "4-GROUND(int=2): FAIL ok=" .. tostring(ok))
    end
end

-- ── 5. spawnFromDescriptor wrapper (descriptor.spawnAs path) ───────────────
do
    local nx, nz = pos(44)
    local ok, obj = ctld.utils.spawnFromDescriptor(
        { spawnAs = "STATIC" }, cId,
        {
            name = "diag_iso_desc_static", type = "Sandbag_09",
            x = nx, y = nz, heading = 0, start_time = 0,
            transportable = { randomTransportable = false },
        })
    if ok and obj then
        pcall(function() obj:destroy() end)
        table.insert(results, "5-spawnFromDescriptor: OK")
    else
        table.insert(results, "5-spawnFromDescriptor: FAIL ok=" .. tostring(ok))
    end
end

return table.concat(results, " | ")
