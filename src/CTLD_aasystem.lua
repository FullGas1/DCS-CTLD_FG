-- ============================================================
-- CTLD_aasystem.lua
-- CTLDCrateAssemblyManager singleton
--
-- Manages multi-part AA system assembly, rearm, and repair.
-- Supported systems: HAWK, Patriot, NASAMS, BUK, KUB, S-300.
--
-- Spawn geometry:
--   All parts are placed relative to the unpacking transport unit
--   (same pattern as CTLD_fob.lua: reference point at 100 m / 12 o'clock
--   of the transport, then parts arranged in a circle of radius spawnRadius
--   around that reference).  This avoids terrain issues caused by scattered
--   crate positions.
--
-- Usage (called by M7 menu):
--   local aam = CTLDCrateAssemblyManager.getInstance()
--   local handled = aam:tryUnpackOrRepair(heliUnit, crate, allCrates, radius)
--   -- if handled == false, caller falls through to standard unpack.
--
-- Events published:
--   OnAASystemDeployed  — full system assembled for the first time
--   OnAASystemRearmed   — extra launchers added to an existing complete system
--   OnAASystemRepaired  — damaged system respawned in place
--
-- Config keys: aaLaunchers, AASystemLimitRED, AASystemLimitBLUE,
--              AASystemCrateStacking
--
-- Dependencies: class (lib/class.lua), ctld.utils, ctld.gs,
--               EventDispatcher
-- DCS API: Unit, Group, land.getHeight, timer, trigger.action
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- AA system templates (static data — mission-maker can override
-- CTLDCrateAssemblyManager.TEMPLATES before init if needed).
-- Structure mirrors source ctld.AASystemTemplate.
-- ============================================================

CTLDCrateAssemblyManager = class()
CTLDCrateAssemblyManager._instance = nil

--- Static template table.  Each entry:
--   name    string   system display name
--   count   number   unique part types required for a complete system
--   parts   array    { name, desc, launcher?, amount?, NoCrate? }
--     name     DCS type name of the ground unit
--     desc     human-readable label (for "missing" messages)
--     launcher true   → this part is the "launcher" (used for rearm detection)
--     amount   number → override spawn count per template (default 1, or aaLaunchers for launchers)
--     NoCrate  true   → part is spawned without a crate (always found)
--   repair  string   DCS type name of the repair crate unit for this system
CTLDCrateAssemblyManager.TEMPLATES = {
    {
        name  = "HAWK AA System",
        count = 5,
        parts = {
            { name = "Hawk ln",   desc = "HAWK Launcher",     launcher = true },
            { name = "Hawk tr",   desc = "HAWK Track Radar",  amount = 2 },
            { name = "Hawk sr",   desc = "HAWK Search Radar", amount = 2 },
            { name = "Hawk pcp",  desc = "HAWK PCP",          NoCrate = true },
            { name = "Hawk cwar", desc = "HAWK CWAR",         amount = 2, NoCrate = true },
        },
        repair = "HAWK Repair",
    },
    {
        name  = "Patriot AA System",
        count = 4,
        parts = {
            { name = "Patriot ln",  desc = "Patriot Launcher",               launcher = true, amount = 8 },
            { name = "Patriot ECS", desc = "Patriot Control Unit" },
            { name = "Patriot str", desc = "Patriot Search and Track Radar", amount = 2 },
            { name = "Patriot AMG", desc = "Patriot AMG DL relay",           NoCrate = true },
        },
        repair = "Patriot Repair",
    },
    {
        name  = "NASAMS AA System",
        count = 3,
        parts = {
            { name = "NASAMS_LN_C",          desc = "NASAMS Launcher 120C",     launcher = true },
            { name = "NASAMS_Radar_MPQ64F1", desc = "NASAMS Search/Track Radar" },
            { name = "NASAMS_Command_Post",  desc = "NASAMS Command Post" },
        },
        repair = "NASAMS Repair",
    },
    {
        name  = "BUK AA System",
        count = 3,
        parts = {
            { name = "SA-11 Buk LN 9A310M1", desc = "BUK Launcher",    launcher = true },
            { name = "SA-11 Buk CC 9S470M1", desc = "BUK CC Radar" },
            { name = "SA-11 Buk SR 9S18M1",  desc = "BUK Search Radar" },
        },
        repair = "BUK Repair",
    },
    {
        name  = "KUB AA System",
        count = 2,
        parts = {
            { name = "Kub 2P25 ln",  desc = "KUB Launcher", launcher = true },
            { name = "Kub 1S91 str", desc = "KUB Radar" },
        },
        repair = "KUB Repair",
    },
    {
        name  = "S-300 AA System",
        count = 6,
        parts = {
            { name = "S-300PS 5P85C ln", desc = "S-300 Grumble TEL C",         launcher = true, amount = 1 },
            { name = "S-300PS 5P85D ln", desc = "S-300 Grumble TEL D",         NoCrate = true,  amount = 2 },
            { name = "S-300PS 40B6M tr", desc = "S-300 Grumble Flap Lid-A TR" },
            { name = "S-300PS 40B6MD sr",desc = "S-300 Grumble Clam Shell SR" },
            { name = "S-300PS 64H6E sr", desc = "S-300 Grumble Big Bird SR" },
            { name = "S-300PS 54K6 cp",  desc = "S-300 Grumble C2" },
        },
        repair = "S-300 Repair",
    },
}

