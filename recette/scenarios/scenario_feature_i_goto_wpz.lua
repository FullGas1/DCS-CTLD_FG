---@diagnostic disable
-- =============================================================================
-- scenario_feature_i_goto_wpz.lua
-- Feature I — Post-spawn task: "gotoNearestWPZ"
--
-- Verifies that a spawned troop group is ordered to march to the nearest WPZ
-- when its template has specificParams = { task = "gotoNearestWPZ" }.
--
-- Protocol:
--   Step 1 — Inject mock WPZ zone, spawn BLUE ground group, call _assignPostSpawnTask
--   Step 2 — (inject 3s later) Verify CTLD.log contains assignment confirmation
--   Step 3 — Cleanup
--
-- Pre-requisites:
--   - BLUE player slot occupied (any aircraft)
--   - CTLD fully initialised (inject CTLD_Next.lua + 5s wait before this scenario)
--   - recette/enable_debug.lua injected before this scenario
-- =============================================================================

local cfg = CTLDConfig.get()
local _saved_debug = cfg.settings["debug"]
cfg.settings["debug"] = true

local TAG    = "[FI-WPZ]"
local START  = os.date("%Y-%m-%d %H:%M:%S")
local STEP_N = "_FI_WPZ_STEP"

local GRP_NAME    = "FI_WPZ_TestGroup"
local ZONE_NAME   = "FI_WPZ_MockZone"
local WPZ_OFFSET  = 600   -- WPZ injected 600 m north of player

local function log(msg)
    ctld.utils.log("INFO", TAG .. " " .. msg)
end
local function report(msg)
    trigger.action.outText(TAG .. " " .. msg, 30)
    log(msg)
end
local function pass(msg)  report("[PASS] " .. msg) end
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

-- ── CLEANUP ───────────────────────────────────────────────────────────────────
local function cleanup()
    -- Remove mock WPZ from zone manager
    local zm = CTLDZoneManager.getInstance()
    if zm and zm._troopZones then
        zm._troopZones[ZONE_NAME] = nil
    end
    -- Destroy test group
    local grp = Group.getByName(GRP_NAME)
    if grp and grp:isExist() then grp:destroy() end
    log("cleanup done")
end

-- ── PLAYER RESOLUTION ─────────────────────────────────────────────────────────
local playerUnit = nil
for attempt = 1, 5 do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    if #units > 0 and units[1]:isExist() then
        playerUnit = units[1]; break
    end
    local t = os.clock() + 0.5; while os.clock() < t do end
end
if not playerUnit or not playerUnit:isExist() then
    cfg.settings["debug"] = _saved_debug
    return TAG .. " ABORT: no BLUE player"
end

-- ── STATE MACHINE ─────────────────────────────────────────────────────────────
_G[STEP_N] = _G[STEP_N] or 1
local step = _G[STEP_N]
report("==== START " .. START .. " | step=" .. step .. " ====")

if step == 1 then pcall(function()
    ctld.utils.closeLog()
    local f = io.open((cfg.settings["ctldLogPath"] or "") .. "CTLD.log", "w")
    if f then f:write("[" .. START .. "] === LOG RESET ===\n"); f:close() end
    ctld.utils.reopenLogAppend()
end) end

