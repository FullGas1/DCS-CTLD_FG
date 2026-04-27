-- ============================================================
-- CTLD_recon.lua
-- CTLDReconRenderer (static) + CTLDReconManager (singleton)
--
-- SCOPE: RECON is exclusively for displaying ENEMY unit information
-- detected via Line-of-Sight (LOS) from an allied unit.
-- It must NOT be used to display friendly assets (FOBs, zones, beacons…).
-- Those belong in their own manager menus.
--
-- Dependencies : class (lib/class.lua), CTLDUtils (ctld.utils),
--                CTLDConfig (ctld.gs), EventDispatcher
-- DCS API      : coalition.getGroups, Unit.getByName, land.getHeight,
--                land.isVisible (via ctld.utils.getUnitsLOS),
--                trigger.action, timer, missionCommands
--
-- Recon workflow:
--   1. Player enables one or more layers (Layers submenu)
--   2. Player scans → LOS check via ctld.utils.getUnitsLOS()
--      → Draw API icons per layer type on F10 map
--   3. Optional: Auto-Refresh every reconRefreshInterval seconds
--      → tracks moved/new/lost targets
--   4. Hide All Targets → remove marks, stop timer
--
-- Layers (per-player state):
--   infantry, ground_vehicles, air_defense, aircraft, helicopters, ships
--
-- Icons (CTLDReconRenderer):
--   Each target gets a markId; elements at markId*10+1..3
--   infantry   : circle + cross (2 lines)
--   vehicle    : rectangle + diagonal
--   aa         : triangle (3 lines)
--   aircraft   : cross (2 lines) + small circle
--   helicopter : circle + H shape (2 lines)
--   ship       : elongated rectangle + bow lines
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDReconRenderer  (static table — no instance)
-- ============================================================

CTLDReconRenderer = {}

--- Remove all draw elements for a markId (3 sub-elements max).
function CTLDReconRenderer.removeIcon(markId)
    for i = 1, 3 do
        trigger.action.removeMark(markId * 10 + i)
    end
end

--- Infantry icon: circle + horizontal + vertical cross (⊕).
function CTLDReconRenderer.drawInfantryIcon(pos, markId, color)
    local r    = (ctld.gs("reconIconSizes") and ctld.gs("reconIconSizes").infantry) or 30
    local fill = { color[1], color[2], color[3], 0.3 }
    local p    = { x = pos.x, y = 0, z = pos.z }
    trigger.action.circleToAll(-1, markId * 10 + 1, p, r, color, fill, 1, true, "Infantry")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - r, y = 0, z = pos.z }, { x = pos.x + r, y = 0, z = pos.z },
        color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3,
        { x = pos.x, y = 0, z = pos.z - r }, { x = pos.x, y = 0, z = pos.z + r },
        color, 1, true, "")
end

--- Vehicle icon: rectangle + diagonal (▭╱).
function CTLDReconRenderer.drawVehicleIcon(pos, markId, color)
    local s    = (ctld.gs("reconIconSizes") and ctld.gs("reconIconSizes").vehicle) or 40
    local hs   = s / 2
    local fill = { color[1], color[2], color[3], 0.3 }
    trigger.action.rectToAll(-1, markId * 10 + 1,
        { x = pos.x - hs, y = 0, z = pos.z - hs },
        { x = pos.x + hs, y = 0, z = pos.z + hs },
        color, fill, 1, true, "Vehicle")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - hs, y = 0, z = pos.z - hs },
        { x = pos.x + hs, y = 0, z = pos.z + hs },
        color, 1, true, "")
end

--- AA icon: triangle (3 lines: bottom-left, bottom-right, apex).
function CTLDReconRenderer.drawAAIcon(pos, markId, color)
    local s  = (ctld.gs("reconIconSizes") and ctld.gs("reconIconSizes").aa) or 35
    local hs = s / 2
    local p1 = { x = pos.x - hs, y = 0, z = pos.z - hs }
    local p2 = { x = pos.x + hs, y = 0, z = pos.z - hs }
    local p3 = { x = pos.x,      y = 0, z = pos.z + hs }
    trigger.action.lineToAll(-1, markId * 10 + 1, p1, p2, color, 1, true, "AA")
    trigger.action.lineToAll(-1, markId * 10 + 2, p2, p3, color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3, p3, p1, color, 1, true, "")
