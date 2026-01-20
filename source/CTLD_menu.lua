-- =============================================================================
-- CTLD Menu Manager - Complete Implementation + Test Examples
-- =============================================================================
-- Fusion de CTLD_Menu.lua et CTLD_Menu_Example.lua
-- Contient la classe complète + exemples de tests dynamiques
--
-- Version: 1.0
-- Date: January 9, 2026
-- =============================================================================

-- Singleton MenuManager
MenuManager = MenuManager or {}
MenuManager._instance = nil

-- =============================================================================
-- MenuManager: Singleton that manages all group menus
-- =============================================================================

function MenuManager:getInstance()
    if not self._instance then
        self._instance = self:new()
    end
    return self._instance
end

function MenuManager:new()
    local obj = {
        menus = {},
        nextMenuId = 1,
        logger = self:_createLogger()
    }
    setmetatable(obj, { __index = MenuManager })
    return obj
end

function MenuManager:_createLogger()
    return {
        info = function(self, msg)
            trigger.action.outText(msg,5)
            --local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            --print(string.format("[INFO] %s | MenuManager | %s", timestamp, msg))
        end,
        warn = function(self, msg)
            trigger.action.outText(msg,5)
            --local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            --print(string.format("[WARN] %s | MenuManager | %s", timestamp, msg))
        end,
        error = function(self, msg)
            trigger.action.outText(msg,5)
            --local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            --print(string.format("[ERROR] %s | MenuManager | %s", timestamp, msg))
        end
    }
end

-- ...existing MenuManager methods (createMenuForGroup, refreshMenuForGroup, etc.)...

function MenuManager:createMenuForGroup(groupId)
    if not groupId or type(groupId) ~= "number" then
        self.logger:warn("createMenuForGroup: Invalid groupId " .. tostring(groupId))
        return nil
    end
    
    if self.menus[groupId] then
        self.logger:warn("createMenuForGroup: Menu already exists for group " .. groupId)
        return self.menus[groupId]
    end
    
    local menu = {
        groupId = groupId,
        groupName = self:_getGroupName(groupId),
        children = {},
        _lookup = {},
        manager = self,
        nextItemId = 1
    }
    
    setmetatable(menu, { __index = Menu })
    self.menus[groupId] = menu
    
    self.logger:info("createMenuForGroup: Created menu for group " .. groupId)
    
    return menu
end

function MenuManager:refreshMenuForGroup(groupId)
    if not self.menus[groupId] then
        return {
            success = false,
            message = "Menu not found for group " .. groupId,
            refreshedCount = 0
        }
    end
    
    local menu = self.menus[groupId]
    missionCommands.removeItemForGroup(groupId, nil)
    
    local count = 0
    for _, item in ipairs(menu.children) do
        count = count + self:_rebuildMenuNode(groupId, {}, item)
    end
    
    self.logger:info("refreshMenuForGroup: Refreshed " .. count .. " items for group " .. groupId)
    
    return {
        success = true,
        message = "Menu refreshed for group " .. groupId .. ": " .. count .. " items loaded",
        refreshedCount = count
    }
end

function MenuManager:_rebuildMenuNode(groupId, parentPath, node)
    local count = 0
    
    if node.type == "submenu" then
        local path = #parentPath > 0 and parentPath or nil
        missionCommands.addSubMenuForGroup(groupId, node.name, path)
        count = count + 1
        
        local childPath = {}
        for i, p in ipairs(parentPath) do
            childPath[i] = p
        end
        table.insert(childPath, node.name)
        
        for _, child in ipairs(node.children or {}) do
            count = count + self:_rebuildMenuNode(groupId, childPath, child)
        end
    
    elseif node.type == "command" then
        local path = #parentPath > 0 and parentPath or nil
        
        local wrappedFunc = function()
            if node.functionToCall then
                local arg = type(node.anyArgument) == "table" and node.anyArgument or {}
                local success, err = pcall(node.functionToCall, arg)
                if not success then
                    self.logger:error("Command callback failed for '" .. node.name .. "': " .. tostring(err))
                end
            end
        end
        
        missionCommands.addCommandForGroup(groupId, node.name, path, wrappedFunc, {})
        count = count + 1
    end
    
    return count
