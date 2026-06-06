---@diagnostic disable
local zm = CTLDZoneManager.getInstance()
local r  = {}

-- Check exact zone names in _troopZones
for k in pairs(zm._troopZones) do
    if k:find("mt14") then
        r[#r+1] = "troopZone=[" .. k .. "] len=" .. #k
    end
end

-- Check DCS trigger zones
for _, z in pairs(trigger.misc.getZones and trigger.misc.getZones() or {}) do
    if z.name and z.name:find("mt14") then
        r[#r+1] = "dcsZone=[" .. z.name .. "] len=" .. #z.name
    end
end

-- Check userConfig aiZones
local cfg = CTLDConfig.get()
local aiZ = cfg.settings["aiZones"] or {}
for i, z in ipairs(aiZ) do
    if z.dcsZoneName and z.dcsZoneName:find("mt14") then
        r[#r+1] = "userConfig[" .. i .. "]=[" .. z.dcsZoneName .. "] len=" .. #z.dcsZoneName
    end
end

return #r > 0 and table.concat(r, " | ") or "no mt14 zones found"
