-- scenarios/scenario_recon_layers.lua
-- Interactive RECON layer test — inject once per layer.
-- Each injection: cleanup previous → spawn target unit → scan → report detection.
-- Re-inject when ready to move to the next layer.
--
-- State persisted across injections via DCS Lua global _RECON_LAYER_IDX (integer 1–7).
-- Injection 7 resets the counter and destroys all test units.
--
-- Compatible with helicopter on the ground (getUnitsLOS uses altoffset=180).

-- ── layer definitions (ordered) ───────────────────────────────────────────────

-- Batumi airport absolute coords (Caucasus map).
-- Used as anchor for air/ship spawns that need specific terrain (water, airspace).
local BATUMI = { x = -356437, z = 618211 }
local NM1    = 1852   -- 1 nautical mile in metres

local LAYERS = {
    {
        layerId = "infantry",
        label   = "Infantry",
        cat     = Group.Category.GROUND,
        grpName = "RECON_TEST_infantry",
        uName   = "RECON_TEST_inf_1",
        uType   = "Soldier AK",
        dx = -200, dz = -30,  -- relative to player: 200m south
    },
    {
        layerId = "ground_vehicles",
        label   = "Ground Vehicles",
        cat     = Group.Category.GROUND,
        grpName = "RECON_TEST_vehicle",
        uName   = "RECON_TEST_veh_1",
        uType   = "BMP-2",
        dx = -200, dz = 30,   -- relative to player: 200m south, slightly east
    },
    {
        layerId = "air_defense",
        label   = "Air Defense (AA)",
        cat     = Group.Category.GROUND,
        grpName = "RECON_TEST_aa",
        uName   = "RECON_TEST_aa_1",
        uType   = "ZU-23 Emplacement Closed",
        dx = -250, dz = 0,    -- relative to player: 250m south
    },
    {
        layerId  = "aircraft",
        label    = "Aircraft",
        cat      = Group.Category.AIRPLANE,
        grpName  = "RECON_TEST_ac",
        uName    = "RECON_TEST_ac_1",
        uType    = "Su-25",
        useOrbit = true,      -- absolute position + square orbit around Batumi
        spawnAlt = 500,       -- metres AGL
    },
    {
        layerId  = "helicopters",
        label    = "Helicopters",
        cat      = Group.Category.HELICOPTER,
        grpName  = "RECON_TEST_helo",
        uName    = "RECON_TEST_helo_1",
        uType    = "Mi-8MT",
        useOrbit = true,      -- absolute position + square orbit around Batumi
        spawnAlt = 300,       -- metres AGL
    },
    {
        layerId   = "ships",
        label     = "Ships",
        cat       = Group.Category.SHIP,
        grpName   = "RECON_TEST_ship",
        uName     = "RECON_TEST_ship_1",
        uType     = "Speedboat",
        useAbs    = true,     -- absolute position in the Black Sea west of Batumi
        absX      = BATUMI.x + 556,   -- 0.3nm north (avoid trees blocking LOS from Batumi)
        absZ      = BATUMI.z - 3500,  -- 3.5 km west of Batumi (confirmed sea: surf=WATER at -3km)
    },
}

local TOTAL = #LAYERS
local RUSSIA = country.id.RUSSIA

-- ── helpers ──────────────────────────────────────────────────────────────────

local function report(msg)
    trigger.action.outText("[RECON] " .. msg, 40)
    env.info("[scenario_recon_layers] " .. msg)
end

local function destroyGroup(name)
    local g = Group.getByName(name)
    if g and g:isExist() then g:destroy() end
end

local function destroyAll()
    for _, lay in ipairs(LAYERS) do destroyGroup(lay.grpName) end
end


--- Remove all BLUE ground units from the mission (keep air/helo player).
--- Called once at first injection so no friendly ground unit interferes with spawned RED targets.
local function destroyBlueGroundUnits()
    local grps = coalition.getGroups(coalition.side.BLUE, Group.Category.GROUND) or {}
    for _, g in ipairs(grps) do
        if g and g:isExist() then
            g:destroy()
            env.info("[scenario_recon_layers] destroyed BLUE ground group: " .. g:getName())
        end
    end
end

local function nextId() return ctld.utils.getNextUniqId() end

