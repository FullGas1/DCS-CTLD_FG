-- Diagnostic: replicate AttackNearestEnemyOnLos from AIZ_livraison drop zone
-- Checks world.searchObjects + land.isVisible exactly as _assignPostSpawnTask does
-- AIZ_livraison_B_D_G is stored in _troopZones["livraison"]

local zm = CTLDZoneManager.getInstance()

-- Dump all troopZone keys to find the AIZ
local keys = {}
for k, _ in pairs(zm._troopZones) do table.insert(keys, k) end
trigger.action.outText("[DIAG] troopZone keys: " .. table.concat(keys, " | "), 20)

-- AIZ zones stored with full DCS name as key
local aizZone = zm._troopZones["AIZ_mt10d_B_D_G"]
if not aizZone then
    return "[DIAG] ERROR: key 'AIZ_mt10d_B_D_G' not in _troopZones. Keys: " .. table.concat(keys, " | ")
end

local spawnPt = aizZone:getCenter()
trigger.action.outText(string.format(
    "[DIAG] Spawn origin: x=%.1f  z=%.1f  y=%.1f", spawnPt.x, spawnPt.z, spawnPt.y), 15)

-- Enemy coalition (BLUE deploying against RED)
local enemyCoa    = coalition.side.RED
local searchRadius = ctld.gs("maximumSearchDistance") or 3000

-- Elevate origin by 2m (same as _assignPostSpawnTask)
local offsetA = { x = spawnPt.x, y = spawnPt.y + 2, z = spawnPt.z }

local found = {}
world.searchObjects(
    Object.Category.UNIT,
    { id = world.VolumeType.SPHERE, params = { point = spawnPt, radius = searchRadius } },
    function(unit, _)
        if not unit:isExist() or unit:getLife() <= 1 then return true end
        if unit:getCoalition() ~= enemyCoa then return true end
        local uPos    = unit:getPoint()
        local offsetB = { x = uPos.x, y = uPos.y + 2, z = uPos.z }
        local los     = land.isVisible(offsetA, offsetB)
        local dist    = math.sqrt((spawnPt.x-uPos.x)^2 + (spawnPt.z-uPos.z)^2)
        table.insert(found, {
            name = unit:getName(),
            dist = dist,
            los  = los,
            x    = uPos.x,
            z    = uPos.z,
            y    = uPos.y,
        })
        return true
    end
)

trigger.action.outText(string.format(
    "[DIAG] searchRadius=%.0fm  RED units in range: %d", searchRadius, #found), 15)

-- Build result string for Witchcraft return
local lines = {}
table.insert(lines, string.format("origin x=%.1f z=%.1f y=%.1f radius=%.0fm RED_in_range=%d",
    spawnPt.x, spawnPt.z, spawnPt.y, searchRadius, #found))

for i, u in ipairs(found) do
    -- Also check terrain height at enemy position
    local terrainY = land.getHeight({ x = u.x, y = u.z })
    table.insert(lines, string.format("#%d %s dist=%.0fm LOS=%s y_unit=%.1f y_terrain=%.1f x=%.1f z=%.1f",
        i, u.name, u.dist, tostring(u.los), u.y, terrainY, u.x, u.z))
end

if #found == 0 then
    -- Wider search: confirm enemy position
    local wideFound = {}
    world.searchObjects(
        Object.Category.UNIT,
        { id = world.VolumeType.SPHERE, params = { point = spawnPt, radius = 50000 } },
        function(unit, _)
            if unit:getCoalition() == enemyCoa and unit:isExist() then
                local uPos = unit:getPoint()
                local dist = math.sqrt((spawnPt.x-uPos.x)^2 + (spawnPt.z-uPos.z)^2)
                table.insert(wideFound, { name=unit:getName(), dist=dist })
            end
            return true
        end
    )
    table.sort(wideFound, function(a,b) return a.dist < b.dist end)
    if #wideFound > 0 then
        local msgs = {}
        for _, u in ipairs(wideFound) do
            table.insert(msgs, u.name .. "=>" .. math.floor(u.dist) .. "m")
        end
        table.insert(lines, "NEAREST_RED(50km): " .. table.concat(msgs, " | "))
    else
        table.insert(lines, "NO_RED_IN_50km")
    end
end

return table.concat(lines, " || ")
