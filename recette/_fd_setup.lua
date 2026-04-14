---@diagnostic disable
-- ============================================================
-- recette/_fd_setup.lua
-- Shared setup for Feature D (LoadableGroups) unit tests.
-- Loads all dependencies, stubs CTLDPlayerManager + missionCommands,
-- and returns a freshly initialised CTLDTroopManager instance.
-- Usage:
--   dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")
--   local mgr = dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/_fd_setup.lua")
-- ============================================================

local SRC = "C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/"

dofile(SRC .. "CTLD_core.lua")
dofile(SRC .. "lib/CTLD_objectRegistry.lua")
dofile(SRC .. "lib/CTLDParachuteEffect.lua")

-- Stubs for unit isolation
CTLDPlayerManager = CTLDPlayerManager or {}
CTLDPlayerManager.getInstance = CTLDPlayerManager.getInstance
    or function() return { registerMenuSection = function() end } end

missionCommands = missionCommands or {
    addSubMenuForGroup = function() return {} end,
    addCommandForGroup = function() end,
    removeItemForGroup = function() end,
}

dofile(SRC .. "CTLD_troop.lua")

-- Inject minimal config (2 standard templates)
CTLDConfig.get().settings["loadableGroups"] = {
    { name = "Standard Group", inf = 6, mg = 2, at = 2 },
    { name = "JTAC Group",     inf = 4, jtac = 1 },
}
CTLDConfig.get().settings["numberOfTroops"]    = 10
CTLDConfig.get().settings["transportLimitByType"] = {}

-- Clear ctld_config_user so _loadUserConfig() is a no-op (avoids cross-test contamination)
ctld_config_user = nil

-- Reset singleton so each test gets a fresh instance
CTLDTroopManager._instance = nil

local mgr = CTLDTroopManager.getInstance()
return mgr
