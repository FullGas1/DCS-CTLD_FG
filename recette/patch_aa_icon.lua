-- Hot-patch: AA icon — filled circle (alpha=0.3) + 2 lines forming apex (no base line).
CTLDReconRenderer.drawAAIcon = function(pos, markId, color)
    local s    = 35 * (ctld.gs("reconIconScale") or 1.0)
    local hs   = s / 2
    local fill = { color[1], color[2], color[3], 0.3 }
    local apex = { x = pos.x,      y = 0, z = pos.z + hs }
    local bl   = { x = pos.x - hs, y = 0, z = pos.z - hs }
    local br   = { x = pos.x + hs, y = 0, z = pos.z - hs }
    trigger.action.circleToAll(-1, markId * 10 + 1,
        { x = pos.x, y = 0, z = pos.z }, hs * 0.9,
        color, fill, 1, true, "AA")
    trigger.action.lineToAll(-1, markId * 10 + 2, bl, apex, color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3, apex, br, color, 1, true, "")
end
return "patch_aa_icon OK — filled circle + apex lines"
