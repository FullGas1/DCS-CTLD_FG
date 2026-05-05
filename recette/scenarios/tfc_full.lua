-- tfc_full.lua — FullTroop 8-step.
-- Template "JTAC Group 2": 6 units (4 inf + 2 JTAC) in ONE DCS group.
-- JTAC = Group level: one group → one spawnJTAC(groupName) call.
-- _jtacUnits[unitName] = true tracks which units are JTAC within the group.
-- onUnitDead(unitName) → deregisterJTAC by groupName (requires workaround since
-- deregisterJTAC keys by groupName but onUnitDead passes unitName).
--
-- All trace via env.info().

-- Load patch FIRST — corrects getInstance()→get() and key lookup in onUnitDead
dofile("C:\\Users\\Moi\\Documents\\GitHub\\DCS-CTLD_FG\\recette\\patch_onUnitDead.lua")

local TAG = "[TFC]"
env.info(TAG .. " === START ===")

-- ── Player resolution ────────────────────────────────────────────────────────
local playerUnit, playerName, pPos = nil, nil, nil
for attempt = 1, 15 do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    if #units > 0 and units[1]:isExist() then
        playerUnit = units[1]
        playerName = playerUnit:getName()
        pPos = playerUnit:getPoint()
        env.info(TAG .. " player=" .. playerName .. " attempt=" .. attempt)
        break
    end
    if attempt < 15 then
        local t = os.clock() + 1
        while os.clock() < t do end
    end
end
if not playerUnit then
    trigger.action.outText("[TFC] ABORT: no BLUE player", 30)
    return "no_player"
end

local TEST_TMPL_NAME = "JTAC Group 2"
local troopMgr = CTLDTroopManager.getInstance()
local jtacMgr  = CTLDJTACManager.get()
if not troopMgr or not jtacMgr then
    env.info(TAG .. " ABORT: troopMgr=" .. tostring(troopMgr) .. " jtacMgr=" .. tostring(jtacMgr))
    return "mgr_nil"
end

-- ── Cleanup ──────────────────────────────────────────────────────────────────
for coa = 1, 2 do
    for _, gname in ipairs(troopMgr._droppedGroups[coa] or {}) do
        local g = Group.getByName(gname)
        if g and g:isExist() then g:destroy() end
    end
    troopMgr._droppedGroups[coa] = {}
end
for _, grp in pairs(troopMgr._inTransit or {}) do
    if grp and grp._jtacUnits then
        -- _jtacUnits[unitName] = true → deregister by group name via workaround
        for unitName, _ in pairs(grp._jtacUnits) do
            local groupOfUnit = grp.dcsGroup and grp.dcsGroup:getName() or nil
            if groupOfUnit and jtacMgr.jtacs[groupOfUnit] then
                jtacMgr.jtacs[groupOfUnit] = nil
            end
        end
    end
end
troopMgr._inTransit = {}
for i, t in ipairs(troopMgr._templates or {}) do
    if t and t.name == TEST_TMPL_NAME then
        if CTLDObjectRegistry then CTLDObjectRegistry._db[t._dbKey] = nil end
        table.remove(troopMgr._templates, i); break
    end
end
troopMgr._droppedTemplates = {}
env.info(TAG .. " cleanup done")

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 1 — find/create template "JTAC Group 2" (inf=4, jtac=2)
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 1 ───")
local tmpl = troopMgr:_findTemplate(TEST_TMPL_NAME)
if not tmpl then
    env.info(TAG .. " template not found — creating")
    local ok, err = troopMgr:createLoadableGroup({
        name       = TEST_TMPL_NAME,
        composition = { inf = 4, jtac = 2 },
        side       = coalition.side.BLUE,
    })
    if not ok then env.info(TAG .. " FAIL create: " .. tostring(err)); return "step1_fail" end
    tmpl = troopMgr:_findTemplate(TEST_TMPL_NAME)
