-- Diagnose reconIconScale and force-redraw aircraft icon at player position
local scale = ctld.gs("reconIconScale")
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = players[1]
local msg = string.format("reconIconScale = %s", tostring(scale))

if pu then
    local pos = pu:getPoint()
    -- Draw a test aircraft icon at player position with current scale
    local mid = 89990
    CTLDReconRenderer.removeIcon(mid)
    local s  = 40 * (scale or 1.0)
    local hs = s / 2
    local color = { 0.95, 0.77, 0.06, 1.0 }
    trigger.action.lineToAll(-1, mid * 10 + 1,
        { x = pos.x,      y = 0, z = pos.z + hs },
        { x = pos.x,      y = 0, z = pos.z - hs }, color, 2, true, "AC_TEST")
    trigger.action.lineToAll(-1, mid * 10 + 2,
        { x = pos.x - hs, y = 0, z = pos.z },
        { x = pos.x + hs, y = 0, z = pos.z }, color, 2, true, "")
    trigger.action.circleToAll(-1, mid * 10 + 3,
        { x = pos.x, y = 0, z = pos.z }, hs * 0.35, color, color, 2, true, "")
    msg = msg .. string.format(" → icon s=%.0fm drawn at player pos (mark 89990x)", s)
end

return msg
