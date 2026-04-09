---@diagnostic disable
-- ============================================================
-- F-84 : mineFieldScene.setLandMine — 5×15 (colonnes impaires)
-- Module  : M10 (src/scenes/CTLD_mineFieldScene.lua)
-- Objectif: quinconce 5 cols × 15 lignes = 68 mines réelles + grand quad F10
-- VISUAL  : mines en quinconce 5col×15lig + quad F10
--           odd rows (1,3,...,15): 8 × 5 = 40 mines
--           even rows (2,4,...,14): 7 × 4 = 28 mines
--           total = 68 mines
-- ============================================================

do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/lib/CTLD_objectRegistry.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_sceneManager.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/scenes/CTLD_mineFieldScene.lua")

ctld_test.start("F-84", "mineFieldScene setLandMine 5x15 quinconce")

local transport = ctld_test.getTransport()
if not transport then ctld_test.finish() return end

local scene = CTLDSceneManager.getInstance():getModel("mineField")

-- Count existing mines in mission before spawning
local function countMines(coa)
    local count = 0
    local statics = coalition.getStaticObjects(coa)
    if statics then
        for _, obj in pairs(statics) do
            if obj and obj:isExist() and obj:getName():find("^Mine%-") then
                count = count + 1
            end
        end
    end
    return count
end

local coa = transport:getCoalition()
local before = countMines(coa)

-- 5 colonnes (impair) × 15 lignes, espacement 6m latéral × 12m longitudinal
-- quinconce: 8 odd rows × 5 + 7 even rows × 4 = 40 + 28 = 68 mines
local ok, result = scene.setLandMine(transport, 20, 5, 15, 6, 12)

ctld_test.assert(ok,                          "T1: return true")
ctld_test.assertNotNil(result,                "T2: result non-nil")
ctld_test.assertEqual(#result, 68,            "T3: 68 mines spawned — quinconce 5×15 (return value)")

local after = countMines(coa)
ctld_test.assertEqual(after - before, 68,     "T4: 68 mines statiques dans la mission (coalition.getStaticObjects)")

env.info("[F-84] VISUAL: 68 mines quinconce 5col×15lig + grand quad F10")

ctld_test.finish()
