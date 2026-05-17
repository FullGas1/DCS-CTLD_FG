ctld.debug = true
local cfg = CTLDConfig.get()
local _saved = cfg.settings["debug"]
cfg.settings["debug"] = true
_G["_DEBUG_GS_SAVED"] = _saved

trigger.action.outText("[DIAG] debug activated, saved=" .. tostring(_saved), 15)