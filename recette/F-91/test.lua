---@diagnostic disable
-- ============================================================
-- F-91 : farpScene — structure + spawn visuel en mission
-- Module  : R4 (src/scenes/CTLD_farpScene.lua)
-- REQUIRES: DCS mission running, BLUE player in slot
-- ============================================================

do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_sceneManager.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/scenes/CTLD_farpScene.lua")

ctld_test.start("F-91", "farpScene — structure 5 steps + spawn visuel")

-- ----------------------------------------------------------------
-- Part 1: Structure tests (unit)
-- ----------------------------------------------------------------
local mgr = CTLDSceneManager.getInstance()
local farp = mgr:getModel("farpScene")

ctld_test.assertNotNil(farp,                                           "farpScene enregistré après dofile")
ctld_test.assertEqual(#farp.steps, 5,                                  "5 steps dans farpScene")

-- Step 1: SINGLE_HELIPAD
ctld_test.assertEqual(farp.steps[1].registryKey, "SINGLE_HELIPAD",    "step 1 : registryKey = SINGLE_HELIPAD")
ctld_test.assertNotNil(farp.steps[1].polar,                            "step 1 : type polar présent")
ctld_test.assertEqual(farp.steps[1].polar.distance, 0,                 "step 1 : polar.distance = 0")
ctld_test.assertEqual(farp.steps[1].polar.angle, 0,                    "step 1 : polar.angle = 0")
ctld_test.assertEqual(farp.steps[1].delayAfterPreviousStep, 0,         "step 1 : delay = 0")

-- Step 2: FARP_Tent
ctld_test.assertEqual(farp.steps[2].registryKey, "FARP_Tent",          "step 2 : registryKey = FARP_Tent")
ctld_test.assertEqual(farp.steps[2].polar.distance, 30,                "step 2 : polar.distance = 30")
ctld_test.assertEqual(farp.steps[2].polar.angle, 90,                   "step 2 : polar.angle = 90°")
ctld_test.assertEqual(farp.steps[2].delayAfterPreviousStep, 1,         "step 2 : delay = 1 s")

-- Step 3: FARP_Ammo_Storage
ctld_test.assertEqual(farp.steps[3].registryKey, "FARP_Ammo_Storage",  "step 3 : registryKey = FARP_Ammo_Storage")
ctld_test.assertEqual(farp.steps[3].polar.distance, 30,                "step 3 : polar.distance = 30")
ctld_test.assertEqual(farp.steps[3].polar.angle, 135,                  "step 3 : polar.angle = 135°")

-- Step 4: Windsock
ctld_test.assertEqual(farp.steps[4].registryKey, "Windsock",           "step 4 : registryKey = Windsock")
ctld_test.assertEqual(farp.steps[4].polar.distance, 15,                "step 4 : polar.distance = 15")
ctld_test.assertEqual(farp.steps[4].polar.angle, 270,                  "step 4 : polar.angle = 270°")

-- Step 5: Fuel_Truck
ctld_test.assertEqual(farp.steps[5].registryKey, "Fuel_Truck",         "step 5 : registryKey = Fuel_Truck")
ctld_test.assertEqual(farp.steps[5].polar.distance, 35,                "step 5 : polar.distance = 35")
ctld_test.assertEqual(farp.steps[5].polar.angle, 225,                  "step 5 : polar.angle = 225°")
ctld_test.assertEqual(farp.steps[5].delayAfterPreviousStep, 1,         "step 5 : delay = 1 s")

-- All steps have relativeAltitudeInMeters
local allHaveAlt = true
for _, s in ipairs(farp.steps) do
    if s.relativeAltitudeInMeters == nil then allHaveAlt = false; break end
end
ctld_test.assert(allHaveAlt,                                            "tous les steps ont relativeAltitudeInMeters")

ctld_test.finish()

-- ----------------------------------------------------------------
-- Part 2: Visual spawn (requires live DCS mission)
-- ----------------------------------------------------------------
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local unit = players[1]
if not unit then
    trigger.action.outText("F-91 VISUAL SKIP: no BLUE player found", 10)
    env.info("[F-91] VISUAL SKIP: no BLUE player")
    return
end

env.info("[F-91] Triggering farpScene for unit: " .. unit:getName())

mgr:playScene(unit, "farpScene", {}, function(scene)
    env.info("[F-91] farpScene onComplete fired. Spawned objects: " .. #scene._spawnedObjs)
end)

trigger.action.outText(
    "F-91 VISUAL CHECK (farpScene):\n" ..
    "  - SINGLE_HELIPAD spawné à la position de l'hélico\n" ..
    "  - FARP_Tent spawné ~30 m à 90° (droite)\n" ..
    "  - FARP_Ammo_Storage spawné ~30 m à 135°\n" ..
    "  - Windsock spawné ~15 m à 270° (gauche)\n" ..
    "  - Fuel_Truck spawné ~35 m à 225° (arrière-gauche)", 30)
env.info("[F-91] playScene called. Awaiting visual confirmation.")
