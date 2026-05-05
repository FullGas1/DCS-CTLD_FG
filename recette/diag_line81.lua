ctld.utils.log("INFO", "[diag81] starting")
ctld.utils.log("INFO", "[diag81] CTLDTroopManager=" .. tostring(pcall(function() return CTLDTroopManager.getInstance() end)))
ctld.utils.log("INFO", "[diag81] CTLDJTACManager=" .. tostring(pcall(function() return CTLDJTACManager.getInstance() end)))
ctld.utils.log("INFO", "[diag81] CTLDObjectRegistry=" .. tostring(pcall(function() return CTLDObjectRegistry.getInstance() end)))
ctld.utils.log("INFO", "[diag81] diag done")
return "diag81 done"