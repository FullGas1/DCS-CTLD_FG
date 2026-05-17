-- Test unitaire : debug via ctld.gs("debug") only
-- Protocole : CTLDConfig.get().settings["debug"] = true → restore en fin

ctld.debug = true
local TAG = "[debug_gs_test]"

local cfg = CTLDConfig.get()
local saved_debug = cfg.settings["debug"]

local function log(msg)
    ctld.utils.log("INFO", TAG .. " " .. msg)
end

log("==== START ====")
log("saved debug = " .. tostring(saved_debug))

cfg.settings["debug"] = true
log("debug ACTIVATED via settings[\"debug\"] = true")
log("ctld.gs(\"debug\") = " .. tostring(ctld.gs("debug")))

trigger.action.outText("[DEBUG-GS] Test OK — ctld.log vérifie [debug_gs_test]", 30)

_G["_DEBUG_GS_SAVED"] = saved_debug
_G["_DEBUG_GS_STEP"] = 2