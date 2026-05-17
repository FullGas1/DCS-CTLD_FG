---@diagnostic disable
local g = Group.getByName("enemi1")
if not g then
    trigger.action.outText("enemi1: NOT FOUND", 15)
    return "enemi1 not found"
end
local coal = g:getCoalition()
local coalName = (coal == 1) and "RED" or (coal == 2) and "BLUE" or "NEUTRAL"
local u = g:getUnits()[1]
local uCoal = u and u:getCoalition() or -1
local uType = u and u:getTypeName() or "?"
local msg = string.format("enemi1: coalition=%d(%s) unit_type=%s unit_coal=%d", coal, coalName, uType, uCoal)
ctld.utils.log("INFO", "[diag] %s", msg)
trigger.action.outText(msg, 20)
return msg
