---@diagnostic disable
-- Diag Feature H: verify toggle + registerSmoke via simulated doSmoke
local sm  = CTLDSmokeManager.getInstance()
local cfg = CTLDConfig.get()

-- Get player unit
local pu = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not pu then return "FAIL: no BLUE player" end
local uName = pu:getName()

-- Simulate toggle activate
sm._players[uName] = nil  -- reset
local active = sm:isActive(uName)  -- should be false (global default)
ctld.utils.log("INFO", "[diag_smoke_menu] isActive before toggle: %s", tostring(active))

sm:toggle(uName)  -- activate
ctld.utils.log("INFO", "[diag_smoke_menu] isActive after toggle: %s", tostring(sm:isActive(uName)))

-- Simulate a smoke drop: get position
local pt  = pu:getPoint()
local pos = { x = pt.x, y = land.getHeight({ x = pt.x, y = pt.z }), z = pt.z }
trigger.action.smoke(pos, trigger.smokeColor.Green)
sm:registerSmoke(uName, pos, trigger.smokeColor.Green)

local count = #sm._players[uName].smokes
ctld.utils.log("INFO", "[diag_smoke_menu] registered smokes count=%d", count)

-- Verify timer re-trigger by fast-forwarding launchTime
sm._players[uName].smokes[1].launchTime = timer.getTime() - 300
sm:_tick()

local msg = string.format(
    "[Feature H] toggle+registerSmoke OK | unit=%s active=%s smokes=%d (tick fired green smoke)",
    uName, tostring(sm:isActive(uName)), count)
ctld.utils.log("INFO", "[diag_smoke_menu] %s", msg)
trigger.action.outText(msg, 20)
return msg
