-- Read last MT-05 log entries from ctld log buffer
local results = {}
-- Re-run and capture via return
local cm = CTLDCrateManager.getInstance()
local vs = CTLDVehicleSpawner.getInstance()
local TRANSPORT_NAME = "mock_transport_MT05"
local VEHICLE_TYPE   = "M1045 HMMWV TOW"
local vehicleWeights = ctld.gs("vehiclesWeight") or {}
local expectedVW = vehicleWeights[VEHICLE_TYPE] or 2500
return string.format("vehiclesWeight[%s]=%s (expected=%d)", VEHICLE_TYPE, tostring(vehicleWeights[VEHICLE_TYPE]), expectedVW)
