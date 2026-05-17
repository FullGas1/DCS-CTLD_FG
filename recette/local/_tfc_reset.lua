ctld.debug = true
local cfg = CTLDConfig.get()
local _saved = cfg.settings["debug"]
cfg.settings["debug"] = true
_G["_TFC_STEP"] = 1
_G["_TFC_SAVED"] = _saved
trigger.action.outText("[DIAG] _TFC_STEP=1 debug=on", 15)