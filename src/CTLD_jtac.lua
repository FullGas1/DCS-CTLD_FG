-- ============================================================
-- CTLD_jtac.lua
-- CTLDJTAC entity + CTLDJTACDetector helpers + CTLDJTACManager singleton
--
-- Dependencies : CTLDConfig (ctld.gs), CTLDUtils, EventDispatcher
-- DCS API      : coalition.addGroup, Group, Unit, Spot, land, world,
--                atmosphere, trigger.action, timer
--
-- JTAC is a feature, not a unit type. It applies to:
--   - ground infantry  (loadable group with jtac=N soldier)
--   - ground vehicle   (crate descriptor with jtac=true)
--   - flying AI drone  (crate descriptor with jtac=true, isFlying=true)
--
-- JTAC lifecycle states:
--   idle       : spawned, no target acquired
--   lasing     : actively lasing a target
--   orbiting   : flying JTAC orbiting a target (implies lasing)
--   in_transit : ground JTAC embarked in a transport
--   dead       : unit destroyed
--
-- Detection: crate descriptor.jtac == true   (no separate jtacUnitTypes table)
-- Laser pool: sequential 1111–1688 (assigned on spawn, freed on death)
-- Timings   : JTAC_laseIntervalSeconds / JTAC_searchIntervalSeconds (config)
-- DCS bug   : coalition.addGroup leaves group empty for ~1s →
--             first _autoLaseLoop is delayed +1s (preserved from source)
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDJTAC  (entity)
-- ============================================================

CTLDJTAC = class()

CTLDJTAC.STATE = {
    IDLE       = "idle",
    LASING     = "lasing",
    ORBITING   = "orbiting",
    IN_TRANSIT = "in_transit",
    DEAD       = "dead",
}

-- Reasons passed to stopLase() and _stopLaseAndPublish()
CTLDJTAC.STOP_REASON = {
    TARGET_LOST   = "target_lost",
    TARGET_DESTROYED = "target_destroyed",
    STANDBY_MODE  = "standby_mode",
    IN_TRANSIT    = "jtac_in_transit",
    DEAD          = "jtac_dead",
}

-- Lock mode values (mirrors JTAC_lock config)
CTLDJTAC.LOCK_MODE = {
    ALL     = "all",
    VEHICLE = "vehicle",
    TROOP   = "troop",
}

--- Constructor.
-- @param data table:
--   groupName    (string)   DCS group name
--   laserCode    (number)   assigned laser code (1111-1688)
--   isFlying     (boolean)  drone/aircraft vs ground
--   isInfantry   (boolean)  infantry vs vehicle (ground only)
--   coalitionId  (number)   coalition.side.*
--   smokeEnabled (boolean)  auto-smoke on target
--   smokeColor   (number)   trigger.smokeColor.*
--   lockMode     (string)   "all" | "vehicle" | "troop"
function CTLDJTAC:init(data)
    self.groupName    = data.groupName
    self.laserCode    = data.laserCode
    self.isFlying     = data.isFlying    or false
    self.isInfantry   = data.isInfantry  or false
    self.coalitionId  = data.coalitionId
    self.smokeEnabled = data.smokeEnabled or false
    self.smokeColor   = data.smokeColor  or trigger.smokeColor.Red
    self.lockMode     = data.lockMode    or "all"
    self.state        = CTLDJTAC.STATE.IDLE

    self.radio = CTLDJTACDetector.calculateFMRadio(data.groupName, data.laserCode)

    self.currentTarget  = nil   -- { unitName, unitType, unitId, position, laseStartTime }
    self.laserSpot      = nil
    self.irSpot         = nil

    -- Flying JTACs only: route stored before first orbit task (used to restore on orbit stop)
    self.initialRoute   = nil
    self.orbitStartTime = nil

    -- Target selection (1 = auto mode, string = manually selected unitName)
    self.selectedTarget = 1

    -- Per-JTAC special options (toggled via F10 menu)
    self.standbyMode         = false
    self.laseSpotCorrections = false
end

--- Begin lasing a new target.
-- @param target    table  { dcsUnit, unitName, unitType, unitId, position }
-- @param laserSpot DCS Spot object (laser)
-- @param irSpot    DCS Spot object (IR)
function CTLDJTAC:startLase(target, laserSpot, irSpot)
    self.currentTarget = {
        unitName      = target.unitName,
        unitType      = target.unitType,
        unitId        = target.unitId,
        position      = target.position,
        laseStartTime = timer.getAbsTime(),
    }
    self.laserSpot = laserSpot
    self.irSpot    = irSpot
    -- Keep ORBITING state if already orbiting; otherwise go LASING
    if self.state ~= CTLDJTAC.STATE.ORBITING then
        self.state = CTLDJTAC.STATE.LASING
    end
end

--- Stop lasing and destroy DCS spots.
-- @param reason string  CTLDJTAC.STOP_REASON.*
function CTLDJTAC:stopLase(reason)
    if self.laserSpot then self.laserSpot:destroy(); self.laserSpot = nil end
    if self.irSpot    then self.irSpot:destroy();    self.irSpot    = nil end
    self.currentTarget = nil
    -- Keep ORBITING state intact — _orbitLoop handles the ORBITING→IDLE transition
    if self.state == CTLDJTAC.STATE.LASING then
        self.state = CTLDJTAC.STATE.IDLE
    end
end

--- Update laser/IR spot position (moving target).
-- @param targetPos table {x, y, z}
function CTLDJTAC:updateLaseSpot(targetPos)
    if self.laserSpot then self.laserSpot:setPoint(targetPos) end
    if self.irSpot    then self.irSpot:setPoint(targetPos)    end
    if self.currentTarget then
        self.currentTarget.position = targetPos
    end
end

--- Flying JTAC: begin orbiting.
-- @param t number  timer.getTime() at orbit start
function CTLDJTAC:startOrbit(t)
    self.state        = CTLDJTAC.STATE.ORBITING
    self.orbitStartTime = t or timer.getTime()
