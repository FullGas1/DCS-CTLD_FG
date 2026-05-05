-- recette/patch_matchlayer_priority.lua
-- Fix: _matchLayer uses ALL layers (not just enabled) to enforce priority.
-- Prevents Mi-8MT falling through to "aircraft" when "helicopters" is OFF.
-- Prevents ZU-23 falling through to "ground_vehicles" when "air_defense" is OFF.

function CTLDReconManager:_matchLayer(unit, allLayers)
    for _, layer in ipairs(allLayers) do
        local ok, has = pcall(function() return unit:hasAttribute(layer.filterAttrib) end)
        if ok and has then
            return layer.enabled and layer or nil
        end
    end
    return nil
end

-- Also patch scan() to pass all layers instead of only enabled layers.
local _origScan = CTLDReconManager.scan
function CTLDReconManager:scan(playerUnit, player)
    if not ctld.gs("reconEnabled") then return end
    local pos    = playerUnit:getPoint()
    local ground = land.getHeight({ x = pos.x, y = pos.z })
    local agl    = pos.y - ground
    local minAlt = ctld.gs("reconMinAltitude") or 50
    if agl < minAlt then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("Altitude too low for recon scan (min %1 m)", minAlt), 10)
        return
    end
    local enabledLayers = self:_enabledLayers(player)
    if #enabledLayers == 0 then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("No recon layers enabled. Activate layers first."), 10)
        return
    end
    local prevScan = self._activeScans[player]
    if prevScan then
        if prevScan.refreshTimer then timer.removeFunction(prevScan.refreshTimer) end
        self:_removeAllMarks(prevScan)
    end
    local radius  = ctld.gs("reconSearchRadius") or 5000
    -- Pass ALL layers so _matchLayer enforces priority regardless of enabled state.
    local allLayers = self:_getPlayerLayers(player)
    local targets = self:_scanLOS(playerUnit, allLayers, radius)
    local targetsByLayer = {}
    for _, tgt in ipairs(targets) do
        local mid = self:_nextMark()
        tgt.markId = mid
        CTLDReconRenderer.createIcon(tgt, mid)
        local lid = tgt.layer.layerId
        targetsByLayer[lid] = (targetsByLayer[lid] or 0) + 1
    end
    self._activeScans[player] = {
        targets     = targets,
        layers      = enabledLayers,
        playerUnit  = playerUnit,
        autoRefresh = false,
        refreshTimer= nil,
    }
    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Recon scan complete. %1 targets detected.", #targets), 10)
    EventDispatcher.getInstance():publish("OnReconScan", {
        player=player, playerUnit=playerUnit, coalition=playerUnit:getCoalition(),
        position=pos, altitude=agl, searchRadius=radius,
        activeLayers=enabledLayers, targets=targets,
        targetsByLayer=targetsByLayer, totalTargetsDetected=#targets,
        totalMarksCreated=#targets, autoRefresh=true, timestamp=timer.getAbsTime(),
    })
    self:enableAutoRefresh(playerUnit, player, true)
    self:_rebuildReconBranch(player, playerUnit)
end

-- Also patch _doRefresh to use all layers.
local _origDoRefresh = CTLDReconManager._doRefresh
function CTLDReconManager:_doRefresh(playerName, unitName, _t)
    local scan = self._activeScans[playerName]
    if not scan or not scan.autoRefresh then return end
    local playerUnit = Unit.getByName(unitName)
    if not playerUnit or not playerUnit:isExist() then
        self:_removeAllMarks(scan); self._activeScans[playerName] = nil; return
    end
    local radius         = ctld.gs("reconSearchRadius") or 5000
    local currentTargets = self:_scanLOS(playerUnit, self:_getPlayerLayers(playerName), radius)
    local prevIndex = {}
    for _, tgt in ipairs(scan.targets) do prevIndex[tgt.unitName] = tgt end
    local newTargets, movedTargets, lostTargets = {}, {}, {}
    for _, tgt in ipairs(currentTargets) do
        local prev = prevIndex[tgt.unitName]
        if not prev then
            local mid = self:_nextMark(); tgt.markId = mid
            CTLDReconRenderer.createIcon(tgt, mid); tgt.status = "new"
            newTargets[#newTargets+1] = tgt
        else
            local d = ctld.utils.getDistance("_doRefresh", prev.position, tgt.position)
            if d > 5 then
                CTLDReconRenderer.removeIcon(prev.markId)
                local newMid = self:_nextMark(); tgt.markId = newMid
                CTLDReconRenderer.createIcon(tgt, newMid)
                tgt.status = "moved"; tgt.hasMoved = true; tgt.distanceMoved = d
                movedTargets[#movedTargets+1] = tgt
            else
                tgt.markId = prev.markId; tgt.status = "existing"
            end
            prevIndex[tgt.unitName] = nil
        end
    end
    for uName, prevTgt in pairs(prevIndex) do
        local reason = prevTgt.unit:isExist() and "out_of_los" or "dead"
        CTLDReconRenderer.removeIcon(prevTgt.markId)
        lostTargets[#lostTargets+1] = { unitName=uName, unitType=prevTgt.unitType,
            reason=reason, markId=prevTgt.markId }
    end
    scan.targets = currentTargets; scan.playerUnit = playerUnit
    local interval = ctld.gs("reconRefreshInterval") or 10
    local self_ref = self; local pN = playerName; local uN = unitName
    scan.refreshTimer = timer.scheduleFunction(function(_,t) self_ref:_doRefresh(pN,uN,t) end,
        nil, timer.getTime()+interval)
    EventDispatcher.getInstance():publish("OnReconScanRefresh", {
        player=playerName, playerUnit=playerUnit, coalition=playerUnit:getCoalition(),
        targets=currentTargets, newTargets=newTargets, movedTargets=movedTargets,
        lostTargets=lostTargets, totalTargets=#currentTargets, timestamp=timer.getAbsTime(),
    })
end

ctld.logInfo("patch_matchlayer_priority: _matchLayer + scan + _doRefresh patched — priority enforced")
return "PATCH OK — layer priority fix applied"
