---@diagnostic disable
-- Read last lines of DCS log containing DIAG keyword
local logPath = lfs and lfs.writedir and (lfs.writedir() .. "Logs/dcs.log")
if not logPath then return "lfs not available" end
local f = io.open(logPath, "r")
if not f then return "cannot open: " .. logPath end
local lines = {}
for line in f:lines() do
    if line:find("unloadVehicle DIAG") or line:find("_computeSpawnPosition") then
        lines[#lines+1] = line
    end
end
f:close()
-- Return last 5 matching lines
local start = math.max(1, #lines - 4)
local out = {}
for i = start, #lines do out[#out+1] = lines[i] end
return #out > 0 and table.concat(out, "\n") or ("no DIAG lines found in " .. logPath)
