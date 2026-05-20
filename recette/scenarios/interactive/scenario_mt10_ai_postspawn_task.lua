---@diagnostic disable
-- =============================================================================
-- scenario_mt10_ai_postspawn_task.lua  [INTERACTIVE]
-- MT-10 — AI post-spawn task assignment: gotoNearestWPZ + gotoAttackNearestEnemyOnLos
--
-- PREREQUIS MISSION :
--   - heliai_mt10a : UH-1H BLUE, AI, activation retardee
--       Route : WP Landing sur AIZ_depot_B_P_T_5 -> WP Landing sur AIZ_livraison_B_D_G
--   - heliai_mt10b : UH-1H BLUE, AI, activation retardee
--       Route : meme route que mt10a
--   - AIZ_depot_B_P_T_10   : zone pickup T, stock=10, r~60m
--   - AIZ_livraison_B_D_G  : zone dropoff G (sol), r~274m
--   - WPZ_mt10_B           : zone waypoint BLUE (cle parsee "mt10"), 1-2 km de AIZ_livraison
--   - mt10_enemy_RED       : groupe sol RED, <3 km de AIZ_livraison, LOS degagee
--   - enable_debug.lua injecte avant ce script
--   - ctldLogPath defini dans le .miz (trigger MISSION START)
--
-- PROTOCOLE :
--   Step 1 — Setup A : verif prerequis, force template WPZ, active heliai_mt10a
--            >> Attendre que mt10a ait fait le CYCLE COMPLET (pickup + dropoff) <<
--   Step 2 — Verif A : log contient "gotoNearestWPZ" pointe vers "mt10"
--   Step 3 — Setup B : reset stock, force template Attack, active heliai_mt10b
--            >> Attendre que mt10b ait fait le CYCLE COMPLET (pickup + dropoff) <<
--   Step 4 — Verif B : log contient "gotoAttackNearestEnemyOnLos" avec coordonnees
--   Step 5 — Cleanup
--
-- NOTE: Les checks se font APRES le cycle complet du heli (pas mid-vol).
--       Injecter chaque step de verif ~3s apres la pose sur AIZ_livraison.
-- =============================================================================

local cfg = CTLDConfig.get()
local _saved_debug = cfg.settings["debug"]
cfg.settings["debug"] = true

local TAG    = "[MT-10]"
local START  = os.date("%Y-%m-%d %H:%M:%S")
local STEP_N = "_MT10_STEP"

local AI_UNIT_A = "heliai_mt10a"
local AI_UNIT_B = "heliai_mt10b"
local AIZ_P     = "AIZ_depot_B_P_T_10"
local AIZ_D     = "AIZ_mt10d_B_D_G"
local WPZ_KEY   = "mt10"                  -- cle parsee de WPZ_mt10_B dans _troopZones
local ENEMY_GRP = "mt10_enemy_RED"

local function log(msg)    ctld.utils.log("INFO",  TAG .. " " .. msg) end
local function report(msg) trigger.action.outText(TAG .. " " .. msg, 30); log(msg) end
local function pass(msg)   report("[PASS] " .. msg) end
local function fail(msg)
    local trace = debug.traceback(msg, 2)
    trigger.action.outText(TAG .. " !! FAIL: " .. msg, 60)
    log("FAIL: " .. trace)
    error(msg)
end
local function check(id, desc, cond, details)
    if cond then pass(id .. " — " .. desc)
    else fail(id .. " — " .. desc .. (details and (" | " .. details) or "")) end
end

-- Find first non-JTAC template that fits within the pickup zone stock.
-- Uses Standard Group (total=10) if AIZ_P stock >= 10, else first that fits.
local function findBaseTemplate(tm)
    local zm  = CTLDZoneManager.getInstance()
    local zP  = zm._troopZones[AIZ_P]
    local maxStock = (zP and zP.pickMaxStock) or 5
    for _, t in ipairs(tm._templates) do
        if not t.disabled and not t.hasJtac and (t.total or 0) <= maxStock and (t.total or 0) > 0 then
            return t
        end
    end
    return nil
end

-- Scan CTLD.log for a keyword; return last matching line or nil.
-- Force-closes the log before reading to flush any buffered DCS writes.
local function scanLog(keyword)
    pcall(ctld.utils.closeLog)          -- flush DCS log buffer to disk
    local logPath = (cfg.settings["ctldLogPath"] or "") .. "CTLD.log"
    local f = io.open(logPath, "r")
    pcall(ctld.utils.reopenLogAppend)   -- reopen for future CTLD writes
    if not f then return nil end
    local lastMatch = nil
    for line in f:lines() do
        if string.find(line, keyword, 1, true) then lastMatch = line end
    end
    f:close()
    return lastMatch
