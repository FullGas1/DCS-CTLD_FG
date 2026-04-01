---@diagnostic disable
-- CTLD_aaBukScene.lua
-- BUK AA System scene — defines the unit composition for the BUK battery.
--
-- Source: ctld.AASystemTemplate[4] in CTLD.lua (root)
--   Name  : "BUK AA System"
--   Count : 3 crates required
--   Parts : SA-11 Buk LN 9A310M1 (launcher), SA-11 Buk CC 9S470M1 (CC radar), SA-11 Buk SR 9S18M1 (search radar)
--
-- Note: Assembly logic handled by CTLDCrateAssemblyManager.
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager
-- ====================================================================================================

local aaBukScene = {}
aaBukScene.name = "BUK AA System"

aaBukScene.stepsDatas = {
    { registryKey = "SA-11 Buk LN 9A310M1", polar = { dist = 0,  angle = 0   }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "SA-11 Buk CC 9S470M1", polar = { dist = 30, angle = 120 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "SA-11 Buk SR 9S18M1",  polar = { dist = 30, angle = 240 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(aaBukScene)
