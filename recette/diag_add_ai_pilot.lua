-- diag_add_ai_pilot.lua — diagnostic complet transportPilotNames
local cfg = CTLDConfig.get()
local names = cfg:getSetting("transportPilotNames") or {}
local found = false
local idx = nil
for i, n in ipairs(names) do
    if n == "heliai_troops" then found = true; idx = i; break end
end
local last3 = {}
for i = math.max(1, #names-2), #names do last3[#last3+1] = names[i] end
return string.format("total=%d | found=%s idx=%s | last3=[%s]",
    #names, tostring(found), tostring(idx), table.concat(last3, ", "))