end

--- Flying JTAC: stop orbiting, return to IDLE.
function CTLDJTAC:stopOrbit()
    self.state          = CTLDJTAC.STATE.IDLE
    self.orbitStartTime = nil
end

--- Ground JTAC: mark as embarked in a transport.
function CTLDJTAC:setInTransit()
    self:stopLase(CTLDJTAC.STOP_REASON.IN_TRANSIT)
    self.state = CTLDJTAC.STATE.IN_TRANSIT
end

--- Mark JTAC as dead and clean up spots.
function CTLDJTAC:kill()
    self:stopLase(CTLDJTAC.STOP_REASON.DEAD)
    self.state = CTLDJTAC.STATE.DEAD
end

--- Destroy DCS group + spots.
function CTLDJTAC:destroy()
    self:stopLase(CTLDJTAC.STOP_REASON.DEAD)
    local g = Group.getByName(self.groupName)
    if g then g:destroy() end
end


-- ============================================================
-- CTLDJTACDetector  (static helpers — no instance)
-- ============================================================

CTLDJTACDetector = {}

--- Compute FM radio frequency from laser code.
-- Formula from CTLD_jtac.lua source (ctld.JTACAutoLase, lines 72-74):
--   freq = 30 + floor((code-1000)/100) + ((code-1000) mod 100) * 0.05
-- Range: laser 1111–1688 → FM ~31.5–40.4 MHz
-- @param groupName string
-- @param laserCode number
-- @return table { name, freq (string MHz), mod } or nil
function CTLDJTACDetector.calculateFMRadio(groupName, laserCode)
    local code = tonumber(laserCode)
    if not code or code < 1111 or code > 1688 then return nil end
    local laserB  = math.floor((code - 1000) / 100)
    local laserCD = code - 1000 - laserB * 100
    local freq    = tostring(30 + laserB + laserCD * 0.05)
    return { name = groupName, freq = freq, mod = "fm" }
end

--- Find the nearest visible enemy for a JTAC unit.
-- Uses world.searchObjects (sphere) + land.isVisible (LOS, +2m Y offset).
-- Prioritises: hpriority > priority > Air Defence > standard; ties broken by distance.
-- API: world.searchObjects — verified Hoggit 2026-04-01
-- API: land.isVisible      — verified CTLD_jtac.lua source
-- @param jtacUnit    DCS Unit object
-- @param lockMode    string  "all" | "vehicle" | "troop"
-- @param maxDistance number  metres
-- @return table or nil  { dcsUnit, unitName, unitType, unitId, position, priority, distance }
function CTLDJTACDetector.findNearestVisibleEnemy(jtacUnit, lockMode, maxDistance)
    if not jtacUnit or not jtacUnit:isExist() then return nil end

    local jtacPos  = jtacUnit:getPoint()
    local jtacCoal = jtacUnit:getCoalition()
    local offsetA  = { x = jtacPos.x, y = jtacPos.y + 2, z = jtacPos.z }

    -- Track best candidate inline (O(n)) — no sort needed, only one result is used.
    local best = nil

    world.searchObjects(
        Object.Category.UNIT,
        { id = world.VolumeType.SPHERE, params = { point = jtacPos, radius = maxDistance } },
        function(unit, _)
            if unit:getCoalition() == jtacCoal then return true end
            if not unit:isExist() or unit:getLife() <= 1 then return true end

            local attrs      = unit:getDesc().attributes or {}
            local isVehicle  = attrs["Vehicles"] == true or attrs["Armored vehicles"] == true
            local isInfantry = attrs["Infantry"] == true
            if lockMode == CTLDJTAC.LOCK_MODE.VEHICLE and not isVehicle  then return true end
            if lockMode == CTLDJTAC.LOCK_MODE.TROOP   and not isInfantry then return true end

            -- LOS check (+2m height offset — avoids terrain/hull occlusion at ground level)
            local unitPos = unit:getPoint()
            local offsetB = { x = unitPos.x, y = unitPos.y + 2, z = unitPos.z }
            if not land.isVisible(offsetA, offsetB) then return true end

            local dist = ctld.utils.getDistance("CTLDJTACDetector.findNearestVisibleEnemy", jtacPos, unitPos)

            -- Priority: hpriority(1) > priority(2) > Air Defence(3) > standard(4)
            local name     = unit:getName()
            local typeName = unit:getTypeName()
            local priority
            if string.find(name, "hpriority") or string.find(typeName, "hpriority") then
                priority = 1
            elseif string.find(name, "priority") or string.find(typeName, "priority") then
                priority = 2
            elseif attrs["Air Defence"] == true then
                priority = 3
            else
                priority = 4
            end

            if not best
                or priority < best.priority
                or (priority == best.priority and dist < best.distance)
            then
                best = {
                    dcsUnit  = unit,
                    unitName = name,
                    unitType = typeName,
                    unitId   = unit:getID(),
                    position = unitPos,
                    priority = priority,
                    distance = dist,
                }
            end
            return true
        end,
        nil
    )

    return best
end

--- Line-of-sight check (convenience wrapper).
-- API: land.isVisible — verified CTLD_jtac.lua source
-- @param posA table {x,y,z}
-- @param posB table {x,y,z}
-- @return boolean
function CTLDJTACDetector.checkLOS(posA, posB)
    return land.isVisible(posA, posB)
end

--- Compute predictive laser-spot correction for a moving target.
-- Compensates target velocity (+1.0s anticipation) and wind (-1.05s).
-- API: atmosphere.getWind — verified CTLD_jtac.lua source
-- @param targetPos      table {x,y,z}
-- @param targetVelocity table {x,y,z}  Unit:getVelocity()
-- @param wind           table {x,y,z}  atmosphere.getWind(pos)
-- @return table {x,y,z}
function CTLDJTACDetector.calculateCorrectedSpot(targetPos, targetVelocity, wind)
    return {
        x = targetPos.x + targetVelocity.x * 1.0 - wind.x * 1.05,
        y = targetPos.y,
        z = targetPos.z + targetVelocity.z * 1.0 - wind.z * 1.05,
    }
