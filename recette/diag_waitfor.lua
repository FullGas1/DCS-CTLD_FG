-- Test ctld.utils.waitFor
-- Appel 1 : doit retourner false (démarre le timer)
-- Réinjecter après 5s : doit retourner true
local r = ctld.utils.waitFor("test_wf", 5)
local t = timer.getTime()
trigger.action.outText(string.format("waitFor result=%s  DCS_time=%.1f", tostring(r), t), 15)
return string.format("waitFor=%s DCS_time=%.1f", tostring(r), t)
