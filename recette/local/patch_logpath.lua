---@diagnostic disable
-- Restore ctldLogPath after CTLD_Next re-injection.
-- The mission trigger sets ctldLogPath at MISSION START, but a Witchcraft
-- re-injection creates a fresh CTLDConfig with empty ctldLogPath.
-- Inject this script immediately after each CTLD_Next injection.
local cfg = CTLDConfig.get()
cfg.settings["debug"]             = true
cfg.settings["debugScreenLog"]    = false
cfg.settings["ctldLogPath"]       = "C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/"

ctld.utils.closeLog()
ctld.utils.reopenLogAppend()

ctld.utils.log("INFO", "[patch_logpath] ctldLogPath restored, debug=true")
trigger.action.outText("[patch_logpath] log restored OK", 10)
return "patch_logpath OK"
