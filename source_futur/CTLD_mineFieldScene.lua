---@diagnostic disable
-- CTLD_mineFieldScene.lua
-- Minefield scene model — migrated from source_scene_ini/mineFieldSceneDatas.lua.
--
-- Changes vs. original:
--   - mist.dynAddStatic()        → CTLDObjectsDescDb.spawnObject("Landmine", ...)
--   - coalitionId undefined bug  → triggerUnitObj:getCoalition()
--   - _spawnedGroup global leak  → local variable
--   - Dead variable lineOffsetInMeters removed (was set but never read)
--   - func step signature updated to (triggerUnitObj, spawnedObj, step)
--   - Registration: CTLDSceneManager.getInstance():registerSceneModel(...)
--
-- Dependencies: CTLDUtils, CTLDObjectsDescDb, CTLDSceneManager
-- DCS API: trigger.action.outText
-- ====================================================================================================

local mineFieldScene = {}
mineFieldScene.name = "mineField"

mineFieldScene.stepsDatas = {
    -- Step 1: deploy minefield (func-only — positions computed inside)
    {
        delayAfterPreviousStep = 0,
        func = function(triggerUnitObj, spawnedObj, step)
            local success, result = mineFieldScene.setLandMine(triggerUnitObj, 20, 5, 15, 6, 12)
            if trigger and trigger.action and trigger.action.outText then
                trigger.action.outText(
                    ctld.tr("--- mineField Deployed by %1 ---", triggerUnitObj:getName()), 10)
            end
            return success, result
        end,
    },
}

