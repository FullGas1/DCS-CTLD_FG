-- MT-03 setup: allow UH-1H to load 2 vehicles
local limits = CTLDConfig.get().settings["internalCargoLimits"]
limits["UH-1H"] = 2
return "internalCargoLimits UH-1H = " .. tostring(limits["UH-1H"])
