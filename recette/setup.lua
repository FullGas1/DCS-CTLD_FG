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

-- Apply test configuration before loading utils
CTLDConfig.get():load()

-- Override log path so utils writes to recette/CTLD.log
ctld = ctld or {}
ctld.debug    = true
ctldLogPath   = LOG_PATH   -- global used by ctld.utils.initLog()

dofile(SRC .. "CTLD_utils.lua")
dofile(SRC .. "CTLD_i18n.lua")
dofile(SRC .. "CTLD_i18n_en.lua")

-- Re-apply log path in case CTLD_utils reinitialised it
ctldLogPath = LOG_PATH

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

--- Finish the test case. Logs summary and final OK/KO.
function ctld_test.finish()
    local verdict = (ctld_test._failed == 0) and "OK" or "KO"
    _log(string.format("END    [%s] %s — %d/%d passed  →  %s",
        ctld_test._caseId, ctld_test._caseName,
        ctld_test._passed, ctld_test._total,
        verdict))
end