end

--- Aircraft icon: perpendicular cross (2 lines) + small center circle.
function CTLDReconRenderer.drawAircraftIcon(pos, markId, color)
    local s  = (ctld.gs("reconIconSizes") and ctld.gs("reconIconSizes").aircraft) or 40
    local hs = s / 2
    trigger.action.lineToAll(-1, markId * 10 + 1,
        { x = pos.x,      y = 0, z = pos.z + hs },
        { x = pos.x,      y = 0, z = pos.z - hs },
        color, 1, true, "Aircraft")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - hs, y = 0, z = pos.z },
        { x = pos.x + hs, y = 0, z = pos.z },
        color, 1, true, "")
    trigger.action.circleToAll(-1, markId * 10 + 3,
        { x = pos.x, y = 0, z = pos.z }, hs * 0.35,
        color, color, 1, true, "")
end

--- Helicopter icon: circle + H shape (2 vertical bars).
function CTLDReconRenderer.drawHelicopterIcon(pos, markId, color)
    local r    = (ctld.gs("reconIconSizes") and ctld.gs("reconIconSizes").helicopter) or 25
    local fill = { color[1], color[2], color[3], 0.3 }
    trigger.action.circleToAll(-1, markId * 10 + 1,
        { x = pos.x, y = 0, z = pos.z }, r, color, fill, 1, true, "Helicopter")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - r * 0.4, y = 0, z = pos.z - r * 0.5 },
        { x = pos.x - r * 0.4, y = 0, z = pos.z + r * 0.5 },
        color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3,
        { x = pos.x + r * 0.4, y = 0, z = pos.z - r * 0.5 },
        { x = pos.x + r * 0.4, y = 0, z = pos.z + r * 0.5 },
        color, 1, true, "")
end

--- Ship icon: elongated rectangle + bow arrow (2 lines converging to point).
function CTLDReconRenderer.drawShipIcon(pos, markId, color)
    local sw   = (ctld.gs("reconIconSizes") and ctld.gs("reconIconSizes").ship_width)  or 50
    local sh   = (ctld.gs("reconIconSizes") and ctld.gs("reconIconSizes").ship_height) or 20
    local fill = { color[1], color[2], color[3], 0.3 }
    trigger.action.rectToAll(-1, markId * 10 + 1,
        { x = pos.x - sw / 2, y = 0, z = pos.z - sh / 2 },
        { x = pos.x + sw / 2, y = 0, z = pos.z + sh / 2 },
        color, fill, 1, true, "Ship")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x + sw / 2,           y = 0, z = pos.z - sh / 2 },
        { x = pos.x + sw / 2 + sh / 2,  y = 0, z = pos.z },
        color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3,
        { x = pos.x + sw / 2,           y = 0, z = pos.z + sh / 2 },
        { x = pos.x + sw / 2 + sh / 2,  y = 0, z = pos.z },
        color, 1, true, "")
end

--- Dispatch icon creation to the correct draw function.
-- @param target table  { position, layer }
-- @param markId number
function CTLDReconRenderer.createIcon(target, markId)
    local r   = target.layer.iconRenderer
    local pos = target.position
    local col = target.layer.color
    if     r == "infantry"   then CTLDReconRenderer.drawInfantryIcon(pos, markId, col)
    elseif r == "vehicle"    then CTLDReconRenderer.drawVehicleIcon(pos, markId, col)
    elseif r == "aa"         then CTLDReconRenderer.drawAAIcon(pos, markId, col)
    elseif r == "aircraft"   then CTLDReconRenderer.drawAircraftIcon(pos, markId, col)
    elseif r == "helicopter" then CTLDReconRenderer.drawHelicopterIcon(pos, markId, col)
    elseif r == "ship"       then CTLDReconRenderer.drawShipIcon(pos, markId, col)
    else
        -- Fallback: plain circle
        local fill = { col[1], col[2], col[3], 0.3 }
        trigger.action.circleToAll(-1, markId * 10 + 1,
            { x = pos.x, y = 0, z = pos.z }, 30, col, fill, 1, true, "")
    end