end

-- Setup shared between steps 1 and 3: inject task directly on the source template.
-- Modifying _templates in-place ensures task survives any _initAITransports rebuild.
-- State persisted in _G to survive across per-step injections.
local function forceAITeam(core, tm, taskName, unitName)
    local baseTmpl = findBaseTemplate(tm)
    if not baseTmpl then return nil, "no base template found (total<=5)" end
    -- Save original specificParams in _G (persists across injections)
    _G["_MT10_FORCED_TMPL_KEY"] = baseTmpl._dbKey or baseTmpl.name
    _G["_MT10_SAVED_SP"]        = baseTmpl.specificParams
    baseTmpl.specificParams = { task = taskName }
    -- Restrict _aiTeams[2] to only this template so no other is picked
    core._aiTeams[2] = { baseTmpl }
    -- Register unit in transportPilotNames
    local names = cfg.settings["transportPilotNames"] or {}
    names[unitName] = true
    cfg.settings["transportPilotNames"] = names
    return baseTmpl, nil
end

local function cleanup()
    local names = cfg.settings["transportPilotNames"] or {}
    names[AI_UNIT_A] = nil
    names[AI_UNIT_B] = nil
    -- Restore modified template specificParams (lookup by key in _templates)
    local tmplKey = _G["_MT10_FORCED_TMPL_KEY"]
    local savedSP = _G["_MT10_SAVED_SP"]
    if tmplKey then
        local ok2, tm2 = pcall(CTLDTroopManager.getInstance)
        if ok2 and tm2 then
            for _, t in ipairs(tm2._templates) do
                if (t._dbKey or t.name) == tmplKey then
                    t.specificParams = savedSP
                    break
                end
            end
        end
    end
    _G["_MT10_FORCED_TMPL_KEY"] = nil
    _G["_MT10_SAVED_SP"]        = nil
    local ok, core = pcall(CTLDCoreManager.getInstance)
    if ok and core then core:_initAITransports() end
    log("cleanup done")
end

-- ── STATE MACHINE ─────────────────────────────────────────────────────────────
_G[STEP_N] = _G[STEP_N] or 1
local step = _G[STEP_N]
report("==== START " .. START .. " | step=" .. step .. " ====")

if step == 1 then
    pcall(function()
        ctld.utils.closeLog()
        local f = io.open((cfg.settings["ctldLogPath"] or "") .. "CTLD.log", "w")
        if f then f:write("[" .. START .. "] === MT-10 LOG RESET ===\n"); f:close() end
        ctld.utils.reopenLogAppend()
    end)
end

