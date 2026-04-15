-- ============================================================
-- CTLD_userConfig.lua
-- User configuration — load AFTER CTLD_Next.lua in the mission.
--
-- HOW TO USE
--   In the Mission Editor, add a trigger "MISSION START → DO SCRIPT FILE"
--   and select this file.  It must run AFTER CTLD_Next.lua.
--
-- All values below are the factory defaults.
-- Uncomment and edit only the lines you want to change.
-- ============================================================

if ctld == nil then ctld = {} end

ctld.yamlConfigDatas = [[

# ============================================================
# General
# ============================================================

# Allow aircraft type (not pilot name) to determine CTLD capability.
# ctld.addPlayerAircraftByType: true

# Show coordinates as Degrees Minutes Seconds (DMS) instead of DDM.
# ctld.location_DMS: false

# Disable all smoke at pickup/dropoff zones regardless of other settings.
# ctld.disableAllSmoke: false


# ============================================================
# Logistics distance
# ============================================================

# Max distance (m) from transport to logistic zone for spawn/load operations.
# ctld.maximumDistanceLogistic: 200

# Minimum distance (m) from a friendly pickup zone where a crate can be deployed.
# ctld.minimumDeployDistance: 1000


# ============================================================
# Crates
# ============================================================

# Master switch — set to false to disable the entire crate system.
# ctld.enableCrates: true

# Allow crate loading via F10 menu (in addition to hover).
# ctld.loadCrateFromMenu: true

# Enable virtual slingload (hover simulation without real DCS weight).
# ctld.slingLoad: false

# Max speed (m/s) while carrying a slingloaded crate before it is lost.
# ctld.maxSlingloadSpeed: 50

# Seconds to wait before a transport can spawn another crate.
# ctld.crateWaitTime: 40

# Crate must be picked up at least once before it can be unpacked.
# ctld.forceCrateToBeMoved: true


# ============================================================
# Hover parameters
# ============================================================

# Lowest allowable AGL height (m) to initiate crate pickup.
# ctld.minimumHoverHeight: 7.5

# Highest allowable AGL height (m) for crate hover.
# ctld.maximumHoverHeight: 12.0

# Maximum horizontal distance (m) from crate centre during hover.
# ctld.maxDistanceFromCrate: 5.5

# Seconds to hold hover above a crate for loading.
# ctld.hoverTime: 10


# ============================================================
# Troops
# ============================================================

# Default number of troops loaded per transport.
# ctld.numberOfTroops: 10

# Max distance (m) from transport to troops to allow extraction.
# ctld.maxExtractDistance: 125

# Max distance (m) for deployed troops to search for enemy.
# ctld.maximumSearchDistance: 4000

# Max distance (m) for troops to move from drop point if no enemy nearby.
# ctld.maximumMoveDistance: 2000

# Allow fast-rope insertion.
# ctld.enableFastRopeInsertion: true

# Maximum safe AGL height (m) for fast-rope (not rappel).
# ctld.fastRopeMaximumHeight: 18.28

# Spawn an RPG soldier with coalition infantry groups.
# ctld.spawnRPGWithCoalition: true

# Spawn a Stinger/Igla MANPAD with groups of 6+ soldiers.
# ctld.spawnStinger: false


# ============================================================
# FOB
# ============================================================

# Enable FOB building via crates.
# ctld.enabledFOBBuilding: true

# Number of large crates required to build a FOB.
# ctld.cratesRequiredForFOB: 3

# Time (s) to build the FOB after the last crate is unpacked.
# ctld.buildTimeFOB: 120

# Allow troops to be picked up at a created FOB.
# ctld.troopPickupAtFOB: true

# Minimum distance (m) from existing logistic zones to deploy a FOB.
# ctld.fobMinDistanceFromZones: 500


# ============================================================
# Beacons
# ============================================================

# Allow players to drop radio beacons.
# ctld.enabledRadioBeaconDrop: true

# Battery life of a deployed beacon (minutes).
# ctld.deployedBeaconBattery: 30

# Sound file for FOB/beacon audio (must be added to the mission).
# ctld.radioSound: beacon.ogg

# Silent beacon file for FC3 aircraft (prevents all beacons being audible).
# ctld.radioSoundFC3: beaconsilent.ogg


# ============================================================
# JTAC
# ============================================================

# Maximum lasing distance (m) for JTAC units.
# ctld.JTAC_maxDistance: 10000

# Allow players to request smoke-on-target from a JTAC.
# ctld.JTAC_allowSmokeRequest: true

# Allow players to request a 9-Line from a JTAC.
# ctld.JTAC_allow9Line: true

# Reschedule delay (s) for the auto-lase loop when actively lasing.
# ctld.JTAC_laseIntervalSeconds: 15

# Reschedule delay (s) for the auto-lase loop when searching for a target.
# ctld.JTAC_searchIntervalSeconds: 10


# ============================================================
# Recon
# ============================================================

# Enable F10 RECON menu.
# ctld.reconF10Menu: true

# Search radius (m) for LOS target detection.
# ctld.reconLosSearchRadius: 2000

# Mark radius (m) for F10 map marks created by recon.
# ctld.reconLosMarkRadius: 100

# Automatically refresh recon LOS target marks.
# ctld.reconAutoRefreshLosTargetMarks: false


# ============================================================
# AA systems (multi-crate)
# ============================================================

# Max number of deployed AA systems per side.
# ctld.AASystemLimitRED: 20
# ctld.AASystemLimitBLUE: 20


# ============================================================
# Vehicles / pack
# ============================================================

# Enable vehicle packing into crates.
# ctld.enablePackingVehicles: true

# Max distance (m) from transport to search for packable vehicles.
# ctld.maximumDistancePackableUnitsSearch: 200

]]

