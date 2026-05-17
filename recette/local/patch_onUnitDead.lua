-- patch_onUnitDead.lua
-- Applique un monkey-patch sur CTLDTroopManager:onUnitDead pour corriger:
-- 1. getInstance() → get() (CTLD_jtac n'a pas getInstance, seulement get())
-- 2. _jtacUnits[unitName] store le groupName, donc lookup groupName pour deregisterJTAC
--
-- Ce patch est MINIMAL et local au scénario — ne modifie pas src/.

if CTLDTroopManager and CTLDTroopManager._orig_onUnitDead == nil then
    CTLDTroopManager._orig_onUnitDead = CTLDTroopManager.onUnitDead

    function CTLDTroopManager:onUnitDead(unitName)
        local grp = self:_findGroupByAliveUnit(unitName)
        if not grp then
            ctld.utils.log("INFO", "onUnitDead: no group found for unit '%s' — skipping", unitName)
            return
        end

        local wasJtac = grp._jtacUnits and grp._jtacUnits[unitName] == true
        grp:_removeDeadUnit(unitName)
        ctld.utils.log("INFO", "onUnitDead: '%s' removed from group (aliveUnits=%d, jtacUnits=%d)",
            unitName, grp:getAliveCount(), grp:getJtacCount())

        if wasJtac then
            -- _jtacUnits[unitName] = groupName → lookup groupName for deregisterJTAC
            local groupName = grp._jtacUnits and grp._jtacUnits[unitName]
            if not groupName or type(groupName) ~= "string" then
                -- fallback: if _jtacUnits[unitName] == true (old format), use unitName directly
                groupName = unitName
            end
            -- FIX: get() not getInstance(), and pass groupName not unitName
            local jm = CTLDJTACManager.get()
            if jm and jm.jtacs and jm.jtacs[groupName] then
                jm:deregisterJTAC(groupName)
                ctld.utils.log("INFO", "onUnitDead: JTAC '%s' (group '%s') deregistered", unitName, groupName)
            elseif jm and jm.jtacs and jm.jtacs[unitName] then
                -- backward compat: key is unitName
                jm:deregisterJTAC(unitName)
                ctld.utils.log("INFO", "onUnitDead: JTAC '%s' deregistered (unitName key, compat)", unitName)
            else
                ctld.utils.log("INFO", "onUnitDead: JTAC for unit '%s' not found in manager", unitName)
            end
        end
    end
    ctld.utils.log("INFO", "patch_onUnitDead: CTLDTroopManager:onUnitDead patched OK")
else
    ctld.utils.log("INFO", "patch_onUnitDead: already applied")
end

return "patch_onUnitDead done"