local _step_start = os.clock()
local _result = "INCOMPLETE"
local _ok, _err = pcall(function()

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 1 — Setup A : verif prerequis + force template WPZ + activation mt10a
-- ══════════════════════════════════════════════════════════════════════════════
if step == 1 then

    local zm   = CTLDZoneManager.getInstance()
    local tm   = CTLDTroopManager.getInstance()
    local core = CTLDCoreManager.getInstance()

    -- Verif zones
    local zP = zm._troopZones[AIZ_P]
    local zD = zm._troopZones[AIZ_D]
    check("MT-10.1.1", "AIZ_P trouvee: " .. AIZ_P,   zP ~= nil)
    check("MT-10.1.2", "AIZ_D trouvee: " .. AIZ_D,   zD ~= nil)
    if zP then
        check("MT-10.1.3", "AIZ_P.isAIPickup=true",  zP.isAIPickup == true)
        check("MT-10.1.4", "AIZ_P.aiCargoType=T",     zP.aiCargoType == "T")
        report("AIZ_P stock max=" .. tostring(zP.pickMaxStock)
            .. " cur=" .. tostring(zP.pickCurrentStock))
    end
    if zD then
        check("MT-10.1.5", "AIZ_D.isAIDropoff=true", zD.isAIDropoff == true)
    end

    -- Verif WPZ (stockee sous cle parsee "mt10")
    local wpzZone = zm._troopZones[WPZ_KEY]
    check("MT-10.1.6", "WPZ trouvee (cle='" .. WPZ_KEY .. "')", wpzZone ~= nil)
    if wpzZone then
        check("MT-10.1.7", "WPZ.isWaypoint=true", wpzZone.isWaypoint == true,
            "isWaypoint=" .. tostring(wpzZone.isWaypoint))
    end

    -- Verif ennemi RED
    local enemyGrp = Group.getByName(ENEMY_GRP)
    check("MT-10.1.8", "Groupe ennemi RED: " .. ENEMY_GRP, enemyGrp ~= nil)

    -- Clone + force _aiTeams[2] = {tmplWPZ}
    local tmplWPZ, err = forceAITeam(core, tm, "gotoNearestWPZ", AI_UNIT_A)
    check("MT-10.1.9",  "Template WPZ clone cree (total<=5)", tmplWPZ ~= nil, err)
    check("MT-10.1.10", "_aiTeams[2] force sur 1 template", #core._aiTeams[2] == 1)
    if tmplWPZ then
        report("Template: '" .. tmplWPZ.name .. "' total=" .. tmplWPZ.total
            .. " task=" .. tmplWPZ.specificParams.task)
    end

    -- Activer heliai_mt10a
    local grpA = Group.getByName(AI_UNIT_A)
    check("MT-10.1.11", "Group " .. AI_UNIT_A .. " accessible", grpA ~= nil)
    if grpA then grpA:activate() end

    report("STEP 1 OK — " .. AI_UNIT_A .. " active."
        .. " Attendre CYCLE COMPLET (pickup + dropoff),"
        .. " puis injecter step 2 (~3s apres pose sur " .. AIZ_D .. ").")
    _G[STEP_N] = 2
    _result = "step=1 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 2 — Verif A : log contient gotoNearestWPZ → 'mt10'
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 2 then

    -- Heli doit etre au dropoff ou reparti — hasTroops doit etre false
    local tm    = CTLDTroopManager.getInstance()
    local hasTr = tm:hasTroops(AI_UNIT_A)
    check("MT-10.2.1", "hasTroops=false (cycle complet)", not hasTr,
        "hasTroops=" .. tostring(hasTr))

    -- Log check
    local logLine = scanLog("_assignPostSpawnTask")
    check("MT-10.2.2", "CTLD.log contient '_assignPostSpawnTask'", logLine ~= nil,
        logLine or "aucune ligne")
    if logLine then
        trigger.action.outText(TAG .. " Log A: " .. logLine, 30)  -- ecran seulement, pas CTLD.log
        check("MT-10.2.3", "Tache = 'gotoNearestWPZ'",
            string.find(logLine, "gotoNearestWPZ", 1, true) ~= nil, "ligne=" .. logLine)
        check("MT-10.2.4b", "Cible = WPZ '" .. WPZ_KEY .. "'",
            string.find(logLine, WPZ_KEY, 1, true) ~= nil, "ligne=" .. logLine)
    end

    -- Verif qu'un groupe BLUE sol existe (troupes deployees)
    local deployed = {}
    local tm2 = CTLDTroopManager.getInstance()
    for _, grpName in ipairs(tm2._droppedGroups[2] or {}) do
        deployed[#deployed + 1] = grpName
    end
    check("MT-10.2.4", "Au moins 1 groupe BLUE depose",
        #deployed > 0, "count=" .. #deployed)
    if #deployed > 0 then
        report("Groupes deposes BLUE: " .. table.concat(deployed, ", "))
    end

    report("STEP 2 OK — Sub-test A WPZ valide. Re-injecter step 3.")
    _G[STEP_N] = 3
    _result = "step=2 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 3 — Setup B : reset stock + force template Attack + activation mt10b
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 3 then

    local zm   = CTLDZoneManager.getInstance()
    local tm   = CTLDTroopManager.getInstance()
    local core = CTLDCoreManager.getInstance()

    -- Reset stock AIZ_P
    local zP = zm._troopZones[AIZ_P]
    if zP and zP.pickMaxStock and zP.pickMaxStock > 0 then
        zP.pickCurrentStock = zP.pickMaxStock
        report("Stock AIZ_P reset: cur=" .. zP.pickCurrentStock)
    end

    -- Clone + force _aiTeams[2] = {tmplAttack}
    local tmplAttack, err = forceAITeam(core, tm, "gotoAttackNearestEnemyOnLos", AI_UNIT_B)
    check("MT-10.3.1", "Template Attack clone cree (total<=5)", tmplAttack ~= nil, err)
    check("MT-10.3.2", "_aiTeams[2] force sur 1 template", #core._aiTeams[2] == 1)
    if tmplAttack then
        report("Template: '" .. tmplAttack.name .. "' total=" .. tmplAttack.total
            .. " task=" .. tmplAttack.specificParams.task)
    end

    -- Verif ennemi RED toujours vivant
    local enemyGrp = Group.getByName(ENEMY_GRP)
    local alive = enemyGrp ~= nil and enemyGrp:getSize() > 0
    check("MT-10.3.3", "Ennemi RED vivant pour LOS", alive)

    -- Activer heliai_mt10b
    local grpB = Group.getByName(AI_UNIT_B)
    check("MT-10.3.4", "Group " .. AI_UNIT_B .. " accessible", grpB ~= nil)
    if grpB then grpB:activate() end

    report("STEP 3 OK — " .. AI_UNIT_B .. " active."
        .. " Attendre CYCLE COMPLET (pickup + dropoff),"
        .. " puis injecter step 4 (~3s apres pose sur " .. AIZ_D .. ").")
    _G[STEP_N] = 4
    _result = "step=3 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 4 — Verif B : log contient gotoAttackNearestEnemyOnLos avec coords
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 4 then

    local tm    = CTLDTroopManager.getInstance()
    local hasTr = tm:hasTroops(AI_UNIT_B)
    check("MT-10.4.1", "hasTroops=false (cycle complet)", not hasTr,
        "hasTroops=" .. tostring(hasTr))

    -- Chercher la derniere ligne contenant "gotoAttackNearestEnemyOnLos" (plain=true dans scanLog)
    -- La derniere occurrence est la ligne resultat de _assignPostSpawnTask (avec coordonnees)
    local logLine = scanLog("gotoAttackNearestEnemyOnLos")
    -- Rejeter la ligne de setup template (ne contient pas "_assignPostSpawnTask")
    if logLine and not string.find(logLine, "_assignPostSpawnTask", 1, true) then
        logLine = nil
    end
    if not logLine then
        -- Diagnostic: verifier portee et existence ennemi
        local enemyGrp = Group.getByName(ENEMY_GRP)
        local diagInfo = "groupe=" .. ENEMY_GRP .. " present=" .. tostring(enemyGrp ~= nil)
        if enemyGrp then
            local u0 = enemyGrp:getUnit(1)
            if u0 then
                local ePos = u0:getPoint()
                local zm2  = CTLDZoneManager.getInstance()
                local zD2  = zm2._troopZones[AIZ_D]
                if zD2 then
                    local dist = ctld.utils.getDistance("mt10diag", zD2:getCenter(), ePos)
                    local maxDist = ctld.gs("maximumSearchDistance") or 4000
                    diagInfo = diagInfo .. " dist=" .. math.floor(dist) .. "m maxDist=" .. maxDist
                end
            end
        end
        report("DIAG ennemi: " .. diagInfo)
    end
    check("MT-10.4.2", "CTLD.log contient 'gotoAttackNearestEnemyOnLos'", logLine ~= nil,
        logLine or "ennemi hors portee ou pas en LOS")
    if logLine then
        trigger.action.outText(TAG .. " Log B: " .. logLine, 30)
        local hasCoords = string.find(logLine, "%d+%.%d") ~= nil
        check("MT-10.4.3", "Coordonnees cible loggees (ennemi en LOS)", hasCoords,
            "ligne=" .. logLine)
    end

    report("STEP 4 OK — Sub-test B Attack valide. Re-injecter step 5 (cleanup).")
    _G[STEP_N] = 5
    _result = "step=4 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 5 — Cleanup
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 5 then

    cleanup()
    report("MT-10 ALL SUCCESS — gotoNearestWPZ + gotoAttackNearestEnemyOnLos valides")
    _G[STEP_N] = 1
    _result = "ALL SUCCESS"

else
    fail("step=" .. step .. " sans branche")
end

end)  -- end pcall

cfg.settings["debug"] = _saved_debug

local _ms = math.floor((os.clock() - _step_start) * 1000)
if not _ok then
    pcall(cleanup)
    _G[STEP_N] = 1  -- reset au fail pour repartir proprement
    return TAG .. " step=" .. step .. " FAIL: " .. tostring(_err)
end
if _result == "ALL SUCCESS" then
    return TAG .. " " .. _result .. " (" .. _ms .. "ms)"
end
return TAG .. " " .. _result:gsub("SUCCESS", "SUCCESS (" .. _ms .. "ms)")
                             :gsub("WAITING", "WAITING (" .. _ms .. "ms)")
