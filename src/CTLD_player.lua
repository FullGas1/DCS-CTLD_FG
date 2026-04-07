---@diagnostic disable
-- ============================================================
-- CTLD_player.lua
-- CTLDPlayer entity + CTLDPlayerManager singleton
--
-- CTLDPlayer       : immutable identity snapshot (unit name, group, coalition,
--                    type, capabilities) plus mutable cargo state
--                    (loaded crates / vehicles / troops).
-- CTLDPlayerManager: lifecycle (enter/leave unit), F10 menu orchestration,
--                    cargo state tracking via EventDispatcher subscriptions.
--
-- DCS events consumed (via CTLDDCSEventBridge):
--   S_EVENT_PLAYER_ENTER_UNIT → onPlayerEnterUnit(event)
--   S_EVENT_PLAYER_LEAVE_UNIT → onPlayerLeaveUnit(event)
--
-- CTLD events consumed (via EventDispatcher):
--   OnVehicleLoaded   { transportUnitObject, ctldVehicleObject } → add to loadedVehicles
--   OnVehicleUnloaded { transportUnitObject, ctldVehicleObject } → remove from loadedVehicles
--   OnCrateLoaded     { carrierUnitName, crate }                → add to loadedCrates
--
-- Events published: none.
--
-- Dependencies: class (lib/class.lua), CTLDUtils (ctld.utils),
--               CTLDConfig (ctld.gs), EventDispatcher, CTLDDCSEventBridge,
--               ctld.MenuManager (CTLD_menu.lua)
-- DCS API: unit:getName, unit:getGroup, unit:getTypeName, unit:getCoalition,
--          unit:getPlayerName, unit:isExist,
--          missionCommands.removeItemForGroup, trigger.action.outTextForGroup
-- ============================================================

ctld = ctld or {}

-- ============================================================
-- CTLDPlayer  (entity)
-- ============================================================

CTLDPlayer = class()

--- Constructor.
-- @param data table  Required fields:
--   unitName, groupId, groupName, coalition, typeName, isTransport, canCarryVehicles
function CTLDPlayer:init(data)
    self.unitName         = data.unitName
    self.groupId          = data.groupId
    self.groupName        = data.groupName
    self.coalition        = data.coalition
    self.typeName         = data.typeName
    self.isTransport      = data.isTransport      or false
    self.canCarryVehicles = data.canCarryVehicles  or false
    self.loadedTroops     = {}
    self.loadedCrates     = {}
    self.loadedVehicles   = {}
end

--- Append a CTLDVehicle to the loaded vehicles list.
-- @param ctldVehicleObject CTLDVehicle
function CTLDPlayer:addLoadedVehicle(ctldVehicleObject)
    table.insert(self.loadedVehicles, ctldVehicleObject)
end

--- Remove a CTLDVehicle from the loaded list (matched by object identity).
-- @param ctldVehicleObject CTLDVehicle
function CTLDPlayer:removeLoadedVehicle(ctldVehicleObject)
    for i, v in ipairs(self.loadedVehicles) do
        if v == ctldVehicleObject then
            table.remove(self.loadedVehicles, i)
            return
        end
    end
end

--- Append a CTLDCrate to the loaded crates list.
-- @param ctldCrateObject CTLDCrate
function CTLDPlayer:addLoadedCrate(ctldCrateObject)
    table.insert(self.loadedCrates, ctldCrateObject)
end

--- Remove a CTLDCrate from the loaded list (matched by object identity).
-- @param ctldCrateObject CTLDCrate
function CTLDPlayer:removeLoadedCrate(ctldCrateObject)
    for i, c in ipairs(self.loadedCrates) do
        if c == ctldCrateObject then
            table.remove(self.loadedCrates, i)
            return
        end
    end
end

-- ============================================================
-- CTLDPlayerManager  (singleton)
-- ============================================================

CTLDPlayerManager = class()
CTLDPlayerManager._instance = nil

--- Return (or create) the singleton instance.
function CTLDPlayerManager.getInstance()
    if not CTLDPlayerManager._instance then
        local o = setmetatable({}, CTLDPlayerManager)
        o:init()
        CTLDPlayerManager._instance = o
    end
    return CTLDPlayerManager._instance
end

function CTLDPlayerManager:init()
    self._players = {}   -- unitName → CTLDPlayer

    -- Register for DCS player slot events
    local bridge = CTLDDCSEventBridge.getInstance()
    bridge:register(self, world.event.S_EVENT_PLAYER_ENTER_UNIT, "onPlayerEnterUnit")
    bridge:register(self, world.event.S_EVENT_PLAYER_LEAVE_UNIT, "onPlayerLeaveUnit")

    -- Subscribe to CTLD cargo events to maintain per-player cargo state
    local ed = EventDispatcher.getInstance()

    ed:subscribe("OnVehicleLoaded", function(p)
        if not p or not p.transportUnitObject then return end
        local playerObj = self:getPlayer(p.transportUnitObject:getName())
        if not playerObj then return end
        if p.ctldVehicleObject then
            playerObj:addLoadedVehicle(p.ctldVehicleObject)
        end
        self:refreshForUnit(playerObj.unitName)
    end)

    ed:subscribe("OnVehicleUnloaded", function(p)
        if not p or not p.transportUnitObject then return end
        local playerObj = self:getPlayer(p.transportUnitObject:getName())
        if not playerObj then return end
        if p.ctldVehicleObject then
            playerObj:removeLoadedVehicle(p.ctldVehicleObject)
        end
        self:refreshForUnit(playerObj.unitName)
    end)

    ed:subscribe("OnCrateLoaded", function(p)
        if not p or not p.carrierUnitName then return end
        local playerObj = self:getPlayer(p.carrierUnitName)
        if not playerObj then return end
        if p.crate then playerObj:addLoadedCrate(p.crate) end
        self:refreshForUnit(playerObj.unitName)
    end)

    ctld.utils.log("INFO", "CTLDPlayerManager: init complete")
