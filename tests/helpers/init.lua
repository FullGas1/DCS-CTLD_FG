---@diagnostic disable
-- tests/helpers/init.lua
-- Loaded by busted before every spec (configured in .busted helper field).
-- 1. Injects DCS API stubs into the global environment.
-- 2. Loads all CTLD src/ modules (idempotent via _CTLD_LOADED guard in loader.lua).
-- ============================================================

-- Resolve repo root from this file's path
local _thisFile = debug.getinfo(1, "S").source:match("^@(.+)tests[\\/]helpers[\\/]init%.lua$")
assert(_thisFile, "init.lua: cannot resolve repo root")

-- Load DCS stubs first (globals must exist before src/ modules load)
dofile(_thisFile .. "tests/helpers/dcs_stubs.lua")

-- Load all CTLD modules
dofile(_thisFile .. "tests/helpers/loader.lua")
