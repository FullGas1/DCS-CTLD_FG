env.info("[tfc_diag_tmpl] START")
ctld.debug = true

local tmplMgr = CTLDTroopManager.getInstance()
if not tmplMgr then
    env.info("[tfc_diag_tmpl] NO troopMgr")
    trigger.action.outText("[DIAG] NO troopMgr", 30)
    return "no_mgr"
end

local list = tmplMgr._templates or {}
env.info("[tfc_diag_tmpl] templates=" .. #list)
for i, t in ipairs(list) do
    local n = t and t.name or "nil"
    local j = t and t.jtac or "?"
    local tot = t and t.total or "?"
    env.info("[tfc_diag_tmpl] [" .. i .. "] name='" .. n .. "' jtac=" .. tostring(j) .. " total=" .. tostring(tot))
    trigger.action.outText("[DIAG] [" .. i .. "] '" .. n .. "' jtac=" .. tostring(j) .. " total=" .. tostring(tot), 30)
end

-- test _findTemplate
local names = { "JTAC Group 2", "JTAC Group 1", "Test2JTAC", "JTAC Group" }
for _, nm in ipairs(names) do
    local found = tmplMgr:_findTemplate(nm)
    env.info("[tfc_diag_tmpl] findTemplate('" .. nm .. "')=" .. tostring(found ~= nil))
end

env.info("[tfc_diag_tmpl] END")
trigger.action.outText("[DIAG] end templates=" .. #list, 30)
return "diag_done"