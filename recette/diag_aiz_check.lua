-- Diagnostic: vérifier _troopZones chargées (AIZ config)
local zm = CTLDZoneManager.getInstance()
local result = {}
local keys = { "AIZ_base_B_P_5", "AIZ_front_B_D", "AIZ_depot_B_P_V_10",
               "AIZ_depot_B_P_TV_5_10", "AIZ_livraison_B_D_G",
               "AIZ_mt10d_B_D_G", "AIZ_depot_B_P_T_10" }
for _, k in ipairs(keys) do
    local z = zm._troopZones[k]
    if z then
        table.insert(result, k .. "=OK P=" .. tostring(z.isAIPickup) ..
            " D=" .. tostring(z.isAIDropoff) .. " cargo=" .. tostring(z.aiCargoType))
    else
        table.insert(result, k .. "=MISSING")
    end
end
-- Also check aiZones config entry count
local cfg = CTLDConfig.get()
local entries = cfg.settings["aiZones"]
table.insert(result, "aiZones_count=" .. tostring(entries and #entries or 0))
return table.concat(result, " | ")
