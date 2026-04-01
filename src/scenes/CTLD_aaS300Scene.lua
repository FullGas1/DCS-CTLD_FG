---@diagnostic disable
-- CTLD_aaS300Scene.lua
-- S-300 AA System scene — defines the unit composition for the S-300 PS battery.
--
-- Source: ctld.AASystemTemplate[6] in CTLD.lua (root)
--   Name  : "S-300 AA System"
--   Count : 6 crates required
--   Parts :
--     S-300PS 5P85C ln  (TEL C — launcher, crated)
--     S-300PS 5P85D ln  x2 (TEL D — NoCrate)
--     S-300PS 40B6M tr  (Flap Lid-A TR)
--     S-300PS 40B6MD sr (Clam Shell SR)
--     S-300PS 64H6E sr  (Big Bird SR)
--     S-300PS 54K6 cp   (C2)
--
-- Note: Assembly logic handled by CTLDCrateAssemblyManager.
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager
-- ====================================================================================================

local aaS300Scene = {}
aaS300Scene.name = "S-300 AA System"

aaS300Scene.stepsDatas = {
    { registryKey = "S-300PS 5P85C ln",  polar = { dist = 0,  angle = 0   }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "S-300PS 5P85D ln",  polar = { dist = 20, angle = 60  }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "S-300PS 5P85D ln",  polar = { dist = 20, angle = 120 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "S-300PS 40B6M tr",  polar = { dist = 50, angle = 180 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "S-300PS 40B6MD sr", polar = { dist = 60, angle = 240 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "S-300PS 64H6E sr",  polar = { dist = 60, angle = 300 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "S-300PS 54K6 cp",   polar = { dist = 40, angle = 330 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(aaS300Scene)