-- ============================================================
-- COMPLEX TABLES
-- These cannot be expressed as YAML key:value pairs.
-- They are applied directly on the CTLDConfig instance.
-- Uncomment and edit the sections you want to override.
-- Each table REPLACES the default entirely when uncommented.
-- ============================================================

local _cfg = CTLDConfig.get()

-- ============================================================
-- Transports — aircraft types allowed to use CTLD
-- (used when ctld.addPlayerAircraftByType = true)
-- Uncomment lines to enable additional aircraft.
-- ============================================================
-- _cfg.settings["aircraftTypeTable"] = {
--     -- Helicopters
--     "Mi-8MT",
--     "Mi-24P",
--     "UH-1H",
--     "CH-47Fbl1",
--     -- "Ka-50", "Ka-50_3",
--     -- "SA342L", "SA342M", "SA342Mistral", "SA342Minigun",
--     -- "UH-60L",          -- mod
--
--     -- Fixed-wing
--     "C-130J-30",
--     -- "Hercules",        -- mod
-- }

-- ============================================================
-- Transport pilot names — unit names authorised to carry CTLD
-- (used when ctld.addPlayerAircraftByType = false, or for AI)
-- ============================================================
-- _cfg.settings["transportPilotNames"] = {
--     "helicargo1", "helicargo2", "helicargo3", "helicargo4", "helicargo5",
--     "helicargo6", "helicargo7", "helicargo8", "helicargo9", "helicargo10",
--     "transport1", "transport2", "transport3",
--     "MEDEVAC #1",  "MEDEVAC #2",  "MEDEVAC #3",
-- }

-- ============================================================
-- Pickup zones
-- Format: { "zone_name", "smoke_color", limit, "active", side, [flag] }
--   smoke_color : "blue"|"red"|"green"|"orange"|"white"|"none"
--   limit       : -1 = unlimited, N = max groups
--   active      : "yes"|"no"
--   side        : 0 = both, 1 = RED, 2 = BLUE
--   flag        : optional DCS flag number to track remaining groups
-- ============================================================
-- _cfg.settings["pickupZones"] = {
--     { "pickzone1", "blue", -1, "yes", 0 },
--     { "pickzone2", "red",  -1, "yes", 0 },
--     { "pickzone3", "none", -1, "yes", 0 },
--     -- { "pickzone4", "none", 5, "yes", 2, 100 }, -- 5 groups max, BLUE only, flag 100
-- }

