-- recette/diag_menu.lua — dump menu tree for BLUE player
local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "no player" end
local pn = u:getName()

local mmgr = ctld.MenuManager:getInstance()
local menu  = mmgr and mmgr:getMenuByUnitName(pn)
if not menu then return "no menu" end

-- Dump internal structure
local function dumpTable(t, prefix, depth)
    if depth > 4 then return end
    prefix = prefix or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            ctld.logInfo("[menu] %s%s = {}", prefix, tostring(k))
            dumpTable(v, prefix .. "  ", depth + 1)
        else
            ctld.logInfo("[menu] %s%s = %s", prefix, tostring(k), tostring(v))
        end
    end
end

-- Check known fields
ctld.logInfo("[menu] type=%s", type(menu))
local keys = {}
for k in pairs(menu) do keys[#keys+1] = tostring(k) end
ctld.logInfo("[menu] keys: %s", table.concat(keys, ", "))

-- Check _commands / _subMenus / _items
if menu._commands then
    ctld.logInfo("[menu] _commands count=%d", #menu._commands)
end
if menu._subMenus then
    local n = 0
    for _ in pairs(menu._subMenus) do n = n + 1 end
    ctld.logInfo("[menu] _subMenus count=%d", n)
end
if menu._items then
    ctld.logInfo("[menu] _items count=%d", #menu._items)
end
if menu._nodes then
    local n = 0
    for _ in pairs(menu._nodes) do n = n + 1 end
    ctld.logInfo("[menu] _nodes count=%d", n)
end

return "dump done — check CTLD.log"
