-- Enable debug and check step counter
ctld.debug = true
local cfg = CTLDConfig.get()
local _saved = cfg.settings["debug"]
cfg.settings["debug"] = true

local step = _G["_TFC_STEP"] or 1
trigger.action.outText("[DIAG] Current step=" .. step, 15)
log:write("step=" .. step .. "\n")

cfg.settings["debug"] = _saved