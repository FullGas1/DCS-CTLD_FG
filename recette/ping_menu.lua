local u = (coalition.getPlayers(coalition.side.BLUE) or {})[1]
if not u then return "no player" end
trigger.action.outTextForGroup(u:getGroup():getID(), "CTLD menu actif - appuie sur * numpad", 10)
return "ping"
