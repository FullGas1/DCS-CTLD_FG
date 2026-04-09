---@diagnostic disable
-- ============================================================
-- F-85 : mineFieldScene.setLandMine — 4×3 (colonnes paires)
-- Module  : M10 (src/scenes/CTLD_mineFieldScene.lua)
-- Objectif: quinconce 4 cols × 3 lignes = 11 mines réelles + quad F10
-- VISUAL  : mines en quinconce 4col×3lig + quad F10
--           row 1 (odd): 4 mines
--           row 2 (even): 3 mines
--           row 3 (odd): 4 mines
--           total = 11 mines
-- ============================================================

do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/lib/CTLD_objectRegistry.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_sceneManager.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/scenes/CTLD_mineFieldScene.lua")

ctld_test.start("F-85", "mineFieldScene setLandMine 4x3 quinconce")

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

-- 4 colonnes (pair) × 3 lignes, espacement 6m latéral × 12m longitudinal
-- quinconce: row1=4, row2=3, row3=4 → 11 mines
local ok, result = scene.setLandMine(transport, 20, 4, 3, 6, 12)

ctld_test.assert(ok,                          "T1: return true")
ctld_test.assertNotNil(result,                "T2: result non-nil")
ctld_test.assertEqual(#result, 11,            "T3: 11 mines spawned — quinconce 4×3 (return value)")

local after = countMines(coa)
ctld_test.assertEqual(after - before, 11,     "T4: 11 mines statiques dans la mission (coalition.getStaticObjects)")

env.info("[F-85] VISUAL: 11 mines quinconce 4col×3lig + quad F10 (branche paire)")

ctld_test.finish()