end


-- ============================================================
-- CTLDJTACMessage  (static — message builder)
-- ============================================================

CTLDJTACMessage = {}

--- Build short + full notification strings from a structured context.
-- All i18n calls are co-located here. No message logic elsewhere.
--
-- Supported events:
--   "new_target"        JTAC locks a new target
--   "target_reacquired" manually-selected target back in LOS
--   "target_lost"       target alive but LOS broken
--   "target_destroyed"  target confirmed dead
--   "kia"               JTAC unit destroyed
--   "no_targets"        search loop found nothing (optional use)
--
-- @param ctx table:
--   event       (string)       one of the events above
--   jtacName    (string)       JTAC group name
--   targetType  (string|nil)   DCS typeName of target
--   laserCode   (number|nil)   assigned laser code
--   positionStr (string|nil)   pre-formatted MGRS/DMS string
--   wasSelected (boolean)      target was manually selected by player
--   standby     (boolean)      standby mode active (laser off)
--
-- @return table { short (string), full (string) }
--   short : concise, suitable for SRS read-out (no coords)
--   full  : detailed, displayed on screen (includes code + position)
function CTLDJTACMessage.build(ctx)
    local name  = ctx.jtacName   or "JTAC"
    local ttype = ctx.targetType or ctld.i18n_translate("unknown")
    local code  = ctx.laserCode  and tostring(ctx.laserCode) or ctld.i18n_translate("UNKNOWN")
    local pos   = ctx.positionStr or ""

    local codePosStr = ctld.i18n_translate(". CODE: %1. POSITION: %2", code, pos)

    local short, full

    if ctx.event == "new_target" then
        local verb = ctx.standby
            and ctld.i18n_translate("standing by on")
            or  ctld.i18n_translate("lasing")
        if ctx.wasSelected then
            short = ctld.i18n_translate("%1, selected %2 %3", name, verb, ttype)
        else
            short = ctld.i18n_translate("%1, %2 new target, %3", name, verb, ttype)
        end
        full = short .. codePosStr

    elseif ctx.event == "target_reacquired" then
        short = ctld.i18n_translate("%1, selected target reacquired, %2", name, ttype)
        full  = short .. codePosStr

    elseif ctx.event == "target_lost" then
        if ctx.wasSelected then
            short = ctld.i18n_translate("%1, selected target lost, temporarily lasing %2", name, ttype)
        else
            short = ctld.i18n_translate("%1, target lost.", name)
        end
        full = short

    elseif ctx.event == "target_destroyed" then
        if ctx.wasSelected then
            short = ctld.i18n_translate("%1, selected target destroyed.", name)
        else
            short = ctld.i18n_translate("%1, target destroyed.", name)
        end
        full = short

    elseif ctx.event == "kia" then
        short = ctld.i18n_translate("JTAC %1 KIA!", name)
        full  = short

    elseif ctx.event == "no_targets" then
        short = ctld.i18n_translate("%1, no targets in range.", name)
        full  = short

    else
        short = name .. " " .. tostring(ctx.event)
        full  = short
    end

    return { short = short, full = full }
end


-- ============================================================
-- CTLDJTACManager  (singleton)
-- ============================================================

CTLDJTACManager = class()
CTLDJTACManager._instance = nil

--- Return (or create) the singleton instance.
function CTLDJTACManager.get()
    if not CTLDJTACManager._instance then
        local o          = setmetatable({}, CTLDJTACManager)
        o.jtacs          = {}
        o._laserPool     = {}
        o._pendingJTACs  = {}
        o._orbitScheduleId = nil
        o:_initLaserPool()
        CTLDJTACManager._instance = o
        CTLDPlayerManager.getInstance():registerMenuSection({
            key       = "jtac",
            manager   = o,
            method    = "buildMenuSection",
            configKey = "JTAC_jtacStatusF10",
            order     = 90,
        })
    end
    return CTLDJTACManager._instance
end

