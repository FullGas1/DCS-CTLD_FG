---@diagnostic disable
-- CTLD_mineFieldScene.lua
-- Minefield scene model — migrated from source_scene_ini/mineFieldSceneDatas.lua.
--
-- Changes vs. original:
--   - mist.dynAddStatic()        → CTLDObjectRegistry.spawnObject("Landmine", ...)
--   - coalitionId undefined bug  → triggerUnitObj:getCoalition()
--   - _spawnedGroup global leak  → local variable
--   - func step signature updated to (triggerUnitObj, spawnedObj, step)
--   - Registration: CTLDSceneManager.getInstance():registerSceneModel(...)
--   - Layout: quinconce (staggered) pattern — odd rows N mines, even rows N-1 mines offset cs/2
--
-- Dependencies: CTLDUtils, CTLDObjectRegistry, CTLDSceneManager
-- DCS API: trigger.action.outText
-- ====================================================================================================

local mineFieldScene = {}
mineFieldScene.name = "mineField"

mineFieldScene.stepsDatas = {
    -- Step 1: deploy minefield (func-only — positions computed inside)
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            local success, result = mineFieldScene.setLandMine(ctx.unit, 20, 5, 15, 6, 12)
            if trigger and trigger.action and trigger.action.outText then
                trigger.action.outText(
                    ctld.tr("--- mineField Deployed by %1 ---", ctx.unit:getName()), 10)
            end
            return success, result
        end,
    },
}

