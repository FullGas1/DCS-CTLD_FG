-- Force Step 2 execution
_G['_TFC_STEP'] = 2
ctld.debug = true
local TAG = "[tfc_force]"
ctld.utils.log("INFO", TAG .. " force step=2, about to run scenario")
dofile("C:\\Users\\Moi\\Documents\\GitHub\\DCS-CTLD_FG\\recette\\scenarios\\scenarioTroopsFullCycle_v2.lua")
ctld.utils.log("INFO", TAG .. " scenario returned")
return "force step 2 done"