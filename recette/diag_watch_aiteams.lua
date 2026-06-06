-- Watchdog: log #_aiTeams[2] every 1s, alert on change
local lastSize = -1
local iteration = 0

local function watch(_, t)
    iteration = iteration + 1
    local ok, core = pcall(CTLDCoreManager.getInstance)
    if not ok or not core then
        ctld.utils.log("INFO", "[WATCH] core unavailable")
        return nil
    end
    local teams = core._aiTeams and core._aiTeams[2] or {}
    local sz = #teams
    if sz ~= lastSize then
        -- also dump first template info
        local first = teams[1]
        local info = first and string.format("tmpl[1]=%s sp.task=%s",
            tostring(first.name),
            tostring(first.specificParams and first.specificParams.task)) or "empty"
        ctld.utils.log("INFO",
            "[WATCH] iter=%d _aiTeams[2] size CHANGED %d->%d | %s",
            iteration, lastSize, sz, info)
        -- also log raw table address for identity check
        ctld.utils.log("INFO", "[WATCH] _aiTeams addr=%s [2] addr=%s",
            tostring(core._aiTeams), tostring(core._aiTeams[2]))
        lastSize = sz
    end
    return t + 1
end

-- register local ref so it stays alive
local fid = timer.scheduleFunction(watch, nil, timer.getTime() + 0.5)
ctld.utils.log("INFO", "[WATCH] watchdog registered fid=%s", tostring(fid))
return "watchdog started"
