---@diagnostic disable
-- Diag Feature H: CTLDSmokeManager sanity check
local ok, sm = pcall(CTLDSmokeManager.getInstance)
if not ok or not sm then
    trigger.action.outText("FAIL: CTLDSmokeManager not available: " .. tostring(sm), 15)
    return "FAIL: no CTLDSmokeManager"
end

local unitName = "TEST_UNIT"

-- Initial state: should follow global default (false)
local state0 = sm:isActive(unitName)

-- Toggle once → true
local state1 = sm:toggle(unitName)

-- Register a fake smoke
sm:registerSmoke(unitName, {x=0, y=0, z=0}, trigger.smokeColor.Red)
local count1 = #(sm._players[unitName] and sm._players[unitName].smokes or {})

-- Toggle again → false
local state2 = sm:toggle(unitName)

-- Clear
sm:clearSmokes(unitName)
local count2 = #(sm._players[unitName] and sm._players[unitName].smokes or {})

-- Interval config
local interval = CTLDConfig.get().settings["smokeAutoResumeInterval"]

local msg = string.format(
    "SmokeManager OK | init=%s toggle1=%s count=%d toggle2=%s cleared=%d interval=%ss",
    tostring(state0), tostring(state1), count1, tostring(state2), count2, tostring(interval))
ctld.utils.log("INFO", "[diag_smoke_mgr] %s", msg)
trigger.action.outText(msg, 20)
return msg
