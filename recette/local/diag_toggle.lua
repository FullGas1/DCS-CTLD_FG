-- recette/diag_toggle.lua
-- Simulate toggleLayer("infantry") with correct arg order.

local units = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = units[1]
if not pu or not pu:isExist() then return "NO PLAYER" end
local playerName = pu:getName()
local rmgr = CTLDReconManager.getInstance()

-- Layer state before
local layers = rmgr:_getPlayerLayers(playerName)
local before = {}
for _, l in ipairs(layers) do
    before[l.layerId] = l.enabled
end
ctld.logInfo("diag_toggle: BEFORE — " .. (function()
    local t = {}; for k,v in pairs(before) do t[#t+1] = k.."="..tostring(v) end
    table.sort(t); return table.concat(t, " ")
end)())

-- Correct signature: toggleLayer(self, player:string, playerUnit:DCSUnit, layerId:string)
rmgr:toggleLayer(playerName, pu, "infantry")

-- Layer state after
local after = {}
for _, l in ipairs(layers) do
    after[l.layerId] = l.enabled
end
ctld.logInfo("diag_toggle: AFTER  — " .. (function()
    local t = {}; for k,v in pairs(after) do t[#t+1] = k.."="..tostring(v) end
    table.sort(t); return table.concat(t, " ")
end)())

local s = rmgr._activeScans[playerName]
ctld.logInfo(string.format("diag_toggle: infantry before=%s after=%s scan_targets=%d",
    tostring(before.infantry), tostring(after.infantry), s and #s.targets or 0))

trigger.action.outText(string.format("[DIAG] Infantry enabled: %s → %s",
    tostring(before.infantry), tostring(after.infantry)), 20)
return "DIAG OK"
