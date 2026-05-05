---@diagnostic disable
-- =============================================================================
-- TEMPLATE : scenario_<nom>.lua
-- Injectable test scenario for DCS via Witchcraft
--
-- HOW TO USE THIS TEMPLATE:
--   1. Copy this file to recette/scenarios/scenario_<nom>.lua
--   2. Replace all SCENARIO_TAG with a unique short tag (e.g. TFC, RECON, BCN)
--   3. Add your test steps in the step machine below
--   4. Execute: node bridge.js "recette/scenarios/scenario_<nom>.lua"
--
-- PROTOCOL (always follow this order):
--   - ctldLogPath must be set via mission .miz MISSION START trigger (PRIVATE, not in repo)
--   - Debug ON:  cfg.settings["debug"] = true     (NOT ctld.debug = true)
--   - Debug OFF: cfg.settings["debug"] = _saved_debug  (ALWAYS restored, even on error)
--
-- RETURN VALUE (Witchcraft stdout):
--   "[SCENARIO_TAG] step=N SUCCESS (Xms)"   — step completed
--   "[SCENARIO_TAG] step=N FAIL: <msg>"     — fail() or assert failed
--   "[SCENARIO_TAG] step=N INCOMPLETE"      — no branch matched (counter drift)
--   "[SCENARIO_TAG] ALL SUCCESS"            — final step reached
-- =============================================================================

-- ── DEBUG ACTIVATION ──────────────────────────────────────────────────────────
local cfg = CTLDConfig.get()
local _saved_debug = cfg.settings["debug"]
cfg.settings["debug"] = true

-- ── METADATA ──────────────────────────────────────────────────────────────────
local TAG    = "[SCENARIO_TAG]"
local START  = os.date("%Y-%m-%d %H:%M:%S")
local STEP_N = "_SCENARIO_TAG_STEP"  -- global key (persists across Witchcraft injections)

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

--- Logs a failure with Lua stack trace, then aborts the step via error().
--- Caught by the pcall wrapper below — cleanup always runs.
local function fail(msg)
    local trace = debug.traceback(msg, 2)
    trigger.action.outText(TAG .. " !! FAIL: " .. msg, 60)
    log("FAIL: " .. trace)
    error(msg)
end

--- Structured check: logs PASS or triggers fail() with expected vs actual.
--- id should map to F-xx / U-xx case (e.g. "F-33.1").
local function check(id, desc, condition, details)
    if condition then
        pass(id .. " — " .. desc)
    else
        fail(id .. " — " .. desc .. (details and (" | " .. details) or ""))
    end
end

--- Equality assertion — formats expected/actual automatically.
local function assert_eq(id, actual, expected)
    check(id, "eq", actual == expected,
        "expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
end

--- Not-nil assertion.
local function assert_not_nil(id, val, desc)
    check(id, desc or "not nil", val ~= nil, "got nil")
end

-- ── STATE MACHINE ─────────────────────────────────────────────────────────────

_G[STEP_N] = _G[STEP_N] or 1
local step = _G[STEP_N]

-- Start banner: screen + CTLD.log, timestamp differentiates successive calls
report("==== START " .. START .. " | step=" .. step .. " ====")

-- P1 — At step 1: truncate CTLD.log for a clean run (no stale lines from previous runs)
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

-- P5 — Step timer
local _step_start = os.clock()

local _result = "INCOMPLETE"

local _ok, _err = pcall(function()

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 1 — [description]
-- Expected: [what should happen]
-- ══════════════════════════════════════════════════════════════════════════════
if step == 1 then

    -- TODO: your test code here
    -- check("F-xx.1", "description", condition, tostring(actual))
    -- assert_eq("F-xx.2", actual, expected)
    -- assert_not_nil("F-xx.3", obj, "obj exists")

    pass("Step 1 — [description]. Re-inject for Step 2.")
    _G[STEP_N] = 2
    _result = "step=1 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 2 — [description]
-- Expected: [what should happen]
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 2 then

    -- TODO: your test code here

    pass("Step 2 — [description]. Re-inject for Step 3.")
    _G[STEP_N] = 3
    _result = "step=2 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP FINAL — Summary report
-- ══════════════════════════════════════════════════════════════════════════════
elseif step >= 99 then

    report("═══════════════════════════════════════")
    report("SCENARIO_TAG — All steps complete")
    report("═══════════════════════════════════════")

    _G[STEP_N] = 1  -- reset for next run
    _result = "ALL SUCCESS"

-- P3 — INCOMPLETE guard: no branch matched (step counter drift or missing elseif)
else
    fail("step=" .. step .. " has no matching branch — reset with _reset_steps.lua or add elseif")
end

end)  -- end pcall

-- ── CLEANUP (always executed — debug restored even if fail() was called) ──────
cfg.settings["debug"] = _saved_debug

-- ── WITCHCRAFT RETURN VALUE ───────────────────────────────────────────────────
-- P5 — Include elapsed time in SUCCESS returns
local _ms = math.floor((os.clock() - _step_start) * 1000)

if not _ok then
    return TAG .. " step=" .. step .. " FAIL: " .. tostring(_err)
end
if _result == "ALL SUCCESS" then
    return TAG .. " " .. _result .. " (" .. _ms .. "ms)"
end
return TAG .. " " .. _result:gsub("SUCCESS", "SUCCESS (" .. _ms .. "ms)")
