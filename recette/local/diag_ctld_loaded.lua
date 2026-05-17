-- diag_ctld_loaded.lua
-- Vérifie que CTLD et ses managers sont accessibles dans le contexte Witchcraft
ctld.debug = true

local checks = {
    { name = "ctld global",       fn = function() return ctld ~= nil end },
    { name = "CTLDTroopManager",  fn = function() return CTLDTroopManager ~= nil end },
    { name = "CTLDJTACManager",   fn = function() return CTLDJTACManager ~= nil end },
    { name = "CTLDObjectRegistry",fn = function() return CTLDObjectRegistry ~= nil end },
}

for _, c in ipairs(checks) do
    local ok, res = pcall(c.fn)
    local status = ok and res == true and "✅" or "❌"
    trigger.action.outText(status .. " " .. c.name .. " — ok=" .. tostring(ok) .. " res=" .. tostring(res), 30)
    ctld.utils.log("INFO", "[diag] " .. status .. " " .. c.name .. " ok=" .. tostring(ok) .. " res=" .. tostring(res))
end

if CTLDTroopManager then
    local ok, tm = pcall(CTLDTroopManager.getInstance)
    trigger.action.outText((ok and tm and "✅" or "❌") .. " CTLDTroopManager:getInstance() — ok=" .. tostring(ok), 30)
    ctld.utils.log("INFO", "[diag] TM getInstance ok=" .. tostring(ok) .. " instance=" .. tostring(tm))
end

if CTLDJTACManager then
    local ok, jm = pcall(CTLDJTACManager.get)
    trigger.action.outText((ok and jm and "✅" or "❌") .. " CTLDJTACManager:get() — ok=" .. tostring(ok), 30)
    ctld.utils.log("INFO", "[diag] JM get ok=" .. tostring(ok) .. " instance=" .. tostring(jm))
end

trigger.action.outText("[diag] CTLD loaded modules check complete", 30)