-- ============================================================
-- Dropoff zones (AI auto-unload when inside radius)
-- Format: { "zone_name", "smoke_color", side }
-- ============================================================
-- _cfg.settings["dropOffZones"] = {
--     { "dropzone1", "green",  2 },
--     { "dropzone2", "blue",   2 },
--     { "dropzone3", "none",   1 },
--     { "dropzone4", "none",   0 }, -- both sides
-- }

-- ============================================================
-- Waypoint zones (AI transport routing waypoints)
-- Format: { "zone_name", "smoke_color", "active", side }
-- ============================================================
-- _cfg.settings["wpZones"] = {
--     { "wpzone1", "green", "yes", 2 },
--     { "wpzone2", "blue",  "yes", 2 },
--     { "wpzone3", "none",  "yes", 1 },
-- }

-- ============================================================
-- Extractable groups — DCS group names that can be extracted
-- ============================================================
-- _cfg.settings["extractableGroups"] = {
--     "extract1", "extract2", "extract3",
--     "extract4", "extract5",
-- }

-- ============================================================
-- Logistic units — unit names that allow crate spawning nearby
-- ============================================================
-- _cfg.settings["logisticUnits"] = {
--     "logistic1", "logistic2", "logistic3",
--     "logistic4", "logistic5",
-- }

-- ============================================================
-- Vehicle transport — aircraft types allowed to carry vehicles
-- ============================================================
-- _cfg.settings["vehicleTransportEnabled"] = {
--     "C-130J-30",
--     -- "Hercules",   -- mod
--     -- "CH-47Fbl1",
-- }

-- ============================================================
-- Dynamic cargo units — aircraft using DCS native cargo system
-- ============================================================
-- _cfg.settings["dynamicCargoUnits"] = {
--     "CH-47Fbl1", "UH-1H", "Mi-8MT", "Mi-24P", "C-130J-30",
-- }

-- ============================================================
-- Unit load limits — max group size per aircraft type
-- ============================================================
-- _cfg.settings["unitLoadLimits"] = {
--     ["Mi-8MT"]    = 16,
--     ["Mi-24P"]    = 10,
--     ["UH-1H"]     = 8,
--     ["CH-47Fbl1"] = 33,
--     ["C-130J-30"] = 80,
--     -- ["UH-60L"]    = 12,  -- mod
--     -- ["Hercules"]  = 30,  -- mod
-- }

-- ============================================================
-- Internal cargo limits — max simultaneous crates per aircraft
-- ============================================================
-- _cfg.settings["internalCargoLimits"] = {
--     ["Mi-8MT"]    = 2,
--     ["CH-47Fbl1"] = 8,
--     ["C-130J-30"] = 20,
-- }

-- ============================================================
-- Unit actions — per-type capability flags
--   crates       : can spawn / load / unpack crates
--   troops       : can load / deploy troops
--   canParachute : enables Parachute menu entries (Feature A)
--   canSlingload : enables slingload hover + Release/Cut menus (Feature B)
-- ============================================================
-- _cfg.settings["unitActions"] = {
--     ["Mi-8MT"]    = { crates = true,  troops = true,  canParachute = false, canSlingload = true  },
--     ["Mi-24P"]    = { crates = true,  troops = true,  canParachute = false, canSlingload = false },
--     ["UH-1H"]     = { crates = true,  troops = true,  canParachute = false, canSlingload = true  },
--     ["CH-47Fbl1"] = { crates = true,  troops = true,  canParachute = false, canSlingload = true  },
--     ["C-130J-30"] = { crates = true,  troops = true,  canParachute = false, canSlingload = false },
--     -- ["UH-60L"]    = { crates = true,  troops = true,  canParachute = false, canSlingload = true  }, -- mod
--     -- ["Hercules"]  = { crates = true,  troops = true,  canParachute = false, canSlingload = false }, -- mod
-- }

