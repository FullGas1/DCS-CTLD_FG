---@diagnostic disable
-- Check _detectCapabilities for current player
local results = {}

local ok, err = pcall(function()
    -- Find a BLUE player unit
    local playerUnit = nil
    for _, player in pairs(net.get_player_list and net.get_player_list() or {}) do
        local ucid = net.get_player_info(player, "ucid")
        local unitName = net.get_player_info(player, "unit_type") -- not quite right
        -- Try via world
    end

    -- Try direct approach: find UH-1H unit
    local coalUnits = coalition.getGroups(2) -- BLUE
    for _, grp in ipairs(coalUnits or {}) do
        for _, u in ipairs(grp:getUnits() or {}) do
            if u:isExist() then
                local utype = u:getTypeName()
                if utype == "UH-1H" then
                    table.insert(results, "Found UH-1H: " .. u:getName())
                    -- Simulate _detectCapabilities
                    local ua = ctld.gs("unitActions")
                    table.insert(results, "ctld.gs(unitActions) type=" .. tostring(type(ua)))
                    if type(ua) == "table" then
                        local cap = ua[utype]
                        table.insert(results, "unitActions['UH-1H']=" .. tostring(cap))
                        table.insert(results, "isTransport would be: " .. tostring(cap ~= nil and cap ~= false))
                    end
                    break
                end
            end
        end
    end
    if #results == 0 then
        table.insert(results, "No UH-1H found in coalition BLUE groups")
        -- Check via CTLDPlayerManager
        if CTLDPlayerManager then
            local pm = CTLDPlayerManager.getInstance()
            table.insert(results, "PlayerManager players count check...")
        end
    end
end)

if not ok then table.insert(results, "ERROR: " .. tostring(err)) end
return table.concat(results, "\n")
