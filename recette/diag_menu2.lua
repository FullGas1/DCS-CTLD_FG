-- recette/diag_menu2.lua — dump children tree
local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "no player" end
local pn = u:getName()

local mmgr = ctld.MenuManager:getInstance()
local menu  = mmgr and mmgr:getMenuByUnitName(pn)
if not menu then return "no menu" end

local function dumpChildren(node, prefix, depth)
    if depth > 5 or not node then return end
    local children = node.children or {}
    local n = 0
    for _ in pairs(children) do n = n + 1 end
    ctld.logInfo("[menu] %schildren=%d", prefix, n)
    for k, child in pairs(children) do
        ctld.logInfo("[menu] %s[%s] label=%s type=%s mcsId=%s",
            prefix, tostring(k),
            tostring(child.label or child.name or "?"),
            tostring(child.type or "?"),
            tostring(child.mcsId or "?"))
        if child.children then
            dumpChildren(child, prefix .. "  ", depth + 1)
        end
    end
end

ctld.logInfo("[menu] === menu dump for %s ===", pn)
dumpChildren(menu, "", 0)
return "done — check CTLD.log"
