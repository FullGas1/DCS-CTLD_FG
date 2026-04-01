---@diagnostic disable
-- CTLD_aaHawkScene.lua
-- HAWK AA System scene — defines the unit composition for the HAWK battery.
--
-- Source: ctld.AASystemTemplate[1] in CTLD.lua (root)
--   Name  : "HAWK AA System"
--   Count : 5 crates required
--   Parts : Hawk ln (launcher), Hawk tr x2 (track radar), Hawk sr x2 (search radar)
--   NoCrate: Hawk pcp (PCP), Hawk cwar x2 (CWAR) — spawned without crate
--
-- Note: This scene describes the visual/spawn composition only.
--       Assembly logic (crate matching, centroid, group spawning) is handled by CTLDCrateAssemblyManager.
--       Scene steps are used for the repair/rebuild animation sequence.
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager
-- ====================================================================================================

local aaHawkScene = {}
aaHawkScene.name   = "HAWK AA System"

-- AA scene steps represent the deployment animation after all crates are assembled.
-- Positions are relative to the crate centroid (computed by CTLDCrateAssemblyManager).
aaHawkScene.stepsDatas = {
    { registryKey = "Hawk ln",   polar = { dist = 0,  angle = 0   }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Hawk tr",   polar = { dist = 30, angle = 60  }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Hawk tr",   polar = { dist = 30, angle = 120 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Hawk sr",   polar = { dist = 40, angle = 300 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Hawk sr",   polar = { dist = 40, angle = 240 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Hawk pcp",  polar = { dist = 20, angle = 180 }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Hawk cwar", polar = { dist = 50, angle = 90  }, delayAfterPreviousStep = 1, relativeHeadingInDegrees = 0, func = nil },
    { registryKey = "Hawk cwar", polar = { dist = 50, angle = 270 }, delayAfterPreviousStep = 0, relativeHeadingInDegrees = 0, func = nil },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(aaHawkScene)
