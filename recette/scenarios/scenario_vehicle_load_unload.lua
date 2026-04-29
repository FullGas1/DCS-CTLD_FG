---@diagnostic disable
-- =============================================================================
-- scenarios/scenario_vehicle_load_unload.lua
-- Interactive test — GAP-1 : Load / Unload whole vehicle via F10 menu
--
-- Steps (one injection per step):
--   Step 1 — cleanup + config + Request Equipment (spawn HMMWV crate near player)
--   Step 2 — Unpack crate (spawn HMMWV vehicle) + assert registered in spawner
--   Step 3 — Simulate Load menu (findLoadableVehicles + loadVehicle)
--   Step 4 — Simulate Unload menu (findLoadedVehicles + unloadVehicle) + final report
--   Step 5 — RESET
--
-- Requires: UH-1H BLUE player slot occupied, CTLD loaded.
-- =============================================================================

local STEP_VAR = "_VEH_LOAD_STEP"

local function report(msg)
    trigger.action.outText("[VEH-LOAD] " .. msg, 50)
    ctld.utils.log("INFO", "[scenario_vehicle_load_unload] " .. msg)
end

local function fail(msg)
    trigger.action.outText("[VEH-LOAD] !! FAIL: " .. msg, 60)
    ctld.utils.log("INFO", "[scenario_vehicle_load_unload] FAIL: " .. msg)
end

-- ── resolve player ────────────────────────────────────────────────────────────

local playerUnit = nil
do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    if #units > 0 then playerUnit = units[1] end
end
if not playerUnit or not playerUnit:isExist() then
    return "ABORT: no BLUE player — occupy a slot first"
end
local playerName = playerUnit:getName()
local pPos       = playerUnit:getPoint()

-- ── helpers ───────────────────────────────────────────────────────────────────

-- M1043 HMMWV Armament = 1 crate only (M1045 TOW = 2 crates, would need 2 requests)
local HMMWV_TYPE  = "M1043 HMMWV Armament"
local CRATE_GROUP = "SCN_VEH_CRATE_HMMWV"
local VEH_GROUP   = "SCN_VEH_HMMWV"

local function destroyGroup(name)
    local g = Group.getByName(name)
    if g and g:isExist() then g:destroy() end
end

local function cleanupAll()
    destroyGroup(CRATE_GROUP)
    destroyGroup(VEH_GROUP)
    -- Destroy all non-player BLUE ground groups
    local grps = coalition.getGroups(coalition.side.BLUE, Group.Category.GROUND) or {}
    for _, g in ipairs(grps) do
        if g and g:isExist() then g:destroy() end
    end
    -- Remove injected test vehicle from spawner registry
    local spawner = CTLDVehicleSpawner.getInstance()
    for id, v in pairs(spawner._vehicles) do
        if v.vehicleType == HMMWV_TYPE then
            if v.spawnData then
                spawner._unitToVehicle[v.spawnData.unitName] = nil
            end
            spawner._vehicles[id] = nil
        end
    end
    ctld.utils.log("INFO", "[scenario_vehicle_load_unload] cleanup done")
end

local function findRegisteredHmmwv()
    local spawner = CTLDVehicleSpawner.getInstance()
    for _, v in pairs(spawner._vehicles) do
        if v.vehicleType == HMMWV_TYPE then return v end
    end
    return nil
end

-- ── state machine ─────────────────────────────────────────────────────────────

