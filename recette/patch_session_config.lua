-- recette/patch_session_config.lua
-- Permanently enable RECON config for test session:
--   reconEnabled = true (prevents scan() early return via menu)
--   reconSearchRadius = 12000 (covers all test units at 1nm)
--   reconMinAltitude = 0 (air units at any altitude)
--   reconIconSizes x10 (visible when zoomed out on F10 map)
-- Inject once after enable_debug.lua. Stays active for entire session.

local cfg = CTLDConfig.get().settings

cfg["reconEnabled"]      = true
cfg["reconSearchRadius"] = 12000
cfg["reconMinAltitude"]  = 0
cfg["reconIconSizes"] = {
    infantry   = 240,   -- default 30 × 8
    vehicle    = 320,   -- default 40 × 8
    aa         = 280,   -- default 35 × 8
    aircraft   = 320,   -- default 40 × 8
    helicopter = 200,   -- default 25 × 8
    ship_width = 400,   -- default 50 × 8
    ship_height= 160,   -- default 20 × 8
}

-- Force redraw of all existing scan marks at new size.
local units = coalition.getPlayers(coalition.side.BLUE) or {}
local pu = units[1]
if pu and pu:isExist() then
    local playerName = pu:getName()
    local rmgr = CTLDReconManager.getInstance()
    local s = rmgr._activeScans[playerName]
    if s then
        -- Remove all existing marks and recreate them at new size.
        for _, tgt in ipairs(s.targets) do
            if tgt.markId then
                CTLDReconRenderer.removeIcon(tgt.markId)
                if tgt.layer and tgt.layer.enabled then
                    CTLDReconRenderer.createIcon(tgt, tgt.markId)
                end
            end
        end
        ctld.logInfo("patch_session_config: redrawn " .. #s.targets .. " icons at x10 size")
    else
        ctld.logInfo("patch_session_config: no active scan yet (icons will be x10 on next scan)")
    end
end

ctld.logInfo("patch_session_config: reconEnabled=true, radius=12km, minAlt=0, iconSizes x8")
return "PATCH OK — session config applied"
