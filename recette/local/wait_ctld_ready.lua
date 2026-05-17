-- wait_ctld_ready.lua
-- Script à injecter AVANT tout scenario si CTLD n'est pas encore initialisé
-- Retry jusqu'à ce que CTLDTroopManager soit disponible (max ~20s)
ctld.debug = true
local cfg = CTLDConfig.get()
local _saved = cfg.settings["debug"]
cfg.settings["debug"] = true

local MAX_ATTEMPTS = 20
local ATTEMPT = _G["_WCR_ATTEMPT"] or 0
_G["_WCR_ATTEMPT"] = ATTEMPT + 1

ctld.utils.log("INFO", "[wait_ctld] attempt " .. ATTEMPT .. "/max " .. MAX_ATTEMPTS)

local tm_ok = pcall(function() return CTLDTroopManager.getInstance() end)
local jm_ok = pcall(function() return CTLDJTACManager.getInstance() end)

ctld.utils.log("INFO", "[wait_ctld] CTLDTroopManager=" .. tostring(tm_ok) .. " CTLDJTACManager=" .. tostring(jm_ok))

if tm_ok and jm_ok then
    trigger.action.outText("[WAIT-CTLD] Ready! (attempt " .. ATTEMPT .. ")", 15)
    ctld.utils.log("INFO", "[wait_ctld] CTLD fully initialized after " .. ATTEMPT .. " attempts")
    _G["_WCR_ATTEMPT"] = nil
else
    if ATTEMPT >= MAX_ATTEMPTS then
        trigger.action.outText("[WAIT-CTLD] TIMEOUT — CTLD not ready after " .. MAX_ATTEMPTS .. " attempts", 30)
        ctld.utils.log("ERROR", "[wait_ctld] TIMEOUT after " .. MAX_ATTEMPTS .. " attempts")
    else
        trigger.action.outText("[WAIT-CTLD] Waiting... attempt " .. ATTEMPT, 5)
    end
end

cfg.settings["debug"] = _saved