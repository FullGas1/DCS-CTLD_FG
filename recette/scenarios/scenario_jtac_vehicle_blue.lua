-- scenarios/scenario_jtac_vehicle.lua
-- Injectable scenario: JTAC ground vehicle auto-lase cycle
-- Mirrors the flow of CTLDCrateManager:_spawnUnpacked → _dispatchPostSpawn → startLase
--
-- Pre-requisites:
--   - Enemy group "Sol_g-2" must exist in the mission (unit "Sol_g-2-1")
--   - Config param: JTAC_dropEnabled = true (default)
--
-- Tested vehicles (isJTAC=true, legacy jtacUnitTypes parité):
--   BLUE : Hummer - JTAC   (weight=1001.01, unit="Hummer",  side=2)
--   RED  : SKP-11 - JTAC   (weight=1001.11, unit="SKP-11",  side=1)  — toggle USE_BLUE below
--
-- Sequence:
--   T+0s  : (0) cleanup existing ground JTACs; save enemy origin
--            (1) spawn JTAC vehicle 100m from enemy → startLase()
--   T+15s : VERIFY 1 — JTAC lasing the enemy (currentTarget set)
--   T+45s : (2) destroy enemy group (guarantees target lost regardless of terrain)
--   T+80s : VERIFY 2 — target lost (currentTarget=nil)
--   T+85s : restore enemy at original position

-- ── config ────────────────────────────────────────────────────────────────────

local ENEMY_GROUP  = "Sol_g-2"
local SPAWN_OFFSET = 100    -- 100m north of enemy

-- Toggle: true = BLUE Hummer, false = RED SKP-11
local USE_BLUE = true

local VEHICLE_WEIGHT = USE_BLUE and 1001.01 or 1001.11
local VEHICLE_COA    = USE_BLUE and coalition.side.BLUE or coalition.side.RED
local VEHICLE_CTY    = USE_BLUE and country.id.USA or country.id.RUSSIA

-- ── helpers ──────────────────────────────────────────────────────────────────

local function report(msg)
    trigger.action.outText("[JTAC-VEH] " .. msg, 25)
    ctld.utils.log("INFO", "[scenario_jtac_vehicle] " .. msg)
end

-- ── 0. cleanup existing ground JTACs ─────────────────────────────────────────

local jmgr = CTLDJTACManager.get()
local tmgr = CTLDTroopManager.getInstance()
local cmgr = CTLDCrateManager.getInstance()

local jtacKeys = {}
for _, t in ipairs(tmgr._templates) do
    if t.hasJtac then jtacKeys[t._dbKey] = true end
end

local removed = 0

-- (a) kill entries tracked in jmgr.jtacs (ground only)
local toKill = {}
for gname, jtac in pairs(jmgr.jtacs) do
    if not jtac.isFlying then table.insert(toKill, gname) end
end
for _, gname in ipairs(toKill) do
    local dg = Group.getByName(gname)
    if dg and dg:isExist() then dg:destroy() end
    jmgr:killJTAC(gname, nil)
    removed = removed + 1
end

-- (b) destroy troop-dropped JTAC groups
for coa = 1, 2 do
    local alive = {}
    for _, gname in ipairs(tmgr._droppedGroups[coa]) do
        local tmplKey = tmgr._droppedTemplates[gname]
        if jtacKeys[tmplKey] then
            local dg = Group.getByName(gname)
            if dg and dg:isExist() then dg:destroy() end
            tmgr._droppedTemplates[gname] = nil
            jmgr.jtacs[gname] = nil
            removed = removed + 1
        else
            table.insert(alive, gname)
        end
    end
    tmgr._droppedGroups[coa] = alive
end

-- (c) scan world for any CTLD_UNP_* groups not tracked anymore (orphans from crashed runs)
for _, coa in ipairs({ coalition.side.BLUE, coalition.side.RED }) do
    for _, grp in ipairs(coalition.getGroups(coa)) do
        local gname = grp:getName()
        if gname:find("^CTLD_UNP_") and grp:isExist() then
            grp:destroy()
            jmgr.jtacs[gname] = nil
            removed = removed + 1
        end
    end
end

report(string.format("Step 0: cleanup done (%d ground JTAC(s) removed)", removed))

-- ── save enemy origin ─────────────────────────────────────────────────────────

local enemyGrp = Group.getByName(ENEMY_GROUP)
if not enemyGrp or not enemyGrp:isExist() then
    return "ABORT: enemy group not found: " .. ENEMY_GROUP