_G[STEP_VAR] = _G[STEP_VAR] or 1
local step = _G[STEP_VAR]

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 1 — Cleanup + config + spawn HMMWV crate near player
-- ══════════════════════════════════════════════════════════════════════════════
if step == 1 then

    cleanupAll()

    -- Enable UH-1H for whole-vehicle transport
    local cfg = CTLDConfig.get().settings
    cfg["vehicleTransportEnabled"] = { "UH-1H", "Mi-8", "Hercules", "76MD", "C-130J-30" }
    report("Config: UH-1H added to vehicleTransportEnabled.")

    -- Spawn a HMMWV crate 30 m in front of the player (simulates Request Equipment)
    local cratePos = { x = pPos.x + 30, y = land.getHeight({x=pPos.x+30, y=pPos.z}), z = pPos.z }
    local mgr = CTLDCrateManager.getInstance()
    local desc = mgr:findDescriptorByUnitType(HMMWV_TYPE)
    if not desc then
        fail("No descriptor found for " .. HMMWV_TYPE .. " — check spawnableCrates config")
        return
    end

    local ok, err = pcall(function()
        mgr:spawnCrate(desc, cratePos, coalition.side.BLUE, playerName, "request_equipment")
    end)
    if not ok then
        fail("spawnCrate failed: " .. tostring(err)); return
    end

    report("Step 1 DONE — HMMWV crate spawned 30m ahead. Re-inject for Step 2 (Unpack).")
    _G[STEP_VAR] = 2

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 2 — Unpack crate → HMMWV vehicle spawned + registered in CTLDVehicleSpawner
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 2 then

    local mgr     = CTLDCrateManager.getInstance()
    local spawner = CTLDVehicleSpawner.getInstance()

    -- Find the crate closest to player
    local nearby = mgr:getCratesInRange(pPos, 200)
    local targetCrate = nil
    for _, c in ipairs(nearby) do
        if c.descriptor and c.descriptor.unit == HMMWV_TYPE and c:isOnGround() then
            targetCrate = c; break
        end
    end
    if not targetCrate then
        fail("No HMMWV crate found within 200m — did Step 1 succeed?"); return
    end

    -- Count spawner entries before unpack
    local beforeCount = 0
    for _ in pairs(spawner._vehicles) do beforeCount = beforeCount + 1 end

    -- Unpack
    local spawnPos  = { x = pPos.x + 50, y = land.getHeight({x=pPos.x+50, y=pPos.z+10}), z = pPos.z + 10 }
    local crateDesc = targetCrate.descriptor
    local coa       = coalition.side.BLUE
    local cId       = country.id.USA
    mgr:unpackCrate(targetCrate.crateName, playerUnit)
    mgr:_spawnUnpacked(crateDesc, spawnPos, coa, cId)

    -- Check registration
    local afterCount = 0
    for _ in pairs(spawner._vehicles) do afterCount = afterCount + 1 end

    if afterCount > beforeCount then
        local v = findRegisteredHmmwv()
        if v then
            report(string.format(
                "Step 2 PASS — HMMWV unpacked + registered in spawner (id=%s, state=%s). Re-inject for Step 3 (Load).",
                v.id, v:getState()))
        else
            fail("Vehicle count increased but HMMWV not found — check vehicleType match")
            return
        end
    else
        fail("_dispatchPostSpawn did NOT register the HMMWV (count before=" ..
             beforeCount .. " after=" .. afterCount .. ")")
        return
    end

    _G[STEP_VAR] = 3

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 3 — Simulate Load menu : findLoadableVehicles → loadVehicle
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 3 then

    local spawner = CTLDVehicleSpawner.getInstance()

    local loadable = spawner:findLoadableVehicles(playerUnit)
    if #loadable == 0 then
        fail("findLoadableVehicles returned empty — HMMWV not in WAITING state or too far?")
        return
    end

    -- Pick first HMMWV
    local veh = nil
    for _, v in ipairs(loadable) do
        if v.vehicleType == HMMWV_TYPE then veh = v; break end
    end
    if not veh then
        fail("HMMWV not in loadable list — found " .. #loadable .. " other vehicle(s)")
        return
    end

    report(string.format("findLoadableVehicles: found %d vehicle(s), picking HMMWV id=%s", #loadable, veh.id))

    -- Execute load
    local ok, err = pcall(function()
        spawner:loadVehicle(veh, playerUnit, playerName, "menu_ctld")
    end)
    if not ok then
        fail("loadVehicle crashed: " .. tostring(err)); return
    end

    if veh:getState() == CTLDVehicle.STATE.LOADED then
        report(string.format(
            "Step 3 PASS — HMMWV id=%s loaded into %s (state=LOADED). Re-inject for Step 4 (Unload).",
            veh.id, playerName))
    else
        fail("loadVehicle did not set state LOADED (got: " .. veh:getState() .. ")")
        return
    end

    _G[STEP_VAR] = 4

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 4 — Simulate Unload menu : findLoadedVehicles → unloadVehicle
-- ══════════════════════════════════════════════════════════════════════════════
elseif step == 4 then

    local spawner = CTLDVehicleSpawner.getInstance()

    local onboard = spawner:findLoadedVehicles(playerUnit)
    if #onboard == 0 then
        fail("findLoadedVehicles returned empty — HMMWV not in LOADED state on this transport?")
        return
    end

    local veh = nil
    for _, v in ipairs(onboard) do
        if v.vehicleType == HMMWV_TYPE then veh = v; break end
    end
    if not veh then
        fail("HMMWV not in onboard list — found " .. #onboard .. " other vehicle(s)")
        return
    end

    report(string.format("findLoadedVehicles: found %d vehicle(s) onboard, picking HMMWV id=%s", #onboard, veh.id))

    -- Execute unload
    local ok, err = pcall(function()
        spawner:unloadVehicle(veh, playerUnit, playerName, "menu_ctld")
    end)
    if not ok then
        fail("unloadVehicle crashed: " .. tostring(err)); return
    end

    if veh:getState() == CTLDVehicle.STATE.WAITING then
        -- Verify it no longer appears in onboard list
        local stillOnboard = spawner:findLoadedVehicles(playerUnit)
        local stillFound = false
        for _, v in ipairs(stillOnboard) do
            if v.id == veh.id then stillFound = true end
        end
        if stillFound then
            fail("HMMWV still in findLoadedVehicles after unload!")
            return
        end
        report(string.format(
            "Step 4 PASS — HMMWV id=%s unloaded (state=WAITING, re-loadable, no longer in onboard list).",
            veh.id))
        report("=== SCENARIO COMPLETE — all 4 steps PASS. Re-inject for RESET. ===")
    else
        fail("unloadVehicle did not set state WAITING (got: " .. veh:getState() .. ")")
        return
    end

    _G[STEP_VAR] = 5

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 5 — RESET
-- ══════════════════════════════════════════════════════════════════════════════
elseif step >= 5 then

    cleanupAll()
    -- Restore default vehicleTransportEnabled (without UH-1H override)
    -- Note: UH-1H is now in the default config — this just resets any runtime change.
    _G[STEP_VAR] = 1
    report("RESET — all test objects removed. Re-inject to start from Step 1.")

end
