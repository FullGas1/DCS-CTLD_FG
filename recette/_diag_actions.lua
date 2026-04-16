---@diagnostic disable
local results = {}
local ua = ctld.gs("unitActions") or {}
local a = ua["UH-1H"]
results[#results+1] = "type=" .. tostring(type(a))
if type(a) == "table" then
    for k,v in pairs(a) do
        results[#results+1] = "  " .. tostring(k) .. "=" .. tostring(v)
    end
elseif type(a) == "boolean" then
    results[#results+1] = "  val=" .. tostring(a)
end
-- Also check _templates count
local tm = CTLDTroopManager and CTLDTroopManager.getInstance()
if tm then
    results[#results+1] = "_templates count=" .. tostring(#(tm._templates or {}))
    if tm._templates and #tm._templates > 0 then
        local t1 = tm._templates[1]
        results[#results+1] = "  tmpl[1].name=" .. tostring(t1.name)
        results[#results+1] = "  tmpl[1].total=" .. tostring(t1.total)
    end
end
return table.concat(results, "\n")
