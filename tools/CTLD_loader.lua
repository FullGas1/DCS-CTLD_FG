---@diagnostic disable
-- CTLD Dev Loader
-- Manually maintained load order for development via Witchcraft.
-- For production: use tools/merger_V2/merge_CTLD.ps1 to produce CTLD_futur.lua.
--
-- HOW TO USE:
--   1. Set CTLD_SOURCE_PATH to the absolute path of your src/ directory.
--   2. Use forward slashes. End with a trailing slash.
--   3. In your DCS mission trigger: dofile('absolute/path/to/CTLD_loader.lua')

local CTLD_SOURCE_PATH = "C:/replace/with/your/absolute/path/to/src/"  -- CONFIGURE THIS

-- OOP micro-framework (must be first)
dofile(CTLD_SOURCE_PATH .. "lib/class.lua")

-- Core foundations (no business state)
dofile(CTLD_SOURCE_PATH .. "CTLD_config.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_i18n.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_i18n_en.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_i18n_fr.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_i18n_es.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_i18n_ko.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_utils.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_menu.lua")
dofile(CTLD_SOURCE_PATH .. "lib/CTLD_objectRegistry.lua")  -- spawn descriptors + scene objects DB

-- Scene engine (before scene data files)
dofile(CTLD_SOURCE_PATH .. "CTLD_sceneManager.lua")

-- Business domain managers
dofile(CTLD_SOURCE_PATH .. "CTLD_zone.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_troop.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_crate.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_vehicle.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_fob.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_aasystem.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_beacon.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_recon.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_jtac.lua")
dofile(CTLD_SOURCE_PATH .. "CTLD_player.lua")

-- Orchestrator
dofile(CTLD_SOURCE_PATH .. "CTLD_core.lua")

-- Scene data (after CTLDSceneManager registry is ready)
dofile(CTLD_SOURCE_PATH .. "scenes/CTLD_farpScene.lua")
dofile(CTLD_SOURCE_PATH .. "scenes/CTLD_fobScene.lua")
dofile(CTLD_SOURCE_PATH .. "scenes/CTLD_mineFieldScene.lua")
-- AA system compositions are embedded in CTLDCrateAssemblyManager.TEMPLATES (CTLD_aasystem.lua)
-- No separate scene files needed for AA systems.

-- User configuration (always last)
dofile(CTLD_SOURCE_PATH .. "CTLD_userConfig.lua")
