local results = {}
local units = { "heliai_troops", "heliai_vehicle", "heliai_full", "heliai_mt10a", "heliai_mt10b" }
for _, name in ipairs(units) do
    local grp = Group.getByName(name)
    local u = Unit.getByName(name)
    local active = grp ~= nil
    local inAir = u and u:isExist() and u:inAir() or false
    local inPilots = false
    local cfg = CTLDConfig.get()
    for _, n in ipairs(cfg.settings["transportPilotNames"] or {}) do
        if n == name then inPilots = true; break end
    end
    local cm = CTLDCoreManager.getInstance()
    local inAINames = cm._aiPilotNames[name] ~= nil
    table.insert(results, name .. ": grp=" .. tostring(active) .. " inAir=" .. tostring(inAir)
        .. " inPilotNames=" .. tostring(inPilots) .. " inAINames=" .. tostring(inAINames))
end
return table.concat(results, " | ")
