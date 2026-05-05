-- recette/patch_recon_colors.lua
-- Hot-patch CTLDReconRenderer.createIcon so mark color follows detected unit coalition.
-- Inject once per session after enable_debug.lua.

local COALITION_COLORS = {
    [0] = { 0.70, 0.70, 0.70, 1.0 },  -- neutral  → grey
    [1] = { 1.00, 0.15, 0.15, 1.0 },  -- RED      → red
    [2] = { 0.15, 0.40, 1.00, 1.0 },  -- BLUE     → blue
}

function CTLDReconRenderer.createIcon(target, markId)
    local r   = target.layer.iconRenderer
    local pos = target.position
    local col = COALITION_COLORS[target.coalition] or target.layer.color
    if     r == "infantry"   then CTLDReconRenderer.drawInfantryIcon(pos, markId, col)
    elseif r == "vehicle"    then CTLDReconRenderer.drawVehicleIcon(pos, markId, col)
    elseif r == "aa"         then CTLDReconRenderer.drawAAIcon(pos, markId, col)
    elseif r == "aircraft"   then CTLDReconRenderer.drawAircraftIcon(pos, markId, col)
    elseif r == "helicopter" then CTLDReconRenderer.drawHelicopterIcon(pos, markId, col)
    elseif r == "ship"       then CTLDReconRenderer.drawShipIcon(pos, markId, col)
    else
        trigger.action.circleToAll(-1, markId * 10 + 1,
            { x = pos.x, y = 0, z = pos.z }, 40, col,
            { col[1], col[2], col[3], 0.2 }, 1, true, r or "?")
    end
end

ctld.logInfo("createIcon hot-patched: mark color now follows unit coalition (RED/BLUE/NEUTRAL)")
return "PATCH OK — createIcon uses coalition color"
