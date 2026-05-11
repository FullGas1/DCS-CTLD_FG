-- diag_fi_wpz.lua — cleanup + reset step counter for FI-WPZ scenario
_G["_FI_WPZ_STEP"]      = 1
_G["_FI_WPZ_DEST"]      = nil
_G["_FI_WPZ_DIST_ORIG"] = nil

-- Cleanup mock zone
local zm = CTLDZoneManager.getInstance()
if zm and zm._troopZones then
    zm._troopZones["FI_WPZ_MockZone"] = nil
end

-- Destroy test group
for _, name in ipairs({ "FI_WPZ_TestGroup", "FI_ATK_BlueGroup", "FI_ATK_RedEnemy" }) do
    local grp = Group.getByName(name)
    if grp and grp:isExist() then grp:destroy() end
end

-- Remove draw marks
for i = 1, 33 do
    pcall(function() trigger.action.removeMark(99900 + i) end)
end
pcall(function() trigger.action.removeMark(99999) end)

return "FI-WPZ cleanup + reset done"