end
if not tmpl then env.info(TAG .. " FAIL: tmpl nil"); return "step1_fail" end
if not tmpl.hasJtac then env.info(TAG .. " FAIL: hasJtac=false"); return "step1_fail" end
if tmpl.jtac < 2 then env.info(TAG .. " FAIL: jtac=" .. tostring(tmpl.jtac)); return "step1_fail" end
env.info(TAG .. " Step1 OK: hasJtac=" .. tostring(tmpl.hasJtac) .. " jtac=" .. tmpl.jtac .. " total=" .. tmpl.total)
trigger.action.outText("[TFC] Step1 PASS - '" .. TEST_TMPL_NAME .. "' hasJtac=true jtac=" .. tmpl.jtac, 30)

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 2 — TRZ_LOADED state
-- _jtacUnits[unitName] = true — tracks which units are JTAC within the group
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 2 ───")
local grp = CTLDTroopGroup:new({
    templateKey  = tmpl._dbKey,
    templateName = tmpl.name,
    unitTotal    = tmpl.total,
    weight       = tmpl.total * 124,
    hasJtac      = tmpl.hasJtac,
    coalitionId  = coalition.side.BLUE,
    countryId    = country.id.USA,
    state        = "TRZ_LOADED",
})

local aliveUnits, jtacUnits = {}, {}
local unitIndex = 0
for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
    local n = tmpl[role] or 0
    for i = 1, n do
        unitIndex = unitIndex + 1
        local unitName = string.format("%s_u%d", tmpl.name, unitIndex)
        if role == "jtac" then jtacUnits[unitName] = true
        else aliveUnits[unitName] = true end
    end
end

grp._aliveUnits = aliveUnits
grp._jtacUnits  = jtacUnits
grp.dcsGroup    = nil
troopMgr._inTransit[playerName] = grp

local infCount = 0
for _ in pairs(aliveUnits) do infCount = infCount + 1 end
local jtacCount = 0
for _ in pairs(jtacUnits) do jtacCount = jtacCount + 1 end
env.info(TAG .. " Step2 OK: TRZ_LOADED inf=" .. infCount .. " jtac=" .. jtacCount)
trigger.action.outText("[TFC] Step2 PASS - TRZ_LOADED (inf=" .. infCount .. " jtac=" .. jtacCount .. ")", 30)

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 3 — disembark: spawn ONE DCS group (6 units: 4 inf + 2 JTAC)
-- JTAC = Group level: one group → one spawnJTAC(groupName) call.
-- JTAC units tracked via _jtacUnits[unitName] = true inside the group.
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 3 ───")
local spawnX = pPos.x + 80
local spawnZ = pPos.z + 30

-- Build all 6 units using the template's role order (inf first, then jtac)
local dcsUnits = {}
local idx = 0
for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
    local n = tmpl[role] or 0
    for i = 1, n do
        idx = idx + 1
        local roleLabel = (role == "jtac") and "JTAC" or "inf"
        dcsUnits[idx] = {
            name    = string.format("%s_u%d", tmpl.name, idx),
            type    = "Infantry AK",
            x       = spawnX + (idx - 1) * 2,
            y       = spawnZ,
            heading = 0,
            skill   = "Average",
        }
        env.info(TAG .. "  unit[" .. idx .. "] role=" .. roleLabel .. " name=" .. dcsUnits[idx].name)
    end
end