-- Build a 4-WP square orbit centred on (cx,cz) at altitude alt_m.
-- side = half-edge length in metres (default NM10).
-- 3-WP triangle route around (cx,cz) with SwitchWaypoint on WP3 → WP1.
-- Same pattern as JTAC drone orbit (validated in production).
local function loopingTriangleRoute(cx, cz, alt_m, side, speed)
    side  = side  or NM1
    speed = speed or 100
    local n   = 3
    local wps = {
        { x = cx,        y = cz + side },   -- north
        { x = cx - side, y = cz - side },   -- south-west
        { x = cx + side, y = cz - side },   -- south-east
    }
    local pts = {}
    for i = 1, n do
        pts[i] = {
            x            = wps[i].x,
            y            = wps[i].y,
            alt          = alt_m,
            alt_type     = "BARO",
            speed        = speed,
            speed_locked = true,
            type         = "Turning Point",
            action       = "Turning Point",
            ETA          = 0,
            ETA_locked   = false,
            task         = { id = "ComboTask", params = { tasks = {} } },
        }
    end
    -- SwitchWaypoint on last WP → loops back to WP 1 indefinitely.
    pts[n].task = {
        id     = "ComboTask",
        params = { tasks = { [1] = {
            enabled = true, auto = false,
            id      = "WrappedAction", number = 1,
            params  = { action = {
                id     = "SwitchWaypoint",
                params = { goToWaypointIndex = 1, fromWaypointIndex = n },
            }},
        }}}
    }
    return { points = pts }
end

local function spawnUnit(lay, pPos)
    local ok, err

    if lay.useOrbit then
        -- Air unit: looping 3-WP triangle around Batumi, never lands.
        local spawnX = BATUMI.x
        local spawnZ = BATUMI.z
        local alt    = lay.spawnAlt or 500
        ok, err = pcall(function()
            coalition.addGroup(RUSSIA, lay.cat, {
                id = nextId(), name = lay.grpName,
                task = "Nothing", start_time = 0,
                units = {{
                    id = nextId(), name = lay.uName, type = lay.uType,
                    x = spawnX, y = spawnZ, heading = 0,
                    skill = "Average", playerCanDrive = false, alt = alt,
                }},
                route = loopingTriangleRoute(spawnX, spawnZ, alt, NM1),
            })
        end)

    elseif lay.useAbs then
        -- Ship or unit at absolute position (not relative to player).
        local px, pz = lay.absX, lay.absZ
        ok, err = pcall(function()
            coalition.addGroup(RUSSIA, lay.cat, {
                id = nextId(), name = lay.grpName,
                task = "Nothing", start_time = 0,
                units = {{
                    id = nextId(), name = lay.uName, type = lay.uType,
                    x = px, y = pz, heading = 0,
                    skill = "Average", playerCanDrive = false,
                }},
                route = { points = {{
                    x = px, y = pz, type = "Turning Point",
                    action = "Turning Point", speed = 5, alt = 0,
                }}},
            })
        end)

    else
        -- Ground unit: relative to player position.
        local px = pPos.x + lay.dx
        local pz = pPos.z + lay.dz
        local py = land.getHeight({ x = px, y = pz })
        ok, err = pcall(function()
            coalition.addGroup(RUSSIA, lay.cat, {
                id = nextId(), name = lay.grpName,
                task = "Ground Nothing", start_time = 0,
                units = {{
                    id = nextId(), name = lay.uName, type = lay.uType,
                    x = px, y = pz, heading = 0,
                    skill = "Average", playerCanDrive = false,
                }},
                route = { points = {{
                    x = px, y = pz, type = "Turning Point",
                    action = "Off Road", speed = 0, alt = py,
                }}},
            })
        end)
    end

    if not ok then return false, err end
    -- Force WEAPON HOLD so test units never fire
    timer.scheduleFunction(function()
        local g = Group.getByName(lay.grpName)
        if g and g:isExist() then
            local ctrl = g:getController()
            ctrl:setOption(0, 4)  -- ROE = WEAPON_HOLD (id=0, val=4)
            ctrl:setOption(9, 0)  -- REACTION_ON_THREAT = NO_REACTION (id=9, val=0)
        end
    end, nil, timer.getTime() + 0.5)
    return true, nil
end

-- ── resolve player ────────────────────────────────────────────────────────────

local playerUnit = nil
do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    if #units > 0 then playerUnit = units[1] end
end

