---@diagnostic disable
-- Verify singleton identity and tick consistency
local sm1 = CTLDSmokeManager.getInstance()
local sm2 = CTLDSmokeManager.getInstance()
local same = (sm1 == sm2)

sm1:toggle("_test_unit_")
sm1:registerSmoke("_test_unit_", {x=0,y=0,z=0}, trigger.smokeColor.Green)

for _, s in ipairs(sm2._players["_test_unit_"] and sm2._players["_test_unit_"].smokes or {}) do
    s.launchTime = timer.getTime() - 9999
end
sm2:_tick()

local count = sm1._players["_test_unit_"] and #sm1._players["_test_unit_"].smokes or 0
sm1._players["_test_unit_"] = nil

local msg = string.format("[singleton] sm1==sm2: %s | smokes after tick=%d", tostring(same), count)
trigger.action.outText(msg, 20)
return msg