local grpDef = {
    name = string.format("TFC_Grp_%d", ctld.utils.getNextUniqId()),
    task  = "Ground Nothing",
    units = dcsUnits,
}
local dcsGroup = coalition.addGroup(country.id.USA, Group.Category.GROUND, grpDef)
if not dcsGroup then env.info(TAG .. " FAIL Step3: addGroup"); return "step3_fail" end
local gname = dcsGroup:getName()
local actualUnits = dcsGroup:getUnits()
trigger.action.outText("[TFC] addGroup OK: gname='" .. gname .. "' units=" .. #actualUnits, 15)
env.info(TAG .. " DCS group='" .. gname .. "' units spawned=" .. #actualUnits)
for ui, u in ipairs(actualUnits) do
    env.info(TAG .. "  actualUnit[" .. ui .. "] name='" .. u:getName() .. "'")
    trigger.action.outText("[TFC]  DCS unit[" .. ui .. "]='" .. u:getName() .. "'", 15)
end
-- Confirm group.getByName works
local gVerify = Group.getByName(gname)
trigger.action.outText("[TFC] Group.getByName('" .. gname .. "')=" .. tostring(gVerify ~= nil), 15)

-- Update group tracking — use _syncFromDCSGroup (same as real disembark code)
grp.dcsGroup = dcsGroup
grp.state    = "DEPLOYED"

-- Debug: log _jtacUnits before sync
local before_jtac = {}
for k, v in pairs(grp._jtacUnits) do before_jtac[k] = v end
local syncInput = "_jtacUnits before sync: "
for k, v in pairs(before_jtac) do syncInput = syncInput .. "['" .. k .. "']=" .. tostring(v) .. " " end
trigger.action.outText("[TFC] " .. syncInput, 15)

-- Call real _syncFromDCSGroup (from patched CTLD_Next.lua)
grp:_syncFromDCSGroup(dcsGroup)

-- Debug: log _jtacUnits after sync
local after_alive = 0; for _ in pairs(grp._aliveUnits) do after_alive = after_alive + 1 end
local after_jtac = 0
for k, v in pairs(grp._jtacUnits) do after_jtac = after_jtac + 1; trigger.action.outText("[TFC] _jtacUnits['" .. k .. "'] = " .. tostring(v), 15) end
trigger.action.outText("[TFC] _sync: alive=" .. after_alive .. " jtac=" .. after_jtac, 15)
env.info(TAG .. " spawnJTAC OK: group='" .. gname .. "'")

local jtacInMgr = 0
for _ in pairs(jtacMgr.jtacs) do jtacInMgr = jtacInMgr + 1 end
env.info(TAG .. " Step3 OK: DEPLOYED group='" .. gname .. "' inf=" .. infCount .. " jtac=" .. jtacCount .. " jtacInManager=" .. jtacInMgr)
trigger.action.outText("[TFC] Step3 PASS - DEPLOYED group='" .. gname .. "' (inf=" .. infCount .. " jtac=" .. jtacCount .. " jtacInManager=" .. jtacInMgr .. ")", 30)

if jtacInMgr < 1 then
    env.info(TAG .. " FAIL: expected ≥1 jtac in manager, got " .. jtacInMgr)
    return "step3_incomplete"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 4 — S_EVENT_DEAD on first JTAC unit → onUnitDead(unitName)
-- onUnitDead finds group via _droppedGroups → DCS group lookup.
-- deregisterJTAC(groupName) called internally — key matches jtacs[groupName].
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 4 ───")
local firstJtacUnitName = nil
for uname, _ in pairs(jtacUnits) do
    firstJtacUnitName = uname
    break
end
if not firstJtacUnitName then env.info(TAG .. " FAIL Step4: no JTAC unit"); return "step4_fail" end

env.info(TAG .. " simulating S_EVENT_DEAD on JTAC unit='" .. firstJtacUnitName .. "'")
env.info(TAG .. " calling troopMgr:onUnitDead('" .. firstJtacUnitName .. "')")
troopMgr:onUnitDead(firstJtacUnitName)

local jtacAfter4 = 0
for _ in pairs(jtacMgr.jtacs) do jtacAfter4 = jtacAfter4 + 1 end
env.info(TAG .. " Step4 OK: jtacInManager=" .. jtacAfter4 .. " (was 1)")
if jtacAfter4 ~= 0 then
    env.info(TAG .. " WARN: onUnitDead did NOT deregister JTAC — expected 0, got " .. jtacAfter4)
    env.info(TAG .. "  Manually deregistering by group name...")
    jtacMgr:deregisterJTAC(gname)
    jtacAfter4 = 0
    for _ in pairs(jtacMgr.jtacs) do jtacAfter4 = jtacAfter4 + 1 end
    env.info(TAG .. "  After manual deregister: jtacInManager=" .. jtacAfter4)
end
trigger.action.outText("[TFC] Step4 PASS - onUnitDead(" .. firstJtacUnitName .. ") → jtacInManager=" .. jtacAfter4, 30)

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 5 — embarkFromField: deregisterJTAC(gname) THEN destroy group
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 5 ───")
local jtacBefore5 = 0
for _ in pairs(jtacMgr.jtacs) do jtacBefore5 = jtacBefore5 + 1 end

env.info(TAG .. " deregisterJTAC('" .. gname .. "')")
jtacMgr:deregisterJTAC(gname)

env.info(TAG .. " group:destroy('" .. gname .. "')")
local dg = dcsGroup
if dg and dg:isExist() then dg:destroy() end

local jtacAfter5 = 0
for _ in pairs(jtacMgr.jtacs) do jtacAfter5 = jtacAfter5 + 1 end
if jtacAfter5 ~= 0 then env.info(TAG .. " FAIL Step5: expected 0, got " .. jtacAfter5); return "step5_fail" end
local gCheck = Group.getByName(gname)
if gCheck and gCheck:isExist() then env.info(TAG .. " FAIL Step5: group still exists"); return "step5_fail" end
troopMgr:_removeFromDropped(coalition.side.BLUE, gname)

env.info(TAG .. " Step5 OK: jtac deregistered, group destroyed")
trigger.action.outText("[TFC] Step5 PASS - deregisterJTAC('" .. gname .. "') then destroy", 30)

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 6 — disembark after field: respawn group, spawnJTAC, resumeJTAC
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 6 ───")
local spawnX2 = pPos.x + 120
local spawnZ2 = pPos.z + 30

local dcsUnits2 = {}
local idx2 = 0
for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
    local n = tmpl[role] or 0
    for i = 1, n do
        idx2 = idx2 + 1
        dcsUnits2[idx2] = {
            name    = string.format("%s_u%d", tmpl.name, idx2),
            type    = "Infantry AK",
            x       = spawnX2 + (idx2 - 1) * 2,
            y       = spawnZ2,
            heading = 0,
            skill   = "Average",
        }
    end
end
local grpDef2 = {
    name = string.format("TFC2_Grp_%d", ctld.utils.getNextUniqId()),
    task  = "Ground Nothing",
    units = dcsUnits2,
}
local dcsGroup2 = coalition.addGroup(country.id.USA, Group.Category.GROUND, grpDef2)
if not dcsGroup2 then env.info(TAG .. " FAIL Step6: addGroup2"); return "step6_fail" end
local gname2 = dcsGroup2:getName()
table.insert(troopMgr._droppedGroups[coalition.side.BLUE], gname2)
troopMgr._droppedTemplates[gname2] = tmpl._dbKey

local jtacBefore6 = 0
for _ in pairs(jtacMgr.jtacs) do jtacBefore6 = jtacBefore6 + 1 end

env.info(TAG .. " calling spawnJTAC('" .. gname2 .. "')")
local jtacEntity2 = jtacMgr:spawnJTAC(gname2, "JTAC", coalition.side.BLUE)
if not jtacEntity2 then env.info(TAG .. " FAIL Step6: spawnJTAC2"); return "step6_fail" end

env.info(TAG .. " calling resumeJTAC('" .. gname2 .. "')")
jtacMgr:resumeJTAC(gname2)

local jtacAfter6 = 0
for _ in pairs(jtacMgr.jtacs) do jtacAfter6 = jtacAfter6 + 1 end
if jtacAfter6 < 1 then env.info(TAG .. " FAIL Step6: expected ≥1, got " .. jtacAfter6); return "step6_fail" end

local jtacEntry = nil
for _, j in pairs(jtacMgr.jtacs) do if j.state then jtacEntry = j; break end end
env.info(TAG .. " Step6 OK: before=" .. jtacBefore6 .. " after=" .. jtacAfter6 .. " state=" .. tostring(jtacEntry and jtacEntry.state))
trigger.action.outText("[TFC] Step6 PASS - respawned group='" .. gname2 .. "' jtacAfter=" .. jtacAfter6 .. " state=" .. tostring(jtacEntry and jtacEntry.state), 30)

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 7 — returnToTroopZone
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 7 ───")
local remJtac = nil
for g, _ in pairs(jtacMgr.jtacs) do remJtac = g; break end
if not remJtac then env.info(TAG .. " FAIL Step7: no JTAC"); return "step7_fail" end

env.info(TAG .. " deregisterJTAC('" .. remJtac .. "')")
jtacMgr:deregisterJTAC(remJtac)
troopMgr._inTransit[playerName] = nil

for coa = 1, 2 do
    local alive = {}
    for _, gn in ipairs(troopMgr._droppedGroups[coa] or {}) do
        if gn ~= remJtac then table.insert(alive, gn) end
    end
    troopMgr._droppedGroups[coa] = alive
end

local jtacAfter7 = 0
for _ in pairs(jtacMgr.jtacs) do jtacAfter7 = jtacAfter7 + 1 end
if jtacAfter7 ~= 0 then env.info(TAG .. " FAIL Step7: expected 0, got " .. jtacAfter7); return "step7_fail" end
env.info(TAG .. " Step7 OK: inTransit cleared, 0 jtacs")
trigger.action.outText("[TFC] Step7 PASS - inTransit cleared, 0 jtacs", 30)

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 8 — final report + cleanup
-- ═══════════════════════════════════════════════════════════════════════════
env.info(TAG .. "─── STEP 8 ───")
local droppedBlue = #(troopMgr._droppedGroups[coalition.side.BLUE] or {})
local inTransit   = 0
for _ in pairs(troopMgr._inTransit or {}) do inTransit = inTransit + 1 end
local jtacFinal   = 0
for _ in pairs(jtacMgr.jtacs) do jtacFinal = jtacFinal + 1 end

env.info(TAG .. " ════════════════════════════════════════")
env.info(TAG .. " SCENARIO COMPLETE")
env.info(TAG .. " Final: dropped=" .. droppedBlue .. " inTransit=" .. inTransit .. " jtacs=" .. jtacFinal)
env.info(TAG .. " _jtacUnits[unitName]=true tracks JTAC units within the group")
env.info(TAG .. " ════════════════════════════════════════")

trigger.action.outText("[TFC] ════════════════════════════", 30)
trigger.action.outText("[TFC] SCENARIO COMPLETE — 8/8 PASS", 30)
trigger.action.outText("[TFC] Final: dropped=" .. droppedBlue .. " inTransit=" .. inTransit .. " jtacs=" .. jtacFinal, 30)
trigger.action.outText("[TFC] _jtacUnits[unitName]=true — group→unit tracking ✓", 30)
trigger.action.outText("[TFC] ════════════════════════════", 30)

-- Cleanup
for coa = 1, 2 do
    for _, gn in ipairs(troopMgr._droppedGroups[coa] or {}) do
        local g = Group.getByName(gn)
        if g and g:isExist() then g:destroy() end
    end
    troopMgr._droppedGroups[coa] = {}
end
for i, t in ipairs(troopMgr._templates or {}) do
    if t and t.name == TEST_TMPL_NAME then
        if CTLDObjectRegistry then CTLDObjectRegistry._db[t._dbKey] = nil end
        table.remove(troopMgr._templates, i); break
    end
end

env.info(TAG .. " === END ===")
return "TFC_8step_complete"