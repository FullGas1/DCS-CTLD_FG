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
farpScene.steps = {
    {
        registryKey              = "SINGLE_HELIPAD",
        polar                    = { distance = 0, angle = 0 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },
    {
        registryKey              = "FARP_Tent",
        polar                    = { distance = 30, angle = 90 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },
    {
        registryKey              = "FARP_Ammo_Storage",
        polar                    = { distance = 30, angle = 135 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },
    {
        registryKey              = "Windsock",
        polar                    = { distance = 15, angle = 270 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },
    {
        registryKey              = "Fuel_Truck",
        polar                    = { distance = 35, angle = 225 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(farpScene)
