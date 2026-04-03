---@diagnostic disable
-- ============================================================
-- CTLD_fobScene.lua
-- FOB deployment scene — spawns an outpost container + watchtower.
--
-- Spawn position:
--   Step 0 (prescript): if ctx.scene._params.centroid is provided, use it
--   as the reference point (pre-computed by CTLDFOBManager at build start,
--   100 m at 12 o'clock from the transport).  Otherwise compute it live from
--   the trigger unit (fallback for ad-hoc calls).
--
-- Steps:
--   0 — prescript: override scene reference point (func-only, no delay)
--   1 — FOB_container  at polar(0, 0°)  relative to reference point
--   2 — FOB_watchtower at polar(39, 158°) relative to reference point
--   3 — completion message (func-only)
--
-- ctx.scene._params expected keys (all optional):
--   centroid   vec3   pre-computed spawn position (set by CTLDFOBManager)
--   player     string display name in the completion message
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager, CTLDUtils
-- DCS API: land.getHeight, trigger.action.outTextForCoalition
-- ============================================================

local fobScene = {}
fobScene.name = "fobScene"

fobScene.steps = {

    -- ----------------------------------------------------------------
    -- Step 0: prescript — override reference point.
    -- Uses params.centroid when set; otherwise computes 100 m ahead.
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            local centroid = ctx.scene._params and ctx.scene._params.centroid
            if centroid then
                ctx.scene._refX   = centroid.x
                ctx.scene._refZ   = centroid.z
                ctx.scene._refAlt = centroid.y
            else
                -- Fallback: compute 100 m at 12 o'clock from the trigger unit.
                local pt  = ctx.unit:getPoint()
                local hdg = ctld.utils.getHeadingInRadians("fobScene.prescript", ctx.unit, true)
                local fx  = pt.x + math.cos(hdg) * 100
                local fz  = pt.z + math.sin(hdg) * 100
                ctx.scene._refX   = fx
                ctx.scene._refZ   = fz
                ctx.scene._refAlt = land.getHeight({ x = fx, y = fz })
            end
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 1: FOB outpost container (STATIC) — at reference point.
    -- ----------------------------------------------------------------
    {
        registryKey              = "FOB_container",
        polar                    = { distance = 0, angle = 0 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 2: Watchtower (STATIC) — ~39 m at 158° from reference.
    -- Reproduces the legacy offset: x+14.86 m, z-36.57 m (polar approx).
    -- ----------------------------------------------------------------
    {
        registryKey              = "FOB_watchtower",
        polar                    = { distance = 39, angle = 158 },
        delayAfterPreviousStep   = 2,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 3: Completion message (func-only).
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            local player = (ctx.scene._params and ctx.scene._params.player)
                           or ctx.unit:getName()
            trigger.action.outTextForCoalition(
                ctx.scene._coalitionId,
                string.format(ctld.tr("fobDeployedMsg", "FOB deployed by %s."), player),
                10)
        end,
    },
}

-- ============================================================
-- Self-registration
-- ============================================================

CTLDSceneManager.getInstance():registerSceneModel(fobScene)
