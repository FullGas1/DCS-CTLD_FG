local step = _G['_TFC_STEP']
env.info("[tfc] _TFC_STEP=" .. tostring(step))
local tmpl = nil
if CTLDTroopManager then
    local m = CTLDTroopManager.getInstance()
    if m then
        for _, t in ipairs(m._templates or {}) do
            if t.name == 'Test2JTAC' then tmpl = t; break end
        end
    end
end
env.info("[tfc] Test2JTAC=" .. tostring(tmpl ~= nil))
if tmpl then env.info("[tfc] jtac=" .. tmpl.jtac) end
if CTLDJTACManager then
    local j = CTLDJTACManager.get()
    if j then
        local c = 0
        for _ in pairs(j.jtacs or {}) do c = c + 1 end
        env.info("[tfc] JTACs=" .. c)
    end
end
env.info("[tfc] done")
return "diag"