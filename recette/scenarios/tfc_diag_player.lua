local TAG = "[tfc_diag]"
env.info(TAG .. " START")

for attempt = 1, 5 do
    local units = coalition.getPlayers(coalition.side.BLUE) or {}
    env.info(TAG .. " attempt " .. attempt .. ": " .. #units .. " BLUE players")
    if #units > 0 and units[1]:isExist() then
        env.info(TAG .. " PLAYER FOUND: " .. units[1]:getName() .. " on attempt " .. attempt)
        trigger.action.outText("[TFC] PLAYER FOUND: " .. units[1]:getName(), 30)
        env.info(TAG .. " END (player found)")
        return "player_found"
    end
    local t = os.clock() + 1
    while os.clock() < t do end
end

env.info(TAG .. " END (no player after 5 attempts)")
trigger.action.outText("[TFC] no BLUE player detected after 5 attempts", 30)
return "no_player"