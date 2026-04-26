-- scenarios/scenario_troop_jtac.lua
-- Injectable scenario: ground JTAC troop auto-lase cycle
--
-- Pre-requisites:
--   - Enemy group "Sol_g-2" must exist in the mission (unit "Sol_g-2-1")
--   - A loadableGroup with jtac >= 1 must be configured (default: "JTAC Group")
--
-- Sequence:
--   T+0s  : (0) cleanup any existing JTAC troop groups (avoid confusion)
--            (1) spawn JTAC troop group 100m from current enemy position
--                → call CTLDJTACManager:startLase() (autoLase at T+1s)
--   T+8s  : VERIFY 1 — JTAC lasing the enemy (currentTarget set)
--   T+15s : (3) move enemy group 30km north (LOS lost)
--   T+35s : VERIFY 2 — target lost (currentTarget=nil)

local ENEMY_GROUP   = "Sol_g-2"
local SPAWN_OFFSET  =  100    -- 100m north of enemy
local OFFSET_FAR    = 30000   -- 30km north for target lost

-- ── helpers ──────────────────────────────────────────────────────────────────

local function report(msg)
    trigger.action.outText("[JTAC-TROOP] " .. msg, 25)
    ctld.utils.log("INFO", "[scenario_troop_jtac] " .. msg)
end

local function moveGroupByDx(groupName, dx)
    local grp = Group.getByName(groupName)
    if not grp or not grp:isExist() then return nil end
    local u = grp:getUnit(1)
    if not u or not u:isExist() then return nil end
    local pos    = u:getPoint()
    local cntry  = u:getCountry()
    local utype  = u:getTypeName()
    local uname  = u:getName()
    local gname  = grp:getName()
    grp:destroy()
    local nx = pos.x + dx
    coalition.addGroup(cntry, Group.Category.GROUND, {
        id = ctld.utils.getNextUniqId(), name = gname, task = "Ground Nothing", start_time = 0,
        units = {{ id = ctld.utils.getNextUniqId(), name = uname, type = utype,
                   x = nx, y = pos.z, heading = 0, skill = "Average", playerCanDrive = false }},
        route = { points = {{ x = nx, y = pos.z, type = "Turning Point",
                               action = "Off Road", speed = 0, alt = pos.y }}},
    })
    return pos
end

-- ── 0. cleanup existing ground JTACs ────────────────────────────────────────

local jmgr = CTLDJTACManager.get()
local tmgr = CTLDTroopManager.getInstance()

-- Build set of JTAC-template keys for quick lookup
local jtacKeys = {}
for _, t in ipairs(tmgr._templates) do
    if t.hasJtac then jtacKeys[t._dbKey] = true end
end

local removed = 0

-- (a) Kill entries still tracked by CTLDJTACManager (ground only)
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

-- (b) Destroy any troop groups that used a JTAC template (may have lost their jtacs entry)
for coa = 1, 2 do
    local alive = {}
    for _, gname in ipairs(tmgr._droppedGroups[coa]) do
        local tmplKey = tmgr._droppedTemplates[gname]
        if jtacKeys[tmplKey] then
            local dg = Group.getByName(gname)
            if dg and dg:isExist() then dg:destroy() end
            tmgr._droppedTemplates[gname] = nil
            -- also remove from jmgr if still lurking
            jmgr.jtacs[gname] = nil
            removed = removed + 1
        else
            table.insert(alive, gname)
        end
    end
    tmgr._droppedGroups[coa] = alive
end

report(string.format("Step 0: cleanup done (%d ground JTAC group(s) removed)", removed))

-- ── 1. find JTAC template ────────────────────────────────────────────────────

local jtacTmpl = nil
for _, t in ipairs(tmgr._templates) do
    if t.hasJtac then jtacTmpl = t; break end
end
if not jtacTmpl then
    return "ABORT: no loadableGroup with hasJtac=true — add jtac>=1 to loadableGroups config"
end

-- ── 2. get enemy position and spawn JTAC troop nearby ───────────────────────

local enemyGrp = Group.getByName(ENEMY_GROUP)
if not enemyGrp or not enemyGrp:isExist() then
    return "ABORT: enemy group not found: " .. ENEMY_GROUP
end
local enemyUnit = enemyGrp:getUnit(1)
if not enemyUnit or not enemyUnit:isExist() then
    return "ABORT: no unit in group: " .. ENEMY_GROUP
end
local epos = enemyUnit:getPoint()

local spawnX = epos.x + SPAWN_OFFSET
local spawnZ = epos.z

local dcsGroup = CTLDObjectRegistry.spawnObject(
    jtacTmpl._dbKey,
    coalition.side.BLUE,
    country.id.USA,
    spawnX, spawnZ, 0
)
if not dcsGroup then
    return "ABORT: CTLDObjectRegistry.spawnObject failed for key: " .. tostring(jtacTmpl._dbKey)
end

local jtacGroupName = dcsGroup:getName()

-- Register in troop manager (mirrors CTLDTroopManager:deploy())
table.insert(tmgr._droppedGroups[coalition.side.BLUE], jtacGroupName)
tmgr._droppedTemplates[jtacGroupName] = jtacTmpl._dbKey

-- Start auto-lase (schedules autoLase at T+1s internally)
jmgr:startLase(jtacGroupName)

report(string.format(
    "Step 1: JTAC troop '%s' spawned 100m from '%s' @ (%.0f,%.0f) — startLase called",
    jtacGroupName, ENEMY_GROUP, spawnX, spawnZ))

-- ── T+15s: VERIFY 1 — JTAC lasing enemy ─────────────────────────────────────
-- (autoLase starts at T+1s; searchInterval=10s → target acquired by T+11s at most)

timer.scheduleFunction(function()
    local jtac = CTLDJTACManager.get().jtacs[jtacGroupName]
    if not jtac then
        report("VERIFY 1 FAIL — JTAC entry not found in manager"); return
    end
    if jtac.currentTarget then
        report(string.format("VERIFY 1 PASS — lasing '%s' | state=%s",
            jtac.currentTarget.unitName, tostring(jtac.state)))
    else
        report(string.format("VERIFY 1 FAIL — no target yet | state=%s", tostring(jtac.state)))
    end
end, nil, timer.getTime() + 15)

-- ── T+45s: move enemy 30km north ─────────────────────────────────────────────
-- (30s to observe lasing in action)

timer.scheduleFunction(function()
    moveGroupByDx(ENEMY_GROUP, OFFSET_FAR)
    report("Step 3: '" .. ENEMY_GROUP .. "' moved 30km north — expect target lost")
end, nil, timer.getTime() + 45)

-- ── T+80s: VERIFY 2 — target lost ────────────────────────────────────────────
-- (laseInterval=15s → 2 loop ticks after move → target lost detected by T~75s)

timer.scheduleFunction(function()
    local jtac = CTLDJTACManager.get().jtacs[jtacGroupName]
    if not jtac then
        report("VERIFY 2 INFO — JTAC entry gone (soldier dead?)"); return
    end
    if not jtac.currentTarget then
        report(string.format("VERIFY 2 PASS — target lost confirmed | state=%s", tostring(jtac.state)))
    else
        report(string.format("VERIFY 2 FAIL — still lasing '%s' | state=%s",
            jtac.currentTarget.unitName, tostring(jtac.state)))
    end
end, nil, timer.getTime() + 80)

-- ── return ────────────────────────────────────────────────────────────────────

return string.format("scenario_troop_jtac started | tmpl='%s' | jtac='%s' | enemy @ (%.0f,%.0f)",
    jtacTmpl.name, jtacGroupName, epos.x, epos.z)