--- Spawn a JTAC from an unpacked crate.
-- The DCS group must already exist in the world (spawned by CTLDCrateManager).
-- DCS bug workaround: first _autoLaseLoop is delayed +1s (group units empty on spawn).
-- @param groupName string   DCS group name
-- @param cfg       table    { laserCode, smokeEnabled, smokeColor, lockMode }  (all optional)
-- @param spawner   table    { playerName, unitName, unitId, coalition }
-- @return CTLDJTAC or nil
function CTLDJTACManager:spawnJTAC(groupName, cfg, spawner)
    local dcsGroup = Group.getByName(groupName)
    if not dcsGroup then
        ctld.logError("CTLDJTACManager:spawnJTAC — group not found: " .. tostring(groupName))
        return nil
    end

    -- Resolve or assign laser code
    local laserCode = cfg and cfg.laserCode
    if not laserCode then
        laserCode = self:_assignLaserCode()
    end
    if not laserCode then
        ctld.logError("CTLDJTACManager:spawnJTAC — laser code pool exhausted")
        return nil
    end

    local coalitionId = dcsGroup:getCoalition()

    -- Unit may be nil for ~1s after spawn (DCS bug); classify defensively
    local dcsUnit    = dcsGroup:getUnits()[1]
    local isFlying   = false
    local isInfantry = false
    if dcsUnit then
        local attrs  = dcsUnit:getDesc().attributes or {}
        isFlying     = attrs["Planes"] == true or attrs["Helicopters"] == true
        isInfantry   = attrs["Infantry"] == true
    end

    -- Explicit false from caller must not be overridden by config (boolean or-pattern trap)
    local smokeEnabled
    if cfg and cfg.smokeEnabled ~= nil then
        smokeEnabled = cfg.smokeEnabled
    elseif coalitionId == coalition.side.RED then
        smokeEnabled = ctld.gs("JTAC_smokeOn_RED") or false
    else
        smokeEnabled = ctld.gs("JTAC_smokeOn_BLUE") or false
    end
    local smokeColor
    if cfg and cfg.smokeColor ~= nil then
        smokeColor = cfg.smokeColor
    elseif coalitionId == coalition.side.RED then
        smokeColor = ctld.gs("JTAC_smokeColour_RED") or trigger.smokeColor.Red
    else
        smokeColor = ctld.gs("JTAC_smokeColour_BLUE") or trigger.smokeColor.Red
    end
    local lockMode = (cfg and cfg.lockMode) or ctld.gs("JTAC_lock") or "all"

    local jtac = CTLDJTAC:new({
        groupName    = groupName,
        laserCode    = laserCode,
        isFlying     = isFlying,
        isInfantry   = isInfantry,
        coalitionId  = coalitionId,
        smokeEnabled = smokeEnabled,
        smokeColor   = smokeColor,
        lockMode     = lockMode,
    })

    -- Store initial flight route for flying JTACs (before any orbit task replaces it).
    -- Used by _orbitLoop to restore route when orbit ends.
    -- Controller:getTask() is not guaranteed by the DCS API; pcall to avoid crash.
    if isFlying then
        local ctrl = dcsGroup:getController()
        if ctrl then
            local ok2, task = pcall(function() return ctrl:getTask() end)
            if ok2 and task then jtac.initialRoute = task end
        end
    end

    self.jtacs[groupName] = jtac

    -- Start the shared orbit loop on first flying JTAC
    if isFlying and not self._orbitScheduleId then
        self._orbitScheduleId = timer.scheduleFunction(
            function(_, t) return CTLDJTACManager.get():_orbitLoop(t) end,
            nil,
            timer.getTime() + 3
        )
    end

    -- DCS spawn bug: delay first auto-lase loop by 1s so group:getUnits()[1] is populated
    timer.scheduleFunction(
        function(gn, t) return CTLDJTACManager.get():_autoLaseLoop(gn, t) end,
        groupName,
        timer.getTime() + 1
    )

    -- Publish event (dcsUnit may be nil within the 1s DCS spawn window — acceptable)
    self:_publishEvent("OnJTACSpawned", {
        jtac = {
            groupName  = groupName,
            groupId    = dcsGroup:getID(),
            unitName   = dcsUnit and dcsUnit:getName()    or groupName,
            unitId     = dcsUnit and dcsUnit:getID()      or nil,
            unitType   = dcsUnit and dcsUnit:getTypeName() or nil,
            coalition  = coalitionId,
            position   = dcsUnit and dcsUnit:getPoint()   or nil,
            isFlying   = isFlying,
            isInfantry = isInfantry,
            route      = jtac.initialRoute,
        },
        spawner      = spawner,
        laserCode    = laserCode,
        smokeEnabled = smokeEnabled,
        smokeColor   = smokeColor,
        lockMode     = lockMode,
        radio        = jtac.radio,
        timestamp    = timer.getAbsTime(),
    })

    return jtac
end

--- Get a JTAC entity by DCS group name.
-- @param groupName string
-- @return CTLDJTAC or nil
function CTLDJTACManager:getJTACByName(groupName)
    return self.jtacs[groupName]
end

--- Mark a ground JTAC as in-transit (called by CTLDTroopManager / CTLDVehicleSpawner).
-- @param groupName string   JTAC group name
-- @param transport table    { unitName, playerName }
function CTLDJTACManager:setJTACInTransit(groupName, transport)
    local jtac = self.jtacs[groupName]
    if not jtac or jtac.state == CTLDJTAC.STATE.DEAD then return end

    jtac:setInTransit()

    self:_publishEvent("OnJTACInTransit", {
        jtac      = { groupName = groupName, coalition = jtac.coalitionId },
        transport = transport,
        timestamp = timer.getAbsTime(),
    })
end

--- Smoke current target on demand (F10 menu action).
-- Applies JTAC_smokeMarginOfError offset.
-- @param groupName string
function CTLDJTACManager:requestSmoke(groupName)
    local jtac = self.jtacs[groupName]
    if not jtac or not jtac.currentTarget then return end

    local targetPos = jtac.currentTarget.position
    local margin    = ctld.gs("JTAC_smokeMarginOfError") or 50
    local smokePos  = {
        x = targetPos.x + math.random(-margin, margin),
        y = targetPos.y + (ctld.gs("JTAC_smokeOffset_y") or 2),
        z = targetPos.z + math.random(-margin, margin),
    }

    trigger.action.smoke(smokePos, jtac.smokeColor)

    self:_publishEvent("OnJTACSmokeTarget", {
        jtac          = { groupName = groupName, coalition = jtac.coalitionId },
        target        = { unitName = jtac.currentTarget.unitName, position = targetPos },
        smokePosition = smokePos,
        smokeColor    = jtac.smokeColor,
        timestamp     = timer.getAbsTime(),
    })
end

