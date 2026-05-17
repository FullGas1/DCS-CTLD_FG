-- recette/diag_ship_scan.lua
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = players[1]
if not pu then return "NO PLAYER" end
local pp = pu:getPoint()

-- Check if Speedboat appears in RED SHIP groups
local shipGroups = coalition.getGroups(coalition.side.RED, Group.Category.SHIP) or {}
ctld.logInfo(string.format("diag_ship: RED SHIP groups count=%d", #shipGroups))
local found = false
for _, g in ipairs(shipGroups) do
    ctld.logInfo("  group: " .. g:getName())
    for _, u in ipairs(g:getUnits()) do
        ctld.logInfo("    unit: " .. u:getName())
        if u:getName() == "RECON_TEST_ship_1" then found = true end
    end
end
ctld.logInfo("diag_ship: RECON_TEST_ship_1 found in RED SHIP groups: " .. tostring(found))

-- Manual LOS
local su = Unit.getByName("RECON_TEST_ship_1")
if su then
    local sp = su:getPoint()
    local dist = math.sqrt((pp.x-sp.x)^2+(pp.z-sp.z)^2)
    local vis180 = land.isVisible({x=pp.x,y=pp.y+180,z=pp.z},{x=sp.x,y=sp.y+180,z=sp.z})
    local vis500 = land.isVisible({x=pp.x,y=pp.y+500,z=pp.z},{x=sp.x,y=sp.y+2,z=sp.z})
    ctld.logInfo(string.format("diag_ship: dist=%.0fm ship_y=%.1f vis+180=%s vis+500/+2=%s",
        dist, sp.y, tostring(vis180), tostring(vis500)))
    trigger.action.outText(string.format("[SHIP] dist=%.0fm found=%s vis+180=%s", dist, tostring(found), tostring(vis180)), 20)
end
return "SHIP DIAG DONE"
