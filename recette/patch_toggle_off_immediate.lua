-- Hot-patch: scan() removes marks immediately even when no layers are enabled.
-- Fixes: toggling last active layer OFF leaves marks until next _doRefresh tick.
local _origScan = CTLDReconManager.scan
CTLDReconManager.scan = function(self, playerUnit, player)
    if not ctld.gs("reconEnabled") then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            "RECON is disabled (set reconEnabled=true in config).", 10)
        return
    end

    -- Altitude check
    local pos    = playerUnit:getPoint()
    local ground = land.getHeight({ x = pos.x, y = pos.z })
    local agl    = pos.y - ground
    local minAlt = ctld.gs("reconMinAltitude") or 50
    if agl < minAlt then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            string.format("Altitude too low for recon scan (min %d m)", minAlt), 10)
        return
    end

    -- Cancel previous timer + remove marks BEFORE any early-return (key fix).
    local prevScan = self._activeScans[player]
    if prevScan then
        if prevScan.refreshTimer then timer.removeFunction(prevScan.refreshTimer) end
        for _, tgt in ipairs(prevScan.targets or {}) do
            CTLDReconRenderer.removeIcon(tgt.markId)
        end
        self._activeScans[player] = nil
    end

    local enabledLayers = self:_enabledLayers(player)
    if #enabledLayers == 0 then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            "No recon layers enabled. Activate layers first.", 10)
        self:_rebuildReconBranch(player, playerUnit)
        return
    end

    -- Continue with original scan (re-assign _activeScans inside original)
    return _origScan(self, playerUnit, player)
end

return "patch_toggle_off_immediate OK — toggle OFF now clears marks instantly"
