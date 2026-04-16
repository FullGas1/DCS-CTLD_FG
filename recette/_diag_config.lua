---@diagnostic disable
-- Quick diagnostic: check CTLDConfig.get():load() and unitActions
local results = {}

local ok, err = pcall(function()
    -- Check if CTLDConfig exists
    if not CTLDConfig then
        table.insert(results, "CTLDConfig = nil (CTLD not loaded)")
        return
    end

    local cfg = CTLDConfig.get()
    table.insert(results, "CTLDConfig.get() OK")

    -- Check settings before load
    local ua_before = cfg.settings and cfg.settings["unitActions"] or "nil"
    table.insert(results, "unitActions BEFORE load: " .. tostring(ua_before ~= "nil" and type(ua_before) or "nil"))

    -- Call load
    cfg:load()
    table.insert(results, "cfg:load() OK")

    -- Check settings after load
    local ua = cfg.settings and cfg.settings["unitActions"]
    if ua then
        table.insert(results, "unitActions AFTER load: " .. tostring(type(ua)) .. " #=" .. tostring(#ua or "?"))
        -- Check UH-1H
        local found = false
        for _, v in ipairs(ua) do
            if v.unitType == "UH-1H" then
                found = true
                table.insert(results, "UH-1H troops=" .. tostring(v.troops) .. " crates=" .. tostring(v.crates))
                break
            end
        end
        if not found then table.insert(results, "UH-1H NOT found in unitActions") end
    else
        table.insert(results, "unitActions AFTER load: nil (PROBLEM)")
    end
end)

if not ok then
    table.insert(results, "ERROR: " .. tostring(err))
end

return table.concat(results, "\n")
