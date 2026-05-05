-- recette/patch_dorefresh_markid.lua
-- Fix: _doRefresh "existing" targets must carry forward prev.markId
-- so stopScan / _removeAllMarks can remove them.
-- Bug: tgt.markId was nil for unchanged targets → removeIcon(nil) was a noop.

local _origDoRefresh = CTLDReconManager._doRefresh
function CTLDReconManager:_doRefresh(playerName, unitName, _t)
    local scan = self._activeScans[playerName]
    if not scan or not scan.autoRefresh then return end

    local playerUnit = Unit.getByName(unitName)
    if not playerUnit or not playerUnit:isExist() then
        self:_removeAllMarks(scan)
        self._activeScans[playerName] = nil
        return
    end

    local radius         = ctld.gs("reconSearchRadius") or 5000
    local currentTargets = self:_scanLOS(playerUnit, scan.layers, radius)

    local prevIndex = {}
    for _, tgt in ipairs(scan.targets) do
        prevIndex[tgt.unitName] = tgt
    end

    local newTargets   = {}
    local movedTargets = {}
    local lostTargets  = {}

    for _, tgt in ipairs(currentTargets) do
        local prev = prevIndex[tgt.unitName]
        if not prev then
            local mid = self:_nextMark()
            tgt.markId = mid
            CTLDReconRenderer.createIcon(tgt, mid)
            tgt.status = "new"
            newTargets[#newTargets + 1] = tgt
        else
            local d = ctld.utils.getDistance("CTLDReconManager:_doRefresh", prev.position, tgt.position)
            if d > 5 then
                CTLDReconRenderer.removeIcon(prev.markId)
                local newMid = self:_nextMark()
                tgt.markId = newMid
                CTLDReconRenderer.createIcon(tgt, newMid)
                tgt.status = "moved"; tgt.hasMoved = true; tgt.distanceMoved = d
                movedTargets[#movedTargets + 1] = { unit=tgt.unit, unitName=tgt.unitName, unitType=tgt.unitType,
                    positionOld=prev.position, positionNew=tgt.position, distanceMoved=d, markId=newMid }
            else
                tgt.markId = prev.markId  -- FIX: carry forward markId for stop/cleanup
                tgt.status = "existing"
            end
            prevIndex[tgt.unitName] = nil
        end
    end

    for uName, prevTgt in pairs(prevIndex) do
        local reason = "out_of_los"
        if not prevTgt.unit:isExist() then reason = "dead" end
        CTLDReconRenderer.removeIcon(prevTgt.markId)
        lostTargets[#lostTargets + 1] = { unit=prevTgt.unit, unitName=uName, unitType=prevTgt.unitType,
            reason=reason, markId=prevTgt.markId }
    end

    scan.targets    = currentTargets
    scan.playerUnit = playerUnit

    local interval = ctld.gs("reconRefreshInterval") or 10
    local self_ref = self; local pName = playerName; local uNameRef = unitName
    scan.refreshTimer = timer.scheduleFunction(function(_, t)
        self_ref:_doRefresh(pName, uNameRef, t)
    end, nil, timer.getTime() + interval)

    EventDispatcher.getInstance():publish("OnReconScanRefresh", {
        player=playerName, playerUnit=playerUnit, coalition=playerUnit:getCoalition(),
        position=playerUnit:getPoint(), altitude=playerUnit:getPoint().y,
        activeLayers=scan.layers, targets=currentTargets,
        newTargets=newTargets, movedTargets=movedTargets, lostTargets=lostTargets,
        totalTargets=#currentTargets, timestamp=timer.getAbsTime(),
    })
end

ctld.logInfo("patch_dorefresh_markid: existing targets now carry forward markId for clean stop")
return "PATCH OK — _doRefresh markId fixed"