local _step_start = os.clock()
local _result = "INCOMPLETE"
local _ok, _err = pcall(function()

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 1 — Setup: inject WPZ, spawn group, call _assignPostSpawnTask
-- ══════════════════════════════════════════════════════════════════════════════
if step == 1 then
    cleanup()

    local pPos     = playerUnit:getPoint()
    local spawnPt  = { x = pPos.x, y = land.getHeight({ x = pPos.x, y = pPos.z }), z = pPos.z }
    local wpzCenter = { x = pPos.x + WPZ_OFFSET, y = 0, z = pPos.z }
    wpzCenter.y = land.getHeight({ x = wpzCenter.x, y = wpzCenter.z })

    -- Inject a mock WPZ CTLDTroopZone into the zone manager
    local zm = CTLDZoneManager.getInstance()
    check("FI-WPZ.1.1", "CTLDZoneManager available", zm ~= nil)

    local mockZone = CTLDTroopZone:new({
        dcsName    = ZONE_NAME,
        zoneName   = ZONE_NAME,
        coalition  = coalition.side.BLUE,
        center     = wpzCenter,
        radius     = 300,
        isWaypoint = true,
        active     = true,
    })
    zm._troopZones[ZONE_NAME] = mockZone
    log("Mock WPZ injected at (" .. wpzCenter.x .. ", " .. wpzCenter.z .. ")")

    -- Verify getNearestWaypointZone finds our mock zone
    local found = zm:getNearestWaypointZone(spawnPt, coalition.side.BLUE)
    check("FI-WPZ.1.2", "getNearestWaypointZone returns mock WPZ",
        found ~= nil and found.zoneName == ZONE_NAME,
        "got " .. tostring(found and found.zoneName))

    -- Spawn a real DCS BLUE ground group at player position
    local country = playerUnit:getCountry()
    local grpData = {
        name  = GRP_NAME,
        task  = "Ground Nothing",
        units = {
            { name = GRP_NAME .. "_u1", type = "Soldier M4",
              x = spawnPt.x, y = spawnPt.z, heading = 0, skill = "High",
              playerCanDrive = false, unitId = math.random(90000, 99999) },
        },
    }
    local spawnedGrp = coalition.addGroup(country, Group.Category.GROUND, grpData)
    check("FI-WPZ.1.3", "test group spawned", spawnedGrp ~= nil)

    -- Call _assignPostSpawnTask (scheduled +2s)
    CTLDTroopManager.getInstance():_assignPostSpawnTask(
        GRP_NAME, spawnPt, coalition.side.BLUE, { task = "gotoNearestWPZ" })
    log("_assignPostSpawnTask called — task will execute in 2s")

    pass("Step 1 OK — re-inject in 3s+ for Step 2")
    _G[STEP_N] = 2
    _result = "step=1 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 2 — Verify CTLD.log + group alive
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 2 then
    -- Read CTLD.log and check for assignment confirmation
    local logPath = (cfg.settings["ctldLogPath"] or "") .. "CTLD.log"
    local f = io.open(logPath, "r")
    local logContent = f and f:read("*a") or ""
    if f then f:close() end

    local hasWPZLog = logContent:find("_assignPostSpawnTask.*gotoNearestWPZ", 1, false)
                   or logContent:find("_assignPostSpawnTask.*" .. ZONE_NAME, 1, false)
    check("FI-WPZ.2.1", "CTLD.log confirms WPZ task assignment",
        hasWPZLog ~= nil, "pattern not found in CTLD.log")

    -- Verify group still exists
    local grp = Group.getByName(GRP_NAME)
    check("FI-WPZ.2.2", "test group still alive after task assignment", grp ~= nil and grp:isExist())

    pass("Step 2 OK — gotoNearestWPZ task confirmed. Re-inject for cleanup.")
    _G[STEP_N] = 99
    _result = "step=2 SUCCESS"

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP FINAL — Cleanup + Summary
-- ══════════════════════════════════════════════════════════════════════════════
elseif step >= 99 then
    cleanup()
    report("═══════════════════════════════════")
    report("FI-WPZ — ALL STEPS COMPLETE")
    report("═══════════════════════════════════")
    _G[STEP_N] = 1
    _result = "ALL SUCCESS"
else
    fail("step=" .. step .. " has no matching branch")
end

end)  -- end pcall

cfg.settings["debug"] = _saved_debug
local _ms = math.floor((os.clock() - _step_start) * 1000)
if not _ok then return TAG .. " step=" .. step .. " FAIL: " .. tostring(_err) end
if _result == "ALL SUCCESS" then return TAG .. " " .. _result .. " (" .. _ms .. "ms)" end
return TAG .. " " .. _result:gsub("SUCCESS", "SUCCESS (" .. _ms .. "ms)")
