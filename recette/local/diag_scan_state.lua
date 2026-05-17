-- Diagnose current RECON scan state for BLUE player
local rmgr = CTLDReconManager.getInstance()
local players = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = players[1]
if not pu then return "no BLUE player" end

local pName = pu:getName()
local scan  = rmgr._activeScans[pName]
local layers = rmgr:_getPlayerLayers(pName)

local lines = {}
lines[#lines+1] = "player=" .. pName
lines[#lines+1] = string.format("reconEnabled=%s  reconSearchRadius=%s  reconIconScale=%s",
    tostring(ctld.gs("reconEnabled")),
    tostring(ctld.gs("reconSearchRadius")),
    tostring(ctld.gs("reconIconScale")))

-- Layers state
for _, l in ipairs(layers) do
    lines[#lines+1] = string.format("  layer [%s] enabled=%s", l.layerId, tostring(l.enabled))
end

-- Scan state
if not scan then
    lines[#lines+1] = "activeScan: NONE"
else
    lines[#lines+1] = string.format("activeScan: %d targets  autoRefresh=%s",
        #scan.targets, tostring(scan.autoRefresh))
    for _, t in ipairs(scan.targets) do
        lines[#lines+1] = string.format("  [%s] %s  markId=%s  dist=%.0fm",
            t.layer.layerId, t.unitType, tostring(t.markId), t.distance or 0)
    end
end

local msg = table.concat(lines, "\n")
trigger.action.outText(msg, 30)
return msg