-- ============================================================
-- Singleton
-- ============================================================

function CTLDCrateAssemblyManager.getInstance()
    if not CTLDCrateAssemblyManager._instance then
        local o = setmetatable({}, CTLDCrateAssemblyManager)
        o:init()
        CTLDCrateAssemblyManager._instance = o
    end
    return CTLDCrateAssemblyManager._instance
end

function CTLDCrateAssemblyManager:init()
    -- groupName → { details = [{point,unit,name,hdg}], template = template }
    self._completeSystems = {}
    ctld.utils.log("INFO", "CTLDCrateAssemblyManager: init complete")
end

-- ============================================================
-- Module-local helpers
-- ============================================================

local _SPAWN_RADIUS  = 50   -- metres, circle radius for unit placement around reference
local _REARM_DIST    = 300  -- metres, max dist to existing system for rearm
local _ASSEMBLY_DIST = 500  -- metres, max crate-to-reference dist for assembly

--- Compute the reference spawn origin: 100 m at 12 o'clock from the transport.
-- Mirrors _computeCentroid in CTLD_fob.lua.
local function _computeOrigin(transport)
    local pt  = transport:getPoint()
    local hdg = ctld.utils.getHeadingInRadians(
                    "CTLDCrateAssemblyManager._computeOrigin", transport, true)
    local fx  = pt.x + math.cos(hdg) * 100
    local fz  = pt.z + math.sin(hdg) * 100
    return { x = fx, y = land.getHeight({ x = fx, y = fz }), z = fz }
end

--- Return the launcher part name for a template, or nil.
local function _getLauncherUnit(template)
    for _, part in ipairs(template.parts) do
        if part.launcher then return part.name end
    end
    return nil
end

-- ============================================================
-- Public helpers
-- ============================================================

--- Find the AA template that owns a given DCS unit type name.
-- Checks both part names and the repair unit name.
-- @param unitName string   DCS type name (from crate descriptor.unit)
-- @return table|nil        template entry from TEMPLATES, or nil
function CTLDCrateAssemblyManager:getTemplateForUnit(unitName)
    if not unitName then return nil end
    for _, tmpl in ipairs(CTLDCrateAssemblyManager.TEMPLATES) do
        if tmpl.repair == unitName then return tmpl end
        for _, part in ipairs(tmpl.parts) do
            if part.name == unitName then return tmpl end
        end
    end
    return nil
end

--- Count complete active AA systems for a given coalition.
-- A system is complete when its group is still alive and contains the
-- required number of unique part types.
-- @param coalitionId number  coalition.side.*
-- @return number
function CTLDCrateAssemblyManager:countComplete(coalitionId)
    local count = 0
    for groupName, entry in pairs(self._completeSystems) do
        local grp = Group.getByName(groupName)
        if grp and grp:getCoalition() == coalitionId then
            local units = grp:getUnits() or {}
            local uniqueTypes = {}
            for _, u in ipairs(units) do
                if u:getLife() > 0 then
                    uniqueTypes[u:getTypeName()] = true
                end
            end
            local typeCount = 0
            for _ in pairs(uniqueTypes) do typeCount = typeCount + 1 end
            if typeCount >= entry.template.count then
                count = count + 1
            end
        end
    end
    return count
