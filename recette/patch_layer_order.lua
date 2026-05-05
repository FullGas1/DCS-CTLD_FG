-- recette/patch_layer_order.lua
-- Hot-patch layer order: air_defense before ground_vehicles, helicopters before aircraft.
-- Also resets player layer cache so new order takes effect immediately.

local NEW_ORDER = {
    { layerId="infantry",      filterAttrib="Infantry",   iconRenderer="infantry",   color={0.29,0.56,0.89,1.0}, name="Infantry",           enabled=false },
    { layerId="air_defense",   filterAttrib="Air Defence",iconRenderer="aa",         color={0.91,0.30,0.24,1.0}, name="Air Defense (AA)",   enabled=false },
    { layerId="ground_vehicles",filterAttrib="Vehicles",  iconRenderer="vehicle",    color={0.31,0.78,0.47,1.0}, name="Ground Vehicles",    enabled=false },
    { layerId="helicopters",   filterAttrib="Helicopters",iconRenderer="helicopter", color={0.90,0.49,0.13,1.0}, name="Helicopters",        enabled=false },
    { layerId="aircraft",      filterAttrib="Planes",     iconRenderer="aircraft",   color={0.95,0.77,0.06,1.0}, name="Aircraft",           enabled=false },
    { layerId="ships",         filterAttrib="Ships",      iconRenderer="ship",       color={0.20,0.60,0.86,1.0}, name="Ships",              enabled=false },
}

CTLDReconManager._defaultLayers = NEW_ORDER

-- Clear player layer cache so _getPlayerLayers() rebuilds with new order
local rmgr = CTLDReconManager.getInstance()
rmgr._playerLayers = {}

ctld.logInfo("layer order patched: air_defense before ground_vehicles, helicopters before aircraft")
return "PATCH OK — layer order fixed, player cache cleared"
