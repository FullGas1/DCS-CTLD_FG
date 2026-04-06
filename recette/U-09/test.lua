---@diagnostic disable
-- ============================================================
-- U-09 : CTLDZoneManager._parseTRZ — formats invalides
-- Module  : M1 (src/CTLD_zone.lua)
-- Objectif: Le parser retourne nil + message d'erreur pour des
--           noms invalides : non-TRZ, TRZ sans zoneName.
-- ============================================================

-- Purge CTLD.log
do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_core.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_zone.lua")

ctld_test.start("U-09", "CTLDZoneManager._parseTRZ — formats invalides")

local zm = setmetatable({}, CTLDZoneManager)

-- 1. Préfixe incorrect → erreur "not a TRZ"
local r1, e1 = zm:_parseTRZ("LGZ_alpha_B")
ctld_test.assertNil(r1,      "LGZ_alpha_B : résultat nil")
ctld_test.assertNotNil(e1,   "LGZ_alpha_B : message erreur non-nil")
ctld_test.assert(e1:find("not a TRZ") ~= nil, "LGZ_alpha_B : erreur contient 'not a TRZ'")

-- 2. Préfixe différent → nil
local r2, e2 = zm:_parseTRZ("PKZ_alpha")
ctld_test.assertNil(r2, "PKZ_alpha : résultat nil")
ctld_test.assertNotNil(e2, "PKZ_alpha : erreur non-nil")

-- 3. Juste "TRZ" sans zoneName → erreur "missing zoneName"
local r3, e3 = zm:_parseTRZ("TRZ")
ctld_test.assertNil(r3, "TRZ seul : résultat nil")
ctld_test.assertNotNil(e3, "TRZ seul : message erreur non-nil")
ctld_test.assert(e3:find("zoneName") ~= nil, "TRZ seul : erreur mentionne zoneName")

-- 4. "TRZ_" (prefix + underscore mais zoneName vide) → nil
--    Note : selon _split, "TRZ_" donne parts={"TRZ"} car la chaîne se termine par _
--    Le parser détecte parts[2] == nil → "missing zoneName"
local r4, e4 = zm:_parseTRZ("TRZ_")
ctld_test.assertNil(r4, "TRZ_ seul : résultat nil")

-- 5. Nom vide → nil
local r5, e5 = zm:_parseTRZ("")
ctld_test.assertNil(r5, "chaîne vide : résultat nil")

-- 6. Nom sans préfixe TRZ
local r6, e6 = zm:_parseTRZ("alpha_B_10")
ctld_test.assertNil(r6, "alpha_B_10 sans préfixe : résultat nil")

ctld_test.finish()