end

function MenuManager:getMenuByGroupId(groupId)
    return self.menus[groupId] or nil
end

function MenuManager:getMenuByGroupName(groupName)
    for groupId, menu in pairs(self.menus) do
        if menu.groupName == groupName then
            return menu
        end
    end
    return nil
end

function MenuManager:getMenuByUnitName(unitName)
    local unit = Unit.getByName(unitName)
    if unit then
        local group = unit:getGroup()
        if group then
            return self:getMenuByGroupId(group:getID())
        end
    end
    return nil
end

function MenuManager:getMenuByUnitId(unitId)
    local unit = Unit.getByID(unitId)
    if unit then
        local group = unit:getGroup()
        if group then
            return self:getMenuByGroupId(group:getID())
        end
    end
    return nil
end

function MenuManager:_getGroupName(groupId)
    --Group.getByID(groupId)
    local _oGroups = {}
    for i, gp in pairs(coalition.getGroups(0)) do
        table.insert(_oGroups, gp)
    end
    for i, gp in pairs(coalition.getGroups(1)) do
        table.insert(_oGroups, gp)
    end
    for i, gp in pairs(coalition.getGroups(2)) do
        table.insert(_oGroups, gp)
    end
    for i, gp in pairs(_oGroups) do
        if gp:getID() == groupId then
            return gp:getName()
        end
    end
    return "Unknown"
end

-- =============================================================================
-- Menu: Individual menu for a group
-- =============================================================================

Menu = {}

function Menu:addSubMenu(pathTable, menuName)
    if not pathTable or type(pathTable) ~= "table" then
        pathTable = {}
    end
    
    if not menuName or type(menuName) ~= "string" then
        return {
            success = false,
            message = "Invalid menu name",
            subMenuId = nil
        }
    end
    
    local parent = self:_findNode(pathTable)
    
    if not parent then
        return {
            success = false,
            message = "Path not found: " .. self:_pathToString(pathTable),
            subMenuId = nil
        }
    end
    
    if parent.type == "command" then
        return {
            success = false,
            message = "Cannot add submenu to command node at " .. self:_pathToString(pathTable),
            subMenuId = nil
        }
    end
    
    if parent.children then
        for _, child in ipairs(parent.children) do
            if child.name == menuName and child.type == "submenu" then
                return {
                    success = true,
                    message = "Submenu '" .. menuName .. "' already exists",
                    subMenuId = child.id
                }
            end
        end
    end
    
    local subMenuId = "sub_" .. self.nextItemId
    self.nextItemId = self.nextItemId + 1
    
    local newNode = {
        id = subMenuId,
        name = menuName,
        type = "submenu",
        index = #(parent.children or {}) + 1,
        children = {}
    }
    
    if not parent.children then
        parent.children = {}
    end
    table.insert(parent.children, newNode)
    
    local fullPath = self:_buildPathString(pathTable, menuName)
    self._lookup[fullPath] = newNode
    
    self.manager.logger:info("addSubMenu: Added '" .. menuName .. "' at path " .. fullPath .. " for group " .. self.groupId)
    
    return {
        success = true,
        message = "Submenu '" .. menuName .. "' added successfully",
        subMenuId = subMenuId
    }
end

