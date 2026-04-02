---@diagnostic disable
-- CTLD_sceneManager.lua
-- CTLDSceneManager singleton — scene model registry + sequential execution engine.
-- CtldScene      — executes one scene instance step by step.
--
-- Step types (fields in each step table):
--   polar  : { polar={distance, angle}, relativeHeadingInDegrees, relativeAltitudeInMeters,
--              registryKey [, func] }
--              Deterministic position relative to the trigger unit's snapshot position.
--   axis   : { axis={count, safeDistance, spacing}, registryKey [, func] }
--              Random single axis around the unit; N objects spread along it.
--   func   : { func=function(unit, spawnedObj, step) ... end }
--              No spawn; only executes the function.
--
-- All steps carry delayAfterPreviousStep (seconds).  After executing step N,
-- the engine waits that many seconds before starting step N+1.  The same field
-- is also used before step 1 (initial delay from mission start / scene trigger).
--
-- Dependencies: CTLDUtils, CTLDObjectRegistry
-- DCS API: timer.getTime, timer.scheduleFunction, Unit.*, Airbase.*,
--          trigger.action.outText
-- ====================================================================================================

-- ====================================================================================================
-- CtldScene
-- ====================================================================================================

CtldScene = class()

local _sceneCounter = 0

-- Creates and immediately starts a new scene instance.
-- @param unit   DCS Unit object (trigger unit — position/heading snapshot is taken here)
-- @param model  table { name=string, steps={...} }
-- @return CtldScene
function CtldScene:init(unit, model)
    _sceneCounter  = _sceneCounter + 1
    self._name     = string.format("%s#%d", model.name, _sceneCounter)
    self._unit     = unit
    self._steps    = model.steps
    self._stepIndex   = 0
    self._timeMarker  = 0
    self._spawnedObjs = {}

    -- Snapshot reference position and heading at creation time.
    -- All step positions are computed relative to this snapshot (unit may have moved).
    local pt        = unit:getPoint()
    self._refX      = pt.x          -- world North axis
    self._refZ      = pt.z          -- world East axis
    self._refAlt    = pt.y          -- altitude (metres)
    self._refHdgRad = ctld.utils.getHeadingInRadians("CtldScene", unit, true)

    -- Magnetic declination is constant for the whole scene (computed once at reference point).
    self._magDecDeg = math.deg(
        ctld.utils.getNorthCorrectionInRadians("CtldScene", { x = self._refX, y = self._refZ })
    )
end

-- Schedules the first step.
function CtldScene:_execute()
    local firstDelay = tonumber(self._steps[1].delayAfterPreviousStep) or 0
    self._timeMarker = timer.getTime() + firstDelay
    if self._timeMarker > timer.getTime() then
        local fn = function() self:_runNextStep() end
        timer.scheduleFunction(fn, nil, self._timeMarker)
    else
        self:_runNextStep()
    end
end

