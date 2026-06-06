-- Patch _aiTeams[2] to use a template compatible with UH-1H (maxTroopsOnboard=8)
local cm = CTLDCoreManager.getInstance()
local tm = CTLDTroopManager.getInstance()
local caps = (ctld.gs("capabilitiesByType") or {})["UH-1H"] or {}
local limit = caps.maxTroopsOnboard or ctld.gs("numberOfTroops") or 10
-- Find first non-JTAC template with total <= limit
local found = nil
for _, t in ipairs(tm._templates) do
    if not t.disabled and not t.hasJtac and (t.total or 0) <= limit and (t.total or 0) > 0 then
        found = t
        break
    end
end
if not found then return "NO TEMPLATE FOUND with total<=" .. limit end
-- Patch task on the template
found.specificParams = { task = "gotoNearestWPZ" }
cm._aiTeams[2] = { found }
return string.format("patched: tmpl='%s' total=%d task=%s", found.name, found.total, found.specificParams.task)
