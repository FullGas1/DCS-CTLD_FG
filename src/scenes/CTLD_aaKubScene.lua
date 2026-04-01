---@diagnostic disable
-- CTLD_aaKubScene.lua
-- KUB AA System scene — defines the unit composition for the KUB battery.
--
-- Source: ctld.AASystemTemplate[5] in CTLD.lua (root)
--   Name  : "KUB AA System"
--   Count : 2 crates required
--   Parts : Kub 2P25 ln (launcher), Kub 1S91 str (radar)
--
-- Note: Assembly logic handled by CTLDCrateAssemblyManager.
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager
-- ====================================================================================================

local aaKubScene = {}
aaKubScene.name = "KUB AA System"

aaKubScene.stepsDatas = {
    { registryKey = "Kub 2P25 ln",  polar = { dist = 0,  angle = 0  }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Kub 1S91 str", polar = { dist = 25, angle = 90 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(aaKubScene)
