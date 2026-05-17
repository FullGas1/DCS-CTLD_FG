---@diagnostic disable
-- witchcraft_ping.lua — smoke test Witchcraft + CTLD.log

-- 1. Log DCS
env.info("[WITCHCRAFT_PING] START")

-- 2. Log fichier
local logPath = "C:/Users/Moi/Documents/GitHub/DCS-CTLD_FG/recette/CTLD.log"
local f = io.open(logPath, "w")
if f then
    f:write("[WITCHCRAFT_PING] execution OK\n")
    f:write("[WITCHCRAFT_PING] timer.getAbsTime() = " .. tostring(timer.getAbsTime()) .. "\n")

    -- Slot joueur connecté
    local players = coalition.getPlayers(coalition.side.BLUE) or {}
    f:write("[WITCHCRAFT_PING] BLUE players count = " .. tostring(#players) .. "\n")
    for i, u in ipairs(players) do
        f:write(string.format("[WITCHCRAFT_PING]   [%d] unitName=%s playerName=%s\n",
            i, tostring(u:getName()), tostring(u:getPlayerName())))
    end

    f:close()
end

env.info("[WITCHCRAFT_PING] END — log écrit dans CTLD.log")
