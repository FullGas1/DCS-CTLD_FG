---@diagnostic disable
-- Test direct: lance la scène fobScene sans passer par unpackFOBCrates
local sm = CTLDSceneManager.getInstance()

-- Vérifier que le modèle est enregistré
local model = sm:getModel("fobScene")
if not model then
    return "FAIL: fobScene model NOT registered in SceneManager"
end

local transport = coalition.getPlayers(coalition.side.BLUE)
transport = transport and transport[1]
if not transport or not transport:isExist() then
    return "FAIL: no BLUE player"
end

local pt  = transport:getPoint()
local hdg = ctld.utils.getHeadingInRadians("diag", transport, true)
local fx  = pt.x + math.cos(hdg) * 100
local fz  = pt.z + math.sin(hdg) * 100
local centroid = { x = fx, y = land.getHeight({x = fx, y = fz}), z = fz }

local scene = sm:playScene(transport, "fobScene",
    { player = transport:getName(), centroid = centroid },
    nil)

if scene then
    return "OK: scene started — " .. tostring(scene._name)
else
    return "FAIL: playScene returned nil"
end
