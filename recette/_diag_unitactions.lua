---@diagnostic disable
-- Inspect unitActions structure in CTLDConfig
local results = {}

local ok, err = pcall(function()
    if not CTLDConfig then
        table.insert(results, "CTLDConfig=nil")
        return
    end
    local cfg = CTLDConfig.get()
    cfg:load()

    local ua = cfg.settings and cfg.settings["unitActions"]
    if not ua then
        table.insert(results, "unitActions=nil")
        return
    end

    table.insert(results, "type=" .. type(ua))
    table.insert(results, "#=" .. tostring(#ua))

    -- Try pairs (dict-style)
    local count = 0
    for k, v in pairs(ua) do
        count = count + 1
        if count <= 5 then
            table.insert(results, "  key=[" .. tostring(k) .. "] val=" .. tostring(type(v) == "table" and (v.unitType or v.troops or "table") or v))
        end
    end
    table.insert(results, "total pairs=" .. count)

    -- Also check ctld.gs wrapper
    local ua2 = ctld.gs("unitActions")
    table.insert(results, "ctld.gs unitActions type=" .. tostring(type(ua2)))
    if type(ua2) == "table" then
        local c2 = 0
        for k, v in pairs(ua2) do
            c2 = c2 + 1
            if c2 <= 3 then
                table.insert(results, "  gs key=[" .. tostring(k) .. "]")
            end
        end
        table.insert(results, "gs total=" .. c2)
    end
end)

if not ok then table.insert(results, "ERROR: " .. tostring(err)) end
return table.concat(results, "\n")