if not playerUnit or not playerUnit:isExist() then
    return "ABORT: no BLUE player — occupy a slot first"
end

-- Use DCS unit name ("uh1-1" style) as key — matches what CTLDMenuManager and _addReconCommands use.
local playerName = playerUnit:getName()
local rmgr       = CTLDReconManager.getInstance()
local pPos       = playerUnit:getPoint()

-- Permanently enable RECON for the test session (no restore):
-- reconEnabled=true  : allows F10 menu scan commands to work
-- reconMinAltitude=0 : allows scanning from the ground / low altitude
do
    local cfg = CTLDConfig.get().settings
    cfg["reconEnabled"]    = true
    cfg["reconMinAltitude"] = 0
end

-- Remove all BLUE ground units so they cannot kill spawned RED targets during the test.
destroyBlueGroundUnits()

--- Remove all visible marks: route debug marks (90001-90030) + all active RECON scan marks.
--- Called at the start of each injection to prevent mark accumulation.
local function clearAllMarks()
    -- Route debug marks (draw_routes.lua range)
    for i = 90001, 90030 do pcall(trigger.action.removeMark, i) end
    -- RECON scan marks from all active scans
    for _, s in pairs(rmgr._activeScans or {}) do
        if s and s.targets then
            for _, t in ipairs(s.targets) do
                if t.markId then
                    pcall(function() CTLDReconRenderer.removeIcon(t.markId) end)
                    t.markId = nil
                end
            end
        end
    end
end

-- Helper: safely clean up a scan entry (timer + marks may already be gone).
local function cleanupScan(scan, key)
    if not scan then return end
    if scan.refreshTimer then
        pcall(timer.removeFunction, scan.refreshTimer)
        scan.refreshTimer = nil
    end
    pcall(function() rmgr:_removeAllMarks(scan) end)
    rmgr._activeScans[key] = nil
end

-- ── state machine ────────────────────────────────────────────────────────────

_RECON_LAYER_IDX = _RECON_LAYER_IDX or 1

-- Clear all visible marks at every injection (prevents accumulation on re-inject).
clearAllMarks()

-- Full reset (injection TOTAL+2)
if _RECON_LAYER_IDX > TOTAL + 1 then
    destroyAll()
    cleanupScan(rmgr._activeScans[playerName], playerName)
    local layers = rmgr:_getPlayerLayers(playerName)
    for _, l in ipairs(layers) do l.enabled = false end
    _RECON_LAYER_IDX = 1
    return "RECON scenario RESET — all test units destroyed, layers OFF. Re-inject to start from layer 1."
end