function Menu:addCommand(pathTable, commandName, functionToCall, anyArgument)
    if not pathTable or type(pathTable) ~= "table" then
        pathTable = {}
    end
    
    if not commandName or type(commandName) ~= "string" then
        return {
            success = false,
            message = "Invalid command name",
            commandId = nil
        }
    end
    
    if not functionToCall or type(functionToCall) ~= "function" then
        return {
            success = false,
            message = "Invalid function reference",
            commandId = nil
        }
    end
    
    if anyArgument ~= nil and type(anyArgument) ~= "table" then
        return {
            success = false,
            message = "anyArgument must be a table, not " .. type(anyArgument),
            commandId = nil
        }
    end
    
    local parent = self:_findNode(pathTable)
    
    if not parent then
        return {
            success = false,
            message = "Path not found: " .. self:_pathToString(pathTable),
            commandId = nil
        }
    end
    
    if parent.type == "command" then
        return {
            success = false,
            message = "Cannot add command to command node at " .. self:_pathToString(pathTable),
            commandId = nil
        }
    end
    
    if self:_countTotalItems() >= 1000 then
        return {
            success = false,
            message = "Menu capacity exceeded (max 1000 items)",
            commandId = nil
        }
    end
    
    local commandId = "cmd_" .. self.nextItemId
    self.nextItemId = self.nextItemId + 1
    
    local newNode = {
        id = commandId,
        name = commandName,
        type = "command",
        index = #(parent.children or {}) + 1,
        functionToCall = functionToCall,
        anyArgument = anyArgument or {}
    }
    
    if not parent.children then
        parent.children = {}
    end
    table.insert(parent.children, newNode)
    
    local fullPath = self:_buildPathString(pathTable, commandName)
    self._lookup[fullPath] = newNode
    
    self.manager.logger:info("addCommand: Added '" .. commandName .. "' at path " .. fullPath .. " for group " .. self.groupId)
    
    return {
        success = true,
        message = "Command '" .. commandName .. "' added successfully",
        commandId = commandId
    }
end

