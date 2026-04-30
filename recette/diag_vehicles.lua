-- Dump all registered CTLDVehicles
local spawner = CTLDVehicleSpawner.getInstance()
local lines   = {}
local count   = 0
for id, veh in pairs(spawner._vehicles) do
    count = count + 1
    local uname  = veh.unit and veh.unit:getName() or "(nil)"
    local spawnU = veh.spawnData and veh.spawnData.unitName  or "?"
    local spawnG = veh.spawnData and veh.spawnData.groupName or "?"
    table.insert(lines, string.format(
        "[VEH] id=%s type=%s state=%s unit=%s spawnData.unit=%s spawnData.grp=%s",
        id, veh.vehicleType, veh.state, uname, spawnU, spawnG))
end
if count == 0 then
    ctld.utils.log("INFO", "[VEH DIAG] No vehicles registered")
    trigger.action.outText("[VEH DIAG] No vehicles registered", 10)
else
    for _, l in ipairs(lines) do ctld.utils.log("INFO", l) end
    trigger.action.outText(string.format("[VEH DIAG] %d vehicle(s) - see CTLD.log", count), 10)
end
