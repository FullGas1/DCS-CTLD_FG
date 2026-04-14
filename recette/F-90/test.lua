---@diagnostic disable
-- ============================================================
-- F-90 : fobScene — structure + spawn visuel en mission
-- Module  : R4 (src/scenes/CTLD_fobScene.lua)
-- REQUIRES: DCS mission running, BLUE player in slot
-- ============================================================

do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_sceneManager.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/scenes/CTLD_fobScene.lua")

ctld_test.start("F-90", "fobScene — structure 4 steps + spawn visuel")

-- ----------------------------------------------------------------
-- Part 1: Structure tests (unit)
-- ----------------------------------------------------------------
local mgr = CTLDSceneManager.getInstance()
local fob = mgr:getModel("fobScene")

ctld_test.assertNotNil(fob,                                        "fobScene enregistré après dofile")
ctld_test.assertEqual(#fob.steps, 4,                               "4 steps dans fobScene")

-- Step 1 (prescript): func-only
ctld_test.assertNil(fob.steps[1].registryKey,                      "step 1 : prescript — pas de registryKey")
ctld_test.assertNotNil(fob.steps[1].func,                          "step 1 : prescript — func présente")
ctld_test.assertEqual(fob.steps[1].delayAfterPreviousStep, 0,      "step 1 : delay = 0")

-- Step 2: FOB_container
ctld_test.assertEqual(fob.steps[2].registryKey, "FOB_container",   "step 2 : registryKey = FOB_container")
ctld_test.assertNotNil(fob.steps[2].polar,                         "step 2 : type polar présent")
ctld_test.assertEqual(fob.steps[2].polar.distance, 0,              "step 2 : polar.distance = 0")
ctld_test.assertEqual(fob.steps[2].polar.angle, 0,                 "step 2 : polar.angle = 0")
ctld_test.assertEqual(fob.steps[2].delayAfterPreviousStep, 0,      "step 2 : delay = 0")

-- Step 3: FOB_watchtower
ctld_test.assertEqual(fob.steps[3].registryKey, "FOB_watchtower",  "step 3 : registryKey = FOB_watchtower")
ctld_test.assertNotNil(fob.steps[3].polar,                         "step 3 : type polar présent")
ctld_test.assertEqual(fob.steps[3].polar.distance, 39,             "step 3 : polar.distance = 39")
ctld_test.assertEqual(fob.steps[3].polar.angle, 158,               "step 3 : polar.angle = 158°")
ctld_test.assertEqual(fob.steps[3].delayAfterPreviousStep, 2,      "step 3 : delay = 2 s")

-- Step 4: completion func-only
ctld_test.assertNil(fob.steps[4].registryKey,                      "step 4 : completion — pas de registryKey")
ctld_test.assertNotNil(fob.steps[4].func,                          "step 4 : completion — func présente")
ctld_test.assertEqual(fob.steps[4].delayAfterPreviousStep, 0,      "step 4 : delay = 0")

ctld_test.finish()

-- ----------------------------------------------------------------
-- Part 2: Visual spawn (requires live DCS mission)
-- ----------------------------------------------------------------
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local unit = players[1]
if not unit then
    trigger.action.outText("F-90 VISUAL SKIP: no BLUE player found", 10)
    env.info("[F-90] VISUAL SKIP: no BLUE player")
    return
end

env.info("[F-90] Triggering fobScene for unit: " .. unit:getName())

mgr:playScene(unit, "fobScene", {}, function(scene)
    env.info("[F-90] fobScene onComplete fired. Spawned objects: " .. #scene._spawnedObjs)
end)

trigger.action.outText(
    "F-90 VISUAL CHECK (fobScene):\n" ..
    "  - FOB outpost container spawned ~100 m devant l'hélico\n" ..
    "  - Watchtower spawned ~39 m à 158° du container\n" ..
    "  - Message coalition 'FOB deployed by...' reçu en fin de scène", 30)
env.info("[F-90] playScene called. Awaiting visual confirmation.")
