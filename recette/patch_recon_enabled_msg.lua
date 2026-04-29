-- Hot-patch: scan() shows message when reconEnabled=false (session fix until next mission restart)
local _origScan = CTLDReconManager.scan
CTLDReconManager.scan = function(self, playerUnit, player)
    if not ctld.gs("reconEnabled") then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            "RECON is disabled (set reconEnabled=true in config).", 10)
        return
    end
    return _origScan(self, playerUnit, player)
end

-- Permanently enable RECON for this test session
CTLDConfig.get().settings["reconEnabled"]     = true
CTLDConfig.get().settings["reconMinAltitude"] = 0
return "patch_recon_enabled_msg OK — reconEnabled=true, reconMinAltitude=0"
