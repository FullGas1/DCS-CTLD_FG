---@diagnostic disable
-- ============================================================
-- U-20 : CTLDVehicleSpawner singleton
-- Module  : M5 (src/CTLD_vehicle.lua)
-- Statut  : PENDING IMPLEMENTATION
-- ============================================================

-- Purge CTLD.log
do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

ctld_test.start("U-20", "CTLDVehicleSpawner — singleton")

-- TODO: pending CTLDVehicle implementation
-- Ce test sera complété dès que src/CTLD_vehicle.lua sera disponible.
--
-- Plan de test :
--   1. Reset CTLDVehicleSpawner._instance = nil
--   2. inst1 = CTLDVehicleSpawner.getInstance()
--   3. inst2 = CTLDVehicleSpawner.getInstance()
--   4. assert inst1 == inst2 (même référence)
--   5. assert inst1._vehicles est une table
--
-- dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_vehicle.lua")
-- CTLDVehicleSpawner._instance = nil
-- local s1 = CTLDVehicleSpawner.getInstance()
-- local s2 = CTLDVehicleSpawner.getInstance()
-- ctld_test.assert(s1 == s2, "singleton : même référence")

ctld_test.assert(true, "PENDING — test non exécutable avant implémentation CTLDVehicleSpawner")
ctld_test.finish()