-- ====================================================================================================
-- mineFieldScene.setLandMine
-- Computes a grid of landmine positions relative to triggerUnitObj and spawns them.
--
-- @param triggerUnitObj                   DCS Unit object
-- @param distanceOf1stMineFromHeliInMeter number  distance from unit to first mine (metres)
-- @param nbMinesColumns                   number  number of mine columns
-- @param nbMinesPerColumns                number  mines per column
-- @param distanceBetweenColumnsInMeters   number  lateral spacing between columns
-- @param distanceBetweenLinesInMeters     number  forward spacing between mines in a column
-- @return boolean, table|string  success flag + spawned object array or error message
-- ====================================================================================================
function mineFieldScene.setLandMine(triggerUnitObj, distanceOf1stMineFromHeliInMeter, nbMinesColumns, nbMinesPerColumns,
                                    distanceBetweenColumnsInMeters, distanceBetweenLinesInMeters)
    if not triggerUnitObj then
        return false, "ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0"
    end

    local triggerUnitPosition      = triggerUnitObj:getPosition()
    local triggerUnitHeadingInRad  = ctld.utils.getHeadingInRadians(
                                         "mineFieldScene.setLandMine", triggerUnitObj, true)
    local coalitionId              = triggerUnitObj:getCoalition()
    local countryId                = triggerUnitObj:getCountry()

    local nbMines    = nbMinesColumns * nbMinesPerColumns
    local MinesCoord = {}
    local spawnedObjs = {}

    if nbMines <= 0 then
        return false, "ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0"
    end

    distanceBetweenLinesInMeters = distanceBetweenLinesInMeters or 12

    local vec3Points1To4 = {}  -- corner points for the F10 map quadrilateral marker

    if nbMines == 1 then
        -- ----------------------------------------------------------------
        -- Single mine
        -- ----------------------------------------------------------------
        local pt = ctld.utils.GetRelativeVec2Coords(
            { x = triggerUnitPosition.p.x, y = triggerUnitPosition.p.z },
            triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)
        MinesCoord[1] = { [1] = { x = pt.x, y = pt.y } }

        local ofs = 3
        vec3Points1To4[1] = { x = MinesCoord[1][1].x - ofs, y = 0, z = MinesCoord[1][1].y }
        vec3Points1To4[2] = { x = MinesCoord[1][1].x,       y = 0, z = MinesCoord[1][1].y + ofs }
        vec3Points1To4[3] = { x = MinesCoord[1][1].x + ofs, y = 0, z = MinesCoord[1][1].y }
        vec3Points1To4[4] = { x = MinesCoord[1][1].x,       y = 0, z = MinesCoord[1][1].y - ofs }

    else
        -- ----------------------------------------------------------------
        -- Multi-column minefield grid
        -- ----------------------------------------------------------------
        local Vec2CentralPoint = ctld.utils.GetRelativeVec2Coords(
            { x = triggerUnitPosition.p.x, y = triggerUnitPosition.p.z },
            triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)

        if nbMinesColumns % 2 == 0 then
            -- Even number of columns
            for i = 1, nbMinesColumns do
                MinesCoord[i] = {}
                if i == 1 then
                    MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(
                        Vec2CentralPoint, triggerUnitHeadingInRad,
                        (((nbMinesColumns - 1) / 2) * distanceBetweenColumnsInMeters)
                        + (distanceBetweenColumnsInMeters / 2), 90)
                else
                    MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(
                        MinesCoord[i - 1][1], triggerUnitHeadingInRad,
                        distanceBetweenColumnsInMeters, -90)
                end
                for line = 2, nbMinesPerColumns do
                    MinesCoord[i][line] = ctld.utils.GetRelativeVec2Coords(
                        MinesCoord[i][line - 1], triggerUnitHeadingInRad,
                        distanceBetweenLinesInMeters, 0)
                end
            end
        else
            -- Odd number of columns
            for i = 1, nbMinesColumns do
                MinesCoord[i] = {}
                if i == 1 then
                    MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(
                        Vec2CentralPoint, triggerUnitHeadingInRad,
                        ((nbMinesColumns - 1) / 2) * distanceBetweenColumnsInMeters, 90)
                else
                    MinesCoord[i][1] = ctld.utils.GetRelativeVec2Coords(
                        MinesCoord[i - 1][1], triggerUnitHeadingInRad,
                        distanceBetweenColumnsInMeters, -90)
                end
                for line = 2, nbMinesPerColumns do
                    MinesCoord[i][line] = ctld.utils.GetRelativeVec2Coords(
                        MinesCoord[i][line - 1], triggerUnitHeadingInRad,
                        distanceBetweenLinesInMeters, 0)
                end
            end
        end

        -- Compute quadrilateral corner points for the F10 map marker.
        if nbMinesColumns < 2 then
            vec3Points1To4[1] = { x = MinesCoord[1][1].x - 3,                          y = 0, z = MinesCoord[1][1].y - 3 }
            vec3Points1To4[2] = { x = MinesCoord[1][1].x + 3,                          y = 0, z = MinesCoord[1][1].y + 3 }
            vec3Points1To4[3] = { x = MinesCoord[#MinesCoord][#MinesCoord[1]].x + 3,   y = 0, z = MinesCoord[#MinesCoord][#MinesCoord[1]].y + 3 }
            vec3Points1To4[4] = { x = MinesCoord[#MinesCoord][#MinesCoord[1]].x - 3,   y = 0, z = MinesCoord[#MinesCoord][#MinesCoord[1]].y - 3 }
        elseif nbMinesPerColumns < 2 then
            vec3Points1To4[1] = { x = MinesCoord[1][1].x,                              y = 0, z = MinesCoord[1][1].y - 3 }
            vec3Points1To4[2] = { x = MinesCoord[1][1].x,                              y = 0, z = MinesCoord[1][1].y + 3 }
            vec3Points1To4[3] = { x = MinesCoord[#MinesCoord][#MinesCoord[1]].x,       y = 0, z = MinesCoord[#MinesCoord][#MinesCoord[1]].y + 3 }
            vec3Points1To4[4] = { x = MinesCoord[#MinesCoord][#MinesCoord[1]].x,       y = 0, z = MinesCoord[#MinesCoord][#MinesCoord[1]].y - 3 }
        else
            vec3Points1To4[1] = { x = MinesCoord[1][1].x,                              y = 0, z = MinesCoord[1][1].y }
            vec3Points1To4[2] = { x = MinesCoord[#MinesCoord][1].x,                    y = 0, z = MinesCoord[#MinesCoord][1].y }
            vec3Points1To4[3] = { x = MinesCoord[#MinesCoord][#MinesCoord[1]].x,       y = 0, z = MinesCoord[#MinesCoord][#MinesCoord[1]].y }
            vec3Points1To4[4] = { x = MinesCoord[1][#MinesCoord[1]].x,                 y = 0, z = MinesCoord[1][#MinesCoord[1]].y }
        end
    end

    -- ----------------------------------------------------------------
    -- Spawn mines via CTLDObjectsDescDb
    -- MinesCoord[col][row]: .x = world North, .y = world East (vec2)
    -- ----------------------------------------------------------------
    local lastSpawned = nil
    for j = 1, #MinesCoord do
        for i = 1, #MinesCoord[j] do
            local spawnedGroup = CTLDObjectsDescDb.spawnObject(
                "Landmine", coalitionId, countryId,
                MinesCoord[j][i].x, MinesCoord[j][i].y,
                0, nil
            )
            if spawnedGroup then
                spawnedObjs[#spawnedObjs + 1] = spawnedGroup
                lastSpawned = spawnedGroup
            end
        end
    end

    -- Draw quadrilateral outline around the minefield on the F10 map.
    if lastSpawned then
        ctld.utils.drawQuad(coalitionId, vec3Points1To4, lastSpawned:getName())
    end

    return true, spawnedObjs
end

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(mineFieldScene)