function Menu:removeMenuBranch(pathTable)
    if not pathTable or type(pathTable) ~= "table" then
        pathTable = {}
    end
    
    if #pathTable == 0 then
        return {
            success = false,
            message = "Cannot remove root menu",
            removedCount = 0
        }
    end
    
    local parentPath = {}
    for i = 1, #pathTable - 1 do
        table.insert(parentPath, pathTable[i])
    end
    local itemName = pathTable[#pathTable]
    
    local parent = self:_findNode(parentPath)
    if not parent or not parent.children then
        return {
            success = false,
            message = "Path not found: " .. self:_pathToString(pathTable),
            removedCount = 0
        }
    end
    
    local childIndex = nil
    for i, child in ipairs(parent.children) do
        if child.name == itemName then
            childIndex = i
            break
        end
    end
    
    if not childIndex then
        return {
            success = false,
            message = "Item not found: " .. itemName,
            removedCount = 0
        }
    end
    
    local child = parent.children[childIndex]
    local count = self:_countNodeItems(child)
    
    table.remove(parent.children, childIndex)
    
    for i, ch in ipairs(parent.children) do
        ch.index = i
    end
    
    self:_cleanupLookup(self:_buildPathString(pathTable, ""))
    
    self.manager.logger:info("removeMenuBranch: Removed branch at " .. self:_pathToString(pathTable) .. " with " .. count .. " items for group " .. self.groupId)
    
    return {
        success = true,
        message = "Removed branch with " .. count .. " items",
        removedCount = count
    }
end

function Menu:refresh()
    return self.manager:refreshMenuForGroup(self.groupId)
end

-- =============================================================================
-- Private Helper Methods
-- =============================================================================

function Menu:_findNode(pathTable)
    if not pathTable or #pathTable == 0 then
        return self
    end
    
    local current = self
    for i, segment in ipairs(pathTable) do
        if not current.children then
            current.children = {}
        end
        
        local found = nil
        for _, child in ipairs(current.children) do
            if child.name == segment then
                found = child
                break
            end
        end
        
        if not found then
            found = {
                name = segment,
                type = "submenu",
                index = #current.children + 1,
                children = {}
            }
            table.insert(current.children, found)
        end
        
        current = found
    end
    
    return current
end

function Menu:_pathToString(pathTable)
    if not pathTable or #pathTable == 0 then
        return "/"
    end
    return table.concat(pathTable, ".")
end

function Menu:_buildPathString(pathTable, itemName)
    local path = {}
    for _, p in ipairs(pathTable) do
        table.insert(path, p)
    end
    if itemName and itemName ~= "" then
        table.insert(path, itemName)
    end
    return table.concat(path, ".")
end

function Menu:_countNodeItems(node)
    if not node then
        return 0
    end
    local count = 1
    if node.children then
        for _, child in ipairs(node.children) do
            count = count + self:_countNodeItems(child)
        end
    end
    return count
end

function Menu:_countTotalItems()
    local count = 0
    for _, child in ipairs(self.children) do
        count = count + self:_countNodeItems(child)
    end
    return count
end

function Menu:_cleanupLookup(pathPrefix)
    for key in pairs(self._lookup) do
        if key:find(pathPrefix, 1, true) == 1 then
            self._lookup[key] = nil
        end
    end
end

-- =============================================================================
-- TEST EXAMPLES - Section Tests Dynamiques
-- =============================================================================

local function exampleBasicCTLDMenu()
    local mgr = MenuManager:getInstance()
    
    local function deployInfantry(arg)
        local deployType = arg.deployType or "Unknown"
        trigger.action.outText("Infantry deployed: " .. deployType, 5)
    end
    
    local function deployAntiAir(arg)
        local teamType = arg.teamType or "Standard"
        trigger.action.outText("Anti-Air Team (" .. teamType .. ") deployed", 5)
    end
    
    local function deployVehicle(arg)
        local vehicleId = arg.vehicleId or "Unknown"
        local vehicleNum = arg.vehicleNum or 0
        trigger.action.outText("Vehicle " .. vehicleId .. " (#" .. vehicleNum .. ") deployed", 5)
    end
    
    if Unit.getByName("h1-1") then
        local unit = Unit.getByName("h1-1")
        local group = unit:getGroup()
        local groupId = group:getID()
        local groupName = group:getName()
        
        local menu = mgr:createMenuForGroup(groupId)
        
        if menu then
            menu:addSubMenu({}, "CTLD")
            menu:addSubMenu({}, "JTAC")
            menu:addSubMenu({}, "BEACON")
            
            menu:addSubMenu({"CTLD"}, "Troop Transport")
            menu:addSubMenu({"CTLD"}, "Vehicles")
            menu:addSubMenu({"CTLD"}, "Drone")
            
            menu:addCommand({"CTLD", "Troop Transport"}, "Infantry", deployInfantry, { deployType = "Infantry_Squad", size = 12 })
            menu:addCommand({"CTLD", "Troop Transport"}, "Anti Air", deployAntiAir, { teamType = "Stinger", count = 4 })
            
            for i = 1, 15 do
                menu:addCommand({"CTLD", "Vehicles"}, "vehicle_" .. string.format("%02d", i), deployVehicle, { vehicleId = "Vehicle_ID_" .. i, vehicleNum = i })
            end
            
            local refreshResult = mgr:refreshMenuForGroup(groupId)
            
            if refreshResult.success then
                trigger.action.outText("CTLD Menu created successfully for group '" .. groupName .. "'\nTotal items: " .. refreshResult.refreshedCount, 5)
            else
                trigger.action.outText("Error refreshing menu: " .. refreshResult.message, 5)
            end
        else
            trigger.action.outText("Failed to create menu for group " .. groupId, 5)
        end
    else
        trigger.action.outText("Unit 'h1-1' not found in mission", 5)
    end
end

local function exampleDynamicMenuUpdate()
    local function detectNearbyVehicles(groupId)
        return {
            { id = "tank_01", name = "M1 Abrams", type = "Heavy Tank" },
            { id = "hmmwv_01", name = "HMMWV", type = "Transport" },
            { id = "truck_01", name = "Supply Truck", type = "Logistics" },
            { id = "aa_01", name = "Patriot SAM", type = "Air Defense" }
        }
    end
    
    local function callInVehicle(arg)
        local vehicleName = arg.name or "Unknown Vehicle"
        local vehicleType = arg.type or "Transport"
        trigger.action.outText("Requesting " .. vehicleName .. " (" .. vehicleType .. ")", 5)
    end
    
    local mgr = MenuManager:getInstance()
    local menu = mgr:getMenuByGroupId(42)
    
    if menu then
        local removeResult = menu:removeMenuBranch({"CTLD", "Vehicles"})
        if removeResult.success then
            trigger.action.outText("Cleared " .. removeResult.removedCount .. " old vehicle entries", 5)
        end
        
        menu:addSubMenu({"CTLD"}, "Vehicles")
        
        local vehicles = detectNearbyVehicles(42)
        for _, vehicle in ipairs(vehicles) do
            menu:addCommand({"CTLD", "Vehicles"}, vehicle.name, callInVehicle, vehicle)
        end
        
        local refreshResult = mgr:refreshMenuForGroup(42)
        if refreshResult.success then
            trigger.action.outText("Vehicle menu updated: " .. refreshResult.refreshedCount .. " vehicles available", 5)
        end
    else
        trigger.action.outText("No menu found for group 42", 5)
    end
end

local function exampleMenuLookup()
    local mgr = MenuManager:getInstance()
    
    local menu1 = mgr:getMenuByUnitName("Alpha-1-1")
    if menu1 then
        trigger.action.outText("Found menu for unit 'Alpha-1-1' in group " .. menu1.groupId, 5)
        menu1:addCommand({}, "New Command", function(arg) end, { testArg = "test" })
        mgr:refreshMenuForGroup(menu1.groupId)
    end
    
    local menu2 = mgr:getMenuByUnitId(1001)
    if menu2 then
        trigger.action.outText("Found menu for unit ID 1001 in group " .. menu2.groupId, 5)
    end
    
    local menu3 = mgr:getMenuByGroupName("Alpha")
    if menu3 then
        trigger.action.outText("Found menu for group named 'Alpha' (ID: " .. menu3.groupId .. ")", 5)
    end
    
    local menu4 = mgr:getMenuByGroupId(42)
    if menu4 then
        trigger.action.outText("Found menu for group ID 42", 5)
    end
end

local function exampleErrorHandling()
    local mgr = MenuManager:getInstance()
    local menu = mgr:createMenuForGroup(99)
    
    if menu then
        local result1 = menu:addCommand({"NonExistent", "Path"}, "Test", function(arg) end, { testValue = "test" })
        if not result1.success then
            trigger.action.outText("Expected error: " .. result1.message, 3)
        end
        
        local result2 = menu:addCommand({}, "BadFunc", "not_a_function", { testValue = "test" })
        if not result2.success then
            trigger.action.outText("Expected error: " .. result2.message, 3)
        end
        
        menu:addCommand({}, "MyCommand", function(arg) end, { testArg = "value" })
        local result3 = menu:addSubMenu({"MyCommand"}, "BadSubmenu")
        if not result3.success then
            trigger.action.outText("Expected error: " .. result3.message, 3)
        end
    end
end

-- =============================================================================
-- Test Runner
-- =============================================================================

if true then
    MenuManager:getInstance()
    
    trigger.action.outText("Starting CTLD Menu Tests...", 5)
    
    exampleBasicCTLDMenu()
    
    -- Décommenter pour exécuter d'autres tests:
    -- exampleDynamicMenuUpdate()
    -- exampleMenuLookup()
    -- exampleErrorHandling()
    
    trigger.action.outText("CTLD Menu Tests Complete", 5)
end

return MenuManager
