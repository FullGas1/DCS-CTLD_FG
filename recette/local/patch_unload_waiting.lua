---@diagnostic disable
-- Hot-patch: unloadVehicle sets WAITING instead of DELIVERED (re-loadable)
local _orig = CTLDVehicleSpawner.unloadVehicle
CTLDVehicleSpawner.unloadVehicle = function(self, vehicle, transport, player, method)
    _orig(self, vehicle, transport, player, method)
    if vehicle:getState() == CTLDVehicle.STATE.DELIVERED then
        vehicle:setState(CTLDVehicle.STATE.WAITING)
    end
end
trigger.action.outText("[PATCH] unloadVehicle -> WAITING applied", 10)
ctld.utils.log("INFO", "[patch] unloadVehicle -> WAITING applied")
