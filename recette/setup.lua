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