end


-- ============================================================
-- CTLDReconManager  (singleton)
-- ============================================================

CTLDReconManager = class()
CTLDReconManager._instance = nil

function CTLDReconManager.getInstance()
    if not CTLDReconManager._instance then
        local o = setmetatable({}, CTLDReconManager)
        o:init()
        CTLDReconManager._instance = o
    end
    return CTLDReconManager._instance
end

function CTLDReconManager:init()
    self._activeScans  = {}   -- player -> scan state
    self._playerLayers = {}   -- player -> array of layer copies
    -- Mark IDs are allocated from ctld.utils.getNextMarkId() (app-wide monotonic counter)

    CTLDPlayerManager.getInstance():registerMenuSection({
        key       = "recon",
        manager   = self,
        method    = "buildMenuSection",
        configKey = "reconF10Menu",
        order     = 70,
    })
    ctld.utils.log("INFO", "CTLDReconManager: init complete")
end

-- ============================================================
-- Default layer definitions
-- ============================================================

-- DCS attribute names (case-sensitive, from DCS unit type tables)
CTLDReconManager._defaultLayers = {
    {
        layerId      = "infantry",
        name         = "Infantry",
        enabled      = false,
        color        = { 0.29, 0.56, 0.89, 1.0 },
        filterAttrib = "Infantry",
        iconRenderer = "infantry",
    },
    {
        layerId      = "ground_vehicles",
        name         = "Ground Vehicles",
        enabled      = false,
        color        = { 0.31, 0.78, 0.47, 1.0 },
        filterAttrib = "Vehicles",
        iconRenderer = "vehicle",
    },
    {
        layerId      = "air_defense",
        name         = "Air Defense (AA)",
        enabled      = false,
        color        = { 0.91, 0.30, 0.24, 1.0 },
        filterAttrib = "Air Defence",
        iconRenderer = "aa",
    },
    {
        layerId      = "aircraft",
        name         = "Aircraft",
        enabled      = false,
        color        = { 0.95, 0.77, 0.06, 1.0 },
        filterAttrib = "Planes",       -- fixed-wing only (not "Air" which includes helos)
        iconRenderer = "aircraft",
    },
    {
        layerId      = "helicopters",
        name         = "Helicopters",
        enabled      = false,
        color        = { 0.90, 0.49, 0.13, 1.0 },
        filterAttrib = "Helicopters",
        iconRenderer = "helicopter",
    },
    {
        layerId      = "ships",
        name         = "Ships",
        enabled      = false,
        color        = { 0.20, 0.60, 0.86, 1.0 },
        filterAttrib = "Ships",
        iconRenderer = "ship",
    },
}

-- ============================================================
-- Layer management (per-player)
-- ============================================================

-- Returns or lazily initializes the per-player layer array.
function CTLDReconManager:_getPlayerLayers(player)
    if not self._playerLayers[player] then
        local layers = {}
        for _, def in ipairs(CTLDReconManager._defaultLayers) do
            layers[#layers + 1] = {
                layerId      = def.layerId,
                name         = def.name,
                enabled      = def.enabled,
                color        = def.color,
                filterAttrib = def.filterAttrib,
                iconRenderer = def.iconRenderer,
            }
        end
        self._playerLayers[player] = layers
    end
    return self._playerLayers[player]
end

-- Returns the layer object for layerId in player's list, or nil.
function CTLDReconManager:_findLayer(player, layerId)
    for _, layer in ipairs(self:_getPlayerLayers(player)) do
        if layer.layerId == layerId then return layer end
    end
    return nil
end

