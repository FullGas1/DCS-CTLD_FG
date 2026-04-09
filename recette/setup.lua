---@diagnostic disable
-- ============================================================
-- recette/setup.lua
-- Common test harness: dependencies, config, ctld_test module.
-- Must be loaded via dofile() at the top of each test script.
-- CTLD.log purge is done in each test script, NOT here.
-- ============================================================

local PROJECT = "C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/"
local SRC     = PROJECT .. "src/"
local LOG_PATH = PROJECT .. "recette/"

-- ============================================================
-- 1. Load dependencies
-- ============================================================

dofile(SRC .. "lib/class.lua")
dofile(SRC .. "CTLD_config.lua")

-- Stub ctld.tr before config:load() — CTLD_config.lua calls it at line 348
-- Will be properly overridden once CTLD_i18n.lua is loaded below.
ctld = ctld or {}
ctld.tr = ctld.tr or function(key, default) return default or key end

-- Apply test configuration before loading utils
CTLDConfig.get():load()

-- Override log path so utils writes to recette/CTLD.log
ctld = ctld or {}
ctld.debug    = true
ctldLogPath   = LOG_PATH   -- global used by ctld.utils.initLog()

-- Close any open log handle before reloading utils (prevents orphaned handle / file lock)
if ctld and ctld.utils and ctld.utils.closeLog then
    ctld.utils.closeLog()
end
-- Release any remaining orphaned file handles from previous test runs
collectgarbage("collect")
dofile(SRC .. "CTLD_utils.lua")
dofile(SRC .. "CTLD_i18n.lua")
dofile(SRC .. "CTLD_i18n_en.lua")

-- Inject debug + log path into config settings (initLog reads them via ctld.gs)
CTLDConfig.get().settings["debug"]       = true
CTLDConfig.get().settings["ctldLogPath"] = LOG_PATH

-- Open CTLD.log file handle
ctld.utils.initLog()

-- ctld.logInfo / logWarning / logError — used by CTLD_menu.lua and other src modules.
-- Route through ctld.utils.log so all output lands in CTLD.log.
ctld.logInfo    = ctld.logInfo    or function(fmt, ...) ctld.utils.log("INFO",    fmt, ...) end
ctld.logWarning = ctld.logWarning or function(fmt, ...) ctld.utils.log("WARNING", fmt, ...) end
ctld.logError   = ctld.logError   or function(fmt, ...) ctld.utils.log("ERROR",   fmt, ...) end

-- ============================================================
-- 2. ctld.gs helper (required by all src modules)
-- ============================================================

-- ctld.gs() is defined in CTLD_config.lua as a shorthand.
-- Ensure it exists; if not, create a passthrough.
if not ctld.gs then
    function ctld.gs(key)
        return CTLDConfig.get().settings[key]
    end
end

-- ============================================================
-- 3. ctld_test module
-- ============================================================

ctld_test = {}

ctld_test._caseId    = "?"
ctld_test._caseName  = "?"
ctld_test._startTime = 0
ctld_test._passed    = 0
ctld_test._failed    = 0
ctld_test._total     = 0

--- Log to both env.info and CTLD.log.
local function _log(msg)
    env.info("[CTLD_TEST] " .. msg)
    -- Also write through ctld.utils if available
    if ctld.utils and ctld.utils.log then
        ctld.utils.log("TEST", msg)
    end
end

--- Start a test case. Must be called once per script.
-- @param caseId   string  e.g. "U-01"
-- @param caseName string  human-readable name
function ctld_test.start(caseId, caseName)
    ctld_test._caseId   = caseId
    ctld_test._caseName = caseName
    ctld_test._passed   = 0
    ctld_test._failed   = 0
    ctld_test._total    = 0
    -- Use DCS absolute time if available, otherwise os.time
    local ok, t = pcall(function() return timer.getAbsTime() end)
    ctld_test._startTime = ok and t or (os.time and os.time() or 0)
    _log(string.format("START  [%s] %s", caseId, caseName))
end

--- Assert that condition is true.
-- @param condition  boolean
-- @param desc       string  description of the assertion
function ctld_test.assert(condition, desc)
    ctld_test._total = ctld_test._total + 1
    if condition then
        ctld_test._passed = ctld_test._passed + 1
        _log(string.format("  OK     %s", desc))
    else
        ctld_test._failed = ctld_test._failed + 1
        _log(string.format("  FAIL   %s", desc))
    end
end

--- Assert equality (==).
-- @param a    any
-- @param b    any
-- @param desc string
function ctld_test.assertEqual(a, b, desc)
    local ok = (a == b)
    ctld_test._total = ctld_test._total + 1
    if ok then
        ctld_test._passed = ctld_test._passed + 1
        _log(string.format("  OK     %s  [%s == %s]", desc, tostring(a), tostring(b)))
    else
        ctld_test._failed = ctld_test._failed + 1
        _log(string.format("  FAIL   %s  [expected %s, got %s]", desc, tostring(b), tostring(a)))
    end
end

--- Assert value is nil.
-- @param v    any
-- @param desc string
function ctld_test.assertNil(v, desc)
    ctld_test._total = ctld_test._total + 1
    if v == nil then
        ctld_test._passed = ctld_test._passed + 1
        _log(string.format("  OK     %s  [nil]", desc))
    else
        ctld_test._failed = ctld_test._failed + 1
        _log(string.format("  FAIL   %s  [expected nil, got %s]", desc, tostring(v)))
    end
end