end

--- DCS S_EVENT_PLAYER_ENTER_UNIT handler.
-- Creates a CTLDPlayer and builds the F10 CTLD menu.
-- AI units (no playerName) are silently ignored.
-- @param event table  DCS event { initiator = Unit, ... }
function CTLDPlayerManager:onPlayerEnterUnit(event)
    local unit = event and event.initiator
    if not unit or not unit:isExist() then return end
    if not unit:getPlayerName() then return end   -- skip AI

    local unitName = unit:getName()
    local group    = unit:getGroup()
    if not group then
        ctld.utils.log("WARNING", "CTLDPlayerManager:onPlayerEnterUnit — no group for " .. unitName)
        return
    end

    local isTransport, canCarryVehicles = self:_detectCapabilities(unit)

    local playerObj = CTLDPlayer:new({
        unitName         = unitName,
        groupId          = group:getID(),
        groupName        = group:getName(),
        coalition        = unit:getCoalition(),
        typeName         = unit:getTypeName(),
        isTransport      = isTransport,
        canCarryVehicles = canCarryVehicles,
    })

    self._players[unitName] = playerObj
    self:buildMenu(playerObj)

    ctld.utils.log("INFO", string.format(
        "CTLDPlayerManager: enter unit=%s type=%s transport=%s vehicles=%s",
        unitName, playerObj.typeName,
        tostring(isTransport), tostring(canCarryVehicles)))
end

--- DCS S_EVENT_PLAYER_LEAVE_UNIT handler.
-- Removes the CTLDPlayer and wipes the F10 CTLD menu.
-- @param event table  DCS event { initiator = Unit, ... }
function CTLDPlayerManager:onPlayerLeaveUnit(event)
    local unit = event and event.initiator
    if not unit then return end
    local unitName  = unit:getName()
    local playerObj = self._players[unitName]
    if not playerObj then return end

    missionCommands.removeItemForGroup(playerObj.groupId, nil)
    self._players[unitName] = nil

    ctld.utils.log("INFO", "CTLDPlayerManager: leave unit=" .. unitName)
end

--- Return the CTLDPlayer for unitName, or nil if not tracked.
-- @param unitName string
-- @return CTLDPlayer or nil
function CTLDPlayerManager:getPlayer(unitName)
    return self._players[unitName]
end

--- Build (or rebuild) the full F10 CTLD menu for a player.
-- Wipes and reconstructs atomically via ctld.MenuManager.
-- @param playerObj CTLDPlayer
function CTLDPlayerManager:buildMenu(playerObj)
    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:createMenuForGroup(playerObj.groupId)
    if not menu then
        ctld.utils.log("WARNING", "CTLDPlayerManager:buildMenu — cannot create menu for group "
            .. tostring(playerObj.groupId))
        return
    end

    -- Root submenu "CTLD" at F1 slot (order 10)
    menu:addSubMenu({}, ctld.tr("CTLD", "CTLD"), { order = 10 })

    -- Check Cargo — always present regardless of transport type
    local groupId = playerObj.groupId
    menu:addCommand({ ctld.tr("CTLD", "CTLD") }, ctld.tr("Check Cargo", "Check Cargo"),
        function()
            trigger.action.outTextForGroup(groupId,
                ctld.tr("No cargo on board.", "No cargo on board."), 10)
        end, {})

    -- TODO M8+: if playerObj.isTransport, delegate to functional managers:
    --   CTLDTroopManager:buildMenuSection(playerObj, menu)
    --   CTLDVehicleManager:buildMenuSection(playerObj, menu)
    --   CTLDCrateManager:buildMenuSection(playerObj, menu)
    --   CTLDBeaconManager:buildMenuSection(playerObj, menu)

    menu:refresh()
end

--- Refresh the F10 menu for a single player unit.
-- @param unitName string
function CTLDPlayerManager:refreshForUnit(unitName)
    local playerObj = self._players[unitName]
    if not playerObj then return end
    ctld.MenuManager:getInstance():refreshMenuForGroup(playerObj.groupId)
end

--- Refresh F10 menus for all currently tracked players.
function CTLDPlayerManager:refreshAll()
    for unitName in pairs(self._players) do
        self:refreshForUnit(unitName)
    end
end

-- ============================================================
-- Private helpers
-- ============================================================

--- Detect transport and vehicle-carry capabilities from a unit.
-- isTransport      : typeName has an entry in ctld.gs("unitActions") map.
-- canCarryVehicles : typeName matches (case-insensitive substring) an entry
--                   in the ctld.gs("vehicleTransportEnabled") list.
-- @param unit DCS Unit
-- @return isTransport bool, canCarryVehicles bool
function CTLDPlayerManager:_detectCapabilities(unit)
    local typeName    = unit:getTypeName()
    local typeLower   = string.lower(typeName)
    local unitActions = ctld.gs("unitActions") or {}
    local isTransport = (unitActions[typeName] ~= nil)

    local canCarryVehicles  = false
    local vehicleTransports = ctld.gs("vehicleTransportEnabled") or {}
    for _, name in ipairs(vehicleTransports) do
        if string.find(typeLower, string.lower(name), 1, true) then
            canCarryVehicles = true
            break
        end
    end

    return isTransport, canCarryVehicles
end
