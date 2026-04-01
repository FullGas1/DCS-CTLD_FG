---@diagnostic disable
-- CTLD_farpScene.lua
-- FARP deployment scene — spawns a functional Forward Arming and Refueling Point.
--
-- Objects registered (all in CTLDObjectRegistry):
--   SINGLE_HELIPAD  — landing pad (logistic zone anchor)
--   FARP_Tent       — crew tent
--   FARP_Ammo_Storage — ammunition dump
--   Windsock        — wind indicator / logistic unit marker
--   Fuel_Truck      — coalition-aware fuel truck
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager, CTLDUtils
-- ====================================================================================================

local farpScene = {}
farpScene.name = "farpScene"

-- All offsets are (dx = forward/North, dz = right/East) relative to trigger unit, metres.
farpScene.stepsDatas = {
    {
        registryKey              = "SINGLE_HELIPAD",
        polar                    = { dist = 0, angle = 0 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        func                     = nil,
    },
    {
        registryKey              = "FARP_Tent",
        polar                    = { dist = 20, angle = 90 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        func                     = nil,
    },
    {
        registryKey              = "FARP_Ammo_Storage",
        polar                    = { dist = 30, angle = 135 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        func                     = nil,
    },
    {
        registryKey              = "Windsock",
        polar                    = { dist = 15, angle = 270 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        func                     = nil,
    },
    {
        registryKey              = "Fuel_Truck",
        polar                    = { dist = 25, angle = 225 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        func                     = nil,
    },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(farpScene)
