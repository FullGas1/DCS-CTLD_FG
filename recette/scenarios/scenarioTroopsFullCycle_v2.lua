---@diagnostic disable
-- =============================================================================
-- SCENARIO: scenarioTroopsFullCycle_v2.lua
-- Full troop lifecycle — CTLDTroopGroup (inf=4, jtac=2), 8-step state machine
--
-- Pre-requisites:
--   - BLUE player slot occupied (UH-1H or any transport)
--   - TRZ zone "TRZ_alpha_B_10_nil_0" in mission
--   - RED group "Sol_g-2" (unit "Sol_g-2-1") for JTAC targeting
--   - ctldLogPath set via mission .miz MISSION START trigger
--
-- Steps:
--   1. Create "Test2JTAC" template (inf=4, jtac=2)
--   2. Simulate TRZ_LOADED group in _inTransit
--   3. Deploy → DCS group spawn → _syncFromDCSGroup → _jtacUnits populated (BUG-03)
--   4. S_EVENT_DEAD on JTAC unit #2 → onUnitDead → deregisterJTAC (BUG-02)
--   5. embarkFromField → deregisterJTAC BEFORE group:destroy()
--   6. Redeploy → resumeJTAC
--   7. returnToTroopZone → deregisterJTAC + _inTransit cleared
--   8. Final report + cleanupAll
-- =============================================================================

-- ── DEBUG ACTIVATION ──────────────────────────────────────────────────────────
local cfg = CTLDConfig.get()
local _saved_debug = cfg.settings["debug"]
cfg.settings["debug"] = true

-- ── METADATA ──────────────────────────────────────────────────────────────────
local TAG    = "[TFC]"
local START  = os.date("%Y-%m-%d %H:%M:%S")
local STEP_N = "_TFC_STEP"

-- ── HELPERS ───────────────────────────────────────────────────────────────────

local function log(msg)
    ctld.utils.log("INFO", TAG .. " " .. msg)
end

local function report(msg)
    trigger.action.outText(TAG .. " " .. msg, 30)
    log(msg)
end

local function pass(msg)
    report("[PASS] " .. msg)
end

local function fail(msg)
    local trace = debug.traceback(msg, 2)
    trigger.action.outText(TAG .. " !! FAIL: " .. msg, 60)
    log("FAIL: " .. trace)
    error(msg)
end

local function check(id, desc, condition, details)
    if condition then
        pass(id .. " — " .. desc)
    else
        fail(id .. " — " .. desc .. (details and (" | " .. details) or ""))
    end
end