-- Returns list of enabled layers for player.
function CTLDReconManager:_enabledLayers(player)
    local result = {}
    for _, layer in ipairs(self:_getPlayerLayers(player)) do
        if layer.enabled then result[#result + 1] = layer end
    end
    return result
end

-- ============================================================
-- LOS scan helpers
-- ============================================================

-- Returns enemy unit name list for all relevant categories.
function CTLDReconManager:_getEnemyUnitNames(coalitionId)
    local enemySide = coalitionId == coalition.side.BLUE
                      and coalition.side.RED
                      or  coalition.side.BLUE
    return ctld.utils.getUnitsListNamesByCategory(
        "CTLDReconManager:_getEnemyUnitNames",
        enemySide,
        {
            Group.Category.GROUND,
            Group.Category.AIRPLANE,
            Group.Category.HELICOPTER,
            Group.Category.SHIP,
        })
end

-- Find the first enabled layer matching unit attributes, or nil.
function CTLDReconManager:_matchLayer(unit, enabledLayers)
    for _, layer in ipairs(enabledLayers) do
        local ok, has = pcall(function() return unit:hasAttribute(layer.filterAttrib) end)
        if ok and has then return layer end
    end
    return nil
end

-- Allocate next unique mark ID (delegates to shared app-wide counter).
function CTLDReconManager:_nextMark()
    return ctld.utils.getNextMarkId()
end

-- Core LOS scan. Returns array of target records.
-- altoffset = 180 matches source/CTLD_recon.lua ctld.utils.getUnitsLOS call.
function CTLDReconManager:_scanLOS(playerUnit, enabledLayers, searchRadius)
    local enemyNames = self:_getEnemyUnitNames(playerUnit:getCoalition())
    if #enemyNames == 0 then return {} end

    local los = ctld.utils.getUnitsLOS(
        "CTLDReconManager:_scanLOS",
        { playerUnit:getName() },
        180,
        enemyNames,
        180,
        searchRadius)

    local targets   = {}
    local playerPos = playerUnit:getPoint()

    if los then
        for _, entry in ipairs(los) do
            if entry.vis then
                for _, unit in ipairs(entry.vis) do
                    local layer = self:_matchLayer(unit, enabledLayers)
                    if layer then
                        local uPos = unit:getPoint()
                        targets[#targets + 1] = {
                            unit      = unit,
                            unitName  = unit:getName(),
                            unitType  = unit:getTypeName(),
                            coalition = unit:getCoalition(),
                            position  = uPos,
                            distance  = ctld.utils.getDistance(
                                "CTLDReconManager:_scanLOS", playerPos, uPos),
                            layer     = layer,
                            los       = true,
                        }
                    end
                end
            end
        end
    end

    return targets
end

-- Remove all Draw API icons from a scan's target list.
function CTLDReconManager:_removeAllMarks(scan)
    for _, tgt in ipairs(scan.targets) do
        CTLDReconRenderer.removeIcon(tgt.markId)
    end
end

-- ============================================================
-- Public actions
-- ============================================================

--- Manual scan (menu F10 "Scan Area" / "Rescan Area").
-- @param playerUnit DCS Unit
-- @param player     string  playerName
function CTLDReconManager:scan(playerUnit, player)
    if not ctld.gs("reconEnabled") then return end

    -- Altitude check (AGL)
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

    -- Cancel previous auto-refresh timer if any
    local prevScan = self._activeScans[player]
    if prevScan then
        if prevScan.refreshTimer then timer.removeFunction(prevScan.refreshTimer) end
        self:_removeAllMarks(prevScan)
    end

    local radius  = ctld.gs("reconSearchRadius") or 5000
    local targets = self:_scanLOS(playerUnit, enabledLayers, radius)

    -- Create icons + count per layer
    local targetsByLayer = {}
    for _, tgt in ipairs(targets) do
        local mid = self:_nextMark()
        tgt.markId = mid
        CTLDReconRenderer.createIcon(tgt, mid)
        local lid = tgt.layer.layerId
        targetsByLayer[lid] = (targetsByLayer[lid] or 0) + 1
    end

    self._activeScans[player] = {
        playerUnit   = playerUnit,
        coalition    = playerUnit:getCoalition(),
        targets      = targets,
        layers       = enabledLayers,
        autoRefresh  = false,
        refreshTimer = nil,
    }

    -- Build activeLayers payload
    local activeLayersPayload = {}
    for _, l in ipairs(enabledLayers) do
        activeLayersPayload[#activeLayersPayload + 1] = {
            layerId = l.layerId, name = l.name, enabled = true, color = l.color
        }
    end

    EventDispatcher.getInstance():publish("OnReconScan", {
        player               = player,
        playerUnit           = playerUnit,
        coalition            = playerUnit:getCoalition(),
        position             = pos,
        altitude             = agl,
        searchRadius         = radius,
        activeLayers         = activeLayersPayload,
        targets              = targets,
        targetsByLayer       = targetsByLayer,
        totalTargetsDetected = #targets,
        totalMarksCreated    = #targets,
        autoRefresh          = false,
        timestamp            = timer.getAbsTime(),
    })
end

--- Hide all marks for player (menu F10 "Hide All Targets").
-- @param playerUnit DCS Unit
-- @param player     string
function CTLDReconManager:hideScan(playerUnit, player)
    local scan = self._activeScans[player]
    if not scan then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("No active recon scan to hide."), 10)
        return
    end

    local refreshStopped = scan.autoRefresh
    if scan.refreshTimer then
        timer.removeFunction(scan.refreshTimer)
        scan.refreshTimer = nil
    end

    local marksRemoved = {}
    for _, tgt in ipairs(scan.targets) do
        CTLDReconRenderer.removeIcon(tgt.markId)
        marksRemoved[#marksRemoved + 1] = {
            markId    = tgt.markId,
            unitType  = tgt.unitType,
            layer     = { layerId = tgt.layer.layerId, name = tgt.layer.name },
            position  = tgt.position,
            wasActive = true,
        }
    end
    self._activeScans[player] = nil

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Recon stopped. %1 targets hidden.", #marksRemoved), 10)

    EventDispatcher.getInstance():publish("OnReconHideTargets", {
        player            = player,
        playerUnit        = playerUnit,
        coalition         = playerUnit:getCoalition(),
        marksRemoved      = marksRemoved,
        totalMarksRemoved = #marksRemoved,
        refreshStopped    = refreshStopped,
        timestamp         = timer.getAbsTime(),
    })