--- Called when a JTAC unit is destroyed (routed from CTLDDCSEventBridge / S_EVENT_DEAD).
-- @param groupName string
-- @param killer    table or nil  { unitName, playerName }
function CTLDJTACManager:killJTAC(groupName, killer)
    local jtac = self.jtacs[groupName]
    if not jtac then return end

    local lastTarget = jtac.currentTarget
    jtac:kill()

    local kiaMsg = CTLDJTACMessage.build({ event = "kia", jtacName = groupName })
    ctld.notifyCoalition(kiaMsg.full, 10, jtac.coalitionId, jtac.radio, kiaMsg.short)

    self:_publishEvent("OnJTACDead", {
        jtac = {
            groupName = groupName,
            coalition = jtac.coalitionId,
            laserCode = jtac.laserCode,
        },
        killer      = killer,
        lastTarget  = lastTarget,
        timestamp   = timer.getAbsTime(),
    })

    self:_freeLaserCode(jtac.laserCode)
    self.jtacs[groupName] = nil
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Build the DCS group definition for a flying JTAC (orbit + EPLRS route).
-- Pure builder: no spawn, no side-effects.
-- @param descriptor table  crate descriptor (reads .unit, .spawnAs)
-- @param position   vec3   spawn position {x, y, z}
-- @param gname      string group name (pre-allocated by caller)
-- @param gid        number DCS group id (pre-allocated by caller)
-- @param uid        number DCS unit id (pre-allocated by caller)
-- @return table  unitDef ready for ctld.utils.spawnFromDescriptor
function CTLDJTACManager:_buildAirUnitDef(descriptor, position, gname, gid, uid)
    local uname = gname .. "_1"
    local alt   = ctld.gs("jtacDroneAltitude") or 4000
    local speed = 54  -- m/s (~105 kts)
    return {
        ["name"]          = gname,
        ["groupId"]       = gid,
        ["communication"] = true,
        ["frequency"]     = 124,
        ["visible"]       = false,
        ["hidden"]        = false,
        ["start_time"]    = 0,
        ["task"]          = "Ground Nothing",
        ["x"]             = position.x,
        ["y"]             = position.z,
        ["units"] = {
            [1] = {
                ["type"]     = descriptor.unit,
                ["name"]     = uname,
                ["unitId"]   = uid,
                ["x"]        = position.x,
                ["y"]        = position.z,
                ["heading"]  = 0,
                ["alt"]      = alt,
                ["alt_type"] = "RADIO",
                ["speed"]    = speed,
                ["skill"]    = "Excellent",
            },
        },
        ["route"] = {
            ["points"] = {
                [1] = {
                    ["alt"]                = alt,
                    ["alt_type"]           = "RADIO",
                    ["action"]             = "Turning Point",
                    ["type"]               = "Turning Point",
                    ["speed"]              = speed,
                    ["ETA"]                = 0,
                    ["ETA_locked"]         = true,
                    ["speed_locked"]       = true,
                    ["formation_template"] = "",
                    ["properties"]         = { ["addopt"] = {} },
                    ["x"]                  = position.x,
                    ["y"]                  = position.z,
                    ["task"] = {
                        ["id"]     = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["number"]  = 1,
                                    ["auto"]    = true,
                                    ["id"]      = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"]  = {
                                        ["action"] = {
                                            ["id"]     = "EPLRS",
                                            ["params"] = {
                                                ["value"]   = true,
                                                ["groupId"] = gid,
                                            },
                                        },
                                    },
                                },
                                [2] = {
                                    ["number"]  = 2,
                                    ["auto"]    = false,
                                    ["id"]      = "Orbit",
                                    ["enabled"] = true,
                                    ["params"]  = {
                                        ["altitude"] = alt,
                                        ["pattern"]  = "Circle",
                                        ["speed"]    = speed,
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    }
end

--- Spawn a flying JTAC from an unpacked crate and start auto-lase.
-- Orchestrates: _buildAirUnitDef → spawnFromDescriptor → startLase.
-- Can also be called from legacy DO SCRIPT (ctld.JTACAutoLase wrapper path).
-- @param transport  Unit    transport unit (player helicopter)
-- @param position   vec3    horizontal spawn position {x, y, z} (y = ground level)
-- @param descriptor table   crate descriptor { unit, spawnAs, isJTAC, ... }
-- @param countryId  number  country.id.*
-- @return boolean  true if spawn succeeded
function CTLDJTACManager:deployAirJTAC(transport, position, descriptor, countryId)
    if not (ctld.gs("JTAC_dropEnabled") ~= false) then
        ctld.utils.log("INFO", "CTLDJTACManager:deployAirJTAC — JTAC_dropEnabled=false, skipped")
        return false
    end
    local gid   = ctld.utils.getNextUniqId()
    local uid   = ctld.utils.getNextUniqId()
    local gname = string.format("CTLD_JTAC_AIR_%d", gid)
    local unitDef = self:_buildAirUnitDef(descriptor, position, gname, gid, uid)
    local cId = countryId or country.id.USA
    -- Default spawnAs to "AIRPLANE" when field absent (legacy compat)
    local spawnDesc = descriptor.spawnAs and descriptor or { spawnAs = "AIRPLANE", unit = descriptor.unit }
    local ok, err = ctld.utils.spawnFromDescriptor(spawnDesc, cId, unitDef)
    if not ok then
        local errStr = type(err) == "table" and ctld.utils.p(err) or tostring(err)
        ctld.utils.log("WARNING",
            "CTLDJTACManager:deployAirJTAC — spawnFromDescriptor failed: " .. errStr)
        return false
    end
    self:startLase(gname)
    ctld.utils.log("INFO",
        string.format("CTLDJTACManager:deployAirJTAC — spawned %s as %s spawnAs=%s alt=%dm",
            gname, descriptor.unit, descriptor.spawnAs or "AIRPLANE",
            ctld.gs("jtacDroneAltitude") or 4000))
    return true
end

--- Activate auto-lase for an existing DCS JTAC group (MM DO SCRIPT).
-- Equivalent to legacy ctld.JTACAutoLase(). Wraps spawnJTAC with converted params.
-- @param groupName string   DCS group name
-- @param laserCode number   laser code 1111-1688 (nil = auto-assigned)
-- @param smoke     boolean  enable smoke on target
-- @param lock      string   "all" | "vehicle" | "troop" (nil = "all")
-- @param colour    number   trigger.smokeColor.* (nil = Red)
-- @param radio     table    { freq, mod, name } (nil = auto)
-- @return CTLDJTAC|nil
function CTLDJTACManager:autoLase(groupName, laserCode, smoke, lock, colour, radio)
    if self.jtacs[groupName] then
        ctld.utils.log("WARN", "CTLDJTACManager:autoLase — JTAC already active: %s", groupName)
        return self.jtacs[groupName]
    end
    local cfg = {
        laserCode    = laserCode and tonumber(laserCode) or nil,
        smokeEnabled = smoke == true,
        lockMode     = (lock == "vehicle" or lock == "troop") and lock or "all",
        smokeColor   = colour or trigger.smokeColor.Red,
        radio        = radio,
    }
    return self:spawnJTAC(groupName, cfg, nil)
end

--- Activate auto-lase with a 1-second delay (legacy ctld.JTACStart behaviour).
-- @param groupName string
-- @param laserCode number
-- @param smoke     boolean
-- @param lock      string
-- @param colour    number
-- @param radio     table
function CTLDJTACManager:startLase(groupName, laserCode, smoke, lock, colour, radio)
    timer.scheduleFunction(
        function(args, t)
            CTLDJTACManager.get():autoLase(
                args[1], args[2], args[3], args[4], args[5], args[6])
        end,
        { groupName, laserCode, smoke, lock, colour, radio },
        timer.getTime() + 1
    )
end

--- Stop auto-lase for a JTAC group without firing the Dead event.
-- Sets the JTAC to standby mode; the auto-lase loop will stop lasing and idle.
-- @param groupName string
function CTLDJTACManager:stopAutoLase(groupName)
    local jtac = self.jtacs[groupName]
    if not jtac then
        ctld.utils.log("WARN", "CTLDJTACManager:stopAutoLase — JTAC not found: %s", tostring(groupName))
        return
    end
    jtac.standbyMode = true
    ctld.utils.log("INFO", "CTLDJTACManager:stopAutoLase — '%s' set to standby", groupName)
end

--- Destroy all active JTACs and reset state.
function CTLDJTACManager:cleanup()
    for _, jtac in pairs(self.jtacs) do
        jtac:destroy()
    end
    self.jtacs      = {}
    self._laserPool = {}
    self:_initLaserPool()
    self._orbitScheduleId = nil
end


-- ──────────────────────────────────────────────────
-- Private
-- ──────────────────────────────────────────────────

--- Main auto-lase loop for one JTAC. Self-rescheduling via timer.scheduleFunction.
-- Interval: JTAC_laseIntervalSeconds when lasing, JTAC_searchIntervalSeconds when searching.
-- @param groupName string
-- @param t         number  timer.getTime() at call time (provided by scheduleFunction)
-- @return number or nil    next schedule time (nil stops the loop)
function CTLDJTACManager:_autoLaseLoop(groupName, t)
    local jtac = self.jtacs[groupName]
    if not jtac then return nil end
    if jtac.state == CTLDJTAC.STATE.DEAD then return nil end

    -- Verify group still alive
    local dcsGroup = Group.getByName(groupName)
    if not dcsGroup or not dcsGroup:isExist() then
        self:killJTAC(groupName, nil)
        return nil
    end

    local jtacUnit = dcsGroup:getUnits()[1]
    if not jtacUnit or not jtacUnit:isExist() then
        -- Unit gone but group still reported alive — treat as dead
        self:killJTAC(groupName, nil)
        return nil
    end

    local searchInterval = ctld.gs("JTAC_searchIntervalSeconds")
    local laseInterval   = ctld.gs("JTAC_laseIntervalSeconds")

    -- Standby mode: stop lasing if active, wait
    if jtac.standbyMode then
        if jtac.currentTarget then
            self:_stopLaseAndPublish(jtac, CTLDJTAC.STOP_REASON.STANDBY_MODE)
        end
        return t + searchInterval
    end

    -- In transit: no lasing
    if jtac.state == CTLDJTAC.STATE.IN_TRANSIT then
        return t + searchInterval
    end

    -- ── Check existing target ──────────────────────────────────
    if jtac.currentTarget then
        local targetUnit = Unit.getByName(jtac.currentTarget.unitName)

        -- Target destroyed?
        if not targetUnit or not targetUnit:isExist() or targetUnit:getLife() <= 1 then
            self:_stopLaseAndPublish(jtac, CTLDJTAC.STOP_REASON.TARGET_DESTROYED)
            -- Fall through to search below
        else
            -- LOS still valid?
            local jtacPos   = jtacUnit:getPoint()
            local targetPos = targetUnit:getPoint()
            local offsetA   = { x = jtacPos.x,   y = jtacPos.y   + 2, z = jtacPos.z   }
            local offsetB   = { x = targetPos.x, y = targetPos.y + 2, z = targetPos.z }

            if not CTLDJTACDetector.checkLOS(offsetA, offsetB) then
                self:_stopLaseAndPublish(jtac, CTLDJTAC.STOP_REASON.TARGET_LOST)
                -- Fall through to search below
            else
                -- Target still valid — update spot position
                local correctedPos = targetPos
                if jtac.laseSpotCorrections then
                    local vel  = targetUnit:getVelocity()
                    local wind = atmosphere.getWind(targetPos)
                    correctedPos = CTLDJTACDetector.calculateCorrectedSpot(targetPos, vel, wind)
                end
                jtac:updateLaseSpot(correctedPos)

                self:_publishEvent("OnJTACTargetLased", {
                    jtac   = { groupName = groupName, unitName = jtacUnit:getName(), coalition = jtac.coalitionId },
                    target = { unitName = jtac.currentTarget.unitName, position = correctedPos },
                    laserCode = jtac.laserCode,
                    timestamp = timer.getAbsTime(),
                })
                return t + laseInterval
            end
        end
    end

    -- ── Search for new target ──────────────────────────────────
    local found = CTLDJTACDetector.findNearestVisibleEnemy(
        jtacUnit,
        jtac.lockMode,
        ctld.gs("JTAC_maxDistance")
    )

    if not found then
        return t + searchInterval
    end

    -- Stop ground unit movement while lasing
    -- API: trigger.action.groupStopMoving — verified CTLD_jtac.lua source
    if not jtac.isFlying then
        trigger.action.groupStopMoving(dcsGroup)
    end

    -- Compute lase position (with correction if enabled)
    local lasePos = found.position
    if jtac.laseSpotCorrections then
        local vel  = found.dcsUnit:getVelocity()
        local wind = atmosphere.getWind(found.position)
        lasePos = CTLDJTACDetector.calculateCorrectedSpot(found.position, vel, wind)
    end

    -- Create DCS Spot objects
    -- API: Spot.createLaser, Spot.createInfraRed — verified CTLD_jtac.lua source
    local spotOffset = { x = 0, y = 2, z = 0 }
    local laserSpot  = Spot.createLaser(jtacUnit, spotOffset, lasePos, jtac.laserCode)
    local irSpot     = Spot.createInfraRed(jtacUnit, spotOffset, lasePos)

    jtac:startLase(found, laserSpot, irSpot)

    -- Auto-smoke on target
    if jtac.smokeEnabled then
        trigger.action.smoke(lasePos, jtac.smokeColor)
    end

    -- Build and send player notification
    local msg = CTLDJTACMessage.build({
        event       = "new_target",
        jtacName    = groupName,
        targetType  = found.unitType,
        laserCode   = jtac.laserCode,
        positionStr = ctld.getPositionString(found.dcsUnit),
        wasSelected = (jtac.selectedTarget == found.unitName),
        standby     = jtac.standbyMode,
    })
    ctld.notifyCoalition(msg.full, 10, jtac.coalitionId, jtac.radio, msg.short)

    self:_publishEvent("OnJTACLaseStart", {
        jtac = {
            groupName = groupName,
            unitName  = jtacUnit:getName(),
            position  = jtacUnit:getPoint(),
            coalition = jtac.coalitionId,
        },
        target = {
            unitName            = found.unitName,
            unitId              = found.unitId,
            unitType            = found.unitType,
            coalition           = found.dcsUnit:getCoalition(),
            position            = found.position,
            priority            = found.priority,
            selectionMethod     = "auto_nearest",
            wasManuallySelected = false,
        },
        laserCode   = jtac.laserCode,
        lockMode    = jtac.lockMode,
        distance    = found.distance,
        lineOfSight = true,
        radio       = jtac.radio,
        message     = msg,
        timestamp   = timer.getAbsTime(),
    })

    return t + laseInterval
end

--- Shared orbit loop for all flying JTACs. Runs every 3 seconds.
-- Handles: orbit start, orbit update (every 60s), orbit stop + backToRoute.
-- API: Unit:getController():popTask(), Group:getController():pushTask()
--      verified CTLD_jtac.lua source (ctld.StartOrbitGroup / backToRoute)
-- @param t number  timer.getTime()
-- @return number or nil
function CTLDJTACManager:_orbitLoop(t)
    local hasFlying = false
    for groupName, jtac in pairs(self.jtacs) do
        if jtac.isFlying and jtac.state ~= CTLDJTAC.STATE.DEAD then
            self:_updateOrbit(groupName, jtac, t)
            hasFlying = true
        end
    end
    if not hasFlying then
        self._orbitScheduleId = nil
        return nil
    end
    return t + 3
end

--- Update orbit state for one flying JTAC.
function CTLDJTACManager:_updateOrbit(groupName, jtac, t)
    local hasCurrent = jtac.currentTarget ~= nil
    local inOrbit    = jtac.state == CTLDJTAC.STATE.ORBITING

    local dcsGroup = Group.getByName(groupName)
    if not dcsGroup then return end
    local jtacUnit = dcsGroup:getUnits()[1]
    if not jtacUnit then return end

    if hasCurrent and not inOrbit then
        -- New target acquired — start orbiting
        local targetUnit = Unit.getByName(jtac.currentTarget.unitName)
        if not targetUnit or not targetUnit:isExist() then return end

        self:_setOrbitTask(jtacUnit, dcsGroup, targetUnit:getPoint())
        jtac:startOrbit(t)

        self:_publishEvent("OnJTACOrbitStart", {
            jtac      = { groupName = groupName, coalition = jtac.coalitionId },
            target    = { unitName = jtac.currentTarget.unitName, position = jtac.currentTarget.position },
            timestamp = timer.getAbsTime(),
        })

    elseif hasCurrent and inOrbit then
        -- Already orbiting — update orbit centre every 60s if target moved
        if jtac.orbitStartTime and (t - jtac.orbitStartTime) >= 60 then
            local targetUnit = Unit.getByName(jtac.currentTarget.unitName)
            if targetUnit and targetUnit:isExist() then
                self:_setOrbitTask(jtacUnit, dcsGroup, targetUnit:getPoint())
                jtac.orbitStartTime = t  -- reset 60s window
            end
        end

    elseif not hasCurrent and inOrbit then
        -- Target lost — restore initial route
        if jtac.initialRoute then
            dcsGroup:getController():setTask(jtac.initialRoute)
        end

        jtac:stopOrbit()

        self:_publishEvent("OnJTACOrbitStop", {
            jtac      = { groupName = groupName, coalition = jtac.coalitionId },
            timestamp = timer.getAbsTime(),
        })
    end
end

--- Push an Orbit task to a flying JTAC (Circle, 100 km/h, current drone altitude).
-- API: Unit:getController():popTask(), Group:getController():pushTask()
--      verified CTLD_jtac.lua source (ctld.StartOrbitGroup)
-- @param jtacUnit  DCS Unit
-- @param dcsGroup  DCS Group
-- @param targetPos table {x,y,z}
function CTLDJTACManager:_setOrbitTask(jtacUnit, dcsGroup, targetPos)
    local droneAlt = jtacUnit:getPoint().y
    jtacUnit:getController():popTask()
    dcsGroup:getController():pushTask({
        id     = "Orbit",
        params = { pattern = "Circle", point = targetPos, speed = 100 / 3.6, altitude = droneAlt },
    })
end

--- Stop lasing and publish OnJTACLaseStop event.
-- @param jtac   CTLDJTAC
-- @param reason string
function CTLDJTACManager:_stopLaseAndPublish(jtac, reason)
    local prevTarget = jtac.currentTarget
    jtac:stopLase(reason)

    -- Notify player on target events (not on internal transitions like standby/transit)
    if reason == CTLDJTAC.STOP_REASON.TARGET_LOST or reason == CTLDJTAC.STOP_REASON.TARGET_DESTROYED then
        local msg = CTLDJTACMessage.build({
            event       = reason,
            jtacName    = jtac.groupName,
            targetType  = prevTarget and prevTarget.unitType or nil,
            wasSelected = prevTarget ~= nil and (prevTarget.unitName == jtac.selectedTarget),
        })
        ctld.notifyCoalition(msg.full, 10, jtac.coalitionId, jtac.radio, msg.short)
    end

    self:_publishEvent("OnJTACLaseStop", {
        jtac = {
            groupName = jtac.groupName,
            coalition = jtac.coalitionId,
            laserCode = jtac.laserCode,
        },
        target = prevTarget and {
            unitName          = prevTarget.unitName,
            unitType          = prevTarget.unitType,
            lastKnownPosition = prevTarget.position,
        } or nil,
        reason    = reason,
        timestamp = timer.getAbsTime(),
    })
end

--- Fill the laser pool with all valid codes (1111–1688). Called at init and cleanup.
function CTLDJTACManager:_initLaserPool()
    self._laserPool = {}
    for code = 1111, 1688 do
        self._laserPool[#self._laserPool + 1] = code
    end
end

--- Assign next laser code from the pool. O(1) — removes from tail.
-- @return number or nil  (nil = pool exhausted)
function CTLDJTACManager:_assignLaserCode()
    return table.remove(self._laserPool)
end

--- Return a laser code to the pool.
-- @param code number
function CTLDJTACManager:_freeLaserCode(code)
    if code then
        self._laserPool[#self._laserPool + 1] = code
    end
end

--- Publish an event via EventDispatcher.
function CTLDJTACManager:_publishEvent(eventName, payload)
    EventDispatcher.getInstance():publish(eventName, payload)
end

--- Register a pre-placed MM JTAC group (reuses spawnJTAC logic).
-- Called by CTLDCoreManager:_initMMJTACs() for active groups,
-- and by onBirth() for late-activation groups.
-- @param group Group  DCS group object (must be active and exist)
-- @return CTLDJTAC or nil
function CTLDJTACManager:registerMMJTAC(group)
    return self:spawnJTAC(group:getName(), nil, "mission_maker")
end

--- Mark a JTAC group as pending late activation.
-- @param groupName string
function CTLDJTACManager:markPendingJTAC(groupName)
    self._pendingJTACs[groupName] = true
end

--- Return true if groupName is marked as pending.
-- @param groupName string
-- @return boolean
function CTLDJTACManager:_isPendingJTAC(groupName)
    return self._pendingJTACs[groupName] == true
end

--- Clear the pending flag for groupName.
-- @param groupName string
function CTLDJTACManager:_clearPendingJTAC(groupName)
    self._pendingJTACs[groupName] = nil
end

--- S_EVENT_BIRTH handler: activate pending late-activation JTAC groups.
-- Registered in CTLDDCSEventBridge by CTLDCoreManager.
function CTLDJTACManager:onBirth(event)
    local unit = event.initiator
    if not unit then return end
    local group = (unit.getGroup and unit:getGroup()) or nil
    if not group then return end
    local groupName = group:getName()
    if self:_isPendingJTAC(groupName) then
        self:registerMMJTAC(group)
        self:_clearPendingJTAC(groupName)
    end
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Build the "JTAC" F10 submenu for a player.
-- Requires JTAC_jtacStatusF10 = true (configKey gate).
-- Adds "JTAC Status" command + per-active-JTAC submenus for player coalition.
-- On JTAC state changes (spawn/dead/transit), CTLDPlayerManager:refreshAll()
-- triggers a full wipe+rebuild, keeping this content current.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDJTACManager:buildMenuSection(playerObj, menu)
    local root    = ctld.tr("CTLD")
    local jtacSub = ctld.tr("JTAC")
    menu:addSubMenu({ root }, jtacSub, { order = 90 })

    menu:addCommand({ root, jtacSub }, ctld.tr("JTAC Status"),
        function(arg)
            trigger.action.outTextForGroup(arg.groupId,
                ctld.tr("No active JTACs."), 10)
        end,
        { groupId = playerObj.groupId })

    -- Per-active-JTAC submenus for this coalition
    for groupName, jtac in pairs(self.jtacs) do
        if jtac.coalition == playerObj.coalition and not jtac:isDead() then
            menu:addSubMenu({ root, jtacSub }, groupName)

            if ctld.gs("JTAC_allowStandbyMode") then
                menu:addCommand({ root, jtacSub, groupName }, ctld.tr("Toggle Lasing"),
                    function(arg)
                        ctld.utils.log("INFO", "Toggle Lasing for " .. arg.groupName)
                    end,
                    { groupName = groupName })
            end

            if ctld.gs("JTAC_allowSmokeRequest") then
                menu:addCommand({ root, jtacSub, groupName }, ctld.tr("Request Smoke on Target"),
                    function(arg)
                        CTLDJTACManager.get():requestSmoke(arg.groupName)
                    end,
                    { groupName = groupName })
            end

            if ctld.gs("JTAC_allow9Line") then
                menu:addCommand({ root, jtacSub, groupName }, ctld.tr("Request 9-Line"),
                    function(arg)
                        ctld.utils.log("INFO", "9-Line for " .. arg.groupName)
                    end,
                    { groupName = groupName })
            end
        end
    end
end
