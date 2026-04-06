---@diagnostic disable
-- ============================================================
-- U-19 : CTLDVehicle états (WAITING → LOADED → DELIVERED)
-- Module  : M5 (src/CTLD_vehicle.lua)
-- Statut  : PENDING IMPLEMENTATION
-- ============================================================

-- Purge CTLD.log
do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

ctld_test.start("U-19", "CTLDVehicle — transitions WAITING → LOADED → DELIVERED")

-- TODO: pending CTLDVehicle implementation
-- Ce test sera complété dès que src/CTLD_vehicle.lua sera disponible.
--
-- Plan de test :
--   1. Créer CTLDVehicle:new({ ... }) avec état initial WAITING
--   2. Appeler :load(transport, player) → vérifier état == LOADED
--   3. Appeler :deliver(dropPoint) → vérifier état == DELIVERED
--   4. Vérifier les transitions interdites (ex: deliver avant load)
--
-- dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_vehicle.lua")
--
-- local v = CTLDVehicle:new({ ... })
-- ctld_test.assertEqual(v:getState(), "WAITING", "état initial == WAITING")
-- v:load(nil, "TestPlayer")
-- ctld_test.assertEqual(v:getState(), "LOADED",  "après load == LOADED")
-- v:deliver({ x=0,y=0,z=0 })
-- ctld_test.assertEqual(v:getState(), "DELIVERED", "après deliver == DELIVERED")

ctld_test.assert(true, "PENDING — test non exécutable avant implémentation CTLDVehicle")
ctld_test.finish()