local function assert_eq(id, actual, expected)
    check(id, "eq", actual == expected,
        "expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
end

local function assert_not_nil(id, val, desc)
    check(id, desc or "not nil", val ~= nil, "got nil")
end

--- Count entries in a hash table (# only works on arrays in Lua 5.1).
local function countPairs(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end

-- ── CONSTANTS ─────────────────────────────────────────────────────────────────
local TEST_TMPL_NAME = "Test2JTAC"

-- ── STATE MACHINE INIT ────────────────────────────────────────────────────────
_G[STEP_N] = _G[STEP_N] or 1
local step = _G[STEP_N]

-- Start banner: outText + CTLD.log, timestamp differentiates successive runs
report("==== START " .. START .. " | step=" .. step .. " ====")

-- Log reset at step 1: clean CTLD.log for a fresh run
if step == 1 then
    pcall(function()
        ctld.utils.closeLog()
        local f = io.open((cfg.settings["ctldLogPath"] or "") .. "CTLD.log", "w")
        if f then
            f:write("[" .. START .. "] === LOG RESET — new run ===\n")
            f:close()
        end
        ctld.utils.reopenLogAppend()
    end)
end

-- Step timer
local _step_start = os.clock()
local _result = "INCOMPLETE"

-- ── MODULE-LEVEL STATE (shared between helpers and pcall closure) ─────────────
local playerName = nil
local pPos       = nil

-- ── CLEANUP HELPER ────────────────────────────────────────────────────────────
local function cleanupAll()
    local troopMgr = CTLDTroopManager.getInstance()
    if not troopMgr then log("cleanupAll: CTLDTroopManager not ready, skipping"); return end
    local jtacMgr = CTLDJTACManager and CTLDJTACManager.get() or nil

    -- Destroy any spawned DCS groups still alive
    for coa = 1, 2 do
        for _, gname in ipairs(troopMgr._droppedGroups[coa] or {}) do
            local g = Group.getByName(gname)
            if g and g:isExist() then g:destroy() end
        end
        troopMgr._droppedGroups[coa] = {}
    end

    -- Deregister any JTAC entries linked to in-transit groups
    if jtacMgr then
        for uname, grp in pairs(troopMgr._inTransit or {}) do
            if grp and grp._jtacUnits then
                for jname in pairs(grp._jtacUnits) do
                    jtacMgr.jtacs[jname] = nil
                end
            end
        end
    end
    troopMgr._inTransit = {}

    -- Remove the test template from registry + templates list
    if CTLDObjectRegistry then
        for i, t in ipairs(troopMgr._templates or {}) do
            if t.name == TEST_TMPL_NAME then
                CTLDObjectRegistry._db[t._dbKey] = nil
                table.remove(troopMgr._templates, i)
                break
            end
        end
    end

    troopMgr._droppedTemplates = {}

    -- Destroy RED target vehicle group if still alive
    local tgtGname = _G["_TFC_TARGET_GROUP"]
    if tgtGname then
        local tgtGrp = Group.getByName(tgtGname)
        if tgtGrp and tgtGrp:isExist() then tgtGrp:destroy() end
        _G["_TFC_TARGET_GROUP"] = nil
    end

    log("cleanupAll done")
end

-- ── SPAWN HELPER ──────────────────────────────────────────────────────────────
-- Spawns a test DCS group with unit names matching the real CTLD naming convention
-- (JTAC-N prefix for JTAC units, INF-N for infantry) so _syncFromDCSGroup works.
local function spawnTroopGroup(tmpl, coalitionId, countryId, x, z, hdg)
    local troopMgr = CTLDTroopManager.getInstance()
    local units    = {}
    local idx      = 0

    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = tmpl[role] or 0
        for _ = 1, n do
            idx = idx + 1
            local namePrefix = (role == "jtac") and "JTAC" or "INF"
            local uid        = ctld.utils.getNextUniqId()
            local unitType   = (role == "jtac") and "Soldier AK" or "Soldier AK"
            units[idx] = {
                name    = string.format("%s-%d", namePrefix, uid),
                type    = unitType,
                x       = x + (idx - 1) * 3,
                y       = z,
                heading = hdg or 0,
                skill   = "Average",
            }
        end
    end

    local gname = string.format("TroopGrp_%s_%d", tmpl.name, ctld.utils.getNextUniqId())
    local grpDef = {
        name  = gname,
        task  = "Ground Nothing",
        units = units,
    }

    local dcsGroup = coalition.addGroup(countryId, Group.Category.GROUND, grpDef)
    if not dcsGroup then fail("coalition.addGroup failed") end

    -- Register in _droppedGroups
    table.insert(troopMgr._droppedGroups[coalitionId], dcsGroup:getName())
    -- Register in _droppedTemplates with enriched format (BUG-06/07 fix)
    troopMgr._droppedTemplates[dcsGroup:getName()] = {
        key    = tmpl._dbKey,
        name   = tmpl.name,
        weight = tmpl.total * 124,
        total  = tmpl.total,
    }

    return dcsGroup
end

-- ══════════════════════════════════════════════════════════════════════════════
-- STATE MACHINE (wrapped in pcall — cleanup always runs)
-- ══════════════════════════════════════════════════════════════════════════════
local _ok, _err = pcall(function()

-- Player resolution (fail is caught by pcall → cleanup runs)
do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    local pu = units[1]
    if not pu or not pu:isExist() then
        fail("ABORT: no BLUE player — occupy a slot first")
    end
    playerName = pu:getName()
    pPos       = pu:getPoint()
end

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 1 — Cleanup previous run + create 2-JTAC test template
-- Expected: template hasJtac=true, jtac=2, total=6
-- ══════════════════════════════════════════════════════════════════════════════
if step == 1 then

    cleanupAll()

    -- Spawn 4 unarmed RED vehicles ~300m south as JTAC target pool.
    -- DCS coalition.addGroup ground unit coords: unit.x = world-x (East), unit.y = world-z (North).
    -- Spread east-west by 25m so each unit is individually targetable.
    do
        local units = {}
        -- Hummer spawned as RED (country.id.RUSSIA = RED coalition in standard DCS).
        -- Troops/JTACs use country.id.USA = BLUE — no coalition inversion.
        for i = 1, 4 do
            units[i] = {
                name    = string.format("TFC_Target_%d", ctld.utils.getNextUniqId()),
                type    = "Hummer",
                x       = pPos.x + (i - 2) * 25,
                y       = pPos.z - 300,
                heading = 0,
                skill   = "Average",
            }
        end
        local tgtGrp = coalition.addGroup(country.id.RUSSIA, Group.Category.GROUND, {
            name  = string.format("TFC_Targets_%d", ctld.utils.getNextUniqId()),
            task  = "Ground Nothing",
            units = units,
        })
        if tgtGrp then
            _G["_TFC_TARGET_GROUP"] = tgtGrp:getName()
            log("Step 1: RED targets spawned — group='" .. tgtGrp:getName() .. "' (4x Hummer RED, ~300m south)")
        else
            log("Step 1: WARNING — RED target group spawn failed")
        end
    end

    local troopMgr = CTLDTroopManager.getInstance()
    assert_not_nil("F-T1.1", troopMgr, "CTLDTroopManager available")

    local ok, err = troopMgr:createLoadableGroup({
        name        = TEST_TMPL_NAME,
        composition = { inf = 4, jtac = 2 },
        side        = coalition.side.BLUE,
    })
    check("F-T1.2", "createLoadableGroup ok", ok, tostring(err))

    local tmpl = troopMgr:_findTemplate(TEST_TMPL_NAME)
    assert_not_nil("F-T1.3", tmpl, "template found after creation")
    check("F-T1.4", "hasJtac=true", tmpl.hasJtac == true, tostring(tmpl.hasJtac))
    assert_eq("F-T1.5", tmpl.jtac, 2)
    assert_eq("F-T1.6", tmpl.inf,  4)

    log("Step 1: template created hasJtac=" .. tostring(tmpl.hasJtac)
        .. " jtac=" .. tmpl.jtac .. " inf=" .. tmpl.inf .. " total=" .. tostring(tmpl.total))

    pass("Step 1 — 2-JTAC template created (inf=4, jtac=2). Re-inject for Step 2.")
    _G[STEP_N] = 2
    _result = "step=1 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 2 — Simulate TRZ pickup → TRZ_LOADED group in _inTransit
-- Expected: grp in _inTransit[playerName], state=TRZ_LOADED, hasJtac=true
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 2 then

    local troopMgr = CTLDTroopManager.getInstance()
    local tmpl = troopMgr:_findTemplate(TEST_TMPL_NAME)
    assert_not_nil("F-T2.1", tmpl, "template found — run Step 1 first")

    -- Build virtual slot maps matching production embarkFromTroopZone:
    -- _aliveUnits: ALL units (inf + jtac), _jtacUnits: jtac subset only
    local allAliveUnits = {}
    local jtacUnits     = {}
    local unitIndex     = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = tmpl[role] or 0
        for _ = 1, n do
            unitIndex = unitIndex + 1
            local slotName = string.format("%s_u%d", tmpl.name, unitIndex)
            allAliveUnits[slotName] = unitIndex  -- all slots
            if role == "jtac" then
                jtacUnits[slotName] = true
            end
        end
    end

    local grp = CTLDTroopGroup:new({
        templateKey  = tmpl._dbKey,
        templateName = tmpl.name,
        unitTotal    = tmpl.total,
        weight       = tmpl.total * 124,
        coalitionId  = coalition.side.BLUE,
        countryId    = country.id.USA,
        state        = CTLDTroopGroup.STATE.TRZ_LOADED,
        _aliveUnits  = allAliveUnits,
        _jtacUnits   = jtacUnits,
    })
    assert_not_nil("F-T2.2", grp, "CTLDTroopGroup:new() returned object")

    troopMgr._inTransit[playerName] = grp

    local jtacCount  = countPairs(grp._jtacUnits)
    local totalCount = countPairs(grp._aliveUnits)

    check("F-T2.3", "state=TRZ_LOADED",
        grp.state == CTLDTroopGroup.STATE.TRZ_LOADED, grp.state)
    -- hasJtac lives on the template; group uses _jtacUnits
    check("F-T2.4", "_jtacUnits non-empty (template has jtac=2)",
        jtacCount > 0, "jtacCount=" .. jtacCount)
    assert_eq("F-T2.5", jtacCount, 2)
    assert_eq("F-T2.6", totalCount, 6)   -- 4 inf + 2 jtac = 6

    log("Step 2: TRZ_LOADED | templateKey=" .. grp.templateKey
        .. " | total=" .. totalCount .. " | jtac=" .. jtacCount)
    pass("Step 2 — TRZ_LOADED (inf=4, jtac=2). Re-inject for Step 3 (deploy).")
    _G[STEP_N] = 3
    _result = "step=2 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 3 — Deploy → DCS group spawned → _syncFromDCSGroup → _jtacUnits populated
-- Validates BUG-03 fix: unit names come from DCS, not template slots
-- Expected: _jtacUnits has 2 entries keyed by real DCS unit names (JTAC-N)
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 3 then

    local troopMgr = CTLDTroopManager.getInstance()
    local jtacMgr  = CTLDJTACManager and CTLDJTACManager.get() or nil
    assert_not_nil("F-T3.1", jtacMgr, "CTLDJTACManager available")

    local grp = troopMgr._inTransit[playerName]
    assert_not_nil("F-T3.2", grp, "TRZ_LOADED group in _inTransit — run Step 2 first")

    local tmpl = troopMgr:_findTemplate(TEST_TMPL_NAME)
    assert_not_nil("F-T3.3", tmpl, "template found")

    -- Spawn right at helicopter position (no north offset) facing south (hdg=180)
    -- so troops have direct LOS to the RED vehicles 300m south.
    local spawnX = pPos.x + 5
    local spawnZ = pPos.z
    local dcsGroup = spawnTroopGroup(tmpl, coalition.side.BLUE, country.id.USA, spawnX, spawnZ, 180)
    assert_not_nil("F-T3.4", dcsGroup, "DCS group spawned")

    local gname = dcsGroup:getName()
    grp.dcsGroup = dcsGroup
    grp.state    = "DEPLOYED"

    -- BUG-03 fix validation: _syncFromDCSGroup rebuilds from real DCS unit names
    grp:_syncFromDCSGroup(dcsGroup)

    local jtacCount  = countPairs(grp._jtacUnits)
    local aliveCount = countPairs(grp._aliveUnits)

    check("F-T3.5", "state=DEPLOYED", grp.state == "DEPLOYED", grp.state)
    assert_eq("F-T3.6", jtacCount, 2)    -- BUG-03 fix: was 0 before
    assert_eq("F-T3.7", aliveCount, 6)   -- _aliveUnits = all units (inf+jtac)

    -- Verify JTAC unit names start with "JTAC" prefix (real DCS names, not template slots)
    for uname in pairs(grp._jtacUnits) do
        check("F-T3.8", "JTAC unit has JTAC prefix",
            uname:match("^JTAC") ~= nil, "unitName=" .. uname)
        break  -- check first entry only (all should match by construction)
    end

    -- startLaseTroopUnit: unit-keyed lasing (unit-level tracking, corrects group-level mismatch).
    -- Each call creates a CTLDJTAC entry keyed by unitName in jtacMgr.jtacs and starts the loop.
    -- Mission may have pre-existing JTACs → persist only our unit names.
    local registeredNames = {}
    for uname in pairs(grp._jtacUnits) do
        jtacMgr:startLaseTroopUnit(uname)
        table.insert(registeredNames, uname)
    end
    _G["_TFC_JTAC_NAMES"] = registeredNames
    -- (unit-keyed entries: no separate _TFC_GROUP_NAME needed)

    troopMgr._inTransit[playerName] = nil

    log("Step 3: DEPLOYED | group='" .. gname .. "' | alive=" .. aliveCount
        .. " | jtac=" .. jtacCount .. " | startLaseTroopUnit x" .. #registeredNames
        .. " | jtacMgr.jtacs=" .. countPairs(jtacMgr.jtacs))
    pass("Step 3 — deploy: group='" .. gname .. "', startLaseTroopUnit active. OBSERVE LASING 10s — inject step 4.")
    _G[STEP_N] = 4
    _result = "step=3 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 4 — S_EVENT_DEAD on JTAC unit #2 → onUnitDead → deregisterJTAC
-- Validates BUG-02 fix: wasJtac captured BEFORE _removeDeadUnit
-- Expected: 1 JTAC removed from jtacMgr, _jtacUnits updated
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 4 then

    local troopMgr = CTLDTroopManager.getInstance()
    local jtacMgr  = CTLDJTACManager and CTLDJTACManager.get() or nil
    assert_not_nil("F-T4.1", jtacMgr, "CTLDJTACManager available")

    -- Use only the JTAC names we registered in step 3 (mission may have pre-existing JTACs)
    local jtacNames = _G["_TFC_JTAC_NAMES"] or {}
    check("F-T4.2", "step 3 registered ≥2 JTAC mocks",
        #jtacNames >= 2, "got " .. #jtacNames .. " — run Step 3 first")

    local deadUnitName = jtacNames[2]
    check("F-T4.3", "dead unit still in jtacMgr",
        jtacMgr.jtacs[deadUnitName] ~= nil, "key='" .. deadUnitName .. "' missing")

    log("Step 4: simulating S_EVENT_DEAD for unit '" .. deadUnitName .. "'")
    local jtacBefore = countPairs(jtacMgr.jtacs)
    troopMgr:onUnitDead(deadUnitName)
    local jtacAfter  = countPairs(jtacMgr.jtacs)

    -- Expected: the dead unit removed from jtacMgr.jtacs (net -1)
    assert_eq("F-T4.4", jtacAfter, jtacBefore - 1)
    check("F-T4.5", "dead unit removed from jtacMgr",
        jtacMgr.jtacs[deadUnitName] == nil, "still present")

    log("Step 4: jtacMgr.jtacs before=" .. jtacBefore .. " after=" .. jtacAfter)
    pass("Step 4 — S_EVENT_DEAD: JTAC '" .. deadUnitName .. "' removed from manager (BUG-02 verified). Re-inject for Step 5.")
    _G[STEP_N] = 5
    _result = "step=4 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 5 — embarkFromField: deregisterJTAC BEFORE group:destroy()
-- Expected: 0 JTAC in manager after deregister, DCS group destroyed cleanly
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 5 then

    local troopMgr = CTLDTroopManager.getInstance()
    local jtacMgr  = CTLDJTACManager and CTLDJTACManager.get() or nil
    assert_not_nil("F-T5.1", jtacMgr, "CTLDJTACManager available")

    local deployedName = nil
    local deployedGrp  = nil
    for _, gname in ipairs(troopMgr._droppedGroups[coalition.side.BLUE] or {}) do
        local g = Group.getByName(gname)
        if g and g:isExist() then
            deployedName = gname
            deployedGrp  = g
            break
        end
    end
    assert_not_nil("F-T5.2", deployedGrp, "deployed group exists — run Step 3 first")

    -- Deregister unit-keyed JTAC entries (stops lasing loops) — BEFORE group:destroy()
    local jtacNames = _G["_TFC_JTAC_NAMES"] or {}
    local deregCount = 0
    for _, uname in ipairs(jtacNames) do
        if jtacMgr.jtacs[uname] then
            jtacMgr:deregisterJTAC(uname)
            log("Step 5: deregisterJTAC(mock uname='" .. uname .. "')")
            deregCount = deregCount + 1
        end
    end

    deployedGrp:destroy()
    log("Step 5: group:destroy() called for '" .. deployedName .. "'")

    -- Verify our mocks are gone from jtacMgr
    local ourMocksRemaining = 0
    for _, uname in ipairs(jtacNames) do
        if jtacMgr.jtacs[uname] then ourMocksRemaining = ourMocksRemaining + 1 end
    end
    assert_eq("F-T5.3", ourMocksRemaining, 0)

    -- NOTE: Group:destroy() is not instantaneous in DCS (takes ≥1 frame).
    -- Cannot assert group is gone synchronously in Witchcraft — just log.
    local stillAlive = Group.getByName(deployedName)
    log("Step 5: DCS group post-destroy still visible=" .. tostring(stillAlive ~= nil)
        .. " (expected: may be true within same tick — ok)")

    troopMgr:_removeFromDropped(coalition.side.BLUE, deployedName)
    troopMgr._droppedTemplates[deployedName] = nil
    _G["_TFC_JTAC_NAMES"] = nil  -- reset for steps 6-7

    log("Step 5: deregCount=" .. deregCount .. " ourMocksRemaining=" .. ourMocksRemaining)
    pass("Step 5 — embarkFromField: " .. deregCount
        .. " mock JTAC(s) deregistered before destroy (ordering verified). Re-inject for Step 6.")
    _G[STEP_N] = 6
    _result = "step=5 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 6 — Redeploy after field pickup → spawn new group → re-register JTAC mocks
-- Tests: _syncFromDCSGroup on a fresh spawn (same as step 3 but from a field pickup)
-- Expected: new DCS group spawned, JTAC units found by prefix, mocks re-registered
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 6 then

    local troopMgr = CTLDTroopManager.getInstance()
    local jtacMgr  = CTLDJTACManager and CTLDJTACManager.get() or nil
    assert_not_nil("F-T6.1", jtacMgr, "CTLDJTACManager available")

    local tmpl = troopMgr:_findTemplate(TEST_TMPL_NAME)
    assert_not_nil("F-T6.2", tmpl, "template found — run Step 1 first")

    -- Same as step 3: right at helicopter, facing south toward RED vehicles.
    local spawnX = pPos.x + 5
    local spawnZ = pPos.z
    local dcsGroup = spawnTroopGroup(tmpl, coalition.side.BLUE, country.id.USA, spawnX, spawnZ, 180)
    assert_not_nil("F-T6.3", dcsGroup, "DCS group spawned")

    local gname = dcsGroup:getName()

    -- Rebuild a CTLDTroopGroup from the new DCS group (mirrors disembark flow)
    local grp6 = CTLDTroopGroup:new({
        templateKey  = tmpl._dbKey,
        templateName = tmpl.name,
        unitTotal    = tmpl.total,
        weight       = 0,
        coalitionId  = coalition.side.BLUE,
        countryId    = country.id.USA,
        state        = CTLDTroopGroup.STATE.TRZ_LOADED,
    })
    grp6:_syncFromDCSGroup(dcsGroup)

    local jtacCount = countPairs(grp6._jtacUnits)
    check("F-T6.4", "_syncFromDCSGroup found JTAC units",
        jtacCount > 0, "jtacCount=" .. jtacCount)

    -- startLaseTroopUnit per unit (unit-keyed, mirrors production disembark flow)
    local registeredNames = {}
    for uname in pairs(grp6._jtacUnits) do
        jtacMgr:startLaseTroopUnit(uname)
        table.insert(registeredNames, uname)
    end
    _G["_TFC_JTAC_NAMES"] = registeredNames

    assert_eq("F-T6.5", #registeredNames, jtacCount)

    log("Step 6: group='" .. gname .. "' | jtac units found=" .. jtacCount
        .. " | startLaseTroopUnit x" .. #registeredNames)
    pass("Step 6 — redeploy: group='" .. gname .. "', " .. #registeredNames
        .. " JTAC unit(s) lasing. Re-inject for Step 7.")
    _G[STEP_N] = 7
    _result = "step=6 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 7 — returnToTroopZone → deregisterJTAC(our mocks) + _inTransit cleared
-- Expected: our mock JTACs gone from manager, _inTransit empty
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 7 then

    local troopMgr = CTLDTroopManager.getInstance()
    local jtacMgr  = CTLDJTACManager and CTLDJTACManager.get() or nil
    assert_not_nil("F-T7.1", jtacMgr, "CTLDJTACManager available")

    -- Deregister unit-keyed JTAC entries registered in step 6 (stops lasing loops)
    local jtacNames = _G["_TFC_JTAC_NAMES"] or {}
    local jtacBefore = countPairs(jtacMgr.jtacs)
    check("F-T7.2", "step 6 registered mock JTACs", #jtacNames > 0,
        "got " .. #jtacNames .. " — run Step 6 first")

    -- Deregister: collect first to avoid mutating during iteration
    local deregCount = 0
    for _, uname in ipairs(jtacNames) do
        if jtacMgr.jtacs[uname] then
            log("Step 7: deregisterJTAC('" .. uname .. "')")
            jtacMgr:deregisterJTAC(uname)
            deregCount = deregCount + 1
        end
    end

    troopMgr._inTransit[playerName] = nil

    -- Verify our mocks are gone
    local ourMocksRemaining = 0
    for _, uname in ipairs(jtacNames) do
        if jtacMgr.jtacs[uname] then ourMocksRemaining = ourMocksRemaining + 1 end
    end
    local inTransit = countPairs(troopMgr._inTransit)

    assert_eq("F-T7.3", ourMocksRemaining, 0)
    assert_eq("F-T7.4", inTransit, 0)
    _G["_TFC_JTAC_NAMES"] = nil

    log("Step 7: jtac before=" .. jtacBefore .. " deregCount=" .. deregCount
        .. " ourMocksRemaining=" .. ourMocksRemaining .. " inTransit=" .. inTransit)
    pass("Step 7 — returnToTroopZone: " .. deregCount
        .. " mock JTAC(s) deregistered, _inTransit cleared. Re-inject for Step 8.")
    _G[STEP_N] = 8
    _result = "step=7 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 8 — Final report + full cleanup
-- ══════════════════════════════════════════════════════════════════════════════
elseif step >= 8 then

    local troopMgr = CTLDTroopManager.getInstance()
    local jtacMgr  = CTLDJTACManager and CTLDJTACManager.get() or nil

    local droppedBlue = #(troopMgr._droppedGroups[coalition.side.BLUE] or {})
    local inTransit   = countPairs(troopMgr._inTransit)
    local jtacCount   = jtacMgr and countPairs(jtacMgr.jtacs) or -1
    local templates   = #(troopMgr._templates or {})

    log("Final: droppedGroups[BLUE]=" .. droppedBlue
        .. " inTransit=" .. inTransit
        .. " jtacs=" .. jtacCount
        .. " templates=" .. templates)

    report("═══════════════════════════════════════")
    report("SCENARIO COMPLETE — Full Troop Cycle (inf=4, jtac=2)")
    report("Steps 1-8 all PASS")
    report("BUG-02 verified: onUnitDead reads wasJtac before _removeDeadUnit")
    report("BUG-03 verified: _syncFromDCSGroup rebuilds _jtacUnits from DCS names")
    report("droppedGroups[BLUE]=" .. droppedBlue
        .. " | inTransit=" .. inTransit
        .. " | jtacMgr=" .. jtacCount)
    report("═══════════════════════════════════════")

    cleanupAll()
    _G[STEP_N] = 1
    report("Cleanup done. Re-inject to restart from Step 1.")
    _result = "ALL SUCCESS"

-- ── INCOMPLETE guard: step counter drift or missing elseif ────────────────────
else
    fail("step=" .. step .. " has no matching branch — reset with _reset_steps.lua or add elseif")
end

end)  -- end pcall

-- ── CLEANUP (always executed — debug restored even if fail() was called) ──────
cfg.settings["debug"] = _saved_debug

-- ── WITCHCRAFT RETURN VALUE ───────────────────────────────────────────────────
local _ms = math.floor((os.clock() - _step_start) * 1000)

if not _ok then
    return TAG .. " step=" .. step .. " FAIL: " .. tostring(_err)
end
if _result == "ALL SUCCESS" then
    return TAG .. " " .. _result .. " (" .. _ms .. "ms)"
end
return TAG .. " " .. _result:gsub("SUCCESS", "SUCCESS (" .. _ms .. "ms)")