end

--- Enable auto-refresh (menu F10 "Auto-Refresh: [OFF]" → ON).
-- @param playerUnit DCS Unit
-- @param player     string
function CTLDReconManager:enableAutoRefresh(playerUnit, player)
    local scan = self._activeScans[player]
    if not scan then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("No active recon scan. Use 'Scan Area' first."), 10)
        return
    end
    if scan.autoRefresh then return end

    local interval = ctld.gs("reconRefreshInterval") or 10
    scan.autoRefresh = true

    local self_ref = self
    local pName    = player
    local uName    = playerUnit:getName()
    scan.refreshTimer = timer.scheduleFunction(function(_, t)
        self_ref:_doRefresh(pName, uName, t)
    end, nil, timer.getTime() + interval)

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Auto-refresh enabled. Targets update every %1 s.", interval), 10)

    EventDispatcher.getInstance():publish("OnReconAutoRefreshEnabled", {
        player          = player,
        playerUnit      = playerUnit,
        coalition       = playerUnit:getCoalition(),
        previousState   = false,
        newState        = true,
        targetsCount    = #scan.targets,
        refreshInterval = interval,
        timestamp       = timer.getAbsTime(),
    })
end

--- Disable auto-refresh (menu F10 "Auto-Refresh: [ON]" → OFF).
-- @param playerUnit DCS Unit
-- @param player     string
function CTLDReconManager:disableAutoRefresh(playerUnit, player)
    local scan = self._activeScans[player]
    if not scan or not scan.autoRefresh then return end

    local interval = ctld.gs("reconRefreshInterval") or 10
    scan.autoRefresh = false
    if scan.refreshTimer then
        timer.removeFunction(scan.refreshTimer)
        scan.refreshTimer = nil
    end

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Auto-refresh disabled. Current targets frozen on map."), 10)

    EventDispatcher.getInstance():publish("OnReconAutoRefreshDisabled", {
        player          = player,
        playerUnit      = playerUnit,
        coalition       = playerUnit:getCoalition(),
        previousState   = true,
        newState        = false,
        targetsCount    = #scan.targets,
        refreshInterval = interval,
        timestamp       = timer.getAbsTime(),
    })
