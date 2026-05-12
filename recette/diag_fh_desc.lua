---@diagnostic disable
-- Check what getDesc() returns for fh1/fh2/fh3
local out = {}
for _, name in ipairs({"fh1","fh2","fh3"}) do
    local s = StaticObject.getByName(name)
    if not (s and s:isExist()) then s = Unit.getByName(name) end
    if s and s:isExist() then
        local ok, desc = pcall(function() return s:getDesc() end)
        if ok and desc then
            local shape = desc.shapeName or desc.shape_name or "NIL"
            table.insert(out, name .. ":shape=" .. tostring(shape))
        else
            table.insert(out, name .. ":getDesc=FAIL")
        end
    else
        table.insert(out, name .. "=NOT_FOUND")
    end
end
return table.concat(out, " | ")
