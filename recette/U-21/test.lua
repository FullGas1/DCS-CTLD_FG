---@diagnostic disable
-- ============================================================
-- U-21 : _worldToLocal + bbox inclusion (algo géométrique pur)
-- Module  : M5 (src/CTLD_vehicle.lua)
-- Statut  : PENDING IMPLEMENTATION
-- ============================================================

-- Purge CTLD.log
do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

ctld_test.start("U-21", "_worldToLocal + bbox inclusion — algo géométrique pur")

-- TODO: pending CTLDVehicle implementation
-- Ce test sera complété dès que src/CTLD_vehicle.lua sera disponible.
--
-- Plan de test (algorithme pur, sans DCS) :
--   1. Définir une bbox (min/max en coordonnées locales)
--   2. Définir une matrice de transformation world→local (heading connu)
--   3. Appeler _worldToLocal(worldPoint, transportPos, heading)
--   4. Vérifier que le point converti est bien dans la bbox (min<=x<=max)
--   5. Tester un point dehors de la bbox
--
-- Paramètres typiques C-130J-30 (source desc.box) :
--   min = { x=-15, y=-2, z=-3 }, max = { x=15, y=3, z=3 }
--
-- dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_vehicle.lua")
--
-- local bbox = { min = {x=-15,y=-2,z=-3}, max = {x=15,y=3,z=3} }
-- local transportPos = { x=1000, y=0, z=2000 }
-- local heading = 0  -- nord
-- local ptInside  = { x=1005, y=0, z=2000 }  -- 5 m devant = dans bbox
-- local ptOutside = { x=1020, y=0, z=2000 }  -- 20 m devant = hors bbox
-- local localIn  = CTLDVehicleSpawner._worldToLocal(ptInside, transportPos, heading)
-- local localOut = CTLDVehicleSpawner._worldToLocal(ptOutside, transportPos, heading)
-- ctld_test.assert(localIn.x >= bbox.min.x and localIn.x <= bbox.max.x, "ptInside dans bbox")
-- ctld_test.assert(localOut.x > bbox.max.x, "ptOutside hors bbox")

ctld_test.assert(true, "PENDING — test non exécutable avant implémentation CTLDVehicleSpawner")
ctld_test.finish()
