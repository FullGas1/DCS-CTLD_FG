---@diagnostic disable
-- ============================================================
-- U-08 : CTLDZoneManager._parseTRZ — formats valides
-- Module  : M1 (src/CTLD_zone.lua)
-- Objectif: Parser TRZ sur 5 formats valides :
--   1. Minimal     : TRZ_alpha
--   2. Coalition   : TRZ_bravo_B
--   3. Stock       : TRZ_charlie_B_10
--   4. Flag        : TRZ_delta_R_0_obj1
--   5. Full        : TRZ_echo_N_5_win_20
-- Méthode testée en isolation : instance temporaire, pas de singleton.
-- ============================================================

-- Purge CTLD.log
do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

-- Charger uniquement zone (nécessite core pour EventDispatcher mais pas d'init)
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_core.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_zone.lua")

ctld_test.start("U-08", "CTLDZoneManager._parseTRZ — formats valides")

-- Créer une instance temporaire (sans init() pour éviter les appels DCS)
local zm = setmetatable({}, CTLDZoneManager)

-- 1. Minimal : TRZ_alpha
local r1, e1 = zm:_parseTRZ("TRZ_alpha")
ctld_test.assertNotNil(r1,               "TRZ_alpha : résultat non-nil")
ctld_test.assertNil(e1,                  "TRZ_alpha : pas d'erreur")
ctld_test.assertEqual(r1.zoneName, "alpha", "TRZ_alpha : zoneName == 'alpha'")
ctld_test.assertEqual(r1.coalition, 0,      "TRZ_alpha : coalition == 0 (neutre)")
ctld_test.assertNil(r1.pickMaxStock,        "TRZ_alpha : pickMaxStock == nil")
ctld_test.assertNil(r1.objectiveFlag,       "TRZ_alpha : objectiveFlag == nil")

-- 2. Coalition : TRZ_bravo_B
local r2 = zm:_parseTRZ("TRZ_bravo_B")
ctld_test.assertNotNil(r2, "TRZ_bravo_B : résultat non-nil")
ctld_test.assertEqual(r2.zoneName,  "bravo", "TRZ_bravo_B : zoneName == 'bravo'")
ctld_test.assertEqual(r2.coalition, coalition.side.BLUE, "TRZ_bravo_B : coalition BLUE")
ctld_test.assertNil(r2.pickMaxStock, "TRZ_bravo_B : pickMaxStock nil")

-- 3. Stock : TRZ_charlie_B_10
local r3 = zm:_parseTRZ("TRZ_charlie_B_10")
ctld_test.assertNotNil(r3,                    "TRZ_charlie_B_10 : résultat non-nil")
ctld_test.assertEqual(r3.coalition,  coalition.side.BLUE, "TRZ_charlie_B_10 : coalition BLUE")
ctld_test.assertEqual(r3.pickMaxStock, 10,    "TRZ_charlie_B_10 : pickMaxStock == 10")
ctld_test.assertNil(r3.objectiveFlag,          "TRZ_charlie_B_10 : objectiveFlag nil")

-- 4. Flag : TRZ_delta_R_0_obj1
local r4 = zm:_parseTRZ("TRZ_delta_R_0_obj1")
ctld_test.assertNotNil(r4,                      "TRZ_delta_R_0_obj1 : résultat non-nil")
ctld_test.assertEqual(r4.coalition, coalition.side.RED, "TRZ_delta_R_0_obj1 : coalition RED")
ctld_test.assertEqual(r4.pickMaxStock, 0,       "TRZ_delta_R_0_obj1 : pickMaxStock == 0 (illimité)")
ctld_test.assertEqual(r4.objectiveFlag, "obj1", "TRZ_delta_R_0_obj1 : objectiveFlag == 'obj1'")
ctld_test.assertNil(r4.objectiveTarget,          "TRZ_delta_R_0_obj1 : objectiveTarget nil")

-- 5. Full : TRZ_echo_N_5_win_20
local r5 = zm:_parseTRZ("TRZ_echo_N_5_win_20")
ctld_test.assertNotNil(r5,                       "TRZ_echo_N_5_win_20 : résultat non-nil")
ctld_test.assertEqual(r5.coalition, coalition.side.NEUTRAL, "TRZ_echo_N_5_win_20 : coalition NEUTRAL")
ctld_test.assertEqual(r5.pickMaxStock,   5,      "TRZ_echo_N_5_win_20 : pickMaxStock == 5")
ctld_test.assertEqual(r5.objectiveFlag,  "win",  "TRZ_echo_N_5_win_20 : objectiveFlag == 'win'")
ctld_test.assertEqual(r5.objectiveTarget, 20,    "TRZ_echo_N_5_win_20 : objectiveTarget == 20")

ctld_test.finish()