end
local enemyUnit = enemyGrp:getUnit(1)
if not enemyUnit or not enemyUnit:isExist() then
    return "ABORT: no unit in group: " .. ENEMY_GROUP
end
local epos           = enemyUnit:getPoint()
local savedEnemyCntry = enemyUnit:getCountry()
local savedEnemyType  = enemyUnit:getTypeName()
local savedEnemyUName = enemyUnit:getName()
local savedEnemyGName = enemyGrp:getName()
local ox, oy, oz      = epos.x, epos.y, epos.z

-- ── 1. find descriptor and spawn JTAC vehicle ─────────────────────────────────

local desc = cmgr:findDescriptorByWeight(VEHICLE_WEIGHT)
if not desc then
    return string.format("ABORT: no descriptor for weight=%.2f", VEHICLE_WEIGHT)
end
if not desc.isJTAC then
    return string.format("ABORT: '%s' has no isJTAC=true", tostring(desc.desc))
end

local gid      = ctld.utils.getNextUniqId()
local uid      = ctld.utils.getNextUniqId()
local gname    = string.format("CTLD_UNP_%d", uid)
local spawnPos = { x = ox + SPAWN_OFFSET, y = oy, z = oz }

local unitDef  = ctld.utils.buildGroupUnitDef(desc, spawnPos, gname, gid, uid)
local ok, err  = ctld.utils.spawnFromDescriptor(desc, VEHICLE_CTY, unitDef)
if not ok then
    return string.format("ABORT: spawnFromDescriptor failed: %s", tostring(err))
end

-- Mirrors _dispatchPostSpawn
jmgr:startLase(gname)

report(string.format("Step 1: '%s' (%s) spawned 100m from '%s' @ (%.0f,%.0f) — startLase called",
    desc.desc, desc.unit, ENEMY_GROUP, spawnPos.x, spawnPos.z))

-- ── T+15s: VERIFY 1 — JTAC lasing enemy ──────────────────────────────────────

timer.scheduleFunction(function()
    local jtac = jmgr.jtacs[gname]
    if not jtac then
        report("VERIFY 1 FAIL — JTAC entry not found: " .. gname); return
    end
    if jtac.currentTarget then
        report(string.format("VERIFY 1 PASS — lasing '%s' | state=%s",
            jtac.currentTarget.unitName, tostring(jtac.state)))
    else
        report(string.format("VERIFY 1 FAIL — no target | state=%s", tostring(jtac.state)))
    end
end, nil, timer.getTime() + 15)

-- ── T+45s: destroy enemy (guaranteed target loss) ────────────────────────────

timer.scheduleFunction(function()
    local grp = Group.getByName(savedEnemyGName)
    if grp and grp:isExist() then grp:destroy() end
    report("Step 2: '" .. savedEnemyGName .. "' destroyed — JTAC should lose target")
end, nil, timer.getTime() + 45)

-- ── T+80s: VERIFY 2 — target lost ────────────────────────────────────────────

timer.scheduleFunction(function()
    local jtac = jmgr.jtacs[gname]
    if not jtac then
        report("VERIFY 2 INFO — JTAC entry gone"); return
    end
    if not jtac.currentTarget then
        report(string.format("VERIFY 2 PASS — target lost confirmed | state=%s", tostring(jtac.state)))
    else
        report(string.format("VERIFY 2 FAIL — still lasing '%s' | state=%s",
            jtac.currentTarget.unitName, tostring(jtac.state)))
    end
end, nil, timer.getTime() + 80)

-- ── T+85s: restore enemy at original position ────────────────────────────────

timer.scheduleFunction(function()
    coalition.addGroup(savedEnemyCntry, Group.Category.GROUND, {
        id = ctld.utils.getNextUniqId(), name = savedEnemyGName, task = "Ground Nothing", start_time = 0,
        units = {{ id = ctld.utils.getNextUniqId(), name = savedEnemyUName, type = savedEnemyType,
                   x = ox, y = oz, heading = 0, skill = "Average", playerCanDrive = false }},
        route = { points = {{ x = ox, y = oz, type = "Turning Point",
                               action = "Off Road", speed = 0, alt = oy }}},
    })
    report(string.format("Restore: '%s' back at (%.0f,%.0f)", savedEnemyGName, ox, oz))
end, nil, timer.getTime() + 85)

-- ── return ────────────────────────────────────────────────────────────────────

return string.format("scenario_jtac_vehicle started | '%s' | gname='%s' | enemy @ (%.0f,%.0f)",
    desc.desc, gname, ox, oz)
