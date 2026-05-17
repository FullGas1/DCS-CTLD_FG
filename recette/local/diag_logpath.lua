---@diagnostic disable
local cfg = CTLDConfig.get()
local logPath = cfg.settings["ctldLogPath"] or "(nil)"
local debug   = cfg.settings["debug"]
local logFile = logPath .. "CTLD.log"

-- Try to write a probe line to the log via ctld.utils.log
ctld.utils.log("INFO", "[diag_logpath] ctldLogPath='%s' debug=%s", logPath, tostring(debug))

-- Also write directly to confirm the file location
local ok, err = pcall(function()
    local f = io.open(logFile, "a")
    if f then
        f:write("[diag_logpath] direct write test — " .. os.date() .. "\n")
        f:close()
    end
end)

trigger.action.outText(
    "[diag_logpath] ctldLogPath='" .. logPath .. "' debug=" .. tostring(debug) ..
    " | direct write ok=" .. tostring(ok) .. " err=" .. tostring(err), 30)

return "logPath='" .. logPath .. "' logFile='" .. logFile .. "'"
