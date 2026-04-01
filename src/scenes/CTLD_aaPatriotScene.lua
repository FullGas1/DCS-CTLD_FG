---@diagnostic disable
-- CTLD_aaPatriotScene.lua
-- Patriot AA System scene — defines the unit composition for the Patriot battery.
--
-- Source: ctld.AASystemTemplate[2] in CTLD.lua (root)
--   Name  : "Patriot AA System"
--   Count : 4 crates required
--   Parts : Patriot ln x8 (launcher), Patriot ECS (control unit), Patriot str x2 (radar)
--   NoCrate: Patriot AMG (DL relay) — spawned without crate
--
-- Note: Assembly logic handled by CTLDCrateAssemblyManager.
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager
-- ====================================================================================================

local aaPatriotScene = {}
aaPatriotScene.name = "Patriot AA System"

aaPatriotScene.stepsDatas = {
    { registryKey = "Patriot ln",  polar = { dist = 0,  angle = 0   }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ln",  polar = { dist = 20, angle = 45  }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ln",  polar = { dist = 20, angle = 90  }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ln",  polar = { dist = 20, angle = 135 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ln",  polar = { dist = 20, angle = 180 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ln",  polar = { dist = 20, angle = 225 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ln",  polar = { dist = 20, angle = 270 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ln",  polar = { dist = 20, angle = 315 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot ECS", polar = { dist = 40, angle = 0   }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot str", polar = { dist = 50, angle = 60  }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot str", polar = { dist = 50, angle = 300 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Patriot AMG", polar = { dist = 35, angle = 180 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(aaPatriotScene)
