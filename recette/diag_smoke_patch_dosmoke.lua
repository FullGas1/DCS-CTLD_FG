---@diagnostic disable
-- Patch doSmoke via menu node inspection to log what happens when called
-- We monkey-patch CTLDCrateManager buildSmokeSection to trace the doSmoke call

local _orig_buildSmokeSection = CTLDCrateManager.getInstance().buildSmokeSection

CTLDCrateManager.getInstance().buildSmokeSection = function(self, playerObj, menu)
    if not playerObj.isTransport then return end

    local root     = ctld.tr("CTLD")
    local smokeSub = ctld.tr("Smoke")
    menu:addSubMenu({ root }, smokeSub, { order = 80 })

    local smMgr = CTLDSmokeManager.getInstance()
    local uName = playerObj.unitName

    local function doSmoke(arg)
        ctld.utils.log("INFO", "[patch_doSmoke] called unitName=%s color=%s", tostring(arg.unitName), tostring(arg.color))
        local unit = Unit.getByName(arg.unitName)
        if not (unit and unit:isExist()) then
            ctld.utils.log("INFO", "[patch_doSmoke] FAIL: unit not found or not exist")
            return
        end
        local pt  = unit:getPoint()
        local pos = { x = pt.x, y = land.getHeight({ x = pt.x, y = pt.z }), z = pt.z }
        trigger.action.smoke(pos, arg.color)
        trigger.action.outTextForCoalition(unit:getCoalition(),
            string.format(ctld.tr("%1 dropped %2 smoke."), arg.unitName, arg.colorName), 10)
        smMgr:registerSmoke(arg.unitName, pos, arg.color)
        ctld.utils.log("INFO", "[patch_doSmoke] registerSmoke OK active=%s smokes=%d",
            tostring(smMgr:isActive(arg.unitName)),
            #(smMgr._players[arg.unitName] and smMgr._players[arg.unitName].smokes or {}))
    end

    local function doToggleAutoResume(arg)
        local newState = smMgr:toggle(arg.unitName)
        local interval = ctld.gs("smokeAutoResumeInterval") or 270
        local msgKey   = newState and "Smoke auto-resume ON (%1s interval)" or "Smoke auto-resume OFF"
        local msg = ctld.tr(msgKey):gsub("%%1", tostring(interval))
        local u = Unit.getByName(arg.unitName)
        local gid = u and u:getGroup() and u:getGroup():getID() or -1
        trigger.action.outTextForGroup(gid, msg, 10)
        ctld.utils.log("INFO", "[patch_doSmoke] toggle active=%s", tostring(newState))
        local pm = CTLDPlayerManager.getInstance()
        if pm then
            local pObj = pm:getPlayer(arg.unitName)
            if pObj then pm:buildMenu(pObj) end
        end
    end

    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Red Smoke"),    doSmoke,
        { unitName = uName, color = trigger.smokeColor.Red,    colorName = "RED" })
    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Blue Smoke"),   doSmoke,
        { unitName = uName, color = trigger.smokeColor.Blue,   colorName = "BLUE" })
    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Orange Smoke"), doSmoke,
        { unitName = uName, color = trigger.smokeColor.Orange, colorName = "ORANGE" })
    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Green Smoke"),  doSmoke,
        { unitName = uName, color = trigger.smokeColor.Green,  colorName = "GREEN" })

    local toggleLabel = smMgr:isActive(uName)
        and ctld.tr("Smoke Auto-Resume [deactivate]")
        or  ctld.tr("Smoke Auto-Resume [activate]")
    menu:addCommand({ root, smokeSub }, toggleLabel, doToggleAutoResume, { unitName = uName })
end

-- Rebuild menu for current player
local pu = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not pu then return "FAIL: no BLUE player" end
local uName = pu:getName()
local pm = CTLDPlayerManager.getInstance()
local pObj = pm:getPlayer(uName)
if pObj then pm:buildMenu(pObj) end

return "patch_doSmoke installed — drop a smoke and check CTLD.log"
