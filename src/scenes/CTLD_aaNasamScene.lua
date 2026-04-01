---@diagnostic disable
-- CTLD_aaNasamScene.lua
-- NASAMS AA System scene — defines the unit composition for the NASAMS battery.
--
-- Source: ctld.AASystemTemplate[3] in CTLD.lua (root)
--   Name  : "NASAMS AA System"
--   Count : 3 crates required
--   Parts : NASAMS_LN_C (launcher), NASAMS_Radar_MPQ64F1 (radar), NASAMS_Command_Post (CP)
--
-- Note: Assembly logic handled by CTLDCrateAssemblyManager.
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager
-- ====================================================================================================

local aaNasamScene = {}
aaNasamScene.name = "NASAMS AA System"

aaNasamScene.stepsDatas = {
    { registryKey = "NASAMS_LN_C",          polar = { dist = 0,  angle = 0   }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "NASAMS_Radar_MPQ64F1", polar = { dist = 35, angle = 60  }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "NASAMS_Command_Post",  polar = { dist = 30, angle = 300 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(aaNasamScene)
