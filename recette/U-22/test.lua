---@diagnostic disable
-- ============================================================
-- U-22 : getDesc().box existence sur C-130J-30
-- Module  : M5 (src/CTLD_vehicle.lua)
-- Statut  : PENDING IMPLEMENTATION
-- Note    : Ce test vérifie une API DCS réelle (desc.box).
--           Il nécessite qu'un C-130J-30 soit présent dans la mission.
-- ============================================================

-- Purge CTLD.log
do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

ctld_test.start("U-22", "getDesc().box — existence sur C-130J-30")

-- TODO: pending CTLDVehicle implementation
-- Ce test nécessite également qu'un C-130J-30 soit spawné dans la mission martyr.
--
-- Plan de test :
--   1. Obtenir une unité C-130J-30 via Unit.getByName("c130_test") ou
--      chercher dans la liste des unités de la coalition.
--   2. Appeler unit:getDesc()
--   3. Vérifier que desc ~= nil
--   4. Vérifier que desc.box ~= nil
--   5. Vérifier que desc.box.min et desc.box.max existent
--   6. Vérifier que les dimensions sont cohérentes (min.x < max.x, etc.)
--
-- DEPENDENCY: mission martyr doit contenir un C-130J-30 nommé "c130_test"
--
-- local unit = Unit.getByName("c130_test")
-- ctld_test.assertNotNil(unit, "C-130J-30 'c130_test' trouvé dans la mission")
-- if unit then
--     local desc = unit:getDesc()
--     ctld_test.assertNotNil(desc,       "getDesc() non-nil")
--     ctld_test.assertNotNil(desc.box,   "desc.box non-nil")
--     ctld_test.assertNotNil(desc.box.min, "desc.box.min non-nil")
--     ctld_test.assertNotNil(desc.box.max, "desc.box.max non-nil")
--     ctld_test.assert(desc.box.min.x < desc.box.max.x, "box.min.x < box.max.x")
--     ctld_test.assert(desc.box.min.z < desc.box.max.z, "box.min.z < box.max.z")
-- end

ctld_test.assert(true, "PENDING — test non exécutable avant implémentation CTLDVehicle")
ctld_test.finish()