end

--- Return the config limit for a coalition.
-- @param coalitionId number
-- @return number
function CTLDCrateAssemblyManager:getAllowedCount(coalitionId)
    if coalitionId == coalition.side.BLUE then
        return ctld.gs("AASystemLimitBLUE") or 20
    end
    return ctld.gs("AASystemLimitRED") or 20
end

-- ============================================================
-- Main entry point
-- ============================================================

--- Try to handle an unpack action as an AA system operation.
-- Called by the M7 menu controller before falling through to standard unpack.
--
-- @param heli      Unit        transport unit performing the action
-- @param crate     CTLDCrate   the nearest crate (already confirmed on ground)
-- @param allCrates table       CTLDCrateManager.crates  (name → CTLDCrate)
-- @param radius    number|nil  search radius for nearby crates (default 500 m)
-- @return boolean  true if an AA action was performed (caller must not unpack further)
function CTLDCrateAssemblyManager:tryUnpackOrRepair(heli, crate, allCrates, radius)
    if not crate or not crate.descriptor then return false end

    local unitName = crate.descriptor.unit
    local template = self:getTemplateForUnit(unitName)
    if not template then return false end

    if unitName == template.repair then
        self:_repair(heli, crate, template)
    else
        self:_assemble(heli, crate, allCrates, template, radius or _ASSEMBLY_DIST)
    end
    return true
end

-- ============================================================
-- _assemble  (new deployment or rearm path)
-- ============================================================