-- Executes the current step then schedules the next one.
function CtldScene:_runNextStep()
    self._stepIndex = self._stepIndex + 1
    local step = self._steps[self._stepIndex]
    if not step then
        ctld.utils.log("WARN", "CtldScene '%s': no step at index %d", self._name, self._stepIndex)
        return
    end

    local coalitionId = self._unit:getCoalition()
    local countryId   = self._unit:getCountry()
    local spawnedObj  = nil

    -- -----------------------------------------------------------------------
    -- Spawn phase (skipped for func-only steps)
    -- -----------------------------------------------------------------------
    if step.registryKey then
        local desc = CTLDObjectRegistry.get(step.registryKey)

        -- Auto-inject circleRadius when the descriptor uses circle formation.
        local overrides = {}
        if desc and desc.formation and desc.formation.type == "circle" then
            local safeR = ctld.utils.getSecureDistanceFromUnit(self._unit:getName()) or 10
            overrides.circleRadius = safeR + (ctld.gs("spawnDistanceInCircle") or 10)
        end

        if step.polar then
            -- Polar step: deterministic world position derived from the snapshot.
            local spawnX, spawnEast, spawnHdgDeg = ctld.utils.getRelativeCoords(
                self._refX, self._refZ, self._refHdgRad, self._refAlt,
                step.polar.angle    or 0,
                step.polar.distance or 0,
                step.relativeHeadingInDegrees or 0,
                step.relativeAltitudeInMeters or 0,
                self._magDecDeg
            )
            spawnedObj = CTLDObjectRegistry.spawnObject(
                step.registryKey, coalitionId, countryId,
                spawnX, spawnEast, math.rad(spawnHdgDeg), overrides
            )
            if spawnedObj then
                self._spawnedObjs[#self._spawnedObjs + 1] = spawnedObj
            end

        elseif step.axis then
            -- Axis step: random single axis; N objects distributed along it.
            local count    = step.axis.count       or 1
            local safeDist = step.axis.safeDistance
                          or ctld.utils.getSecureDistanceFromUnit(self._unit:getName())
                          or 20
            local spacing  = step.axis.spacing or (ctld.gs("crateSpacing") or 5)
            local result   = ctld.utils.getSpawnObjectPositions(self._unit, count, safeDist, spacing)
            for _, pos in ipairs(result.positions) do
                local obj = CTLDObjectRegistry.spawnObject(
                    step.registryKey, coalitionId, countryId,
                    pos.x, pos.z, 0, overrides
                )
                if obj then
                    self._spawnedObjs[#self._spawnedObjs + 1] = obj
                    spawnedObj = obj   -- pass the last spawned object to func
                end
            end
        end
    end

    -- -----------------------------------------------------------------------
    -- Optional func
    -- -----------------------------------------------------------------------
    if step.func then
        local ok, err = pcall(step.func, self._unit, spawnedObj, step)
        if not ok then
            ctld.utils.log("ERROR", "CtldScene '%s' step %d func error: %s",
                self._name, self._stepIndex, tostring(err))
        end
    end

    -- -----------------------------------------------------------------------
    -- Schedule next step (if any)
    -- -----------------------------------------------------------------------
    if self._steps[self._stepIndex + 1] then
        self._timeMarker = self._timeMarker + (tonumber(step.delayAfterPreviousStep) or 0)
        if self._timeMarker > timer.getTime() then
            local fn = function() self:_runNextStep() end
            timer.scheduleFunction(fn, nil, self._timeMarker)
        else
            self:_runNextStep()
        end
    else
        ctld.utils.log("INFO", "CtldScene '%s': completed (%d steps)", self._name, self._stepIndex)
    end
end

-- ====================================================================================================
-- CTLDSceneManager
-- ====================================================================================================

CTLDSceneManager = class()

local _smInstance = nil

function CTLDSceneManager.getInstance()
    if not _smInstance then
        _smInstance = setmetatable({}, CTLDSceneManager)
        _smInstance:_init()
    end
    return _smInstance
end

function CTLDSceneManager:_init()
    self._models = {}   -- model name → model table
    self._active = {}   -- scene name  → CtldScene instance
    self:_registerBuiltins()
    local n = 0
    for _ in pairs(self._models) do n = n + 1 end
    ctld.utils.log("INFO", "CTLDSceneManager: initialized (%d built-in scene(s))", n)
end

-- Registers a scene model.  Returns true on success.
-- External files (e.g. CTLD_mineFieldScene.lua) call this at load time.
-- @param model  table  { name=string, steps={...} }
function CTLDSceneManager:registerSceneModel(model)
    if not model or not model.name or model.name == "" then
        ctld.utils.log("WARN", "CTLDSceneManager:registerSceneModel: model missing 'name' field")
        return false
    end
    if self._models[model.name] then
        ctld.utils.log("WARN", "CTLDSceneManager:registerSceneModel: '%s' already registered", model.name)
        return false
    end
    self._models[model.name] = model
    ctld.utils.log("INFO", "CTLDSceneManager: registered scene model '%s'", model.name)
    return true
end

-- Starts a named scene triggered by a DCS unit.
-- @param unit       DCS Unit object
-- @param modelName  string  key in _models
-- @return CtldScene instance, or nil on error
function CTLDSceneManager:playScene(unit, modelName)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDSceneManager:playScene: unit is nil or dead")
        return nil
    end
    local model = self._models[modelName]
    if not model then
        ctld.utils.log("WARN", "CTLDSceneManager:playScene: unknown model '%s'", tostring(modelName))
        return nil
    end
    local scene = CtldScene:new(unit, model)
    self._active[scene._name] = scene
    scene:_execute()
    ctld.utils.log("INFO", "CTLDSceneManager: started scene '%s' for unit '%s'",
        scene._name, unit:getName())
    return scene
end

-- Returns a registered model table by name, or nil.
function CTLDSceneManager:getModel(name)
    return self._models[name]
end

-- ====================================================================================================
-- Built-in scene registration
-- ====================================================================================================

function CTLDSceneManager:_registerBuiltins()
    self:registerSceneModel(CTLDSceneManager._FARP_ALPHA_SCENE)
    self:registerSceneModel(CTLDSceneManager._FOB_SCENE)
end

-- ====================================================================================================
-- Built-in scene: FARP Alpha
-- Migrated from source_scene_ini/farpSceneDatas.lua.
-- 13 object steps + 1 completion func.
-- ====================================================================================================

CTLDSceneManager._FARP_ALPHA_SCENE = {
    name  = "FARP Alpha",
    steps = {

        -- Step 1: FARP helipad (STATIC) — warehouse stocked with all fuel types after spawn.
        {
            polar                    = { distance = 100, angle = 0 },
            delayAfterPreviousStep   = 0,
            relativeHeadingInDegrees = 180,
            relativeAltitudeInMeters = 0,
            registryKey         = "SINGLE_HELIPAD",
            func = function(unit, spawnedObj, step)
                if not spawnedObj then return false end
                local ab = Airbase.getByName(spawnedObj:getName())
                if ab then
                    local w = ab:getWarehouse()
                    w:addLiquid(0, 10000)   -- jet fuel
                    w:addLiquid(1, 10000)   -- aviation gasoline
                    w:addLiquid(2, 10000)   -- MW50
                    w:addLiquid(3, 10000)   -- diesel
                end
                return true
            end,
        },

        -- Step 2: Command tent (STATIC)
        {
            polar                    = { distance = 130, angle = 5 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 90,
            relativeAltitudeInMeters = 0,
            registryKey         = "FARP_Tent",
        },

        -- Step 3: Ammo storage (STATIC)
        {
            polar                    = { distance = 110, angle = 340 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "FARP_Ammo_Storage",
        },

        -- Step 4a: Fuel truck (GROUND)
        {
            polar                    = { distance = 110, angle = 15 },
            delayAfterPreviousStep   = 5,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "Fuel_Truck",
        },

        -- Step 4b: Repair truck (GROUND)
        {
            polar                    = { distance = 125, angle = 15 },
            delayAfterPreviousStep   = 5,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "repare_Truck",
        },

        -- Step 5: Security guard group (GROUND)
        {
            polar                    = { distance = 90, angle = 15 },
            delayAfterPreviousStep   = 0,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "FARP_Security_Guard",
        },

        -- Step 6a: Barrels (STATIC)
        {
            polar                    = { distance = 100, angle = 350 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "barrels_cargo",
        },

        -- Step 6b1: Cargo box (STATIC)
        {
            polar                    = { distance = 95, angle = 349 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "Cargo06",
        },

        -- Step 6b2: Ammo cargo (STATIC)
        {
            polar                    = { distance = 105, angle = 351.2 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "ammo_cargo",
        },

        -- Step 6c: Ammo cargo 2 (STATIC)
        {
            polar                    = { distance = 106.5, angle = 351.3 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 5,
            relativeAltitudeInMeters = 0,
            registryKey         = "ammo_cargo",
        },

        -- Step 6d: Carrier shooter static (STATIC)
        {
            polar                    = { distance = 115, angle = 5 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 220,
            relativeAltitudeInMeters = 0,
            registryKey         = "us carrier shooter",
        },

        -- Step 6e: Light panel (STATIC)
        {
            polar                    = { distance = 116.7, angle = 353 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 220,
            relativeAltitudeInMeters = 0,
            registryKey         = "NF-2_LightOn",
        },

        -- Step 6f: Windsock (STATIC)
        {
            polar                    = { distance = 80, angle = 10 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 220,
            relativeAltitudeInMeters = 0,
            registryKey         = "Windsock",
        },

        -- Step 7: Completion message (func-only)
        {
            delayAfterPreviousStep = 0,
            func = function(unit, spawnedObj, step)
                trigger.action.outText(
                    ctld.tr("--- FARP Dynamic Deployment by %1 : Complete! ---", unit:getName()), 10)
                return true
            end,
        },
    },
}

-- ====================================================================================================
-- Built-in scene: FOB
-- 2 object steps (container + watchtower) + 1 func registering the logistic zone.
-- CTLDFOBManager.onFOBBuilt is called when that manager is loaded; guarded otherwise.
-- ====================================================================================================

CTLDSceneManager._FOB_SCENE = {
    name  = "FOB",
    steps = {

        -- Step 1: FOB outpost container (STATIC)
        {
            polar                    = { distance = 10, angle = 0 },
            delayAfterPreviousStep   = 0,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "FOB_container",
        },

        -- Step 2: Watchtower (STATIC)
        {
            polar                    = { distance = 25, angle = 5 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "FOB_watchtower",
        },

        -- Step 3: Register FOB as logistic zone (func-only)
        {
            delayAfterPreviousStep = 0,
            func = function(unit, spawnedObj, step)
                -- Forward to CTLDFOBManager once it is loaded.
                if CTLDFOBManager then
                    CTLDFOBManager.getInstance():onFOBBuilt(unit)
                end
                trigger.action.outText(
                    ctld.tr("FOB deployed by %1", unit:getName()), 10)
                return true
            end,
        },
    },
}