-- ====================================================================================================
-- mineFieldScene.setLandMine
-- Computes a quinconce (staggered) grid of landmine positions relative to triggerUnitObj
-- and spawns them.
--
-- Layout (nbMinesColumns >= 2):
--   odd rows  : N mines,   centered
--   even rows : N-1 mines, shifted laterally by colSpacing/2
--
-- Special cases:
--   nbMines == 1                  → single mine, diamond F10 marker
--   nbMinesColumns < 2            → straight forward column, no stagger
--
-- @param triggerUnitObj                   DCS Unit object
-- @param distanceOf1stMineFromHeliInMeter number  distance from unit to first row (metres)
-- @param nbMinesColumns                   number  mines per odd (full) row
-- @param nbMinesPerColumns                number  total number of rows
-- @param distanceBetweenColumnsInMeters   number  lateral spacing between adjacent mines (metres)
-- @param distanceBetweenLinesInMeters     number  forward spacing between rows (metres)
-- @return boolean, table|string  success flag + spawned object array or error message
-- ====================================================================================================
function mineFieldScene.setLandMine(triggerUnitObj, distanceOf1stMineFromHeliInMeter, nbMinesColumns, nbMinesPerColumns,
                                    distanceBetweenColumnsInMeters, distanceBetweenLinesInMeters)
    if not triggerUnitObj then
        return false, "ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0"
    end

    local triggerUnitPosition     = triggerUnitObj:getPosition()
    local triggerUnitHeadingInRad = ctld.utils.getHeadingInRadians(
                                        "mineFieldScene.setLandMine", triggerUnitObj, true)
    local coalitionId             = triggerUnitObj:getCoalition()
    local countryId               = triggerUnitObj:getCountry()

    local nbMines     = nbMinesColumns * nbMinesPerColumns
    local spawnedObjs = {}

    if nbMines <= 0 then
        return false, "ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0"
    end

    distanceBetweenLinesInMeters = distanceBetweenLinesInMeters or 12

    local vec3Points1To4 = {}
    local unitVec2       = { x = triggerUnitPosition.p.x, y = triggerUnitPosition.p.z }

    -- Spawn a single mine at a Vec2 position {x, y}
    local function spawnAt(pos)
        local obj = CTLDObjectRegistry.spawnObject(
            "Landmine", coalitionId, countryId,
            pos.x, pos.y, 0, nil)
        if obj then
            spawnedObjs[#spawnedObjs + 1] = obj
        end
    end

    if nbMines == 1 then
        -- ----------------------------------------------------------------
        -- Single mine — diamond F10 marker
        -- ----------------------------------------------------------------
        local pt = ctld.utils.GetRelativeVec2Coords(
            unitVec2, triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)
        spawnAt(pt)
        -- Square aligned with aircraft heading (3m half-side)
        local half = 3
        local fwd  = ctld.utils.GetRelativeVec2Coords(pt, triggerUnitHeadingInRad,  half,  0)
        local bwd  = ctld.utils.GetRelativeVec2Coords(pt, triggerUnitHeadingInRad, -half,  0)
        local tl   = ctld.utils.GetRelativeVec2Coords(fwd, triggerUnitHeadingInRad, -half, 90)
        local tr   = ctld.utils.GetRelativeVec2Coords(fwd, triggerUnitHeadingInRad,  half, 90)
        local br   = ctld.utils.GetRelativeVec2Coords(bwd, triggerUnitHeadingInRad,  half, 90)
        local bl   = ctld.utils.GetRelativeVec2Coords(bwd, triggerUnitHeadingInRad, -half, 90)
        vec3Points1To4[1] = { x = tl.x, y = 0, z = tl.y }
        vec3Points1To4[2] = { x = tr.x, y = 0, z = tr.y }
        vec3Points1To4[3] = { x = br.x, y = 0, z = br.y }
        vec3Points1To4[4] = { x = bl.x, y = 0, z = bl.y }

    elseif nbMinesColumns < 2 then
        -- ----------------------------------------------------------------
        -- Single column: straight forward line, no stagger
        -- ----------------------------------------------------------------
        local refPoint = ctld.utils.GetRelativeVec2Coords(
            unitVec2, triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)
        for r = 1, nbMinesPerColumns do
            local pos = ctld.utils.GetRelativeVec2Coords(
                refPoint, triggerUnitHeadingInRad,
                (r - 1) * distanceBetweenLinesInMeters, 0)
            spawnAt(pos)
        end
        local lastPos = ctld.utils.GetRelativeVec2Coords(
            refPoint, triggerUnitHeadingInRad,
            (nbMinesPerColumns - 1) * distanceBetweenLinesInMeters, 0)
        vec3Points1To4[1] = { x = refPoint.x - 3, y = 0, z = refPoint.y }
        vec3Points1To4[2] = { x = refPoint.x + 3, y = 0, z = refPoint.y }
        vec3Points1To4[3] = { x = lastPos.x  + 3, y = 0, z = lastPos.y  }
        vec3Points1To4[4] = { x = lastPos.x  - 3, y = 0, z = lastPos.y  }

    else
        -- ----------------------------------------------------------------
        -- Quinconce (staggered) layout — nbMinesColumns >= 2
        --   odd rows  (r=1,3,...) : N mines,   leftmost at -halfWidth
        --   even rows (r=2,4,...) : N-1 mines, leftmost at -halfWidth + cs/2
        -- ----------------------------------------------------------------
        local refPoint  = ctld.utils.GetRelativeVec2Coords(
            unitVec2, triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)
        local halfWidth = ((nbMinesColumns - 1) / 2) * distanceBetweenColumnsInMeters

        for r = 1, nbMinesPerColumns do
            local rowCenter = ctld.utils.GetRelativeVec2Coords(
                refPoint, triggerUnitHeadingInRad,
                (r - 1) * distanceBetweenLinesInMeters, 0)

            local minesInRow, leftmostLateral
            if r % 2 == 1 then
                -- Odd row: full width
                minesInRow      = nbMinesColumns
                leftmostLateral = -halfWidth
            else
                -- Even row: one mine less, shifted right by cs/2
                minesInRow      = nbMinesColumns - 1
                leftmostLateral = -halfWidth + distanceBetweenColumnsInMeters / 2
            end

            for col = 1, minesInRow do
                local lateralOffset = leftmostLateral + (col - 1) * distanceBetweenColumnsInMeters
                local pos = ctld.utils.GetRelativeVec2Coords(
                    rowCenter, triggerUnitHeadingInRad, lateralOffset, 90)
                spawnAt(pos)
            end
        end

        -- Bounding rectangle corners (based on full-row lateral extent)
        local lastRowCenter = ctld.utils.GetRelativeVec2Coords(
            refPoint, triggerUnitHeadingInRad,
            (nbMinesPerColumns - 1) * distanceBetweenLinesInMeters, 0)
        local tl = ctld.utils.GetRelativeVec2Coords(refPoint,      triggerUnitHeadingInRad, -halfWidth, 90)
        local tr = ctld.utils.GetRelativeVec2Coords(refPoint,      triggerUnitHeadingInRad,  halfWidth, 90)
        local br = ctld.utils.GetRelativeVec2Coords(lastRowCenter, triggerUnitHeadingInRad,  halfWidth, 90)
        local bl = ctld.utils.GetRelativeVec2Coords(lastRowCenter, triggerUnitHeadingInRad, -halfWidth, 90)
        vec3Points1To4[1] = { x = tl.x, y = 0, z = tl.y }
        vec3Points1To4[2] = { x = tr.x, y = 0, z = tr.y }
        vec3Points1To4[3] = { x = br.x, y = 0, z = br.y }
        vec3Points1To4[4] = { x = bl.x, y = 0, z = bl.y }
    end

    -- Draw bounding quadrilateral on the F10 map
    local lastSpawned = spawnedObjs[#spawnedObjs]
    if lastSpawned then
        ctld.utils.drawQuad(coalitionId, vec3Points1To4, lastSpawned:getName())
    end

    return true, spawnedObjs
end

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(mineFieldScene)