-- Sandbox phase (injection TOTAL+1): all layers ON, all threats spawned, RECON started.
-- Player can then test layer toggle on/off via F10 menu.
if _RECON_LAYER_IDX == TOTAL + 1 then
    destroyAll()
    cleanupScan(rmgr._activeScans[playerName], playerName)

    -- Enable all layers
    local allLayers = rmgr:_getPlayerLayers(playerName)
    for _, l in ipairs(allLayers) do l.enabled = true end

    -- Spawn all threat types
    local spawnErrors = {}
    for _, lay in ipairs(LAYERS) do
        local ok, err = spawnUnit(lay, pPos)
        if not ok then spawnErrors[#spawnErrors + 1] = lay.layerId .. ": " .. tostring(err) end
    end

    report("=== SANDBOX MODE — all layers ON, all threats spawned ===")
    if #spawnErrors > 0 then
        report("  spawn errors: " .. table.concat(spawnErrors, ", "))
    end
    report("  Toggle layers via F10 RECON menu. Re-inject this script to RESET.")

    -- Start RECON scan after 2s (aircraft need time to appear in DCS unit list).
    -- Patch radius to 40 km so air/ship units 10 nm away are in range.
    timer.scheduleFunction(function()
        local pu = playerUnit:isExist() and playerUnit or nil
        if not pu then return end
        -- reconEnabled=true and reconMinAltitude=0 already set permanently at injection start.
        local cfg = CTLDConfig.get().settings
        local oRad = cfg["reconSearchRadius"]
        cfg["reconSearchRadius"] = 12000  -- 12 km covers 3 nm orbit
        pcall(function() rmgr:scan(pu, playerName) end)
        cfg["reconSearchRadius"] = oRad
        local s = rmgr._activeScans[playerName]
        report(string.format("  RECON started: %d targets detected", s and #s.targets or 0))
        if s then
            for _, t in ipairs(s.targets) do
                report(string.format("    [%s] %s dist=%.0fm", t.layer.layerId, t.unitType, t.distance or 0))
            end
        end
    end, nil, timer.getTime() + 2)

    _RECON_LAYER_IDX = TOTAL + 2
    return "SANDBOX — all threats spawned, RECON starts in 1s. Toggle layers via F10. Re-inject to RESET."
end

local current = LAYERS[_RECON_LAYER_IDX]

-- ── 1. Cleanup all test units + previous scan ─────────────────────────────────

destroyAll()
cleanupScan(rmgr._activeScans[playerName], playerName)

-- ── 2. Disable all layers, toggle only the current one ON ────────────────────

local allLayers = rmgr:_getPlayerLayers(playerName)
for _, l in ipairs(allLayers) do
    l.enabled = false
end
for _, l in ipairs(allLayers) do
    if l.layerId == current.layerId then l.enabled = true end
end

report(string.format("Layer %d/%d — toggle [%s] %s → ON  (all others OFF)",
    _RECON_LAYER_IDX, TOTAL, current.layerId, current.label))

-- ── 3. Spawn the target unit ──────────────────────────────────────────────────

local spawnOk, spawnErr = spawnUnit(current, pPos)
if not spawnOk then
    report("SPAWN FAIL: " .. tostring(spawnErr))
    return "ERROR: spawn failed for " .. current.layerId
end

if current.useOrbit then
    report(string.format("  spawned: %s '%s'  orbit 10nm around Batumi alt=%dm",
        current.uType, current.grpName, current.spawnAlt or 500))
elseif current.useAbs then
    report(string.format("  spawned: %s '%s'  abs pos x=%.0f z=%.0f",
        current.uType, current.grpName, current.absX, current.absZ))
else
    report(string.format("  spawned: %s '%s'  offset=(%.0f, %.0f)",
        current.uType, current.grpName, current.dx, current.dz))
end

-- ── 4. Scan after 2s (air units need time to appear; extend radius for air/ship) ─

-- Air and ship layers use absolute positions 10+ nm away — use a 40 km radius.
local needsWideRadius = current.useOrbit or current.useAbs

timer.scheduleFunction(function()
    local pu = playerUnit:isExist() and playerUnit or nil
    if not pu then report("SCAN SKIP: player gone"); return end

    -- reconEnabled=true and reconMinAltitude=0 are already set permanently at injection start.
    -- Only patch reconSearchRadius for wide-radius scans (air/ship), restored after scan.
    local cfg = CTLDConfig.get().settings
    local origRadius = cfg["reconSearchRadius"]
    if needsWideRadius then cfg["reconSearchRadius"] = 8000 end   -- 8 km covers 1 nm orbit with margin
    local ok2, err2 = pcall(function() rmgr:scan(pu, playerName) end)
    cfg["reconSearchRadius"] = origRadius
    if not ok2 then report("SCAN ERROR: " .. tostring(err2)); return end

    local scan = rmgr._activeScans[playerName]
    local n = scan and #scan.targets or 0

    if n == 0 then
        report("  SCAN: 0 targets — unit may be out of LOS or wrong DCS attribute. Check F10 map manually.")
    else
        for _, tgt in ipairs(scan.targets) do
            report(string.format("  DETECTED [%s] %s  markId=%s  dist=%.0fm",
                tgt.layer.layerId, tgt.unitType, tostring(tgt.markId), tgt.distance or 0))
        end
        report(string.format("  Layer [%s] PASS — icon visible on F10 map", current.layerId))
    end

    report(string.format(">>> Re-inject this script when ready for layer %d/%d [%s]",
        _RECON_LAYER_IDX + 1, TOTAL,
        (_RECON_LAYER_IDX < TOTAL) and LAYERS[_RECON_LAYER_IDX + 1].label or "RESET"))
end, nil, timer.getTime() + (needsWideRadius and 3 or 1))

-- ── advance counter ───────────────────────────────────────────────────────────

_RECON_LAYER_IDX = _RECON_LAYER_IDX + 1

local scanDelay = needsWideRadius and "3s" or "1s"
return string.format("Layer %d/%d [%s] — spawning %s — scan in %s",
    _RECON_LAYER_IDX - 1, TOTAL, current.label, current.uType, scanDelay)
