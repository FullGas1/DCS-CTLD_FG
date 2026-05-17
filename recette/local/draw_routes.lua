-- recette/draw_routes.lua
-- Draw the looping triangle routes for Su-25 (plane) and Mi-8MT (helo),
-- and the ship's static position — all in cyan so they don't clash with RECON marks.
-- Uses markIds 90001-90030 range. Re-inject to refresh positions.

local BATUMI = { x = -356437, z = 618211 }
local NM1    = 1852

-- Triangle WP coordinates (same as loopingTriangleRoute in scenario)
local wps = {
    { x = BATUMI.x,        z = BATUMI.z + NM1 },  -- WP1: north
    { x = BATUMI.x - NM1,  z = BATUMI.z - NM1 },  -- WP2: south-west
    { x = BATUMI.x + NM1,  z = BATUMI.z - NM1 },  -- WP3: south-east
}

local CYAN    = { 0.0, 1.0, 1.0, 1.0 }
local YELLOW  = { 1.0, 0.9, 0.0, 1.0 }
local MAGENTA = { 1.0, 0.0, 1.0, 1.0 }
local EMPTY   = { 0.0, 0.0, 0.0, 0.0 }

-- Remove previous route marks
for i = 90001, 90030 do
    pcall(trigger.action.removeMark, i)
end

-- Helper: draw a labelled waypoint circle
local function drawWP(markId, pos, label, col)
    trigger.action.circleToAll(-1, markId,
        { x = pos.x, y = 0, z = pos.z }, 150,
        col, EMPTY, 2, true, label)
end

-- Helper: draw a line between two WPs
local function drawLeg(markId, a, b, col)
    trigger.action.lineToAll(-1, markId,
        { x = a.x, y = 0, z = a.z },
        { x = b.x, y = 0, z = b.z },
        col, 2, true, "")
end

local id = 90001

-- ── Plane (Su-25) route — CYAN ────────────────────────────────────────────────
trigger.action.markToAll(id, "Su-25 orbit route", { x = BATUMI.x, y = 0, z = BATUMI.z + NM1 + 300 }, true, CYAN)
id = id + 1
for i, wp in ipairs(wps) do
    drawWP(id, wp, "SU-25 WP"..i, CYAN)
    id = id + 1
end
drawLeg(id, wps[1], wps[2], CYAN); id = id + 1
drawLeg(id, wps[2], wps[3], CYAN); id = id + 1
drawLeg(id, wps[3], wps[1], CYAN); id = id + 1

-- ── Helo (Mi-8MT) route — YELLOW (same triangle) ─────────────────────────────
trigger.action.markToAll(id, "Mi-8MT orbit route", { x = BATUMI.x - 300, y = 0, z = BATUMI.z + NM1 + 300 }, true, YELLOW)
id = id + 1
for i, wp in ipairs(wps) do
    drawWP(id, wp, "Mi-8 WP"..i, YELLOW)
    id = id + 1
end
drawLeg(id, wps[1], wps[2], YELLOW); id = id + 1
drawLeg(id, wps[2], wps[3], YELLOW); id = id + 1
drawLeg(id, wps[3], wps[1], YELLOW); id = id + 1

-- ── Ship (Speedboat) position — MAGENTA ───────────────────────────────────────
local shipPos = { x = BATUMI.x + 556, z = BATUMI.z - 3500 }  -- 3.5km west + 0.3nm north
trigger.action.circleToAll(-1, id,
    { x = shipPos.x, y = 0, z = shipPos.z }, 200,
    MAGENTA, EMPTY, 2, true, "Speedboat position")
id = id + 1
trigger.action.markToAll(id, "Ship spawn (1nm W Batumi)", { x = shipPos.x, y = 0, z = shipPos.z + 300 }, true, MAGENTA)

trigger.action.outText("[ROUTES] Drawn: cyan=Su-25, yellow=Mi-8MT, magenta=Speedboat. Triangle is 1nm from Batumi.", 30)
env.info("[draw_routes] routes drawn, markIds 90001-" .. id)
return "ROUTES DRAWN — " .. id .. " marks"
