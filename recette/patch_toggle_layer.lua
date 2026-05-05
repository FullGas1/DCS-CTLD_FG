-- recette/patch_toggle_layer.lua
-- Fix toggleLayer: avoid double rebuild + call scan() with config radius
-- (air/ship units must be within reconSearchRadius for toggle re-detection to work)

function CTLDReconManager:toggleLayer(player, playerUnit, layerId)
    local layer = self:_findLayer(player, layerId)
    if not layer then
        ctld.utils.log("WARN", "CTLDReconManager:toggleLayer: unknown layerId '%s'", tostring(layerId))
        return
    end

    layer.enabled = not layer.enabled
    local state   = layer.enabled and "ON" or "OFF"

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Recon layer '%1': %2", layer.name, state), 10)

    -- Re-scan if active. scan() handles its own menu rebuild.
    local didScan = false
    if self._activeScans[player] then
        self:scan(playerUnit, player)
        didScan = true
    end

    EventDispatcher.getInstance():publish("OnReconLayerToggled", {
        layerId   = layer.layerId,
        layerName = layer.name,
        visible   = layer.enabled,
        coalition = playerUnit:getCoalition(),
        player    = player,
        timestamp = timer.getAbsTime(),
    })

    if not didScan then
        self:_rebuildReconBranch(player, playerUnit)
    end
end

ctld.logInfo("toggleLayer patched: no double rebuild")
return "PATCH OK — toggleLayer fixed"
