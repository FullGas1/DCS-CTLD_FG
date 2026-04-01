---@diagnostic disable
-- CTLD_fobScene.lua
-- FOB deployment scene — spawns a Forward Operating Base (outpost + watchtower).
--
-- Source logic: ctld.spawnFOB() in CTLD.lua (root)
--   - "outpost"  static at trigger position          → FOB_container
--   - "house2arm" static at offset (-36.57, +14.86)  → FOB_watchtower
--   Post-spawn: FOB is registered as a logistic unit (done by CTLDFOBManager, not here).
--
-- Objects registered (all in CTLDObjectRegistry):
--   FOB_container   — outpost fortification (main structure)
--   FOB_watchtower  — house2arm watchtower
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager, CTLDUtils
-- ====================================================================================================

local fobScene = {}
fobScene.name = "fobScene"

fobScene.stepsDatas = {
    {
        registryKey              = "FOB_container",
        polar                    = { dist = 0, angle = 0 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        func                     = nil,
    },
    {
        -- Watchtower offset derived from ctld.spawnFOB: x+14.86, z-36.57
        -- In polar terms relative to trigger unit (approx): dist~39m, angle~158° (SE)
        registryKey              = "FOB_watchtower",
        polar                    = { dist = 39, angle = 158 },
        delayAfterPreviousStep   = 2,
        relativeHeadingInDegrees = 0,
        func                     = nil,
    },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(fobScene)
