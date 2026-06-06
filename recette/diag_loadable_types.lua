-- Liste les types loadables configurés pour UH-1H (BLUE)
local typeName = "UH-1H"
local coa = coalition.side.BLUE

-- loadableVehiclesByType ou loadableVehiclesBLUE selon config
local byType = ctld.gs("loadableVehiclesByType") or {}
local byTypeEntry = byType[typeName] or {}

local blue = ctld.gs("loadableVehiclesBLUE") or {}

return string.format("loadableVehiclesByType[UH-1H]=%d entries | loadableVehiclesBLUE=%d entries: [%s]",
    #byTypeEntry, #blue, table.concat(blue, ", "))
