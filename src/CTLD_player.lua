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
    self._players      = {}   -- unitName → CTLDPlayer
    self._menuSections = {}   -- ordered list of { key, manager, method, configKey, order }

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
        -- Crate is now inside the aircraft: remove it from the Unpack menu immediately
        CTLDCrateManager.getInstance():refreshUnpackSectionForUnit(p.carrierUnitName)
    end)

    ctld.utils.log("INFO", "CTLDPlayerManager: init complete")
end

--- Build menus for any players already occupying slots when CTLD loads.
-- Called once at init(); uses coalition.getPlayers() to enumerate connected players.
function CTLDPlayerManager:_scanExistingPlayers()
    local count = 0
    for _, side in ipairs({ coalition.side.RED, coalition.side.BLUE }) do
        local units = coalition.getPlayers(side) or {}
        for _, unit in ipairs(units) do
            if unit:isExist() and unit:getPlayerName() then
                local unitName = unit:getName()
                if not self._players[unitName] then
                    -- Simulate the enter-unit event
                    self:onPlayerEnterUnit({ initiator = unit })
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        ctld.utils.log("INFO", "CTLDPlayerManager: built menu for %d pre-existing player(s)", count)
    end
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

--- DCS S_EVENT_LAND handler — rebuild troop menu section for landing unit.
-- Delayed 1 s: S_EVENT_LAND fires before the aircraft has fully settled,
-- so _isInAir() may still return true at the exact moment of the event.
function CTLDPlayerManager:onLand(event)
    local unit = event and event.initiator
    if not unit then return end
    local unitName  = unit:getName()
    local playerObj = self._players[unitName]
    if not playerObj then return end
    local captured = playerObj
    timer.scheduleFunction(function()
        CTLDTroopManager.getInstance():refreshMenuSection(captured)
        CTLDCrateManager.getInstance():refreshLoadCrateSection(captured)
        CTLDCrateManager.getInstance():refreshUnpackSection(captured)
        CTLDVehicleSpawner.getInstance():refreshPackSection(captured)
    end, nil, timer.getTime() + 1)
end

--- DCS S_EVENT_TAKEOFF handler — rebuild troop menu section for departing unit.
function CTLDPlayerManager:onTakeoff(event)
    local unit = event and event.initiator
    if not unit then return end
    local playerObj = self._players[unit:getName()]
    if not playerObj then return end
    CTLDTroopManager.getInstance():refreshMenuSection(playerObj)
end

--- Register a menu section contributed by a manager.
-- Called by each manager in its own init(), before any player enters a unit.
-- sectionDef = {
--   key       = string      unique identifier, e.g. "troops", "beacons"
--   manager   = object      manager instance
--   method    = string      method name: manager[method](manager, playerObj, menu)
--   configKey = string|nil  ctld.gs(configKey) must be true to activate; nil = always active
--   order     = number|nil  render position (ascending); nil = appended last
-- }
-- Idempotent: duplicate keys are silently ignored.
function CTLDPlayerManager:registerMenuSection(sectionDef)
    if not sectionDef or not sectionDef.key then return end
    for _, s in ipairs(self._menuSections) do
        if s.key == sectionDef.key then return end
    end
    table.insert(self._menuSections, sectionDef)
    ctld.utils.log("INFO", "CTLDPlayerManager: registered menu section '%s'", sectionDef.key)
end

--- Return the CTLDPlayer for unitName, or nil if not tracked.
-- @param unitName string
-- @return CTLDPlayer or nil
function CTLDPlayerManager:getPlayer(unitName)
    return self._players[unitName]
end

--- Build (or rebuild) the full F10 CTLD menu for a player.
-- Wipes and reconstructs atomically via ctld.MenuManager.
-- Sections are contributed by managers registered via registerMenuSection().
-- Each section is rendered only when its configKey (if any) resolves to true.
-- @param playerObj CTLDPlayer
function CTLDPlayerManager:buildMenu(playerObj)
    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:createMenuForGroup(playerObj.groupId)
    if not menu then
        ctld.utils.log("WARNING", "CTLDPlayerManager:buildMenu — cannot create menu for group "
            .. tostring(playerObj.groupId))
        return
    end

    local root     = ctld.tr("CTLD")
    local gid      = playerObj.groupId
    local unitName = playerObj.unitName

    -- Root submenu "CTLD" at F1 slot (order 10)
    menu:addSubMenu({}, root, { order = 10 })

    -- "Check Cargo" — queries crates and troops loaded on this transport
    menu:addCommand({ root }, ctld.tr("Check Cargo"),
        function()
            local transport = Unit.getByName(unitName)
            local lines     = {}
            local total     = 0

            -- Crates loaded on this transport — grouped by descriptor.desc
            -- Compare by unit name, not object identity (DCS userdata equality is unreliable)
            local crateMgr   = CTLDCrateManager.getInstance()
            local crateCount = {}   -- desc → { count, totalWeight }
            local crateOrder = {}   -- preserve insertion order for deterministic output
            for _, c in pairs(crateMgr.crates) do
                if c:isLoaded() and c.loadedBy and c.loadedBy:getName() == unitName then
                    local desc   = (c.descriptor and c.descriptor.desc) or "?"
                    local weight = (c.descriptor and c.descriptor.weight) or 0
                    if not crateCount[desc] then
                        crateCount[desc] = { count = 0, totalWeight = 0 }
                        table.insert(crateOrder, desc)
                    end
                    crateCount[desc].count       = crateCount[desc].count + 1
                    crateCount[desc].totalWeight = crateCount[desc].totalWeight + weight
                    total = total + weight
                end
            end
            for _, desc in ipairs(crateOrder) do
                local info = crateCount[desc]
                table.insert(lines,
                    ctld.tr("%1: %2 crate(s) onboard (%3 kg)", desc, info.count, info.totalWeight))
            end

            -- Troops loaded on this transport
            local troopMgr = CTLDTroopManager.getInstance()
            local tGroup   = troopMgr:getInTransit(unitName)
            if tGroup then
                table.insert(lines, ctld.tr("%1 troop(s) onboard (%2 kg)", tGroup.unitTotal, tGroup.weight))
                total = total + tGroup.weight
            end

            local msg
            if #lines == 0 then
                msg = ctld.tr("No cargo on board.")
            else
                table.insert(lines, ctld.tr("Total cargo weight: %1 kg", total))
                msg = table.concat(lines, "\n")
            end
            trigger.action.outTextForGroup(gid, msg, 10)
        end, {})

    -- Registered sections sorted by order field
    local sorted = {}
    for _, s in ipairs(self._menuSections) do table.insert(sorted, s) end
    table.sort(sorted, function(a, b)
        return (a.order or math.huge) < (b.order or math.huge)
    end)

    for _, section in ipairs(sorted) do
        local active = true
        if section.configKey then
            active = ctld.gs(section.configKey) == true
        end
        if active then
            local fn = section.manager[section.method]
            if fn then
                fn(section.manager, playerObj, menu)
            else
                ctld.utils.log("WARN", "CTLDPlayerManager:buildMenu — section '%s' method '%s' not found",
                    section.key, tostring(section.method))
            end
        end
    end

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
