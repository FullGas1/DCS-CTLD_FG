-- recette/enable_debug.lua — enable CTLD debug logging to recette/CTLD.log
-- Inject via Witchcraft at the start of each recette session.
local logDir = "C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/"
CTLDConfig.get().settings["debug"]       = true
CTLDConfig.get().settings["ctldLogPath"] = logDir
ctld.utils.initLog()
ctld.logInfo("=== DEBUG MODE ENABLED — log: %sCTLD.log ===", logDir)
return "Debug enabled — CTLD.log → " .. logDir .. "CTLD.log"