--- Main assembly logic: collect nearby parts, check completeness, spawn.
-- First tries the rearm path if the nearest crate is a launcher and a
-- complete system exists within rearm distance.
-- @param heli      Unit
-- @param crate     CTLDCrate   nearest crate (the one the player is at)
-- @param allCrates table       name → CTLDCrate
-- @param template  table
-- @param radius    number      part search radius in metres
function CTLDCrateAssemblyManager:_assemble(heli, crate, allCrates, template, radius)
    -- Rearm path: launcher crate + existing complete system nearby
    if crate.descriptor.unit == _getLauncherUnit(template) then
        if self:_rearm(heli, crate, allCrates, template) then return end
    end

    -- Compute reference origin (100 m / 12 o'clock of heli)
    local origin = _computeOrigin(heli)

    -- ---- Collect all on-ground crates that are parts of this template ----
    -- systemParts[partName] = { desc, launcher, amount, NoCrate, found, required, crates[] }
    local systemParts = {}
    for _, part in ipairs(template.parts) do
        systemParts[part.name] = {
            desc     = part.desc,
            launcher = part.launcher,
            amount   = part.amount,
            NoCrate  = part.NoCrate,
            found    = part.NoCrate and 1 or 0,
            required = 1,
            crates   = {},
        }
    end

    for _, c in pairs(allCrates) do
        if c:isOnGround() and c.descriptor then
            local pName = c.descriptor.unit
            if systemParts[pName] then
                local dist = ctld.utils.getDistance(
                    "CTLDCrateAssemblyManager:_assemble",
                    origin, c.position)
                if dist <= radius then
                    local sp = systemParts[pName]
                    -- First occurrence: read cratesRequired from descriptor
                    if sp.found == 0 then
                        sp.required = c.descriptor.cratesRequired or 1
                    end
                    sp.found = sp.found + 1
                    table.insert(sp.crates, c)
                end
            end
        end
    end

    -- ---- Check completeness, build missing-parts message ----
    local missingTxt = ""
    for _, part in ipairs(template.parts) do
        local sp = systemParts[part.name]
        if sp.found < sp.required then
            missingTxt = missingTxt .. ctld.tr("Missing %1\n", "Missing " .. sp.desc .. "\n")
        end
    end

    if missingTxt ~= "" then
        trigger.action.outTextForGroup(
            heli:getGroup():getID(),
            ctld.tr("Cannot build %1\n%2\n\nOr the crates are not close enough together",
                    "Cannot build " .. template.name .. "\n" .. missingTxt ..
                    "\nOr the crates are not close enough together"),
            20)
        return
    end

    -- ---- Check system limit ----
    local coalitionId   = heli:getCoalition()
    local active        = self:countComplete(coalitionId)
    local allowed       = self:getAllowedCount(coalitionId)
    if active + 1 > allowed then
        trigger.action.outTextForGroup(
            heli:getGroup():getID(),
            ctld.tr("Out of parts for AA Systems. Current limit is %1\n",
                    "Out of parts for AA Systems. Current limit is " .. allowed),
            10)
        return
    end

    -- ---- Compute spawn positions relative to origin ----
    local positions, types, headings = self:_buildSpawnArrays(template, systemParts, origin, heli)

    -- ---- Destroy consumed crates ----
    local stacking = ctld.gs("AASystemCrateStacking") or false
    for _, part in ipairs(template.parts) do
        local sp = systemParts[part.name]
        if not sp.NoCrate then
            local amountFactor = stacking
                and (sp.found - sp.found % sp.required)
                or 1
            local toDelete  = amountFactor * sp.required
            local deleted   = 0
            for _, c in ipairs(sp.crates) do
                if deleted >= toDelete then break end
                c:destroy()
                deleted = deleted + 1
            end
        end
    end

    -- ---- Spawn group ----
    local spawnedGroup = self:_spawnGroup(heli, positions, types, headings)
    if not spawnedGroup then
        ctld.utils.log("ERROR", "CTLDCrateAssemblyManager:_assemble — spawnGroup failed for " .. template.name)
        return
    end

    self._completeSystems[spawnedGroup:getName()] = {
        details  = self:_getDetails(spawnedGroup, template),
        template = template,
    }

    EventDispatcher.getInstance():publish("OnAASystemDeployed", {
        systemName  = template.name,
        groupName   = spawnedGroup:getName(),
        heli        = heli,
        coalition   = coalitionId,
        position    = origin,
        timestamp   = timer.getAbsTime(),
    })

    trigger.action.outTextForCoalition(
        coalitionId,
        string.format("%s successfully deployed a full %s in the field.\n\nAA Active System limit: %d\nActive: %d",
            heli:getName(), template.name, allowed, active + 1),
        10)

    ctld.utils.log("INFO", string.format(
        "CTLDCrateAssemblyManager: deployed %s group=%s coalition=%d",
        template.name, spawnedGroup:getName(), coalitionId))
end

-- ============================================================
-- _rearm  (add launchers to existing complete system)
-- ============================================================

--- Add launcher crates to an existing complete system within rearm distance.
-- @param heli      Unit
-- @param crate     CTLDCrate   launcher crate
-- @param allCrates table
-- @param template  table
-- @return boolean  true if rearm was performed
function CTLDCrateAssemblyManager:_rearm(heli, crate, allCrates, template)
    local nearest = self:_findNearest(heli, template)
    if not nearest or nearest.dist > _REARM_DIST then return false end

    local grp   = nearest.group
    local units = grp:getUnits() or {}

    -- Collect current unit positions/types/headings from the live group
    local uniqueTypes = {}
    local points, types, headings = {}, {}, {}
    for _, u in ipairs(units) do
        if u:getLife() > 0 then
            uniqueTypes[u:getTypeName()] = true
            table.insert(points,   u:getPoint())
            table.insert(types,    u:getTypeName())
            table.insert(headings, ctld.utils.getHeadingInRadians(
                "CTLDCrateAssemblyManager:_rearm", u, true))
        end
    end

    local typeCount = 0
    for _ in pairs(uniqueTypes) do typeCount = typeCount + 1 end
    if typeCount < template.count then return false end  -- system not complete

    -- Destroy old group
    self._completeSystems[grp:getName()] = nil
    grp:destroy()

    -- Respawn with same positions/types/headings (fully rearmed)
    local spawnedGroup = self:_spawnGroup(heli, points, types, headings)
    if not spawnedGroup then
        ctld.utils.log("ERROR", "CTLDCrateAssemblyManager:_rearm — spawnGroup failed")
        return false
    end

    self._completeSystems[spawnedGroup:getName()] = {
        details  = self:_getDetails(spawnedGroup, template),
        template = template,
    }

    -- Destroy launcher crate
    crate:destroy()

    EventDispatcher.getInstance():publish("OnAASystemRearmed", {
        systemName = template.name,
        groupName  = spawnedGroup:getName(),
        heli       = heli,
        coalition  = heli:getCoalition(),
        timestamp  = timer.getAbsTime(),
    })

    trigger.action.outTextForCoalition(
        heli:getCoalition(),
        string.format("%s successfully rearmed a full %s in the field",
            heli:getName(),
            template.name),
        20)

    ctld.utils.log("INFO", "CTLDCrateAssemblyManager: rearmed " .. template.name)
    return true
end

-- ============================================================
-- _repair  (respawn damaged system in place)
-- ============================================================

--- Repair a damaged AA system: respawn it at the same positions/headings.
-- @param heli      Unit
-- @param crate     CTLDCrate   repair crate
-- @param template  table
function CTLDCrateAssemblyManager:_repair(heli, crate, template)
    local nearest = self:_findNearest(heli, template)
    if not nearest or nearest.dist > _REARM_DIST then
        trigger.action.outTextForGroup(
            heli:getGroup():getID(),
            string.format("Cannot repair %s. No damaged %s within %dm",
                template.name, template.name, _REARM_DIST),
            10)
        return
    end

    local entry   = self._completeSystems[nearest.group:getName()]
    local oldGrp  = nearest.group

    local points, types, headings = {}, {}, {}
    for _, detail in ipairs(entry.details) do
        table.insert(points,   detail.point)
        table.insert(types,    detail.unit)
        table.insert(headings, detail.hdg)
    end

    -- Destroy old (damaged) group
    self._completeSystems[oldGrp:getName()] = nil
    oldGrp:destroy()

    local spawnedGroup = self:_spawnGroup(heli, points, types, headings)
    if not spawnedGroup then
        ctld.utils.log("ERROR", "CTLDCrateAssemblyManager:_repair — spawnGroup failed")
        return
    end

    self._completeSystems[spawnedGroup:getName()] = {
        details  = self:_getDetails(spawnedGroup, template),
        template = template,
    }

    crate:destroy()

    EventDispatcher.getInstance():publish("OnAASystemRepaired", {
        systemName = template.name,
        groupName  = spawnedGroup:getName(),
        heli       = heli,
        coalition  = heli:getCoalition(),
        timestamp  = timer.getAbsTime(),
    })

    trigger.action.outTextForCoalition(
        heli:getCoalition(),
        string.format("%s successfully repaired a full %s in the field.",
            heli:getName(),
            template.name),
        10)

    ctld.utils.log("INFO", "CTLDCrateAssemblyManager: repaired " .. template.name)
end

-- ============================================================
-- Internal helpers
-- ============================================================

--- Find the nearest complete AA system of a given template type
-- that belongs to the same coalition as heli.
-- @param heli      Unit
-- @param template  table
-- @return table|nil  { group=Group, dist=number }
function CTLDCrateAssemblyManager:_findNearest(heli, template)
    local best     = nil
    local bestDist = -1
    local heliPos  = heli:getPoint()

    for groupName, entry in pairs(self._completeSystems) do
        if entry.template.name == template.name then
            local grp = Group.getByName(groupName)
            if grp and grp:getCoalition() == heli:getCoalition() then
                local units = grp:getUnits() or {}
                for _, u in ipairs(units) do
                    if u:getLife() > 0 then
                        local d = ctld.utils.getDistance(
                            "CTLDCrateAssemblyManager:_findNearest",
                            u:getPoint(), heliPos)
                        if d and (bestDist < 0 or d < bestDist) then
                            bestDist = d
                            best     = grp
                        end
                        break
                    end
                end
            end
        end
    end

    if best then return { group = best, dist = bestDist } end
    return nil
end

--- Capture current positions/types/headings of all alive units in a group.
-- Used to persist state for repair.
-- @param group    DCS Group
-- @param template table
-- @return array   { point, unit, name, hdg }
function CTLDCrateAssemblyManager:_getDetails(group, template)
    local details = {}
    local units   = group:getUnits() or {}
    for _, u in ipairs(units) do
        table.insert(details, {
            point = u:getPoint(),
            unit  = u:getTypeName(),
            name  = u:getName(),
            hdg   = ctld.utils.getHeadingInRadians(
                        "CTLDCrateAssemblyManager:_getDetails", u, true),
        })
    end
    return details
end

--- Build parallel position/type/heading arrays for dynAdd from systemParts.
-- All positions are relative to origin (100 m / 12 o'clock of transport).
-- Parts are arranged in a circle of radius _SPAWN_RADIUS around origin;
-- multiple units of the same part are evenly distributed around the circle.
-- NoCrate parts use random offsets within spawnRadius from origin.
-- @param template    table
-- @param systemParts table  name → { found, required, NoCrate, amount, ... }
-- @param origin      vec3   reference spawn point (from _computeOrigin)
-- @param heli        Unit   used to get heading for NoCrate offset direction
-- @return positions[], types[], headings[]
function CTLDCrateAssemblyManager:_buildSpawnArrays(template, systemParts, origin, heli)
    local positions = {}
    local types     = {}
    local headings  = {}

    local aaLaunchers  = ctld.gs("aaLaunchers") or 3
    local stacking     = ctld.gs("AASystemCrateStacking") or false
    local arcRad       = math.pi * 2
    -- Distribute each template part across equal arc segments so parts
    -- don't pile up on each other.  Index tracks arc offset per call.
    local partIndex    = 0
    local partCount    = #template.parts

    for _, part in ipairs(template.parts) do
        local sp = systemParts[part.name]

        -- Compute amountFactor (stacking multiplier)
        local amountFactor = 1
        if stacking and not sp.NoCrate and sp.required > 0 then
            amountFactor = sp.found - (sp.found % sp.required)
            if amountFactor < 1 then amountFactor = 1 end
        end

        -- Compute partAmount
        local partAmount = 1
        if part.amount then
            partAmount = part.amount
        elseif part.launcher then
            partAmount = aaLaunchers
        end
        partAmount = partAmount * amountFactor

        -- Arc base for this part (evenly spaced around circle)
        local arcBase = (arcRad / partCount) * partIndex

        if partAmount == 1 then
            local angle = arcBase
            local px = origin.x + math.cos(angle) * _SPAWN_RADIUS
            local pz = origin.z + math.sin(angle) * _SPAWN_RADIUS
            local py = land.getHeight({ x = px, y = pz })
            table.insert(positions, { x = px, y = py, z = pz })
            table.insert(types,     part.name)
            table.insert(headings,  angle)
        else
            local step = arcRad / partAmount
            for i = 1, partAmount do
                local angle = ((step * (i - 1)) + arcBase) % arcRad
                local px = origin.x + math.cos(angle) * _SPAWN_RADIUS
                local pz = origin.z + math.sin(angle) * _SPAWN_RADIUS
                local py = land.getHeight({ x = px, y = pz })
                table.insert(positions, { x = px, y = py, z = pz })
                table.insert(types,     part.name)
                table.insert(headings,  angle)
            end
        end

        partIndex = partIndex + 1
    end

    return positions, types, headings
end

--- Spawn a multi-unit ground group via dynAdd.
-- @param heli      Unit    used for country and coalition
-- @param positions array   vec3 per unit
-- @param types     array   DCS type name per unit
-- @param headings  array   radians per unit
-- @return DCS Group or nil
function CTLDCrateAssemblyManager:_spawnGroup(heli, positions, types, headings)
    if #positions == 0 then return nil end

    local baseName  = types[1] .. "_CTLD_AA_" .. tostring(math.floor(timer.getAbsTime()))
    local groupData = {
        visible  = false,
        hidden   = false,
        category = Group.Category.GROUND,
        country  = heli:getCountry(),
        name     = baseName,
        task     = {},
        units    = {},
    }

    for i, pos in ipairs(positions) do
        local hdg = headings[i] or 0
        groupData.units[i] = {
            type           = types[i],
            name           = string.format("CTLD_AA_%s_%d", types[i]:gsub("[%s/\\]", "_"), i),
            x              = pos.x,
            y              = pos.z,   -- dynAdd convention: y == world Z
            heading        = hdg,
            skill          = "High",
            playerCanDrive = false,
        }
    end

    local result = ctld.utils.dynAdd("CTLDCrateAssemblyManager:_spawnGroup", groupData)
    if not result then return nil end
    return Group.getByName(result.name)
end
