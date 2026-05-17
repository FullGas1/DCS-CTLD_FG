-- recette/diag_attrib.lua
-- Check hasAttribute("Ships") for both ship units
local units_to_check = { "RECON_TEST_ship_1", "BDK-775" }
for _, name in ipairs(units_to_check) do
    local u = Unit.getByName(name)
    if u and u:isExist() then
        local ok1, has1 = pcall(function() return u:hasAttribute("Ships") end)
        local ok2, has2 = pcall(function() return u:hasAttribute("Naval") end)
        local ok3, has3 = pcall(function() return u:hasAttribute("Watercraft") end)
        local desc = u:getDesc()
        local attribs = desc and desc.attributes or {}
        local keys = {}
        for k,_ in pairs(attribs) do keys[#keys+1] = k end
        table.sort(keys)
        ctld.logInfo(string.format("ATTRIB [%s] Ships=%s Naval=%s Watercraft=%s", name,
            tostring(ok1 and has1), tostring(ok2 and has2), tostring(ok3 and has3)))
        ctld.logInfo("  attribs: " .. table.concat(keys, ", "))
    else
        ctld.logInfo("ATTRIB [" .. name .. "] unit not found")
    end
end
trigger.action.outText("[ATTRIB] Check CTLD.log for attribute details", 10)
return "ATTRIB DONE"