-- ============================================================
-- Loadable troop groups
-- Fields: name (display), inf, mg, at, aa, mortar, jtac (counts)
-- Optional: side = 1 (RED only) or 2 (BLUE only); omit for both.
-- ============================================================
-- _cfg.settings["loadableGroups"] = {
--     { name = "Standard Group",    inf = 6, mg = 2, at = 2 },
--     { name = "Anti Air",          inf = 2, aa = 3 },
--     { name = "Anti Tank",         inf = 2, at = 6 },
--     { name = "Mortar Squad",      mortar = 6 },
--     { name = "JTAC Group",        inf = 4, jtac = 1 },
--     { name = "Single JTAC",       jtac = 1 },
--     -- { name = "Red Mortar Squad", mortar = 5, side = 1 }, -- RED only
-- }

-- ============================================================
-- Spawnable crates — the F10 crate menu catalogue
-- Organised by sub-menu category.
--   weight        : unique kg value (lookup key, must be unique)
--   desc          : F10 menu label
--   unit          : DCS type name of the spawned ground unit
--   cratesRequired: number of identical crates needed to unpack
--   side          : 1=RED, 2=BLUE; omit for both
--   multiple      : {w1,w2,...} shortcut to spawn all parts at once
-- ============================================================
-- _cfg.settings["spawnableCrates"] = {
--     ["Combat Vehicles"] = {
--         -- BLUE
--         { weight = 1000.01, desc = "Humvee - MG",       unit = "M1043 HMMWV Armament", side = 2 },
--         { weight = 1000.02, desc = "Humvee - TOW",      unit = "M1045 HMMWV TOW",      side = 2, cratesRequired = 2 },
--         { multiple = { 1000.02, 1000.02 }, desc = "Humvee - TOW - All crates", side = 2 },
--         -- RED
--         { weight = 1000.11, desc = "BTR-D",  unit = "BTR_D",  side = 1 },
--         { weight = 1000.12, desc = "BRDM-2", unit = "BRDM-2", side = 1 },
--     },
--     ["Support"] = {
--         -- BLUE
--         { weight = 1001.01, desc = "Hummer - JTAC",   unit = "Hummer",            side = 2, cratesRequired = 2 },
--         { weight = 1001.02, desc = "M-818 Ammo Truck", unit = "M 818",            side = 2, cratesRequired = 2 },
--         { weight = 1001.03, desc = "M-978 Tanker",     unit = "M978 HEMTT Tanker",side = 2, cratesRequired = 2 },
--         -- RED
--         { weight = 1001.11, desc = "SKP-11 - JTAC",          unit = "SKP-11",      side = 1 },
--         { weight = 1001.12, desc = "Ural-375 Ammo Truck",     unit = "Ural-375",    side = 1, cratesRequired = 2 },
--         { weight = 1001.13, desc = "KAMAZ Ammo Truck",        unit = "KAMAZ Truck", side = 1, cratesRequired = 2 },
--         -- Both
--         { weight = 1001.21, desc = "EWR Radar",    unit = "FPS-117",   cratesRequired = 3 },
--         { weight = 1001.22, desc = "FOB Crate - Small", unit = "FOB-SMALL" },
--     },
--     ["Artillery"] = {
--         -- BLUE
--         { weight = 1002.01, desc = "MLRS",       unit = "MLRS",         side = 2, cratesRequired = 3 },
--         { weight = 1002.04, desc = "Howitzer",   unit = "M-109",        side = 2, cratesRequired = 3 },
--         -- RED
--         { weight = 1002.11, desc = "SPH 2S19 Msta", unit = "SAU Msta", side = 1, cratesRequired = 3 },
--     },
--     ["SAM short range"] = {
--         -- BLUE
--         { weight = 1003.01, desc = "M1097 Avenger",  unit = "M1097 Avenger",  side = 2, cratesRequired = 3 },
--         { weight = 1003.02, desc = "M48 Chaparral",  unit = "M48 Chaparral",  side = 2, cratesRequired = 2 },
--         -- RED
--         { weight = 1003.11, desc = "9K33 Osa",       unit = "Osa 9A33 ln",    side = 1, cratesRequired = 3 },
--         { weight = 1003.14, desc = "9K331 Tor",      unit = "Tor 9A331",      side = 1, cratesRequired = 3 },
--         { weight = 1003.15, desc = "2K22 Tunguska",  unit = "2S6 Tunguska",   side = 1, cratesRequired = 3 },
--     },
--     ["SAM mid range"] = {
--         -- BLUE — HAWK
--         { weight = 1004.01, desc = "HAWK Launcher",       unit = "Hawk ln",  side = 2 },
--         { weight = 1004.02, desc = "HAWK Search Radar",   unit = "Hawk sr",  side = 2 },
--         { weight = 1004.03, desc = "HAWK Track Radar",    unit = "Hawk tr",  side = 2 },
--         { weight = 1004.06, desc = "HAWK Repair",         unit = "HAWK Repair", side = 2 },
--         { multiple = { 1004.01, 1004.02, 1004.03 }, desc = "HAWK - All crates", side = 2 },
--         -- BLUE — NASAMS
--         { weight = 1004.11, desc = "NASAMS Launcher",      unit = "NASAMS_LN_C",          side = 2 },
--         { weight = 1004.12, desc = "NASAMS Radar",         unit = "NASAMS_Radar_MPQ64F1", side = 2 },
--         { weight = 1004.13, desc = "NASAMS Command Post",  unit = "NASAMS_Command_Post",  side = 2 },
--         { multiple = { 1004.11, 1004.12, 1004.13 }, desc = "NASAMS - All crates", side = 2 },
--         -- RED — KUB
--         { weight = 1004.21, desc = "KUB Launcher", unit = "Kub 2P25 ln",  side = 1 },
--         { weight = 1004.22, desc = "KUB Radar",    unit = "Kub 1S91 str", side = 1 },
--         { multiple = { 1004.21, 1004.22 }, desc = "KUB - All crates", side = 1 },
--         -- RED — BUK
--         { weight = 1004.31, desc = "BUK Launcher",      unit = "SA-11 Buk LN 9A310M1", side = 1 },
--         { weight = 1004.32, desc = "BUK Search Radar",  unit = "SA-11 Buk SR 9S18M1",  side = 1 },
--         { weight = 1004.33, desc = "BUK CC Radar",      unit = "SA-11 Buk CC 9S470M1", side = 1 },
--         { multiple = { 1004.31, 1004.32, 1004.33 }, desc = "BUK - All crates", side = 1 },
--     },
--     ["SAM long range"] = {
--         -- BLUE — Patriot
--         { weight = 1005.01, desc = "Patriot Launcher", unit = "Patriot ln",  side = 2 },
--         { weight = 1005.02, desc = "Patriot Radar",    unit = "Patriot str", side = 2 },
--         { weight = 1005.03, desc = "Patriot ECS",      unit = "Patriot ECS", side = 2 },
--         { weight = 1005.07, desc = "Patriot Repair",   unit = "Patriot Repair", side = 2 },
--         { multiple = { 1005.01, 1005.02, 1005.03 }, desc = "Patriot - All crates", side = 2 },
--         -- RED — S-300
--         { weight = 1005.11, desc = "S-300 TEL C",       unit = "S-300PS 5P85C ln",  side = 1 },
--         { weight = 1005.12, desc = "S-300 Track Radar", unit = "S-300PS 40B6M tr",  side = 1 },
--         { weight = 1005.13, desc = "S-300 Search Radar",unit = "S-300PS 40B6MD sr", side = 1 },
--         { weight = 1005.14, desc = "S-300 Big Bird SR", unit = "S-300PS 64H6E sr",  side = 1 },
--         { weight = 1005.15, desc = "S-300 C2",          unit = "S-300PS 54K6 cp",   side = 1 },
--         { multiple = { 1005.11, 1005.12, 1005.13, 1005.14, 1005.15 }, desc = "S-300 - All crates", side = 1 },
--     },
--     ["Drone"] = {
--         { weight = 1006.01, desc = "MQ-9 Reaper - JTAC",    unit = "MQ-9 Reaper",    side = 2 },
--         { weight = 1006.11, desc = "RQ-1A Predator - JTAC", unit = "RQ-1A Predator", side = 1 },
--     },
-- }
