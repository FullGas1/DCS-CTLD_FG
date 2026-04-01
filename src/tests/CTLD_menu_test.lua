---@diagnostic disable
-- CTLD_menu_test.lua
-- Test suite for ctld.Menu and ctld.MenuManager.
--
-- STRUCTURE:
--   T01-T20 : Pure memory-model tests (no DCS API required).
--             Run in any Lua 5.1 environment or in-mission.
--             Uses a lightweight mock for DCS globals.
--   T21-T23 : DCS integration checks (visual, in-mission only).
--             Load after CTLD and call runDCSChecks() from a mission trigger.
--
-- USAGE (in-mission):
--   DO SCRIPT FILE → CTLD_menu_test.lua
--   All T01-T20 results printed to DCS log and outText.
--   Call runDCSChecks() manually to execute T21-T23.

-- =============================================================================
-- Mock DCS globals (for T01-T20)
-- =============================================================================

-- Only mock what the menu module actually calls.
-- Real DCS calls are intercepted and recorded for assertion.

local _dcs_calls = {}   -- records every missionCommands call for inspection

missionCommands = missionCommands or {
    addSubMenuForGroup  = function(gId, name, path)
        table.insert(_dcs_calls, { fn = "addSubMenu",  groupId = gId, name = name, path = path })
    end,
    addCommandForGroup  = function(gId, name, path, fn, arg)
        table.insert(_dcs_calls, { fn = "addCommand", groupId = gId, name = name, path = path })
    end,
    removeItemForGroup  = function(gId, item)
        table.insert(_dcs_calls, { fn = "removeItem", groupId = gId })
    end,
}

-- ctld.tr mock: returns the key unchanged (acceptable for menu labels in tests).
ctld          = ctld or {}
ctld.tr       = ctld.tr or function(key, ...) return key end
ctld.logInfo  = ctld.logInfo  or function(fmt, ...) end
ctld.logWarning = ctld.logWarning or function(fmt, ...) end
ctld.logError = ctld.logError or function(fmt, ...) end

-- Unit / coalition mocks (used by _getGroupName / lookup helpers)
Unit      = Unit or { getByName = function() return nil end, getByID = function() return nil end }
coalition = coalition or { getGroups = function() return {} end }

-- =============================================================================
-- Minimal test harness
-- =============================================================================

local _pass, _fail, _results = 0, 0, {}

local function assert_true(label, cond)
    if cond then
        _pass = _pass + 1
        table.insert(_results, "  PASS  " .. label)
    else
        _fail = _fail + 1
        table.insert(_results, "  FAIL  " .. label)
        ctld.logError("CTLD_menu_test FAIL: %s", label)
    end
end

local function assert_eq(label, got, expected)
    assert_true(label .. string.format(" (got=%s expected=%s)", tostring(got), tostring(expected)),
        got == expected)
end

local function assert_false(label, cond) assert_true(label, not cond) end

local function section(title)
    table.insert(_results, "\n--- " .. title .. " ---")
end

-- Reset the singleton and DCS call log between test groups.
local function resetManager()
    ctld.MenuManager._instance = nil
    _dcs_calls = {}
end

-- =============================================================================
-- T01-T05 : Singleton and menu creation
-- =============================================================================

section("T01-T05: Singleton and menu creation")
resetManager()

local mgr1 = ctld.MenuManager:getInstance()
local mgr2 = ctld.MenuManager:getInstance()
assert_true("T01: getInstance() always returns the same object", mgr1 == mgr2)

local menu = mgr1:createMenuForGroup(100)
assert_true("T02: createMenuForGroup returns non-nil", menu ~= nil)
assert_eq("T03: menu.groupId is correct", menu.groupId, 100)

local menu2 = mgr1:createMenuForGroup(100)
assert_true("T04: createMenuForGroup idempotent (returns existing)", menu == menu2)

local menuB = mgr1:createMenuForGroup(200)
assert_true("T05: two different groupIds produce independent menus", menu ~= menuB)

