-- recette/chk_ship.lua
local g = Group.getByName("RECON_TEST_ship")
if not g or not g:isExist() then
    trigger.action.outText("[CHK] RECON_TEST_ship: NOT FOUND", 15)
    return "MISSING"
end
local units = g:getUnits()
local u = units[1]
local p = u:getPoint()
local msg = string.format("[CHK] %s exists, life=%.0f pos=x%.0f z%.0f cat=%s isActive=%s",
    u:getName(), u:getLife(), p.x, p.z, tostring(Object.getCategory(u)), tostring(u:isActive()))
trigger.action.outText(msg, 20)

-- manual LOS from player
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = players[1]
if pu and pu:isExist() then
    local pp = pu:getPoint()
    local dist = math.sqrt((pp.x-p.x)^2+(pp.z-p.z)^2)
    local vis = land.isVisible({x=pp.x,y=pp.y+180,z=pp.z},{x=p.x,y=p.y+180,z=p.z})
    local msg2 = string.format("[CHK] dist=%.0fm LOS+180=%s", dist, tostring(vis))
    trigger.action.outText(msg2, 20)
    ctld.logInfo(msg .. " | " .. msg2)
end
return msg