--- Assert value is not nil.
-- @param v    any
-- @param desc string
function ctld_test.assertNotNil(v, desc)
    ctld_test._total = ctld_test._total + 1
    if v ~= nil then
        ctld_test._passed = ctld_test._passed + 1
        _log(string.format("  OK     %s  [%s]", desc, tostring(v)))
    else
        ctld_test._failed = ctld_test._failed + 1
        _log(string.format("  FAIL   %s  [expected not-nil, got nil]", desc))
    end
end

--- Flush, close, read and return the full content of CTLD.log.
-- Use this before any io.open(CTLD.log, "r") call in a test script to avoid
-- the write-handle lock (Windows blocks concurrent "r" open while "w" is held).
-- NOTE: after this call the log file handle is closed; remaining asserts still
--       appear in env.info but NOT in CTLD.log.
function ctld_test.readLog()
    if ctld.utils and ctld.utils.closeLog then
        ctld.utils.closeLog()
    end
    local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log", "r")
    local content = f and f:read("*a") or ""
    if f then f:close() end
    -- Reopen in append mode so finish() and remaining asserts still go to file
    if ctld.utils and ctld.utils.reopenLogAppend then
        ctld.utils.reopenLogAppend()
    end
    return content
end

--- Destroy all CTLD-spawned ground groups left over from previous test runs.
-- Must be called at the start of every functional test, after dofile("setup.lua")
-- and before dofile of any src module.
-- Targets groups whose name contains "CTLD_AA_" or "CTLD_VEH_" (naming conventions
-- used by CTLDCrateAssemblyManager and CTLDVehicleSpawner).
function ctld_test.cleanup()
    local destroyed = 0
    for _, side in ipairs({ coalition.side.BLUE, coalition.side.RED }) do
        local groups = coalition.getGroups(side, Group.Category.GROUND) or {}
        for _, grp in ipairs(groups) do
            local name = grp:getName()
            if name:find("CTLD_AA_", 1, true) or name:find("CTLD_VEH_", 1, true) then
                grp:destroy()
                destroyed = destroyed + 1
            end
        end
    end
    if destroyed > 0 then
        env.info(string.format("[CTLD_TEST] cleanup: destroyed %d leftover CTLD group(s)", destroyed))
    end
end

--- Destroy all Mine-N statics and F10 map marks left over from previous test runs.
--
-- Mark IDs are tracked in the DCS Lua global _CTLD_MINE_MARK_IDS (persists between
-- Witchcraft injections, survives dofile resets). Only previously registered IDs are
-- removed — avoids invalidating IDs that will be reused in the current run.
--
-- Call at the start of any M10 functional test, after all dofile() calls.
-- After spawning, call ctld_test.saveMineMarks() to register the new IDs.
function ctld_test.clearMines()
    -- Destroy leftover mine statics
    local destroyed = 0
    for i = 1, 500 do
        local obj = StaticObject.getByName("Mine-" .. i)
        if obj and obj:isExist() then
            obj:destroy()
            destroyed = destroyed + 1
        end
    end
    if destroyed > 0 then
        env.info(string.format("[CTLD_TEST] clearMines: destroyed %d leftover mine(s)", destroyed))
    end
    -- Remove only the F10 marks registered by the previous run
    _CTLD_MINE_MARK_IDS = _CTLD_MINE_MARK_IDS or {}
    local removed = 0
    for _, id in ipairs(_CTLD_MINE_MARK_IDS) do
        trigger.action.removeMark(id)
        removed = removed + 1
    end
    _CTLD_MINE_MARK_IDS = {}
    if removed > 0 then
        env.info(string.format("[CTLD_TEST] clearMines: removed %d leftover F10 mark(s)", removed))
    end
    -- Advance UniqIdCounter into a fresh range so the new run never reuses
    -- a just-deleted mark ID (DCS ignores quadToAll on a recently-deleted ID).
    _CTLD_ID_BASE = (_CTLD_ID_BASE or 0) + 10000
    if ctld and ctld.utils then
        ctld.utils.UniqIdCounter = _CTLD_ID_BASE
    end
    env.info(string.format("[CTLD_TEST] clearMines: ID counter offset to %d", _CTLD_ID_BASE))
end

--- Save the mark IDs created during this run so clearMines() can remove them next run.
-- Call after setLandMine/setLandMineAuto.
function ctld_test.saveMineMarks()
    _CTLD_MINE_MARK_IDS = {}
    if ctld and ctld.utils and ctld.utils.marks then
        for id, _ in pairs(ctld.utils.marks) do
            _CTLD_MINE_MARK_IDS[#_CTLD_MINE_MARK_IDS + 1] = id
        end
    end
    env.info(string.format("[CTLD_TEST] saveMineMarks: saved %d mark ID(s)", #_CTLD_MINE_MARK_IDS))
end

--- Return the first BLUE player unit, or nil.
-- On failure, logs a FAIL assert (counted in current test) and returns nil.
-- Caller must guard: if not transport then ctld_test.finish() return end
-- @return DCS Unit or nil
function ctld_test.getTransport()
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    if #units > 0 then return units[1] end
    ctld_test.assert(false, "ECHEC SETUP: aucun transport BLUE dans la mission")
    return nil
end

--- Finish the test case. Logs summary, final OK/KO, then closes the log file handle.
function ctld_test.finish()
    local verdict = (ctld_test._failed == 0) and "OK" or "KO"
    _log(string.format("END    [%s] %s — %d/%d passed  →  %s",
        ctld_test._caseId, ctld_test._caseName,
        ctld_test._passed, ctld_test._total,
        verdict))
    -- Flush and close the log file so the next test can purge and reopen it.
    if ctld.utils and ctld.utils.closeLog then
        ctld.utils.closeLog()
    end
end