end

--- Toggle a recon layer ON/OFF for a player.
-- If a scan is active, re-scans immediately with updated layer set.
-- @param player     string
-- @param playerUnit DCS Unit
-- @param layerId    string
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

    -- Immediate re-scan if scan is active (applies new layer state)
    if self._activeScans[player] then
        self:scan(playerUnit, player)
    end

    EventDispatcher.getInstance():publish("OnReconLayerToggled", {
        layerId   = layer.layerId,
        layerName = layer.name,
        visible   = layer.enabled,
        coalition = playerUnit:getCoalition(),
        player    = player,
        timestamp = timer.getAbsTime(),
    })
end

-- ============================================================
-- Auto-refresh timer callback
-- ============================================================

--- Called by timer.scheduleFunction every reconRefreshInterval seconds.
-- @param playerName string
-- @param unitName   string  (DCS unit name, for re-lookup after tick)
function CTLDReconManager:_doRefresh(playerName, unitName, _t)
    local scan = self._activeScans[playerName]
    if not scan or not scan.autoRefresh then return end

    local playerUnit = Unit.getByName(unitName)
    if not playerUnit or not playerUnit:isExist() then
        -- Player gone — cleanup silently
        self:_removeAllMarks(scan)
        self._activeScans[playerName] = nil
        return
    end

    local radius         = ctld.gs("reconSearchRadius") or 5000
    local currentTargets = self:_scanLOS(playerUnit, scan.layers, radius)

    -- Index previous targets by unitName
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
            -- New target
            local mid = self:_nextMark()
            tgt.markId = mid
            CTLDReconRenderer.createIcon(tgt, mid)
            tgt.status = "new"
            newTargets[#newTargets + 1] = tgt
        else
            local d = ctld.utils.getDistance(
                "CTLDReconManager:_doRefresh", prev.position, tgt.position)
            if d > 5 then
                -- Moved: remove old icon (invalidates its DCS ID permanently),
                -- allocate a fresh ID for the new icon (DCS IDs must never be reused).
                CTLDReconRenderer.removeIcon(prev.markId)
                local newMid = self:_nextMark()
                tgt.markId = newMid
                CTLDReconRenderer.createIcon(tgt, newMid)
                tgt.status        = "moved"
                tgt.hasMoved      = true
                tgt.distanceMoved = d
                movedTargets[#movedTargets + 1] = {
                    unit          = tgt.unit,
                    unitName      = tgt.unitName,
                    unitType      = tgt.unitType,
                    positionOld   = prev.position,
                    positionNew   = tgt.position,
                    distanceMoved = d,
                    markId        = newMid,
                }
            else
                tgt.status = "existing"
            end
            prevIndex[tgt.unitName] = nil
        end
    end

    -- Remaining in prevIndex = lost (out of LOS or dead)
    for uName, prevTgt in pairs(prevIndex) do
        local reason = "out_of_los"
        if not prevTgt.unit:isExist() then reason = "dead" end
        CTLDReconRenderer.removeIcon(prevTgt.markId)
        lostTargets[#lostTargets + 1] = {
            unit     = prevTgt.unit,
            unitName = uName,
            unitType = prevTgt.unitType,
            reason   = reason,
            markId   = prevTgt.markId,
        }
    end

    -- Update scan state
    scan.targets     = currentTargets
    scan.playerUnit  = playerUnit

    -- Re-schedule next refresh
    local interval = ctld.gs("reconRefreshInterval") or 10
    local self_ref = self
    local pName    = playerName
    local uNameRef = unitName
    scan.refreshTimer = timer.scheduleFunction(function(_, t)
        self_ref:_doRefresh(pName, uNameRef, t)
    end, nil, timer.getTime() + interval)

    EventDispatcher.getInstance():publish("OnReconScanRefresh", {
        player                = playerName,
        playerUnit            = playerUnit,
        coalition             = playerUnit:getCoalition(),
        position              = playerUnit:getPoint(),
        altitude              = playerUnit:getPoint().y,
        activeLayers          = scan.layers,
        targets               = currentTargets,
        newTargets            = newTargets,
        movedTargets          = movedTargets,
        lostTargets           = lostTargets,
        totalTargetsCurrent   = #currentTargets,
        totalTargetsNew       = #newTargets,
        totalTargetsMoved     = #movedTargets,
        totalTargetsLost      = #lostTargets,
        marksCreated          = #newTargets,
        marksUpdated          = #movedTargets,
        marksRemoved          = #lostTargets,
        timestamp             = timer.getAbsTime(),
    })
end

-- ============================================================
-- Query API
-- ============================================================

--- Return current scan state for player, or nil.
-- @param player string
-- @return table|nil  { playerUnit, coalition, targets, layers, autoRefresh, refreshTimer }
function CTLDReconManager:getActiveScan(player)
    return self._activeScans[player]
end

--- Return per-player layers array.
-- @param player string
-- @return table  array of layer objects
function CTLDReconManager:getPlayerLayers(player)
    return self:_getPlayerLayers(player)
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Build the "RECON" F10 submenu for a player.
-- Requires reconF10Menu = true (configKey gate).
-- Adds Scan, Hide, per-layer toggles, and AutoRefresh commands.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDReconManager:buildMenuSection(playerObj, menu)
    local root     = ctld.tr("CTLD")
    local reconSub = ctld.tr("RECON")
    menu:addSubMenu({ root }, reconSub, { order = 70 })

    menu:addCommand({ root, reconSub }, ctld.tr("Scan Area"),
        function(arg)
            local unit = Unit.getByName(arg.unitName)
            if unit then CTLDReconManager.getInstance():scan(unit, arg.playerName) end
        end,
        { unitName = playerObj.unitName, playerName = playerObj.unitName })

    menu:addCommand({ root, reconSub }, ctld.tr("Hide All Targets"),
        function(arg)
            local unit = Unit.getByName(arg.unitName)
            if unit then CTLDReconManager.getInstance():hideScan(unit, arg.playerName) end
        end,
        { unitName = playerObj.unitName, playerName = playerObj.unitName })

    -- Per-layer toggle commands
    for _, layer in ipairs(CTLDReconManager._defaultLayers) do
        menu:addCommand({ root, reconSub },
            string.format(ctld.tr("Toggle %s"), layer.name),
            function(arg)
                local unit = Unit.getByName(arg.unitName)
                if unit then
                    CTLDReconManager.getInstance():toggleLayer(arg.playerName, unit, arg.layerId)
                end
            end,
            { unitName = playerObj.unitName, playerName = playerObj.unitName, layerId = layer.layerId })
    end

    menu:addCommand({ root, reconSub }, ctld.tr("Auto-Refresh: [OFF]"),
        function(arg)
            local unit = Unit.getByName(arg.unitName)
            if unit then CTLDReconManager.getInstance():enableAutoRefresh(unit, arg.playerName) end
        end,
        { unitName = playerObj.unitName, playerName = playerObj.unitName })

    menu:addCommand({ root, reconSub }, ctld.tr("Auto-Refresh: [ON]"),
        function(arg)
            local unit = Unit.getByName(arg.unitName)
            if unit then CTLDReconManager.getInstance():disableAutoRefresh(unit, arg.playerName) end
        end,
        { unitName = playerObj.unitName, playerName = playerObj.unitName })
end