-- =============================================================================
-- T06-T09 : addSubMenu
-- =============================================================================

section("T06-T09: addSubMenu")
resetManager()
local m = ctld.MenuManager:getInstance():createMenuForGroup(1)

local r1 = m:addSubMenu({}, "CTLD Commands")
assert_true("T06: addSubMenu root returns success", r1.success)

local r2 = m:addSubMenu({}, "CTLD Commands")
assert_true("T07: addSubMenu idempotent (same path+name returns success)", r2.success)
assert_eq("T07b: children count unchanged after duplicate addSubMenu", #m.children, 1)

local r3 = m:addSubMenu({"CTLD Commands"}, "Troops")
assert_true("T08: addSubMenu nested returns success", r3.success)

local r4 = m:addSubMenu({}, "Bad", nil)   -- opts = nil is allowed
assert_true("T09: addSubMenu with nil opts is accepted", r4.success)

-- =============================================================================
-- T10-T13 : addCommand
-- =============================================================================

section("T10-T13: addCommand")
resetManager()
local m = ctld.MenuManager:getInstance():createMenuForGroup(2)
m:addSubMenu({}, "CTLD Commands")
m:addSubMenu({"CTLD Commands"}, "Troops")

local dummyFn = function(arg) end

local r1 = m:addCommand({"CTLD Commands", "Troops"}, "Infantry", dummyFn, { size = 6 })
assert_true("T10: addCommand valid returns success", r1.success)

local r2 = m:addCommand({"CTLD Commands", "Troops"}, "BadArg", dummyFn, "not_a_table")
assert_false("T11: addCommand with non-table anyArgument returns failure", r2.success)

local r3 = m:addCommand({"CTLD Commands", "Troops"}, "NoFn", nil, {})
assert_false("T12: addCommand with nil function returns failure", r3.success)

-- Try to add a command under another command (must fail)
local r4 = m:addCommand({"CTLD Commands", "Troops", "Infantry"}, "Sub", dummyFn, {})
assert_false("T13: addCommand under a command node returns failure", r4.success)

-- =============================================================================
-- T14-T16 : clearBranch
-- =============================================================================

section("T14-T16: clearBranch")
resetManager()
local m = ctld.MenuManager:getInstance():createMenuForGroup(3)
m:addSubMenu({}, "CTLD Commands", { order = 100 })
m:addSubMenu({"CTLD Commands"}, "Pack Vehicles", { order = 30 })
m:addCommand({"CTLD Commands", "Pack Vehicles"}, "M1 Abrams", dummyFn, {})
m:addCommand({"CTLD Commands", "Pack Vehicles"}, "HMMWV",     dummyFn, {})

-- Verify initial state
local packNode = m:_getNode({"CTLD Commands", "Pack Vehicles"})
assert_eq("T14: before clearBranch, children count = 2", #packNode.children, 2)

local rc = m:clearBranch({"CTLD Commands", "Pack Vehicles"})
assert_true("T15: clearBranch returns success", rc.success)
assert_eq("T15b: after clearBranch, children count = 0", #packNode.children, 0)

-- The container node itself must still exist in its parent (ORDER preserved)
local ctldNode = m:_getNode({"CTLD Commands"})
local stillExists = false
for _, child in ipairs(ctldNode.children) do
    if child.name == "Pack Vehicles" then stillExists = true; break end
end
assert_true("T16: clearBranch keeps the container node in its parent (ORDER preserved)", stillExists)

-- =============================================================================
-- T17-T18 : setBranchEnabled
-- =============================================================================

section("T17-T18: setBranchEnabled")
resetManager()
local m = ctld.MenuManager:getInstance():createMenuForGroup(4)
-- ORDER usage: FOB at position 40, disabled at init (feature unlocked mid-mission)
m:addSubMenu({}, "CTLD Commands", { order = 100 })
m:addSubMenu({"CTLD Commands"}, "Troops",   { order = 10 })
m:addSubMenu({"CTLD Commands"}, "FOB",      { order = 40, enabled = false })

local fobNode = m:_getNode({"CTLD Commands", "FOB"})
assert_false("T17: FOB initially disabled", fobNode.enabled)

m:setBranchEnabled({"CTLD Commands", "FOB"}, true)
assert_true("T18: setBranchEnabled(true) toggles the flag", fobNode.enabled)

-- =============================================================================
-- T19-T20 : removeMenuBranch
-- =============================================================================

section("T19-T20: removeMenuBranch")
resetManager()
local m = ctld.MenuManager:getInstance():createMenuForGroup(5)
m:addSubMenu({}, "CTLD Commands")
m:addSubMenu({"CTLD Commands"}, "Troops")
m:addCommand({"CTLD Commands", "Troops"}, "Infantry", dummyFn, {})
m:addCommand({"CTLD Commands", "Troops"}, "AntiAir",  dummyFn, {})

local rr = m:removeMenuBranch({"CTLD Commands", "Troops"})
assert_true("T19: removeMenuBranch returns success", rr.success)
assert_eq("T19b: removedCount = 3 (1 submenu + 2 commands)", rr.removedCount, 3)

local gone = m:_getNode({"CTLD Commands", "Troops"})
assert_true("T20: node is absent from memory after removeMenuBranch", gone == nil)

-- =============================================================================
-- T21 : ORDER sorting — DCS render order follows order field, not insertion order
-- =============================================================================

section("T21: ORDER sorting in rebuild")
resetManager()
_dcs_calls = {}
local m = ctld.MenuManager:getInstance():createMenuForGroup(6)
-- Insert in reverse order; DCS should receive them in order 10, 20, 30.
m:addSubMenu({}, "CTLD Commands")
m:addSubMenu({"CTLD Commands"}, "FOB",    { order = 30 })
m:addSubMenu({"CTLD Commands"}, "Troops", { order = 10 })
m:addSubMenu({"CTLD Commands"}, "Crates", { order = 20 })
m:refresh()

-- Collect addSubMenu calls for groupId=6 under CTLD Commands (path = {"CTLD Commands"})
local childCalls = {}
for _, c in ipairs(_dcs_calls) do
    if c.fn == "addSubMenu" and c.path and c.path[1] == "CTLD Commands" then
        table.insert(childCalls, c.name)
    end
end
assert_eq("T21a: first child rendered = Troops (order=10)",  childCalls[1], "Troops")
assert_eq("T21b: second child rendered = Crates (order=20)", childCalls[2], "Crates")
assert_eq("T21c: third child rendered = FOB    (order=30)",  childCalls[3], "FOB")

-- =============================================================================
-- T22 : PAGINATION — more than 10 items produces "→ Next Page" at F10
-- =============================================================================

section("T22: Pagination")
resetManager()
_dcs_calls = {}
local m = ctld.MenuManager:getInstance():createMenuForGroup(7)
m:addSubMenu({}, "CTLD Commands")
m:addSubMenu({"CTLD Commands"}, "Vehicles")
-- Add 13 commands → page 1: 9 items + "→ Next Page", page 2: 4 items (no pagination)
for i = 1, 13 do
    m:addCommand({"CTLD Commands", "Vehicles"}, "Vehicle_" .. i, dummyFn, {})
end
m:refresh()

-- Count items rendered directly under {"CTLD Commands", "Vehicles"} path
local vehiclePath = {"CTLD Commands", "Vehicles"}
local directItems = 0
local hasNextPage = false
for _, c in ipairs(_dcs_calls) do
    if c.path then
        local match = (#c.path == #vehiclePath)
        if match then
            for i, seg in ipairs(vehiclePath) do
                if c.path[i] ~= seg then match = false; break end
            end
        end
        if match then
            if c.name == ctld.tr("→ Next Page") then
                hasNextPage = true
            else
                directItems = directItems + 1
            end
        end
    end
end
assert_eq("T22a: 9 items rendered on page 1 (F1-F9)", directItems, 9)
assert_true("T22b: '→ Next Page' submenu inserted at F10", hasNextPage)

-- =============================================================================
-- T23 : ENABLED — disabled node absent from DCS rebuild
-- =============================================================================

section("T23: Enabled flag in rebuild")
resetManager()
_dcs_calls = {}
local m = ctld.MenuManager:getInstance():createMenuForGroup(8)
m:addSubMenu({}, "CTLD Commands")
m:addSubMenu({"CTLD Commands"}, "Troops",   { order = 10 })
m:addSubMenu({"CTLD Commands"}, "FOB",      { order = 20, enabled = false })
m:addSubMenu({"CTLD Commands"}, "Beacons",  { order = 30 })
m:refresh()

local rendered = {}
for _, c in ipairs(_dcs_calls) do
    if c.fn == "addSubMenu" and c.path and c.path[1] == "CTLD Commands" then
        rendered[c.name] = true
    end
end
assert_true("T23a: Troops rendered (enabled)",    rendered["Troops"]  == true)
assert_true("T23b: FOB not rendered (disabled)",  rendered["FOB"]     == nil)
assert_true("T23c: Beacons rendered (enabled)",   rendered["Beacons"] == true)

-- =============================================================================
-- Report
-- =============================================================================

local summary = string.format(
    "\nCTLD_menu_test: %d PASS / %d FAIL / %d TOTAL",
    _pass, _fail, _pass + _fail
)
table.insert(_results, summary)

local report = table.concat(_results, "\n")
ctld.logInfo(report)
if trigger and trigger.action then
    trigger.action.outText(summary, 10)
end

-- =============================================================================
-- T_DCS21-T_DCS23 : Visual DCS checks (call manually from mission trigger)
-- =============================================================================

-- These tests require a live DCS mission and a real helicopter group named "h1-1".
-- They cannot be automated — verify the F10 menu visually after each call.

function runDCSChecks()
    local unit = Unit.getByName("h1-1")
    if not unit then
        trigger.action.outText("runDCSChecks: unit 'h1-1' not found", 10)
        return
    end
    local groupId = unit:getGroup():getID()
    local mgr     = ctld.MenuManager:getInstance()
    local menu    = mgr:createMenuForGroup(groupId)

    -- T_DCS21: Basic menu visible in F10 after refresh()
    menu:addSubMenu({}, "CTLD Commands", { order = 100 })
    menu:addSubMenu({"CTLD Commands"}, "Troops",        { order = 10 })
    menu:addSubMenu({"CTLD Commands"}, "Crates",        { order = 20 })
    menu:addSubMenu({"CTLD Commands"}, "Pack Vehicles", { order = 30 })
    menu:addSubMenu({"CTLD Commands"}, "FOB",           { order = 40, enabled = false })
    menu:refresh()
    trigger.action.outText(
        "T_DCS21: menu built. Check F10:\n" ..
        "  CTLD Commands → Troops / Crates / Pack Vehicles\n" ..
        "  FOB must NOT appear (disabled).", 15)

    -- T_DCS22: double refresh() is idempotent
    menu:refresh()
    trigger.action.outText("T_DCS22: second refresh(). Menu must look identical.", 10)

    -- T_DCS23: enable FOB mid-mission + clearBranch + re-add + refresh
    timer.scheduleFunction(function()
        menu:setBranchEnabled({"CTLD Commands", "FOB"}, true)
        menu:clearBranch({"CTLD Commands", "Pack Vehicles"})
        for i = 1, 11 do
            menu:addCommand({"CTLD Commands", "Pack Vehicles"}, "Vehicle_" .. i,
                function(arg) end, { id = i })
        end
        menu:refresh()
        trigger.action.outText(
            "T_DCS23: FOB now enabled, Pack Vehicles has 11 items (pagination expected).\n" ..
            "Check F10: FOB appears, Pack Vehicles shows 9 + Next Page.", 15)
    end, {}, timer.getTime() + 5)
end
