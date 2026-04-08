---@diagnostic disable
-- menu_test_setup.lua
-- Shared mock setup for R5 config-variant menu tests (F-48 to F-56).
-- dofile this before the test assertions.
--
-- Provides:
--   buildTestMenu(playerObj, cfg)  → ctld.Menu (already refresh()'d)
--   getRendered(menu, groupId)     → { [subMenuName]=true } for all submenus under "CTLD" root
--
-- cfg overrides any key in the default config (all features ON by default).

-- ── DCS mocks ──────────────────────────────────────────────────────────────
_MENU_DCS_CALLS = {}
missionCommands = {
    addSubMenuForGroup  = function(gId, name, path)
        table.insert(_MENU_DCS_CALLS, { fn="sub", gId=gId, name=name, path=path })
    end,
    addCommandForGroup  = function(gId, name, path)
        table.insert(_MENU_DCS_CALLS, { fn="cmd", gId=gId, name=name, path=path })
    end,
    removeItemForGroup  = function() end,
}
Unit      = Unit      or { getByName=function()return nil end, getByID=function()return nil end }
coalition = coalition or { getGroups=function()return{}end, side={RED=1,BLUE=2,NEUTRAL=0} }
timer     = timer     or { getTime=function()return 0 end, scheduleFunction=function()end, getAbsTime=function()return 0 end }
trigger   = trigger   or { action={ outTextForGroup=function()end, outText=function()end } }
world     = world     or { event={ S_EVENT_PLAYER_ENTER_UNIT=1, S_EVENT_PLAYER_LEAVE_UNIT=2,
                                   S_EVENT_DEAD=3, S_EVENT_BIRTH=4 } }

ctld = ctld or {}
ctld.tr         = function(k) return k end
ctld.logInfo    = function() end
ctld.logWarning = function() end
ctld.logError   = function() end
ctld.utils      = ctld.utils or { log=function()end }

CTLDDCSEventBridge = { getInstance=function() return {register=function()end} end }
EventDispatcher    = { getInstance=function() return {subscribe=function()end} end }
CTLDZoneManager    = {
    getInstance=function()
        return {
            getTroopZonesForCoalition    = function() return {} end,
            getLogisticZonesForCoalition = function() return {} end,
        }
    end
}

-- ── Default config (all ON) ────────────────────────────────────────────────
local _defaults = {
    enableCrates           = true,
    enableSmokeDrop        = true,
    enabledFOBBuilding     = true,
    enablePackingVehicles  = true,
    enabledRadioBeaconDrop = true,
    reconF10Menu           = true,
    JTAC_jtacStatusF10     = true,
    JTAC_dropEnabled       = true,
    JTAC_allowStandbyMode  = false,
    JTAC_allowSmokeRequest = false,
    JTAC_allow9Line        = false,
    unitActions            = { ["UH-1H"] = {crates=true,troops=true}, ["C-130J-30"]={crates=true,troops=true} },
    spawnableCrates        = {},
    loadableGroups         = {},
}

-- ── Minimal section stubs (inline, no real manager deps) ──────────────────
local function _sectionStubs()
    return {
        { key="troops",   order=20, configKey=nil, fn=function(p,m)
            local acts=(ctld.gs("unitActions") or {})[p.typeName]
            if not (p.isTransport and acts and acts.troops) then return end
            m:addSubMenu({ctld.tr("CTLD")}, ctld.tr("Troop Commands"), {order=20})
        end},
        { key="vehicles", order=30, configKey=nil, fn=function(p,m)
            if not p.canCarryVehicles then return end
            m:addSubMenu({ctld.tr("CTLD")}, ctld.tr("Vehicle Commands"), {order=30})
        end},
        { key="crates",   order=40, configKey="enableCrates", fn=function(p,m)
            local acts=(ctld.gs("unitActions") or {})[p.typeName]
            if not (p.isTransport and acts and acts.crates) then return end
            local root=ctld.tr("CTLD")
            m:addSubMenu({root}, ctld.tr("Spawn Crates"),   {order=40})
            m:addSubMenu({root}, ctld.tr("Crate Commands"), {order=50})
            if ctld.gs("enabledFOBBuilding") then
                m:addCommand({root,ctld.tr("Crate Commands")},ctld.tr("List FOBs"),function()end,{})
            end
            if ctld.gs("enablePackingVehicles") then
                m:addSubMenu({root,ctld.tr("Crate Commands")},ctld.tr("Pack Vehicle"),{order=99})
            end
        end},
        { key="smoke",    order=80, configKey="enableSmokeDrop", fn=function(p,m)
            if not p.isTransport then return end
            m:addSubMenu({ctld.tr("CTLD")}, ctld.tr("Smoke"), {order=80})
        end},
        { key="beacons",  order=60, configKey="enabledRadioBeaconDrop", fn=function(p,m)
            if not p.isTransport then return end
            m:addSubMenu({ctld.tr("CTLD")}, ctld.tr("Radio Beacons"), {order=60})
        end},
        { key="recon",    order=70, configKey="reconF10Menu", fn=function(p,m)
            m:addSubMenu({ctld.tr("CTLD")}, ctld.tr("RECON"), {order=70})
        end},
        { key="jtac",     order=90, configKey="JTAC_jtacStatusF10", fn=function(p,m)
            local root=ctld.tr("CTLD")
            m:addSubMenu({root}, ctld.tr("JTAC"), {order=90})
            m:addCommand({root,ctld.tr("JTAC")},ctld.tr("JTAC Status"),function()end,{})
        end},
    }
end

-- ── Public helpers ─────────────────────────────────────────────────────────

--- Build a menu for playerObj using cfg overrides and return the menu.
-- @param playerObj table   CTLDPlayer-like: unitName, groupId, typeName, isTransport, canCarryVehicles, coalition
-- @param cfg       table   Config key overrides (nil = all defaults)
function buildTestMenu(playerObj, cfg)
    -- Apply config
    local merged = {}
    for k,v in pairs(_defaults) do merged[k]=v end
    if cfg then for k,v in pairs(cfg) do merged[k]=v end end
    ctld.gs = function(k) return merged[k] end

    -- Reset singletons
    CTLDPlayerManager._instance = nil
    ctld.MenuManager._instance  = nil
    _MENU_DCS_CALLS = {}

    local pm   = CTLDPlayerManager.getInstance()
    local stubs = _sectionStubs()
    for _, s in ipairs(stubs) do
        local mgr = { _fn=s.fn }
        mgr.buildMenuSection  = function(self,p,m) self._fn(p,m) end
        mgr.buildSmokeSection = mgr.buildMenuSection
        pm:registerMenuSection({
            key=s.key, manager=mgr,
            method = (s.key=="smoke") and "buildSmokeSection" or "buildMenuSection",
            configKey=s.configKey, order=s.order,
        })
    end

    pm:buildMenu(playerObj)
    return ctld.MenuManager:getInstance():getMenuByGroupId(playerObj.groupId)
end

--- Collect submenus rendered directly under "CTLD" root for groupId.
-- @param groupId number
-- @return table  { [subMenuName]=true }
function getRendered(groupId)
    local r = {}
    for _, c in ipairs(_MENU_DCS_CALLS) do
        if c.fn=="sub" and c.gId==groupId and c.path and c.path[1]==ctld.tr("CTLD") then
            r[c.name] = true
        end
    end
    return r
end

--- Collect commands rendered directly under a path for groupId.
-- @param groupId number
-- @param path    table   e.g. {"CTLD", "Crate Commands"}
-- @return table  { [commandName]=true }
function getRenderedCmds(groupId, path)
    local r = {}
    for _, c in ipairs(_MENU_DCS_CALLS) do
        if c.fn=="cmd" and c.gId==groupId and c.path then
            local match = (#c.path == #path)
            if match then for i,s in ipairs(path) do if c.path[i]~=s then match=false;break end end end
            if match then r[c.name]=true end
        end
    end
    return r
end

env.info("[menu_test_setup] loaded")
