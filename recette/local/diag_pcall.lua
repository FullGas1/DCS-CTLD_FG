ctld.debug = true

local ok, err = pcall(function()
    local tm = CTLDTroopManager.getInstance()
    return tostring(tm)
end)

trigger.action.outText("pcall result: ok=" .. tostring(ok) .. " val=" .. tostring(err), 30)