---@diagnostic disable
-- ============================================================
-- F-19 : unloadVehicle method=dcs_native (C-130 au sol)
-- Module  : M5 (src/CTLD_vehicle.lua)
-- Objectif: Vérifier que unloadVehicle(method="dcs_native") :
--   1. Ne crash pas
--   2. Passe le vehicle en état DELIVERED
--   3. Publie OnVehicleUnloaded avec method="dcs_native"
-- Ce test simule la sortie de bbox lorsque le transport est au sol
-- en appelant unloadVehicle directement avec method="dcs_native".
-- Précondition : un transport BLUE doit être présent dans la mission.
-- ============================================================

-- Purge CTLD.log
do local f = io.open("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log","w") if f then f:close() end end

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/setup.lua")

dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_core.lua")
dofile("C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/src/CTLD_vehicle.lua")

ctld_test.start("F-19", "unloadVehicle method=dcs_native (au sol) → OnVehicleUnloaded")

CTLDVehicleSpawner._instance = nil
EventDispatcher._instance    = nil
CTLDDCSEventBridge._instance = nil

CTLDVehicleSpawner.getInstance()
local vs = CTLDVehicleSpawner._instance

-- Récupérer un transport BLUE
local transport = nil
local blueUnits = coalition.getPlayers(coalition.side.BLUE) or {}
if #blueUnits > 0 then transport = blueUnits[1] end

if not transport then
    ctld_test.assert(false, "ECHEC SETUP : aucun transport BLUE dans la mission")
    ctld_test.finish()
    return
end

local vehicleType = "M1045 HMMWV TOW"

-- Setup : spawn + load dcs_native
local vehicle = vs:spawnVehicleForTransport(vehicleType, transport, nil)
ctld_test.assertNotNil(vehicle, "spawnVehicleForTransport OK")
if not vehicle then ctld_test.finish() return end

vs:loadVehicle(vehicle, transport, nil, "dcs_native")
ctld_test.assertEqual(vehicle:getState(), CTLDVehicle.STATE.LOADED,
    "vehicle en LOADED avant unload")

-- Capturer OnVehicleUnloaded
local unloadedPayload = nil
EventDispatcher.getInstance():subscribe("OnVehicleUnloaded", function(p)
    unloadedPayload = p
end)

-- Simuler sortie bbox au sol : appel direct unloadVehicle avec method="dcs_native"
local okUnload = pcall(function()
    vs:unloadVehicle(vehicle, transport, nil, "dcs_native")
end)

ctld_test.assert(okUnload, "unloadVehicle dcs_native ne crash pas")
ctld_test.assertEqual(vehicle:getState(), CTLDVehicle.STATE.DELIVERED,
    "vehicle en DELIVERED après dcs_native unload")

-- Event OnVehicleUnloaded
ctld_test.assertNotNil(unloadedPayload, "OnVehicleUnloaded publié")

if unloadedPayload then
    ctld_test.assertEqual(unloadedPayload.vehicleId, vehicle.id,
        "payload.vehicleId correct")
    ctld_test.assertEqual(unloadedPayload.vehicleType, vehicleType,
        "payload.vehicleType correct")
    ctld_test.assertEqual(unloadedPayload.method, "dcs_native",
        "payload.method == 'dcs_native'")
    ctld_test.assertNotNil(unloadedPayload.transport, "payload.transport non-nil")
    ctld_test.assertNotNil(unloadedPayload.position,  "payload.position non-nil")
    ctld_test.assertNotNil(unloadedPayload.timestamp, "payload.timestamp non-nil")
end

ctld_test.finish()
