---@meta
---@diagnostic disable

-- ====================================================================================================
-- Start : lib/class.lua
---@diagnostic disable
-- class.lua
-- Minimal OOP micro-framework for Lua 5.1 (DCS sandbox).
--
-- Usage:
--   MyClass = class()
--   function MyClass:init(...)  -- constructor body; receives same args as new()
--
--   local obj = MyClass:new(...)  -- factory: allocates instance, calls init()
--
-- Inheritance:
--   Child = class(Parent)        -- Child inherits all Parent methods
--
-- Singleton pattern (compatible — getInstance() bypasses new()):
--   MySingleton = class()
--   local _inst = nil
--   function MySingleton.getInstance()
--       if not _inst then
--           _inst = setmetatable({}, MySingleton)
--           _inst:init()
--       end
--       return _inst
--   end
-- ============================================================

function class(base)
    local cls = {}
    cls.__index = cls
    if base then setmetatable(cls, { __index = base }) end
    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then instance:init(...) end
        return instance
    end
    return cls
end

-- End : lib/class.lua
-- ====================================================================================================
-- Start : CTLD_config.lua
-- CTLDConfig Singleton Class
-- src version — do not edit source/ original
ctld = ctld or {}

CTLDConfig = {}
CTLDConfig._instance = nil

-- Get the unique instance of the config
function CTLDConfig.get()
    if CTLDConfig._instance == nil then
        CTLDConfig._instance = setmetatable({}, { __index = CTLDConfig })
        CTLDConfig._instance.settings = {}
        CTLDConfig._instance.isLoaded = false
    end
    return CTLDConfig._instance
end

-- Load settings from the text file
function CTLDConfig:load()
    if self.isLoaded then
        return true, "CTLDConfig: Configuration already loaded."
    end
    self.isLoaded                                       = true

    -- ****************************************************************
    -- ******************** DEFAULT CONFIGURATION AREA ****************
    -- ****************************************************************

    -- ═══════════════════════════════════════════════════════════
    -- [1] SYSTEM — Global switches and display options
    -- ═══════════════════════════════════════════════════════════
    self.settings["debug"]                              = false -- if true, enables verbose logging to CTLD.log (requires non-sanitized DCS)
    self.settings["ctldLogPath"]                        = ""    -- override log file path (default: DCS Saved Games folder); empty = default
    self.settings["debugScreenLog"]                     = false -- if true, ctld.utils.log() also echoes to DCS screen via outText
    self.settings["debugScreenLogDuration"]             = 10    -- seconds each screen log message is displayed (requires debugScreenLog=true)
    self.settings["CTLD_ctldStatusF10"]                 = true  -- enables F10 CTLD Status menus
    self.settings["staticBugWorkaround"]                = false --    DCS had a bug where destroying statics would cause a crash. If this happens again, set this to TRUE
    self.settings["disableAllSmoke"]                    = false -- if true, all smoke is diabled at pickup and drop off zones regardless of settings below. Leave false to respect settings below
    self.settings["addPlayerAircraftByType"]            = true  -- Allow units to CTLD by aircraft type and not by pilot name - this is done everytime a player enters a new units
    self.settings["location_DMS"]                       = false -- shows coordinates as Degrees Minutes Seconds instead of Degrees Decimal minutes

    -- ═══════════════════════════════════════════════════════════
    -- [2] TRANSPORTS — Aircraft types and pilot names
    -- ═══════════════════════════════════════════════════════════

    -- If ctld.addPlayerAircraftByType = True, comment or uncomment lines to allow aircraft's type carry CTLD
    self.settings["aircraftTypeTable"]                  = {
        --%%%%% MODS %%%%%
        --"Bronco-OV-10A",
        --"Hercules",
        --"SK-60",
        --"UH-60L",
        --"T-45",

        --%%%%% CHOPPERS %%%%%
        --"Ka-50",
        --"Ka-50_3",
        "Mi-8MT",
        "Mi-24P",
        --"SA342L",
        --"SA342M",
        --"SA342Mistral",
        --"SA342Minigun",
        "UH-1H",
        "CH-47Fbl1",

        --%%%%% AIRCRAFTS %%%%%
        --"C-101EB",
        --"C-101CC",
        --"Christen Eagle II",
        --"L-39C",
        --"L-39ZA",
        --"MB-339A",
        --"MB-339APAN",
        --"Mirage-F1B",
        --"Mirage-F1BD",
        --"Mirage-F1BE",
        --"Mirage-F1BQ",
        --"Mirage-F1DDA",
        --"Su-25T",
        --"Yak-52",
        "C-130J-30",

        --%%%%% WARBIRDS %%%%%
        --"Bf-109K-4",
        --"Fw 190A8",
        --"FW-190D9",
        --"I-16",
        --"MosquitoFBMkVI",
        --"P-47D-30",
        --"P-47D-40",
        --"P-51D",
        --"P-51D-30-NA",
        --"SpitfireLFMkIX",
        --"SpitfireLFMkIXCW",
        --"TF-51D",
    }

    -- Use any of the predefined names or set your own ones
    self.settings["transportPilotNames"]                = {
        "helicargo1",
        "helicargo2",
        "helicargo3",
        "helicargo4",
        "helicargo5",
        "helicargo6",
        "helicargo7",
        "helicargo8",
        "helicargo9",
        "helicargo10",

        "helicargo11",
        "helicargo12",
        "helicargo13",
        "helicargo14",
        "helicargo15",
        "helicargo16",
        "helicargo17",
        "helicargo18",
        "helicargo19",
        "helicargo20",

        "helicargo21",
        "helicargo22",
        "helicargo23",
        "helicargo24",
        "helicargo25",

        "MEDEVAC #1",
        "MEDEVAC #2",
        "MEDEVAC #3",
        "MEDEVAC #4",
        "MEDEVAC #5",
        "MEDEVAC #6",
        "MEDEVAC #7",
        "MEDEVAC #8",
        "MEDEVAC #9",
        "MEDEVAC #10",
        "MEDEVAC #11",
        "MEDEVAC #12",
        "MEDEVAC #13",
        "MEDEVAC #14",
        "MEDEVAC #15",
        "MEDEVAC #16",

        "MEDEVAC RED #1",
        "MEDEVAC RED #2",
        "MEDEVAC RED #3",
        "MEDEVAC RED #4",
        "MEDEVAC RED #5",
        "MEDEVAC RED #6",
        "MEDEVAC RED #7",
        "MEDEVAC RED #8",
        "MEDEVAC RED #9",
        "MEDEVAC RED #10",
        "MEDEVAC RED #11",
        "MEDEVAC RED #12",
        "MEDEVAC RED #13",
        "MEDEVAC RED #14",
        "MEDEVAC RED #15",
        "MEDEVAC RED #16",
        "MEDEVAC RED #17",
        "MEDEVAC RED #18",
        "MEDEVAC RED #19",
        "MEDEVAC RED #20",
        "MEDEVAC RED #21",

        "MEDEVAC BLUE #1",
        "MEDEVAC BLUE #2",
        "MEDEVAC BLUE #3",
        "MEDEVAC BLUE #4",
        "MEDEVAC BLUE #5",
        "MEDEVAC BLUE #6",
        "MEDEVAC BLUE #7",
        "MEDEVAC BLUE #8",
        "MEDEVAC BLUE #9",
        "MEDEVAC BLUE #10",
        "MEDEVAC BLUE #11",
        "MEDEVAC BLUE #12",
        "MEDEVAC BLUE #13",
        "MEDEVAC BLUE #14",
        "MEDEVAC BLUE #15",
        "MEDEVAC BLUE #16",
        "MEDEVAC BLUE #17",
        "MEDEVAC BLUE #18",
        "MEDEVAC BLUE #19",
        "MEDEVAC BLUE #20",
        "MEDEVAC BLUE #21",

        -- *** AI transports names (different names only to ease identification in mission) ***

        -- Use any of the predefined names or set your own ones
        "transport1",
        "transport2",
        "transport3",
        "transport4",
        "transport5",
        "transport6",
        "transport7",
        "transport8",
        "transport9",
        "transport10",

        "transport11",
        "transport12",
        "transport13",
        "transport14",
        "transport15",
        "transport16",
        "transport17",
        "transport18",
        "transport19",
        "transport20",

        "transport21",
        "transport22",
        "transport23",
        "transport24",
        "transport25",
    }

    -- ═══════════════════════════════════════════════════════════
    -- [3] CRATES — Crate spawning, hover pickup, sling load, timers
    -- ═══════════════════════════════════════════════════════════
    self.settings["enableCrates"]                       = true  -- if false, Helis will not be able to spawn or unpack crates so will be normal CTTS
    self.settings["enableAllCrates"]                    = true  -- if false, the "all crates" menu items will not be displayed
    self.settings["enableHoverSlingload"]               = true  -- if false, hover-based slingload pickup is disabled; crates can still be loaded via F10 menu (loadCrateFromMenu)
    self.settings["loadCrateFromMenu"]                  = true  -- if set to true, you can load crates with the F10 menu OR hovering, in case of using choppers and planes for example.
    self.settings["slingLoad"]                          = false -- if false, crates can be used WITHOUT slingloading, by hovering above the crate, simulating slingloading but not the weight...
    -- There are some bug with Sling-loading that can cause crashes, if these occur set slingLoad to false
    -- to use the other method.
    -- Set staticBugFix    to FALSE if use set ctld.slingLoad to TRUE
    self.settings["enableSmokeDrop"]                    = true -- if false, helis and c-130 will not be able to drop smoke
    self.settings["smokeAutoResume"]                    = false -- Feature H: global default for smoke auto-resume (per-player toggle overrides)
    self.settings["smokeAutoResumeInterval"]            = 270  -- Feature H: seconds before a smoke is re-triggered (default 4min30, DCS smoke lasts ~5min)
    self.settings["crateWaitTime"]                      = 40   -- time in seconds to wait before you can spawn another crate
    self.settings["minimumDeployDistance"]              = 1000 -- minimum distance from a friendly pickup zone where you can deploy a crate
    self.settings["maximumDistanceLogistic"]            = 200  -- max distance from vehicle to logistics to allow a loading or spawning operation

    -- Simulated Sling load configuration (Feature B)
    self.settings["minimumHoverHeight"]                 = 7.5  -- Lowest allowable height for crate hover
    self.settings["maximumHoverHeight"]                 = 12.0 -- Highest allowable height for crate hover
    self.settings["maxDistanceFromCrate"]               = 5.5  -- Maximum distance from from crate for hover
    self.settings["hoverTime"]                          = 10   -- Time to hold hover above a crate for loading in seconds
    self.settings["maxSlingloadSpeed"]                  = 50   -- Max speed (m/s) while carrying a slingloaded crate — exceed it and the crate is lost
    -- end of Simulated Sling load configuration

    -- ═══════════════════════════════════════════════════════════
    -- [4] TROOPS — Infantry loading, fast rope, extraction limits
    -- ═══════════════════════════════════════════════════════════
    self.settings["numberOfTroops"]                     = 10       -- default number of troops to load on a transport heli or C-130
    -- also works as maximum size of group that'll fit into a helicopter unless overridden
    self.settings["enableFastRopeInsertion"]            = true     -- allows you to drop troops by fast rope
    self.settings["fastRopeMaximumHeight"]              = 18.28    -- in meters which is 60 ft max fast rope (not rappell) safe height
    self.settings["spawnRPGWithCoalition"]              = true     --spawns a friendly RPG unit with Coalition forces
    self.settings["spawnStinger"]                       = false    -- spawns a stinger / igla soldier with a group of 6 or more soldiers!
    self.settings["allowRandomAiTeamPickups"]           = false    -- Allows the AI to randomize the loading of infantry teams (specified below) at pickup zones
    -- Limit the dropping of infantry teams -- this limit control is inactive if ctld.nbLimitSpawnedTroops = {0, 0} ----
    self.settings["nbLimitSpawnedTroops"]               = { 0, 0 } -- {redLimitInfantryCount, blueLimitInfantryCount} when this cumulative number of troops is reached, no more troops can be loaded onboard
    self.settings["InfantryInGameCount"]                = { 0, 0 } -- {redCoaInfantryCount, blueCoaInfantryCount}
    self.settings["maxExtractDistance"]                 = 125      -- max distance from vehicle to troops to allow a group extraction
    self.settings["maximumSearchDistance"]              = 4000     -- max distance for troops to search for enemy
    self.settings["maximumMoveDistance"]                = 2000     -- max distance for troops to move from drop point if no enemy is nearby

    -- ═══════════════════════════════════════════════════════════
    -- [5] VEHICLES — Packable vehicles and transport configuration
    -- ═══════════════════════════════════════════════════════════
    self.settings["enablePackingVehicles"]              = true                                          -- if true, vehicles can be packed into crates
    self.settings["maximumDistancePackableUnitsSearch"] = 200                                           -- max distance from transportUnit to search for packable units in meters
    self.settings["vehiclesForTransportRED"]            = { "BRDM-2", "BTR_D" }                         -- vehicles to load onto Il-76 - Alternatives {"Strela-1 9P31","BMP-1"}
    self.settings["vehiclesForTransportBLUE"]           = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" } -- vehicles to load onto c130 - Alternatives {"M1128 Stryker MGS","M1097 Avenger"}
    self.settings["vehiclesWeight"]                     = {
        ["BRDM-2"] = 7000,
        ["BTR_D"] = 8000,
        ["M1045 HMMWV TOW"] = 3220,
        ["M1043 HMMWV Armament"] = 2500
    }

    -- ═══════════════════════════════════════════════════════════
    -- [6] FOB — Forward Operating Base building and configuration
    -- ═══════════════════════════════════════════════════════════
    self.settings["enabledFOBBuilding"]                 = true -- if true, you can load a crate INTO a C-130 than when unpacked creates a Forward Operating Base (FOB) which is a new place to spawn (crates) and carry crates from
    -- In future i'd like it to be a FARP but so far that seems impossible...
    -- You can also enable troop Pickup at FOBS
    self.settings["troopPickupAtFOB"]                   = true -- if true, troops can also be picked up at a created FOB
    self.settings["buildTimeFOB"]                       = 120  -- time in seconds for the FOB to be built
    self.settings["fobMinDistanceFromZones"]            = 500  -- minimum distance (m) from existing logistic zones to deploy a FOB
    self.settings["fobLogisticZoneRadius"]              = 150  -- radius (m) of the logistic zone created around a deployed FOB
    self.settings["fobDestructionThreshold"]            = 0.5  -- fraction of scene objects destroyed before FOB is considered lost (0.0–1.0)
    self.settings["fobTroopPickupRadius"]               = 150  -- radius (m) within which troops can be picked up at a FOB (troopPickupAtFOB)


    -- ═══════════════════════════════════════════════════════════
    -- [FA] PARACHUTE — Virtual parachute drop (Feature A)
    -- ═══════════════════════════════════════════════════════════
    -- Minimum altitude AGL (m) required to initiate a parachute drop.
    self.settings["parachuteMinAltitudeCrates"]           = 30   -- m AGL
    self.settings["parachuteMinAltitudeTroops"]           = 50   -- m AGL (safety margin for personnel)
    self.settings["parachuteMinAltitudeVehicles"]         = 30   -- m AGL
    -- Vertical descent speed (m/s) — determines time-to-ground.
    self.settings["parachuteDescentRateCrates"]           = 5    -- m/s
    self.settings["parachuteDescentRateTroops"]           = 5    -- m/s
    self.settings["parachuteDescentRateVehicles"]         = 8    -- m/s (heavier load)
    -- Horizontal drift physics.
    self.settings["parachuteInertiaFactor"]               = 0.3  -- fraction of transport velocity applied as forward drift (0.0–1.0)
    self.settings["parachuteLateralDriftMin"]             = 10   -- m, minimum random lateral drift per unit
    self.settings["parachuteLateralDriftMax"]             = 80   -- m, maximum random lateral drift per unit
    -- Auto-unpack radius for parachuted crates (wider than normal because of dispersion).
    self.settings["autoUnpackRadiusParachute"]            = 1000 -- m

    -- ═══════════════════════════════════════════════════════════
    -- [7] BEACONS — Radio beacon drop, sounds and battery life
    -- ═══════════════════════════════════════════════════════════
    self.settings["enabledRadioBeaconDrop"]               = true -- if its set to false then beacons cannot be dropped by units
    self.settings["radioSound"]                           =
    "beacon.ogg"                                                 -- the name of the sound file to use for the FOB radio beacons. If this isnt added to the mission BEACONS WONT WORK!
    self.settings["radioSoundFC3"]                        =
    "beaconsilent.ogg"                                           -- name of the second silent radio file, used so FC3 aircraft dont hear ALL the beacon noises... :)
    self.settings["deployedBeaconBattery"]                = 30   -- the battery on deployed beacons will last for this number minutes before needing to be re-deployed

    -- ═══════════════════════════════════════════════════════════
    -- [8] AA — Anti-Aircraft system limits and crate stacking
    -- ═══════════════════════════════════════════════════════════
    self.settings["aaLaunchers"]                          = 3 -- controls how many launchers to add to the AA systems when its spawned if no amount is specified in the template.
    -- Sets a limit on the number of active AA systems that can be built for RED.
    -- A system is counted as Active if its fully functional and has all parts
    -- If a system is partially destroyed, it no longer counts towards the total
    -- When this limit is hit, a player will still be able to get crates for an AA system, just unable
    -- to unpack them
    self.settings["AASystemLimitRED"]                     = 20 -- Red side limit
    self.settings["AASystemLimitBLUE"]                    = 20 -- Blue side limit

    -- Allows players to create systems using as many crates as they like
    -- Example : an amount X of patriot launcher crates allows for Y launchers to be deployed, if a player brings 2*X+Z crates (Z being lower then X), then deploys the patriot site, 2*Y launchers will be in the group and Z launcher crate will be left over
    self.settings["AASystemCrateStacking"]                = false
    --END AA SYSTEM CONFIG ------------------------------------

    -- ═══════════════════════════════════════════════════════════
    -- [9] JTAC — JTAC crate limits, smoke, lasing and 9-Line
    -- ═══════════════════════════════════════════════════════════
    self.settings["JTAC_LIMIT_RED"]                       = 10    -- max number of JTAC Crates for the RED Side
    self.settings["JTAC_LIMIT_BLUE"]                      = 10    -- max number of JTAC Crates for the BLUE Side
    self.settings["JTAC_dropEnabled"]                     = true  -- allow JTAC Crate spawn from F10 menu
    self.settings["JTAC_maxDistance"]                     = 10000 -- How far a JTAC can "see" in meters (with Line of Sight)
    self.settings["JTAC_smokeOn_RED"]                     = false -- enables marking of target with smoke for RED forces
    self.settings["JTAC_smokeOn_BLUE"]                    = false -- enables marking of target with smoke for BLUE forces
    self.settings["JTAC_smokeColour_RED"]                 = 4     -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
    self.settings["JTAC_smokeColour_BLUE"]                = 1     -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
    self.settings["JTAC_smokeMarginOfError"]              = 50    -- error that the JTAC is allowed to make when popping a smoke (in meters)
    self.settings["JTAC_smokeOffset_x"]                   = 0.0   -- distance in the X direction from target to smoke (meters)
    self.settings["JTAC_smokeOffset_y"]                   = 2.0   -- distance in the Y direction from target to smoke (meters)
    self.settings["JTAC_smokeOffset_z"]                   = 0.0   -- distance in the z direction from target to smoke (meters)
    self.settings["JTAC_jtacStatusF10"]                   = true  -- enables F10 JTAC Status menu
    self.settings["JTAC_location"]                        = true  -- shows location of target in JTAC message
    self.settings["location_DMS"]                         = false -- shows coordinates as Degrees Minutes Seconds instead of Degrees Decimal minutes
    self.settings["JTAC_lock"]                            =
    "all"                                                         -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units
    self.settings["JTAC_allowStandbyMode"]                = true  -- if true, allow players to toggle lasing on/off
    self.settings["JTAC_laseSpotCorrections"]             = true  -- if true, each JTAC will have a special option (toggle on/off) available in it's menu to attempt to lead the target, taking into account current wind conditions and the speed of the target (particularily useful against moving heavy armor)
    self.settings["JTAC_allowSmokeRequest"]               = true  -- if true, allow players to request a smoke on target (temporary)
    self.settings["JTAC_allow9Line"]                      = true  -- if true, allow players to ask for a 9Line (individual) for a specific JTAC's target
    self.settings["JTAC_laseIntervalSeconds"]             = 15    -- auto-lase loop reschedule delay (s) when actively lasing a target
    self.settings["JTAC_searchIntervalSeconds"]           = 10    -- auto-lase loop reschedule delay (s) when searching for a target (no target acquired)
    self.settings["JTAC_targetDeconfliction"]             = true  -- prevent multiple JTACs from lasing the same target simultaneously
    self.settings["enableAutoOrbitingFlyingJtacOnTarget"] = true  -- if true, flying JTAC drones auto-orbit detected targets

    -- JTAC role is declared via isJTAC=true in spawnableCrates descriptors (no separate type list)
    self.settings["JTAC_droneRadius"]                     = 1000 -- fallback orbit radius (m) when crate specificParams absent
    self.settings["JTAC_droneAltitude"]                   = 4000 -- fallback orbit altitude AGL (m) when crate specificParams absent

    -- JTAC equipment requestable via F10 JTAC > Request JTAC Equipment, per coalition.
    -- Values are exact DCS type names passed directly to coalition.addGroup — no pattern matching.
    -- Note: DCS may encode the dash character differently in some typenames (legacy issue with SKP-11).
    -- If a vehicle does not appear in-game, verify the typename via unit:getTypeName() in a test script.
    self.settings["JTAC_unitTypeNames"]                   = {
        [1] = { "SKP-11" }, -- RED: JTAC vehicles available to RED coalition
        [2] = { "Hummer" }, -- BLUE: JTAC vehicles available to BLUE coalition
    }

    -- ═══════════════════════════════════════════════════════════
    -- [10] RECON — Recon menu, LOS search, auto-refresh
    -- ═══════════════════════════════════════════════════════════
    self.settings["reconF10Menu"]                         = true  -- enable RECON submenu in F10 CTLD menu
    self.settings["reconEnabled"]                         = false -- master switch: set to true to activate RECON functionality
    self.settings["reconSearchRadius"]                    = 5000  -- LOS detection radius (m) around the scanning unit
    self.settings["reconMinAltitude"]                     = 50    -- minimum AGL altitude (m) required to perform a scan
    self.settings["reconRefreshInterval"]                 = 10    -- auto-refresh interval (s) between target position updates
    self.settings["reconIconScale"]                       = 1.0   -- icon size multiplier (1.0 = default sizes; increase for larger icons)

    -- ═══════════════════════════════════════════════════════════
    -- [M10] MINEFIELD — Landmine deployment options
    -- ═══════════════════════════════════════════════════════════
    self.settings["showMinefieldOnF10Map"]                = true -- if true, draws a bounding quad on the F10 map when a minefield is deployed

    -- ═══════════════════════════════════════════════════════════
    -- [11] ZONES — Pickup, drop-off and waypoint zones
    -- ═══════════════════════════════════════════════════════════

    -- Available colors (anything else like "none" disables smoke): "green", "red", "white", "orange", "blue", "none",
    -- Use any of the predefined names or set your own ones
    -- You can add number as a third option to limit the number of soldier or vehicle groups that can be loaded from a zone.
    -- Dropping back a group at a limited zone will add one more to the limit
    -- If a zone isn't ACTIVE then you can't pickup from that zone until the zone is activated by ctld.activatePickupZone
    -- using the Mission editor
    -- You can pickup from a SHIP by adding the SHIP UNIT NAME instead of a zone name
    -- Side - Controls which side can load/unload troops at the zone
    -- Flag Number - Optional last field. If set the current number of groups remaining can be obtained from the flag value
    --pickupZones = { "Zone name or Ship Unit Name", "smoke color", "limit (-1 unlimited)", "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", flag number (optional) }
    self.settings["pickupZones"]                          = {
        { "pickzone1",   "blue", -1, "yes", 0 },
        { "pickzone2",   "red",  -1, "yes", 0 },
        { "pickzone3",   "none", -1, "yes", 0 },
        { "pickzone4",   "none", -1, "yes", 0 },
        { "pickzone5",   "none", -1, "yes", 0 },
        { "pickzone6",   "none", -1, "yes", 0 },
        { "pickzone7",   "none", -1, "yes", 0 },
        { "pickzone8",   "none", -1, "yes", 0 },
        { "pickzone9",   "none", 5,  "yes", 1 }, -- limits pickup zone 9 to 5 groups of soldiers or vehicles, only red can pick up
        { "pickzone10",  "none", 10, "yes", 2 }, -- limits pickup zone 10 to 10 groups of soldiers or vehicles, only blue can pick up

        { "pickzone11",  "blue", 20, "no",  2 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
        { "pickzone12",  "red",  20, "no",  1 }, -- limits pickup zone 11 to 20 groups of soldiers or vehicles, only blue can pick up. Zone starts inactive!
        { "pickzone13",  "none", -1, "yes", 0 },
        { "pickzone14",  "none", -1, "yes", 0 },
        { "pickzone15",  "none", -1, "yes", 0 },
        { "pickzone16",  "none", -1, "yes", 0 },
        { "pickzone17",  "none", -1, "yes", 0 },
        { "pickzone18",  "none", -1, "yes", 0 },
        { "pickzone19",  "none", 5,  "yes", 0 },
        { "pickzone20",  "none", 10, "yes", 0, 1000 }, -- optional extra flag number to store the current number of groups available in

        { "USA Carrier", "blue", 10, "yes", 0, 1001 }, -- instead of a Zone Name you can also use the UNIT NAME of a ship
    }

    -- dropOffZones = {"name","smoke colour",0,side 1 = Red or 2 = Blue or 0 = Both sides}
    self.settings["dropOffZones"]                         = {
        { "dropzone1",  "green",  2 },
        { "dropzone2",  "blue",   2 },
        { "dropzone3",  "orange", 2 },
        { "dropzone4",  "none",   2 },
        { "dropzone5",  "none",   1 },
        { "dropzone6",  "none",   1 },
        { "dropzone7",  "none",   1 },
        { "dropzone8",  "none",   1 },
        { "dropzone9",  "none",   1 },
        { "dropzone10", "none",   1 },
    }

    --wpZones = { "Zone name", "smoke color",    "ACTIVE (yes/no)", "side (0 = Both sides / 1 = Red / 2 = Blue )", }
    self.settings["wpZones"]                              = {
        { "wpzone1",  "green",  "yes", 2 },
        { "wpzone2",  "blue",   "yes", 2 },
        { "wpzone3",  "orange", "yes", 2 },
        { "wpzone4",  "none",   "yes", 2 },
        { "wpzone5",  "none",   "yes", 2 },
        { "wpzone6",  "none",   "yes", 1 },
        { "wpzone7",  "none",   "yes", 1 },
        { "wpzone8",  "none",   "yes", 1 },
        { "wpzone9",  "none",   "yes", 1 },
        { "wpzone10", "none",   "no",  0 }, -- Both sides as its set to 0
    }

    -- ═══════════════════════════════════════════════════════════
    -- MISC — Extractable groups, logistics, unit limits and crate templates
    -- ═══════════════════════════════════════════════════════════

    -- *************** Optional Extractable GROUPS *****************

    -- Use any of the predefined names or set your own ones
    self.settings["extractableGroups"]                    = {
        "extract1",
        "extract2",
        "extract3",
        "extract4",
        "extract5",
        "extract6",
        "extract7",
        "extract8",
        "extract9",
        "extract10",

        "extract11",
        "extract12",
        "extract13",
        "extract14",
        "extract15",
        "extract16",
        "extract17",
        "extract18",
        "extract19",
        "extract20",

        "extract21",
        "extract22",
        "extract23",
        "extract24",
        "extract25",
    }

    -- ************** Logistics UNITS FOR CRATE SPAWNING ******************

    -- Use any of the predefined names or set your own ones
    -- When a logistic unit is destroyed, you will no longer be able to spawn crates
    self.settings["dynamicLogisticUnitsIndex"]            = 0 -- This is the unit that will be spawned first and then subsequent units will be from the next in the list
    self.settings["logisticUnits"]                        = {
        "logistic1",
        "logistic2",
        "logistic3",
        "logistic4",
        "logistic5",
        "logistic6",
        "logistic7",
        "logistic8",
        "logistic9",
        "logistic10",
    }

    -- ************** UNITS ABLE TO TRANSPORT VEHICLES ******************
    -- Add the model name of the unit that you want to be able to transport and deploy vehicles
    -- units db has all the names or you can extract a mission.miz file by making it a zip and looking
    -- in the contained mission file
    self.settings["vehicleTransportEnabled"]              = {
        "76MD", -- the il-76 mod doesnt use a normal - sign so il-76md wont match... !!!! GRR
        "Hercules",
        "C-130J-30",
        "UH-1H",
        "Mi-8",
        --"CH-47Fbl1",
    }

    -- ************** Units able to use DCS dynamic cargo system ******************
    -- DCS (version) added the ability to load and unload cargo from aircraft.
    -- Units listed here will spawn a cargo static that can be loaded with the standard DCS cargo system
    -- We will also use this to make modifications to the menu and other checks and messages
    self.settings["dynamicCargoUnits"]                    = {
        "CH-47Fbl1",
        "UH-1H",
        "Mi-8MT",
        "Mi-24P",
        "C-130J-30"
    }

    -- ************** Maximum Units SETUP for UNITS ******************
    -- Put the name of the Unit you want to limit group sizes too
    -- i.e
    -- ["UH-1H"] = 10,
    --
    -- Will limit UH1 to only transport groups with a size 10 or less
    -- Make sure the unit name is exactly right or it wont work

    self.settings["unitLoadLimits"]                       = {
        -- Remove the -- below to turn on options
        -- ["SA342Mistral"] = 4,
        -- ["SA342L"] = 4,
        -- ["SA342M"] = 4,

        --%%%%% MODS %%%%%
        --["Bronco-OV-10A"] = 4,
        ["Hercules"] = 30,
        --["SK-60"] = 1,
        ["UH-60L"] = 12,
        --["T-45"] = 1,

        --%%%%% CHOPPERS %%%%%
        ["Mi-8MT"] = 16,
        ["Mi-24P"] = 10,
        --["SA342L"] = 4,
        --["SA342M"] = 4,
        --["SA342Mistral"] = 4,
        --["SA342Minigun"] = 3,
        ["UH-1H"] = 8,
        ["CH-47Fbl1"] = 33,

        --%%%%% AIRCRAFTS %%%%%
        --["C-101EB"] = 1,
        --["C-101CC"] = 1,
        --["Christen Eagle II"] = 1,
        --["L-39C"] = 1,
        --["L-39ZA"] = 1,
        --["MB-339A"] = 1,
        --["MB-339APAN"] = 1,
        --["Mirage-F1B"] = 1,
        --["Mirage-F1BD"] = 1,
        --["Mirage-F1BE"] = 1,
        --["Mirage-F1BQ"] = 1,
        --["Mirage-F1DDA"] = 1,
        --["Su-25T"] = 1,
        --["Yak-52"] = 1,
        ["C-130J-30"] = 80

        --%%%%% WARBIRDS %%%%%
        --["Bf-109K-4"] = 1,
        --["Fw 190A8"] = 1,
        --["FW-190D9"] = 1,
        --["I-16"] = 1,
        --["MosquitoFBMkVI"] = 1,
        --["P-47D-30"] = 1,
        --["P-47D-40"] = 1,
        --["P-51D"] = 1,
        --["P-51D-30-NA"] = 1,
        --["SpitfireLFMkIX"] = 1,
        --["SpitfireLFMkIXCW"] = 1,
        --["TF-51D"] = 1,
    }

    -- Put the name of the Unit you want to enable loading multiple crates
    self.settings["internalCargoLimits"]                  = {

        -- Remove the -- below to turn on options
        ["Mi-8MT"] = 2,
        ["CH-47Fbl1"] = 8,
        ["C-130J-30"] = 20
    }


    -- ************** Allowable actions for UNIT TYPES ******************
    -- Put the name of the Unit you want to limit actions for
    -- NOTE - the unit must've been listed in the transportPilotNames list above
    -- This can be used in conjunction with the options above for group sizes
    -- By default you can load both crates and troops unless overriden below
    -- i.e
    -- ["UH-1H"] = {crates=true, troops=false},
    --
    -- Will limit UH1 to only transport CRATES but NOT TROOPS
    --
    -- ["SA342Mistral"] = {crates=fales, troops=true},
    -- Will allow Mistral Gazelle to only transport crates, not troops

    self.settings["unitActions"] = {

        -- Remove the -- below to turn on options
        -- ["SA342Mistral"] = {crates=true, troops=true},
        -- ["SA342L"] = {crates=false, troops=true},
        -- ["SA342M"] = {crates=false, troops=true},

        -- canParachute=true  enables "Parachute Crates/Troops/Vehicle" menu entries (Feature A).
        -- canSlingload=true  enables "Release Slingload" / "Cut Slingload" menu entries (Feature B)
        --                    and activates hover-pickup polling for this aircraft type.
        -- Helicopters support slingload; fixed-wing aircraft do not.

        --%%%%% MODS %%%%%
        --["Bronco-OV-10A"] = {crates=true, troops=true, canParachute=false, canSlingload=false},
        ["Hercules"]  = { crates = true, troops = true, canParachute = false, canSlingload = false },
        ["SK-60"]     = { crates = true, troops = true, canParachute = false, canSlingload = false },
        ["UH-60L"]    = { crates = true, troops = true, canParachute = false, canSlingload = true },
        ["C-130J-30"] = { crates = true, troops = true, canParachute = false, canSlingload = false },
        --["T-45"] = {crates=true, troops=true, canParachute=false, canSlingload=false},

        --%%%%% CHOPPERS %%%%%
        --["Ka-50"]   = {crates=true, troops=false, canParachute=false, canSlingload=true},
        --["Ka-50_3"] = {crates=true, troops=false, canParachute=false, canSlingload=true},
        ["Mi-8MT"]    = { crates = true, troops = true, canParachute = false, canSlingload = true },
        ["Mi-24P"]    = { crates = true, troops = true, canParachute = false, canSlingload = false },
        --["SA342L"]      = {crates=false, troops=true, canParachute=false, canSlingload=false},
        --["SA342M"]      = {crates=false, troops=true, canParachute=false, canSlingload=false},
        --["SA342Mistral"] = {crates=false, troops=true, canParachute=false, canSlingload=false},
        --["SA342Minigun"] = {crates=false, troops=true, canParachute=false, canSlingload=false},
        ["UH-1H"]     = { crates = true, troops = true, canParachute = false, canSlingload = true },
        ["CH-47Fbl1"] = { crates = true, troops = true, canParachute = false, canSlingload = true },

        --%%%%% AIRCRAFTS %%%%%
        --["C-101EB"] = {crates=true, troops=true},
        --["C-101CC"] = {crates=true, troops=true},
        --["Christen Eagle II"] = {crates=true, troops=true},
        --["L-39C"] = {crates=true, troops=true},
        --["L-39ZA"] = {crates=true, troops=true},
        --["MB-339A"] = {crates=true, troops=true},
        --["MB-339APAN"] = {crates=true, troops=true},
        --["Mirage-F1B"] = {crates=true, troops=true},
        --["Mirage-F1BD"] = {crates=true, troops=true},
        --["Mirage-F1BE"] = {crates=true, troops=true},
        --["Mirage-F1BQ"] = {crates=true, troops=true},
        --["Mirage-F1DDA"] = {crates=true, troops=true},
        --["Su-25T"]= {crates=true, troops=false},
        --["Yak-52"] = {crates=true, troops=true},

        --%%%%% WARBIRDS %%%%%
        --["Bf-109K-4"] = {crates=true, troops=false},
        --["Fw 190A8"] = {crates=true, troops=false},
        --["FW-190D9"] = {crates=true, troops=false},
        --["I-16"] = {crates=true, troops=false},
        --["MosquitoFBMkVI"] = {crates=true, troops=true},
        --["P-47D-30"] = {crates=true, troops=false},
        --["P-47D-40"] = {crates=true, troops=false},
        --["P-51D"] = {crates=true, troops=false},
        --["P-51D-30-NA"] = {crates=true, troops=false},
        --["SpitfireLFMkIX"] = {crates=true, troops=false},
        --["SpitfireLFMkIXCW"] = {crates=true, troops=false},
        --["TF-51D"] = {crates=true, troops=true},
    }

    -- ************** WEIGHT CALCULATIONS FOR INFANTRY GROUPS ******************

    -- Infantry groups weight is calculated based on the soldiers' roles, and the weight of their kit
    -- Every soldier weights between 90% and 120% of ctld.SOLDIER_WEIGHT, and they all carry a backpack and their helmet (ctld.KIT_WEIGHT)
    -- Standard grunts have a rifle and ammo (ctld.RIFLE_WEIGHT)
    -- AA soldiers have a MANPAD tube (ctld.MANPAD_WEIGHT)
    -- Anti-tank soldiers have a RPG and a rocket (ctld.RPG_WEIGHT)
    -- Machine gunners have the squad MG and 200 bullets (ctld.MG_WEIGHT)
    -- JTAC have the laser sight, radio and binoculars (ctld.JTAC_WEIGHT)
    -- Mortar servants carry their tube and a few rounds (ctld.MORTAR_WEIGHT)

    self.settings["SOLDIER_WEIGHT"] = 80 -- kg, will be randomized between 90% and 120%
    self.settings["KIT_WEIGHT"] = 20     -- kg
    self.settings["RIFLE_WEIGHT"] = 5    -- kg
    self.settings["MANPAD_WEIGHT"] = 18  -- kg
    self.settings["RPG_WEIGHT"] = 7.6    -- kg
    self.settings["MG_WEIGHT"] = 10      -- kg
    self.settings["MORTAR_WEIGHT"] = 26  -- kg
    self.settings["JTAC_WEIGHT"] = 15    -- kg

    -- ************** INFANTRY GROUPS FOR PICKUP ******************
    -- Unit Types
    -- inf is normal infantry
    -- mg is M249
    -- at is RPG-16
    -- aa is Stinger or Igla
    -- mortar is a 2B11 mortar unit
    -- jtac is a JTAC soldier, which will use JTACAutoLase
    -- You must add a name to the group for it to work
    -- You can also add an optional coalition side to limit the group to one side
    -- for the side - 2 is BLUE and 1 is RED
    self.settings["loadableGroups"] = {
        { name = ctld.tr("Standard Group"),                   inf = 6,    mg = 2,  at = 2 }, -- will make a loadable group with 6 infantry, 2 MGs and 2 anti-tank for both coalitions
        { name = ctld.tr("Anti Air"),                         inf = 2,    aa = 3 },
        { name = ctld.tr("Anti Tank"),                        inf = 2,    at = 6 },
        { name = ctld.tr("Mortar Squad"),                     mortar = 6 },
        { name = ctld.tr("JTAC Group"),                       inf = 4,    jtac = 1 }, -- will make a loadable group with 4 infantry and a JTAC soldier for both coalitions
        { name = ctld.tr("JTAC Group 2"),                     inf = 4,    jtac = 2 }, -- will make a loadable group with 4 infantry and a JTAC soldier for both coalitions
        { name = ctld.tr("Single JTAC"),                      jtac = 1 },             -- will make a loadable group witha single JTAC soldier for both coalitions
        { name = ctld.tr("2x - Standard Groups"),             inf = 12,   mg = 4,  at = 4 },
        { name = ctld.tr("2x - Anti Air"),                    inf = 4,    aa = 6 },
        { name = ctld.tr("2x - Anti Tank"),                   inf = 4,    at = 12 },
        { name = ctld.tr("2x - Standard Groups + 2x Mortar"), inf = 12,   mg = 4,  at = 4, mortar = 12 },
        { name = ctld.tr("3x - Standard Groups"),             inf = 18,   mg = 6,  at = 6 },
        { name = ctld.tr("3x - Anti Air"),                    inf = 6,    aa = 9 },
        { name = ctld.tr("3x - Anti Tank"),                   inf = 6,    at = 18 },
        { name = ctld.tr("3x - Mortar Squad"),                mortar = 18 },
        { name = ctld.tr("5x - Mortar Squad"),                mortar = 30 },
        -- {name = ctld.tr("Mortar Squad Red"), inf = 2, mortar = 5, side =1 }, --would make a group loadable by RED only
    }

    -- ************** SPAWNABLE CRATES ******************
    -- Weights must be unique as we use the weight to change the cargo to the correct unit
    -- when we unpack
    --
    self.settings["spawnableCrates"] = {
        -- name of the sub menu on F10 for spawning crates
        ["Combat Vehicles"] = {
            --crates you can spawn
            -- weight in KG
            -- Desc is the description on the F10 MENU
            -- unit is the model name of the unit to spawn
            -- cratesRequired - if set requires that many crates of the same type within 100m of each other in order build the unit
            -- side is optional but 2 is BLUE and 1 is RED

            -- Some descriptions are filtered to determine if JTAC or not!

            --- BLUE
            { weight = 1000.01, desc = ctld.tr("Humvee - MG"),         unit = "M1043 HMMWV Armament", side = 2 }, --careful with the names as the script matches the desc to JTAC types
            { weight = 1000.02, desc = ctld.tr("Humvee - TOW"),        unit = "M1045 HMMWV TOW",      side = 2, cratesRequired = 2 },
            { weight = 1000.03, desc = ctld.tr("Light Tank - MRAP"),   unit = "MaxxPro_MRAP",         side = 2, cratesRequired = 2 },
            { weight = 1000.04, desc = ctld.tr("Med Tank - LAV-25"),   unit = "LAV-25",               side = 2, cratesRequired = 3 },
            { weight = 1000.05, desc = ctld.tr("Heavy Tank - Abrams"), unit = "M-1 Abrams",           side = 2, cratesRequired = 4 },

            --- RED
            { weight = 1000.11, desc = ctld.tr("BTR-D"),               unit = "BTR_D",                side = 1 },
            { weight = 1000.12, desc = ctld.tr("BRDM-2"),              unit = "BRDM-2",               side = 1 },
            -- need more redfor!
        },
        ["Support"] = {
            --- BLUE
            { weight = 1001.01, desc = ctld.tr("Hummer - JTAC"),       unit = "Hummer",            side = 2,          cratesRequired = 1, isJTAC = true }, -- hidden when JTAC_dropEnabled=false
            { weight = 1001.02, desc = ctld.tr("M-818 Ammo Truck"),    unit = "M 818",             side = 2,          cratesRequired = 2 },
            { weight = 1001.03, desc = ctld.tr("M-978 Tanker"),        unit = "M978 HEMTT Tanker", side = 2,          cratesRequired = 2 },

            --- RED
            { weight = 1001.11, desc = ctld.tr("SKP-11 - JTAC"),       unit = "SKP-11",            side = 1,          isJTAC = true }, -- hidden when JTAC_dropEnabled=false
            { weight = 1001.12, desc = ctld.tr("Ural-375 Ammo Truck"), unit = "Ural-375",          side = 1,          cratesRequired = 2 },
            { weight = 1001.13, desc = ctld.tr("KAMAZ Ammo Truck"),    unit = "KAMAZ Truck",       side = 1,          cratesRequired = 2 },

            --- Both
            { weight = 1001.21, desc = ctld.tr("EWR Radar"),           unit = "FPS-117",           cratesRequired = 3 },
            { weight = 1001.22, desc = ctld.tr("FOB Crate"),           unit = "FOB",               side = nil,        cratesRequired = 3, showSets = false }, -- Sentinel: triggers FOBManager, not a DCS unit type

        },
        ["Artillery"] = {
            --- BLUE
            { weight = 1002.01, desc = ctld.tr("MLRS"),          unit = "MLRS",         side = 2, cratesRequired = 3 },
            { weight = 1002.02, desc = ctld.tr("SpGH DANA"),     unit = "SpGH_Dana",    side = 2, cratesRequired = 3 },
            { weight = 1002.03, desc = ctld.tr("T155 Firtina"),  unit = "T155_Firtina", side = 2, cratesRequired = 3 },
            { weight = 1002.04, desc = ctld.tr("Howitzer"),      unit = "M-109",        side = 2, cratesRequired = 3 },

            --- RED
            { weight = 1002.11, desc = ctld.tr("SPH 2S19 Msta"), unit = "SAU Msta",     side = 1, cratesRequired = 3 },

        },
        ["SAM short range"] = {
            --- BLUE
            { weight = 1003.01, desc = ctld.tr("M1097 Avenger"),   unit = "M1097 Avenger",       side = 2, cratesRequired = 3 },
            { weight = 1003.02, desc = ctld.tr("M48 Chaparral"),   unit = "M48 Chaparral",       side = 2, cratesRequired = 2 },
            { weight = 1003.03, desc = ctld.tr("Roland ADS"),      unit = "Roland ADS",          side = 2, cratesRequired = 3 },
            { weight = 1003.04, desc = ctld.tr("Gepard AAA"),      unit = "Gepard",              side = 2, cratesRequired = 3 },
            { weight = 1003.05, desc = ctld.tr("LPWS C-RAM"),      unit = "HEMTT_C-RAM_Phalanx", side = 2, cratesRequired = 3 },

            --- RED
            { weight = 1003.11, desc = ctld.tr("9K33 Osa"),        unit = "Osa 9A33 ln",         side = 1, cratesRequired = 3 },
            { weight = 1003.12, desc = ctld.tr("9P31 Strela-1"),   unit = "Strela-1 9P31",       side = 1, cratesRequired = 3 },
            { weight = 1003.13, desc = ctld.tr("9K35M Strela-10"), unit = "Strela-10M3",         side = 1, cratesRequired = 3 },
            { weight = 1003.14, desc = ctld.tr("9K331 Tor"),       unit = "Tor 9A331",           side = 1, cratesRequired = 3 },
            { weight = 1003.15, desc = ctld.tr("2K22 Tunguska"),   unit = "2S6 Tunguska",        side = 1, cratesRequired = 3 },
        },
        ["SAM mid range"] = {
            --- BLUE
            -- HAWK System
            { weight = 1004.01,                         desc = ctld.tr("HAWK Launcher"),             unit = "Hawk ln",              side = 2 },
            { weight = 1004.02,                         desc = ctld.tr("HAWK Search Radar"),         unit = "Hawk sr",              side = 2 },
            { weight = 1004.03,                         desc = ctld.tr("HAWK Track Radar"),          unit = "Hawk tr",              side = 2 },
            { weight = 1004.04,                         desc = ctld.tr("HAWK PCP"),                  unit = "Hawk pcp",             side = 2 },
            { weight = 1004.05,                         desc = ctld.tr("HAWK CWAR"),                 unit = "Hawk cwar",            side = 2 },
            { weight = 1004.06,                         desc = ctld.tr("HAWK Repair"),               unit = "HAWK Repair",          side = 2 },
            { mixedSet = { 1004.01, 1004.02, 1004.03 }, desc = ctld.tr("HAWK - All crates"),         side = 2 },
            -- End of HAWK

            -- NASAMS Sysyem
            { weight = 1004.11,                         desc = ctld.tr("NASAMS Launcher 120C"),      unit = "NASAMS_LN_C",          side = 2 },
            { weight = 1004.12,                         desc = ctld.tr("NASAMS Search/Track Radar"), unit = "NASAMS_Radar_MPQ64F1", side = 2 },
            { weight = 1004.13,                         desc = ctld.tr("NASAMS Command Post"),       unit = "NASAMS_Command_Post",  side = 2 },
            { weight = 1004.14,                         desc = ctld.tr("NASAMS Repair"),             unit = "NASAMS Repair",        side = 2 },
            { mixedSet = { 1004.11, 1004.12, 1004.13 }, desc = ctld.tr("NASAMS - All crates"),       side = 2 },
            -- End of NASAMS

            --- RED
            -- KUB SYSTEM
            { weight = 1004.21,                         desc = ctld.tr("KUB Launcher"),              unit = "Kub 2P25 ln",          side = 1 },
            { weight = 1004.22,                         desc = ctld.tr("KUB Radar"),                 unit = "Kub 1S91 str",         side = 1 },
            { weight = 1004.23,                         desc = ctld.tr("KUB Repair"),                unit = "KUB Repair",           side = 1 },
            { mixedSet = { 1004.21, 1004.22 },          desc = ctld.tr("KUB - All crates"),          side = 1 },
            -- End of KUB

            -- BUK System
            { weight = 1004.31,                         desc = ctld.tr("BUK Launcher"),              unit = "SA-11 Buk LN 9A310M1", side = 1 },
            { weight = 1004.32,                         desc = ctld.tr("BUK Search Radar"),          unit = "SA-11 Buk SR 9S18M1",  side = 1 },
            { weight = 1004.33,                         desc = ctld.tr("BUK CC Radar"),              unit = "SA-11 Buk CC 9S470M1", side = 1 },
            { weight = 1004.34,                         desc = ctld.tr("BUK Repair"),                unit = "BUK Repair",           side = 1 },
            { mixedSet = { 1004.31, 1004.32, 1004.33 }, desc = ctld.tr("BUK - All crates"),          side = 1 },
            -- END of BUK
        },
        ["SAM long range"] = {
            --- BLUE
            -- Patriot System
            { weight = 1005.01,                                           desc = ctld.tr("Patriot Launcher"),            unit = "Patriot ln",        side = 2 },
            { weight = 1005.02,                                           desc = ctld.tr("Patriot Radar"),               unit = "Patriot str",       side = 2 },
            { weight = 1005.03,                                           desc = ctld.tr("Patriot ECS"),                 unit = "Patriot ECS",       side = 2 },
            -- { weight = 1005.04, desc = ctld.tr("Patriot ICC"), unit = "Patriot cp", side = 2 },
            -- { weight = 1005.05, desc = ctld.tr("Patriot EPP"), unit = "Patriot EPP", side = 2 },
            { weight = 1005.06,                                           desc = ctld.tr("Patriot AMG (optional)"),      unit = "Patriot AMG",       side = 2 },
            { weight = 1005.07,                                           desc = ctld.tr("Patriot Repair"),              unit = "Patriot Repair",    side = 2 },
            { mixedSet = { 1005.01, 1005.02, 1005.03 },                   desc = ctld.tr("Patriot - All crates"),        side = 2 },
            -- End of Patriot

            -- S-300 SYSTEM
            { weight = 1005.11,                                           desc = ctld.tr("S-300 Grumble TEL C"),         unit = "S-300PS 5P85C ln",  side = 1 },
            { weight = 1005.12,                                           desc = ctld.tr("S-300 Grumble Flap Lid-A TR"), unit = "S-300PS 40B6M tr",  side = 1 },
            { weight = 1005.13,                                           desc = ctld.tr("S-300 Grumble Clam Shell SR"), unit = "S-300PS 40B6MD sr", side = 1 },
            { weight = 1005.14,                                           desc = ctld.tr("S-300 Grumble Big Bird SR"),   unit = "S-300PS 64H6E sr",  side = 1 },
            { weight = 1005.15,                                           desc = ctld.tr("S-300 Grumble C2"),            unit = "S-300PS 54K6 cp",   side = 1 },
            { weight = 1005.16,                                           desc = ctld.tr("S-300 Repair"),                unit = "S-300 Repair",      side = 1 },
            { mixedSet = { 1005.11, 1005.12, 1005.13, 1005.14, 1005.15 }, desc = ctld.tr("S-300 - All crates"),          side = 1 },
            -- End of S-300
        },
        ["Drone"] = {
            --- BLUE MQ-9 Repear
            {
                weight = 1006.01,
                desc = ctld.tr("MQ-9 Repear - JTAC"),
                unit = "MQ-9 Reaper",
                side = 2,
                isJTAC = true,
                spawnAs = "AIRPLANE",
                specificParams = { speed = 150, alti = 3000, orbitRadiusNoLase = 2000, orbitRadiusOnLase = 1000 }
            },
            -- End of BLUE MQ-9 Repear

            --- RED RQ-1A Predator
            {
                weight = 1006.11,
                desc = ctld.tr("RQ-1A Predator - JTAC"),
                unit = "RQ-1A Predator",
                side = 1,
                isJTAC = true,
                spawnAs = "AIRPLANE",
                specificParams = { speed = 150, alti = 3000, orbitRadiusNoLase = 2000, orbitRadiusOnLase = 1000 }
            },
            -- End of RED RQ-1A Predator
        },
    }

    self.settings["spawnableCratesModels"] = {
        ["load"] = {
            ["category"] = "Cargos", --"Fortifications"
            ["type"] = "ammo_cargo", --"uh1h_cargo"    --"Cargo04"
            ["canCargo"] = true,
        },
        ["sling"] = {
            ["category"] = "Cargos",
            ["shape_name"] = "bw_container_cargo",
            ["type"] = "container_cargo",
            ["canCargo"] = true
        },
        ["dynamic"] = {
            ["category"] = "Cargos",
            ["type"] = "ammo_cargo",
            ["canCargo"] = true
        }
    }


    --[[ Placeholder for different type of cargo containers. Let's say pipes and trunks, fuel for FOB building
        ["shape_name"] = "ab-212_cargo",
        ["type"] = "uh1h_cargo" --new type for the container previously used

        ["shape_name"] = "ammo_box_cargo",
        ["type"] = "ammo_cargo",

        ["shape_name"] = "barrels_cargo",
        ["type"] = "barrels_cargo",

        ["shape_name"] = "bw_container_cargo",
        ["type"] = "container_cargo",

        ["shape_name"] = "f_bar_cargo",
        ["type"] = "f_bar_cargo",

        ["shape_name"] = "fueltank_cargo",
        ["type"] = "fueltank_cargo",

        ["shape_name"] = "iso_container_cargo",
        ["type"] = "iso_container",

        ["shape_name"] = "iso_container_small_cargo",
        ["type"] = "iso_container_small",

        ["shape_name"] = "oiltank_cargo",
        ["type"] = "oiltank_cargo",

        ["shape_name"] = "pipes_big_cargo",
        ["type"] = "pipes_big_cargo",

        ["shape_name"] = "pipes_small_cargo",
        ["type"] = "pipes_small_cargo",

        ["shape_name"] = "tetrapod_cargo",
        ["type"] = "tetrapod_cargo",

        ["shape_name"] = "trunks_long_cargo",
        ["type"] = "trunks_long_cargo",

        ["shape_name"] = "trunks_small_cargo",
        ["type"] = "trunks_small_cargo",
]] --

    -- ******************************************************************
    -- ****************** END OF CONFIGURATION AREA *********************
    -- ******************************************************************

    -- overwrite defaults settings from CTLD_userConfig.lua --------------------------------------------
    if ctld.yamlConfigDatas then
        local userConfigTable = CTLDConfig.parseYAML(ctld.yamlConfigDatas) -- get user config coming from CTLD_userConfig.lua execution in ME

        local report = "REPORT - CTLD user config loaded :"
        for k, v in pairs(userConfigTable) do
            local tableName, fieldName = k:match("([^%.]+)%.(.+)") -- extract key after "ctld."
            if tableName == "ctld" then                            -- load general settings
                self.settings[fieldName] =
                    v                                              -- fix: use variable fieldName, not literal "fieldName"
                report = report .. "\nctld." .. fieldName .. " = " .. tostring(v)
            end
        end
        return true, report
    else
        if self.settings["debug"] then
            env.info("CTLDConfig: No YAML config data found in ctld.yamlConfigDatas")
        end
    end

    -- Temporary: Loading old ctld settings variables for backward compatibility
    if ctld ~= nil then
        for k, v in pairs(CTLDConfig.getAllSettings()) do
            if self.settings[k] ~= nil then
                ctld[k] = v -- set old ctld variables
            end
        end
    end
end

-- Retrieve a specific setting
function CTLDConfig:getSetting(key)
    return self.settings[key]
end

-- Retrieve a specific setting
function CTLDConfig.getAllSettings()
    return CTLDConfig._instance.settings
end

-- Retrieve a specific setting
function CTLDConfig:setSetting(key, value)
    self.settings[key] = value
    return self.settings[key]
end

------------------------------------------------------------------
-- yaml parsing utilities
------------------------------------------------------------------
-- Utility: Trims whitespace from both ends of a string
-- @param s: The raw string to trim
function CTLDConfig.trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Utility: Converts string values to their appropriate Lua types
-- @param v: The string value to convert
function CTLDConfig.to_type(v)
    if v == "true" then return true end
    if v == "false" then return false end
    if tonumber(v) then return tonumber(v) end
    return v:gsub("^['\"]", ""):gsub("['\"]$", "")
end

-- Main Parser: Converts a YAML-formatted string into a Lua Table
function CTLDConfig.parseYAML(data)
    local result = {}
    local stack = { result }
    local indentStack = { -1 }

    local literalMode = false
    local literalKey, literalIndent = "", 0
    local literalLines = {}

    for line in data:gmatch("[^\r\n]+") do
        local indent = line:match("^%s*"):len()
        local content = CTLDConfig.trim(line)

        -- 1. EXIT MULTILINE MODE
        if literalMode and #content > 0 and indent <= literalIndent then
            stack[#stack][literalKey] = table.concat(literalLines, "\n")
            literalMode = false
            literalLines = {}
        end

        -- 2. PROCESSING
        if literalMode then
            literalLines[#literalLines + 1] = line:sub(literalIndent + 3) or ""
        elseif content ~= "" and not content:match("^#") then
            -- STACK REALIGNMENT
            while #indentStack > 1 and indent <= indentStack[#indentStack] do
                table.remove(stack)
                table.remove(indentStack)
            end

            -- Check for list item with key attached (- polar:)
            local listDashKey, listDashValue = content:match("^%- ([^:]+):%s*(.*)")
            local key, value

            if listDashKey then
                -- NEW LIST ITEM OBJECT
                local newEntry = {}
                local parent = stack[#stack]
                parent[#parent + 1] = newEntry

                -- We push the entry into the stack
                table.insert(stack, newEntry)
                table.insert(indentStack, indent)

                key, value = listDashKey, listDashValue
                -- Important: update indent to match the key position after the dash
                indent = line:find(listDashKey) - 1
            else
                -- Standard key:value
                key, value = content:match("([^:]+):%s*(.*)")
            end

            if key then
                key, value = CTLDConfig.trim(key), CTLDConfig.trim(value)
                if value == "|" then
                    literalMode, literalKey, literalIndent = true, key, indent
                    literalLines = {}
                elseif value == "" then
                    -- Nested object
                    local newSubTable = {}
                    stack[#stack][key] = newSubTable
                    -- Move into the sub-table
                    table.insert(stack, newSubTable)
                    table.insert(indentStack, indent)
                else
                    -- Simple assignment
                    stack[#stack][key] = CTLDConfig.to_type(value)
                end
            elseif content:match("^%-") then
                -- Simple list item (- SAM-6)
                local item = CTLDConfig.trim(content:sub(2))
                local parent = stack[#stack]
                if type(parent) == "table" then
                    parent[#parent + 1] = CTLDConfig.to_type(item)
                end
            end
        end
    end

    if literalMode then stack[#stack][literalKey] = table.concat(literalLines, "\n") end
    return result
end

local config = CTLDConfig.get() -- get the singleton instance

-- Global shortcut for config access.
-- Usage: ctld.gs("paramName")  instead of  CTLDConfig.get():getSetting("paramName")
-- This is the ONLY authorised form to read config parameters throughout src/.
function ctld.gs(key)
    return CTLDConfig.get():getSetting(key)
end

--[[
------------------------------------------------------------------
-- Example: At start of CTLD initialization : Load ctld user config from CTLD_userConfig.lua
-- and set the ctld settings accordingly
-- ctld.yamlConfigDatas must be loaded beforehand by executing CTLD_userConfig.lua in the mission editor
-- with a trigger at START MISSION in "DO SCRIPT FILE" action
------------------------------------------------------------------

local myConfig = CTLDConfig.get()   -- Get the singleton instance
local success, report = myConfig:load()   -- Load the data from your specific path
if success then
    trigger.action.outText(report, 10)    -- Display the result if loading was successful
end

--At this stage, the ctld configuration settings are loaded with the user's values.


------------------------------------------------------------------
--- How to use the CTLDConfig singleton class in your scripts
--- to get ex "ctld.maximumDistanceLogistic = 200" value
------------------------------------------------------------------
local config = CTLDConfig.get()                                        -- get the singleton instance
local maximumDistanceLogistic = config:getSetting("maximumDistanceLogistic")  -- retrieve specific setting
-- Now you can use maximumDistanceLogistic in your script

-- You can also modify settings:
config:setSetting("maximumDistanceLogistic", 250)

-- To completely reset the singleton (useful for testing):
CTLDConfig.reset()  -- class method (dot notation)
]] --

-- End : CTLD_config.lua
-- ====================================================================================================
-- Start : CTLD_i18n.lua
--[[
    CTLD — Internationalization class (CTLDi18n)
    src version — logic only, no dictionary data.

    Dictionary files (loaded after this file):
        CTLD_i18n_en.lua  — English reference (keys and EN text)
        CTLD_i18n_fr.lua  — French
        CTLD_i18n_es.lua  — Spanish
        CTLD_i18n_ko.lua  — Korean

    To add a new language: create CTLD_i18n_XX.lua following the EN template,
    add it to tools/merger_V2/listToMerge.txt, and regenerate the loader.

    Translators: edit only the CTLD_i18n_XX.lua files. Never edit this file.
    Run tools/merger_V2/generate_i18n_dicts.ps1 after any ctld.tr() change in scripts.
]]

if not ctld then ctld = {} end
ctld.i18n = ctld.i18n or {}

-- =====================================================================
-- Active language selector
-- Uncomment the language you want to use.
-- =====================================================================
ctld.i18n_lang = "en"
--ctld.i18n_lang = "fr"
--ctld.i18n_lang = "es"
--ctld.i18n_lang = "ko"

-- =====================================================================
-- CTLDi18n singleton
-- =====================================================================
CTLDi18n = {}
CTLDi18n._instance = nil

function CTLDi18n.getInstance()
    if not CTLDi18n._instance then
        CTLDi18n._instance = setmetatable({}, { __index = CTLDi18n })
        CTLDi18n._instance:_init()
    end
    return CTLDi18n._instance
end

--- Apply mission-maker overrides declared in CTLD_userConfig.lua.
--- Called once at startup by getInstance().
function CTLDi18n:_init()
    if ctld.i18n_overrides then
        for lang, entries in pairs(ctld.i18n_overrides) do
            if ctld.i18n[lang] then
                for key, value in pairs(entries) do
                    ctld.i18n[lang][key] = value
                end
            end
        end
    end
end

-- =====================================================================
-- Translation function
-- =====================================================================

--- Translate a string to the active language, with optional parameter substitution.
--- Fallback chain: active lang → EN → key itself (never empty, never nil).
---@param text string The key to translate (= the English text)
---@param ... any Parameters to substitute for %1, %2, ... placeholders
---@return string
function ctld.tr(text, ...)
    local _text

    if not ctld.i18n[ctld.i18n_lang] then
        env.info(string.format("E - CTLDi18n.tr: language '%s' not found, defaulting to 'en'",
            tostring(ctld.i18n_lang)))
        _text = ctld.i18n["en"][text]
    else
        _text = ctld.i18n[ctld.i18n_lang][text]
    end

    -- Fallback to English
    if _text == nil then
        _text = ctld.i18n["en"][text]
    end

    -- Final fallback: use the key itself (= the English text)
    if _text == nil or _text == "" then
        _text = text
    end

    -- Parameter substitution (%1, %2, ...)
    local args = { ... }
    if #args > 0 then
        for i, v in ipairs(args) do
            _text = string.gsub(_text, "%%" .. i, tostring(v))
        end
    end

    return _text
end

--- Backward-compatibility alias.
ctld.i18n_translate = ctld.tr

-- =====================================================================
-- Dictionary integrity checker
-- =====================================================================

--- Audit a language dictionary against EN.
--- Returns a structured result table suitable for assertions in tests or scripts.
--- Does NOT write to env.* — callers decide how to display/log the result.
---@param language string Language code to audit (e.g. "fr")
---@return table|nil result  { version_match=bool, en_version=str, lang_version=str, missing={}, untranslated={} }
---@return string|nil err    non-nil when the language is unknown
function ctld.i18n_audit(language)
    local english = ctld.i18n["en"]
    local tocheck = ctld.i18n[language]
    if not tocheck then
        return nil, string.format("CTLDi18n.audit: language '%s' not found", tostring(language))
    end
    local enVer   = english.translation_version or "?"
    local langVer = tocheck.translation_version or "?"
    local result  = {
        version_match = (enVer == langVer),
        en_version    = enVer,
        lang_version  = langVer,
        missing       = {},
        untranslated  = {},
    }
    for key, enVal in pairs(english) do
        if key ~= "translation_version" then
            local langVal = tocheck[key]
            if langVal == nil then
                result.missing[#result.missing + 1] = key
            elseif langVal == enVal then
                result.untranslated[#result.untranslated + 1] = key
            end
        end
    end
    return result
end

--- Audit all non-English dictionaries in one call.
--- @return table  { [lang] = audit_result, ... }  one entry per loaded non-EN language
function ctld.i18n_auditAll()
    local results = {}
    for lang in pairs(ctld.i18n) do
        if lang ~= "en" then
            results[lang] = ctld.i18n_audit(lang)
        end
    end
    return results
end

--- Check that a language dictionary is complete and version-compatible with EN.
--- Logs errors for missing keys and warnings for untranslated entries.
---@param language string Language code to check (e.g. "fr")
---@param verbose boolean If true, log each passing entry as well
function ctld.i18n_check(language, verbose)
    local english = ctld.i18n["en"]
    local tocheck = ctld.i18n[language]
    if not tocheck then
        env.error(string.format("CTLDi18n.i18n_check: language '%s' not found", language))
        return false
    end

    local englishVersion = english.translation_version
    local tocheckVersion = tocheck.translation_version
    if englishVersion ~= tocheckVersion then
        env.error(string.format(
            "CTLDi18n.i18n_check: version mismatch — EN is %s, %s is %s",
            englishVersion, language, tocheckVersion))
    end

    for textRef, textEnglish in pairs(english) do
        if textRef ~= "translation_version" then
            local textTocheck = tocheck[textRef]
            if not textTocheck then
                env.error(string.format(
                    "CTLDi18n.i18n_check: MISSING in %s: [%s]", language, textRef))
            elseif textTocheck == textEnglish then
                env.warning(string.format(
                    "CTLDi18n.i18n_check: UNTRANSLATED in %s: [%s]", language, textRef))
            elseif verbose then
                env.info(string.format(
                    "CTLDi18n.i18n_check: OK in %s: [%s]", language, textRef))
            end
        end
    end
end

-- =====================================================================
-- Translator audit helper — call from a DO SCRIPT trigger (dev/QA only)
-- =====================================================================
--[[
-- Run after CTLD_Next.lua to get a per-language gap report in DCS.log:
--
--   local results = ctld.i18n_auditAll()
--   for lang, r in pairs(results) do
--       local lines = { string.format(
--           "=== i18n audit: lang=%s  EN_v=%s  lang_v=%s  version_match=%s",
--           lang, r.en_version, r.lang_version, tostring(r.version_match)) }
--       if #r.missing > 0 then
--           lines[#lines+1] = string.format("  MISSING (%d):", #r.missing)
--           for _, k in ipairs(r.missing) do
--               lines[#lines+1] = "    - " .. k
--           end
--       end
--       if #r.untranslated > 0 then
--           lines[#lines+1] = string.format("  UNTRANSLATED (%d):", #r.untranslated)
--           for _, k in ipairs(r.untranslated) do
--               lines[#lines+1] = "    ~ " .. k
--           end
--       end
--       if #r.missing == 0 and #r.untranslated == 0 then
--           lines[#lines+1] = "  All entries translated."
--       end
--       env.info(table.concat(lines, "\n"))
--   end
--]]

-- End : CTLD_i18n.lua
-- ====================================================================================================
-- Start : CTLD_i18n_en.lua
--[[
    CTLD — English dictionary (reference)
    Translation version: 1.7

    All values equal their key (English is the reference language).
    The ctld.tr() fallback chain already uses the key as last resort,
    but explicit values let ctld.i18n_check() detect untranslated entries
    in other languages by comparing against a non-empty EN value.

    Translators: DO NOT edit this file.
    To add or rename a key: edit this file AND bump translation_version,
    then run tools/merger_V2/generate_i18n_dicts.ps1 to propagate to other langs.
]]
if not ctld then ctld = {} end
if not ctld.i18n then ctld.i18n = {} end

ctld.i18n["en"] = {}
ctld.i18n["en"].translation_version = "1.8"

--- groups names
ctld.i18n["en"]["Standard Group"] = "Standard Group"
ctld.i18n["en"]["Anti Air"] = "Anti Air"
ctld.i18n["en"]["Anti Tank"] = "Anti Tank"
ctld.i18n["en"]["Mortar Squad"] = "Mortar Squad"
ctld.i18n["en"]["JTAC Group"] = "JTAC Group"
ctld.i18n["en"]["Single JTAC"] = "Single JTAC"
ctld.i18n["en"]["2x - Standard Groups"] = "2x - Standard Groups"
ctld.i18n["en"]["2x - Anti Air"] = "2x - Anti Air"
ctld.i18n["en"]["2x - Anti Tank"] = "2x - Anti Tank"
ctld.i18n["en"]["2x - Standard Groups + 2x Mortar"] = "2x - Standard Groups + 2x Mortar"
ctld.i18n["en"]["3x - Standard Groups"] = "3x - Standard Groups"
ctld.i18n["en"]["3x - Anti Air"] = "3x - Anti Air"
ctld.i18n["en"]["3x - Anti Tank"] = "3x - Anti Tank"
ctld.i18n["en"]["3x - Mortar Squad"] = "3x - Mortar Squad"
ctld.i18n["en"]["5x - Mortar Squad"] = "5x - Mortar Squad"
ctld.i18n["en"]["Mortar Squad Red"] = "Mortar Squad Red"

--- crates names
ctld.i18n["en"]["Humvee - MG"] = "Humvee - MG"
ctld.i18n["en"]["Humvee - TOW"] = "Humvee - TOW"
ctld.i18n["en"]["Light Tank - MRAP"] = "Light Tank - MRAP"
ctld.i18n["en"]["Med Tank - LAV-25"] = "Med Tank - LAV-25"
ctld.i18n["en"]["Heavy Tank - Abrams"] = "Heavy Tank - Abrams"
ctld.i18n["en"]["BTR-D"] = "BTR-D"
ctld.i18n["en"]["BRDM-2"] = "BRDM-2"
ctld.i18n["en"]["Hummer - JTAC"] = "Hummer - JTAC"
ctld.i18n["en"]["M-818 Ammo Truck"] = "M-818 Ammo Truck"
ctld.i18n["en"]["M-978 Tanker"] = "M-978 Tanker"
ctld.i18n["en"]["SKP-11 - JTAC"] = "SKP-11 - JTAC"
ctld.i18n["en"]["Ural-375 Ammo Truck"] = "Ural-375 Ammo Truck"
ctld.i18n["en"]["KAMAZ Ammo Truck"] = "KAMAZ Ammo Truck"
ctld.i18n["en"]["KAMAZ Ammo Truck - All crates"] = "KAMAZ Ammo Truck - All crates"
ctld.i18n["en"]["EWR Radar"] = "EWR Radar"
ctld.i18n["en"]["FOB Crate"] = "FOB Crate"
ctld.i18n["en"]["You must be on the ground to deploy a FOB."] = "You must be on the ground to deploy a FOB."
ctld.i18n["en"]["FOB needs %1 crate(s) within 750 m - only %2 found."] = "FOB needs %1 crate(s) within 750 m - only %2 found."
ctld.i18n["en"]["You can't deploy a FOB here! Take it to where it's needed."] = "You can't deploy a FOB here! Take it to where it's needed."
ctld.i18n["en"]["FOB deployment blocked: move at least %1 m away from existing logistic zone."] = "FOB deployment blocked: move at least %1 m away from existing logistic zone."
ctld.i18n["en"]["%1 started building a FOB (%2 crate(s)). Ready in %3 seconds."] = "%1 started building a FOB (%2 crate(s)). Ready in %3 seconds."
ctld.i18n["en"]["FOB established by %1 - logistics hub now active."] = "FOB established by %1 - logistics hub now active."
ctld.i18n["en"]["MQ-9 Repear - JTAC"] = "MQ-9 Repear - JTAC"
ctld.i18n["en"]["RQ-1A Predator - JTAC"] = "RQ-1A Predator - JTAC"
ctld.i18n["en"]["MLRS"] = "MLRS"
ctld.i18n["en"]["SpGH DANA"] = "SpGH DANA"
ctld.i18n["en"]["T155 Firtina"] = "T155 Firtina"
ctld.i18n["en"]["Howitzer"] = "Howitzer"
ctld.i18n["en"]["SPH 2S19 Msta"] = "SPH 2S19 Msta"
ctld.i18n["en"]["M1097 Avenger"] = "M1097 Avenger"
ctld.i18n["en"]["M48 Chaparral"] = "M48 Chaparral"
ctld.i18n["en"]["Roland ADS"] = "Roland ADS"
ctld.i18n["en"]["Gepard AAA"] = "Gepard AAA"
ctld.i18n["en"]["LPWS C-RAM"] = "LPWS C-RAM"
ctld.i18n["en"]["9K33 Osa"] = "9K33 Osa"
ctld.i18n["en"]["9P31 Strela-1"] = "9P31 Strela-1"
ctld.i18n["en"]["9K35M Strela-10"] = "9K35M Strela-10"
ctld.i18n["en"]["9K331 Tor"] = "9K331 Tor"
ctld.i18n["en"]["2K22 Tunguska"] = "2K22 Tunguska"
ctld.i18n["en"]["HAWK Launcher"] = "HAWK Launcher"
ctld.i18n["en"]["HAWK Search Radar"] = "HAWK Search Radar"
ctld.i18n["en"]["HAWK Track Radar"] = "HAWK Track Radar"
ctld.i18n["en"]["HAWK PCP"] = "HAWK PCP"
ctld.i18n["en"]["HAWK CWAR"] = "HAWK CWAR"
ctld.i18n["en"]["HAWK Repair"] = "HAWK Repair"
ctld.i18n["en"]["NASAMS Launcher 120C"] = "NASAMS Launcher 120C"
ctld.i18n["en"]["NASAMS Search/Track Radar"] = "NASAMS Search/Track Radar"
ctld.i18n["en"]["NASAMS Command Post"] = "NASAMS Command Post"
ctld.i18n["en"]["NASAMS Repair"] = "NASAMS Repair"
ctld.i18n["en"]["KUB Launcher"] = "KUB Launcher"
ctld.i18n["en"]["KUB Radar"] = "KUB Radar"
ctld.i18n["en"]["KUB Repair"] = "KUB Repair"
ctld.i18n["en"]["BUK Launcher"] = "BUK Launcher"
ctld.i18n["en"]["BUK Search Radar"] = "BUK Search Radar"
ctld.i18n["en"]["BUK CC Radar"] = "BUK CC Radar"
ctld.i18n["en"]["BUK Repair"] = "BUK Repair"
ctld.i18n["en"]["Patriot Launcher"] = "Patriot Launcher"
ctld.i18n["en"]["Patriot Radar"] = "Patriot Radar"
ctld.i18n["en"]["Patriot ECS"] = "Patriot ECS"
ctld.i18n["en"]["Patriot ICC"] = "Patriot ICC"
ctld.i18n["en"]["Patriot EPP"] = "Patriot EPP"
ctld.i18n["en"]["Patriot AMG (optional)"] = "Patriot AMG (optional)"
ctld.i18n["en"]["Patriot Repair"] = "Patriot Repair"
ctld.i18n["en"]["S-300 Grumble TEL C"] = "S-300 Grumble TEL C"
ctld.i18n["en"]["S-300 Grumble Flap Lid-A TR"] = "S-300 Grumble Flap Lid-A TR"
ctld.i18n["en"]["S-300 Grumble Clam Shell SR"] = "S-300 Grumble Clam Shell SR"
ctld.i18n["en"]["S-300 Grumble Big Bird SR"] = "S-300 Grumble Big Bird SR"
ctld.i18n["en"]["S-300 Grumble C2"] = "S-300 Grumble C2"
ctld.i18n["en"]["S-300 Repair"] = "S-300 Repair"
ctld.i18n["en"]["Humvee - TOW - All crates"] = "Humvee - TOW - All crates"
ctld.i18n["en"]["Light Tank - MRAP - All crates"] = "Light Tank - MRAP - All crates"
ctld.i18n["en"]["Med Tank - LAV-25 - All crates"] = "Med Tank - LAV-25 - All crates"
ctld.i18n["en"]["Heavy Tank - Abrams - All crates"] = "Heavy Tank - Abrams - All crates"
ctld.i18n["en"]["Hummer - JTAC - All crates"] = "Hummer - JTAC - All crates"
ctld.i18n["en"]["M-818 Ammo Truck - All crates"] = "M-818 Ammo Truck - All crates"
ctld.i18n["en"]["M-978 Tanker - All crates"] = "M-978 Tanker - All crates"
ctld.i18n["en"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 Ammo Truck - All crates"
ctld.i18n["en"]["EWR Radar - All crates"] = "EWR Radar - All crates"
ctld.i18n["en"]["MLRS - All crates"] = "MLRS - All crates"
ctld.i18n["en"]["SpGH DANA - All crates"] = "SpGH DANA - All crates"
ctld.i18n["en"]["T155 Firtina - All crates"] = "T155 Firtina - All crates"
ctld.i18n["en"]["Howitzer - All crates"] = "Howitzer - All crates"
ctld.i18n["en"]["SPH 2S19 Msta - All crates"] = "SPH 2S19 Msta - All crates"
ctld.i18n["en"]["M1097 Avenger - All crates"] = "M1097 Avenger - All crates"
ctld.i18n["en"]["M48 Chaparral - All crates"] = "M48 Chaparral - All crates"
ctld.i18n["en"]["Roland ADS - All crates"] = "Roland ADS - All crates"
ctld.i18n["en"]["Gepard AAA - All crates"] = "Gepard AAA - All crates"
ctld.i18n["en"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - All crates"
ctld.i18n["en"]["9K33 Osa - All crates"] = "9K33 Osa - All crates"
ctld.i18n["en"]["9P31 Strela-1 - All crates"] = "9P31 Strela-1 - All crates"
ctld.i18n["en"]["9K35M Strela-10 - All crates"] = "9K35M Strela-10 - All crates"
ctld.i18n["en"]["9K331 Tor - All crates"] = "9K331 Tor - All crates"
ctld.i18n["en"]["2K22 Tunguska - All crates"] = "2K22 Tunguska - All crates"
ctld.i18n["en"]["HAWK - All crates"] = "HAWK - All crates"
ctld.i18n["en"]["NASAMS - All crates"] = "NASAMS - All crates"
ctld.i18n["en"]["KUB - All crates"] = "KUB - All crates"
ctld.i18n["en"]["BUK - All crates"] = "BUK - All crates"
ctld.i18n["en"]["Patriot - All crates"] = "Patriot - All crates"
ctld.i18n["en"]["S-300 - All crates"] = "S-300 - All crates"

--- mission design error messages
-- STALE: ctld.i18n["en"]["CTLD.lua ERROR: Can't find trigger called %1"] = "CTLD.lua ERROR: Can't find trigger called %1"
-- STALE: ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone called %1"] = "CTLD.lua ERROR: Can't find zone called %1"
-- STALE: ctld.i18n["en"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = "CTLD.lua ERROR: Can't find zone or ship called %1"
-- STALE: ctld.i18n["en"]["CTLD.lua ERROR: Can't find crate with weight %1"] = "CTLD.lua ERROR: Can't find crate with weight %1"

--- runtime messages
-- STALE: ctld.i18n["en"]["You are not close enough to friendly logistics to get a crate!"] = "You are not close enough to friendly logistics to get a crate!"
-- STALE: ctld.i18n["en"]["No more JTAC Crates Left!"] = "No more JTAC Crates Left!"
-- STALE: ctld.i18n["en"]["Sorry you must wait %1 seconds before you can get another crate"] = "Sorry you must wait %1 seconds before you can get another crate"
-- STALE: ctld.i18n["en"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = "A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "
-- STALE: ctld.i18n["en"]["%1 fast-ropped troops from %2 into combat"] = "%1 fast-ropped troops from %2 into combat"
-- STALE: ctld.i18n["en"]["%1 dropped troops from %2 into combat"] = "%1 dropped troops from %2 into combat"
-- STALE: ctld.i18n["en"]["%1 fast-ropped troops from %2 into %3"] = "%1 fast-ropped troops from %2 into %3"
-- STALE: ctld.i18n["en"]["%1 dropped troops from %2 into %3"] = "%1 dropped troops from %2 into %3"
-- STALE: ctld.i18n["en"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] = "Too high or too fast to drop troops into combat! Hover below %1 feet or land."
-- STALE: ctld.i18n["en"]["%1 dropped vehicles from %2 into combat"] = "%1 dropped vehicles from %2 into combat"
-- STALE: ctld.i18n["en"]["%1 loaded troops into %2"] = "%1 loaded troops into %2"
-- STALE: ctld.i18n["en"]["%1 loaded %2 vehicles into %3"] = "%1 loaded %2 vehicles into %3"
-- STALE: ctld.i18n["en"]["%1 delivered a FOB Crate"] = "%1 delivered a FOB Crate"
-- STALE: ctld.i18n["en"]["Delivered FOB Crate 60m at 6'oclock to you"] = "Delivered FOB Crate 60m at 6'oclock to you"
-- STALE: ctld.i18n["en"]["FOB Crate dropped back to base"] = "FOB Crate dropped back to base"
-- STALE: ctld.i18n["en"]["FOB Crate Loaded"] = "FOB Crate Loaded"
-- STALE: ctld.i18n["en"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 loaded a FOB Crate ready for delivery!"
-- STALE: ctld.i18n["en"]["There are no friendly logistic units nearby to load a FOB crate from!"] = "There are no friendly logistic units nearby to load a FOB crate from!"
-- STALE: ctld.i18n["en"]["This area has no more reinforcements available!"] = "This area has no more reinforcements available!"
-- STALE: ctld.i18n["en"]["You are not in a pickup zone and no one is nearby to extract"] = "You are not in a pickup zone and no one is nearby to extract"
-- STALE: ctld.i18n["en"]["You are not in a pickup zone"] = "You are not in a pickup zone"
-- STALE: ctld.i18n["en"]["No one to unload"] = "No one to unload"
-- STALE: ctld.i18n["en"]["Dropped troops back to base"] = "Dropped troops back to base"
-- STALE: ctld.i18n["en"]["Dropped vehicles back to base"] = "Dropped vehicles back to base"
-- STALE: ctld.i18n["en"]["You already have troops onboard."] = "You already have troops onboard."
-- STALE: ctld.i18n["en"]["Count Infantries limit in the mission reached, you can't load more troops"] = "Count Infantries limit in the mission reached, you can't load more troops"
-- STALE: ctld.i18n["en"]["You already have vehicles onboard."] = "You already have vehicles onboard."
-- STALE: ctld.i18n["en"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] = "Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"
-- STALE: ctld.i18n["en"]["%1 extracted troops in %2 from combat"] = "%1 extracted troops in %2 from combat"
-- STALE: ctld.i18n["en"]["No extractable troops nearby!"] = "No extractable troops nearby!"
-- STALE: ctld.i18n["en"]["%1 extracted vehicles in %2 from combat"] = "%1 extracted vehicles in %2 from combat"
-- STALE: ctld.i18n["en"]["No extractable vehicles nearby!"] = "No extractable vehicles nearby!"
-- STALE: ctld.i18n["en"]["%1 troops onboard (%2 kg)\n"] = "%1 troops onboard (%2 kg)\n"
-- STALE: ctld.i18n["en"]["%1 vehicles onboard (%2)\n"] = "%1 vehicles onboard (%2)\n"
-- STALE: ctld.i18n["en"]["1 FOB Crate oboard (%1 kg)\n"] = "1 FOB Crate oboard (%1 kg)\n"
-- STALE: ctld.i18n["en"]["%1 crate onboard (%2 kg)\n"] = "%1 crate onboard (%2 kg)\n"
-- STALE: ctld.i18n["en"]["Total weight of cargo : %1 kg\n"] = "Total weight of cargo : %1 kg\n"
-- STALE: ctld.i18n["en"]["No cargo."] = "No cargo."
-- STALE: ctld.i18n["en"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] = "Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"
-- STALE: ctld.i18n["en"]["Loaded %1 crate!"] = "Loaded %1 crate!"
-- STALE: ctld.i18n["en"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = "Too low to hook %1 crate.\n\nHold hover for %2 seconds"
-- STALE: ctld.i18n["en"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = "Too high to hook %1 crate.\n\nHold hover for %2 seconds"
-- STALE: ctld.i18n["en"]["You must land before you can load a crate!"] = "You must land before you can load a crate!"
-- STALE: ctld.i18n["en"]["No Crates within 50m to load!"] = "No Crates within 50m to load!"
-- STALE: ctld.i18n["en"]["Maximum number of crates are on board!"] = "Maximum number of crates are on board!"
-- STALE: ctld.i18n["en"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 crate - kg %3 - %4 m - %5 o'clock"
-- STALE: ctld.i18n["en"]["FOB Crate - %1 m - %2 o'clock\n"] = "FOB Crate - %1 m - %2 o'clock\n"
-- STALE: ctld.i18n["en"]["No Nearby Crates"] = "No Nearby Crates"
-- STALE: ctld.i18n["en"]["Nearby Crates:\n%1"] = "Nearby Crates:\n%1"
-- STALE: ctld.i18n["en"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = "Nearby FOB Crates (Not Slingloadable):\n%1"
-- STALE: ctld.i18n["en"]["FOB Positions:"] = "FOB Positions:"
-- STALE: ctld.i18n["en"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
-- STALE: ctld.i18n["en"]["Sorry, there are no active FOBs!"] = "Sorry, there are no active FOBs!"
-- STALE: ctld.i18n["en"]["You can't unpack that here! Take it to where it's needed!"] = "You can't unpack that here! Take it to where it's needed!"
-- STALE: ctld.i18n["en"]["Sorry you must move this crate before you unpack it!"] = "Sorry you must move this crate before you unpack it!"
-- STALE: ctld.i18n["en"]["%1 successfully deployed %2 to the field"] = "%1 successfully deployed %2 to the field"
-- STALE: ctld.i18n["en"]["No friendly crates close enough to unpack, or crate too close to aircraft."] = "No friendly crates close enough to unpack, or crate too close to aircraft."
-- STALE: ctld.i18n["en"]["Finished building FOB! Crates and Troops can now be picked up."] = "Finished building FOB! Crates and Troops can now be picked up."
-- STALE: ctld.i18n["en"]["Finished building FOB! Crates can now be picked up."] = "Finished building FOB! Crates can now be picked up."
-- STALE: ctld.i18n["en"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] = "%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."
-- STALE: ctld.i18n["en"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] = "Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"
-- STALE: ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] = "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."
-- STALE: ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] = "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."
-- STALE: ctld.i18n["en"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] = "You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."
-- STALE: ctld.i18n["en"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = "%1 crate has been safely unhooked and is at your %2 o'clock"
-- STALE: ctld.i18n["en"]["%1 crate has been safely dropped below you"] = "%1 crate has been safely dropped below you"
-- STALE: ctld.i18n["en"]["You were too high! The crate has been destroyed"] = "You were too high! The crate has been destroyed"
--- Radio Beacon messages
ctld.i18n["en"]["No Radio Beacons within 500m."] = "No Radio Beacons within 500m."
ctld.i18n["en"]["Navigation beacon deployed - %1"] = "Navigation beacon deployed - %1"
ctld.i18n["en"]["Radio beacon removed - %1"] = "Radio beacon removed - %1"
ctld.i18n["en"]["Radio Beacons:"] = "Radio Beacons:"
ctld.i18n["en"]["No Active Radio Beacons"] = "No Active Radio Beacons"
ctld.i18n["en"]["Beacon layer enabled. %1 beacon(s)."] = "Beacon layer enabled. %1 beacon(s)."
ctld.i18n["en"]["Beacon layer disabled."] = "Beacon layer disabled."
ctld.i18n["en"]["CTLD"] = "CTLD"
ctld.i18n["en"]["Radio Beacons"] = "Radio Beacons"
ctld.i18n["en"]["Drop Beacon"] = "Drop Beacon"
ctld.i18n["en"]["Remove Closest Beacon"] = "Remove Closest Beacon"
ctld.i18n["en"]["List Beacons"] = "List Beacons"
-- STALE: ctld.i18n["en"]["Radio Beacons:\n%1"] = "Radio Beacons:\n%1"
-- STALE: ctld.i18n["en"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 deployed a Radio Beacon.\n\n%2"
-- STALE: ctld.i18n["en"]["You need to land before you can deploy a Radio Beacon!"] = "You need to land before you can deploy a Radio Beacon!"
-- STALE: ctld.i18n["en"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 removed a Radio Beacon.\n\n%2"
-- STALE: ctld.i18n["en"]["You need to land before remove a Radio Beacon"] = "You need to land before remove a Radio Beacon"
-- STALE: ctld.i18n["en"]["%1 successfully rearmed a full %2 in the field"] = "%1 successfully rearmed a full %2 in the field"
-- STALE: ctld.i18n["en"]["Missing %1\n"] = "Missing %1\n"
-- STALE: ctld.i18n["en"]["Out of parts for AA Systems. Current limit is %1\n"] = "Out of parts for AA Systems. Current limit is %1\n"
-- STALE: ctld.i18n["en"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] = "Cannot build %1\n%2\n\nOr the crates are not close enough together"
-- STALE: ctld.i18n["en"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] = "%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"
-- STALE: ctld.i18n["en"]["%1 successfully repaired a full %2 in the field."] = "%1 successfully repaired a full %2 in the field."
-- STALE: ctld.i18n["en"]["Cannot repair %1. No damaged %2 within 300m"] = "Cannot repair %1. No damaged %2 within 300m"
-- STALE: ctld.i18n["en"]["%1 successfully deployed %2 to the field using %3 crates."] = "%1 successfully deployed %2 to the field using %3 crates."
-- STALE: ctld.i18n["en"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] = "Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"
-- STALE: ctld.i18n["en"]["%1 dropped %2 smoke."] = "%1 dropped %2 smoke."

--- JTAC messages
-- STALE: ctld.i18n["en"]["JTAC Group %1 KIA!"] = "JTAC Group %1 KIA!"
-- STALE: ctld.i18n["en"]["%1, selected target reacquired, %2"] = "%1, selected target reacquired, %2"
-- STALE: ctld.i18n["en"][". CODE: %1. POSITION: %2"] = ". CODE: %1. POSITION: %2"
-- STALE: ctld.i18n["en"]["new target, "] = "new target, "
-- STALE: ctld.i18n["en"]["standing by on %1"] = "standing by on %1"
-- STALE: ctld.i18n["en"]["lasing %1"] = "lasing %1"
-- STALE: ctld.i18n["en"][", temporarily %1"] = ", temporarily %1"
-- STALE: ctld.i18n["en"]["target lost"] = "target lost"
-- STALE: ctld.i18n["en"]["target destroyed"] = "target destroyed"
-- STALE: ctld.i18n["en"][", selected %1"] = ", selected %1"
-- STALE: ctld.i18n["en"]["%1 %2 target lost."] = "%1 %2 target lost."
-- STALE: ctld.i18n["en"]["%1 %2 target destroyed."] = "%1 %2 target destroyed."
-- STALE: ctld.i18n["en"]["JTAC STATUS: \n\n"] = "JTAC STATUS: \n\n"
-- STALE: ctld.i18n["en"][", available on %1 %2,"] = ", available on %1 %2,"
-- STALE: ctld.i18n["en"]["UNKNOWN"] = "UNKNOWN"
-- STALE: ctld.i18n["en"][" targeting "] = " targeting "
-- STALE: ctld.i18n["en"][" targeting selected unit "] = " targeting selected unit "
-- STALE: ctld.i18n["en"][" attempting to find selected unit, temporarily targeting "] = " attempting to find selected unit, temporarily targeting "
-- STALE: ctld.i18n["en"]["(Laser OFF) "] = "(Laser OFF) "
-- STALE: ctld.i18n["en"]["Visual On: "] = "Visual On: "
-- STALE: ctld.i18n["en"][" searching for targets %1\n"] = " searching for targets %1\n"
-- STALE: ctld.i18n["en"]["No Active JTACs"] = "No Active JTACs"
-- STALE: ctld.i18n["en"][", targeting selected unit, %1"] = ", targeting selected unit, %1"
-- STALE: ctld.i18n["en"][", target selection reset."] = ", target selection reset."
-- STALE: ctld.i18n["en"]["%1, laser and smokes enabled"] = "%1, laser and smokes enabled"
-- STALE: ctld.i18n["en"]["%1, laser and smokes disabled"] = "%1, laser and smokes disabled"
-- STALE: ctld.i18n["en"]["%1, wind and target speed laser spot compensations enabled"] = "%1, wind and target speed laser spot compensations enabled"
-- STALE: ctld.i18n["en"]["%1, wind and target speed laser spot compensations disabled"] = "%1, wind and target speed laser spot compensations disabled"
-- STALE: ctld.i18n["en"]["%1, WHITE smoke deployed near target"] = "%1, WHITE smoke deployed near target"

--- F10 menu messages
-- STALE: ctld.i18n["en"]["Actions"] = "Actions"
-- STALE: ctld.i18n["en"]["Troop Transport"] = "Troop Transport"
-- STALE: ctld.i18n["en"]["Unload / Extract Troops"] = "Unload / Extract Troops"
-- STALE: ctld.i18n["en"]["Next page"] = "Next page"
-- STALE: ctld.i18n["en"]["Load "] = "Load "
-- STALE: ctld.i18n["en"]["Vehicle / FOB Transport"] = "Vehicle / FOB Transport"
-- STALE: ctld.i18n["en"]["Crates: Vehicle / FOB / Drone"] = "Crates: Vehicle / FOB / Drone"
-- STALE: ctld.i18n["en"]["Unload Vehicles"] = "Unload Vehicles"
-- STALE: ctld.i18n["en"]["Load / Extract Vehicles"] = "Load / Extract Vehicles"
-- STALE: ctld.i18n["en"]["Load / Unload FOB Crate"] = "Load / Unload FOB Crate"
-- STALE: ctld.i18n["en"]["Pack Vehicles"] = "Pack Vehicles"
-- STALE: ctld.i18n["en"]["CTLD Commands"] = "CTLD Commands"
-- STALE: ctld.i18n["en"]["CTLD"] = "CTLD"
-- STALE: ctld.i18n["en"]["Check Cargo"] = "Check Cargo"
-- STALE: ctld.i18n["en"]["Load Nearby Crate(s)"] = "Load Nearby Crate(s)"
-- STALE: ctld.i18n["en"]["Unpack Any Crate"] = "Unpack Any Crate"
-- STALE: ctld.i18n["en"]["Drop Crate(s)"] = "Drop Crate(s)"
-- STALE: ctld.i18n["en"]["List Nearby Crates"] = "List Nearby Crates"
-- STALE: ctld.i18n["en"]["List FOBs"] = "List FOBs"
-- STALE: ctld.i18n["en"]["List Beacons"] = "List Beacons"
-- STALE: ctld.i18n["en"]["List Radio Beacons"] = "List Radio Beacons"
-- STALE: ctld.i18n["en"]["Smoke Markers"] = "Smoke Markers"
-- STALE: ctld.i18n["en"]["Drop Red Smoke"] = "Drop Red Smoke"
-- STALE: ctld.i18n["en"]["Drop Blue Smoke"] = "Drop Blue Smoke"
-- STALE: ctld.i18n["en"]["Drop Orange Smoke"] = "Drop Orange Smoke"
-- STALE: ctld.i18n["en"]["Drop Green Smoke"] = "Drop Green Smoke"
-- STALE: ctld.i18n["en"]["JTAC Status"] = "JTAC Status"
-- STALE: ctld.i18n["en"]["DISABLE "] = "DISABLE "
-- STALE: ctld.i18n["en"]["ENABLE "] = "ENABLE "
-- STALE: ctld.i18n["en"]["REQUEST "] = "REQUEST "
-- STALE: ctld.i18n["en"]["Reset TGT Selection"] = "Reset TGT Selection"

--- F10 RECON menus
ctld.i18n["en"]["RECON"] = "RECON"
ctld.i18n["en"]["RECON [Start]"] = "RECON [Start]"
ctld.i18n["en"]["RECON [Stop]"] = "RECON [Stop]"
ctld.i18n["en"]["Scan Area"] = "Scan Area"
ctld.i18n["en"]["Hide All Targets"] = "Hide All Targets"
ctld.i18n["en"]["Toggle %s"] = "Toggle %s"
ctld.i18n["en"]["Auto-Refresh: [OFF]"] = "Auto-Refresh: [OFF]"
ctld.i18n["en"]["Auto-Refresh: [ON]"] = "Auto-Refresh: [ON]"
ctld.i18n["en"]["Altitude too low for recon scan (min %1 m)"] = "Altitude too low for recon scan (min %1 m)"
ctld.i18n["en"]["No recon layers enabled. Activate layers first."] = "No recon layers enabled. Activate layers first."
ctld.i18n["en"]["Recon stopped. %1 targets hidden."] = "Recon stopped. %1 targets hidden."
ctld.i18n["en"]["No active recon scan to hide."] = "No active recon scan to hide."
ctld.i18n["en"]["No active recon scan. Use 'Scan Area' first."] = "No active recon scan. Use 'Scan Area' first."
ctld.i18n["en"]["Auto-refresh enabled. Targets update every %1 s."] = "Auto-refresh enabled. Targets update every %1 s."
ctld.i18n["en"]["Auto-refresh disabled. Current targets frozen on map."] = "Auto-refresh disabled. Current targets frozen on map."
ctld.i18n["en"]["Recon layer '%1': %2"] = "Recon layer '%1': %2"
-- STALE: ctld.i18n["en"]["Layers"] = "Layers"
-- STALE: ctld.i18n["en"]["Show targets in LOS (refresh)"] = "Show targets in LOS (refresh)"
-- STALE: ctld.i18n["en"]["Hide targets in LOS"] = "Hide targets in LOS"
-- STALE: ctld.i18n["en"]["Scan targets in LOS"] = "Scan targets in LOS"
-- STALE: ctld.i18n["en"]["START autoRefresh"] = "START autoRefresh"
-- STALE: ctld.i18n["en"]["STOP autoRefresh"] = "STOP autoRefresh"
-- STALE: ctld.i18n["en"]["START autoRefresh targets in LOS"] = "START autoRefresh targets in LOS"
-- STALE: ctld.i18n["en"]["STOP autoRefresh targets in LOS"] = "STOP autoRefresh targets in LOS"

--- Load Crate submenu
ctld.i18n["en"]["Load Crate"] = "Load Crate"
ctld.i18n["en"]["Land to load crates"] = "Land to load crates"
ctld.i18n["en"]["No crates within 50m"] = "No crates within 50m"
ctld.i18n["en"]["You must land before you can load a crate!"] = "You must land before you can load a crate!"
ctld.i18n["en"]["Maximum number of crates are on board!"] = "Maximum number of crates are on board!"
ctld.i18n["en"]["No crates within 50m to load!"] = "No crates within 50m to load!"
ctld.i18n["en"]["Loaded %1 crate!"] = "Loaded %1 crate!"

--- Drop Crate(s)
ctld.i18n["en"]["No crates on board to drop."] = "No crates on board to drop."
ctld.i18n["en"]["You must land before dropping crates!"] = "You must land before dropping crates!"
ctld.i18n["en"]["%1 crate(s) dropped at your %2 o'clock"] = "%1 crate(s) dropped at your %2 o'clock"

--- Unpack Crate submenu
ctld.i18n["en"]["Unpack Crate"] = "Unpack Crate"
ctld.i18n["en"]["Land to unpack crates"] = "Land to unpack crates"
ctld.i18n["en"]["No complete crate sets nearby"] = "No complete crate sets nearby"
ctld.i18n["en"]["Build FOB"] = "Build FOB"
ctld.i18n["en"]["You must land before unpacking crates!"] = "You must land before unpacking crates!"
ctld.i18n["en"]["Not enough crates nearby to unpack!"] = "Not enough crates nearby to unpack!"
ctld.i18n["en"]["%1 unpacked successfully!"] = "%1 unpacked successfully!"

--- Pack Vehicle submenu
ctld.i18n["en"]["Land to pack vehicles"] = "Land to pack vehicles"
ctld.i18n["en"]["No packable vehicles nearby"] = "No packable vehicles nearby"
ctld.i18n["en"]["Vehicle no longer exists."] = "Vehicle no longer exists."
ctld.i18n["en"]["Cannot pack this vehicle type."] = "Cannot pack this vehicle type."

--- Load / Unload Vehicle submenu (GAP-1)
ctld.i18n["en"]["Land to load vehicles"] = "Land to load vehicles"
ctld.i18n["en"]["No vehicles nearby"] = "No vehicles nearby"
ctld.i18n["en"]["Vehicle no longer available."] = "Vehicle no longer available."
ctld.i18n["en"]["Land to unload vehicles"] = "Land to unload vehicles"
ctld.i18n["en"]["No vehicle loaded."] = "No vehicle loaded."
ctld.i18n["en"]["Vehicle no longer loaded."] = "Vehicle no longer loaded."
ctld.i18n["en"]["Cannot load more vehicles (max: %d)."] = "Cannot load more vehicles (max: %d)."

--- List Nearby Crates
ctld.i18n["en"]["List Nearby Crates"] = "List Nearby Crates"
ctld.i18n["en"]["No crates within 300m."] = "No crates within 300m."
ctld.i18n["en"]["Crates within 300m:"] = "Crates within 300m:"
ctld.i18n["en"]["  %1: %2/%3 — READY"] = "  %1: %2/%3 — READY"
ctld.i18n["en"]["  %1: %2/%3 — incomplete"] = "  %1: %2/%3 — incomplete"

--- Check Cargo summary
ctld.i18n["en"]["No cargo on board."] = "No cargo on board."
ctld.i18n["en"]["%1: %2 crate(s) onboard (%3 kg)"] = "%1: %2 crate(s) onboard (%3 kg)"
ctld.i18n["en"]["%1 troop(s) onboard (%2 kg)"] = "%1 troop(s) onboard (%2 kg)"
ctld.i18n["en"]["%1: %2 vehicle(s) onboard"] = "%1: %2 vehicle(s) onboard"
ctld.i18n["en"]["Total cargo weight: %1 kg"] = "Total cargo weight: %1 kg"

--- Request JTAC Equipment menu
ctld.i18n["en"]["Request JTAC Equipment"] = "Request JTAC Equipment"
ctld.i18n["en"]["You must be landed to request JTAC equipment."] = "You must be landed to request JTAC equipment."
ctld.i18n["en"]["You are not close enough to friendly logistics."] = "You are not close enough to friendly logistics."
ctld.i18n["en"]["%s is ready for pickup."] = "%s is ready for pickup."

--- Request Equipment spawn messages
ctld.i18n["en"]["Land near logistics to request equipment"] = "Land near logistics to request equipment"
ctld.i18n["en"]["All crates"] = "All crates"
ctld.i18n["en"]["No logistics in range"] = "No logistics in range"
ctld.i18n["en"]["You must be landed to request a crate."] = "You must be landed to request a crate."
ctld.i18n["en"]["You are not close enough to friendly logistics to get a crate!"] = "You are not close enough to friendly logistics to get a crate!"
ctld.i18n["en"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = "A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "
ctld.i18n["en"]["%1 crates have been brought out at your %2 o'clock"] = "%1 crates have been brought out at your %2 o'clock"

--- FOBs List menu
ctld.i18n["en"]["FOBs List"] = "FOBs List"
ctld.i18n["en"]["List active FOBs"] = "List active FOBs"
ctld.i18n["en"]["No active FOBs."] = "No active FOBs."
ctld.i18n["en"]["FOB Positions:"] = "FOB Positions:"

--- Keys added by generate_i18n_dicts.ps1 on 2026-03-21
ctld.i18n["en"]["→ Next Page"] = "→ Next Page"

--- Feature H — Smoke auto-resume toggle
ctld.i18n["en"]["Smoke Auto-Resume [activate]"]   = "Smoke Auto-Resume [activate]"
ctld.i18n["en"]["Smoke Auto-Resume [deactivate]"] = "Smoke Auto-Resume [deactivate]"
ctld.i18n["en"]["Smoke auto-resume ON (%1s interval)"]  = "Smoke auto-resume ON (%1s interval)"
ctld.i18n["en"]["Smoke auto-resume OFF"]                = "Smoke auto-resume OFF"

-- End : CTLD_i18n_en.lua
-- ====================================================================================================
-- Start : CTLD_i18n_fr.lua
--[[
    CTLD — French dictionary
    Translation version: 1.7

    Translator: FullGas1
    To update: run tools/merger_V2/generate_i18n_dicts.ps1 after any ctld.tr() change.
]]
if not ctld then ctld = {} end
if not ctld.i18n then ctld.i18n = {} end

ctld.i18n["fr"] = {}
ctld.i18n["fr"].translation_version = "1.8"

--- groups names
ctld.i18n["fr"]["Standard Group"] = "Groupe standard"
ctld.i18n["fr"]["Anti Air"] = "Défense aérienne"
ctld.i18n["fr"]["Anti Tank"] = "Anti Tank"
ctld.i18n["fr"]["Mortar Squad"] = "Groupe mortier"
ctld.i18n["fr"]["JTAC Group"] = "Groupe JTAC"
ctld.i18n["fr"]["Single JTAC"] = "JTAC seul"
ctld.i18n["fr"]["2x - Standard Groups"] = "2x - Groupes standards"
ctld.i18n["fr"]["2x - Anti Air"] = "2x - Défenses aériennes"
ctld.i18n["fr"]["2x - Anti Tank"] = "2x - Anti Tank"
ctld.i18n["fr"]["2x - Standard Groups + 2x Mortar"] = "2x - Groupes standards + 2x Groupes mortiers"
ctld.i18n["fr"]["3x - Standard Groups"] = "3x - Groupes standards"
ctld.i18n["fr"]["3x - Anti Air"] = "3x - Défenses aériennes"
ctld.i18n["fr"]["3x - Anti Tank"] = "3x - Anti Tank"
ctld.i18n["fr"]["3x - Mortar Squad"] = "3x - Groupes mortiers"
ctld.i18n["fr"]["5x - Mortar Squad"] = "5x - Groupes mortiers"
ctld.i18n["fr"]["Mortar Squad Red"] = "Groupe mortier rouge"

--- crates names (untranslated = keep EN via fallback)
ctld.i18n["fr"]["Humvee - MG"] = "Humvee - MG"
ctld.i18n["fr"]["Humvee - TOW"] = "Humvee - TOW"
ctld.i18n["fr"]["Light Tank - MRAP"] = "Char léger - MRAP"
ctld.i18n["fr"]["Med Tank - LAV-25"] = "Char moyen - LAV-25"
ctld.i18n["fr"]["Heavy Tank - Abrams"] = "Char lourd - Abrams"
ctld.i18n["fr"]["BTR-D"] = "BTR-D"
ctld.i18n["fr"]["BRDM-2"] = "BRDM-2"
ctld.i18n["fr"]["Hummer - JTAC"] = "Hummer - JTAC"
ctld.i18n["fr"]["M-818 Ammo Truck"] = "M-818 Camion de munitions"
ctld.i18n["fr"]["M-978 Tanker"] = "M-978 Citerne"
ctld.i18n["fr"]["SKP-11 - JTAC"] = "SKP-11 - JTAC"
ctld.i18n["fr"]["Ural-375 Ammo Truck"] = "Ural-375 Camion de munitions"
ctld.i18n["fr"]["KAMAZ Ammo Truck"] = "KAMAZ Camion de munitions"
ctld.i18n["fr"]["KAMAZ Ammo Truck - All crates"] = "KAMAZ Camion de munitions - Toutes les caisses"
ctld.i18n["fr"]["EWR Radar"] = "Radar de détection TEL"
ctld.i18n["fr"]["FOB Crate"] = "Caisse FOB"
ctld.i18n["fr"]["You must be on the ground to deploy a FOB."] = "Vous devez etre au sol pour deployer un FOB."
ctld.i18n["fr"]["FOB needs %1 crate(s) within 750 m - only %2 found."] = "FOB : %1 caisse(s) requise(s) dans 750 m - seulement %2 trouvee(s)."
ctld.i18n["fr"]["You can't deploy a FOB here! Take it to where it's needed."] = "Vous ne pouvez pas deployer un FOB ici ! Transportez-le la ou il est necessaire."
ctld.i18n["fr"]["FOB deployment blocked: move at least %1 m away from existing logistic zone."] = "Deploiement FOB bloque : eloignez-vous d'au moins %1 m d'une zone logistique."
ctld.i18n["fr"]["%1 started building a FOB (%2 crate(s)). Ready in %3 seconds."] = "%1 commence la construction d'un FOB (%2 caisse(s)). Pret dans %3 secondes."
ctld.i18n["fr"]["FOB established by %1 - logistics hub now active."] = "FOB établi par %1 - hub logistique opérationnel."
ctld.i18n["fr"]["MQ-9 Repear - JTAC"] = "MQ-9 Reaper - JTAC"
ctld.i18n["fr"]["RQ-1A Predator - JTAC"] = "RQ-1A Predator - JTAC"
ctld.i18n["fr"]["MLRS"] = "MLRS"
ctld.i18n["fr"]["SpGH DANA"] = "SpGH DANA"
ctld.i18n["fr"]["T155 Firtina"] = "T155 Firtina"
ctld.i18n["fr"]["Howitzer"] = "Obusier"
ctld.i18n["fr"]["SPH 2S19 Msta"] = "SPH 2S19 Msta"
ctld.i18n["fr"]["M1097 Avenger"] = "M1097 Avenger"
ctld.i18n["fr"]["M48 Chaparral"] = "M48 Chaparral"
ctld.i18n["fr"]["Roland ADS"] = "Roland ADS"
ctld.i18n["fr"]["Gepard AAA"] = "Gepard AAA"
ctld.i18n["fr"]["LPWS C-RAM"] = "LPWS C-RAM"
ctld.i18n["fr"]["9K33 Osa"] = "9K33 Osa"
ctld.i18n["fr"]["9P31 Strela-1"] = "9P31 Strela-1"
ctld.i18n["fr"]["9K35M Strela-10"] = "9K35M Strela-10"
ctld.i18n["fr"]["9K331 Tor"] = "9K331 Tor"
ctld.i18n["fr"]["2K22 Tunguska"] = "2K22 Tunguska"
ctld.i18n["fr"]["HAWK Launcher"] = "HAWK - Lanceur"
ctld.i18n["fr"]["HAWK Search Radar"] = "HAWK - Radar de recherche"
ctld.i18n["fr"]["HAWK Track Radar"] = "HAWK - Radar de poursuite"
ctld.i18n["fr"]["HAWK PCP"] = "HAWK - PCP"
ctld.i18n["fr"]["HAWK CWAR"] = "HAWK - CWAR"
ctld.i18n["fr"]["HAWK Repair"] = "HAWK - Réparation"
ctld.i18n["fr"]["NASAMS Launcher 120C"] = "NASAMS - Lanceur 120C"
ctld.i18n["fr"]["NASAMS Search/Track Radar"] = "NASAMS - Radar recherche/poursuite"
ctld.i18n["fr"]["NASAMS Command Post"] = "NASAMS - Poste de commandement"
ctld.i18n["fr"]["NASAMS Repair"] = "NASAMS - Réparation"
ctld.i18n["fr"]["KUB Launcher"] = "KUB - Lanceur"
ctld.i18n["fr"]["KUB Radar"] = "KUB - Radar"
ctld.i18n["fr"]["KUB Repair"] = "KUB - Réparation"
ctld.i18n["fr"]["BUK Launcher"] = "BUK - Lanceur"
ctld.i18n["fr"]["BUK Search Radar"] = "BUK - Radar de recherche"
ctld.i18n["fr"]["BUK CC Radar"] = "BUK - Radar de contrôle"
ctld.i18n["fr"]["BUK Repair"] = "BUK - Réparation"
ctld.i18n["fr"]["Patriot Launcher"] = "Patriot - Lanceur"
ctld.i18n["fr"]["Patriot Radar"] = "Patriot - Radar"
ctld.i18n["fr"]["Patriot ECS"] = "Patriot - ECS"
ctld.i18n["fr"]["Patriot ICC"] = "Patriot - ICC"
ctld.i18n["fr"]["Patriot EPP"] = "Patriot - EPP"
ctld.i18n["fr"]["Patriot AMG (optional)"] = "Patriot - AMG (optionnel)"
ctld.i18n["fr"]["Patriot Repair"] = "Patriot - Réparation"
ctld.i18n["fr"]["S-300 Grumble TEL C"] = "S-300 Grumble TEL C"
ctld.i18n["fr"]["S-300 Grumble Flap Lid-A TR"] = "S-300 Grumble Flap Lid-A TR"
ctld.i18n["fr"]["S-300 Grumble Clam Shell SR"] = "S-300 Grumble Clam Shell SR"
ctld.i18n["fr"]["S-300 Grumble Big Bird SR"] = "S-300 Grumble Big Bird SR"
ctld.i18n["fr"]["S-300 Grumble C2"] = "S-300 Grumble C2"
ctld.i18n["fr"]["S-300 Repair"] = "S-300 - Réparation"
ctld.i18n["fr"]["Humvee - TOW - All crates"] = "Humvee - TOW - Toutes les caisses"
ctld.i18n["fr"]["Light Tank - MRAP - All crates"] = "Light Tank - MRAP - Toutes les caisses"
ctld.i18n["fr"]["Med Tank - LAV-25 - All crates"] = "Med Tank - LAV-25 - Toutes les caisses"
ctld.i18n["fr"]["Heavy Tank - Abrams - All crates"] = "Heavy Tank - Abrams - Toutes les caisses"
ctld.i18n["fr"]["Hummer - JTAC - All crates"] = "Hummer - JTAC - Toutes les caisses"
ctld.i18n["fr"]["M-818 Ammo Truck - All crates"] = "M-818 Ammo Truck - Toutes les caisses"
ctld.i18n["fr"]["M-978 Tanker - All crates"] = "M-978 Tanker - Toutes les caisses"
ctld.i18n["fr"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 Ammo Truck - Toutes les caisses"
ctld.i18n["fr"]["EWR Radar - All crates"] = "EWR Radar - Toutes les caisses"
ctld.i18n["fr"]["MLRS - All crates"] = "MLRS - Toutes les caisses"
ctld.i18n["fr"]["SpGH DANA - All crates"] = "SpGH DANA - Toutes les caisses"
ctld.i18n["fr"]["T155 Firtina - All crates"] = "T155 Firtina - Toutes les caisses"
ctld.i18n["fr"]["Howitzer - All crates"] = "Howitzer - Toutes les caisses"
ctld.i18n["fr"]["SPH 2S19 Msta - All crates"] = "SPH 2S19 Msta - Toutes les caisses"
ctld.i18n["fr"]["M1097 Avenger - All crates"] = "M1097 Avenger - Toutes les caisses"
ctld.i18n["fr"]["M48 Chaparral - All crates"] = "M48 Chaparral - Toutes les caisses"
ctld.i18n["fr"]["Roland ADS - All crates"] = "Roland ADS - Toutes les caisses"
ctld.i18n["fr"]["Gepard AAA - All crates"] = "Gepard AAA - Toutes les caisses"
ctld.i18n["fr"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - Toutes les caisses"
ctld.i18n["fr"]["9K33 Osa - All crates"] = "9K33 Osa - Toutes les caisses"
ctld.i18n["fr"]["9P31 Strela-1 - All crates"] = "9P31 Strela-1 - Toutes les caisses"
ctld.i18n["fr"]["9K35M Strela-10 - All crates"] = "9K35M Strela-10 - Toutes les caisses"
ctld.i18n["fr"]["9K331 Tor - All crates"] = "9K331 Tor - Toutes les caisses"
ctld.i18n["fr"]["2K22 Tunguska - All crates"] = "2K22 Tunguska - Toutes les caisses"
ctld.i18n["fr"]["HAWK - All crates"] = "HAWK - Toutes les caisses"
ctld.i18n["fr"]["NASAMS - All crates"] = "NASAMS - Toutes les caisses"
ctld.i18n["fr"]["KUB - All crates"] = "KUB - Toutes les caisses"
ctld.i18n["fr"]["BUK - All crates"] = "BUK - Toutes les caisses"
ctld.i18n["fr"]["Patriot - All crates"] = "Patriot - Toutes les caisses"
ctld.i18n["fr"]["S-300 - All crates"] = "S-300 - Toutes les caisses"

--- mission design error messages
-- STALE: ctld.i18n["fr"]["CTLD.lua ERROR: Can't find trigger called %1"] = "CTLD.lua ERREUR : Impossible de trouver le déclencheur appelé %1"
-- STALE: ctld.i18n["fr"]["CTLD.lua ERROR: Can't find zone called %1"] = "CTLD.lua ERREUR : Impossible de trouver la zone appelée %1"
-- STALE: ctld.i18n["fr"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = "CTLD.lua ERREUR : Impossible de trouver la zone ou le navire appelé %1"
-- STALE: ctld.i18n["fr"]["CTLD.lua ERROR: Can't find crate with weight %1"] = "CTLD.lua ERREUR : Impossible de trouver une caisse avec un poids de %1"

--- runtime messages
-- STALE: ctld.i18n["fr"]["You are not close enough to friendly logistics to get a crate!"] = "Vous n'êtes pas assez proche de la logistique alliée pour obtenir une caisse !"
-- STALE: ctld.i18n["fr"]["No more JTAC Crates Left!"] = "Plus de caisses JTAC disponibles !"
-- STALE: ctld.i18n["fr"]["Sorry you must wait %1 seconds before you can get another crate"] = "Désolé, vous devez attendre %1 secondes avant de pouvoir obtenir une autre caisse"
-- STALE: ctld.i18n["fr"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = "Une caisse %1 pesant %2 kg a été apportée et se trouve à vos %3 heure"
-- STALE: ctld.i18n["fr"]["%1 fast-ropped troops from %2 into combat"] = "%1 a largué rapidement des troupes de %2 au combat"
-- STALE: ctld.i18n["fr"]["%1 dropped troops from %2 into combat"] = "%1 a largué des troupes de %2 au combat"
-- STALE: ctld.i18n["fr"]["%1 fast-ropped troops from %2 into %3"] = "%1 a largué rapidement des troupes de %2 à %3"
-- STALE: ctld.i18n["fr"]["%1 dropped troops from %2 into %3"] = "%1 a largué des troupes de %2 à %3"
-- STALE: ctld.i18n["fr"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] = "Trop haut ou trop rapide pour larguer des troupes au combat ! Survolez en dessous de %1 pieds ou atterrissez."
-- STALE: ctld.i18n["fr"]["%1 dropped vehicles from %2 into combat"] = "%1 a largué des véhicules de %2 au combat"
-- STALE: ctld.i18n["fr"]["%1 loaded troops into %2"] = "%1 a chargé des troupes dans %2"
-- STALE: ctld.i18n["fr"]["%1 loaded %2 vehicles into %3"] = "%1 a chargé %2 véhicules dans %3"
-- STALE: ctld.i18n["fr"]["%1 delivered a FOB Crate"] = "%1 a livré une caisse FOB"
-- STALE: ctld.i18n["fr"]["Delivered FOB Crate 60m at 6'oclock to you"] = "Caisse FOB livrée à 60 m à 6 heures de vous"
-- STALE: ctld.i18n["fr"]["FOB Crate dropped back to base"] = "Caisse FOB ramenée à la base"
-- STALE: ctld.i18n["fr"]["FOB Crate Loaded"] = "Caisse FOB chargée"
-- STALE: ctld.i18n["fr"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 a chargé une caisse FOB prête à être livrée !"
-- STALE: ctld.i18n["fr"]["There are no friendly logistic units nearby to load a FOB crate from!"] = "Il n'y a pas d'unités logistiques alliée à proximité pour charger une caisse FOB !"
-- STALE: ctld.i18n["fr"]["This area has no more reinforcements available!"] = "Cette zone n'a plus de renforts disponibles !"
-- STALE: ctld.i18n["fr"]["You are not in a pickup zone and no one is nearby to extract"] = "Vous n'êtes pas dans une zone d'embarquement et personne n'est à proximité pour être extrait."
-- STALE: ctld.i18n["fr"]["You are not in a pickup zone"] = "Vous n'êtes pas dans une zone d'embarquement"
-- STALE: ctld.i18n["fr"]["No one to unload"] = "Personne à débarquer"
-- STALE: ctld.i18n["fr"]["Dropped troops back to base"] = "Troupes larguées à la base"
-- STALE: ctld.i18n["fr"]["Dropped vehicles back to base"] = "Véhicules largués à la base"
-- STALE: ctld.i18n["fr"]["You already have troops onboard."] = "Vous avez déjà des troupes à bord."
-- STALE: ctld.i18n["fr"]["Count Infantries limit in the mission reached, you can't load more troops"] = "Nombre maximum de troupes sur mission atteint, vous ne pouvez pas charger plus de troupes"
-- STALE: ctld.i18n["fr"]["You already have vehicles onboard."] = "Vous avez déjà des véhicules à bord."
-- STALE: ctld.i18n["fr"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] = "Désolé - Le groupe de %1 est trop important. \n\nLa limite est de %2 pour %3"
-- STALE: ctld.i18n["fr"]["%1 extracted troops in %2 from combat"] = "%1 troupes extraites du combat en %2"
-- STALE: ctld.i18n["fr"]["No extractable troops nearby!"] = "Aucune troupe extractible à proximité !"
-- STALE: ctld.i18n["fr"]["%1 extracted vehicles in %2 from combat"] = "%1 véhicules extraits du combat en %2"
-- STALE: ctld.i18n["fr"]["No extractable vehicles nearby!"] = "Aucun véhicule extractible à proximité !"
-- STALE: ctld.i18n["fr"]["%1 troops onboard (%2 kg)\n"] = "%1 troupes à bord (%2 kg)\n"
-- STALE: ctld.i18n["fr"]["%1 vehicles onboard (%2)\n"] = "%1 véhicules à bord (%2)\n"
-- STALE: ctld.i18n["fr"]["1 FOB Crate oboard (%1 kg)\n"] = "1 caisse FOB à bord (%1 kg)\n"
-- STALE: ctld.i18n["fr"]["%1 crate onboard (%2 kg)\n"] = "%1 caisse à bord (%2 kg)\n"
-- STALE: ctld.i18n["fr"]["Total weight of cargo : %1 kg\n"] = "Poids total de la cargaison : %1 kg\n"
-- STALE: ctld.i18n["fr"]["No cargo."] = "Aucune cargaison."
-- STALE: ctld.i18n["fr"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] = "Stationaire au-dessus de la caisse %1. \n\nMaintenez le stationaire pendant %2 secondes ! \n\nSi le compte à rebours s'arrête, vous êtes trop loin !"
-- STALE: ctld.i18n["fr"]["Loaded %1 crate!"] = "Caisse %1 chargée !"
-- STALE: ctld.i18n["fr"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = "Trop bas pour accrocher la caisse %1.\n\nMaintenez le stationaire pendant %2 secondes"
-- STALE: ctld.i18n["fr"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = "Trop haut pour accrocher la caisse %1.\n\nMaintenez le stationaire pendant %2 secondes"
-- STALE: ctld.i18n["fr"]["You must land before you can load a crate!"] = "Vous devez atterrir avant de pouvoir charger une caisse !"
-- STALE: ctld.i18n["fr"]["No Crates within 50m to load!"] = "Aucune caisse à moins de 50 m pour charger !"
-- STALE: ctld.i18n["fr"]["Maximum number of crates are on board!"] = "Nombre maximal de caisses à bord !"
-- STALE: ctld.i18n["fr"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caisse - kg %3 - %4 m - %5 heures"
-- STALE: ctld.i18n["fr"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caisse FOB - %1 m - %2 heures\n"
-- STALE: ctld.i18n["fr"]["No Nearby Crates"] = "Aucune caisse à proximité"
-- STALE: ctld.i18n["fr"]["Nearby Crates:\n%1"] = "Caisses à proximité :\n%1"
-- STALE: ctld.i18n["fr"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = "Caisses FOB à proximité (non chargeables par élingue) :\n%1"
-- STALE: ctld.i18n["fr"]["FOB Positions:"] = "Positions FOB :"
-- STALE: ctld.i18n["fr"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
-- STALE: ctld.i18n["fr"]["Sorry, there are no active FOBs!"] = "Désolé, il n'y a pas de FOB actif !"
-- STALE: ctld.i18n["fr"]["You can't unpack that here! Take it to where it's needed!"] = "Vous ne pouvez déballer ça ici ! Emmenez-le là où vous en avez besoin !"
-- STALE: ctld.i18n["fr"]["Sorry you must move this crate before you unpack it!"] = "Désolé, vous devez déplacer cette caisse avant de la déballer !"
-- STALE: ctld.i18n["fr"]["%1 successfully deployed %2 to the field"] = "%1 a déployé avec succès %2 sur le terrain."
-- STALE: ctld.i18n["fr"]["No friendly crates close enough to unpack, or crate too close to aircraft."] = "Aucune caisse alliée n'est suffisamment proche pour être déballée, ou la caisse est trop proche d'un avion."
-- STALE: ctld.i18n["fr"]["Finished building FOB! Crates and Troops can now be picked up."] = "Construction du FOB terminée ! Les caisses et les troupes peuvent maintenant embarqués."
-- STALE: ctld.i18n["fr"]["Finished building FOB! Crates can now be picked up."] = "Construction du FOB terminée ! Les caisses peuvent maintenant être embarqués."
-- STALE: ctld.i18n["fr"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] = "%1 a commencé à construire le FOB en utilisant %2 caisses FOB, il sera terminé dans %3 secondes.\nPosition marquée par le fumigène."
-- STALE: ctld.i18n["fr"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] = "Impossible de construire le FOB !\n\nIl nécessite %1 grandes caisses FOB (3 petites caisses FOB équivalent à 1 grande caisse FOB) et il y a l'équivalent de %2 grandes caisses FOB à proximité\n\nOu les caisses ne sont pas à moins de 750 m les unes des autres autre"
-- STALE: ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] = "Vous ne transportez actuellement aucune caisse. \n\nPour charger une caisse, survolez la caisse pendant %1 secondes ou atterrissez et utilisez les commandes de caisse F10."
-- STALE: ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] = "Vous ne transportez actuellement aucune caisse. \n\nPour ramasser une caisse, survolez la caisse pendant %1 secondes."
-- STALE: ctld.i18n["fr"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] = "Vous ne transportez actuellement aucune caisse. \n\nPour charger une caisse, atterrissez et utilisez les commandes de caisse F10."
-- STALE: ctld.i18n["fr"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = "%1 caisse a été décrochée en toute sécurité et se trouve à vos %2 heures"
-- STALE: ctld.i18n["fr"]["%1 crate has been safely dropped below you"] = "%1 caisse a été déposée en toute sécurité sous vous"
-- STALE: ctld.i18n["fr"]["You were too high! The crate has been destroyed"] = "Vous étiez trop haut! La caisse a été détruite"
--- Radio Beacon messages
ctld.i18n["fr"]["No Radio Beacons within 500m."] = "Aucune balise radio dans un rayon de 500 m."
ctld.i18n["fr"]["Navigation beacon deployed - %1"] = "Balise de navigation déployée - %1"
ctld.i18n["fr"]["Radio beacon removed - %1"] = "Balise radio retirée - %1"
ctld.i18n["fr"]["Radio Beacons:"] = "Balises radio :"
ctld.i18n["fr"]["No Active Radio Beacons"] = "Aucune balise radio active"
ctld.i18n["fr"]["Beacon layer enabled. %1 beacon(s)."] = "Couche balises activée. %1 balise(s)."
ctld.i18n["fr"]["Beacon layer disabled."] = "Couche balises désactivée."
ctld.i18n["fr"]["CTLD"] = "CTLD"
ctld.i18n["fr"]["Radio Beacons"] = "Balises radio"
ctld.i18n["fr"]["Drop Beacon"] = "Déposer balise"
ctld.i18n["fr"]["Remove Closest Beacon"] = "Retirer balise la plus proche"
ctld.i18n["fr"]["List Beacons"] = "Lister balises"
-- STALE: ctld.i18n["fr"]["Radio Beacons:\n%1"] = "Balises radio :\n%1"
-- STALE: ctld.i18n["fr"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 a déployé une balise radio.\n\n%2"
-- STALE: ctld.i18n["fr"]["You need to land before you can deploy a Radio Beacon!"] = "Vous devez atterrir avant de pouvoir déployer une balise radio !"
-- STALE: ctld.i18n["fr"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 a supprimé une balise radio.\n\n%2"
-- STALE: ctld.i18n["fr"]["You need to land before remove a Radio Beacon"] = "Vous devez atterrir avant de retirer une balise radio"
-- STALE: ctld.i18n["fr"]["%1 successfully rearmed a full %2 in the field"] = "%1 a réarmé avec succès un %2 complet sur le terrain"
-- STALE: ctld.i18n["fr"]["Missing %1\n"] = "%1 manquant\n"
-- STALE: ctld.i18n["fr"]["Out of parts for AA Systems. Current limit is %1\n"] = "Plus de pièces pour les systèmes AA. La limite actuelle est de %1\n"
-- STALE: ctld.i18n["fr"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] = "Impossible de construire %1\n%2\n\nOu les caisses ne sont pas assez proches les unes des autres"
-- STALE: ctld.i18n["fr"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] = "%1 a déployé avec succès un %2 complet sur le terrain. \n\nLa limite du système actif AA est : %3\nActif : %4"
-- STALE: ctld.i18n["fr"]["%1 successfully repaired a full %2 in the field."] = "%1 a réparé avec succès un %2 complet sur le terrain."
-- STALE: ctld.i18n["fr"]["Cannot repair %1. No damaged %2 within 300m"] = "Impossible de réparer %1. Aucun %2 endommagé à moins de 300 m"
-- STALE: ctld.i18n["fr"]["%1 successfully deployed %2 to the field using %3 crates."] = "%1 a déployé avec succès %2 sur le terrain en utilisant %3 caisses."
-- STALE: ctld.i18n["fr"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] = "Impossible de construire %1 !\n\nIl faut %2 caisses et il y en a %3 \n\nOu les caisses ne sont pas à moins de 300 m les unes des autres"
-- STALE: ctld.i18n["fr"]["%1 dropped %2 smoke."] = "%1 a largué un fumigène %2."

--- JTAC messages
-- STALE: ctld.i18n["fr"]["JTAC Group %1 KIA!"] = "Groupe JTAC %1 KIA !"
-- STALE: ctld.i18n["fr"]["%1, selected target reacquired, %2"] = "%1, cible sélectionnée réacquise, %2"
-- STALE: ctld.i18n["fr"][". CODE: %1. POSITION: %2"] = ". CODE : %1. POSITION : %2"
-- STALE: ctld.i18n["fr"]["new target, "] = "nouvelle cible, "
-- STALE: ctld.i18n["fr"]["standing by on %1"] = "en attente sur %1"
-- STALE: ctld.i18n["fr"]["lasing %1"] = "laser %1"
-- STALE: ctld.i18n["fr"][", temporarily %1"] = ", temporairement %1"
-- STALE: ctld.i18n["fr"]["target lost"] = "cible perdue"
-- STALE: ctld.i18n["fr"]["target destroyed"] = "cible détruite"
-- STALE: ctld.i18n["fr"][", selected %1"] = ", %1 sélectionné"
-- STALE: ctld.i18n["fr"]["%1 %2 target lost."] = "%1 %2 cible perdue."
-- STALE: ctld.i18n["fr"]["%1 %2 target destroyed."] = "%1 %2 cible détruite."
-- STALE: ctld.i18n["fr"]["JTAC STATUS: \n\n"] = "ÉTAT JTAC : \n\n"
-- STALE: ctld.i18n["fr"][", available on %1 %2,"] = ", disponible sur %1 %2,"
-- STALE: ctld.i18n["fr"]["UNKNOWN"] = "INCONNU"
-- STALE: ctld.i18n["fr"][" targeting "] = " ciblage "
-- STALE: ctld.i18n["fr"][" targeting selected unit "] = " ciblage de l'unité sélectionnée "
-- STALE: ctld.i18n["fr"][" attempting to find selected unit, temporarily targeting "] = " tentative de recherche de l'unité sélectionnée, ciblage temporaire "
-- STALE: ctld.i18n["fr"]["(Laser OFF) "] = "(Laser INACTIF) "
-- STALE: ctld.i18n["fr"]["Visual On: "] = "Visuel activé : "
-- STALE: ctld.i18n["fr"][" searching for targets %1\n"] = " recherche de cibles %1\n"
-- STALE: ctld.i18n["fr"]["No Active JTACs"] = "Aucun JTAC actif"
-- STALE: ctld.i18n["fr"][", targeting selected unit, %1"] = ", ciblage de l'unité sélectionnée, %1"
-- STALE: ctld.i18n["fr"][", target selection reset."] = ", sélection de cible réinitialisée."
-- STALE: ctld.i18n["fr"]["%1, laser and smokes enabled"] = "%1, laser et fumigènes activés"
-- STALE: ctld.i18n["fr"]["%1, laser and smokes disabled"] = "%1, laser et fumigènes désactivés"
-- STALE: ctld.i18n["fr"]["%1, wind and target speed laser spot compensations enabled"] = "%1, compensations activées de la vitesse du vent et de la cible pour le spot laser"
-- STALE: ctld.i18n["fr"]["%1, wind and target speed laser spot compensations disabled"] = "%1, compensations désactivées de la vitesse du vent et de la cible pour le spot laser"
-- STALE: ctld.i18n["fr"]["%1, WHITE smoke deployed near target"] = "%1, fumigène BLANCHE déployée près de la cible"

--- F10 menu messages
-- STALE: ctld.i18n["fr"]["Actions"] = "Actions"
-- STALE: ctld.i18n["fr"]["Troop Transport"] = "Transport troupes"
-- STALE: ctld.i18n["fr"]["Unload / Extract Troops"] = "Débarqt / Embarqt Troupes"
-- STALE: ctld.i18n["fr"]["Next page"] = "page suiv."
-- STALE: ctld.i18n["fr"]["Load "] = "Charger "
-- STALE: ctld.i18n["fr"]["Vehicle / FOB Transport"] = "Transport Vehicule / FOB"
-- STALE: ctld.i18n["fr"]["Crates: Vehicle / FOB / Drone"] = "Caisses Vehicule / FOB / Drone"
-- STALE: ctld.i18n["fr"]["Unload Vehicles"] = "Décharger Vehicles"
-- STALE: ctld.i18n["fr"]["Load / Extract Vehicles"] = "Chargt / Déchargt Vehicules"
-- STALE: ctld.i18n["fr"]["Load / Unload FOB Crate"] = "Chargt / Déchargt Caisse FOB"
-- STALE: ctld.i18n["fr"]["Pack Vehicles"] = "Emballer véhicules"
-- STALE: ctld.i18n["fr"]["CTLD Commands"] = "Commandes CTLD"
-- STALE: ctld.i18n["fr"]["CTLD"] = "CTLD"
-- STALE: ctld.i18n["fr"]["Check Cargo"] = "Vérif° chargement"
-- STALE: ctld.i18n["fr"]["Load Nearby Crate(s)"] = "Charger caisse(s) proche"
-- STALE: ctld.i18n["fr"]["Unpack Any Crate"] = "Déballer caisses"
-- STALE: ctld.i18n["fr"]["Drop Crate(s)"] = "Décharger caisse(s)"
-- STALE: ctld.i18n["fr"]["List Nearby Crates"] = "Liste caisses proches"
-- STALE: ctld.i18n["fr"]["List FOBs"] = "Liste FOBs"
-- STALE: ctld.i18n["fr"]["List Beacons"] = "Liste balises"
-- STALE: ctld.i18n["fr"]["List Radio Beacons"] = "Liste Radio balises"
-- STALE: ctld.i18n["fr"]["Smoke Markers"] = "Marques Fumées"
-- STALE: ctld.i18n["fr"]["Drop Red Smoke"] = "Déposer Fumi Rouge"
-- STALE: ctld.i18n["fr"]["Drop Blue Smoke"] = "Déposer Fumi Bleu"
-- STALE: ctld.i18n["fr"]["Drop Orange Smoke"] = "Déposer Fumi Orange"
-- STALE: ctld.i18n["fr"]["Drop Green Smoke"] = "Déposer Fumi Vert"
-- STALE: ctld.i18n["fr"]["JTAC Status"] = "Statut JTAC"
-- STALE: ctld.i18n["fr"]["DISABLE "] = "DESACTIVE "
-- STALE: ctld.i18n["fr"]["ENABLE "] = "ACTIVE "
-- STALE: ctld.i18n["fr"]["REQUEST "] = "DEMANDE"
-- STALE: ctld.i18n["fr"]["Reset TGT Selection"] = "Réinitialiser sélection TGT"

--- F10 RECON menus
ctld.i18n["fr"]["activate"] = "activer"
ctld.i18n["fr"]["deactivate"] = "désactiver"
ctld.i18n["fr"]["RECON"] = "RECONNAISSANCE"
ctld.i18n["fr"]["RECON [Start]"] = "RECON [Démarrer]"
ctld.i18n["fr"]["RECON [Stop]"] = "RECON [Arrêter]"
ctld.i18n["fr"]["Scan Area"] = "Scanner la zone"
ctld.i18n["fr"]["Hide All Targets"] = "Masquer toutes les cibles"
ctld.i18n["fr"]["Toggle %s"] = "Basculer %s"
ctld.i18n["fr"]["Auto-Refresh: [OFF]"] = "Actualisation auto : [OFF]"
ctld.i18n["fr"]["Auto-Refresh: [ON]"] = "Actualisation auto : [ON]"
ctld.i18n["fr"]["Altitude too low for recon scan (min %1 m)"] = "Altitude trop basse pour le scan reco (min %1 m)"
ctld.i18n["fr"]["No recon layers enabled. Activate layers first."] = "Aucune couche reco activée. Activez les couches d'abord."
ctld.i18n["fr"]["Recon stopped. %1 targets hidden."] = "Reconnaissance arrêtée. %1 cible(s) masquée(s)."
ctld.i18n["fr"]["No active recon scan to hide."] = "Aucun scan de reconnaissance actif à masquer."
ctld.i18n["fr"]["No active recon scan. Use 'Scan Area' first."] = "Aucun scan actif. Utilisez 'Scanner la zone' d'abord."
ctld.i18n["fr"]["Auto-refresh enabled. Targets update every %1 s."] = "Actualisation automatique activée. Mise à jour toutes les %1 s."
ctld.i18n["fr"]["Auto-refresh disabled. Current targets frozen on map."] = "Actualisation automatique désactivée. Cibles gelées sur la carte."
ctld.i18n["fr"]["Recon layer '%1': %2"] = "Couche reco '%1' : %2"
-- STALE: ctld.i18n["fr"]["Layers"] = "Couches"
-- STALE: ctld.i18n["fr"]["Show targets in LOS (refresh)"] = "Marquer cibles visibles sur carte F10"
-- STALE: ctld.i18n["fr"]["Hide targets in LOS"] = "Effacer marques sur carte F10"
-- STALE: ctld.i18n["fr"]["Scan targets in LOS"] = "Scanner les cibles en LOS"
-- STALE: ctld.i18n["fr"]["START autoRefresh"] = "Démarrer actualisation auto"
-- STALE: ctld.i18n["fr"]["STOP autoRefresh"] = "Stopper actualisation auto"
-- STALE: ctld.i18n["fr"]["START autoRefresh targets in LOS"] = "Lancer suivi automatique des cibles"
-- STALE: ctld.i18n["fr"]["STOP autoRefresh targets in LOS"] = "Stopper suivi automatique des cibles"

--- Load Crate submenu
ctld.i18n["fr"]["Load Crate"] = "Charger caisse"
ctld.i18n["fr"]["Land to load crates"] = "Atterrissez pour charger une caisse"
ctld.i18n["fr"]["No crates within 50m"] = "Aucune caisse dans 50 m"
ctld.i18n["fr"]["You must land before you can load a crate!"] = "Vous devez atterrir avant de pouvoir charger une caisse !"
ctld.i18n["fr"]["Maximum number of crates are on board!"] = "Nombre maximal de caisses à bord !"
ctld.i18n["fr"]["No crates within 50m to load!"] = "Aucune caisse à moins de 50 m pour charger !"
ctld.i18n["fr"]["Loaded %1 crate!"] = "Caisse %1 chargée !"

--- Drop Crate(s)
ctld.i18n["fr"]["No crates on board to drop."] = "Aucune caisse à bord à déposer."
ctld.i18n["fr"]["You must land before dropping crates!"] = "Vous devez atterrir avant de déposer les caisses !"
ctld.i18n["fr"]["%1 crate(s) dropped at your %2 o'clock"] = "%1 caisse(s) déposée(s) à vos %2 heures"

--- Unpack Crate submenu
ctld.i18n["fr"]["Unpack Crate"] = "Déballer caisses"
ctld.i18n["fr"]["Land to unpack crates"] = "Atterrissez pour déballer"
ctld.i18n["fr"]["No complete crate sets nearby"] = "Aucun lot complet de caisses à proximité"
ctld.i18n["fr"]["Build FOB"] = "Construire un FOB"
ctld.i18n["fr"]["You must land before unpacking crates!"] = "Vous devez atterrir avant de déballer les caisses !"
ctld.i18n["fr"]["Not enough crates nearby to unpack!"] = "Pas assez de caisses à proximité pour déballer !"
ctld.i18n["fr"]["%1 unpacked successfully!"] = "%1 déballé avec succès !"

--- Pack Vehicle submenu
ctld.i18n["fr"]["Land to pack vehicles"] = "Atterrissez pour emballer des véhicules"
ctld.i18n["fr"]["No packable vehicles nearby"] = "Aucun véhicule emballable à proximité"
ctld.i18n["fr"]["Vehicle no longer exists."] = "Le véhicule n'existe plus."
ctld.i18n["fr"]["Cannot pack this vehicle type."] = "Impossible d'emballer ce type de véhicule."

--- Load / Unload Vehicle submenu (GAP-1)
ctld.i18n["fr"]["Land to load vehicles"] = "Atterrissez pour charger des véhicules"
ctld.i18n["fr"]["No vehicles nearby"] = "Aucun véhicule à proximité"
ctld.i18n["fr"]["Vehicle no longer available."] = "Le véhicule n'est plus disponible."
ctld.i18n["fr"]["Land to unload vehicles"] = "Atterrissez pour décharger des véhicules"
ctld.i18n["fr"]["No vehicle loaded."] = "Aucun véhicule chargé."
ctld.i18n["fr"]["Vehicle no longer loaded."] = "Le véhicule n'est plus chargé."
ctld.i18n["fr"]["Cannot load more vehicles (max: %d)."] = "Impossible de charger davantage de véhicules (max : %d)."

--- List Nearby Crates
ctld.i18n["fr"]["List Nearby Crates"] = "Liste caisses proches"
ctld.i18n["fr"]["No crates within 300m."] = "Aucune caisse dans un rayon de 300m."
ctld.i18n["fr"]["Crates within 300m:"] = "Caisses dans un rayon de 300m :"
ctld.i18n["fr"]["  %1: %2/%3 — READY"] = "  %1 : %2/%3 — PRÊT"
ctld.i18n["fr"]["  %1: %2/%3 — incomplete"] = "  %1 : %2/%3 — incomplet"

--- Check Cargo summary
ctld.i18n["fr"]["No cargo on board."] = "Aucune cargaison à bord."
ctld.i18n["fr"]["%1: %2 crate(s) onboard (%3 kg)"] = "%1 : %2 caisse(s) en soute (%3 kg)"
ctld.i18n["fr"]["%1 troop(s) onboard (%2 kg)"] = "%1 soldat(s) en soute (%2 kg)"
ctld.i18n["fr"]["%1: %2 vehicle(s) onboard"] = "%1 : %2 véhicule(s) en soute"
ctld.i18n["fr"]["Total cargo weight: %1 kg"] = "Poids total du chargement : %1 kg"

--- Request JTAC Equipment menu
ctld.i18n["fr"]["Request JTAC Equipment"] = "Demander équipement JTAC"
ctld.i18n["fr"]["You must be landed to request JTAC equipment."] = "Vous devez être posé pour demander un équipement JTAC."
ctld.i18n["fr"]["You are not close enough to friendly logistics."] = "Vous n'êtes pas assez proche de la logistique alliée."
ctld.i18n["fr"]["%s is ready for pickup."] = "%s est prêt pour embarquement."

--- Request Equipment spawn messages
ctld.i18n["fr"]["Land near logistics to request equipment"] = "Atterrissez près d'une logistique pour demander du matériel"
ctld.i18n["fr"]["No logistics in range"] = "Aucune logistique à portée"
ctld.i18n["fr"]["All crates"] = "Toutes les caisses"
ctld.i18n["fr"]["You must be landed to request a crate."] = "Vous devez être posé pour demander une caisse."
ctld.i18n["fr"]["You are not close enough to friendly logistics to get a crate!"] = "Vous n'êtes pas assez proche de la logistique alliée pour obtenir une caisse !"
ctld.i18n["fr"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = "Une caisse %1 pesant %2 kg a été apportée et se trouve à vos %3 heures"
ctld.i18n["fr"]["%1 crates have been brought out at your %2 o'clock"] = "%1 caisses ont été apportées à vos %2 heures"

--- FOBs List menu
ctld.i18n["fr"]["FOBs List"] = "Liste des FOBs"
ctld.i18n["fr"]["List active FOBs"] = "Lister les FOBs actifs"
ctld.i18n["fr"]["No active FOBs."] = "Aucun FOB actif."
ctld.i18n["fr"]["FOB Positions:"] = "Positions FOB :"

--- Keys added by generate_i18n_dicts.ps1 on 2026-03-21
ctld.i18n["fr"]["→ Next Page"] = "→ Page suivante"

--- Feature H — Smoke auto-resume toggle
ctld.i18n["fr"]["Smoke Auto-Resume [activate]"]   = "Fumée auto-reprise [activer]"
ctld.i18n["fr"]["Smoke Auto-Resume [deactivate]"] = "Fumée auto-reprise [désactiver]"
ctld.i18n["fr"]["Smoke auto-resume ON (%1s interval)"]  = "Fumée auto-reprise ACTIVE (intervalle %1s)"
ctld.i18n["fr"]["Smoke auto-resume OFF"]                = "Fumée auto-reprise DÉSACTIVÉE"

-- End : CTLD_i18n_fr.lua
-- ====================================================================================================
-- Start : CTLD_i18n_es.lua
--[[
    CTLD — Spanish dictionary
    Translation version: 1.7

    Translator: FullGas1
    Deduplicated from source: where duplicate keys existed the last occurrence is kept (Lua semantics).
    To update: run tools/merger_V2/generate_i18n_dicts.ps1 after any ctld.tr() change.
]]
if not ctld then ctld = {} end
if not ctld.i18n then ctld.i18n = {} end

ctld.i18n["es"] = {}
ctld.i18n["es"].translation_version = "1.8"

--- groups names
ctld.i18n["es"]["Standard Group"] = "Grupo estándar"
ctld.i18n["es"]["Anti Air"] = "Defensa aérea"
ctld.i18n["es"]["Anti Tank"] = "Antitanque"
ctld.i18n["es"]["Mortar Squad"] = "Grupo mortero"
ctld.i18n["es"]["JTAC Group"] = "Grupo JTAC"
ctld.i18n["es"]["Single JTAC"] = "JTAC solo"
ctld.i18n["es"]["2x - Standard Groups"] = "2x - Grupos estándares"
ctld.i18n["es"]["2x - Anti Air"] = "2x - Defensas aéreas"
ctld.i18n["es"]["2x - Anti Tank"] = "2x - Antitanque"
ctld.i18n["es"]["2x - Standard Groups + 2x Mortar"] = "2x - Grupos estándar + 2x Grupos morteros"
ctld.i18n["es"]["3x - Standard Groups"] = "3x - Defensas aéreas"
ctld.i18n["es"]["3x - Anti Air"] = "3x - Defensas aéreas"
ctld.i18n["es"]["3x - Anti Tank"] = "3x - Antitanque"
ctld.i18n["es"]["3x - Mortar Squad"] = "3x - Grupos de morteros"
ctld.i18n["es"]["5x - Mortar Squad"] = "5x - Grupos de morteros"
ctld.i18n["es"]["Mortar Squad Red"] = "Grupo mortero rojo"

--- crates names
ctld.i18n["es"]["Humvee - MG"] = "Humvee - Antipersonal .50 cal"
ctld.i18n["es"]["Humvee - TOW"] = "Humvee - Antitanque TOW"
ctld.i18n["es"]["Light Tank - MRAP"] = "Tanque ligero - MRAP"
ctld.i18n["es"]["Med Tank - LAV-25"] = "Tanque Med - LAV-25"
ctld.i18n["es"]["Heavy Tank - Abrams"] = "Tanque pesado - Abrams"
ctld.i18n["es"]["BTR-D"] = "BTR-D - Transporte de tropas"
ctld.i18n["es"]["BRDM-2"] = "BRDM-2 - Reconocimiento"
ctld.i18n["es"]["Hummer - JTAC"] = "JTAC Hummer"
ctld.i18n["es"]["M-818 Ammo Truck"] = "Camión M-818 de municiones"
ctld.i18n["es"]["M-978 Tanker"] = "Camión cisterna M-978"
ctld.i18n["es"]["SKP-11 - JTAC"] = "JTAC SKP-11"
ctld.i18n["es"]["Ural-375 Ammo Truck"] = "Camión Ural-375 de municiones"
ctld.i18n["es"]["KAMAZ Ammo Truck"] = "Camión KAMAZ de municiones"
ctld.i18n["es"]["KAMAZ Ammo Truck - All crates"] = "Camión KAMAZ de municiones - Todas las cajas"
ctld.i18n["es"]["EWR Radar"] = "Radar Alerta Temprana"
ctld.i18n["es"]["FOB Crate"] = "Caja FOB"
ctld.i18n["es"]["You must be on the ground to deploy a FOB."] = "Debes estar en el suelo para desplegar un FOB."
ctld.i18n["es"]["FOB needs %1 crate(s) within 750 m - only %2 found."] = "El FOB necesita %1 caja(s) en 750 m - solo se encontraron %2."
ctld.i18n["es"]["You can't deploy a FOB here! Take it to where it's needed."] = "No puedes desplegar un FOB aqui! Llevalo donde sea necesario."
ctld.i18n["es"]["FOB deployment blocked: move at least %1 m away from existing logistic zone."] = "Despliegue de FOB bloqueado: alejate al menos %1 m de una zona logistica."
ctld.i18n["es"]["%1 started building a FOB (%2 crate(s)). Ready in %3 seconds."] = "%1 comenzo a construir un FOB (%2 caja(s)). Listo en %3 segundos."
ctld.i18n["es"]["FOB established by %1 - logistics hub now active."] = "FOB establecido por %1 - centro logístico activo."
ctld.i18n["es"]["MQ-9 Repear - JTAC"] = "JTAC MQ-9 Repear"
ctld.i18n["es"]["RQ-1A Predator - JTAC"] = "JTAC RQ-1A Predator"
ctld.i18n["es"]["MLRS"] = "MLRS - Artilleria de cohetes"
ctld.i18n["es"]["SpGH DANA"] = "Obus autopropulsado SpGH DANA"
ctld.i18n["es"]["T155 Firtina"] = "Obus autopropulsado T155 Firtina"
ctld.i18n["es"]["Howitzer"] = "Obus autopropulsado M109A6 Paladin"
ctld.i18n["es"]["SPH 2S19 Msta"] = "SPH 2S19 Msta - Obus Autopropulsado"
ctld.i18n["es"]["M1097 Avenger"] = "M1097 Avenger - SAM Corta Distancia"
ctld.i18n["es"]["M48 Chaparral"] = "M48 Chaparral - SAM Corta Distancia"
ctld.i18n["es"]["Roland ADS"] = "Roland ADS - Lanzador"
ctld.i18n["es"]["Gepard AAA"] = "Gepard AAA - AAA"
ctld.i18n["es"]["LPWS C-RAM"] = "LPWS C-RAM - AAA"
ctld.i18n["es"]["9K33 Osa"] = "9K33 Osa - SA-8 Gecko"
ctld.i18n["es"]["9P31 Strela-1"] = "9P31 Strela-1 - SA-9 Gaskin"
ctld.i18n["es"]["9K35M Strela-10"] = "9K35M Strela-10 - SA-13 Gopher"
ctld.i18n["es"]["9K331 Tor"] = "9K331 Tor - SA-15 Tor"
ctld.i18n["es"]["2K22 Tunguska"] = "2K22 Tunguska - SA-19 Tunguska"
ctld.i18n["es"]["HAWK Launcher"] = "HAWK - Lanzador"
ctld.i18n["es"]["HAWK Search Radar"] = "HAWK - Radar de Búsqueda"
ctld.i18n["es"]["HAWK Track Radar"] = "HAWK - Radar de Seguimiento"
ctld.i18n["es"]["HAWK PCP"] = "HAWK - Puesto de Comando"
ctld.i18n["es"]["HAWK CWAR"] = "HAWK - Sistema de Control de Guerra"
ctld.i18n["es"]["HAWK Repair"] = "Reparar HAWK"
ctld.i18n["es"]["NASAMS Launcher 120C"] = "NASAMS - Lanzador 120C"
ctld.i18n["es"]["NASAMS Search/Track Radar"] = "NASAMS - Radar de Búsqueda/Seguimiento"
ctld.i18n["es"]["NASAMS Command Post"] = "NASAMS - Puesto de Mando"
ctld.i18n["es"]["NASAMS Repair"] = "Reparar NASAMS"
ctld.i18n["es"]["KUB Launcher"] = "KUB - Lanzador"
ctld.i18n["es"]["KUB Radar"] = "KUB - Radar"
ctld.i18n["es"]["KUB Repair"] = "Reparar KUB"
ctld.i18n["es"]["BUK Launcher"] = "BUK - Lanzador"
ctld.i18n["es"]["BUK Search Radar"] = "BUK - Radar de Búsqueda"
ctld.i18n["es"]["BUK CC Radar"] = "BUK - Radar de Control de Combate"
ctld.i18n["es"]["BUK Repair"] = "Reparar BUK"
ctld.i18n["es"]["Patriot Launcher"] = "Patriot - Lanzador"
ctld.i18n["es"]["Patriot Radar"] = "Patriot - Radar de Búsqueda"
ctld.i18n["es"]["Patriot ECS"] = "Patriot - Puesto de Mando"
ctld.i18n["es"]["Patriot ICC"] = "Patriot - Sistema de Control de Fuego"
ctld.i18n["es"]["Patriot EPP"] = "Patriot - Generador"
ctld.i18n["es"]["Patriot AMG (optional)"] = "Patriot - AMG (opcional)"
ctld.i18n["es"]["Patriot Repair"] = "Reparar Patriot"
ctld.i18n["es"]["S-300 Grumble TEL C"] = "S-300 Grumble TEL C - Lanzador"
ctld.i18n["es"]["S-300 Grumble Flap Lid-A TR"] = "S-300 Grumble Flap Lid-A TR - Radar de Seguimiento"
ctld.i18n["es"]["S-300 Grumble Clam Shell SR"] = "S-300 Grumble Clam Shell SR - Radar de Búsqueda"
ctld.i18n["es"]["S-300 Grumble Big Bird SR"] = "S-300 Grumble Big Bird SR - Radar de Búsqueda"
ctld.i18n["es"]["S-300 Grumble C2"] = "S-300 Grumble C2 - Puesto de Mando"
ctld.i18n["es"]["S-300 Repair"] = "Reparar S-300"
ctld.i18n["es"]["Humvee - TOW - All crates"] = "Humvee - TOW - Todas las cajas"
ctld.i18n["es"]["Light Tank - MRAP - All crates"] = "Light Tank - MRAP - Todas las cajas"
ctld.i18n["es"]["Med Tank - LAV-25 - All crates"] = "Med Tank - LAV-25 - Todas las cajas"
ctld.i18n["es"]["Heavy Tank - Abrams - All crates"] = "Heavy Tank - Abrams - Todas las cajas"
ctld.i18n["es"]["Hummer - JTAC - All crates"] = "Hummer - JTAC - Todas las cajas"
ctld.i18n["es"]["M-818 Ammo Truck - All crates"] = "M-818 Ammo Truck - Todas las cajas"
ctld.i18n["es"]["M-978 Tanker - All crates"] = "M-978 Tanker - Todas las cajas"
ctld.i18n["es"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 Ammo Truck - Todas las cajas"
ctld.i18n["es"]["EWR Radar - All crates"] = "EWR Radar - Todas las cajas"
ctld.i18n["es"]["MLRS - All crates"] = "MLRS - Todas las cajas"
ctld.i18n["es"]["SpGH DANA - All crates"] = "SpGH DANA - Todas las cajas"
ctld.i18n["es"]["T155 Firtina - All crates"] = "T155 Firtina - Todas las cajas"
ctld.i18n["es"]["Howitzer - All crates"] = "Howitzer - Todas las cajas"
ctld.i18n["es"]["SPH 2S19 Msta - All crates"] = "SPH 2S19 Msta - Todas las cajas"
ctld.i18n["es"]["M1097 Avenger - All crates"] = "M1097 Avenger - Todas las cajas"
ctld.i18n["es"]["M48 Chaparral - All crates"] = "M48 Chaparral - Todas las cajas"
ctld.i18n["es"]["Roland ADS - All crates"] = "Roland ADS - Todas las cajas"
ctld.i18n["es"]["Gepard AAA - All crates"] = "Gepard AAA - Todas las cajas"
ctld.i18n["es"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - Todas las cajas"
ctld.i18n["es"]["9K33 Osa - All crates"] = "9K33 Osa - Todas las cajas"
ctld.i18n["es"]["9P31 Strela-1 - All crates"] = "9P31 Strela-1 - Todas las cajas"
ctld.i18n["es"]["9K35M Strela-10 - All crates"] = "9K35M Strela-10 - Todas las cajas"
ctld.i18n["es"]["9K331 Tor - All crates"] = "9K331 Tor - Todas las cajas"
ctld.i18n["es"]["2K22 Tunguska - All crates"] = "2K22 Tunguska - Todas las cajas"
ctld.i18n["es"]["HAWK - All crates"] = "HAWK - Todas las cajas"
ctld.i18n["es"]["NASAMS - All crates"] = "NASAMS - Todas las cajas"
ctld.i18n["es"]["KUB - All crates"] = "KUB - Todas las cajas"
ctld.i18n["es"]["BUK - All crates"] = "BUK - Todas las cajas"
ctld.i18n["es"]["Patriot - All crates"] = "Patriot - Todas las cajas"
ctld.i18n["es"]["S-300 - All crates"] = "S-300 - Todas las cajas"

--- mission design error messages
-- STALE: ctld.i18n["es"]["CTLD.lua ERROR: Can't find trigger called %1"] = "CTLD.lua ERROR : Imposible encontrar el activador llamado %1"
-- STALE: ctld.i18n["es"]["CTLD.lua ERROR: Can't find zone called %1"] = "CTLD.lua ERROR : Imposible encontrar la zona llamada %1"
-- STALE: ctld.i18n["es"]["CTLD.lua ERROR: Can't find zone or ship called %1"] = "CTLD.lua ERROR : Imposible encontrar la zona o el barco llamado %1"
-- STALE: ctld.i18n["es"]["CTLD.lua ERROR: Can't find crate with weight %1"] = "CTLD.lua ERROR : Imposible encontrar una caja con un peso de %1"

--- runtime messages
-- STALE: ctld.i18n["es"]["You are not close enough to friendly logistics to get a crate!"] = "¡No estás lo suficientemente cerca de la logística aliada para solicitar una caja!"
-- STALE: ctld.i18n["es"]["No more JTAC Crates Left!"] = "¡No hay más cajas JTAC disponibles!"
-- STALE: ctld.i18n["es"]["Sorry you must wait %1 seconds before you can get another crate"] = "Lo sentimos, debes esperar %1 segundos antes de poder solicitar otra caja"
-- STALE: ctld.i18n["es"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = "Una caja %1 pesando %2 kg ha sido preparada y está a tus %3 en punto "
-- STALE: ctld.i18n["es"]["%1 fast-ropped troops from %2 into combat"] = "%1 descolgo tropas con cuerdas de %2 al combate"
-- STALE: ctld.i18n["es"]["%1 dropped troops from %2 into combat"] = "%1 descargo tropas de %2 al combate"
-- STALE: ctld.i18n["es"]["%1 fast-ropped troops from %2 into %3"] = "%1 descolgo tropas con cuerdas de %2 a %3"
-- STALE: ctld.i18n["es"]["%1 dropped troops from %2 into %3"] = "%1 arrojó tropas de %2 a %3"
-- STALE: ctld.i18n["es"]["Too high or too fast to drop troops into combat! Hover below %1 feet or land."] = "¡Demasiado alto o rápido para lanzar tropas al combate! Manten estacionario por debajo de % 1 pies o aterriza."
-- STALE: ctld.i18n["es"]["%1 dropped vehicles from %2 into combat"] = "%1 descargo vehículos de %2 al combate"
-- STALE: ctld.i18n["es"]["%1 loaded troops into %2"] = "%1 cargó tropas en %2"
-- STALE: ctld.i18n["es"]["%1 loaded %2 vehicles into %3"] = "%1 cargó %2 vehículos en %3"
-- STALE: ctld.i18n["es"]["%1 delivered a FOB Crate"] = "%1 entregó una caja FOB"
-- STALE: ctld.i18n["es"]["Delivered FOB Crate 60m at 6'oclock to you"] = "Se le entregó la caja FOB de 60 m a sus 6 en punto"
-- STALE: ctld.i18n["es"]["FOB Crate dropped back to base"] = "Caja FOB devuelta a la base"
-- STALE: ctld.i18n["es"]["FOB Crate Loaded"] = "Caja FOB cargada"
-- STALE: ctld.i18n["es"]["%1 loaded a FOB Crate ready for delivery!"] = "%1 cargó una caja FOB lista para su entrega!"
-- STALE: ctld.i18n["es"]["There are no friendly logistic units nearby to load a FOB crate from!"] = "¡No hay unidades logísticas amigas cerca para cargar una caja FOB!"
-- STALE: ctld.i18n["es"]["This area has no more reinforcements available!"] = "¡Esta área no tiene más refuerzos disponibles!"
-- STALE: ctld.i18n["es"]["You are not in a pickup zone and no one is nearby to extract"] = "No estás en una zona de carga y/o no hay nadie cerca para extraccion"
-- STALE: ctld.i18n["es"]["You are not in a pickup zone"] = "No estás en una zona de carga"
-- STALE: ctld.i18n["es"]["No one to unload"] = "Nadie / Nada para descargar"
-- STALE: ctld.i18n["es"]["Dropped troops back to base"] = "Tropas descargados de vuelta a la base"
-- STALE: ctld.i18n["es"]["Dropped vehicles back to base"] = "Vehículos descargados de vuelta a la base"
-- STALE: ctld.i18n["es"]["You already have troops onboard."] = "Ya tienes tropas a bordo."
-- STALE: ctld.i18n["es"]["Count Infantries limit in the mission reached, you can't load more troops"] = "Se alcanzó el límite de infantería en la misión, no puedes cargar más tropas"
-- STALE: ctld.i18n["es"]["You already have vehicles onboard."] = "Ya tienes vehículos a bordo."
-- STALE: ctld.i18n["es"]["Sorry - The group of %1 is too large to fit. \n\nLimit is %2 for %3"] = "Lo sentimos, el grupo de %1 es demasiado grande. \n \nEl límite es %2 para %3"
-- STALE: ctld.i18n["es"]["%1 extracted troops in %2 from combat"] = "%1 tropas extraídas del combate en %2"
-- STALE: ctld.i18n["es"]["No extractable troops nearby!"] = "¡No hay tropas extraíbles cerca!"
-- STALE: ctld.i18n["es"]["%1 extracted vehicles in %2 from combat"] = "%1 vehículos extraídos del combate en %2"
-- STALE: ctld.i18n["es"]["No extractable vehicles nearby!"] = "¡No hay vehículos extraíbles cerca!"
-- STALE: ctld.i18n["es"]["%1 troops onboard (%2 kg)\n"] = "%1 tropas a bordo (%2 kg)\n"
-- STALE: ctld.i18n["es"]["%1 vehicles onboard (%2)\n"] = "%1 vehículos a bordo (%2)\n"
-- STALE: ctld.i18n["es"]["1 FOB Crate oboard (%1 kg)\n"] = "1 caja FOB a bordo (%1 kg)\n"
-- STALE: ctld.i18n["es"]["%1 crate onboard (%2 kg)\n"] = "%1 caja a bordo (%2 kg)\n"
-- STALE: ctld.i18n["es"]["Total weight of cargo : %1 kg\n"] = "Peso total de la carga: %1 kg\n"
-- STALE: ctld.i18n["es"]["No cargo."] = "Sin carga."
-- STALE: ctld.i18n["es"]["Hovering above %1 crate. \n\nHold hover for %2 seconds! \n\nIf the countdown stops you're too far away!"] = "En estacionario sobre la caja %1 \n\n¡Mantenlo durante %2 segundos! \n\n¡Si la cuenta atras se detiene, estás demasiado lejos!"
-- STALE: ctld.i18n["es"]["Loaded %1 crate!"] = "¡Caja %1 cargada!"
-- STALE: ctld.i18n["es"]["Too low to hook %1 crate.\n\nHold hover for %2 seconds"] = "Demasiado bajo para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
-- STALE: ctld.i18n["es"]["Too high to hook %1 crate.\n\nHold hover for %2 seconds"] = "Demasiado alto para enganchar la caja %1.\n\nMantén el estacionario durante %2 segundos"
-- STALE: ctld.i18n["es"]["You must land before you can load a crate!"] = "¡Debes aterrizar antes de poder cargar una caja!"
-- STALE: ctld.i18n["es"]["No Crates within 50m to load!"] = "¡No hay cajas para cargar en un radio de 50 m!"
-- STALE: ctld.i18n["es"]["Maximum number of crates are on board!"] = "¡Número máximo de cajas a bordo!"
-- STALE: ctld.i18n["es"]["%1\n%2 crate - kg %3 - %4 m - %5 o'clock"] = "%1\n%2 caja - kg %3 - %4 m - a tus %5 en punto"
-- STALE: ctld.i18n["es"]["FOB Crate - %1 m - %2 o'clock\n"] = "Caja FOB - %1 m - a tus %2 en punto\n"
-- STALE: ctld.i18n["es"]["No Nearby Crates"] = "No hay cajas cerca"
-- STALE: ctld.i18n["es"]["Nearby Crates:\n%1"] = "Cajas cercanas:\n%1"
-- STALE: ctld.i18n["es"]["Nearby FOB Crates (Not Slingloadable):\n%1"] = "Cajas FOB cercanas (no se pueden cargar con eslinga):\n%1"
-- STALE: ctld.i18n["es"]["FOB Positions:"] = "Posiciones FOB:"
-- STALE: ctld.i18n["es"]["%1\nFOB @ %2"] = "%1\nFOB @ %2"
-- STALE: ctld.i18n["es"]["Sorry, there are no active FOBs!"] = "¡Lo sentimos, no hay FOB activos!"
-- STALE: ctld.i18n["es"]["You can't unpack that here! Take it to where it's needed!"] = "¡No puedes desembalar eso aquí! ¡Llévalo a donde lo necesiten!"
-- STALE: ctld.i18n["es"]["Sorry you must move this crate before you unpack it!"] = "¡Lo siento, debes mover esta caja antes de desembalar!"
-- STALE: ctld.i18n["es"]["%1 successfully deployed %2 to the field"] = "%1 Desplego %2 con exito en el campo."
-- STALE: ctld.i18n["es"]["No friendly crates close enough to unpack, or crate too close to aircraft."] = "No hay cajas amigas lo suficientemente cerca por desembalar, o la caja está demasiado cerca de un avión"
-- STALE: ctld.i18n["es"]["Finished building FOB! Crates and Troops can now be picked up."] = "¡Construcción FOB completada! Ahora se pueden recoger cajas y tropas"
-- STALE: ctld.i18n["es"]["Finished building FOB! Crates can now be picked up."] = "¡Construcción FOB completada! Ahora se pueden recoger cajas."
-- STALE: ctld.i18n["es"]["%1 started building FOB using %2 FOB crates, it will be finished in %3 seconds.\nPosition marked with smoke."] = "%1 comenzó a construir FOB usando %2 cajas FOB , estará terminado en %3 segundos.\nPosición marcada con bomba de humo."
-- STALE: ctld.i18n["es"]["Cannot build FOB!\n\nIt requires %1 Large FOB crates ( 3 small FOB crates equal 1 large FOB Crate) and there are the equivalent of %2 large FOB crates nearby\n\nOr the crates are not within 750m of each other"] = "¡No se puede construir el FOB!\n\nSe requiere %1 cajas FOB grandes (3 cajas FOB pequeñas equivalente a 1 caja FOB grande) y hay el equivalente a %2 cajas FOB grandes cerca\n\nO las cajas no están a menos de 750 m una de otra"
-- STALE: ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate or land and use F10 Crate Commands."] = "Actualmente no estás transportando ninguna caja.\n\nPara cargar una caja, realiza un estacionario sobre la caja durante %1 segundos o aterrice y use los comandos de caja F10."
-- STALE: ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, hover for %1 seconds above the crate."] = "Actualmente no estás transportando ninguna caja. \n\nPara cargar una caja, realiza un estacionario sobre la caja durante %1 segundos."
-- STALE: ctld.i18n["es"]["You are not currently transporting any crates. \n\nTo Pickup a crate, land and use F10 Crate Commands to load one."] = "Actualmente no estás transportando ninguna caja. \n\nPara cargar una caja, aterriza y usa los controles de la caja F10."
-- STALE: ctld.i18n["es"]["%1 crate has been safely unhooked and is at your %2 o'clock"] = "%1 caja desenganchada de forma segura y está en tus %2 en punto"
-- STALE: ctld.i18n["es"]["%1 crate has been safely dropped below you"] = "%1 caja ha soltado de forma segura debajo de ti"
-- STALE: ctld.i18n["es"]["You were too high! The crate has been destroyed"] = "¡Estabas demasiado alto! La caja ha sido destruida"
--- Radio Beacon messages
ctld.i18n["es"]["No Radio Beacons within 500m."] = "No hay radiobalizas a menos de 500 m."
ctld.i18n["es"]["Navigation beacon deployed - %1"] = "Baliza de navegación desplegada - %1"
ctld.i18n["es"]["Radio beacon removed - %1"] = "Radiobaliza eliminada - %1"
ctld.i18n["es"]["Radio Beacons:"] = "Balizas de radio:"
ctld.i18n["es"]["No Active Radio Beacons"] = "No hay radiobalizas activas"
ctld.i18n["es"]["Beacon layer enabled. %1 beacon(s)."] = "Capa de balizas activada. %1 baliza(s)."
ctld.i18n["es"]["Beacon layer disabled."] = "Capa de balizas desactivada."
ctld.i18n["es"]["CTLD"] = "CTLD"
ctld.i18n["es"]["Radio Beacons"] = "Balizas de radio"
ctld.i18n["es"]["Drop Beacon"] = "Desplegar baliza"
ctld.i18n["es"]["Remove Closest Beacon"] = "Quitar la baliza más cercana"
ctld.i18n["es"]["List Beacons"] = "Listar balizas"
-- STALE: ctld.i18n["es"]["Radio Beacons:\n%1"] = "Balizas de radio:\n%1"
-- STALE: ctld.i18n["es"]["%1 deployed a Radio Beacon.\n\n%2"] = "%1 Despliega una radiobaliza.\n\n%2"
-- STALE: ctld.i18n["es"]["You need to land before you can deploy a Radio Beacon!"] = "¡Debes aterrizar antes de poder desplegar una radiobaliza!"
-- STALE: ctld.i18n["es"]["%1 removed a Radio Beacon.\n\n%2"] = "%1 eliminó una radiobaliza.\n\n%2"
-- STALE: ctld.i18n["es"]["You need to land before remove a Radio Beacon"] = "Es necesario aterrizar antes de eliminar una radiobaliza"
-- STALE: ctld.i18n["es"]["%1 successfully rearmed a full %2 in the field"] = "%1 rearmó con exito un %2 completo en el campo"
-- STALE: ctld.i18n["es"]["Missing %1\n"] = "Faltan: %1\n"
-- STALE: ctld.i18n["es"]["Out of parts for AA Systems. Current limit is %1\n"] = "Sin piezas para sistemas AA. El límite actual es %1\n"
-- STALE: ctld.i18n["es"]["Cannot build %1\n%2\n\nOr the crates are not close enough together"] = "Imposible construir %1\n%2\n\nO las cajas no están lo suficientemente cerca unas de otras."
-- STALE: ctld.i18n["es"]["%1 successfully deployed a full %2 in the field. \n\nAA Active System limit is: %3\nActive: %4"] = "%1 Despliegue con exito un % 2 completo en el campo \n\nEl límite AA del sistema activo es: %3\nActivo: %4"
-- STALE: ctld.i18n["es"]["%1 successfully repaired a full %2 in the field."] = "%1 reparó con exito un %2 completo en el campo."
-- STALE: ctld.i18n["es"]["Cannot repair %1. No damaged %2 within 300m"] = "Imposible reparar %1. No hay daños en %2 en 300 m al rededor"
-- STALE: ctld.i18n["es"]["%1 successfully deployed %2 to the field using %3 crates."] = "%1 Despliegue con exito de %2 en el campo usando %3 cajas."
-- STALE: ctld.i18n["es"]["Cannot build %1!\n\nIt requires %2 crates and there are %3 \n\nOr the crates are not within 300m of each other"] = "Imposible construir %1 !\n\nNecesita %2 cajas y hay %3 \n\nO las cajas están a no menos de 300 m una de otra"
-- STALE: ctld.i18n["es"]["%1 dropped %2 smoke."] = "%1 lanzo humo %2."

--- JTAC messages
-- STALE: ctld.i18n["es"]["JTAC Group %1 KIA!"] = "¡Grupo JTAC %1 KIA!"
-- STALE: ctld.i18n["es"]["%1, selected target reacquired, %2"] = "%1, objetivo seleccionado readquirido, %2"
-- STALE: ctld.i18n["es"][". CODE: %1. POSITION: %2"] = ". CÓDIGO: %1. POSICIÓN: %2"
-- STALE: ctld.i18n["es"]["new target, "] = "nuevo objetivo, "
-- STALE: ctld.i18n["es"]["standing by on %1"] = "en espera en %1"
-- STALE: ctld.i18n["es"]["lasing %1"] = "láser %1"
-- STALE: ctld.i18n["es"][", temporarily %1"] = ", temporalmente %1"
-- STALE: ctld.i18n["es"]["target lost"] = "objetivo perdido"
-- STALE: ctld.i18n["es"]["target destroyed"] = "objetivo destruido"
-- STALE: ctld.i18n["es"][", selected %1"] = ", %1 seleccionado"
-- STALE: ctld.i18n["es"]["%1 %2 target lost."] = "%1 %2 objetivo perdido."
-- STALE: ctld.i18n["es"]["%1 %2 target destroyed."] = "%1 %2 objetivo destruido."
-- STALE: ctld.i18n["es"]["JTAC STATUS: \n\n"] = "ESTADO JTAC: \n\n"
-- STALE: ctld.i18n["es"][", available on %1 %2,"] = ", disponible en %1 %2,"
-- STALE: ctld.i18n["es"]["UNKNOWN"] = "DESCONOCIDO"
-- STALE: ctld.i18n["es"][" targeting "] = " apuntando "
-- STALE: ctld.i18n["es"][" targeting selected unit "] = " apuntando a la unidad indicada"
-- STALE: ctld.i18n["es"][" attempting to find selected unit, temporarily targeting "] = " intentando encontrar la unidad indicada, laser activo "
-- STALE: ctld.i18n["es"]["(Laser OFF) "] = "(Láser INACTIVO) "
-- STALE: ctld.i18n["es"]["Visual On: "] = "Visual activado: "
-- STALE: ctld.i18n["es"][" searching for targets %1\n"] = " buscando objetivos %1\n"
-- STALE: ctld.i18n["es"]["No Active JTACs"] = "Sin JTAC activos"
-- STALE: ctld.i18n["es"][", targeting selected unit, %1"] = ", apuntando a la unidad indicada, %1"
-- STALE: ctld.i18n["es"][", target selection reset."] = ", reinicio de selección de objetivo."
-- STALE: ctld.i18n["es"]["%1, laser and smokes enabled"] = "%1, láser y humo habilitados"
-- STALE: ctld.i18n["es"]["%1, laser and smokes disabled"] = "%1, láser y humo deshabilitados"
-- STALE: ctld.i18n["es"]["%1, wind and target speed laser spot compensations enabled"] = "%1, compensaciones habilitadas del viento y de velocidad del objetivo para el punto láser"
-- STALE: ctld.i18n["es"]["%1, wind and target speed laser spot compensations disabled"] = "%1, compensaciones deshabilitadas del viento y de velocidad del objetivo para el punto láser"
-- STALE: ctld.i18n["es"]["%1, WHITE smoke deployed near target"] = "%1, humo BLANCO desplegado cerca del objetivo"

--- F10 menu messages
-- STALE: ctld.i18n["es"]["Actions"] = "Acciones"
-- STALE: ctld.i18n["es"]["Troop Transport"] = "Transporte de tropas"
-- STALE: ctld.i18n["es"]["Unload / Extract Troops"] = "Descargar/Extraer tropas"
-- STALE: ctld.i18n["es"]["Next page"] = "Página siguiente"
-- STALE: ctld.i18n["es"]["Load "] = "Cargar "
-- STALE: ctld.i18n["es"]["Vehicle / FOB Transport"] = "Transporte de Vehículo / FOB"
-- STALE: ctld.i18n["es"]["Crates: Vehicle / FOB / Drone"] = "Cajas de Vehículo / FOB / Dron"
-- STALE: ctld.i18n["es"]["Unload Vehicles"] = "Descargar vehículos"
-- STALE: ctld.i18n["es"]["Load / Extract Vehicles"] = "Cargar/Extraer vehículos"
-- STALE: ctld.i18n["es"]["Load / Unload FOB Crate"] = "Cargar/Descargar caja FOB"
-- STALE: ctld.i18n["es"]["Pack Vehicles"] = "Envolver vehículos"
-- STALE: ctld.i18n["es"]["CTLD Commands"] = "Comandos CTLD"
-- STALE: ctld.i18n["es"]["CTLD"] = "CTLD"
-- STALE: ctld.i18n["es"]["Check Cargo"] = "Verificar carga"
-- STALE: ctld.i18n["es"]["Load Nearby Crate(s)"] = "Cargar caja(s) cercana(s)"
-- STALE: ctld.i18n["es"]["Unpack Any Crate"] = "Desempaquetar cajas"
-- STALE: ctld.i18n["es"]["Drop Crate(s)"] = "Soltar caja(s)"
-- STALE: ctld.i18n["es"]["List Nearby Crates"] = "Enumerar cajas cercanas"
-- STALE: ctld.i18n["es"]["List FOBs"] = "Enumerar FOBs"
-- STALE: ctld.i18n["es"]["List Beacons"] = "Enumerar balizas"
-- STALE: ctld.i18n["es"]["List Radio Beacons"] = "Enumerar radiobalizas"
-- STALE: ctld.i18n["es"]["Smoke Markers"] = "Marcadores de humo"
-- STALE: ctld.i18n["es"]["Drop Red Smoke"] = "Lanzar humo rojo"
-- STALE: ctld.i18n["es"]["Drop Blue Smoke"] = "Lanzar humo azul"
-- STALE: ctld.i18n["es"]["Drop Orange Smoke"] = "Lanzar humo naranja"
-- STALE: ctld.i18n["es"]["Drop Green Smoke"] = "Lanzar humo verde"
-- STALE: ctld.i18n["es"]["JTAC Status"] = "Estado de JTAC"
-- STALE: ctld.i18n["es"]["DISABLE "] = "DESHABILITAR "
-- STALE: ctld.i18n["es"]["ENABLE "] = "HABILITAR "
-- STALE: ctld.i18n["es"]["REQUEST "] = "SOLICITUD "
-- STALE: ctld.i18n["es"]["Reset TGT Selection"] = "Restablecer selección de objetivo"

--- F10 RECON menus
ctld.i18n["es"]["activate"] = "activar"
ctld.i18n["es"]["deactivate"] = "desactivar"
ctld.i18n["es"]["RECON"] = "RECONOCIMIENTO"
ctld.i18n["es"]["RECON [Start]"] = "RECON [Iniciar]"
ctld.i18n["es"]["RECON [Stop]"] = "RECON [Detener]"
ctld.i18n["es"]["Scan Area"] = "Escanear zona"
ctld.i18n["es"]["Hide All Targets"] = "Ocultar todos los objetivos"
ctld.i18n["es"]["Toggle %s"] = "Alternar %s"
ctld.i18n["es"]["Auto-Refresh: [OFF]"] = "Actualización auto: [OFF]"
ctld.i18n["es"]["Auto-Refresh: [ON]"] = "Actualización auto: [ON]"
ctld.i18n["es"]["Altitude too low for recon scan (min %1 m)"] = "Altitud demasiado baja para el escaneo de reconocimiento (mín. %1 m)"
ctld.i18n["es"]["No recon layers enabled. Activate layers first."] = "Ninguna capa de reconocimiento activada. Activa las capas primero."
ctld.i18n["es"]["Recon stopped. %1 targets hidden."] = "Reconocimiento detenido. %1 objetivo(s) ocultado(s)."
ctld.i18n["es"]["No active recon scan to hide."] = "No hay escaneo de reconocimiento activo para ocultar."
ctld.i18n["es"]["No active recon scan. Use 'Scan Area' first."] = "No hay escaneo activo. Usa 'Escanear zona' primero."
ctld.i18n["es"]["Auto-refresh enabled. Targets update every %1 s."] = "Actualización automática activada. Los objetivos se actualizan cada %1 s."
ctld.i18n["es"]["Auto-refresh disabled. Current targets frozen on map."] = "Actualización automática desactivada. Los objetivos están congelados en el mapa."
ctld.i18n["es"]["Recon layer '%1': %2"] = "Capa de reconocimiento '%1': %2"
-- STALE: ctld.i18n["es"]["Layers"] = "Capas"
-- STALE: ctld.i18n["es"]["Show targets in LOS (refresh)"] = "Marcar objetivos visibles en el mapa F10"
-- STALE: ctld.i18n["es"]["Hide targets in LOS"] = "Borrar marcas del mapa F10"
-- STALE: ctld.i18n["es"]["Scan targets in LOS"] = "Escanear objetivos en LOS"
-- STALE: ctld.i18n["es"]["START autoRefresh"] = "Iniciar actualización auto"
-- STALE: ctld.i18n["es"]["STOP autoRefresh"] = "Detener actualización auto"
-- STALE: ctld.i18n["es"]["START autoRefresh targets in LOS"] = "Iniciar el seguimiento automático de objetivos"
-- STALE: ctld.i18n["es"]["STOP autoRefresh targets in LOS"] = "Detener el seguimiento automático de objetivos"

--- Load Crate submenu
ctld.i18n["es"]["Load Crate"] = "Cargar caja"
ctld.i18n["es"]["Land to load crates"] = "Aterriza para cargar una caja"
ctld.i18n["es"]["No crates within 50m"] = "No hay cajas en 50 m"
ctld.i18n["es"]["You must land before you can load a crate!"] = "¡Debes aterrizar antes de poder cargar una caja!"
ctld.i18n["es"]["Maximum number of crates are on board!"] = "¡Número máximo de cajas a bordo!"
ctld.i18n["es"]["No crates within 50m to load!"] = "¡No hay cajas para cargar en un radio de 50 m!"
ctld.i18n["es"]["Loaded %1 crate!"] = "¡Caja %1 cargada!"

--- Drop Crate(s)
ctld.i18n["es"]["No crates on board to drop."] = "No hay cajas a bordo para soltar."
ctld.i18n["es"]["You must land before dropping crates!"] = "¡Debes aterrizar antes de soltar las cajas!"
ctld.i18n["es"]["%1 crate(s) dropped at your %2 o'clock"] = "%1 caja(s) soltada(s) a tu %2 en punto"

--- Unpack Crate submenu
ctld.i18n["es"]["Unpack Crate"] = "Desempaquetar cajas"
ctld.i18n["es"]["Land to unpack crates"] = "Aterriza para desempaquetar"
ctld.i18n["es"]["No complete crate sets nearby"] = "No hay lotes de cajas completos cercanos"
ctld.i18n["es"]["Build FOB"] = "Construir FOB"
ctld.i18n["es"]["You must land before unpacking crates!"] = "¡Debes aterrizar antes de desempaquetar las cajas!"
ctld.i18n["es"]["Not enough crates nearby to unpack!"] = "¡No hay suficientes cajas cercanas para desempaquetar!"
ctld.i18n["es"]["%1 unpacked successfully!"] = "¡%1 desempaquetado con éxito!"

--- Pack Vehicle submenu
ctld.i18n["es"]["Land to pack vehicles"] = "Aterriza para empaquetar vehículos"
ctld.i18n["es"]["No packable vehicles nearby"] = "No hay vehículos empaquetables cercanos"
ctld.i18n["es"]["Vehicle no longer exists."] = "El vehículo ya no existe."
ctld.i18n["es"]["Cannot pack this vehicle type."] = "No se puede empaquetar este tipo de vehículo."

--- Load / Unload Vehicle submenu (GAP-1)
ctld.i18n["es"]["Land to load vehicles"] = "Aterriza para cargar vehículos"
ctld.i18n["es"]["No vehicles nearby"] = "No hay vehículos cercanos"
ctld.i18n["es"]["Vehicle no longer available."] = "El vehículo ya no está disponible."
ctld.i18n["es"]["Land to unload vehicles"] = "Aterriza para descargar vehículos"
ctld.i18n["es"]["No vehicle loaded."] = "No hay ningún vehículo cargado."
ctld.i18n["es"]["Vehicle no longer loaded."] = "El vehículo ya no está cargado."
ctld.i18n["es"]["Cannot load more vehicles (max: %d)."] = "No se pueden cargar más vehículos (máx: %d)."

--- List Nearby Crates
ctld.i18n["es"]["List Nearby Crates"] = "Enumerar cajas cercanas"
ctld.i18n["es"]["No crates within 300m."] = "No hay cajas en un radio de 300m."
ctld.i18n["es"]["Crates within 300m:"] = "Cajas en un radio de 300m:"
ctld.i18n["es"]["  %1: %2/%3 — READY"] = "  %1: %2/%3 — LISTA"
ctld.i18n["es"]["  %1: %2/%3 — incomplete"] = "  %1: %2/%3 — incompleta"

--- Check Cargo summary
ctld.i18n["es"]["No cargo on board."] = "Sin carga a bordo."
ctld.i18n["es"]["%1: %2 crate(s) onboard (%3 kg)"] = "%1: %2 caja(s) a bordo (%3 kg)"
ctld.i18n["es"]["%1 troop(s) onboard (%2 kg)"] = "%1 soldado(s) a bordo (%2 kg)"
ctld.i18n["es"]["%1: %2 vehicle(s) onboard"] = "%1: %2 vehículo(s) a bordo"
ctld.i18n["es"]["Total cargo weight: %1 kg"] = "Peso total de la carga: %1 kg"

--- Request JTAC Equipment menu
ctld.i18n["es"]["Request JTAC Equipment"] = "Solicitar equipo JTAC"
ctld.i18n["es"]["You must be landed to request JTAC equipment."] = "Debes estar posado para solicitar equipo JTAC."
ctld.i18n["es"]["You are not close enough to friendly logistics."] = "No estás suficientemente cerca de la logística aliada."
ctld.i18n["es"]["%s is ready for pickup."] = "%s listo para embarque."

--- Request Equipment spawn messages
ctld.i18n["es"]["Land near logistics to request equipment"] = "Aterriza cerca de la logística para solicitar equipo"
ctld.i18n["es"]["No logistics in range"] = "Sin logística en rango"
ctld.i18n["es"]["All crates"] = "Todas las cajas"
ctld.i18n["es"]["You must be landed to request a crate."] = "Debes estar posado para solicitar una caja."
ctld.i18n["es"]["You are not close enough to friendly logistics to get a crate!"] = "¡No estás lo suficientemente cerca de la logística aliada para solicitar una caja!"
ctld.i18n["es"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = "Una caja %1 pesando %2 kg ha sido preparada y está a tus %3 en punto "
ctld.i18n["es"]["%1 crates have been brought out at your %2 o'clock"] = "%1 cajas han sido preparadas a tu %2 en punto"

--- FOBs List menu
ctld.i18n["es"]["FOBs List"] = "Lista de FOBs"
ctld.i18n["es"]["List active FOBs"] = "Listar FOBs activos"
ctld.i18n["es"]["No active FOBs."] = "No hay FOBs activos."
ctld.i18n["es"]["FOB Positions:"] = "Posiciones FOB:"

--- Keys added by generate_i18n_dicts.ps1 on 2026-03-21
ctld.i18n["es"]["→ Next Page"] = "→ Página siguiente"

--- Feature H — Smoke auto-resume toggle
ctld.i18n["es"]["Smoke Auto-Resume [activate]"]   = "Humo auto-reanudación [activar]"
ctld.i18n["es"]["Smoke Auto-Resume [deactivate]"] = "Humo auto-reanudación [desactivar]"
ctld.i18n["es"]["Smoke auto-resume ON (%1s interval)"]  = "Humo auto-reanudación ACTIVO (intervalo %1s)"
ctld.i18n["es"]["Smoke auto-resume OFF"]                = "Humo auto-reanudación DESACTIVADO"

-- End : CTLD_i18n_es.lua
-- ====================================================================================================
-- Start : CTLD_i18n_ko.lua
--[[
    CTLD — Korean dictionary
    Translation version: 1.9

    Translator: rising_star (original), Claude AI (RECON + new entries 2026-04-28)
    Note: weapon system proper nouns (BTR-D, BRDM-2, MLRS, etc.) are kept in their original form.
    To update: run tools/merger_V2/generate_i18n_dicts.ps1 after any ctld.tr() change.
]]
if not ctld then ctld = {} end
if not ctld.i18n then ctld.i18n = {} end

ctld.i18n["ko"] = {}
ctld.i18n["ko"].translation_version = "1.9"

--- groups names
ctld.i18n["ko"]["Standard Group"] = "표준 그룹"
ctld.i18n["ko"]["Anti Air"] = "방공"
ctld.i18n["ko"]["Anti Tank"] = "대기갑"
ctld.i18n["ko"]["Mortar Squad"] = "박격포 분대"
ctld.i18n["ko"]["JTAC Group"] = "JTAC 그룹"
ctld.i18n["ko"]["Single JTAC"] = "싱글 JTAC"
ctld.i18n["ko"]["2x - Standard Groups"] = "표준 그룹 2x"
ctld.i18n["ko"]["2x - Anti Air"] = "방공 2x"
ctld.i18n["ko"]["2x - Anti Tank"] = "대기갑 2x"
ctld.i18n["ko"]["2x - Standard Groups + 2x Mortar"] = "표준 그룹 2x + 박격포 분대 2x"
ctld.i18n["ko"]["3x - Standard Groups"] = "표준 그룹 3x"
ctld.i18n["ko"]["3x - Anti Air"] = "방공 3x"
ctld.i18n["ko"]["3x - Anti Tank"] = "대기갑 3x"
ctld.i18n["ko"]["3x - Mortar Squad"] = "박격포 분대 3x"
ctld.i18n["ko"]["5x - Mortar Squad"] = "박격포 분대 5x"
ctld.i18n["ko"]["Mortar Squad Red"] = "레드 박격포 분대"

--- crates names
ctld.i18n["ko"]["Humvee - MG"] = "험비 - MG"
ctld.i18n["ko"]["Humvee - TOW"] = "험비 - TOW"
ctld.i18n["ko"]["Light Tank - MRAP"] = "경전차 - MRAP"
ctld.i18n["ko"]["Med Tank - LAV-25"] = "중형 전차 - LAV-25"
ctld.i18n["ko"]["Heavy Tank - Abrams"] = "M1 에이브럼스"
ctld.i18n["ko"]["BTR-D"] = "BTR-D"
ctld.i18n["ko"]["BRDM-2"] = "BRDM-2"
ctld.i18n["ko"]["Hummer - JTAC"] = "험머 - JTAC"
ctld.i18n["ko"]["M-818 Ammo Truck"] = "M-818 탄약 차량"
ctld.i18n["ko"]["M-978 Tanker"] = "M-978 연료 차량"
ctld.i18n["ko"]["SKP-11 - JTAC"] = "SKP-11 - JTAC"
ctld.i18n["ko"]["Ural-375 Ammo Truck"] = "Ural-375 탄약 차량"
ctld.i18n["ko"]["KAMAZ Ammo Truck"] = "KAMAZ 탄약 차량"
ctld.i18n["ko"]["KAMAZ Ammo Truck - All crates"] = "KAMAZ 탄약 차량 - 전체 화물"
ctld.i18n["ko"]["EWR Radar"] = "조기경보 레이더"
ctld.i18n["ko"]["FOB Crate"] = "FOB 화물"
ctld.i18n["ko"]["You must be on the ground to deploy a FOB."] = "FOB를 배치하려면 착륙해야 합니다."
ctld.i18n["ko"]["FOB needs %1 crate(s) within 750 m - only %2 found."] = "FOB에는 750m 이내에 %1개의 화물이 필요합니다 - %2개만 발견되었습니다."
ctld.i18n["ko"]["You can't deploy a FOB here! Take it to where it's needed."] = "여기에 FOB를 배치할 수 없습니다! 필요한 곳으로 이동하세요."
ctld.i18n["ko"]["FOB deployment blocked: move at least %1 m away from existing logistic zone."] = "FOB 배치 차단: 기존 군수 구역에서 최소 %1m 이상 이동하세요."
ctld.i18n["ko"]["%1 started building a FOB (%2 crate(s)). Ready in %3 seconds."] = "%1이(가) FOB 건설을 시작했습니다 (%2개 화물). %3초 후 완료."
ctld.i18n["ko"]["FOB established by %1 - logistics hub now active."] = "%1이(가) FOB를 설립했습니다. 군수 거점 활성화."
ctld.i18n["ko"]["MQ-9 Repear - JTAC"] = "MQ-9 리퍼 - JTAC"
ctld.i18n["ko"]["RQ-1A Predator - JTAC"] = "RQ-1A 프레데터 - JTAC"
ctld.i18n["ko"]["MLRS"] = "MLRS"
ctld.i18n["ko"]["SpGH DANA"] = "DANA 자주곡사포"
ctld.i18n["ko"]["T155 Firtina"] = "T-155 프르트나"
ctld.i18n["ko"]["Howitzer"] = "곡사포"
ctld.i18n["ko"]["SPH 2S19 Msta"] = "2S19 므스타 자주곡사포"
ctld.i18n["ko"]["M1097 Avenger"] = "M1097 어벤저"
ctld.i18n["ko"]["M48 Chaparral"] = "M48 채퍼럴"
ctld.i18n["ko"]["Roland ADS"] = "롤랑 ADS"
ctld.i18n["ko"]["Gepard AAA"] = "게파트 자주대공포"
ctld.i18n["ko"]["LPWS C-RAM"] = "LPWS C-RAM"
ctld.i18n["ko"]["9K33 Osa"] = "9K33 오사"
ctld.i18n["ko"]["9P31 Strela-1"] = "9P31 스트렐라-1"
ctld.i18n["ko"]["9K35M Strela-10"] = "9K35M 스트렐라-10"
ctld.i18n["ko"]["9K331 Tor"] = "9K331 토르"
ctld.i18n["ko"]["2K22 Tunguska"] = "2K22 퉁구스카"
ctld.i18n["ko"]["HAWK Launcher"] = "호크 포대"
ctld.i18n["ko"]["HAWK Search Radar"] = "호크 탐지 레이더"
ctld.i18n["ko"]["HAWK Track Radar"] = "호크 추적 레이더"
ctld.i18n["ko"]["HAWK PCP"] = "호크 PCP"
ctld.i18n["ko"]["HAWK CWAR"] = "호크 CWAR"
ctld.i18n["ko"]["HAWK Repair"] = "호크 수리킷"
ctld.i18n["ko"]["NASAMS Launcher 120C"] = "NASAMS 포대 120C"
ctld.i18n["ko"]["NASAMS Search/Track Radar"] = "NASAMS 레이더"
ctld.i18n["ko"]["NASAMS Command Post"] = "NASAMS 관제소"
ctld.i18n["ko"]["NASAMS Repair"] = "NASAMS 수리킷"
ctld.i18n["ko"]["KUB Launcher"] = "SA-6 포대"
ctld.i18n["ko"]["KUB Radar"] = "SA-6 레이더"
ctld.i18n["ko"]["KUB Repair"] = "SA-6 수리킷"
ctld.i18n["ko"]["BUK Launcher"] = "SA-11 포대"
ctld.i18n["ko"]["BUK Search Radar"] = "SA-11 탐지 레이더"
ctld.i18n["ko"]["BUK CC Radar"] = "SA-11 CC"
ctld.i18n["ko"]["BUK Repair"] = "SA-11 수리킷"
ctld.i18n["ko"]["Patriot Launcher"] = "패트리어트 포대"
ctld.i18n["ko"]["Patriot Radar"] = "패트리어트 탐지 레이더"
ctld.i18n["ko"]["Patriot ECS"] = "패트리어트 ECS"
ctld.i18n["ko"]["Patriot ICC"] = "패트리어트 ICC"
ctld.i18n["ko"]["Patriot EPP"] = "패트리어트 EPP"
ctld.i18n["ko"]["Patriot AMG (optional)"] = "패트리어트 AMG (선택 사항)"
ctld.i18n["ko"]["Patriot Repair"] = "패트리어트 수리킷"
ctld.i18n["ko"]["S-300 Grumble TEL C"] = "S-300 C 포대"
ctld.i18n["ko"]["S-300 Grumble Flap Lid-A TR"] = "S-300 5N63 추적 레이더"
ctld.i18n["ko"]["S-300 Grumble Clam Shell SR"] = "S-300 Clam Shell 탐지 레이더"
ctld.i18n["ko"]["S-300 Grumble Big Bird SR"] = "S-300 Big Bird 탐지 레이더"
ctld.i18n["ko"]["S-300 Grumble C2"] = "S-300 관제소"
ctld.i18n["ko"]["S-300 Repair"] = "S-300 수리킷"

--- Radio Beacon messages
ctld.i18n["ko"]["No Radio Beacons within 500m."] = "500m 내에 라디오 비콘 없음."
ctld.i18n["ko"]["Navigation beacon deployed - %1"] = "항법 비콘 배치됨 - %1"
ctld.i18n["ko"]["Radio beacon removed - %1"] = "라디오 비콘 제거됨 - %1"
ctld.i18n["ko"]["Radio Beacons:"] = "라디오 비콘:"
ctld.i18n["ko"]["No Active Radio Beacons"] = "활성화된 라디오 비콘 없음."
ctld.i18n["ko"]["Beacon layer enabled. %1 beacon(s)."] = "비콘 레이어 활성화. %1 개."
ctld.i18n["ko"]["Beacon layer disabled."] = "비콘 레이어 비활성화."
ctld.i18n["ko"]["CTLD"] = "CTLD"
ctld.i18n["ko"]["Radio Beacons"] = "라디오 비콘"
ctld.i18n["ko"]["Drop Beacon"] = "비콘 투하"
ctld.i18n["ko"]["Remove Closest Beacon"] = "가까운 비콘 제거"
ctld.i18n["ko"]["List Beacons"] = "비콘 목록"

--- F10 RECON menus
ctld.i18n["ko"]["activate"] = "활성화"
ctld.i18n["ko"]["deactivate"] = "비활성화"
ctld.i18n["ko"]["RECON"] = "정찰"
ctld.i18n["ko"]["RECON [Start]"] = "정찰 [시작]"
ctld.i18n["ko"]["RECON [Stop]"] = "정찰 [정지]"
ctld.i18n["ko"]["Scan Area"] = "구역 스캔"
ctld.i18n["ko"]["Hide All Targets"] = "모든 목표 숨기기"
ctld.i18n["ko"]["Toggle %s"] = "%s 전환"
ctld.i18n["ko"]["Auto-Refresh: [OFF]"] = "자동 갱신: [꺼짐]"
ctld.i18n["ko"]["Auto-Refresh: [ON]"] = "자동 갱신: [켜짐]"
ctld.i18n["ko"]["Altitude too low for recon scan (min %1 m)"] = "정찰 스캔 고도 부족 (최소 %1 m)"
ctld.i18n["ko"]["No recon layers enabled. Activate layers first."] = "활성화된 정찰 레이어 없음. 먼저 레이어를 활성화하세요."
ctld.i18n["ko"]["Recon stopped. %1 targets hidden."] = "정찰 중지. %1 목표 숨김."
ctld.i18n["ko"]["No active recon scan to hide."] = "숨길 활성 정찰 스캔 없음."
ctld.i18n["ko"]["No active recon scan. Use 'Scan Area' first."] = "활성 정찰 스캔 없음."
ctld.i18n["ko"]["Auto-refresh enabled. Targets update every %1 s."] = "자동 갱신 활성화. %1 초마다 목표 업데이트."
ctld.i18n["ko"]["Auto-refresh disabled. Current targets frozen on map."] = "자동 갱신 비활성화. 현재 목표 지도에 고정."
ctld.i18n["ko"]["Recon layer '%1': %2"] = "정찰 레이어 '%1': %2"
-- STALE: ctld.i18n["ko"]["Layers"] = "레이어"
-- STALE: ctld.i18n["ko"]["Show targets in LOS (refresh)"] = "시야 내 목표 표시 (갱신)"
-- STALE: ctld.i18n["ko"]["Hide targets in LOS"] = "시야 내 목표 숨기기"
-- STALE: ctld.i18n["ko"]["Scan targets in LOS"] = "시야 내 목표 스캔"
-- STALE: ctld.i18n["ko"]["START autoRefresh"] = "자동 갱신 시작"
-- STALE: ctld.i18n["ko"]["STOP autoRefresh"] = "자동 갱신 정지"
-- STALE: ctld.i18n["ko"]["START autoRefresh targets in LOS"] = "시야 내 목표 자동 갱신 시작"
-- STALE: ctld.i18n["ko"]["STOP autoRefresh targets in LOS"] = "시야 내 목표 자동 갱신 정지"

--- FOBs List menu
ctld.i18n["ko"]["FOBs List"] = "FOB 목록"
ctld.i18n["ko"]["List active FOBs"] = "활성 FOB 나열"
ctld.i18n["ko"]["No active FOBs."] = "활성 FOB 없음."
ctld.i18n["ko"]["FOB Positions:"] = "FOB 위치:"

--- "All crates" shortcuts
ctld.i18n["ko"]["→ Next Page"] = "→ 다음 페이지"
ctld.i18n["ko"]["2K22 Tunguska - All crates"] = "2K22 퉁구스카 - 전체 화물"
ctld.i18n["ko"]["9K33 Osa - All crates"] = "9K33 오사 - 전체 화물"
ctld.i18n["ko"]["9K331 Tor - All crates"] = "9K331 토르 - 전체 화물"
ctld.i18n["ko"]["9K35M Strela-10 - All crates"] = "9K35M 스트렐라-10 - 전체 화물"
ctld.i18n["ko"]["9P31 Strela-1 - All crates"] = "9P31 스트렐라-1 - 전체 화물"
ctld.i18n["ko"]["BUK - All crates"] = "SA-11 - 전체 화물"
ctld.i18n["ko"]["EWR Radar - All crates"] = "조기경보 레이더 - 전체 화물"
ctld.i18n["ko"]["Gepard AAA - All crates"] = "게파트 자주대공포 - 전체 화물"
ctld.i18n["ko"]["HAWK - All crates"] = "호크 - 전체 화물"
ctld.i18n["ko"]["Heavy Tank - Abrams - All crates"] = "M1 에이브럼스 - 전체 화물"
ctld.i18n["ko"]["Howitzer - All crates"] = "곡사포 - 전체 화물"
ctld.i18n["ko"]["Hummer - JTAC - All crates"] = "험머 - JTAC - 전체 화물"
ctld.i18n["ko"]["Humvee - TOW - All crates"] = "험비 - TOW - 전체 화물"
ctld.i18n["ko"]["KUB - All crates"] = "SA-6 - 전체 화물"
ctld.i18n["ko"]["Light Tank - MRAP - All crates"] = "경전차 - MRAP - 전체 화물"
ctld.i18n["ko"]["LPWS C-RAM - All crates"] = "LPWS C-RAM - 전체 화물"
ctld.i18n["ko"]["M1097 Avenger - All crates"] = "M1097 어벤저 - 전체 화물"
ctld.i18n["ko"]["M48 Chaparral - All crates"] = "M48 채퍼럴 - 전체 화물"
ctld.i18n["ko"]["M-818 Ammo Truck - All crates"] = "M-818 탄약 차량 - 전체 화물"
ctld.i18n["ko"]["M-978 Tanker - All crates"] = "M-978 연료 차량 - 전체 화물"
ctld.i18n["ko"]["Med Tank - LAV-25 - All crates"] = "중형 전차 - LAV-25 - 전체 화물"
ctld.i18n["ko"]["MLRS - All crates"] = "MLRS - 전체 화물"
ctld.i18n["ko"]["NASAMS - All crates"] = "NASAMS - 전체 화물"
ctld.i18n["ko"]["Patriot - All crates"] = "패트리어트 - 전체 화물"
ctld.i18n["ko"]["S-300 - All crates"] = "S-300 - 전체 화물"
ctld.i18n["ko"]["Roland ADS - All crates"] = "롤랑 ADS - 전체 화물"
ctld.i18n["ko"]["SpGH DANA - All crates"] = "DANA 자주곡사포 - 전체 화물"
ctld.i18n["ko"]["SPH 2S19 Msta - All crates"] = "2S19 므스타 - 전체 화물"
ctld.i18n["ko"]["T155 Firtina - All crates"] = "T-155 프르트나 - 전체 화물"
ctld.i18n["ko"]["Ural-375 Ammo Truck - All crates"] = "Ural-375 탄약 차량 - 전체 화물"

--- Load Crate submenu
ctld.i18n["ko"]["Load Crate"] = "화물 적재"
ctld.i18n["ko"]["Land to load crates"] = "착륙 후 화물 적재 가능"
ctld.i18n["ko"]["No crates within 50m"] = "50m 내 화물 없음"
ctld.i18n["ko"]["You must land before you can load a crate!"] = "화물을 싣기 전에 먼저 착륙해야 합니다!"
ctld.i18n["ko"]["Maximum number of crates are on board!"] = "이미 화물을 최대로 실었습니다!"
ctld.i18n["ko"]["No crates within 50m to load!"] = "50m 내에 실을 화물이 없습니다!"
ctld.i18n["ko"]["Loaded %1 crate!"] = "%1 화물 적재 완료!"

--- Drop Crate(s)
ctld.i18n["ko"]["No crates on board to drop."] = "내릴 화물이 없습니다."
ctld.i18n["ko"]["You must land before dropping crates!"] = "화물을 내리기 전에 먼저 착륙해야 합니다!"
ctld.i18n["ko"]["%1 crate(s) dropped at your %2 o'clock"] = "%1개 화물이 %2시 방향에 내려졌습니다"

--- Unpack Crate submenu
ctld.i18n["ko"]["Unpack Crate"] = "화물 풀기"
ctld.i18n["ko"]["Land to unpack crates"] = "화물을 풀려면 착륙하세요"
ctld.i18n["ko"]["No complete crate sets nearby"] = "근처에 완전한 화물 세트 없음"
ctld.i18n["ko"]["Build FOB"] = "FOB 건설"
ctld.i18n["ko"]["You must land before unpacking crates!"] = "화물을 풀기 전에 먼저 착륙해야 합니다!"
ctld.i18n["ko"]["Not enough crates nearby to unpack!"] = "풀기에 충분한 화물이 근처에 없습니다!"
ctld.i18n["ko"]["%1 unpacked successfully!"] = "%1 풀기 완료!"

--- Pack Vehicle submenu
ctld.i18n["ko"]["Land to pack vehicles"] = "차량을 포장하려면 착륙하세요"
ctld.i18n["ko"]["No packable vehicles nearby"] = "근처에 포장 가능한 차량 없음"
ctld.i18n["ko"]["Vehicle no longer exists."] = "차량이 더 이상 존재하지 않습니다."
ctld.i18n["ko"]["Cannot pack this vehicle type."] = "이 유형의 차량은 포장할 수 없습니다."

--- Load / Unload Vehicle submenu (GAP-1)
ctld.i18n["ko"]["Land to load vehicles"] = "차량을 탑재하려면 착륙하세요"
ctld.i18n["ko"]["No vehicles nearby"] = "근처에 차량 없음"
ctld.i18n["ko"]["Vehicle no longer available."] = "차량을 더 이상 사용할 수 없습니다."
ctld.i18n["ko"]["Land to unload vehicles"] = "차량을 하역하려면 착륙하세요"
ctld.i18n["ko"]["No vehicle loaded."] = "탑재된 차량이 없습니다."
ctld.i18n["ko"]["Vehicle no longer loaded."] = "차량이 더 이상 탑재되어 있지 않습니다."
ctld.i18n["ko"]["Cannot load more vehicles (max: %d)."] = "차량을 더 이상 탑재할 수 없습니다 (최대: %d)."

--- List Nearby Crates
ctld.i18n["ko"]["List Nearby Crates"] = "근처 화물 목록"
ctld.i18n["ko"]["No crates within 300m."] = "300m 이내에 화물 없음."
ctld.i18n["ko"]["Crates within 300m:"] = "300m 이내 화물:"
ctld.i18n["ko"]["  %1: %2/%3 — READY"] = "  %1: %2/%3 — 준비됨"
ctld.i18n["ko"]["  %1: %2/%3 — incomplete"] = "  %1: %2/%3 — 불완전"

--- Check Cargo summary
ctld.i18n["ko"]["No cargo on board."] = "탑재 화물 없음."
ctld.i18n["ko"]["%1: %2 crate(s) onboard (%3 kg)"] = "%1: %2개 크레이트 탑재 중 (%3 kg)"
ctld.i18n["ko"]["%1 troop(s) onboard (%2 kg)"] = "%1명 병사 탑재 중 (%2 kg)"
ctld.i18n["ko"]["%1: %2 vehicle(s) onboard"] = "%1: %2대 차량 탑재 중"
ctld.i18n["ko"]["Total cargo weight: %1 kg"] = "총 화물 무게: %1 kg"

--- Request JTAC Equipment menu
ctld.i18n["ko"]["Request JTAC Equipment"] = "JTAC 장비 요청"
ctld.i18n["ko"]["You must be landed to request JTAC equipment."] = "JTAC 장비를 요청하려면 착륙해야 합니다."
ctld.i18n["ko"]["You are not close enough to friendly logistics."] = "아군 군수 시설에서 충분히 가깝지 않습니다."
ctld.i18n["ko"]["%s is ready for pickup."] = "%s 픽업 준비 완료."

--- Request Equipment spawn messages
ctld.i18n["ko"]["Land near logistics to request equipment"] = "장비 요청을 위해 군수 근처에 착륙하세요"
ctld.i18n["ko"]["No logistics in range"] = "범위 내 군수 없음"
ctld.i18n["ko"]["All crates"] = "전체 화물"
ctld.i18n["ko"]["You must be landed to request a crate."] = "화물을 요청하기 전에 먼저 착륙해야 합니다!"
ctld.i18n["ko"]["You are not close enough to friendly logistics to get a crate!"] = "아군 보급계가 화물을 싣기에 충분한 거리에 있지 않습니다!"
ctld.i18n["ko"]["A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock "] = "%2 KG의 %1 화물이 %3 시 방향에 있습니다."
ctld.i18n["ko"]["%1 crates have been brought out at your %2 o'clock"] = "%1개의 화물이 %2시 방향에 배치되었습니다"

--- Feature H — Smoke auto-resume toggle
ctld.i18n["ko"]["Smoke Auto-Resume [activate]"]   = "연막 자동재개 [활성화]"
ctld.i18n["ko"]["Smoke Auto-Resume [deactivate]"] = "연막 자동재개 [비활성화]"
ctld.i18n["ko"]["Smoke auto-resume ON (%1s interval)"]  = "연막 자동재개 ON (%1초 간격)"
ctld.i18n["ko"]["Smoke auto-resume OFF"]                = "연막 자동재개 OFF"

-- End : CTLD_i18n_ko.lua
-- ====================================================================================================
-- Start : CTLD_utils.lua
---@diagnostic disable
-- CTLD_utils.lua
-- Static utility module: geometry, vectors, DCS spawn helpers, table utilities.
-- Originally derived from MIST (https://github.com/mrSkortch/MissionScriptingTools).
-- CTLD no longer depends on MIST; all required functions are embedded here.
-- NOTE: Do NOT re-introduce a MIST dependency. If a utility is missing, port it from MIST into this file.


-- 1. Définition du namespace global 'ctld'
ctld = ctld or {}

-- ====================================================================================================
-- CLASS ctld.utils
-- ====================================================================================================

local utils = {}
ctld.utils = utils
if not ctld.utils.marks then ctld.utils.marks = {}; end

function ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
    local coalitionId = coalitionId or 2
    local markId = ctld.utils.getNextMarkId()

    -- Color
    local tableColor = { 0, 0, 255, 0.4 }  --blue  by default
    if coalitionId == 1 then
        tableColor = { 1, 0, 0, 0.4 }      --red  % of (r,g,b,alpha)    red
    elseif coalitionId == 2 then
        tableColor = { 0, 0, 255, 0.4 }    --blue  % of (r,g,b,alpha)   blue
    elseif coalitionId == 0 then
        tableColor = { 2, 173, 33, 0.4 }   --green  % of (r,g,b,alpha)  neutral
    elseif coalitionId == -1 then
        tableColor = { 247, 179, 30, 0.4 } --orange  % of (r,g,b,alpha) All
    end

    local tableFillColor = { 0, 0, 255, 0.4 } --tableColor
    local lineType = 1                        --solid
    local message = message or ""
    ctld.utils.marks[markId] = message

    --trigger.action.quadToAll(number coalition , number id , vec3 point1 , vec3 point2 , vec3 point3 , vec3 point4 , table color , table fillColor , number lineType , boolean readOnly, string message)
    trigger.action.quadToAll(coalitionId, markId,
        vec3Points1To4[1], vec3Points1To4[2], vec3Points1To4[3], vec3Points1To4[4],
        tableColor, tableFillColor, lineType, true, message)

    --[[-example ------------------------------------------------------------
local heliName = "h1-1"
local triggerUnitObj = Unit.getByName(heliName)
local vec3StartPoint = triggerUnitObj:getPosition().p
local vec3EndPoint = {x = vec3StartPoint.x+1000,z=vec3StartPoint.z+1000,y=vec3StartPoint.y}
ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
]] --
end

--------------------------------------------------------------------------------------------------------
-- Calculates the absolute coordinates (x, y, heading, altitude) of a target point
-- based on a reference point and a relative offset, respecting the DCS coordinate system
-- (X=North, Y=East) and magnetic declination.
---------------------------------------------------------------------------------------------
-- @param refX X coordinate (North) of the reference point.
-- @param refY Y coordinate (East) of the reference point.
-- @param refHeading True/Geographic Heading of the reference unit in degrees.
-- @param refAltitude Altitude of the reference unit.
-- @param offsetAngleInDegrees Angle of the offset relative to the reference heading (0 = directly ahead).
-- @param offsetDistance Distance of the offset.
-- @param offsetHeading True/Geographic Heading for the final point.
-- @param offsetAltitude Altitude difference to add to the reference altitude.
-- @param magneticDeclinationInDegrees Magnetic Declination (subtract from True Heading to get Magnetic Heading).
--
-- @return x Absolute X coordinate (North) of the target point.
-- @return y Absolute Y coordinate (East) of the target point.
-- @return magneticHeadingInDegrees Magnetic Heading of the target point in degrees.
-- @return altitude Absolute altitude of the target point.
---
function ctld.utils.getRelativeCoords(
    refX, refY, refHeading, refAltitude,
    offsetAngleInDegrees, offsetDistanceInMeters,
    offsetHeadingInDegrees, offsetAltitudeInMeters,
    magneticDeclinationInDegrees
)
    -------------------------------------------------------------------------
    -- 1. Convert reference heading (radians → degrees)
    --    refHeading is a DCS true heading in radians, clockwise, 0 = North.
    -------------------------------------------------------------------------
    local refHeadingDeg = math.deg(refHeading)

    -------------------------------------------------------------------------
    -- 2. Compute the world angle used to project the new position.
    --    offsetAngleInDegrees is relative to the aircraft's heading.
    -------------------------------------------------------------------------
    local worldAngleDeg = refHeadingDeg + offsetAngleInDegrees

    -- Convert to radians for math.sin/cos (DCS uses clockwise headings)
    local worldAngleRad = math.rad(worldAngleDeg)

    -------------------------------------------------------------------------
    -- 3. Compute position deltas using DCS Cartesian coordinates:
    --    X axis = South/North, positive to the North.
    --    Y axis (vec3.z) = West/East, positive to the East.
    -------------------------------------------------------------------------
    local dx = math.cos(worldAngleRad) * offsetDistanceInMeters
    local dy = math.sin(worldAngleRad) * offsetDistanceInMeters

    local newX = refX + dx
    local newY = refY + dy

    -------------------------------------------------------------------------
    -- 4. Compute the object's final magnetic heading.
    --
    --    refHeadingDeg            = reference TRUE heading
    --    + offsetHeadingInDegrees = rotation relative to the reference
    --    - magneticDeclination    = convert true → magnetic
    -------------------------------------------------------------------------
    local magneticHeadingDeg =
        refHeadingDeg +
        offsetHeadingInDegrees -
        magneticDeclinationInDegrees

    -- Normalize to 0–360°
    magneticHeadingDeg = (magneticHeadingDeg % 360 + 360) % 360

    -------------------------------------------------------------------------
    -- 5. Compute altitude
    -------------------------------------------------------------------------
    local newAltitude = refAltitude + offsetAltitudeInMeters

    return newX, newY, magneticHeadingDeg, newAltitude
end

--------------------------------------------------------------------------------------------------------
-- Return a Vec2 point relative to  a reference point (position & heading DCS)
function ctld.utils.GetRelativeVec2Coords(refVec2Point, refHeadingInRadians, distanceFromRef,
                                          angleInDegreesFromRefHeading)
    -- absolue Heading in radians
    local absoluteHeadingInRadians = refHeadingInRadians + math.rad(angleInDegreesFromRefHeading)
    -- in DCS : x = Nord (+), z = Est (+)
    local dx = math.cos(absoluteHeadingInRadians) * distanceFromRef -- displacement North/South
    local dy = math.sin(absoluteHeadingInRadians) * distanceFromRef -- displacement Est/West

    local newCoords = {
        x = refVec2Point.x + dx,
        y = refVec2Point.y + dy,
    }
    return newCoords
end

------------------------------------------------------------------------------------
--- Calculates the relative bearing of a destination point from a reference point.
--- The bearing is expressed relative to the reference heading.
---
--- Input conventions (DCS-compatible):
---  - refLat / destLat are in decimal degrees
---  - refLon / destLon are in decimal degrees
---  - refHeading is in DEGREES (user-facing), converted to radians internally
---  - bearing output can be in radians, degrees, or clock position
---
--- Output formats:
---  - "radian" : relative bearing in radians [-pi .. +pi]
---  - "degree" : relative bearing in degrees [0 .. 360[
---  - "clock"  : clock position (12 = ahead, 3 = right, 6 = behind, etc.)
---
--- @param caller string Calling context (for logging)
--- @param refLat number Reference latitude in decimal degrees
--- @param refLon number Reference longitude in decimal degrees
--- @param refHeadingInDegrees number Heading in degrees (0-360)
--- @param destLat number Destination latitude in decimal degrees
--- @param destLon number Destination longitude in decimal degrees
--- @param resultFormat string Output format ("radian", "degree", "clock")
--- @return number, string Relative bearing and format
------------------------------------------------------------------------------------
function ctld.utils.getRelativeBearing(
    caller,
    refLat,
    refLon,
    refHeadingInDegrees,
    destLat,
    destLon,
    resultFormat
)
    -- Input validation
    if not refLat or not refLon or not refHeadingInDegrees or not destLat or not destLon then
        if env and env.error then
            env.error("ctld.utils.getRelativeBearing()." .. tostring(caller) ..
                ": All input values (refLat, refLon, refHeadingInDegrees, destLat, destLon) must be provided.")
        end
        return 0, resultFormat
    end

    -- Convert degrees to radians for calculations
    local refLatRad = math.rad(refLat)
    local refLonRad = math.rad(refLon)
    local destLatRad = math.rad(destLat)
    local destLonRad = math.rad(destLon)

    -- Calculate delta in radians
    local dLat = destLatRad - refLatRad
    local dLon = destLonRad - refLonRad

    -- Calculate bearing using haversine-like formula (forward azimuth)
    -- atan2(sin(dLon) * cos(destLat), cos(refLat) * sin(destLat) - sin(refLat) * cos(destLat) * cos(dLon))
    local trueBearingRad = math.atan2(
        math.sin(dLon) * math.cos(destLatRad),
        math.cos(refLatRad) * math.sin(destLatRad) -
        math.sin(refLatRad) * math.cos(destLatRad) * math.cos(dLon)
    )

    -- Normalize true bearing to [0, 2π)
    if trueBearingRad < 0 then
        trueBearingRad = trueBearingRad + 2 * math.pi
    end

    -- Convert reference heading from degrees to radians
    local refHeadingRad = math.rad(refHeadingInDegrees)

    -- Compute relative bearing (subtract reference heading)
    local relativeRad = trueBearingRad - refHeadingRad

    -- Normalize relative bearing to [-π, +π]
    relativeRad = (relativeRad + math.pi) % (2 * math.pi) - math.pi

    -- Output formats
    if resultFormat == "radian" then
        return relativeRad, resultFormat
    end

    -- Convert to degrees [0, 360)
    local relativeDeg = math.deg(relativeRad)
    if relativeDeg < 0 then
        relativeDeg = relativeDeg + 360
    end

    if resultFormat == "clock" then
        -- 12 o'clock = ahead (0°), each hour = 30 degrees
        -- Clock 3 = right (90°), 6 = behind (180°), 9 = left (270°)
        local clock = math.floor((relativeDeg + 15) / 30) % 12
        if clock == 0 then clock = 12 end
        return clock, resultFormat
    end

    -- Default: degrees [0, 360)
    return relativeDeg, "degree"
end

--------------------------------------------------------------------------------------------------------
--- Returns magnetic variation of given DCS point (vec2 or vec3).
-- borrowed from mist
function ctld.utils.getNorthCorrectionInRadians(caller, vec2OrVec3Point) --gets the correction needed for true north (magnetic variation)
    if vec2OrVec3Point == nil then
        if env and env.error then
            env.error("ctld.utils.getNorthCorrectionInRadians()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return 0
    end

    local point = ctld.utils.deepCopy("ctld.utils.getNorthCorrectionInRadians()", vec2OrVec3Point)
    if point == nil then
        return 0
    else
        if not point.z then --Vec2; convert to Vec3
            point.z = point.y
            point.y = 0
        end
        local lat, lon = coord.LOtoLL(point)
        local north_posit = coord.LLtoLO(lat + 1, lon)
        return math.atan(north_posit.z - point.z, north_posit.x - point.x)
    end
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:getHeadingInRadians
-- @-- borrowed from mist
---@param unitObject any
---@param rawHeading boolean (true=geographic/false=magnetic)
---@return integer       --- @--return "magneticHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, false)))..", geographicHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, true)))
function ctld.utils.getHeadingInRadians(caller, unitObject, rawHeading) --rawHeading: boolean (true=geographic/false=magnetic)
    if not unitObject then
        if env and env.error then
            env.error("ctld.utils.getHeadingInRadians()." .. tostring(caller) .. ": Invalid unit object provided.")
        end
        return 0
    end
    rawHeading = rawHeading or false
    local unitpos = unitObject:getPosition()
    if unitpos then
        local HeadingInRadians = math.atan2(unitpos.x.z, unitpos.x.x)
        if not rawHeading then
            HeadingInRadians = HeadingInRadians +
                ctld.utils.getNorthCorrectionInRadians("ctld.utils.getHeadingInRadians()", unitpos.p)
        end
        if HeadingInRadians < 0 then
            HeadingInRadians = HeadingInRadians + 2 * math.pi -- put heading in range of 0 to 2*pi
        end
        return HeadingInRadians
    end
    return 0
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec2 to a Vec3.
-- @-- borrowed from mist
-- @tparam Vec2 vec the 2D vector
-- @param y optional new y axis (altitude) value. If omitted it's 0.
function ctld.utils.makeVec3FromVec2OrVec3(caller, vec, y)
    if not vec then
        if env and env.error then
            env.error("ctld.utils.makeVec3FromVec2OrVec3()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if not vec.z then
        if vec.alt and not y then
            y = vec.alt
        elseif not y then
            y = 0
        end
        return { x = vec.x, y = y, z = vec.y }
    else
        return { x = vec.x, y = vec.y, z = vec.z } -- it was already Vec3, actually.
    end
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec3 to a Vec2.
-- @tparam Vec3 vec the 3D vector
-- @return vector converted to Vec2
function ctld.utils.makeVec2FromVec3OrVec2(caller, vec)
    if vec == nil then
        if env and env.error then
            env.error("ctld.utils.makeVec2FromVec3OrVec2()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if vec.z then
        return { x = vec.x, y = vec.z }
    else
        return { x = vec.x, y = vec.y } -- it was actually already vec2.
    end
end

--------------------------------------------------------------------------------------------------------
--- Build a position string for a DCS unit (lat/lon + MGRS + altitude).
-- Returns "" if JTAC_location config is false or unit is nil.
-- @param unit DCS Unit object
-- @return string  e.g. " @ 42°15.3'N 041°42.1'E - MGRS 38TML… - ALTI: 250 m / 820 ft"
function ctld.utils.getPositionString(unit)
    if ctld.gs("JTAC_location") == false or unit == nil then
        return ""
    end
    local _lat, _lon  = coord.LOtoLL(unit:getPosition().p)
    local _latLngStr  = ctld.utils.tostringLL("getPositionString", _lat, _lon, 3,
        ctld.gs("location_DMS"))
    local _mgrsString = ctld.utils.tostringMGRS("getPositionString",
        coord.LLtoMGRS(coord.LOtoLL(unit:getPosition().p)), 5)
    local _alt        = land.getHeight(ctld.utils.makeVec2FromVec3OrVec2("getPositionString",
        unit:getPoint()))
    return " @ " .. _latLngStr ..
        " - MGRS " .. _mgrsString ..
        " - ALTI: " .. ctld.utils.round("getPositionString", _alt, 0) ..
        " m / " .. ctld.utils.round("getPositionString", _alt / 0.3048, 0) .. " ft"
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:rotateVec3
-- Calcule l'offset cartésien absolu en appliquant la rotation du cap de l'appareil.
-- (Conçu pour le format de données : relative = {x, y, z})
function ctld.utils.rotateVec3(relativeVec, headingDeg)
    local x_rel = relativeVec.x
    local z_rel = relativeVec.z
    -- y_rel n'est pas utilisé dans le calcul de rotation, mais sera dans le retour
    local y_rel = relativeVec.y or 0

    -- Vérification des données (X et Z sont obligatoires)
    if x_rel == nil or z_rel == nil then
        local msg = "CTLD.utils:rotateVec3: Missing X or Z component in relative position data."
        if env and env.error then
            env.error(msg)
            -- Lève une erreur qui sera capturée par pcall (si appelé)
            error(msg)
        else
            error(msg)
        end
    end

    local headingRad = math.rad(headingDeg)
    local cos_h = math.cos(headingRad)
    local sin_h = math.sin(headingRad)

    local x_rot = (z_rel * sin_h) + (x_rel * cos_h)
    local z_rot = (z_rel * cos_h) - (x_rel * sin_h)

    return { x = x_rot, y = y_rel, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
-- Add 2 position vectors (Vec3) of DCS.
function ctld.utils.addVec3(vec1, vec2)
    return {
        -- Use or 0 to avoid 'nil'
        x = (vec1.x or 0) + (vec2.x or 0),
        y = (vec1.y or 0) + (vec2.y or 0),
        z = (vec1.z or 0) + (vec2.z or 0),
    }
end

--------------------------------------------------------------------------------------------------------
--- Vector substraction.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn Vec3 new vector, vec2 substracted from vec1.
function ctld.utils.subVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.subVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return nil
    end
    return { x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z }
end

--------------------------------------------------------------------------------------------------------
--- Vector dot product.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn number dot product of given vectors
function ctld.utils.multVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.multVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

--------------------------------------------------------------------------------------------------------
--- Returns the center of a zone as Vec3.
-- @-- borrowed from mist
-- @tparam string|table zone trigger zone name or table
-- @treturn Vec3 center of the zone
function ctld.utils.zoneToVec3(caller, zone, gl)
    if zone == nil then
        if env and env.error then
            env.error("ctld.utils.zoneToVec3()." .. tostring(caller) .. ": Invalid zone provided.")
        end
        return nil
    end

    ---@diagnostic disable: assign-type-mismatch
    local new = { x = 0, y = 0, z = 0 }
    if type(zone) == 'table' then
        if zone.point then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        elseif zone.x and zone.y and zone.z then
            local copied = ctld.utils.deepCopy("ctld.utils.zoneToVec3()", zone)
            if copied then
                new = copied
            end
        end
        return new
    elseif type(zone) == 'string' then
        zone = trigger.misc.getZone(zone)
        if zone then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        end
    end

    if new.x and gl then
        new.y = land.getHeight({ x = new.x, y = new.z })
    end
    return new
end

--------------------------------------------------------------------------------------------------------
--- Vector magnitude
-- @tparam Vec3 (3D with x,y,z)vec vector
-- @treturn number magnitude of vector vec
function ctld.utils.vec3Mag(caller, vec3)
    if vec3 == nil or vec3.x == nil or vec3.y == nil or vec3.z == nil then
        if env and env.error then
            env.error("ctld.utils.vec3Mag()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return 0
    end

    return (vec3.x ^ 2 + vec3.y ^ 2 + vec3.z ^ 2) ^ 0.5
end

--------------------------------------------------------------------------------------------------------
--- Returns distance in meters between two points.
-- @-- borrowed from mist
-- @tparam Vec2|Vec3 point1 first point
-- @tparam Vec2|Vec3 point2 second point
-- @treturn number distance between given points.
function ctld.utils.get2DDist(caller, point1, point2)
    if point1 == nil or point2 == nil then
        if env and env.error then
            env.error("ctld.utils.get2DDist()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    if not point1 then
        ctld.logWarning("ctld.utils.get2DDist()  1st input value is nil")
    end
    if not point2 then
        ctld.logWarning("ctld.utils.get2DDist()  2nd input value is nil")
    end
    ---@type table
    point1 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point1)
    ---@type table
    point2 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point2)
    return ctld.utils.vec3Mag("ctld.utils.get2DDist()", { x = point1.x - point2.x, y = 0, z = point1.z - point2.z })
end

--get distance in meters assuming a Flat world
function ctld.utils.getDistance(caller, _point1, _point2)
    if _point1 == nil or _point2 == nil then
        if env and env.error then
            env.error("ctld.utils.getDistance()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

----------------------------------------------------------------------------------------------------------
-- gets the center of a bunch of points!
-- return proper DCS point with height
function ctld.utils.getCentroid(caller, _points)
    if _points == nil or #_points == 0 then
        if env and env.error then
            env.error("ctld.utils.getCentroid()." .. tostring(caller) .. ": Invalid points provided.")
        end
        return nil
    end
    local _tx, _ty = 0, 0
    for _index, _point in ipairs(_points) do
        _tx = _tx + _point.x
        _ty = _ty + _point.z
    end

    local _npoints = #_points

    local _point = { x = _tx / _npoints, z = _ty / _npoints }

    _point.y = land.getHeight({ x = _point.x, y = _point.z })

    return _point
end

--------------------------------------------------------------------------------------------------------
--- Simple rounding function.
-- @-- borrowed from mist
-- From http://lua-users.org/wiki/SimpleRound
-- use negative idp for rounding ahead of decimal place, positive for rounding after decimal place
-- @tparam number num number to round
-- @param idp
function ctld.utils.round(caller, num, idp)
    if num == nil or type(num) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.round()." .. tostring(caller) .. ": Invalid number provided.")
        end
        return 0
    end
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------------------------------
-- initialize the random number generator to make it almost random
math.random(); math.random(); math.random()
--------------------------------------------------------------------------------------------------------
function ctld.utils.RandomReal(caller, mini, maxi)
    if mini == nil or maxi == nil then
        if env and env.error then
            env.error("ctld.RandomReal()." .. tostring(caller) .. ": Both min and max values must be provided.")
        end
        return 0
    end
    local rand = math.random()                 --random value between 0 and 1
    local result = mini + rand * (maxi - mini) --	scale the random value between [mini, maxi]
    return result
end

--------------------------------------------------------------------------------------------------------
--[[acc:
in DM: decimal point of minutes.
In DMS: decimal point of seconds.
position after the decimal of the least significant digit:
So:
42.32 - acc of 2.
]]
function ctld.utils.tostringLL(caller, lat, lon, acc, DMS)
    if lat == nil or lon == nil then
        if env and env.error then
            env.error("ctld.utils.tostringLL()." .. tostring(caller) .. ": Invalid latitude or longitude provided.")
        end
        return ""
    end
    local latHemi, lonHemi
    if lat > 0 then
        latHemi = 'N'
    else
        latHemi = 'S'
    end

    if lon > 0 then
        lonHemi = 'E'
    else
        lonHemi = 'W'
    end

    lat = math.abs(lat)
    lon = math.abs(lon)

    local latDeg = math.floor(lat)
    local latMin = (lat - latDeg) * 60

    local lonDeg = math.floor(lon)
    local lonMin = (lon - lonDeg) * 60

    if DMS then -- degrees, minutes, and seconds.
        local oldLatMin = latMin
        latMin = math.floor(latMin)
        local latSec = ctld.utils.round("ctld.utils.tostringLL()", (oldLatMin - latMin) * 60, acc)

        local oldLonMin = lonMin
        lonMin = math.floor(lonMin)
        local lonSec = ctld.utils.round("ctld.utils.tostringLL()", (oldLonMin - lonMin) * 60, acc)

        if latSec == 60 then
            latSec = 0
            latMin = latMin + 1
        end

        if lonSec == 60 then
            lonSec = 0
            lonMin = lonMin + 1
        end

        local secFrmtStr -- create the formatting string for the seconds place
        if acc <= 0 then -- no decimal place.
            secFrmtStr = '%02d'
        else
            local width = 3 + acc -- 01.310 - that's a width of 6, for example.
            secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
        end

        return string.format('%02d', latDeg) ..
            ' ' ..
            string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '	 '
            ..
            string.format('%02d', lonDeg) ..
            ' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi
    else -- degrees, decimal minutes.
        latMin = ctld.utils.round("ctld.utils.tostringLL()", latMin, acc)
        lonMin = ctld.utils.round("ctld.utils.tostringLL()", lonMin, acc)

        if latMin == 60 then
            latMin = 0
            latDeg = latDeg + 1
        end

        if lonMin == 60 then
            lonMin = 0
            lonDeg = lonDeg + 1
        end

        local minFrmtStr -- create the formatting string for the minutes place
        if acc <= 0 then -- no decimal place.
            minFrmtStr = '%02d'
        else
            local width = 3 + acc -- 01.310 - that's a width of 6, for example.
            minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
        end

        return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '	 '
            .. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi
    end
end

--------------------------------------------------------------------------------------------------------
--- Returns MGRS coordinates as string.
-- @tparam string MGRS MGRS coordinates
-- @tparam number acc the accuracy of each easting/northing.
-- Can be: 0, 1, 2, 3, 4, or 5.
function ctld.utils.tostringMGRS(caller, MGRS, acc)
    if MGRS == nil or type(MGRS) ~= 'table' or not MGRS.UTMZone or not MGRS.MGRSDigraph then
        if env and env.error then
            env.error("ctld.utils.tostringMGRS()." .. tostring(caller) .. ": Invalid MGRS coordinates provided.")
        end
        return ""
    end
    if acc == 0 then
        return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph
    else
        return MGRS.UTMZone ..
            ' ' ..
            MGRS.MGRSDigraph ..
            ' ' ..
            string.format('%0' .. acc .. 'd',
                ctld.utils.round("ctld.utils.tostringMGRS()", MGRS.Easting / (10 ^ (5 - acc)), 0))
            ..
            ' ' ..
            string.format('%0' .. acc .. 'd',
                ctld.utils.round("ctld.utils.tostringMGRS()", MGRS.Northing / (10 ^ (5 - acc)), 0))
    end
end

--------------------------------------------------------------------------------------------------------
ctld.utils.UniqIdCounter = 0 -- Compteur statique pour les ID uniques
--- @function ctld.utils:getNextUniqId
-- Génère un ID unique incrémental, comme requis pour 'unitId' dans groupData.
function ctld.utils.getNextUniqId()
    ctld.utils.UniqIdCounter = ctld.utils.UniqIdCounter + 1
    return ctld.utils.UniqIdCounter
end

-- Mark ID counter — monotonically increasing, app-wide.
-- DCS: once removeMark(id) is called, that id is permanently invalid and must never be reused.
-- All Draw API callers (RECON, Beacon, drawQuad) share this counter to avoid collisions.
-- Encoded IDs use markId * 10 + offset (1–3 elements per logical mark).
ctld.utils.MarkIdCounter = 0

--- Allocate the next unique mark ID for DCS Draw API calls.
-- Never reuse a previously allocated ID after removeMark() has been called on it.
-- @return number
function ctld.utils.getNextMarkId()
    ctld.utils.MarkIdCounter = ctld.utils.MarkIdCounter + 1
    return ctld.utils.MarkIdCounter
end

--- Converts angle in radians to degrees.
-- @param angleInRadians angle in radians
-- @return angle in degrees
function ctld.utils.radianToDegree(caller, angleInRadians)
    if angleInRadians == nil or type(angleInRadians) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.toDegree()." .. tostring(caller) .. ": Invalid angle provided.")
        end
        return 0
    end
    return math.deg(angleInRadians)
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:normalizeHeading
-- Normalise a heading between 0 et 360 degrees.
function ctld.utils.normalizeHeadingInDegrees(caller, offsetHeadingInDegrees)
    if offsetHeadingInDegrees == nil then
        if env and env.error then
            env.error("CTLD.utils.normalizeHeadingInDegrees()." .. tostring(caller) .. ": Invalid heading provided.")
        end
        return 0
    end
    local result = offsetHeadingInDegrees % 360
    if result < 0 then
        result = result + 360
    end
    return result
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:polarToCartesian
-- Convertit une distance (rho), un angle (theta) et un cap de référence (headingDeg)
-- en coordonnées cartésiennes absolues (x, z) de la carte DCS.
-- @param distance number La distance au point de référence.
-- @param relativeAngle number L'angle relatif au point de référence (0 = devant, 90 = droite).
-- @param headingDeg number Le cap absolu de l'appareil (point de référence).
-- @return table L'offset cartésien absolu { x, y=0, z }.
function ctld.utils.polarToCartesian(distance, relativeAngle, headingDeg)
    local absoluteAngle = headingDeg + relativeAngle
    local angleRad = math.rad(absoluteAngle)

    -- Correction du facteur distance (20m -> 10m)
    local dist = (distance or 0) * 2

    -- X (Nord/Sud, l'axe de référence du cap 0°) : Utilise COS
    local x_rot = dist * math.cos(angleRad)

    -- Z (Est/Ouest) : Utilise SIN. La trigonométrie standard sin(angle) augmente CCW.
    -- Nous ne touchons pas au signe car la trigonométrie de DCS peut être non standard.
    local z_rot = dist * math.sin(angleRad)

    return { x = x_rot, y = 0, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
--- Converts kilometers per hour to meters per second.
-- @param kmph speed in km/h
-- @return speed in m/s
function ctld.utils.kmphToMps(caller, kmph)
    if kmph == nil or type(kmph) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.kmphToMps()." .. tostring(caller) .. ": Invalid speed provided.")
        end
        return 0
    end
    return kmph / 3.6
end

--------------------------------------------------------------------------------------------------------
--- Builds a ground waypoint from a point definition.
-- No longer accepts path
function ctld.utils.buildWP(caller, point, overRideForm, overRideSpeed)
    if point == nil then
        if env and env.error then
            env.error("ctld.utils.buildWP()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return nil
    end

    local wp = {}
    wp.x = point.x

    if point.z then
        wp.y = point.z
    else
        wp.y = point.y
    end
    local form, speed

    if point.speed and not overRideSpeed then
        wp.speed = point.speed
    elseif type(overRideSpeed) == 'number' then
        wp.speed = overRideSpeed
    else
        wp.speed = ctld.utils.kmphToMps("ctld.utils.buildWP()", 20)
    end

    if point.form and not overRideForm then
        form = point.form
    else
        form = overRideForm
    end

    if not form then
        wp.action = 'Cone'
    else
        form = string.lower(form)
        if form == 'off_road' or form == 'off road' then
            wp.action = 'Off Road'
        elseif form == 'on_road' or form == 'on road' then
            wp.action = 'On Road'
        elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest' then
            wp.action = 'Rank'
        elseif form == 'cone' then
            wp.action = 'Cone'
        elseif form == 'diamond' then
            wp.action = 'Diamond'
        elseif form == 'vee' then
            wp.action = 'Vee'
        elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
            wp.action = 'EchelonL'
        elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
            wp.action = 'EchelonR'
        else
            wp.action = 'Cone' -- if nothing matched
        end
    end

    wp.type = 'Turning Point'

    return wp
end

--------------------------------------------------------------------------------------------------------
function ctld.utils.getUnitsLOS(caller, unitset1, altoffset1, unitset2, altoffset2, radius)
    --ctld.logInfo("%s, %s, %s, %s, %s", unitset1, altoffset1, unitset2, altoffset2, radius)
    if unitset1 == nil or unitset2 == nil or altoffset1 == nil or altoffset2 == nil or radius == nil then
        if env and env.error then
            env.error("ctld.utils.getUnitsLOS()." .. tostring(caller) .. ": parameters sets cannot be nil.")
        end
        return {}
    end

    radius = radius or math.huge
    local unit_info1 = {}
    local unit_info2 = {}

    -- get the positions all in one step, saves execution time.
    for unitset1_ind = 1, #unitset1 do
        local unit1 = Unit.getByName(unitset1[unitset1_ind])
        if unit1 then
            local lCat = Object.getCategory(unit1)
            if ((lCat == 1 and unit1:isActive()) or lCat ~= 1) and unit1:isExist() == true then
                unit_info1[#unit_info1 + 1] = {}
                unit_info1[#unit_info1].unit = unit1
                unit_info1[#unit_info1].pos = unit1:getPosition().p
            end
        end
    end

    for unitset2_ind = 1, #unitset2 do
        local unit2 = Unit.getByName(unitset2[unitset2_ind])
        if unit2 then
            local lCat = Object.getCategory(unit2)
            if ((lCat == 1 and unit2:isActive()) or lCat ~= 1) and unit2:isExist() == true then
                unit_info2[#unit_info2 + 1] = {}
                unit_info2[#unit_info2].unit = unit2
                unit_info2[#unit_info2].pos = unit2:getPosition().p
            end
        end
    end

    local LOS_data = {}
    -- now compute los
    for unit1_ind = 1, #unit_info1 do
        local unit_added = false
        for unit2_ind = 1, #unit_info2 do
            if radius == math.huge or (ctld.utils.vec3Mag("ctld.utils.getUnitsLOS()", ctld.utils.subVec3("ctld.utils.getUnitsLOS()", unit_info1[unit1_ind].pos, unit_info2[unit2_ind].pos)) < radius) then -- inside radius
                local point1 = {
                    x = unit_info1[unit1_ind].pos.x,
                    y = unit_info1[unit1_ind].pos.y + altoffset1,
                    z =
                        unit_info1[unit1_ind].pos.z
                }
                local point2 = {
                    x = unit_info2[unit2_ind].pos.x,
                    y = unit_info2[unit2_ind].pos.y + altoffset2,
                    z =
                        unit_info2[unit2_ind].pos.z
                }
                if land.isVisible(point1, point2) then
                    if unit_added == false then
                        unit_added = true
                        LOS_data[#LOS_data + 1] = {}
                        LOS_data[#LOS_data].unit = unit_info1[unit1_ind].unit
                        LOS_data[#LOS_data].vis = {}
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    else
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    end
                end
            end
        end
    end

    return LOS_data
end

--------------------------------------------------------------------------------------------------------
--- Returns GroundUnitsListNames for a given coalition
function ctld.utils.getUnitsListNamesByCategory(caller, coalitionId, categoryTable)
    if coalitionId == nil then
        if env and env.error then
            env.error("ctld.utils.getUnitsListNamesByCategory()." ..
                tostring(caller) .. ": Invalid coalition ID provided.")
        end
        return {}
    end

    if categoryTable == nil then -- all categories requested
        categoryTable = {
            Group.Category.AIRPLANE,
            Group.Category.HELICOPTER,
            Group.Category.GROUND,
            Group.Category.SHIP,
            Group.Category.TRAIN,
        }
    end

    local groupList = {}
    for _, v in ipairs(categoryTable) do
        local categGroupList = coalition.getGroups(coalitionId, v)
        if categGroupList then
            for _, group in ipairs(categGroupList) do
                table.insert(groupList, group)
            end
        end
    end

    local UnitsListNames = {}
    for _, v in ipairs(groupList) do
        local groupUnits = v:getUnits()
        for _, vv in ipairs(groupUnits) do
            UnitsListNames[#UnitsListNames + 1] = vv:getName()
        end
    end
    return UnitsListNames
end

--------------------------------------------------------------------------------------------------------
-- same as getGroupPoints but returns speed and formation type along with vec2 of point}
function ctld.utils.getGroupRoute(caller, groupName, task)
    if groupName == nil then
        if env and env.error then
            env.error("ctld.utils.getGroupRoute()." .. tostring(caller) .. ": Invalid group name provided.")
        end
        return nil
    end
    -- refactor to search by groupId and allow groupId and groupName as inputs
    local gpId = groupName
    --if mist.DBs.MEgroupsByName[groupName] then
    if Group.getByName[groupName] then
        gpId = Group.getByName[groupName]:getID()
    else
        ctld.logError("ctld.utils.getGroupRoute()." .. tostring(caller) .. "'%s' not found in mist.DBs.MEgroupsByName",
            groupName)
    end

    for coa_name, coa_data in pairs(env.mission.coalition) do
        if type(coa_data) == 'table' then
            if coa_data.country then --there is a country table
                for cntry_id, cntry_data in pairs(coa_data.country) do
                    for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                        if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then                       -- only these types have points
                            if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
                                for group_num, group_data in pairs(obj_cat_data.group) do
                                    if group_data and group_data.groupId == gpId then                                                                                -- this is the group we are looking for
                                        if group_data.route and group_data.route.points and #group_data.route.points > 0 then
                                            local points = {}

                                            for point_num, point in pairs(group_data.route.points) do
                                                local routeData = {}
                                                if env.mission.version > 7 and env.mission.version < 19 then
                                                    routeData.name = env.getValueDictByKey(point.name)
                                                else
                                                    routeData.name = point.name
                                                end
                                                if not point.point then
                                                    routeData.x = point.x
                                                    routeData.y = point.y
                                                else
                                                    routeData.point = point
                                                        .point --it's possible that the ME could move to the point = Vec2 notation.
                                                end
                                                routeData.form = point.action
                                                routeData.speed = point.speed
                                                routeData.alt = point.alt
                                                routeData.alt_type = point.alt_type
                                                routeData.airdromeId = point.airdromeId
                                                routeData.helipadId = point.helipadId
                                                routeData.type = point.type
                                                routeData.action = point.action
                                                if task then
                                                    routeData.task = point.task
                                                end
                                                points[point_num] = routeData
                                            end

                                            return points
                                        end
                                        ctld.logError('Group route not defined in mission editor for groupId: %s', gpId)
                                        return
                                    end --if group_data and group_data.name and group_data.name == 'groupname'
                                end     --for group_num, group_data in pairs(obj_cat_data.group) do
                            end         --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
                        end             --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
                    end                 --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                end                     --for cntry_id, cntry_data in pairs(coa_data.country) do
            end                         --if coa_data.country then --there is a country table
        end                             --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
    end                                 --for coa_name, coa_data in pairs(mission.coalition) do
end

--------------------------------------------------------------------------------------------------------
--- Returns the groupId for a given unit.
function ctld.utils.getGroupId(caller, _unitId)
    if _unitId == nil then
        if env and env.error then
            env.error("ctld.utils.getGroupId()." .. tostring(caller) .. ": Invalid unit provided.")
        end
        return nil
    end

    return _unitId:getGroup():getID()
end

--------------------------------------------------------------------------------------------------------
--- Spawns a static object to the game world.
-- Borrowed from mist.dynAddStatic and modified.
-- @todo write good docs
-- @tparam table staticObj table containing data needed for the object creation
function ctld.utils.dynAddStatic(caller, n)
    if n == nil then
        if env and env.error then
            env.error("ctld.utils.dynAddStatic()." .. tostring(caller) .. ": Invalid static object data provided.")
        end
        return false
    end
    --local newObj = mist.utils.deepCopy(n)
    local newObj = ctld.utils.deepCopy("ctld.utils.dynAddStatic()", n)
    if not newObj then return false end
    ---@type table
    newObj = newObj
    --ctld.logWarning(newObj)
    if newObj.units and newObj.units[1] then -- if its mist format
        for entry, val in pairs(newObj.units[1]) do
            if newObj[entry] and newObj[entry] ~= val or not newObj[entry] then
                newObj[entry] = val
            end
        end
    end
    --ctld.logInfo(newObj)

    local cntry = newObj.country
    if newObj.countryId then
        cntry = newObj.countryId
    end

    local newCountry = ''

    for countryId, countryName in pairs(country.name) do
        if type(cntry) == 'string' then
            cntry = cntry:gsub("%s+", "_")
            if tostring(countryName) == string.upper(cntry) then
                newCountry = countryName
            end
        elseif type(cntry) == 'number' then
            if countryId == cntry then
                newCountry = countryName
            end
        end
    end

    if newCountry == '' then
        ctld.logError("Country not found: %s", cntry)
        return false
    end

    if newObj.clone or not newObj.groupId then
        newObj.groupId = ctld.utils.getNextUniqId()
    end

    if newObj.clone or not newObj.unitId then
        newObj.unitId = ctld.utils.getNextUniqId()
    end

    newObj.name = newObj.name or newObj.unitName

    if newObj.clone or not newObj.name then
        newObj.name = (newCountry .. ' static ' .. tostring(newObj.groupId))
    end

    if not newObj.dead then
        newObj.dead = false
    end

    if not newObj.heading then
        newObj.heading = math.rad(math.random(360))
    end

    if newObj.categoryStatic then
        newObj.category = newObj.categoryStatic
    end
    if newObj.mass then
        newObj.category = 'Cargos'
    end

    if newObj.shapeName then
        newObj.shape_name = newObj.shapeName
    end

    if not newObj.shape_name then
        ctld.logInfo('shape_name not present')
    end
    if newObj.x and newObj.y and newObj.type and type(newObj.x) == 'number' and type(newObj.y) == 'number' and type(newObj.type) == 'string' then
        --ctld.logWarning(newObj)
        coalition.addStaticObject(country.id[newCountry], newObj)

        return newObj
    end
    ctld.logError("Failed to add static object due to missing or incorrect value. X: %s, Y: %s, Type: %s", newObj.x,
        newObj.y, newObj.type)
    return false
end

--------------------------------------------------------------------------------------------------------
--- Unified DCS object spawner — single call-site for coalition.addGroup / coalition.addStaticObject.
-- All CTLD spawners must route through this function instead of calling DCS APIs directly.
--
-- descriptor.spawnAs (string, optional, default "GROUND"):
--   "GROUND"    → coalition.addGroup(..., Group.Category.GROUND, ...)
--   "AIRPLANE"  → coalition.addGroup(..., Group.Category.AIRPLANE, ...)
--   "HELICOPTER"→ coalition.addGroup(..., Group.Category.HELICOPTER, ...)
--   "SHIP"      → coalition.addGroup(..., Group.Category.SHIP, ...)
--   "TRAIN"     → coalition.addGroup(..., Group.Category.TRAIN, ...)
--   "STATIC"    → coalition.addStaticObject(...)
--
-- @param descriptor table|nil  crate descriptor (reads .spawnAs); nil treated as GROUND
-- @param countryId  number     country.id.*
-- @param unitDef    table      DCS group or static definition
-- @return boolean, any        pcall result: (true, group) or (false, errorMsg)
local _SPAWN_CATEGORY_MAP = {
    GROUND     = Group.Category.GROUND,
    AIRPLANE   = Group.Category.AIRPLANE,
    HELICOPTER = Group.Category.HELICOPTER,
    SHIP       = Group.Category.SHIP,
    TRAIN      = Group.Category.TRAIN,
}
function ctld.utils.spawnFromDescriptor(descriptor, countryId, unitDef)
    local spawnAs = (descriptor and descriptor.spawnAs) or "GROUND"
    if spawnAs == "STATIC" then
        return pcall(coalition.addStaticObject, countryId, unitDef)
    else
        local cat = _SPAWN_CATEGORY_MAP[spawnAs] or Group.Category.GROUND
        return pcall(coalition.addGroup, countryId, cat, unitDef)
    end
end

--------------------------------------------------------------------------------------------------------
--- Build a DCS group unitDef table ready for ctld.utils.spawnFromDescriptor.
-- Handles GROUND and non-ground (AIRPLANE, HELICOPTER, SHIP, TRAIN) categories.
-- STATIC objects use a different DCS schema and are not handled here.
--
-- For non-ground units with descriptor.isJTAC = true, an orbit + EPLRS route is embedded
-- (required by DCS at spawn time; cannot be assigned post-spawn for loitering platforms).
-- The orbit altitude is read from ctld.gs("JTAC_droneAltitude") (default 4000 m).
--
-- @param desc   table   crate descriptor { unit, spawnAs, isJTAC, … }
-- @param pos    vec3    world spawn position {x, y, z}
-- @param gname  string  DCS group name (pre-allocated by caller)
-- @param gid    number  DCS group id   (pre-allocated; used in non-ground groupId + EPLRS)
-- @param uid    number  DCS unit id    (pre-allocated; used in non-ground unitId)
-- @return table  unitDef
function ctld.utils.buildGroupUnitDef(desc, pos, gname, gid, uid)
    local spawnAs = (desc and desc.spawnAs) or "GROUND"
    local isAir   = spawnAs ~= "GROUND" and spawnAs ~= "STATIC"

    if not isAir then
        -- GROUND: minimal DCS group definition
        return {
            name  = gname,
            task  = "Ground Nothing",
            units = { {
                type    = desc.unit,
                name    = gname,
                x       = pos.x,
                y       = pos.z,
                heading = 0,
            } },
        }
    else
        -- Non-ground (AIRPLANE / HELICOPTER / SHIP / TRAIN)
        local alt     = ctld.gs("JTAC_droneAltitude") or 4000
        local speed   = 54 -- m/s (~105 kts)
        local uname   = gname .. "_1"
        local unitDef = {
            ["name"]          = gname,
            ["groupId"]       = gid,
            ["communication"] = true,
            ["frequency"]     = 124,
            ["visible"]       = false,
            ["hidden"]        = false,
            ["start_time"]    = 0,
            ["task"]          = "Ground Nothing",
            ["x"]             = pos.x,
            ["y"]             = pos.z,
            ["units"]         = {
                [1] = {
                    ["type"]     = desc.unit,
                    ["name"]     = uname,
                    ["unitId"]   = uid,
                    ["x"]        = pos.x,
                    ["y"]        = pos.z,
                    ["heading"]  = 0,
                    ["alt"]      = alt,
                    ["alt_type"] = "RADIO",
                    ["speed"]    = speed,
                    ["skill"]    = "Excellent",
                },
            },
        }
        -- Orbit + EPLRS route: required at spawn time for loitering JTAC platforms
        if desc and desc.isJTAC then
            unitDef["route"] = {
                ["points"] = {
                    [1] = {
                        ["alt"]                = alt,
                        ["alt_type"]           = "RADIO",
                        ["action"]             = "Turning Point",
                        ["type"]               = "Turning Point",
                        ["speed"]              = speed,
                        ["ETA"]                = 0,
                        ["ETA_locked"]         = true,
                        ["speed_locked"]       = true,
                        ["formation_template"] = "",
                        ["properties"]         = { ["addopt"] = {} },
                        ["x"]                  = pos.x,
                        ["y"]                  = pos.z,
                        ["task"]               = {
                            ["id"]     = "ComboTask",
                            ["params"] = {
                                ["tasks"] = {
                                    [1] = {
                                        ["number"]  = 1,
                                        ["auto"]    = true,
                                        ["id"]      = "WrappedAction",
                                        ["enabled"] = true,
                                        ["params"]  = {
                                            ["action"] = {
                                                ["id"]     = "EPLRS",
                                                ["params"] = {
                                                    ["value"]   = true,
                                                    ["groupId"] = gid,
                                                },
                                            },
                                        },
                                    },
                                    [2] = {
                                        ["number"]  = 2,
                                        ["auto"]    = false,
                                        ["id"]      = "Orbit",
                                        ["enabled"] = true,
                                        ["params"]  = {
                                            ["altitude"] = alt,
                                            ["pattern"]  = "Circle",
                                            ["speed"]    = speed,
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            }
        end
        return unitDef
    end
end

--------------------------------------------------------------------------------------------------------
--- Spawns a dynamic group into the game world.
-- Borrowed from mist.dynAddStatic and modified.
-- Will generate groupId, groupName, unitId, and unitName if needed
-- @tparam table newGroup table containting values needed for spawning a group.
function ctld.utils.dynAdd(caller, ng)
    if ng == nil then
        if env and env.error then
            env.error("ctld.utils.dynAdd()." .. tostring(caller) .. ": Invalid group data provided.")
        end
        return false
    end
    local newGroup = ctld.utils.deepCopy(" ctld.utils.dynAdd()", ng)
    if not newGroup then return false end
    ---@type table
    newGroup = newGroup
    --ctld.logWarning(newGroup)
    --mist.debug.writeData(mist.utils.serialize,{'msg', newGroup}, 'newGroupOrig.lua')
    local cntry = newGroup.country
    if newGroup.countryId then
        cntry = newGroup.countryId
    end

    local groupType = newGroup.category
    local newCountry = ''
    -- validate data
    for countryId, countryName in pairs(country.name) do
        if type(cntry) == 'string' then
            cntry = cntry:gsub("%s+", "_")
            if tostring(countryName) == string.upper(cntry) then
                newCountry = countryName
            end
        elseif type(cntry) == 'number' then
            if countryId == cntry then
                newCountry = countryName
            end
        end
    end

    if newCountry == '' then
        ctld.logError("Country not found: %s", cntry)
        return false
    end

    local newCat = ''
    for catName, catId in pairs(Unit.Category) do
        if type(groupType) == 'string' then
            if tostring(catName) == string.upper(groupType) then
                newCat = catName
            end
        elseif type(groupType) == 'number' then
            if catId == groupType then
                newCat = catName
            end
        end

        if catName == 'GROUND_UNIT' and (string.upper(groupType) == 'VEHICLE' or string.upper(groupType) == 'GROUND') then
            newCat = 'GROUND_UNIT'
        elseif catName == 'AIRPLANE' and string.upper(groupType) == 'PLANE' then
            newCat = 'AIRPLANE'
        end
    end
    local typeName
    if newCat == 'GROUND_UNIT' then
        typeName = ' gnd '
    elseif newCat == 'AIRPLANE' then
        typeName = ' air '
    elseif newCat == 'HELICOPTER' then
        typeName = ' hel '
    elseif newCat == 'SHIP' then
        typeName = ' shp '
    elseif newCat == 'BUILDING' then
        typeName = ' bld '
    end
    if newGroup.clone or not newGroup.groupId then
        newGroup.groupId = ctld.utils.getNextUniqId()
    end
    if newGroup.groupName or newGroup.name then
        if newGroup.groupName then
            newGroup.name = newGroup.groupName
        elseif newGroup.name then
            newGroup.name = newGroup.name
        end
    else
        newGroup.name = tostring(newCountry) .. "_" .. tostring(typeName) .. "_" .. tostring(newGroup.groupId)
    end

    if not newGroup.hidden then
        newGroup.hidden = false
    end

    if not newGroup.visible then
        newGroup.visible = false
    end

    if (newGroup.start_time and type(newGroup.start_time) ~= 'number') or not newGroup.start_time then
        if newGroup.startTime then
            newGroup.start_time = ctld.utils.round("mist.dynAdd()", newGroup.start_time)
        else
            newGroup.start_time = 0
        end
    end


    for unitIndex, unitData in pairs(newGroup.units) do
        local originalName = newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name
        if newGroup.clone or not unitData.unitId then
            newGroup.units[unitIndex].unitId = ctld.utils.getNextUniqId()
        end
        if newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name then
            if newGroup.units[unitIndex].unitName then
                newGroup.units[unitIndex].name = newGroup.units[unitIndex].unitName
            elseif newGroup.units[unitIndex].name then
                newGroup.units[unitIndex].name = newGroup.units[unitIndex].name
            end
        end
        if not unitData.name then
            newGroup.units[unitIndex].name = tostring(newGroup.name) .. '_unit_' .. tostring(unitIndex)
        end

        if not unitData.skill then
            newGroup.units[unitIndex].skill = 'Random'
        end

        if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
            if newGroup.units[unitIndex].alt_type and newGroup.units[unitIndex].alt_type ~= 'BARO' or not newGroup.units[unitIndex].alt_type then
                newGroup.units[unitIndex].alt_type = 'RADIO'
            end
            if not unitData.speed then
                if newCat == 'AIRPLANE' then
                    newGroup.units[unitIndex].speed = 150
                elseif newCat == 'HELICOPTER' then
                    newGroup.units[unitIndex].speed = 60
                end
            end
            -- if not unitData.payload then
            --     newGroup.units[unitIndex].payload = mist.getPayload(originalName)
            -- end
            if not unitData.alt then
                if newCat == 'AIRPLANE' then
                    newGroup.units[unitIndex].alt = 2000
                    newGroup.units[unitIndex].alt_type = 'RADIO'
                    newGroup.units[unitIndex].speed = 150
                elseif newCat == 'HELICOPTER' then
                    newGroup.units[unitIndex].alt = 500
                    newGroup.units[unitIndex].alt_type = 'RADIO'
                    newGroup.units[unitIndex].speed = 60
                end
            end
        elseif newCat == 'GROUND_UNIT' then
            if nil == unitData.playerCanDrive then
                unitData.playerCanDrive = true
            end
        end
    end
    if newGroup.route then
        if newGroup.route and not newGroup.route.points then
            if newGroup.route[1] then
                local copyRoute = ctld.utils.deepCopy("ctld.utils.dynAdd()", newGroup.route)
                newGroup.route = {}
                newGroup.route.points = copyRoute
            end
        end
    else -- if aircraft and no route assigned. make a quick and stupid route so AI doesnt RTB immediately
        --if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
        newGroup.route = {}
        newGroup.route.points = {}
        newGroup.route.points[1] = {}
        --end
    end
    newGroup.country = newCountry

    -- update and verify any self tasks
    if newGroup.route and newGroup.route.points then
        --ctld.logWarning(newGroup.route.points)
        for i, pData in pairs(newGroup.route.points) do
            if pData.task and pData.task.params and pData.task.params.tasks and #pData.task.params.tasks > 0 then
                for tIndex, tData in pairs(pData.task.params.tasks) do
                    if tData.params and tData.params.action then
                        if tData.params.action.id == "EPLRS" then
                            tData.params.action.params.groupId = newGroup.groupId
                        elseif tData.params.action.id == "ActivateBeacon" or tData.params.action.id == "ActivateICLS" then
                            tData.params.action.params.unitId = newGroup.units[1].unitId
                        end
                    end
                end
            end
        end
    end
    --mist.debug.writeData(mist.utils.serialize,{'msg', newGroup}, newGroup.name ..'.lua')
    --ctld.logWarning(newGroup)
    -- sanitize table
    newGroup.groupName = nil
    newGroup.clone = nil
    newGroup.category = nil
    newGroup.country = nil

    newGroup.tasks = {}

    for unitIndex, unitData in pairs(newGroup.units) do
        newGroup.units[unitIndex].unitName = nil
    end

    ctld.utils.log("TRACE", "ctld.utils.dynAdd newGroup=%s", tostring(newGroup.name))
    coalition.addGroup(country.id[newCountry], Unit.Category[newCat], newGroup)

    return newGroup
end

--------------------------------------------------------------------------------------------------------
--Gets the average position of a group of units (by name)
function ctld.utils.getAvgPos(caller, unitNames)
    if unitNames == nil or #unitNames == 0 then
        if env and env.error then
            env.error("ctld.utils.getAvgPos()." .. tostring(caller) .. ": Invalid unit names provided.")
        end
        return nil
    end

    local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
    for i = 1, #unitNames do
        local unit
        if Unit.getByName(unitNames[i]) then
            unit = Unit.getByName(unitNames[i])
        elseif StaticObject.getByName(unitNames[i]) then
            unit = StaticObject.getByName(unitNames[i])
        end
        if unit and unit:isExist() == true then
            local pos = unit:getPosition().p
            if pos then -- you never know O.o
                avgX = avgX + pos.x
                avgY = avgY + pos.y
                avgZ = avgZ + pos.z
                totNum = totNum + 1
            end
        end
    end
    if totNum ~= 0 then
        return { x = avgX / totNum, y = avgY / totNum, z = avgZ / totNum }
    end
end

--------------------------------------------------------------------------------------------------------
--- Checks if a value exists in an ipairs table.
function ctld.utils.isValueInIpairTable(caller, tab, value)
    if tab == nil or type(tab) ~= "table" then
        if env and env.error then
            env.error("ctld.utils.isValueInIpairTable()." .. tostring(caller) .. ": Invalid table provided.")
        end
        return false
    end
    for i, v in ipairs(tab) do
        if v == value then
            return true -- La valeur existe
        end
    end
    return false -- La valeur n'existe pas
end

--------------------------------------------------------------------------------------------------------
--- Counts the number of entries in a table.
function ctld.utils.countTableEntries(caller, _table)
    if type(_table) ~= "table" then
        if env and env.error then
            env.error("ctld.utils.countTableEntries()." .. tostring(caller) .. ": Invalid table provided.")
        end
        return 0
    end
    if _table == nil then
        return 0
    end

    local _count = 0
    for _key, _value in pairs(_table) do
        _count = _count + 1
    end

    return _count
end

--------------------------------------------------------------------------------------------------------
--- Creates a deep copy of a object.
-- @-- borrowed from mist
-- Usually this object is a table.
-- See also: from http://lua-users.org/wiki/CopyTable
-- @param object object to copy
-- @return copy of object
function ctld.utils.deepCopy(caller, object)
    local lookup_table = {}
    if object == nil then
        if env and env.error then
            env.error("ctld.utils.deepCopy()." .. tostring(caller) .. ": Attempt to deep copy a nil object.")
        end
        return nil
    end
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--------------------------------------------------------------------------------------------------------
--- return table as a lua script string
function ctld.utils.tableShowScript(caller, tblObj, tblName)
    if tblObj == nil then
        if env and env.error then
            env.error("ctld.utils.tableShowScript(): Attempt to show a nil table.")
        end
        return "nil"
    end
    if tblName == nil then
        tblName = "tbl"
    end

    local tScript = "local " .. tblName .. " = " .. ctld.utils.tableShow("ctld.utils.tableShowScript()", tblObj)
    return tScript
end

--------------------------------------------------------------------------------------------------------
--- Returns table in a easy readable string representation.
-- borrowed from mist
-- this function is not meant for serialization because it uses
-- newlines for better readability.
-- @param tbl table to show
-- @param loc
-- @param indent
-- @param tableshow_tbls
-- @return human readable string representation of given table
function ctld.utils.tableShow(caller, tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
    if tbl == nil then
        if env and env.error then
            env.error("ctld.utils.tableShow()." .. tostring(caller) .. ": Attempt to show a nil table.")
        end
        return "nil"
    end

    tableshow_tbls = tableshow_tbls or {} --create table of tables
    loc = loc or ""
    indent = indent or ""
    if type(tbl) == 'table' then --function only works for tables!
        tableshow_tbls[tbl] = loc
        local tbl_str = {}
        --tbl_str[#tbl_str + 1] = indent .. '{\n'
        tbl_str[#tbl_str + 1] = '{\n'

        for ind, val in pairs(tbl) do
            if type(ind) == "number" then
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = tostring(ind)
                tbl_str[#tbl_str + 1] = '] = '
            else
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", ind)
                tbl_str[#tbl_str + 1] = '] = '
            end

            if ((type(val) == 'number') or (type(val) == 'boolean')) then
                tbl_str[#tbl_str + 1] = tostring(val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'string' then
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'nil' then -- won't ever happen, right?
                tbl_str[#tbl_str + 1] = 'nil,\n'
            elseif type(val) == 'table' then
                if tableshow_tbls[val] then
                    tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
                else
                    --tableshow_tbls[val] = loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']'
                    --tbl_str[#tbl_str + 1] = tostring(val) .. ' '
                    --[[
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow(val,
                    loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']',
                    indent .. '    ',
                    tableshow_tbls) ]] --
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow("ctld.utils.tableShow()", val, loc, indent .. '    ')
                    tbl_str[#tbl_str + 1] = ',\n'
                end
            elseif type(val) == 'function' then
                if debug and debug.getinfo then
                    local fcnname = tostring(val)
                    local info = debug.getinfo(val, "S")
                    if info.what == "C" then
                        tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
                    else
                        if (string.sub(info.source, 1, 2) == [[./]]) then
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                fcnname ..
                                ', defined in (' ..
                                info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) .. ',\n'
                        else
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                    fcnname ..
                                    ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..
                                ',\n'
                        end
                    end
                else
                    tbl_str[#tbl_str + 1] = 'a function,\n'
                end
            else
                tbl_str[#tbl_str + 1] = 'unable to serialize value type ' ..
                    ctld.utils.basicSerialize("ctld.utils.tableShow()", type(val)) .. ' at index ' .. tostring(ind)
            end
        end
        --string.sub("Hello, World!", -6, -1)
        if string.sub(table.concat(tbl_str), - #indent - 2, -1) == '{\n' then
            trigger.action.outText(string.sub(table.concat(tbl_str), - #indent - 2, -1), 10)
            for i = 1, #indent do
                tbl_str[#tbl_str] = nil
            end
            tbl_str[#tbl_str + 1] = '{}'
        else
            tbl_str[#tbl_str + 1] = indent .. '}'
        end
        return table.concat(tbl_str)
    end
end

--======================================================================================================
--- Serializes the give variable to a string.
-- borrowed from slmod
-- @param var variable to serialize
-- @treturn string variable serialized to string
function ctld.utils.basicSerialize(caller, var)
    if var == nil then
        if env and env.error then
            env.error("ctld.utils.basicSerialize()." .. tostring(caller) .. ": Attempt to serialize a nil variable.")
        end
        return "nil"
    else
        if ((type(var) == 'number') or
                (type(var) == 'boolean') or
                (type(var) == 'function') or
                (type(var) == 'table') or
                (type(var) == 'userdata')) then
            return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end
end

-- ====================================================================================================
-- SECTION: Shared file logger (EVO-12)
-- Shared across all CTLD modules. ctld.utils.initLog() must be called once during CTLD init.
-- On sanitized DCS (io unavailable) the pcall guard silently falls back to env.info only.
-- Keep ctld.debug=false on standard sanitized DCS installations.
-- ====================================================================================================

local _logFile = nil -- module-local file handle

-- Opens CTLD.log for writing if ctld.debug==true. Safe on sanitized DCS.
-- Always closes any existing handle before opening (allows test harness to reuse the file).
function ctld.utils.initLog()
    if ctld.gs("debug") ~= true then return end
    -- Close any previously open handle (prevents file lock accumulation across test reloads)
    if _logFile ~= nil then
        pcall(function()
            _logFile:flush(); _logFile:close()
        end)
        _logFile = nil
    end
    local path     = ctld.gs("ctldLogPath") or ""
    local filePath = path .. "CTLD.log"
    local ok, _    = pcall(function()
        local f, err = io.open(filePath, "w")
        if f then
            _logFile = f
            _logFile:write(string.format("[CTLD] Log started : %s\n", os.date("%Y-%m-%d %H:%M:%S")))
            _logFile:flush()
        else
            env.info(string.format("[CTLD][WARN] Cannot open log file '%s': %s", filePath, tostring(err)))
        end
    end)
    if not ok then
        env.info("[CTLD][WARN] File logging unavailable (sanitized DCS). Set ctld.debug=false to suppress.")
    end
end

-- Logs a formatted message to env.info and to CTLD.log when debug file is open.
-- @param level  string  "INFO", "WARN", "ERROR", "TRACE"
-- @param fmt    string  format string (string.format style)
-- @param ...           format arguments
function ctld.utils.log(level, fmt, ...)
    local ok, msg = pcall(string.format, "[CTLD][" .. level .. "] " .. fmt, ...)
    if not ok then msg = "[CTLD][" .. level .. "] (log format error)" end
    env.info(msg)
    if not _logFile then
        pcall(ctld.utils.reopenLogAppend)
    end
    if _logFile then
        pcall(function()
            _logFile:write(msg .. "\n")
            _logFile:flush()
        end)
    end
    if ctld.gs("debugScreenLog") == true then
        local duration = ctld.gs("debugScreenLogDuration") or 10
        trigger.action.outText(msg, duration)
    end
end

-- Reopens CTLD.log in append mode (used after closeLog + read to resume logging).
-- File is opened only when config debug=true (ctld.gs("debug")).
function ctld.utils.reopenLogAppend()
    if _logFile ~= nil then return end -- already open
    if ctld.gs("debug") ~= true then return end
    local path     = ctld.gs("ctldLogPath") or ""
    local filePath = path .. "CTLD.log"
    pcall(function()
        local f = io.open(filePath, "a")
        if f then _logFile = f end
    end)
end

-- Flushes and closes CTLD.log.
function ctld.utils.closeLog()
    if _logFile then
        pcall(function()
            _logFile:flush()
            _logFile:close()
        end)
        _logFile = nil
    end
end

-- ====================================================================================================
-- SECTION: Spawn positions on a random axis (used by CTLDCrateManager and CTLDSceneManager)
-- Computes N absolute world positions along a single random axis (full 360° relative to unit heading).
-- Used for:
--   - CTLDCrateManager: pack and virtual unload (crate wave dispersion)
--   - CTLDSceneManager: step.axis positioning (random-axis object placement within a scene)
--
-- @param unit         DCS Unit object (requesting aircraft / scene trigger unit)
-- @param n              Number of positions to compute
-- @param safeDistance   Distance to first position in meters (varies by aircraft size)
-- @param spacing        Inter-position spacing in meters (default: ctld.gs("crateSpacing") or 5)
-- @param axisOffsetDeg  Fixed axis angle in degrees relative to unit heading (nil = random 0-360).
--                       0 = straight ahead (12 o'clock), 180 = straight behind (6 o'clock).
--                       Pass a fixed value to align multiple crates in a predictable line.
-- @return table { positions = {{x,z}, ...}, clock = "1".."12", distance = safeDistance }
--
-- Clock convention: 0° ahead = 12 o'clock, 90° right = 3 o'clock, 180° behind = 6 o'clock.
-- ====================================================================================================

function ctld.utils.getSpawnObjectPositions(unit, n, safeDistance, spacing, axisOffsetDeg)
    n             = n or 1
    spacing       = spacing or (ctld.gs and ctld.gs("crateSpacing")) or 5

    local unitPos = unit:getPoint()
    local unitHdg = ctld.utils.getHeadingInRadians("getSpawnObjectPositions", unit, true)

    -- Use provided axis or pick a random one (single axis for the whole wave)
    if axisOffsetDeg == nil then
        axisOffsetDeg = ctld.utils.RandomReal("getSpawnObjectPositions", 0, 360)
    end

    local positions = {}
    for i = 1, n do
        local dist   = safeDistance + (i - 1) * spacing
        local pt     = ctld.utils.GetRelativeVec2Coords(
            { x = unitPos.x, y = unitPos.z },
            unitHdg,
            dist,
            axisOffsetDeg
        )
        positions[i] = { x = pt.x, z = pt.y }
    end

    -- Clock bearing: axisOffsetDeg (0=12h, 30=1h, ..., 330=11h)
    local clockNum = math.floor(axisOffsetDeg / 30 + 0.5) % 12
    if clockNum == 0 then clockNum = 12 end

    return {
        positions = positions,
        clock     = tostring(clockNum),
        distance  = safeDistance,
    }
end

-- ====================================================================================================
-- SECTION: Unit geometry helper
-- ====================================================================================================

-- Returns the safe spawn distance from a unit's centre (half bounding-box length along X axis).
-- Used to prevent spawned objects from colliding with the requesting aircraft.
-- @param unitName  string  DCS unit name
-- @return number (metres) or nil if unit not found / no bounding box
function ctld.utils.getSecureDistanceFromUnit(unitName)
    local unit = Unit.getByName(unitName)
    if not unit then return nil end
    local ok, box = pcall(function() return unit:getDesc().box end)
    if not ok or not box then return nil end
    return math.max(math.abs(box.max.x), math.abs(box.min.x))
end

--- Returns true if a unit is more than 2 m above ground level.
-- @param unit DCS Unit
-- @return boolean
function ctld.utils.inAir(unit)
    if not unit or not unit.getPoint then return false end
    local pt   = unit:getPoint()
    local gndH = land.getHeight({ x = pt.x, y = pt.z })
    return (pt.y - gndH) > 2.0
end

--- Calculate the ground landing position for a single parachuting object.
-- Accounts for forward inertia (shared direction from transport velocity)
-- plus per-unit lateral random drift.
-- Must be called once per unit at drop time (not deferred).
--
-- @param transport   DCS Unit  transport unit at the moment of drop
-- @param descentRate number    m/s descent rate (positive)
-- @return landPos vec3, descentTime number
--   landPos.y is the MSL ground height at the computed XZ position.
--   descentTime is in seconds.
function ctld.utils.calcDropPosition(transport, descentRate)
    local dropPos     = transport:getPoint()
    local velocity    = transport:getVelocity()
    local groundUnder = land.getHeight({ x = dropPos.x, y = dropPos.z })
    local dropAltAGL  = dropPos.y - groundUnder
    if dropAltAGL < 0 then dropAltAGL = 0 end
    local descentTime   = (descentRate and descentRate > 0) and (dropAltAGL / descentRate) or 0

    local inertiaFactor = ctld.gs and ctld.gs("parachuteInertiaFactor") or 0.3
    local driftMin      = ctld.gs and ctld.gs("parachuteLateralDriftMin") or 10
    local driftMax      = ctld.gs and ctld.gs("parachuteLateralDriftMax") or 80

    local inertiaX      = (velocity.x or 0) * inertiaFactor * descentTime
    local inertiaZ      = (velocity.z or 0) * inertiaFactor * descentTime

    local angle         = math.random(0, 359) * math.pi / 180
    local magnitude     = driftMin + math.random() * (driftMax - driftMin)

    local spawnX        = dropPos.x + inertiaX + math.cos(angle) * magnitude
    local spawnZ        = dropPos.z + inertiaZ + math.sin(angle) * magnitude
    local spawnY        = land.getHeight({ x = spawnX, y = spawnZ })

    return { x = spawnX, y = spawnY, z = spawnZ }, descentTime
end

-- =====================================================================
-- Convenience log shorthands — route through ctld.utils.log.
-- These are used throughout src/ modules (CTLD_menu.lua etc.).
-- =====================================================================

---@param fmt string
---@param ... any
function ctld.logInfo(fmt, ...)
    ctld.utils.log("INFO", fmt, ...)
end

---@param fmt string
---@param ... any
function ctld.logWarning(fmt, ...)
    ctld.utils.log("WARNING", fmt, ...)
end

---@param fmt string
---@param ... any
function ctld.logError(fmt, ...)
    ctld.utils.log("ERROR", fmt, ...)
end

--- Send a text message to a coalition and optionally speak it via STTS.
---@param message     string   Long message (displayed on screen)
---@param displayFor  number   Display duration in seconds
---@param side        number   coalition.side value
---@param radio       table|nil  { freq, mod, volume, name, gender, culture, voice, googleTTS }
---@param shortMessage string|nil  Short version for TTS (falls back to message)
function ctld.utils.notifyCoalition(message, displayFor, side, radio, shortMessage)
    trigger.action.outTextForCoalition(side, message, displayFor)
    local short = shortMessage or message
    if STTS and STTS.TextToSpeech and radio and radio.freq then
        STTS.TextToSpeech(short, radio.freq, radio.mod or "FM", radio.volume or "1.0",
            radio.name or "JTAC", side, nil, 1, radio.gender or "male",
            radio.culture or "en-US", radio.voice, radio.googleTTS or false)
    else
        trigger.action.outSoundForCoalition(side, "radiobeep.ogg")
    end
end

-- End : CTLD_utils.lua
-- ====================================================================================================
-- Start : CTLD_menu.lua
---@diagnostic disable
-- CTLD_menu.lua
-- Menu model and DCS F10 menu manager.
--
-- ARCHITECTURE — two layers:
--
--   ctld.Menu         : Logical tree model for one group's menu.
--                       Callers work exclusively with this model.
--                       The tree is unlimited in memory; pagination is transparent.
--
--   ctld.MenuManager  : Singleton. Owns all ctld.Menu instances (one per groupId).
--                       Handles DCS rendering: wipe + rebuild atomically on refresh().
--
-- ORDER CONVENTION:
--   Every node carries an optional `order` field (number).
--   Siblings are sorted by `order` (ascending) before DCS rendering, regardless of
--   insertion order or manager initialization order.
--   Recommended spacing: 10, 20, 30 … to leave room for future entries.
--   Nodes without an explicit `order` value are appended last (math.huge).
--
--   WHY: each manager calls addSubMenu() independently. Without explicit order,
--   the visual position of a submenu would depend on the manager init sequence —
--   fragile and hard to control. Explicit order makes positions declarative and stable.
--
-- ENABLED CONVENTION:
--   Every node carries an `enabled` field (boolean, default true).
--   Disabled nodes are invisible in DCS but remain in the memory tree.
--   This PRESERVES their ORDER position: re-enabling a node brings it back
--   to the exact same F-key slot it would have occupied if always enabled.
--   Use setBranchEnabled() + refresh() to toggle features at runtime
--   (e.g. a mission trigger unlocks FOB building mid-mission).
--
-- PAGINATION:
--   DCS F10 menus: F1-F10 under programmer control, F11 = Previous Page (DCS),
--   F12 = Quit (DCS). Effective programmer slots per level: 10.
--   Rule applied by _rebuildPagedChildren():
--     - If visible children count <= 10 : render all on one page (no pagination).
--     - If visible children count  > 10 : render 9 in F1-F9,
--                                         F10 = "→ Next Page" submenu (DCS-only, not in memory),
--                                         recurse with remaining items inside that submenu.
--     The last page always receives <= 10 items and needs no "→ Next Page".
--   The "→ Next Page" node NEVER exists in the memory model — it is generated
--   at render time only.
--
-- DYNAMIC REFRESH PATTERN (proximity-based lists):
--   local menu = ctld.MenuManager:getInstance():getMenuByGroupId(groupId)
--   menu:clearBranch({"CTLD Commands", "Pack Vehicles"})  -- empty children, keep container
--   for _, v in ipairs(nearbyVehicles) do
--       menu:addCommand({"CTLD Commands", "Pack Vehicles"}, v.name, packFn, { unitName = v.name })
--   end
--   menu:refresh()   -- wipe DCS + rebuild (paged, ordered) atomically

ctld = ctld or {}

-- =============================================================================
-- ctld.MenuManager — Singleton: owns all group menus, drives DCS rendering
-- =============================================================================

ctld.MenuManager = ctld.MenuManager or {}
ctld.MenuManager._instance = nil

function ctld.MenuManager:getInstance()
    if not self._instance then
        self._instance = self:_new()
    end
    return self._instance
end

function ctld.MenuManager:_new()
    local obj = { menus = {} }
    setmetatable(obj, { __index = ctld.MenuManager })
    return obj
end

-- Create a ctld.Menu for groupId. Idempotent: returns existing menu if already created.
function ctld.MenuManager:createMenuForGroup(groupId)
    if not groupId or type(groupId) ~= "number" then
        ctld.logWarning("ctld.MenuManager:createMenuForGroup: invalid groupId %s", tostring(groupId))
        return nil
    end
    if self.menus[groupId] then
        return self.menus[groupId]
    end
    local menu = ctld.Menu:_new(groupId, self)
    self.menus[groupId] = menu
    ctld.logInfo("ctld.MenuManager:createMenuForGroup: created menu for group %d", groupId)
    return menu
end

-- Wipe the entire DCS menu for groupId, then rebuild from the memory model.
-- ALL-OR-NOTHING: avoids partial / inconsistent DCS menu states.
-- Children are rendered in ORDER-field order (see ORDER CONVENTION above).
function ctld.MenuManager:refreshMenuForGroup(groupId)
    if not self.menus[groupId] then
        ctld.logWarning("ctld.MenuManager:refreshMenuForGroup: no menu for group %s", tostring(groupId))
        return { success = false, message = "Menu not found for group " .. tostring(groupId), refreshedCount = 0 }
    end
    local menu = self.menus[groupId]

    -- Remove only CTLD's own top-level entries — never wipe the whole group menu
    -- (nil path would also destroy standard DCS entries such as Ground Crew / ATC).
    for _, item in ipairs(menu.children) do
        missionCommands.removeItemForGroup(groupId, { item.name })
    end

    local count = 0
    for _, item in ipairs(ctld.MenuManager:_sortByOrder(menu.children)) do
        count = count + ctld.MenuManager:_rebuildMenuNode(groupId, {}, item)
    end

    ctld.logInfo("ctld.MenuManager:refreshMenuForGroup: rebuilt %d items for group %d", count, groupId)
    return { success = true, message = "Menu refreshed: " .. count .. " items", refreshedCount = count }
end

-- Return a copy of `children` sorted by `order` ascending.
-- Nodes without an explicit order are placed last (order = math.huge).
-- Nodes sharing the same order value preserve their insertion order (stable sort).
function ctld.MenuManager:_sortByOrder(children)
    if not children then return {} end
    local sorted = {}
    for _, child in ipairs(children) do table.insert(sorted, child) end
    table.sort(sorted, function(a, b)
        local oa = a.order or math.huge
        local ob = b.order or math.huge
        return oa < ob
    end)
    return sorted
end

-- Recursively render one node into DCS.
-- Disabled nodes (enabled == false) are skipped: invisible in DCS, position preserved in memory.
function ctld.MenuManager:_rebuildMenuNode(groupId, parentPath, node)
    -- Disabled node: skip DCS rendering but preserve memory position.
    if node.enabled == false then return 0 end

    local count  = 0
    local dcsPath = #parentPath > 0 and parentPath or nil

    if node.type == "submenu" then
        missionCommands.addSubMenuForGroup(groupId, node.name, dcsPath)
        count = count + 1
        -- Build the child path for this submenu level.
        local childPath = {}
        for _, p in ipairs(parentPath) do table.insert(childPath, p) end
        table.insert(childPath, node.name)
        -- Sort children by order then paginate into DCS.
        local sorted = ctld.MenuManager:_sortByOrder(node.children)
        ctld.MenuManager:_rebuildPagedChildren(groupId, childPath, sorted)

    elseif node.type == "command" then
        -- Wrap the user callback in pcall to prevent one bad command from crashing the whole menu.
        local fn = node.functionToCall
        local arg = type(node.anyArgument) == "table" and node.anyArgument or {}
        local wrapped = function()
            if fn then
                local ok, err = pcall(fn, arg)
                if not ok then
                    ctld.logError("ctld.MenuManager: callback failed for '%s': %s", node.name, tostring(err))
                end
            end
        end
        missionCommands.addCommandForGroup(groupId, node.name, dcsPath, wrapped, {})
        count = count + 1
    end

    return count
end

-- Paginate and render a pre-sorted list of children at parentPath.
--
-- PAGINATION RULE (see file header for full explanation):
--   visible count <= 10 → render all directly           (last / only page, F1-F10 free)
--   visible count  > 10 → render 9 items in F1-F9,
--                          F10 = "→ Next Page" submenu,
--                          recurse with remaining items inside that submenu.
--
-- The "→ Next Page" DCS submenu is created here only; it does not exist in the memory model.
function ctld.MenuManager:_rebuildPagedChildren(groupId, parentPath, children)
    -- Keep only enabled nodes for DCS rendering.
    local visible = {}
    for _, child in ipairs(children) do
        if child.enabled ~= false then table.insert(visible, child) end
    end

    local PAGE_SIZE = 9   -- F1-F9 for content on intermediate pages
    local dcsPath   = #parentPath > 0 and parentPath or nil

    if #visible <= 10 then
        -- Last (or only) page: all F1-F10 available for content, no "→ Next Page" needed.
        for _, child in ipairs(visible) do
            ctld.MenuManager:_rebuildMenuNode(groupId, parentPath, child)
        end
        return
    end

    -- Intermediate page: render PAGE_SIZE items, then add "→ Next Page" at F10.
    for i = 1, PAGE_SIZE do
        ctld.MenuManager:_rebuildMenuNode(groupId, parentPath, visible[i])
    end

    -- F10 = "→ Next Page" (translated, DCS-only — never in memory model).
    local nextLabel = ctld.tr("→ Next Page")
    missionCommands.addSubMenuForGroup(groupId, nextLabel, dcsPath)

    -- Build path into the "→ Next Page" submenu and recurse with remaining items.
    local nextPath = {}
    for _, p in ipairs(parentPath) do table.insert(nextPath, p) end
    table.insert(nextPath, nextLabel)

    local remaining = {}
    for i = PAGE_SIZE + 1, #visible do table.insert(remaining, visible[i]) end
    ctld.MenuManager:_rebuildPagedChildren(groupId, nextPath, remaining)
end

-- Retrieve group name by iterating all coalitions.
-- Note: Group.getByID() does not exist in the DCS SSE API (only Group.getByName() is documented).
-- Coalition iteration is the only reliable way to resolve groupId → name.
function ctld.MenuManager:_getGroupName(groupId)
    for _, coalId in ipairs({ 0, 1, 2 }) do
        for _, gp in pairs(coalition.getGroups(coalId)) do
            if gp:getID() == groupId then return gp:getName() end
        end
    end
    return "Unknown"
end

-- Lookup helpers
function ctld.MenuManager:getMenuByGroupId(groupId)   return self.menus[groupId] or nil end
function ctld.MenuManager:getMenuByGroupName(groupName)
    for _, menu in pairs(self.menus) do
        if menu.groupName == groupName then return menu end
    end
    return nil
end
function ctld.MenuManager:getMenuByUnitName(unitName)
    local unit = Unit.getByName(unitName)
    if unit then
        local group = unit:getGroup()
        if group then return self:getMenuByGroupId(group:getID()) end
    end
    return nil
end
function ctld.MenuManager:getMenuByUnitId(unitId)
    local unit = Unit.getByID(unitId)
    if unit then
        local group = unit:getGroup()
        if group then return self:getMenuByGroupId(group:getID()) end
    end
    return nil
end

-- =============================================================================
-- ctld.Menu — Logical tree model for one group's F10 menu
-- =============================================================================

ctld.Menu = {}

function ctld.Menu:_new(groupId, manager)
    local obj = {
        groupId    = groupId,
        groupName  = manager:_getGroupName(groupId),
        children   = {},   -- root-level nodes (ordered by `order` field at render time)
        _lookup    = {},   -- path string → node (for fast access)
        manager    = manager,
        nextItemId = 1,
    }
    setmetatable(obj, { __index = ctld.Menu })
    return obj
end

-- Add a submenu node at pathTable / menuName.
--
-- opts (optional table):
--   order   : number  — position among siblings in the DCS menu (ascending).
--             See ORDER CONVENTION at file top. Recommended: multiples of 10.
--             Without this field the node is appended after all ordered siblings.
--   enabled : boolean — initial DCS visibility (default true).
--             false = node reserved in memory but invisible in DCS until
--             setBranchEnabled(path, true) + refresh() is called.
--
-- Idempotent: if the submenu already exists at that path, returns it unchanged.
function ctld.Menu:addSubMenu(pathTable, menuName, opts)
    pathTable = pathTable or {}
    opts      = opts or {}

    if not menuName or type(menuName) ~= "string" then
        ctld.logWarning("ctld.Menu:addSubMenu: invalid menu name")
        return { success = false, message = "Invalid menu name", subMenuId = nil }
    end

    local parent = self:_findOrCreateNode(pathTable)
    if not parent then
        return { success = false, message = "Path not found: " .. self:_pathToString(pathTable), subMenuId = nil }
    end
    if parent.type == "command" then
        return { success = false, message = "Cannot add submenu under a command node", subMenuId = nil }
    end

    -- Idempotent check
    for _, child in ipairs(parent.children or {}) do
        if child.name == menuName and child.type == "submenu" then
            return { success = true, message = "Submenu already exists", subMenuId = child.id }
        end
    end

    local subMenuId = "sub_" .. self.nextItemId
    self.nextItemId = self.nextItemId + 1

    local newNode = {
        id       = subMenuId,
        name     = menuName,
        type     = "submenu",
        children = {},
        -- ORDER: controls position among siblings during DCS render.
        -- Lower values appear higher in the menu (smaller F-key number).
        -- Gaps of 10 allow future insertions without renumbering existing entries.
        order   = opts.order,
        -- ENABLED: false keeps the node in memory (ORDER slot reserved) but
        -- hides it from DCS. Toggle with setBranchEnabled() + refresh().
        enabled = (opts.enabled ~= false),
    }

    if not parent.children then parent.children = {} end
    table.insert(parent.children, newNode)
    self._lookup[self:_buildPathString(pathTable, menuName)] = newNode

    return { success = true, message = "Submenu added", subMenuId = subMenuId }
end

-- Add a command leaf at pathTable / commandName.
-- anyArgument must be a table (or nil → defaults to {}).
function ctld.Menu:addCommand(pathTable, commandName, functionToCall, anyArgument, opts)
    pathTable = pathTable or {}

    if not commandName or type(commandName) ~= "string" then
        ctld.logWarning("ctld.Menu:addCommand: invalid command name")
        return { success = false, message = "Invalid command name", commandId = nil }
    end
    if not functionToCall or type(functionToCall) ~= "function" then
        ctld.logWarning("ctld.Menu:addCommand: invalid function for '%s'", tostring(commandName))
        return { success = false, message = "Invalid function reference", commandId = nil }
    end
    if anyArgument ~= nil and type(anyArgument) ~= "table" then
        ctld.logWarning("ctld.Menu:addCommand: anyArgument must be a table for '%s'", tostring(commandName))
        return { success = false, message = "anyArgument must be a table", commandId = nil }
    end

    local parent = self:_findOrCreateNode(pathTable)
    if not parent then
        return { success = false, message = "Path not found: " .. self:_pathToString(pathTable), commandId = nil }
    end
    if parent.type == "command" then
        return { success = false, message = "Cannot add command under a command node", commandId = nil }
    end

    local commandId = "cmd_" .. self.nextItemId
    self.nextItemId = self.nextItemId + 1

    local newNode = {
        id             = commandId,
        name           = commandName,
        type           = "command",
        functionToCall = functionToCall,
        anyArgument    = anyArgument or {},
        enabled        = true,
        order          = opts and opts.order or nil,
    }

    if not parent.children then parent.children = {} end
    table.insert(parent.children, newNode)
    self._lookup[self:_buildPathString(pathTable, commandName)] = newNode

    return { success = true, message = "Command added", commandId = commandId }
end

-- Empty all children of the node at pathTable WITHOUT removing the node itself.
--
-- Use for dynamic content that must be refreshed (nearby crates, vehicles, etc.):
-- the submenu CONTAINER stays at its ORDER position in its parent, so the
-- F-key slot does not shift when content changes.
--
-- Pattern:
--   menu:clearBranch({"CTLD Commands", "Pack Vehicles"})
--   for _, v in ipairs(nearbyVehicles) do
--       menu:addCommand({"CTLD Commands", "Pack Vehicles"}, v.name, fn, args)
--   end
--   menu:refresh()
function ctld.Menu:clearBranch(pathTable)
    pathTable = pathTable or {}
    local node = self:_getNode(pathTable)
    if not node then
        ctld.logWarning("ctld.Menu:clearBranch: path not found: %s", self:_pathToString(pathTable))
        return { success = false, message = "Path not found" }
    end
    if node.type == "command" then
        return { success = false, message = "Cannot clear a command node" }
    end
    -- Remove child entries from the lookup index.
    self:_cleanupLookup(self:_buildPathString(pathTable, ""))
    -- Wipe children; the node itself remains at its position in its parent's children list.
    node.children = {}
    return { success = true, message = "Branch cleared" }
end

-- Enable or disable the node at pathTable (and its subtree visibility in DCS).
-- The node stays in the memory tree — its ORDER position is preserved.
-- Call refresh() after to apply the change to the live DCS menu.
--
-- Typical use: a mission trigger unlocks a feature mid-mission.
--   menu:setBranchEnabled({"CTLD Commands", "FOB"}, true)
--   menu:refresh()
function ctld.Menu:setBranchEnabled(pathTable, enabled)
    local node = self:_getNode(pathTable)
    if not node then
        ctld.logWarning("ctld.Menu:setBranchEnabled: path not found: %s", self:_pathToString(pathTable))
        return { success = false, message = "Path not found" }
    end
    node.enabled = enabled
    return { success = true }
end

-- Permanently remove the node at pathTable and all its descendants.
-- Frees the ORDER slot in the parent — sibling ORDER values are unaffected but
-- the freed slot will not be visible after the next refresh().
--
-- Prefer clearBranch() for dynamic content and setBranchEnabled() for conditional menus.
-- This method is reserved for truly permanent removals.
function ctld.Menu:removeMenuBranch(pathTable)
    if not pathTable or #pathTable == 0 then
        return { success = false, message = "Cannot remove root menu", removedCount = 0 }
    end

    local parentPath = {}
    for i = 1, #pathTable - 1 do table.insert(parentPath, pathTable[i]) end
    local itemName = pathTable[#pathTable]

    local parent = self:_getNode(parentPath)
    if not parent or not parent.children then
        return { success = false, message = "Path not found: " .. self:_pathToString(pathTable), removedCount = 0 }
    end

    local childIndex = nil
    for i, child in ipairs(parent.children) do
        if child.name == itemName then childIndex = i; break end
    end
    if not childIndex then
        return { success = false, message = "Item not found: " .. itemName, removedCount = 0 }
    end

    local count = self:_countNodeItems(parent.children[childIndex])
    table.remove(parent.children, childIndex)
    self:_cleanupLookup(self:_buildPathString(pathTable, ""))
    return { success = true, message = "Removed branch with " .. count .. " items", removedCount = count }
end

-- Wipe DCS menu + rebuild from memory model (ordered, paged). Convenience shortcut.
function ctld.Menu:refresh()
    return self.manager:refreshMenuForGroup(self.groupId)
end

-- =============================================================================
-- Private helpers
-- =============================================================================

-- Return the node at exactly pathTable, or nil if any segment is missing.
-- Does NOT auto-create nodes.
function ctld.Menu:_getNode(pathTable)
    if not pathTable or #pathTable == 0 then return self end
    local current = self
    for _, segment in ipairs(pathTable) do
        if not current.children then return nil end
        local found = nil
        for _, child in ipairs(current.children) do
            if child.name == segment then found = child; break end
        end
        if not found then return nil end
        current = found
    end
    return current
end

-- Navigate to the node at pathTable, auto-creating missing submenu nodes.
-- Used by addSubMenu / addCommand to ensure intermediate nodes exist.
function ctld.Menu:_findOrCreateNode(pathTable)
    if not pathTable or #pathTable == 0 then return self end
    local current = self
    for _, segment in ipairs(pathTable) do
        if not current.children then current.children = {} end
        local found = nil
        for _, child in ipairs(current.children) do
            if child.name == segment then found = child; break end
        end
        if not found then
            found = { name = segment, type = "submenu", children = {}, enabled = true }
            table.insert(current.children, found)
        end
        current = found
    end
    return current
end

function ctld.Menu:_pathToString(pathTable)
    if not pathTable or #pathTable == 0 then return "/" end
    return table.concat(pathTable, ".")
end

function ctld.Menu:_buildPathString(pathTable, itemName)
    local parts = {}
    for _, p in ipairs(pathTable) do table.insert(parts, p) end
    if itemName and itemName ~= "" then table.insert(parts, itemName) end
    return table.concat(parts, ".")
end

function ctld.Menu:_countNodeItems(node)
    if not node then return 0 end
    local count = 1
    if node.children then
        for _, child in ipairs(node.children) do
            count = count + self:_countNodeItems(child)
        end
    end
    return count
end

function ctld.Menu:_cleanupLookup(pathPrefix)
    for key in pairs(self._lookup) do
        if key:find(pathPrefix, 1, true) == 1 then self._lookup[key] = nil end
    end
end

-- End : CTLD_menu.lua
-- ====================================================================================================
-- Start : lib/CTLD_objectRegistry.lua
---@diagnostic disable
-- CTLD_objectRegistry.lua
-- CTLDObjectRegistry — catalog of enriched DCS object descriptors + spawnObject() factory.
--
-- SCOPE RULE:
--   This registry is NOT a general catalog of all DCS typeNames.
--   It contains only objects that require descriptor enrichment beyond a plain typeName:
--     - STATIC objects with mandatory DCS params  (FARP frequency, helipad callsign, shape_name...)
--     - GROUND groups with multi-unit formation   (guard infantry, circle/linear layouts)
--     - Any object referenced by scene steps      (registryKey field in scene step tables)
--   Standard crate contents (single DCS unit spawned at unpack) bypass this registry
--   and call coalition.addStaticObject / coalition.addGroup directly with the typeName.
--
-- Dynamic registration:
--   Managers may insert entries at INIT time (e.g. CTLDTroopManager._registerTemplates).
--   All entries — static and dynamic — share the same _db table and spawnObject() path.
--
-- Each entry contains only fields specific to the object type; standard fields
-- (name, groupId, unitId, x, z, heading, start_time, transportable, skill)
-- are injected automatically by spawnObject().
--
-- For GROUND groups, intra-unit offsets (dx, dz, dh) are defined per unit
-- in the descriptor and applied by spawnObject() relative to the spawn point
-- and heading. Coordinates passed to spawnObject() are always absolute (world).
--
-- Coalition-aware entries use unitType = function(coalitionId) ... end.
--
-- Dependencies: CTLDUtils (ctld.utils.getNextUniqId, ctld.utils.log)
-- DCS API: coalition.addStaticObject, coalition.addGroup
-- ====================================================================================================

CTLDObjectRegistry = {}

-- ====================================================================================================
-- Internal DB
-- ====================================================================================================

CTLDObjectRegistry._db = {

    -- ------------------------------------------------------------------
    -- HELIPORTS
    -- ------------------------------------------------------------------
    ["FARP"] = {
        groupType            = "STATIC",
        namePrefix           = "FARP",
        type                 = "FARP",
        category             = "Heliports",
        shape_name           = "FARPS",
        heliport_frequency   = "127.5",
        heliport_callsign_id = 1,
        heliport_modulation  = 0,
    },

    ["SINGLE_HELIPAD"] = {
        groupType            = "STATIC",
        namePrefix           = "SINGLE_HELIPAD",
        type                 = "SINGLE_HELIPAD",
        category             = "Heliports",
        shape_name           = "FARP",
        heliport_frequency   = "127.5",
        heliport_callsign_id = 1,
        heliport_modulation  = 0,
    },

    ["Farp_FG_Petit_Helipad"] = {  -- specific mod
        groupType            = "STATIC",
        namePrefix           = "FARP_Helipad",
        type                 = "Farp_FG_Petit_Helipad",
        category             = "Heliports",
        shape_name           = "Farp_FG_Petit_Helipad.edm",
        heliport_frequency   = "127.5",
        heliport_callsign_id = 1,
        heliport_modulation  = 0,
    },

    -- ------------------------------------------------------------------
    -- FORTIFICATIONS
    -- ------------------------------------------------------------------
    ["FARP_Tent"] = {
        groupType  = "STATIC",
        namePrefix = "FARP_Tent",
        type       = "FARP Tent",
        category   = "Fortifications",
    },

    ["FARP_Ammo_Storage"] = {
        groupType  = "STATIC",
        namePrefix = "FARP_Ammo_Storage",
        type       = "FARP Ammo Dump Coating",
        category   = "Fortifications",
    },

    ["Tower Crane"] = {
        groupType  = "STATIC",
        namePrefix = "TowerCrane",
        type       = "Tower Crane",
        category   = "Fortifications",
        shape_name = "TowerCrane_01",
        rate       = 100,
    },

    ["NF-2_LightOn"] = {
        groupType  = "STATIC",
        namePrefix = "LightOn",
        type       = "NF-2_LightOn",
        category   = "Fortifications",
        shape_name = "M92_NF-2_LightOn",
        rate       = 100,
    },

    ["Windsock"] = {
        groupType  = "STATIC",
        namePrefix = "Windsock",
        type       = "Windsock",
        category   = "Fortifications",
        shape_name = "H-Windsock_RW",
        rate       = 3,
    },

    ["Landmine"] = {
        groupType  = "STATIC",
        namePrefix = "Mine",
        type       = "Landmine",
        category   = "Fortifications",
    },

    -- FOB components (used as scene steps by CTLDFOBManager)
    ["FOB_container"] = {
        groupType  = "STATIC",
        namePrefix = "FOB_Outpost",
        type       = "outpost",
        category   = "Fortifications",
        canCargo   = false,
    },

    ["FOB_watchtower"] = {
        groupType  = "STATIC",
        namePrefix = "FOB_Watchtower",
        type       = "house2arm",
        category   = "Fortifications",
        canCargo   = false,
        rate       = 100,
    },

    -- ------------------------------------------------------------------
    -- CARGOS
    -- ------------------------------------------------------------------
    ["barrels_cargo"] = {
        groupType  = "STATIC",
        namePrefix = "barrels_cargo",
        type       = "barrels_cargo",
        category   = "Cargos",
        shape_name = "barrels_cargo",
        rate       = 100,
    },

    ["ammo_cargo"] = {
        groupType  = "STATIC",
        namePrefix = "ammo_box_cargo",
        type       = "ammo_cargo",
        category   = "Cargos",
        shape_name = "ammo_box_cargo",
        rate       = 1,
    },

    ["Cargo06"] = {
        groupType  = "STATIC",
        namePrefix = "ammo_box06",
        type       = "Cargo06",
        category   = "Cargos",
        shape_name = "M92_Cargo06",
        rate       = 1,
    },

    -- ------------------------------------------------------------------
    -- PERSONNEL
    -- ------------------------------------------------------------------
    ["us carrier shooter"] = {
        groupType  = "STATIC",
        namePrefix = "carrier_shooter",
        type       = "us carrier shooter",
        category   = "Personnel",
        shape_name = "carrier_shooter",
        livery_id  = "blue",
        rate       = 20,
    },

    -- ------------------------------------------------------------------
    -- GROUND UNITS (coalition-aware)
    -- ------------------------------------------------------------------
    ["Fuel_Truck"] = {
        groupType  = "GROUND",
        namePrefix = "Fuel_Truck_Grp",
        task       = "Ground Nothing",
        category   = Unit.Category.GROUND_UNIT,
        units = {
            {
                namePrefix     = "Fuel_Truck_Unit",
                unitType       = function(cid)
                    return cid == coalition.side.RED and "ATZ-10" or "M978 HEMTT Tanker"
                end,
                playerCanDrive = false,
                dx = 0, dz = 0, dh = 0,
            },
        },
    },

    ["repare_Truck"] = {
        groupType  = "GROUND",
        namePrefix = "repare_Truck_Grp",
        task       = "Ground Nothing",
        category   = Unit.Category.GROUND_UNIT,
        units = {
            {
                namePrefix     = "repare_Truck_Unit",
                unitType       = function(cid)
                    return cid == coalition.side.RED and "Ural-375" or "M 818"
                end,
                playerCanDrive = false,
                dx = 0, dz = 0, dh = 0,
            },
        },
    },

    ["FARP_Security_Guard"] = {
        groupType  = "GROUND",
        namePrefix = "FARP_Guard_Grp",
        task       = "Ground Nothing",
        category   = Unit.Category.GROUND_UNIT,
        units = {
            {
                namePrefix     = "Guard_Infantry",
                unitType       = function(cid)
                    return cid == coalition.side.RED and "Infantry AK" or "Soldier M4"
                end,
                playerCanDrive = false,
                dx = 0, dz = 0, dh = 0,
            },
            {
                namePrefix     = "Guard_Infantry",
                unitType       = function(cid)
                    return cid == coalition.side.RED and "Infantry AK" or "Soldier M4"
                end,
                playerCanDrive = false,
                dx = 3, dz = 1, dh = 0.610865,
            },
            {
                namePrefix     = "Guard_Infantry",
                unitType       = function(cid)
                    return cid == coalition.side.RED and "Infantry AK" or "Soldier M4"
                end,
                playerCanDrive = false,
                dx = 6, dz = 0, dh = 3.49066,
            },
        },
    },
}

-- ====================================================================================================
-- Public API
-- ====================================================================================================

-- Returns a descriptor from the DB, or nil if not found.
function CTLDObjectRegistry.get(objectKey)
    return CTLDObjectRegistry._db[objectKey]
end

--- Reverse lookup: find the registry key and descriptor whose `type` field
--- matches dcsTypeName (the DCS typeName of a static/cargo object).
--- Used by CTLDCrateManager:registerMMCrate() for MM crate detection (INIT-B).
--- @param dcsTypeName string   e.g. "ammo_cargo", "Cargo06"
--- @return string|nil key, table|nil descriptor
function CTLDObjectRegistry.findByDCSType(dcsTypeName)
    if not dcsTypeName then return nil, nil end
    for key, desc in pairs(CTLDObjectRegistry._db) do
        if desc.type == dcsTypeName then
            return key, desc
        end
    end
    return nil, nil
end

-- Spawns a DCS object described by objectKey at absolute world position (x, z).
--
-- @param objectKey   string    Key in CTLDObjectRegistry._db
-- @param coalitionId number    coalition.side.BLUE or coalition.side.RED
-- @param countryId   number    DCS country id
-- @param x           number    World X coordinate (North axis)
-- @param z           number    World Z coordinate (East axis)
-- @param headingRad  number    Heading in radians (0 = North). Default 0.
-- @param overrides   table|nil Fields merged over injected values (optional)
--
-- @return DCS object handle (StaticObject or Group), or nil on failure.
--
-- For GROUND groups, units[i].dx/dz/dh offsets in the descriptor are rotated
-- by headingRad and added to (x, z) to compute each unit's absolute position.
function CTLDObjectRegistry.spawnObject(objectKey, coalitionId, countryId, x, z, headingRad, overrides)
    local desc = CTLDObjectRegistry._db[objectKey]
    if not desc then
        ctld.utils.log("WARN", "spawnObject: unknown objectKey '%s'", tostring(objectKey))
        return nil
    end

    headingRad = headingRad or 0
    overrides  = overrides  or {}

    -- ----------------------------------------------------------------
    -- STATIC objects
    -- ----------------------------------------------------------------
    if desc.groupType == "STATIC" then
        local uid  = ctld.utils.getNextUniqId()
        local name = string.format("%s-%d", desc.namePrefix, uid)

        -- Build groupData: start with descriptor fields, inject standard fields
        local groupData = {}
        for k, v in pairs(desc) do
            if k ~= "groupType" and k ~= "namePrefix" then
                groupData[k] = v
            end
        end
        -- Standard injected fields
        groupData.name          = name
        groupData.x             = x
        groupData.y             = z   -- DCS static uses y = world Z
        groupData.heading       = headingRad
        groupData.start_time    = 0
        groupData.transportable = { randomTransportable = false }
        -- Caller overrides
        for k, v in pairs(overrides) do groupData[k] = v end

        local ok, result = pcall(coalition.addStaticObject, countryId, groupData)
        if not ok then
            ctld.utils.log("ERROR", "spawnObject: coalition.addStaticObject failed for '%s': %s",
                objectKey, tostring(result))
            return nil
        end
        ctld.utils.log("INFO", "spawnObject: STATIC '%s' spawned at (%.1f, %.1f)", name, x, z)
        return result

    -- ----------------------------------------------------------------
    -- GROUND groups
    -- ----------------------------------------------------------------
    elseif desc.groupType == "GROUND" then
        local gid       = ctld.utils.getNextUniqId()
        local groupName = string.format("%s-%d", desc.namePrefix, gid)
        local cosH      = math.cos(headingRad)
        local sinH      = math.sin(headingRad)

        -- Circle formation: offsets computed dynamically from overrides.circleRadius.
        -- Linear formation: offsets come from uDesc.dx / uDesc.dz (static per descriptor).
        local useCircle  = desc.formation and desc.formation.type == "circle"
        local circleR    = (overrides and overrides.circleRadius) or 10
        local unitCount  = #desc.units

        local units = {}
        for i, uDesc in ipairs(desc.units) do
            local uid      = ctld.utils.getNextUniqId()
            local uName    = string.format("%s-%d", uDesc.namePrefix, uid)
            local uType    = type(uDesc.unitType) == "function"
                             and uDesc.unitType(coalitionId)
                             or  uDesc.unitType
            -- Compute intra-group offset (circle or static dx/dz), then rotate by heading
            local dx, dz
            if useCircle then
                local angle = (i - 1) * (2 * math.pi / unitCount)
                dx = circleR * math.cos(angle)
                dz = circleR * math.sin(angle)
            else
                dx = uDesc.dx or 0
                dz = uDesc.dz or 0
            end
            local ux = x + dx * cosH - dz * sinH
            local uz = z + dx * sinH + dz * cosH

            local unit = {
                name           = uName,
                type           = uType,
                x              = ux,
                y              = uz,  -- DCS ground unit uses y = world Z
                heading        = headingRad + (uDesc.dh or 0),
                skill          = "High",
                playerCanDrive = uDesc.playerCanDrive or false,
                transportable  = { randomTransportable = false },
                unitId         = uid,
            }
            -- Unit-level overrides
            if overrides.units and overrides.units[i] then
                for k, v in pairs(overrides.units[i]) do unit[k] = v end
            end
            units[i] = unit
        end

        local groupData = {
            name       = groupName,
            task       = desc.task or "Ground Nothing",
            start_time = 0,
            groupId    = gid,
            visible    = false,
            hidden     = false,
            units      = units,
        }
        -- Group-level overrides (excluding units table)
        for k, v in pairs(overrides) do
            if k ~= "units" then groupData[k] = v end
        end

        local ok, result = pcall(coalition.addGroup, countryId, desc.category, groupData)
        if not ok then
            ctld.utils.log("ERROR", "spawnObject: coalition.addGroup failed for '%s': %s",
                objectKey, tostring(result))
            return nil
        end
        ctld.utils.log("INFO", "spawnObject: GROUND '%s' spawned at (%.1f, %.1f)", groupName, x, z)
        return result

    else
        ctld.utils.log("WARN", "spawnObject: unknown groupType '%s' for key '%s'",
            tostring(desc.groupType), tostring(objectKey))
        return nil
    end
end

-- End : lib/CTLD_objectRegistry.lua
-- ====================================================================================================
-- Start : lib/CTLDParachuteEffect.lua
-- ============================================================
-- CTLDParachuteEffect.lua
-- Abstract interface + null implementation for virtual parachute side effects.
--
-- Allows mission makers / mods to hook into parachute drop events
-- for visual effects (smoke, markers, animations) without touching
-- core physics logic.
--
-- Usage:
--   manager:setParachuteEffect(CTLDNullParachuteEffect:new())
--   -- or any custom subclass:
--   manager:setParachuteEffect(MyVisualEffect:new())
--
-- dropData payload (passed to all hooks):
--   type          "crate" | "troop" | "vehicle"
--   unitName      string              name of dropped unit / group
--   dropPosition  {x,y,z}            transport position at drop time
--   landPositions {{x,y,z}, ...}     computed ground positions (1 per unit)
--   altitude      number             AGL at drop time (m)
--   descentTime   number             descent duration (s)
--   transport     Unit               DCS transport unit
--   player        string or nil      player name if applicable
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDParachuteEffect  (abstract base)
-- ============================================================

CTLDParachuteEffect = class()

--- Called when the parachute drop is initiated (cargo leaves the transport).
-- @param dropData table
function CTLDParachuteEffect:onStart(dropData)  end  -- luacheck: ignore

--- Called once per second during the descent.
-- @param dropData table
function CTLDParachuteEffect:onTick(dropData)   end  -- luacheck: ignore

--- Called when the cargo has landed (spawn at ground position done).
-- @param dropData table
function CTLDParachuteEffect:onLanded(dropData) end  -- luacheck: ignore

-- ============================================================
-- CTLDNullParachuteEffect  (default no-op implementation)
-- ============================================================

CTLDNullParachuteEffect = class(CTLDParachuteEffect)
-- Inherits all three no-ops — zero overhead, safe default.

-- End : lib/CTLDParachuteEffect.lua
-- ====================================================================================================
-- Start : CTLD_sceneManager.lua
---@diagnostic disable
-- CTLD_sceneManager.lua
-- CTLDSceneManager singleton — scene model registry + sequential execution engine.
-- CtldScene      — executes one scene instance step by step.
--
-- Step types (fields in each step table):
--   polar  : { polar={distance, angle}, relativeHeadingInDegrees, relativeAltitudeInMeters,
--              registryKey [, func] }
--              Deterministic position relative to the trigger unit's snapshot position.
--   axis   : { axis={count, safeDistance, spacing}, registryKey [, func] }
--              Random single axis around the unit; N objects spread along it.
--   func   : { func=function(unit, spawnedObj, step) ... end }
--              No spawn; only executes the function.
--
-- All steps carry delayAfterPreviousStep (seconds).  After executing step N,
-- the engine waits that many seconds before starting step N+1.  The same field
-- is also used before step 1 (initial delay from mission start / scene trigger).
--
-- Dependencies: CTLDUtils, CTLDObjectRegistry
-- DCS API: timer.getTime, timer.scheduleFunction, Unit.*, Airbase.*,
--          trigger.action.outText
-- ====================================================================================================

-- ====================================================================================================
-- CtldScene
-- ====================================================================================================

CtldScene = class()

local _sceneCounter = 0

-- Creates and immediately starts a new scene instance.
-- @param unit   DCS Unit object (trigger unit — position/heading snapshot is taken here)
-- @param model  table { name=string, steps={...} }
-- @return CtldScene
-- @param unit        DCS Unit — trigger unit; position/heading snapshot taken here
-- @param model       table    — scene model (name + steps)
-- @param params      table    — optional key/value bag passed to step funcs via ctx.scene._params
-- @param onComplete  function — optional callback called with (scene) when last step finishes
function CtldScene:init(unit, model, params, onComplete)
    _sceneCounter  = _sceneCounter + 1
    self._name     = string.format("%s#%d", model.name, _sceneCounter)
    self._unit     = unit
    self._steps    = model.steps
    self._stepIndex   = 0
    self._timeMarker  = 0
    self._spawnedObjs = {}
    self._params      = params     or {}
    self._onComplete  = onComplete or nil

    -- Cache coalition/country at init so steps work even if the unit leaves mid-scene.
    self._coalitionId = unit:getCoalition()
    self._countryId   = unit:getCountry()

    -- Snapshot reference position and heading at creation time.
    -- All step positions are computed relative to this snapshot (unit may have moved).
    -- A prescript func may override _refX/_refZ/_refAlt via ctx.scene before the first spawn step.
    local pt        = unit:getPoint()
    self._refX      = pt.x          -- world North axis
    self._refZ      = pt.z          -- world East axis
    self._refAlt    = pt.y          -- altitude (metres)
    self._refHdgRad = ctld.utils.getHeadingInRadians("CtldScene", unit, true)

    -- Magnetic declination is constant for the whole scene (computed once at reference point).
    self._magDecDeg = math.deg(
        ctld.utils.getNorthCorrectionInRadians("CtldScene", { x = self._refX, y = self._refZ })
    )
end

-- Schedules the first step.
function CtldScene:_execute()
    local firstDelay = tonumber(self._steps[1].delayAfterPreviousStep) or 0
    self._timeMarker = timer.getTime() + firstDelay
    if self._timeMarker > timer.getTime() then
        local fn = function() self:_runNextStep() end
        timer.scheduleFunction(fn, nil, self._timeMarker)
    else
        self:_runNextStep()
    end
end

-- Executes the current step then schedules the next one.
function CtldScene:_runNextStep()
    self._stepIndex = self._stepIndex + 1
    local step = self._steps[self._stepIndex]
    if not step then
        ctld.utils.log("WARN", "CtldScene '%s': no step at index %d", self._name, self._stepIndex)
        return
    end

    local coalitionId = self._coalitionId
    local countryId   = self._countryId
    local spawnedObj  = nil

    -- -----------------------------------------------------------------------
    -- Spawn phase (skipped for func-only steps)
    -- -----------------------------------------------------------------------
    if step.registryKey then
        local desc = CTLDObjectRegistry.get(step.registryKey)

        -- Auto-inject circleRadius when the descriptor uses circle formation.
        local overrides = {}
        if desc and desc.formation and desc.formation.type == "circle" then
            local safeR = ctld.utils.getSecureDistanceFromUnit(self._unit:getName()) or 10
            overrides.circleRadius = safeR + (ctld.gs("spawnDistanceInCircle") or 10)
        end

        if step.polar then
            -- Polar step: deterministic world position derived from the snapshot.
            local spawnX, spawnEast, spawnHdgDeg = ctld.utils.getRelativeCoords(
                self._refX, self._refZ, self._refHdgRad, self._refAlt,
                step.polar.angle    or 0,
                step.polar.distance or 0,
                step.relativeHeadingInDegrees or 0,
                step.relativeAltitudeInMeters or 0,
                self._magDecDeg
            )
            spawnedObj = CTLDObjectRegistry.spawnObject(
                step.registryKey, coalitionId, countryId,
                spawnX, spawnEast, math.rad(spawnHdgDeg), overrides
            )
            if spawnedObj then
                self._spawnedObjs[#self._spawnedObjs + 1] = spawnedObj
            end

        elseif step.axis then
            -- Axis step: random single axis; N objects distributed along it.
            local count    = step.axis.count       or 1
            local safeDist = step.axis.safeDistance
                          or ctld.utils.getSecureDistanceFromUnit(self._unit:getName())
                          or 20
            local spacing  = step.axis.spacing or (ctld.gs("crateSpacing") or 5)
            local result   = ctld.utils.getSpawnObjectPositions(self._unit, count, safeDist, spacing)
            for _, pos in ipairs(result.positions) do
                local obj = CTLDObjectRegistry.spawnObject(
                    step.registryKey, coalitionId, countryId,
                    pos.x, pos.z, 0, overrides
                )
                if obj then
                    self._spawnedObjs[#self._spawnedObjs + 1] = obj
                    spawnedObj = obj   -- pass the last spawned object to func
                end
            end
        end
    end

    -- -----------------------------------------------------------------------
    -- Optional func — receives a named context table (ctx).
    -- ctx.unit       : DCS Unit (trigger unit)
    -- ctx.spawnedObj : last object spawned in this step (nil for func-only steps)
    -- ctx.step       : current step table
    -- ctx.scene      : this CtldScene instance (read/write _refX/_refZ/_refAlt, _params, etc.)
    -- -----------------------------------------------------------------------
    if step.func then
        local ctx = {
            unit       = self._unit,
            spawnedObj = spawnedObj,
            step       = step,
            scene      = self,
        }
        local ok, err = pcall(step.func, ctx)
        if not ok then
            ctld.utils.log("ERROR", "CtldScene '%s' step %d func error: %s",
                self._name, self._stepIndex, tostring(err))
        end
    end

    -- -----------------------------------------------------------------------
    -- Schedule next step, or fire onComplete when the last step finishes.
    -- -----------------------------------------------------------------------
    if self._steps[self._stepIndex + 1] then
        self._timeMarker = self._timeMarker + (tonumber(step.delayAfterPreviousStep) or 0)
        if self._timeMarker > timer.getTime() then
            local fn = function() self:_runNextStep() end
            timer.scheduleFunction(fn, nil, self._timeMarker)
        else
            self:_runNextStep()
        end
    else
        ctld.utils.log("INFO", "CtldScene '%s': completed (%d steps)", self._name, self._stepIndex)
        if self._onComplete then
            local ok, err = pcall(self._onComplete, self)
            if not ok then
                ctld.utils.log("ERROR", "CtldScene '%s' onComplete error: %s",
                    self._name, tostring(err))
            end
        end
    end
end

-- ====================================================================================================
-- CTLDSceneManager
-- ====================================================================================================

CTLDSceneManager = class()

local _smInstance = nil

function CTLDSceneManager.getInstance()
    if not _smInstance then
        _smInstance = setmetatable({}, CTLDSceneManager)
        _smInstance:_init()
    end
    return _smInstance
end

function CTLDSceneManager:_init()
    self._models = {}   -- model name → model table
    self._active = {}   -- scene name  → CtldScene instance
    self:_registerBuiltins()
    local n = 0
    for _ in pairs(self._models) do n = n + 1 end
    ctld.utils.log("INFO", "CTLDSceneManager: initialized (%d built-in scene(s))", n)
end

-- Registers a scene model.  Returns true on success.
-- External files (e.g. CTLD_mineFieldScene.lua) call this at load time.
-- @param model  table  { name=string, steps={...} }
function CTLDSceneManager:registerSceneModel(model)
    if not model or not model.name or model.name == "" then
        ctld.utils.log("WARN", "CTLDSceneManager:registerSceneModel: model missing 'name' field")
        return false
    end
    if self._models[model.name] then
        ctld.utils.log("WARN", "CTLDSceneManager:registerSceneModel: '%s' already registered", model.name)
        return false
    end
    self._models[model.name] = model
    ctld.utils.log("INFO", "CTLDSceneManager: registered scene model '%s'", model.name)
    return true
end

-- Starts a named scene triggered by a DCS unit.
-- @param unit        DCS Unit object
-- @param modelName   string    key in _models
-- @param params      table     optional key/value bag forwarded to step funcs via ctx.scene._params
-- @param onComplete  function  optional callback(scene) fired when the last step finishes
-- @return CtldScene instance, or nil on error
function CTLDSceneManager:playScene(unit, modelName, params, onComplete)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDSceneManager:playScene: unit is nil or dead")
        return nil
    end
    local model = self._models[modelName]
    if not model then
        ctld.utils.log("WARN", "CTLDSceneManager:playScene: unknown model '%s'", tostring(modelName))
        return nil
    end
    local scene = CtldScene:new(unit, model, params, onComplete)
    self._active[scene._name] = scene
    scene:_execute()
    ctld.utils.log("INFO", "CTLDSceneManager: started scene '%s' for unit '%s'",
        scene._name, unit:getName())
    return scene
end

-- Returns a registered model table by name, or nil.
function CTLDSceneManager:getModel(name)
    return self._models[name]
end

-- ====================================================================================================
-- Built-in scene registration
-- ====================================================================================================

function CTLDSceneManager:_registerBuiltins()
    self:registerSceneModel(CTLDSceneManager._FARP_ALPHA_SCENE)
    -- FOB scene is defined in scenes/CTLD_fobScene.lua (self-registering)
end

-- ====================================================================================================
-- Built-in scene: FARP Alpha
-- Migrated from source_scene_ini/farpSceneDatas.lua.
-- 13 object steps + 1 completion func.
-- ====================================================================================================

CTLDSceneManager._FARP_ALPHA_SCENE = {
    name  = "FARP Alpha",
    steps = {

        -- Step 1: FARP helipad (STATIC) — warehouse stocked with all fuel types after spawn.
        {
            polar                    = { distance = 100, angle = 0 },
            delayAfterPreviousStep   = 0,
            relativeHeadingInDegrees = 180,
            relativeAltitudeInMeters = 0,
            registryKey         = "SINGLE_HELIPAD",
            func = function(ctx)
                if not ctx.spawnedObj then return false end
                local ab = Airbase.getByName(ctx.spawnedObj:getName())
                if ab then
                    local w = ab:getWarehouse()
                    w:addLiquid(0, 10000)   -- jet fuel
                    w:addLiquid(1, 10000)   -- aviation gasoline
                    w:addLiquid(2, 10000)   -- MW50
                    w:addLiquid(3, 10000)   -- diesel
                end
                return true
            end,
        },

        -- Step 2: Command tent (STATIC)
        {
            polar                    = { distance = 130, angle = 5 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 90,
            relativeAltitudeInMeters = 0,
            registryKey         = "FARP_Tent",
        },

        -- Step 3: Ammo storage (STATIC)
        {
            polar                    = { distance = 110, angle = 340 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "FARP_Ammo_Storage",
        },

        -- Step 4a: Fuel truck (GROUND)
        {
            polar                    = { distance = 110, angle = 15 },
            delayAfterPreviousStep   = 5,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "Fuel_Truck",
        },

        -- Step 4b: Repair truck (GROUND)
        {
            polar                    = { distance = 125, angle = 15 },
            delayAfterPreviousStep   = 5,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "repare_Truck",
        },

        -- Step 5: Security guard group (GROUND)
        {
            polar                    = { distance = 90, angle = 15 },
            delayAfterPreviousStep   = 0,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "FARP_Security_Guard",
        },

        -- Step 6a: Barrels (STATIC)
        {
            polar                    = { distance = 100, angle = 350 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "barrels_cargo",
        },

        -- Step 6b1: Cargo box (STATIC)
        {
            polar                    = { distance = 95, angle = 349 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "Cargo06",
        },

        -- Step 6b2: Ammo cargo (STATIC)
        {
            polar                    = { distance = 105, angle = 351.2 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 0,
            relativeAltitudeInMeters = 0,
            registryKey         = "ammo_cargo",
        },

        -- Step 6c: Ammo cargo 2 (STATIC)
        {
            polar                    = { distance = 106.5, angle = 351.3 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 5,
            relativeAltitudeInMeters = 0,
            registryKey         = "ammo_cargo",
        },

        -- Step 6d: Carrier shooter static (STATIC)
        {
            polar                    = { distance = 115, angle = 5 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 220,
            relativeAltitudeInMeters = 0,
            registryKey         = "us carrier shooter",
        },

        -- Step 6e: Light panel (STATIC)
        {
            polar                    = { distance = 116.7, angle = 353 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 220,
            relativeAltitudeInMeters = 0,
            registryKey         = "NF-2_LightOn",
        },

        -- Step 6f: Windsock (STATIC)
        {
            polar                    = { distance = 80, angle = 10 },
            delayAfterPreviousStep   = 3,
            relativeHeadingInDegrees = 220,
            relativeAltitudeInMeters = 0,
            registryKey         = "Windsock",
        },

        -- Step 7: Completion message (func-only)
        {
            delayAfterPreviousStep = 0,
            func = function(ctx)
                trigger.action.outText(
                    ctld.tr("--- FARP Dynamic Deployment by %1 : Complete! ---", ctx.unit:getName()), 10)
                return true
            end,
        },
    },
}


-- End : CTLD_sceneManager.lua
-- ====================================================================================================
-- Start : CTLD_zone.lua
-- ============================================================
-- CTLD_zone.lua
-- CTLDTroopZone + CTLDLogisticZone entities + CTLDZoneManager singleton
--
-- Dependencies : class (lib/class.lua), CTLDUtils (ctld.utils),
--                CTLDConfig (ctld.gs), EventDispatcher
-- DCS API      : env.mission.triggers.zones, trigger.misc.getZone,
--                trigger.action.smoke, trigger.action.setUserFlag,
--                trigger.misc.getUserFlag, land.getHeight,
--                Unit.getByName, StaticObject.getByName
--
-- Zone naming conventions:
--
--   TRZ  (TroopZone) — troops pickup / extract / mixed
--     TRZ_<name>_<A|R|B|N>_<stock>_<flag>_<target>   (all 5 fields required)
--     stock  : 0=no pickup, 1-998=limited, 999=unlimited
--     flag   : DCS flag name (string) or reserved word "nil"
--     target : 0=no win condition, N≥1=soldier threshold
--
--   LGZ  (LogisticZone) — crate/vehicle services
--     LGZ_name_[R|B|N]
--
-- Legacy fallback: missions using the old PKZ/IAZ/WPZ/EXZ prefix
-- or the ctld.gs config tables (pickupZones, dropOffZones, wpZones,
-- logisticUnits) are loaded after TRZ/LGZ discovery; existing entries
-- are never overwritten.
--
-- Events published:
--   OnZoneSmokeRefreshed  — every smokeRefreshInterval seconds
--   OnLogisticZoneUpdated — at init + on dynamic unit death
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDTroopZone  (entity)
-- ============================================================

CTLDTroopZone = class()

--- Constructor.
-- @param data table
--   Required : dcsName, zoneName, coalition, center (vec3), radius
--   Optional : verticies, pickMaxStock, objectiveFlag, objectiveTarget,
--              smoke (trigger.smokeColor.* or -1), active,
--              isWaypoint (bool), isDropoff (bool)
function CTLDTroopZone:init(data)
    self.dcsName          = data.dcsName
    self.zoneName         = data.zoneName
    self.coalition        = data.coalition  or 0
    self.center           = data.center
    self.radius           = data.radius     or 0
    self.verticies        = data.verticies  or nil

    -- Pickup stock (nil = this zone has no pickup function)
    self.pickMaxStock     = data.pickMaxStock    -- nil | number  (0 = unlimited)
    self.pickCurrentStock = (data.pickMaxStock ~= nil and data.pickMaxStock ~= 0)
                            and data.pickMaxStock or 0

    -- Extract objective (nil = this zone has no extract function)
    self.objectiveFlag    = data.objectiveFlag   -- nil | string
    self.objectiveTarget  = data.objectiveTarget -- nil | number

    -- WPZ: troops deployed inside march to zone center
    self.isWaypoint = data.isWaypoint or false
    -- IAZ: AI transport landing here auto-deploys its troops
    self.isDropoff  = data.isDropoff  or false

    self.smoke  = (data.smoke ~= nil) and data.smoke or -1
    self.active = (data.active ~= nil) and data.active or true
end

--- True if this zone acts as a pickup zone (troops can board here).
function CTLDTroopZone:hasPickup()
    return self.pickMaxStock ~= nil
end

--- True if this zone acts as an extract / objective zone.
function CTLDTroopZone:hasExtract()
    return self.objectiveFlag ~= nil
end

--- True if this zone redirects deployed troops toward its center (WPZ).
function CTLDTroopZone:hasWaypoint()
    return self.isWaypoint == true
end

--- True if this zone is an AI auto-drop point (IAZ).
function CTLDTroopZone:hasDropoff()
    return self.isDropoff == true
end

--- True if point is inside the zone (circular or polygonal).
function CTLDTroopZone:isInZone(point)
    if self.verticies and #self.verticies >= 3 then
        return CTLDTroopZone._raycast(point, self.verticies)
    end
    return ctld.utils.getDistance("CTLDTroopZone:isInZone", point, self.center) <= self.radius
end

--- Jordan ray-casting for polygonal zones.
-- verticies[i].x / .y are mission-file coordinates (mission Y = world Z).
function CTLDTroopZone._raycast(point, verts)
    local px, pz = point.x, point.z
    local inside = false
    local n = #verts
    local j = n
    for i = 1, n do
        local xi, zi = verts[i].x, verts[i].y
        local xj, zj = verts[j].x, verts[j].y
        if ((zi > pz) ~= (zj > pz)) and
           (px < (xj - xi) * (pz - zi) / (zj - zi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

--- Consume n troops from pickup stock. Returns true on success.
-- Unlimited stock (pickMaxStock == 0) always succeeds.
-- @param n number   troops to consume
-- @return boolean
function CTLDTroopZone:consumeStock(n)
    if not self:hasPickup() then return false end
    if self.pickMaxStock == 0 then return true end  -- unlimited
    if self.pickCurrentStock < n then return false end
    self.pickCurrentStock = self.pickCurrentStock - n
    return true
end

--- Restore n troops to pickup stock (capped at pickMaxStock).
-- No-op for unlimited or non-pickup zones.
-- @param n number
function CTLDTroopZone:restoreStock(n)
    if not self:hasPickup() or self.pickMaxStock == 0 then return end
    self.pickCurrentStock = math.min(self.pickMaxStock, self.pickCurrentStock + n)
end

--- Increment the objective flag by soldierCount and check win condition.
-- @param soldierCount number
-- @return boolean incremented, number valueBefore, number valueAfter
function CTLDTroopZone:incrementObjective(soldierCount)
    if not self.objectiveFlag then return false, 0, 0 end
    local before = trigger.misc.getUserFlag(self.objectiveFlag)
    local after  = before + soldierCount
    trigger.action.setUserFlag(self.objectiveFlag, after)
    if self.objectiveTarget and after >= self.objectiveTarget then
        ctld.utils.log("INFO", "CTLDTroopZone: objective '%s' COMPLETE (%d/%d)",
            self.objectiveFlag, after, self.objectiveTarget)
    end
    return true, before, after
end

function CTLDTroopZone:getCenter() return self.center end
function CTLDTroopZone:activate()   self.active = true  end
function CTLDTroopZone:deactivate() self.active = false end


-- ============================================================
-- CTLDLogisticZone  (entity)
-- ============================================================

CTLDLogisticZone = class()

--- Constructor.
-- @param data table
--   Required : name, coalition, center (vec3), radius
--   Optional : linkedUnit (Unit — dynamic zone follows this unit),
--              active, services table
function CTLDLogisticZone:init(data)
    self.name        = data.name
    self.coalition   = data.coalition or 0
    self._center     = data.center
    self.radius      = data.radius   or 200
    self._linkedUnit = data.linkedUnit or nil
    self.active      = (data.active ~= nil) and data.active or true
    self.services    = data.services or {
        cratesPickup  = true,
        cratesDropoff = true,
        vehicleSpawn  = true,
    }
end

--- Return current center. Dynamic zones follow their linked unit.
function CTLDLogisticZone:getCenter()
    if self._linkedUnit and self._linkedUnit:isExist() then
        return self._linkedUnit:getPoint()
    end
    return self._center
end

--- True if this zone is anchored to a moving DCS unit.
function CTLDLogisticZone:isDynamic()
    return self._linkedUnit ~= nil
end

--- True if the linked unit is still alive (always true for static zones).
function CTLDLogisticZone:isAlive()
    if not self._linkedUnit then return true end
    return self._linkedUnit:isExist()
end

--- True if point is inside the zone (circular only — logistic zones are always circular).
function CTLDLogisticZone:isInZone(point)
    return ctld.utils.getDistance("CTLDLogisticZone:isInZone", point, self:getCenter()) <= self.radius
end

function CTLDLogisticZone:activate()   self.active = true  end
function CTLDLogisticZone:deactivate() self.active = false end


-- ============================================================
-- CTLDZoneManager  (singleton)
-- ============================================================

CTLDZoneManager = class()
CTLDZoneManager._instance = nil

local _TROOP_SMOKE_COLOR = {
    [0] = trigger.smokeColor.Green,
    [1] = trigger.smokeColor.Red,
    [2] = trigger.smokeColor.White,
    [3] = trigger.smokeColor.Orange,
    [4] = trigger.smokeColor.Blue,
}
-- Legacy smoke string to number
local _LEGACY_SMOKE_STR = { green=0, red=1, white=2, orange=3, blue=4 }

--- Return (or create) the singleton instance.
-- Triggers full init (discovery + legacy load + smoke schedule + bridge registration).
function CTLDZoneManager.getInstance()
    if not CTLDZoneManager._instance then
        local o = setmetatable({}, CTLDZoneManager)
        o:init()
        CTLDZoneManager._instance = o
    end
    return CTLDZoneManager._instance
end

function CTLDZoneManager:init()
    self._troopZones    = {}   -- zoneName -> CTLDTroopZone
    self._logisticZones = {}   -- name     -> CTLDLogisticZone

    -- Register S_EVENT_DEAD for dynamic logistic zone tracking
    local ok, bridge = pcall(CTLDDCSEventBridge.getInstance)
    if ok and bridge then
        bridge:register(self, world.event.S_EVENT_DEAD, "onDead")
    end

    self:_validateZoneNames()
    self:_discoverTRZ()
    self:_discoverIAZ()
    self:_discoverWPZ()
    self:_discoverLGZ()
    self:_loadLegacyZones()
    self:_scheduleSmoke()

    -- Publish initial state
    self:_publishLogisticZoneUpdated({}, {})

    ctld.utils.log("INFO",
        "CTLDZoneManager ready — troop:%d logistic:%d",
        self:_count(self._troopZones), self:_count(self._logisticZones))
end

-- ============================================================
-- Helpers
-- ============================================================

local function _split(str, sep)
    local parts = {}
    for p in string.gmatch(str, "[^" .. sep .. "]+") do
        parts[#parts + 1] = p
    end
    return parts
end

local function _buildCenter(zd)
    local x = zd.x
    local z = zd.y   -- mission-file Y = world Z
    local y = land.getHeight({ x = x, y = z })
    return { x = x, y = y, z = z }
end

function CTLDZoneManager:_count(tbl)
    local n = 0
    for _ in pairs(tbl) do n = n + 1 end
    return n
end

-- ============================================================
-- TRZ parser
-- ============================================================

-- Parse TRZ_<name>_<A|R|B|N>_<stock>_<flag>_<target>   strict positional, all 5 fields required.
-- stock  : integer 0-999  — 0=no pickup (nil), 999=unlimited (internal 0), 1-998=limited
-- flag   : string or reserved word "nil" (= no objective flag)
-- target : integer ≥0     — 0=no win condition (nil), N≥1=soldier threshold
-- Returns a table on success, nil + error string on failure.
function CTLDZoneManager:_parseTRZ(name)
    local parts = _split(name, "_")
    if parts[1] ~= "TRZ" then return nil, "not a TRZ" end

    -- field 2: zoneName (required, not a reserved word)
    local zoneName = parts[2]
    if not zoneName or zoneName == "" then return nil, "missing zoneName" end
    local _reserved = { ["nil"]=true, A=true, R=true, B=true, N=true }
    if _reserved[zoneName] then
        return nil, "zoneName cannot be a reserved word: " .. zoneName
    end

    -- field 3: coalition (required — A=all, R=RED, B=BLUE, N=NEUTRAL)
    local coalStr = parts[3]
    if not coalStr then return nil, "missing coalition (A|R|B|N)" end
    local coalitionId
    if     coalStr == "A" then coalitionId = 0
    elseif coalStr == "R" then coalitionId = coalition.side.RED
    elseif coalStr == "B" then coalitionId = coalition.side.BLUE
    elseif coalStr == "N" then coalitionId = coalition.side.NEUTRAL
    else return nil, "invalid coalition '" .. coalStr .. "' — expected A, R, B or N" end

    -- field 4: stock (required, integer 0-999)
    local stockStr = parts[4]
    local stockRaw = tonumber(stockStr)
    if not stockRaw or math.floor(stockRaw) ~= stockRaw or stockRaw < 0 or stockRaw > 999 then
        return nil, "invalid stock '" .. tostring(stockStr) .. "' — expected integer 0-999 (0=no pickup, 999=unlimited)"
    end
    local pickMaxStock
    if     stockRaw == 0   then pickMaxStock = nil  -- no pickup capability
    elseif stockRaw == 999 then pickMaxStock = 0    -- unlimited (internal 0)
    else                        pickMaxStock = stockRaw
    end

    -- field 5: flag (required, string or reserved word "nil")
    local flagStr = parts[5]
    if not flagStr then return nil, "missing flag (DCS flag name or 'nil')" end
    if tonumber(flagStr) then
        return nil, "flag must be a string or 'nil', not a number"
    end
    local objectiveFlag
    if flagStr ~= "nil" then objectiveFlag = flagStr end

    -- field 6: target (required, integer ≥0)
    local targetStr = parts[6]
    local targetRaw = tonumber(targetStr)
    if not targetRaw or math.floor(targetRaw) ~= targetRaw or targetRaw < 0 then
        return nil, "invalid target '" .. tostring(targetStr) .. "' — expected integer ≥0 (0=no win condition)"
    end
    local objectiveTarget
    if targetRaw > 0 then objectiveTarget = targetRaw end

    return {
        zoneName        = zoneName,
        coalition       = coalitionId,
        pickMaxStock    = pickMaxStock,
        objectiveFlag   = objectiveFlag,
        objectiveTarget = objectiveTarget,
    }
end

-- Parse LGZ_name_[R|B|N]
function CTLDZoneManager:_parseLGZ(name)
    local parts = _split(name, "_")
    if parts[1] ~= "LGZ" then return nil end
    local lgzName     = parts[2]
    local coalitionId = 0
    if     parts[3] == "R" then coalitionId = coalition.side.RED
    elseif parts[3] == "B" then coalitionId = coalition.side.BLUE
    elseif parts[3] == "N" then coalitionId = coalition.side.NEUTRAL end
    return { name = lgzName, coalition = coalitionId }
end

-- Parse IAZ_name_[R|B|N]  (AI auto-drop zone)
-- Parse WPZ_name_[R|B|N]  (waypoint zone — troops march to center)
-- Shared logic: prefix must match, second field = zoneName, optional third = coalition.
local function _parseSimpleZone(prefix, name)
    local parts = _split(name, "_")
    if parts[1] ~= prefix then return nil, "wrong prefix" end
    local zoneName = parts[2]
    if not zoneName then return nil, "missing zoneName" end
    local coalitionId = 0
    if     parts[3] == "R" then coalitionId = coalition.side.RED
    elseif parts[3] == "B" then coalitionId = coalition.side.BLUE
    elseif parts[3] == "N" then coalitionId = coalition.side.NEUTRAL end
    return { zoneName = zoneName, coalition = coalitionId }
end

function CTLDZoneManager:_parseIAZ(name) return _parseSimpleZone("IAZ", name) end
function CTLDZoneManager:_parseWPZ(name) return _parseSimpleZone("WPZ", name) end

-- ============================================================
-- Discovery
-- ============================================================

function CTLDZoneManager:_discoverTRZ()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then
        ctld.utils.log("WARN", "CTLDZoneManager: env.mission.triggers.zones not accessible")
        return
    end
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "TRZ_" then
            local parsed, err = self:_parseTRZ(name)
            if not parsed then
                ctld.utils.log("WARN", "CTLDZoneManager: cannot parse TRZ '%s': %s", name, tostring(err))
            elseif not self._troopZones[parsed.zoneName] then
                local zone = CTLDTroopZone:new({
                    dcsName        = name,
                    zoneName       = parsed.zoneName,
                    coalition      = parsed.coalition,
                    center         = _buildCenter(zd),
                    radius         = zd.radius or 500,
                    verticies      = zd.verticies or nil,
                    pickMaxStock   = parsed.pickMaxStock,
                    objectiveFlag  = parsed.objectiveFlag,
                    objectiveTarget= parsed.objectiveTarget,
                    smoke          = ctld.gs("troopZoneSmokeColor") and
                                     ctld.gs("troopZoneSmokeColor")[parsed.coalition] or -1,
                    active         = true,
                })
                if zone.objectiveFlag then
                    trigger.action.setUserFlag(zone.objectiveFlag, 0)
                end
                self._troopZones[parsed.zoneName] = zone
                ctld.utils.log("INFO",
                    "CTLDZoneManager: TRZ '%s' coalition=%d stock=%s flag=%s target=%s",
                    parsed.zoneName, parsed.coalition,
                    tostring(parsed.pickMaxStock), tostring(parsed.objectiveFlag),
                    tostring(parsed.objectiveTarget))
            end
        end
    end
end

function CTLDZoneManager:_discoverLGZ()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then return end
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "LGZ_" then
            local parsed = self:_parseLGZ(name)
            if parsed and not self._logisticZones[parsed.name] then
                local zone = CTLDLogisticZone:new({
                    name      = parsed.name,
                    coalition = parsed.coalition,
                    center    = _buildCenter(zd),
                    radius    = ctld.gs("dynamicZoneRadius") or 200,
                    active    = true,
                })
                self._logisticZones[parsed.name] = zone
                ctld.utils.log("INFO", "CTLDZoneManager: LGZ '%s' coalition=%d",
                    parsed.name, parsed.coalition)
            end
        end
    end
end

function CTLDZoneManager:_discoverIAZ()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then return end
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "IAZ_" then
            local parsed, err = self:_parseIAZ(name)
            if not parsed then
                ctld.utils.log("WARN", "CTLDZoneManager: cannot parse IAZ '%s': %s", name, tostring(err))
            elseif not self._troopZones[parsed.zoneName] then
                local zone = CTLDTroopZone:new({
                    dcsName   = name,
                    zoneName  = parsed.zoneName,
                    coalition = parsed.coalition,
                    center    = _buildCenter(zd),
                    radius    = zd.radius or 500,
                    verticies = zd.verticies or nil,
                    isDropoff = true,
                    active    = true,
                })
                self._troopZones[parsed.zoneName] = zone
                ctld.utils.log("INFO", "CTLDZoneManager: IAZ '%s' coalition=%d",
                    parsed.zoneName, parsed.coalition)
            end
        end
    end
end

function CTLDZoneManager:_discoverWPZ()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then return end
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "WPZ_" then
            local parsed, err = self:_parseWPZ(name)
            if not parsed then
                ctld.utils.log("WARN", "CTLDZoneManager: cannot parse WPZ '%s': %s", name, tostring(err))
            elseif not self._troopZones[parsed.zoneName] then
                local zone = CTLDTroopZone:new({
                    dcsName    = name,
                    zoneName   = parsed.zoneName,
                    coalition  = parsed.coalition,
                    center     = _buildCenter(zd),
                    radius     = zd.radius or 500,
                    verticies  = zd.verticies or nil,
                    isWaypoint = true,
                    active     = true,
                })
                self._troopZones[parsed.zoneName] = zone
                ctld.utils.log("INFO", "CTLDZoneManager: WPZ '%s' coalition=%d",
                    parsed.zoneName, parsed.coalition)
            end
        end
    end
end

-- ============================================================
-- Legacy fallback
-- ============================================================

function CTLDZoneManager:_loadLegacyZones()

    -- pickupZones → CTLDTroopZone (pickup only)
    for _, zd in pairs(ctld.gs("pickupZones") or {}) do
        local trig = trigger.misc.getZone(zd[1])
        if trig and not self._troopZones[zd[1]] then
            local smoke = -1
            if zd[2] then
                local n = tonumber(_LEGACY_SMOKE_STR[zd[2]] or zd[2])
                smoke = _TROOP_SMOKE_COLOR[n] or -1
            end
            local stock = (zd[3] == -1 or zd[3] == nil) and 0 or tonumber(zd[3])
            self._troopZones[zd[1]] = CTLDTroopZone:new({
                dcsName      = zd[1], zoneName = zd[1],
                coalition    = tonumber(zd[5]) or 0,
                center       = { x=trig.point.x, y=trig.point.y, z=trig.point.z },
                radius       = trig.radius,
                pickMaxStock = stock,
                smoke        = smoke,
                active       = (zd[4] == "yes" or zd[4] == 1),
            })
        end
    end

    -- dropOffZones → CTLDTroopZone (AI auto-drop marker)
    for _, zd in pairs(ctld.gs("dropOffZones") or {}) do
        local trig = trigger.misc.getZone(zd[1])
        if trig and not self._troopZones[zd[1]] then
            local smoke = -1
            if zd[2] then
                local n = tonumber(_LEGACY_SMOKE_STR[zd[2]] or zd[2])
                smoke = _TROOP_SMOKE_COLOR[n] or -1
            end
            self._troopZones[zd[1]] = CTLDTroopZone:new({
                dcsName   = zd[1], zoneName = zd[1],
                coalition = tonumber(zd[3]) or 0,
                center    = { x=trig.point.x, y=trig.point.y, z=trig.point.z },
                radius    = trig.radius,
                isDropoff = true,
                smoke     = smoke, active = true,
            })
        end
    end

    -- wpZones → CTLDTroopZone (waypoint: troops march to center)
    for _, zd in pairs(ctld.gs("wpZones") or {}) do
        local trig = trigger.misc.getZone(zd[1])
        if trig and not self._troopZones[zd[1]] then
            local smoke = -1
            if zd[2] then
                local n = tonumber(_LEGACY_SMOKE_STR[zd[2]] or zd[2])
                smoke = _TROOP_SMOKE_COLOR[n] or -1
            end
            self._troopZones[zd[1]] = CTLDTroopZone:new({
                dcsName    = zd[1], zoneName = zd[1],
                coalition  = tonumber(zd[4]) or 0,
                center     = { x=trig.point.x, y=trig.point.y, z=trig.point.z },
                radius     = trig.radius,
                isWaypoint = true,
                smoke      = smoke,
                active     = (zd[3] == "yes" or zd[3] == 1),
            })
        end
    end

    -- logisticUnits → CTLDLogisticZone (dynamic, linked to unit/static)
    local maxDist = ctld.gs("maximumDistanceLogistic") or 500
    local added, removed = {}, {}
    for _, unitName in pairs(ctld.gs("logisticUnits") or {}) do
        if not self._logisticZones[unitName] then
            local obj = StaticObject.getByName(unitName) or Unit.getByName(unitName)
            if obj then
                local coal = obj:getCoalition()
                self._logisticZones[unitName] = CTLDLogisticZone:new({
                    name        = unitName,
                    coalition   = coal,
                    center      = obj:getPoint(),
                    radius      = maxDist,
                    linkedUnit  = obj,
                    active      = true,
                })
                added[#added + 1] = { unitName = unitName, coalition = coal }
                ctld.utils.log("INFO", "CTLDZoneManager: logistic unit '%s'", unitName)
            else
                ctld.utils.log("WARN",
                    "CTLDZoneManager: logisticUnits '%s' not found in mission", unitName)
            end
        end
    end
    if #added > 0 then
        self:_publishLogisticZoneUpdated(added, removed)
    end
end

-- ============================================================
-- Smoke scheduler
-- ============================================================

function CTLDZoneManager:_scheduleSmoke()
    local interval = ctld.gs("smokeRefreshInterval") or 300
    local self_ref = self

    local function refresh()
        if ctld.gs("disableAllSmoke") == true then
            timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
            return
        end

        local tZoneData, lZoneData = {}, {}

        -- Smoke troop zones
        for _, zone in pairs(self_ref._troopZones) do
            if zone.active and zone.smoke and zone.smoke >= 0 then
                trigger.action.smoke(zone.center, zone.smoke)
                tZoneData[#tZoneData + 1] = {
                    fullName        = zone.dcsName,
                    zoneName        = zone.zoneName,
                    coalition       = zone.coalition,
                    position        = zone.center,
                    radius          = zone.radius,
                    hasPickup       = zone:hasPickup(),
                    hasExtract      = zone:hasExtract(),
                    pickMaxStock    = zone.pickMaxStock,
                    pickCurrentStock= zone.pickCurrentStock,
                    objectiveFlag   = zone.objectiveFlag,
                    objectiveTarget = zone.objectiveTarget,
                    objectiveCurrent= zone.objectiveFlag
                                      and trigger.misc.getUserFlag(zone.objectiveFlag) or nil,
                    smokeColor      = zone.smoke,
                }
            end
        end

        -- Smoke logistic zones (optional per config)
        for _, zone in pairs(self_ref._logisticZones) do
            if zone.active then
                local smokeColors = ctld.gs("logisticZoneSmokeColor")
                local color = smokeColors and smokeColors[zone.coalition]
                if color then
                    trigger.action.smoke(zone:getCenter(), color)
                end
                lZoneData[#lZoneData + 1] = {
                    name       = zone.name,
                    coalition  = zone.coalition,
                    position   = zone:getCenter(),
                    radius     = zone.radius,
                    type       = zone:isDynamic() and "dynamic" or "static",
                    linkedUnit = zone._linkedUnit,
                    smokeColor = color,
                }
            end
        end

        EventDispatcher.getInstance():publish("OnZoneSmokeRefreshed", {
            troopZones    = tZoneData,
            logisticZones = lZoneData,
            timestamp     = timer.getAbsTime(),
            refreshInterval = interval,
        })

        timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
    end

    timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
end

-- ============================================================
-- Events
-- ============================================================

function CTLDZoneManager:_publishLogisticZoneUpdated(added, removed)
    local zones = {}
    for _, zone in pairs(self._logisticZones) do
        zones[#zones + 1] = {
            name       = zone.name,
            type       = "logistic",
            linkedUnit = zone._linkedUnit,
            position   = zone:getCenter(),
            coalition  = zone.coalition,
            radius     = zone.radius,
            services   = zone.services,
        }
    end
    EventDispatcher.getInstance():publish("OnLogisticZoneUpdated", {
        zones        = zones,
        unitsAdded   = added,
        unitsRemoved = removed,
        timestamp    = timer.getAbsTime(),
    })
end

--- S_EVENT_DEAD: remove dynamic logistic zones whose linked unit died.
function CTLDZoneManager:onDead(event)
    local unit = event.initiator
    if not unit then return end
    local unitName = unit:getName()
    local zone = self._logisticZones[unitName]
    if zone and zone:isDynamic() then
        self._logisticZones[unitName] = nil
        ctld.utils.log("INFO", "CTLDZoneManager: dynamic logistic zone '%s' removed (unit dead)", unitName)
        self:_publishLogisticZoneUpdated({}, { { unitName = unitName, coalition = zone.coalition, reason = "dead" } })
    end
end

-- ============================================================
-- Dynamic registration (FOB, external callers)
-- ============================================================

--- Register a deployed FOB as a logistic zone.
-- @param fobName   string
-- @param point     vec3
-- @param radius    number  (default 150)
-- @param coalitionId number
function CTLDZoneManager:registerFOBAsLogistic(fobName, point, radius, coalitionId)
    local zone = CTLDLogisticZone:new({
        name      = fobName,
        coalition = coalitionId or 0,
        center    = point,
        radius    = radius or 150,
        active    = true,
    })
    self._logisticZones[fobName] = zone
    ctld.utils.log("INFO", "CTLDZoneManager: FOB logistic zone '%s' r=%dm", fobName, radius or 150)
    self:_publishLogisticZoneUpdated({ { unitName = fobName, coalition = coalitionId } }, {})
end

--- Remove a logistic zone (e.g. FOB destroyed).
function CTLDZoneManager:unregisterLogistic(name)
    local zone = self._logisticZones[name]
    if zone then
        self._logisticZones[name] = nil
        ctld.utils.log("INFO", "CTLDZoneManager: logistic zone '%s' unregistered", name)
        self:_publishLogisticZoneUpdated({}, { { unitName = name, coalition = zone.coalition, reason = "removed" } })
    end
end

-- ============================================================
-- Query API — TroopZones
-- ============================================================

--- Return CTLDTroopZone by zoneName, or nil.
function CTLDZoneManager:getTroopZone(zoneName)
    return self._troopZones[zoneName]
end

--- Return all active troop zones matching coalition (0 = both).
-- @param coalition  number   coalition.side.*
-- @return table of CTLDTroopZone
function CTLDZoneManager:getTroopZonesForCoalition(coalition)
    local result = {}
    for _, zone in pairs(self._troopZones) do
        if zone.active and (zone.coalition == coalition or zone.coalition == 0) then
            result[#result + 1] = zone
        end
    end
    return result
end

--- Return the troop zone containing point, or nil.
-- @param point     vec3
-- @param coalition number  (0 = accept all)
-- @return CTLDTroopZone or nil
function CTLDZoneManager:getTroopZoneAtPoint(point, coalition)
    for _, zone in pairs(self._troopZones) do
        if zone.active and (coalition == 0 or zone.coalition == 0 or zone.coalition == coalition) then
            if zone:isInZone(point) then return zone end
        end
    end
    return nil
end

--- Return the troop zone containing unitName, or nil.
-- @param unitName  string
-- @return CTLDTroopZone or nil
function CTLDZoneManager:getTroopZoneForUnit(unitName)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then return nil end
    return self:getTroopZoneAtPoint(unit:getPoint(), unit:getCoalition())
end

--- Return the active WPZ zone containing point for the given coalition, or nil.
-- @param point     vec3
-- @param coalition number  (coalition.side.* — 0 = accept all)
-- @return CTLDTroopZone or nil
function CTLDZoneManager:getWaypointZoneAt(point, coalition)
    for _, zone in pairs(self._troopZones) do
        if zone.active and zone:hasWaypoint()
        and (coalition == 0 or zone.coalition == 0 or zone.coalition == coalition)
        and zone:isInZone(point) then
            return zone
        end
    end
    return nil
end

--- Return the active IAZ zone containing point for the given coalition, or nil.
-- Used by AI transport auto-drop logic.
-- @param point     vec3
-- @param coalition number  (coalition.side.* — 0 = accept all)
-- @return CTLDTroopZone or nil
function CTLDZoneManager:getDropoffZoneAt(point, coalition)
    for _, zone in pairs(self._troopZones) do
        if zone.active and zone:hasDropoff()
        and (coalition == 0 or zone.coalition == 0 or zone.coalition == coalition)
        and zone:isInZone(point) then
            return zone
        end
    end
    return nil
end

-- ============================================================
-- Query API — LogisticZones
-- ============================================================

--- Return CTLDLogisticZone by name, or nil.
function CTLDZoneManager:getLogisticZone(name)
    return self._logisticZones[name]
end

--- Return all active logistic zones matching coalition.
function CTLDZoneManager:getLogisticZonesForCoalition(coalition)
    local result = {}
    for _, zone in pairs(self._logisticZones) do
        if zone.active and zone:isAlive()
           and (zone.coalition == coalition or zone.coalition == 0) then
            result[#result + 1] = zone
        end
    end
    return result
end

--- Return the logistic zone containing point, or nil.
-- @param point     vec3
-- @param coalition number
-- @return CTLDLogisticZone or nil
function CTLDZoneManager:getLogisticZoneAtPoint(point, coalition)
    for _, zone in pairs(self._logisticZones) do
        if zone.active and zone:isAlive()
           and (coalition == 0 or zone.coalition == 0 or zone.coalition == coalition) then
            if zone:isInZone(point) then return zone end
        end
    end
    return nil
end

--- Return the logistic zone containing unitName, or nil.
function CTLDZoneManager:getLogisticZoneForUnit(unitName)
    local unit = Unit.getByName(unitName) or StaticObject.getByName(unitName)
    if not unit or not unit:isExist() then return nil end
    return self:getLogisticZoneAtPoint(unit:getPoint(), unit:getCoalition())
end

--- Return ALL active logistic zones containing point (not just the first one).
-- Filters on coalition (0 = any). Optionally filters on a services key.
-- @param point      vec3
-- @param coalition  number
-- @param serviceKey string|nil   e.g. "cratesPickup" — if provided, zone.services[key] must be truthy
-- @return table  array of CTLDLogisticZone (may be empty)
function CTLDZoneManager:getLogisticZonesAtPoint(point, coalition, serviceKey)
    local result = {}
    for _, zone in pairs(self._logisticZones) do
        if zone.active and zone:isAlive()
           and (coalition == 0 or zone.coalition == 0 or zone.coalition == coalition)
           and zone:isInZone(point) then
            if not serviceKey or (zone.services and zone.services[serviceKey] ~= false) then
                result[#result + 1] = zone
            end
        end
    end
    return result
end

-- ============================================================
-- Misc helpers
-- ============================================================

--- Activate / deactivate a troop zone.
function CTLDZoneManager:setTroopZoneActive(zoneName, active)
    local zone = self._troopZones[zoneName]
    if zone then
        if active then zone:activate() else zone:deactivate() end
    end
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Return the first troop zone of the given capability containing unitName.
-- zoneType: "extract" (hasExtract), "pickup" (hasPickup), nil (any active zone).
-- @param unitName string
-- @param zoneType string|nil
-- @return CTLDTroopZone or nil
function CTLDZoneManager:isUnitInZone(unitName, zoneType)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then return nil end
    local pt = unit:getPoint()
    for _, zone in pairs(self._troopZones) do
        if zone.active and zone:isInZone(pt) then
            if zoneType == "extract" then
                if zone:hasExtract() then return zone end
            elseif zoneType == "pickup" then
                if zone:hasPickup() then return zone end
            else
                return zone
            end
        end
    end
    return nil
end

--- Create a dynamic extract zone at a DCS trigger zone (MM DO SCRIPT).
-- Troops deployed inside will be counted silently and increment flagNumber.
-- smoke: trigger.smokeColor.* or -1 for no smoke.
-- @param zoneName   string          DCS trigger zone name
-- @param flagNumber number|string   DCS user flag to set to troop count
-- @param smoke      number          smoke color or -1
-- @return boolean
function CTLDZoneManager:createExtractZone(zoneName, flagNumber, smoke)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDZoneManager:createExtractZone — zone not found: %s", tostring(zoneName))
        return false
    end
    if self._troopZones[zoneName] then
        ctld.utils.log("WARN", "CTLDZoneManager:createExtractZone — zone already registered: %s", zoneName)
        return false
    end
    local p2 = { x = trig.point.x, y = trig.point.z }
    local pt = { x = p2.x, y = land.getHeight(p2), z = p2.y }
    local smokeColor = (smoke ~= nil and tonumber(smoke) and tonumber(smoke) >= 0) and tonumber(smoke) or -1
    self._troopZones[zoneName] = CTLDTroopZone:new({
        dcsName       = zoneName,
        zoneName      = zoneName,
        coalition     = 0,
        center        = pt,
        radius        = trig.radius,
        objectiveFlag = tostring(flagNumber),
        smoke         = smokeColor,
        active        = true,
    })
    if smokeColor >= 0 then trigger.action.smoke(pt, smokeColor) end
    ctld.utils.log("INFO", "CTLDZoneManager:createExtractZone — '%s' flag=%s", zoneName, tostring(flagNumber))
    return true
end

--- Remove a dynamic extract zone.
-- flagNumber is accepted for API compatibility but ignored.
-- @param zoneName   string
-- @param flagNumber number|string  (ignored)
-- @return boolean
function CTLDZoneManager:removeExtractZone(zoneName, flagNumber)
    if self._troopZones[zoneName] then
        self._troopZones[zoneName] = nil
        ctld.utils.log("INFO", "CTLDZoneManager:removeExtractZone — '%s' removed", zoneName)
        return true
    end
    ctld.utils.log("WARN", "CTLDZoneManager:removeExtractZone — not found: %s", tostring(zoneName))
    return false
end

--- Activate a waypoint zone (troops deployed inside will move toward zone center).
-- @param zoneName string
function CTLDZoneManager:activateWaypointZone(zoneName)
    return self:setTroopZoneActive(zoneName, true)
end

--- Deactivate a waypoint zone.
-- @param zoneName string
function CTLDZoneManager:deactivateWaypointZone(zoneName)
    return self:setTroopZoneActive(zoneName, false)
end

--- Adjust the available pickup stock for a troop zone by amount (positive or negative).
-- @param zoneName string
-- @param amount   number
-- @return boolean
function CTLDZoneManager:changeRemainingGroups(zoneName, amount)
    local zone = self._troopZones[zoneName]
    if not zone then
        ctld.utils.log("WARN", "CTLDZoneManager:changeRemainingGroups — not found: %s", tostring(zoneName))
        return false
    end
    if zone.pickMaxStock == nil then
        ctld.utils.log("WARN", "CTLDZoneManager:changeRemainingGroups — '%s' has no pickup stock", zoneName)
        return false
    end
    zone.pickCurrentStock = math.max(0, zone.pickCurrentStock + amount)
    ctld.utils.log("INFO", "CTLDZoneManager:changeRemainingGroups — '%s' stock=%d", zoneName, zone.pickCurrentStock)
    return true
end

-- ============================================================
-- Zone name validation (developer tool — reports to DCS log + screen)
-- ============================================================

function CTLDZoneManager:_validateZoneNames()
    if not (env.mission and env.mission.triggers and env.mission.triggers.zones) then return end
    local errors = {}
    for _, zd in pairs(env.mission.triggers.zones) do
        local name = zd.name or ""
        if string.sub(name, 1, 4) == "TRZ_" then
            local parsed, err = self:_parseTRZ(name)
            if not parsed then
                errors[#errors + 1] = "  TRZ ERROR '" .. name .. "': " .. tostring(err)
            end
        elseif string.sub(name, 1, 4) == "IAZ_" then
            local parsed, err = self:_parseIAZ(name)
            if not parsed then
                errors[#errors + 1] = "  IAZ ERROR '" .. name .. "': " .. tostring(err)
            end
        elseif string.sub(name, 1, 4) == "WPZ_" then
            local parsed, err = self:_parseWPZ(name)
            if not parsed then
                errors[#errors + 1] = "  WPZ ERROR '" .. name .. "': " .. tostring(err)
            end
        elseif string.sub(name, 1, 4) == "LGZ_" then
            local parsed = self:_parseLGZ(name)
            if not parsed then
                errors[#errors + 1] = "  LGZ ERROR '" .. name .. "': parse failed"
            end
        end
    end
    if #errors > 0 then
        local report = "[CTLD] Zone validation — " .. #errors .. " issue(s):\n"
                    .. table.concat(errors, "\n")
        trigger.action.outText(report, 30)
        ctld.utils.log("WARN", report)
    else
        ctld.utils.log("INFO", "CTLDZoneManager: all zone names valid")
    end
end

-- End : CTLD_zone.lua
-- ====================================================================================================
-- Start : CTLD_troop.lua
-- ============================================================
-- CTLD_troop.lua
-- CTLDTroopGroup entity + CTLDTroopManager singleton
--
-- Dependencies: CTLDConfig (ctld.gs), CTLDUtils, CTLDObjectRegistry, CTLDZoneManager
-- DCS API: coalition.addGroup, Group, Unit, land, trigger.action, missionCommands
--
-- TroopGroup lifecycle states:
--   TRZ_LOADED     : troops onboard a transport (loaded from a TroopZone)
--   DEPLOYED       : troops on the ground as a live DCS group
--   FIELD_LOADED   : troops onboard a transport (recovered from field)
--   DEPLOYED_EXZ   : silent drop into EXZ_ — DCS group never spawned, flag counter only
--   RETURNED_TO_TRZ: troops returned to TroopZone — instance discarded
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDTroopGroup  (entity)
-- ============================================================

CTLDTroopGroup = class()

CTLDTroopGroup.STATE = {
    TRZ_LOADED     = "TRZ_LOADED",
    DEPLOYED       = "deployed",
    FIELD_LOADED   = "FIELD_LOADED",
    DEPLOYED_EXZ   = "DEPLOYED_EXZ",
    RETURNED_TO_TRZ = "RETURNED_TO_TRZ",
}

--- Constructor.
-- @param data table:
--   templateKey   (string|nil)  CTLDObjectRegistry key (nil for recovered groups)
--   templateName   (string)      display name
--   unitTotal      (number)      total unit count (alive at construction time)
--   weight         (number)      total cargo weight (kg)
--   coalitionId    (number)      coalition.side.*
--   countryId      (number)      DCS country id
--   state          (string|nil)  CTLDTroopGroup.STATE.* — defaults to TRZ_LOADED
--   _aliveUnits    (table|nil)   map[unitName] = dcsUnit (references, not indices)
--   _jtacUnits     (table|nil)   map[unitName] = true (subset of _aliveUnits flagged JTAC)
function CTLDTroopGroup:init(data)
    self.templateKey  = data.templateKey
    self.templateName = data.templateName
    self.unitTotal    = data.unitTotal
    self.weight       = data.weight
    self.coalitionId  = data.coalitionId
    self.countryId    = data.countryId
    self.state       = data.state or CTLDTroopGroup.STATE.TRZ_LOADED
    self.dcsGroup    = nil
    self.loadTime    = timer.getAbsTime()
    self._aliveUnits = data._aliveUnits or {}  -- map[unitName] = dcsUnit (DCS Unit reference)
    self._jtacUnits  = data._jtacUnits  or {}  -- map[unitName] = true
end

--- Transition to DEPLOYED: record the spawned DCS group.
-- @param dcsGroup Group|nil  spawned DCS group (nil for objective-zone silent drops)
function CTLDTroopGroup:deploy(dcsGroup)
    self.state    = CTLDTroopGroup.STATE.DEPLOYED
    self.dcsGroup = dcsGroup
end

--- Returns true if troops are onboard the transport (TRZ_LOADED or FIELD_LOADED).
function CTLDTroopGroup:isInTransit()
    return self.state == CTLDTroopGroup.STATE.TRZ_LOADED
        or self.state == CTLDTroopGroup.STATE.FIELD_LOADED
end

--- Returns the count of alive JTAC units in this group.
function CTLDTroopGroup:getJtacCount()
    local n = 0
    for _ in pairs(self._jtacUnits) do n = n + 1 end
    return n
end

--- Returns true if this group has at least one alive JTAC unit.
function CTLDTroopGroup:hasAliveJtac()
    return self:getJtacCount() > 0
end

--- Syncs _aliveUnits / _jtacUnits from the current DCS group.
-- Fully rebuilds both maps from actual DCS unit names.
-- JTAC units are identified by the "JTAC" name prefix (set by _registerOneTemplate).
-- This prefix is exclusive to jtac-role units — all other roles use INF/MG/AT/AA/MORTAR.
-- @param dcsGroup Group|nil  the DCS group (nil to clear refs)
function CTLDTroopGroup:_syncFromDCSGroup(dcsGroup)
    self._aliveUnits = {}
    self._jtacUnits  = {}  -- full reset: rebuild from real DCS unit names
    if not dcsGroup or not dcsGroup:isExist() then
        self.unitTotal = 0
        return
    end
    local units = dcsGroup:getUnits()
    for _, unit in ipairs(units) do
        if unit:isExist() then
            local name = unit:getName()
            self._aliveUnits[name] = unit
            if name:match("^JTAC") then
                self._jtacUnits[name] = true
            end
        end
    end
    self.unitTotal = 0
    for _ in pairs(self._aliveUnits) do self.unitTotal = self.unitTotal + 1 end
end

--- Removes a dead unit from _aliveUnits and _jtacUnits.
-- Called by CTLDTroopManager:onUnitDead() on S_EVENT_DEAD.
-- @param unitName string
function CTLDTroopGroup:_removeDeadUnit(unitName)
    self._aliveUnits[unitName] = nil
    self._jtacUnits[unitName]  = nil
    self.unitTotal = 0
    for _ in pairs(self._aliveUnits) do self.unitTotal = self.unitTotal + 1 end
end

--- Transition to DEPLOYED: record the spawned DCS group and sync unit refs.
-- @param dcsGroup Group|nil  spawned DCS group (nil for DEPLOYED_EXZ silent drops)
function CTLDTroopGroup:disembark(dcsGroup)
    self.state    = CTLDTroopGroup.STATE.DEPLOYED
    self.dcsGroup = dcsGroup
    if dcsGroup then
        self:_syncFromDCSGroup(dcsGroup)
    end
end

--- Alias for backward compatibility during transition.
CTLDTroopGroup.deploy = CTLDTroopGroup.disembark

--- Transition to TRZ_LOADED: troops loaded from TroopZone (new load).
-- @param template table  loadableGroup template (used to init _aliveUnits from composition)
function CTLDTroopGroup:setTRZLoaded(template)
    self.state    = CTLDTroopGroup.STATE.TRZ_LOADED
    self.dcsGroup = nil
    self:_initFromTemplate(template)
end

--- Build _aliveUnits / _jtacUnits from a template at load time (before DCS group exists).
-- @param template table  loadableGroup template
function CTLDTroopGroup:_initFromTemplate(template)
    self._aliveUnits = {}
    self._jtacUnits  = {}
    local idx = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = template[role] or 0
        for i = 1, n do
            idx = idx + 1
            local unitName = string.format("%s_u%d", template.name or "Troop", idx)
            self._aliveUnits[unitName] = idx  -- placeholder: slot number, not a DCS Unit ref yet
            if role == "jtac" then
                self._jtacUnits[unitName] = true
            end
        end
    end
end

-- ============================================================
-- CTLDTroopManager  (singleton)
-- ============================================================

CTLDTroopManager = class()

CTLDTroopManager._instance = nil

-- ============================================================
-- Unit types per role per coalition
-- ============================================================

CTLDTroopManager._UNIT_TYPES = {
    inf    = { [1] = "Infantry AK",        [2] = "Soldier M4 GRG"    },
    mg     = { [1] = "Paratrooper AKS-74", [2] = "Soldier M249"      },
    at     = { [1] = "Paratrooper RPG-16", [2] = "Paratrooper RPG-16"},
    aa     = { [1] = "SA-18 Igla manpad",  [2] = "Soldier stinger"   },
    mortar = { [1] = "2B11 mortar",        [2] = "2B11 mortar"       },
    jtac   = { [1] = "Infantry AK",        [2] = "Soldier M4 GRG"    },  -- same model, name prefix = "JTAC"
}

-- Average weight (kg) per soldier per role: base 84 + kit 20 + equipment
CTLDTroopManager._ROLE_WEIGHTS = {
    inf    = 109,   -- 84+20+5
    mg     = 114,   -- 84+20+10
    at     = 112,   -- 84+20+7.6 (rounded)
    aa     = 122,   -- 84+20+18
    mortar = 130,   -- 84+20+26
    jtac   = 124,   -- 84+20+15+5
}

-- Processing order matches ctld.generateTroopTypes in source
CTLDTroopManager._ROLE_ORDER = { "aa", "inf", "mg", "at", "mortar", "jtac" }

-- ============================================================
-- Singleton
-- ============================================================

function CTLDTroopManager.getInstance()
    if CTLDTroopManager._instance == nil then
        CTLDTroopManager._instance = setmetatable({}, CTLDTroopManager)
        CTLDTroopManager._instance:init()
    end
    return CTLDTroopManager._instance
end

-- ============================================================
-- Init
-- ============================================================

function CTLDTroopManager:init()
    self._inTransit        = {}              -- [unitName] = CTLDTroopGroup (LOADED or EXTRACTED)
    self._droppedGroups    = { [1]={}, [2]={} }  -- [coalition] = { groupName, ... }
    self._droppedTemplates = {}              -- [groupName] = templateKey (for re-deploy after extract)
    self._parachuteEffect  = CTLDNullParachuteEffect:new()
    self._templates        = {}              -- mutable runtime list (standard + custom)
    self:_registerTemplates()
    self:_loadUserConfig()
    self._templateCount = #self._templates
    CTLDPlayerManager.getInstance():registerMenuSection({
        key    = "troops",
        manager = self,
        method  = "buildMenuSection",
        order   = 20,
    })
    ctld.utils.log("INFO", "CTLDTroopManager initialized — %d templates registered",
        self._templateCount)
    return self
end

--- Replace the parachute visual effect handler.
-- @param effect CTLDParachuteEffect
function CTLDTroopManager:setParachuteEffect(effect)
    self._parachuteEffect = effect
end

-- ============================================================
-- Template registration → CTLDObjectRegistry entries
-- ============================================================

local function _sanitizeKey(name)
    return (name:gsub("[^%w]", "_"))
end

-- Populates self._templates from config and registers each standard template.
-- Mutates source objects (adds _dbKey, total, hasJtac, custom, disabled) — consistent with legacy.
function CTLDTroopManager:_registerTemplates()
    local cfgTemplates = ctld.gs("loadableGroups") or {}
    for _, tmpl in ipairs(cfgTemplates) do
        tmpl.custom   = false
        tmpl.disabled = false
        table.insert(self._templates, tmpl)
        self:_registerOneTemplate(tmpl)
    end
end

-- Computes total/hasJtac, assigns _dbKey, and inserts a GROUND descriptor into CTLDObjectRegistry.
-- Safe to call at init or at runtime (createLoadableGroup).
function CTLDTroopManager:_registerOneTemplate(tmpl)
    local total   = 0
    local hasJtac = false
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = tmpl[role] or 0
        total   = total + n
        if role == "jtac" and n > 0 then hasJtac = true end
    end
    tmpl.total   = total
    tmpl.hasJtac = hasJtac

    -- Build the units array (no dx/dz: circle formation computes them at spawn time)
    local units = {}
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n      = tmpl[role] or 0
        local isJtac = (role == "jtac")
        for _ = 1, n do
            local capturedRole = role
            table.insert(units, {
                namePrefix = isJtac and "JTAC" or string.upper(capturedRole),
                unitType   = (function(r)
                    return function(cid)
                        return CTLDTroopManager._UNIT_TYPES[r][cid]
                            or CTLDTroopManager._UNIT_TYPES[r][2]
                    end
                end)(capturedRole),
            })
        end
    end

    local key   = "troop_" .. _sanitizeKey(tmpl.name)
    tmpl._dbKey = key

    CTLDObjectRegistry._db[key] = {
        groupType  = "GROUND",
        namePrefix = "TroopGrp_" .. _sanitizeKey(tmpl.name),
        task       = "Ground Nothing",
        category   = Unit.Category.GROUND_UNIT,
        formation  = { type = "circle" },
        units      = units,
    }

    ctld.utils.log("INFO", "_registerOneTemplate: '%s' → key='%s' (%d units)",
        tmpl.name, key, total)
end

-- Applies ctld_config_user.customLoadableGroups and ctld_config_user.disableLoadableGroups.
function CTLDTroopManager:_loadUserConfig()
    local cfg = (type(ctld_config_user) == "table") and ctld_config_user or {}

    local customs = cfg.customLoadableGroups
    if type(customs) == "table" then
        for _, entry in ipairs(customs) do
            local ok, err = self:createLoadableGroup(entry)
            if not ok then
                ctld.utils.log("WARN", "_loadUserConfig: skipped custom group — %s", err)
            end
        end
    end

    local disables = cfg.disableLoadableGroups
    if type(disables) == "table" then
        for _, name in ipairs(disables) do
            local ok, err = self:disableLoadableGroup(name)
            if not ok then
                ctld.utils.log("WARN", "_loadUserConfig: could not disable '%s' — %s", name, err)
            end
        end
    end
end

-- ============================================================
-- Public API — LoadableGroup management
-- ============================================================

-- Returns the template entry with this name, or nil.
function CTLDTroopManager:_findTemplate(name)
    for _, tmpl in ipairs(self._templates) do
        if tmpl.name == name then return tmpl end
    end
    return nil
end

-- Creates and registers a custom loadable group template.
-- @param config table  { name, composition={inf,mg,at,aa,mortar,jtac}, side }
-- @return boolean, string|nil
function CTLDTroopManager:createLoadableGroup(config)
    if type(config) ~= "table" then
        return false, "config must be a table"
    end
    if not config.name or config.name == "" then
        return false, "name is required"
    end
    if type(config.composition) ~= "table" then
        return false, "composition is required"
    end

    local comp = config.composition
    local inf    = comp.inf    or 0
    local mg     = comp.mg     or 0
    local at     = comp.at     or 0
    local aa     = comp.aa     or 0
    local mortar = comp.mortar or 0
    local jtac   = comp.jtac   or 0
    local total  = inf + mg + at + aa + mortar + jtac

    if total == 0 then
        return false, "composition must have at least 1 soldier"
    end

    if self:_findTemplate(config.name) then
        ctld.utils.log("WARN", "createLoadableGroup: '%s' already exists, skipping", config.name)
        return false, "template name already exists"
    end

    local tmpl = {
        name     = config.name,
        inf      = inf,  mg = mg,  at = at,  aa = aa,  mortar = mortar,  jtac = jtac,
        side     = config.side,
        custom   = true,
        disabled = false,
    }
    table.insert(self._templates, tmpl)
    self:_registerOneTemplate(tmpl)

    ctld.utils.log("INFO", "createLoadableGroup: '%s' (%d soldiers, side=%s)",
        tmpl.name, tmpl.total, tostring(tmpl.side or "both"))
    return true
end

-- Removes a template (standard or custom).
-- @param name string
-- @return boolean, string|nil
function CTLDTroopManager:removeLoadableGroup(name)
    for i, tmpl in ipairs(self._templates) do
        if tmpl.name == name then
            CTLDObjectRegistry._db[tmpl._dbKey] = nil
            table.remove(self._templates, i)
            ctld.utils.log("INFO", "removeLoadableGroup: '%s' removed", name)
            return true
        end
    end
    return false, "template not found: " .. tostring(name)
end

-- Edits a custom template's composition and/or side restriction.
-- Standard templates cannot be edited (use createLoadableGroup instead).
-- @param name   string
-- @param config table  { composition={...}, side }
-- @return boolean, string|nil
function CTLDTroopManager:editLoadableGroup(name, config)
    local tmpl = self:_findTemplate(name)
    if not tmpl then
        return false, "template not found: " .. tostring(name)
    end
    if not tmpl.custom then
        return false, "cannot edit standard template '" .. name .. "' — create a custom one instead"
    end
    if type(config) ~= "table" then
        return false, "config must be a table"
    end

    if type(config.composition) == "table" then
        local comp = config.composition
        local inf    = comp.inf    or 0
        local mg     = comp.mg     or 0
        local at     = comp.at     or 0
        local aa     = comp.aa     or 0
        local mortar = comp.mortar or 0
        local jtac   = comp.jtac   or 0
        if inf + mg + at + aa + mortar + jtac == 0 then
            return false, "composition must have at least 1 soldier"
        end
        tmpl.inf = inf; tmpl.mg = mg; tmpl.at = at
        tmpl.aa  = aa;  tmpl.mortar = mortar; tmpl.jtac = jtac
    end

    if config.side ~= nil then
        tmpl.side = config.side
    end

    -- Re-register to update ObjectRegistry and recompute total/hasJtac
    self:_registerOneTemplate(tmpl)

    ctld.utils.log("INFO", "editLoadableGroup: '%s' updated (%d soldiers, side=%s)",
        tmpl.name, tmpl.total, tostring(tmpl.side or "both"))
    return true
end

-- Hides a template from the F10 menu without removing it.
-- @param name string
-- @return boolean, string|nil
function CTLDTroopManager:disableLoadableGroup(name)
    local tmpl = self:_findTemplate(name)
    if not tmpl then return false, "template not found: " .. tostring(name) end
    tmpl.disabled = true
    ctld.utils.log("INFO", "disableLoadableGroup: '%s' hidden from menu", name)
    return true
end

-- Restores a previously disabled template in the F10 menu.
-- @param name string
-- @return boolean, string|nil
function CTLDTroopManager:enableLoadableGroup(name)
    local tmpl = self:_findTemplate(name)
    if not tmpl then return false, "template not found: " .. tostring(name) end
    tmpl.disabled = false
    ctld.utils.log("INFO", "enableLoadableGroup: '%s' restored to menu", name)
    return true
end

-- ============================================================
-- Public API — cargo queries
-- ============================================================

-- Returns the CTLDTroopGroup in transit for unitName, or nil.
function CTLDTroopManager:getInTransit(unitName)
    return self._inTransit[unitName]
end

-- Returns true if unitName has troops onboard.
function CTLDTroopManager:hasTroops(unitName)
    return self._inTransit[unitName] ~= nil
end

-- Returns troop cargo weight (kg) for unitName, or 0.
function CTLDTroopManager:getWeight(unitName)
    local group = self._inTransit[unitName]
    return group and group.weight or 0
end

-- Updates DCS internal cargo weight for this transport (troops weight only).
-- NOTE: temporary — CTLDPlayerManager will aggregate all cargo sources when built.
function CTLDTroopManager:_updateWeight(unitName)
    trigger.action.setUnitInternalCargo(unitName, self:getWeight(unitName))
end

-- ============================================================
-- loadFromZone
-- ============================================================

-- Loads a troop template onto unit from the TRZ pickup zone the unit is currently in.
-- @param unit      DCS Unit object
-- @param zone      CtldZone (zoneType == "pickup")
-- @param template  entry from ctld.gs("loadableGroups") (must have _dbKey, total, hasJtac set)
-- @return bool
function CTLDTroopManager:embarkFromTroopZone(unit, zone, template)
    local unitName  = unit:getName()
    local coalition = unit:getCoalition()
    local typeName  = unit:getTypeName()

    -- Already has troops?
    if self:hasTroops(unitName) then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("You already have troops onboard."), 10)
        return false
    end

    -- Zone coalition check
    if zone.coalition ~= 0 and zone.coalition ~= coalition then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("This pickup zone is not available to your coalition."), 10)
        return false
    end

    -- Position check: unit must be inside the zone
    if not zone:isInZone(unit:getPoint()) then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("You must land inside the pickup zone to load troops."), 10)
        return false
    end

    -- Zone active check
    if not zone.active then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("This pickup zone is not active."), 10)
        return false
    end

    -- Zone stock check (TRZ native: pickCurrentStock; 0=unlimited if pickMaxStock==0)
    if zone:hasPickup() and zone.pickMaxStock ~= 0 and zone.pickCurrentStock < template.total then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("This pickup zone is empty."), 10)
        return false
    end

    -- Transport capacity check
    local limit = self:_transportLimit(typeName)
    if template.total > limit then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("Group too large for this aircraft (capacity: %1 troops).", limit), 10)
        return false
    end

    -- Global infantry limit check per coalition
    local limits = ctld.gs("nbLimitSpawnedTroops") or { 0, 0 }
    if limits[1] ~= 0 or limits[2] ~= 0 then
        local inGame = self:_countDroppedTroops(coalition)
        if inGame + template.total > (limits[coalition] or 0) then
            trigger.action.outTextForGroup(unit:getGroup():getID(),
                ctld.tr("Infantry coalition limit reached, cannot load more troops."), 10)
            return false
        end
    end

    -- Compute weight from role counts
    local weight = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = template[role] or 0
        weight  = weight + n * (CTLDTroopManager._ROLE_WEIGHTS[role] or 109)
    end

    -- Build _aliveUnits / _jtacUnits from template role composition
    local _aliveUnits = {}
    local _jtacUnits  = {}
    local idx = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = template[role] or 0
        for i = 1, n do
            idx = idx + 1
            local slotName = string.format("%s_u%d", template.name, idx)
            _aliveUnits[slotName] = idx  -- placeholder: slot ref until DCS spawn
            if role == "jtac" then
                _jtacUnits[slotName] = true
            end
        end
    end

    -- Store transit group entity
    local troopGroup = CTLDTroopGroup:new({
        templateKey  = template._dbKey,
        templateName = template.name,
        unitTotal    = template.total,
        weight       = weight,
        coalitionId  = coalition,
        countryId    = unit:getCountry(),
        state        = CTLDTroopGroup.STATE.TRZ_LOADED,
        _aliveUnits  = _aliveUnits,
        _jtacUnits   = _jtacUnits,
    })
    troopGroup.dcsGroup = nil
    self._inTransit[unitName] = troopGroup

    -- Consume pickup stock (TRZ native API; no-op for unlimited zones)
    zone:consumeStock(template.total)

    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("Loaded: %1 (%2 troops).", template.name, template.total), 10)

    ctld.utils.log("INFO", "embarkFromTroopZone: '%s' loaded '%s' (%d units, %.0f kg)",
        unitName, template.name, template.total, weight)

    pcall(self._updateWeight, self, unitName)
    return true
end

-- ============================================================
-- disembark (fast-rope or combat drop)
-- ============================================================

-- Deploys troops from unit into combat (fast-rope if conditions met, else ground drop).
-- If inside a TRZ with objectiveFlag: troops are counted only (flag increment), no DCS group spawned.
-- @param unit  DCS Unit object
-- @return bool
function CTLDTroopManager:disembark(unit)
    local unitName = unit:getName()
    local group    = self._inTransit[unitName]

    if not group then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("No troops onboard."), 10)
        return false
    end

    local canFastRope = self:_safeToFastRope(unit)
    local onGround    = not self:_isInAir(unit)

    if not canFastRope and not onGround then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("Too high or too fast to drop troops! Hover below %1 ft or land.",
                math.floor((ctld.gs("fastRopeMaximumHeight") or 18.28) * 3.2808399)), 10)
        return false
    end

    local pt  = unit:getPoint()
    local hdg = ctld.utils.getHeadingInRadians("TroopManager.deploy", unit, true)

    -- TRZ objective check: if zone has objectiveFlag, count troops silently (no DCS group spawn)
    local exzZone = CTLDZoneManager.getInstance():isUnitInZone(unitName, "extract")
    if exzZone then
        local current = trigger.misc.getUserFlag(exzZone.objectiveFlag) or 0
        trigger.action.setUserFlag(exzZone.objectiveFlag, current + group.unitTotal)
        group:deploy(nil)
        ctld.utils.log("INFO", "deploy: %d troops sent to objective TRZ '%s' (flag %s = %d)",
            group.unitTotal, exzZone.zoneName, exzZone.objectiveFlag, current + group.unitTotal)
    else
        -- Compute circle radius: safe distance from aircraft + config offset
        local safeR   = ctld.utils.getSecureDistanceFromUnit(unitName) or 10
        local circleR = safeR + (ctld.gs("spawnDistanceInCircle") or 10)

        local dcsGroup = CTLDObjectRegistry.spawnObject(
            group.templateKey,
            group.coalitionId,
            group.countryId,
            pt.x, pt.z, hdg,
            { circleRadius = circleR }
        )

        if not dcsGroup then
            ctld.utils.log("ERROR", "deploy: spawnObject failed for key '%s'", group.templateKey)
            return false
        end

        group:deploy(dcsGroup)
        table.insert(self._droppedGroups[group.coalitionId], dcsGroup:getName())
        -- Store both key and display name to restore templateName correctly after field pickup (BUG-06)
        -- Store original weight and total for accurate weight estimation after unit losses (BUG-07)
        self._droppedTemplates[dcsGroup:getName()] = {
            key    = group.templateKey,
            name   = group.templateName,
            weight = group.weight,
            total  = group.unitTotal,
        }

        if group:hasAliveJtac() then
            local jm = CTLDJTACManager.getInstance()
            for jtacName, _ in pairs(group._jtacUnits) do
                -- JTACs are tracked at unit level (unitName) within a composite group.
                -- Use startLaseTroopUnit (Unit.getByName) — not startLase (Group.getByName).
                jm:startLaseTroopUnit(jtacName)
                ctld.utils.log("INFO", "deploy: startLaseTroopUnit('%s') for JTAC unit", jtacName)
            end
        end

        -- WPZ check: if deploy point is inside a waypoint zone, march troops to zone center
        local wpzZone = CTLDZoneManager.getInstance():getWaypointZoneAt(pt, group.coalitionId)
        if wpzZone then
            local dest    = wpzZone:getCenter()
            local wpFrom  = ctld.utils.buildWP("TroopManager.deploy.WPZ", pt,   'Off Road', 50)
            local wpDest  = ctld.utils.buildWP("TroopManager.deploy.WPZ", dest, 'Off Road', 50)
            if wpFrom and wpDest then
                local mission = {
                    id = 'Mission',
                    params = { route = { points = { wpFrom, wpDest } } },
                }
                local grpName = dcsGroup:getName()
                -- Delay 2 s: DCS group controller may be empty immediately after spawn
                timer.scheduleFunction(function(arg)
                    local grp = Group.getByName(arg.grpName)
                    if not grp or not grp:isExist() then return end
                    local ctrl = grp:getController()
                    ctrl:setOption(AI.Option.Ground.id.ALARM_STATE,
                                   AI.Option.Ground.val.ALARM_STATE.AUTO)
                    ctrl:setOption(AI.Option.Ground.id.ROE,
                                   AI.Option.Ground.val.ROE.OPEN_FIRE)
                    ctrl:setTask(arg.mission)
                end, { grpName = grpName, mission = mission }, timer.getTime() + 2)
                ctld.utils.log("INFO",
                    "deploy: WPZ '%s' — group '%s' ordered to march to zone center",
                    wpzZone.zoneName, grpName)
            end
        end
    end

    self._inTransit[unitName] = nil
    pcall(self._updateWeight, self, unitName)

    -- Confirm message
    local method = (canFastRope and self:_isInAir(unit)) and "fast-roped" or "dropped"
    local dest   = exzZone and ctld.tr("into %1", exzZone.zoneName) or ctld.tr("into combat")
    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("%1 [%2] %3.", method, group.templateName, dest), 10)

    return true
end

-- ============================================================
-- returnToBase (TRZ pickup zone: troops returned to zone stock)
-- ============================================================

-- Returns troops to the pickup zone the unit is currently in.
-- Increments zone.limit and updates the DCS flag.
-- @param unit  DCS Unit object
-- @param zone  CtldZone (zoneType == "pickup")
-- @return bool
function CTLDTroopManager:returnToTroopZone(unit, zone)
    local unitName  = unit:getName()
    local group     = self._inTransit[unitName]
    local coalition = unit:getCoalition()

    if not group then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("No troops onboard."), 10)
        return false
    end

    -- Restore pickup stock (TRZ native API; no-op for unlimited zones)
    zone:restoreStock(group.unitTotal)

    ctld.utils.log("INFO", "returnToBase: '%s' returned [%s] to TRZ '%s'",
        unitName, group.templateName, zone.zoneName)

    local jm = CTLDJTACManager.getInstance()
    for jtacName, _ in pairs(group._jtacUnits or {}) do
        jm:deregisterJTAC(jtacName)
        ctld.utils.log("INFO", "returnToTroopZone: deregisterJTAC('%s')", jtacName)
    end

    self._inTransit[unitName] = nil
    pcall(self._updateWeight, self, unitName)

    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("Troops returned to base."), 10)
    return true
end

-- ============================================================
-- embarkFromField
-- ============================================================

-- Extracts the nearest friendly dropped troop group (unit must be on the ground).
-- JTAC units are deregistered BEFORE group destruction to avoid spurious killJTAC
-- from the S_EVENT_DEAD that DCS fires on group:destroy().
-- @param unit  DCS Unit object
-- @return bool
function CTLDTroopManager:embarkFromField(unit)
    local unitName  = unit:getName()
    local coalition = unit:getCoalition()
    local typeName  = unit:getTypeName()

    if self:hasTroops(unitName) then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("You already have troops onboard."), 10)
        return false
    end

    if self:_isInAir(unit) then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("You must land to extract troops."), 10)
        return false
    end

    local nearest = self:_findNearestDropped(unit, coalition)
    if not nearest then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("No extractable troops nearby!"), 10)
        return false
    end

    local groupSize = #nearest.group:getUnits()
    local limit     = self:_transportLimit(typeName)
    if groupSize > limit then
        trigger.action.outTextForGroup(unit:getGroup():getID(),
            ctld.tr("Group too large to fit (%1 troops, limit %2 for %3).",
                groupSize, limit, typeName), 10)
        return false
    end

    local country  = nearest.group:getUnit(1):getCountry()
    local stored   = self._droppedTemplates[nearest.groupName] or {}

    -- Weight: proportional to surviving units using original avg weight (BUG-07)
    local avgWeight = (stored.weight and stored.total and stored.total > 0)
                      and (stored.weight / stored.total) or 130
    local weight    = math.floor(avgWeight * groupSize)

    -- Sync _aliveUnits / _jtacUnits from current DCS group before destroy.
    -- JTAC units identified by "JTAC" prefix — exclusive to jtac-role units (BUG-03 / BUG-05).
    local _aliveUnits = {}
    local _jtacUnits  = {}
    local dcsUnits = nearest.group:getUnits()
    for i = 1, #dcsUnits do
        local dcsUnit = dcsUnits[i]
        if dcsUnit and dcsUnit:isExist() then
            local name = dcsUnit:getName()
            _aliveUnits[name] = dcsUnit
            if name:match("^JTAC") then
                _jtacUnits[name] = true
            end
        end
    end

    -- Deregister JTACs BEFORE group:destroy() to avoid spurious killJTAC from S_EVENT_DEAD
    local jm = CTLDJTACManager.getInstance()
    for jtacName, _ in pairs(_jtacUnits) do
        jm:deregisterJTAC(jtacName)
        ctld.utils.log("INFO", "embarkFromField: deregisterJTAC('%s') called before group destroy", jtacName)
    end

    self._inTransit[unitName] = CTLDTroopGroup:new({
        templateKey  = stored.key,
        templateName = stored.name or nearest.groupName,  -- restore original template name (BUG-06)
        unitTotal    = groupSize,
        weight       = weight,
        coalitionId  = coalition,
        countryId    = country,
        state        = CTLDTroopGroup.STATE.FIELD_LOADED,
        _aliveUnits  = _aliveUnits,
        _jtacUnits   = _jtacUnits,
    })

    self:_removeFromDropped(coalition, nearest.groupName)
    nearest.group:destroy()

    pcall(self._updateWeight, self, unitName)

    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("Extracted [%1] (%2 troops).", nearest.groupName, groupSize), 10)

    ctld.utils.log("INFO", "extract: '%s' extracted group '%s' (%d units)",
        unitName, nearest.groupName, groupSize)
    return true
end

-- ============================================================
-- Menu building
-- ============================================================

-- Builds the "Troop Transport" F10 sub-menu for a player.
-- Load entries are paginated at PAGE_SIZE items per DCS submenu level.
-- @param unit        DCS Unit object
-- @param groupId     DCS group id for missionCommands
-- @param parentPath  missionCommands parent path
function CTLDTroopManager:buildMenu(unit, groupId, parentPath)
    local unitName  = unit:getName()
    local typeName  = unit:getTypeName()
    local coalition = unit:getCoalition()

    local troopPath = missionCommands.addSubMenuForGroup(groupId,
        ctld.tr("Troop Transport"), parentPath)

    -- "Unload / Extract Troops" (always present)
    missionCommands.addCommandForGroup(groupId,
        ctld.tr("Unload / Extract Troops"), troopPath,
        function()
            local u = Unit.getByName(unitName)
            if u then CTLDTroopManager.getInstance():_menuUnloadOrExtract(u) end
        end)

    -- Transport capacity for this aircraft type
    local limit = self:_transportLimit(typeName)

    -- Filter applicable templates (not disabled + side + capacity)
    local entries = {}
    for _, tmpl in ipairs(self._templates) do
        local sideOk = (tmpl.side == nil or tmpl.side == coalition)
        local sizeOk = (tmpl.total <= limit)
        if not tmpl.disabled and sideOk and sizeOk then
            table.insert(entries, tmpl)
        end
    end

    -- Paginated "Load X" entries (9 items per page, slot 0 = Unload already used)
    local PAGE_SIZE = 9
    local menuPath  = troopPath
    local itemNb    = 0

    for i, tmpl in ipairs(entries) do
        if itemNb == PAGE_SIZE and i < #entries then
            menuPath = missionCommands.addSubMenuForGroup(groupId,
                ctld.tr("Next page"), menuPath)
            itemNb = 0
        end
        local capturedTmpl = tmpl
        missionCommands.addCommandForGroup(groupId,
            ctld.tr("Load ") .. tmpl.name, menuPath,
            function()
                local u = Unit.getByName(unitName)
                if not u then return end
                local zone = CTLDZoneManager.getInstance():isUnitInZone(unitName, "pickup")
                if not zone then
                    trigger.action.outTextForGroup(u:getGroup():getID(),
                        ctld.tr("You must be in a pickup zone to load troops."), 10)
                    return
                end
                CTLDTroopManager.getInstance():embarkFromTroopZone(u, zone, capturedTmpl)
            end)
        itemNb = itemNb + 1
    end

    -- "Check Cargo"
    missionCommands.addCommandForGroup(groupId,
        ctld.tr("Check Cargo"), troopPath,
        function()
            local u = Unit.getByName(unitName)
            if u then CTLDTroopManager.getInstance():_menuCheckCargo(u) end
        end)
end

-- ============================================================
-- Polling / cleanup (called by CTLDCore)
-- ============================================================

-- Removes dead/empty groups from _droppedGroups.
function CTLDTroopManager:cleanupDeadGroups()
    for coa = 1, 2 do
        local alive = {}
        for _, name in ipairs(self._droppedGroups[coa]) do
            local g = Group.getByName(name)
            if g and g:isExist() and #g:getUnits() > 0 then
                table.insert(alive, name)
            else
                -- Also purge from _droppedTemplates to avoid stale entries (BUG-08)
                self._droppedTemplates[name] = nil
            end
        end
        self._droppedGroups[coa] = alive
    end
end

-- Removes entries for destroyed transports from _inTransit.
-- JTAC lifecycle: multi-JTAC per group (JTAC units identified by name prefix "JTAC")
-- JTAC managers keep one entry per JTAC unit, not per group.
-- When the last JTAC of a group dies, the whole group is considered "non-JTAC".

--- Finds a CTLDTroopGroup that has a live unit matching `unitName`.
-- Used by `onUnitDead` to locate the owning group after a unit is destroyed.
-- @param unitName string  DCS unit name
-- @return CTLDTroopGroup|nil
function CTLDTroopManager:_findGroupByAliveUnit(unitName)
    for unitNameKey, grp in pairs(self._inTransit) do
        if grp._aliveUnits and grp._aliveUnits[unitName] then
            return grp
        end
    end
    for coa = 1, 2 do
        for _, gname in ipairs(self._droppedGroups[coa]) do
            local g = Group.getByName(gname)
            if g and g:isExist() then
                local units = g:getUnits()
                for i = 1, #units do
                    if units[i]:isExist() and units[i]:getName() == unitName then
                        local stored  = self._droppedTemplates[gname] or {}
                        local aliveUnits = {}
                        local jtacUnits = {}
                        for j = 1, #units do
                            local u = units[j]
                            if u:isExist() then
                                local uname = u:getName()
                                aliveUnits[uname] = u
                                if uname:match("^JTAC") then
                                    jtacUnits[uname] = true
                                end
                            end
                        end
                        local grp = CTLDTroopGroup:new({
                            templateKey  = stored.key,
                            templateName = stored.name or gname,
                            unitTotal = 0,
                            weight = 0,
                            coalitionId = coa,
                            countryId = g:getUnit(1):getCountry(),
                            state = CTLDTroopGroup.STATE.DEPLOYED,
                            _aliveUnits = aliveUnits,
                            _jtacUnits = jtacUnits,
                        })
                        grp.dcsGroup = g
                        return grp
                    end
                end
            end
        end
    end
    return nil
end

--- Called from CTLDDCSEventBridge on S_EVENT_DEAD.
-- Removes the dead unit from _aliveUnits and _jtacUnits of the owning group.
-- Deregisters the JTAC from CTLDJTACManager if the dead unit was a JTAC.
-- NOTE: wasJtac is captured BEFORE _removeDeadUnit clears _jtacUnits[unitName].
-- @param unitName string  DCS unit name
function CTLDTroopManager:onUnitDead(unitName)
    local grp = self:_findGroupByAliveUnit(unitName)
    if not grp then
        ctld.utils.log("INFO", "onUnitDead: no group found for unit '%s' — skipping", unitName)
        return
    end
    -- Capture JTAC status before _removeDeadUnit erases the entry
    local wasJtac = grp._jtacUnits ~= nil and grp._jtacUnits[unitName] ~= nil
    grp:_removeDeadUnit(unitName)
    ctld.utils.log("INFO", "onUnitDead: '%s' removed from group (aliveUnits=%d, jtacUnits=%d)",
        unitName, grp:getAliveCount(), grp:getJtacCount())
    if wasJtac then
        CTLDJTACManager.get():deregisterJTAC(unitName)
        ctld.utils.log("INFO", "onUnitDead: JTAC unit '%s' deregistered", unitName)
    end
end

--- Returns the count of alive units (helper for onUnitDead logging).
-- @return number
function CTLDTroopGroup:getAliveCount()
    local n = 0
    for _ in pairs(self._aliveUnits) do n = n + 1 end
    return n
end

function CTLDTroopManager:cleanupDeadTransports()
    local jm = CTLDJTACManager.getInstance()
    for unitName, grp in pairs(self._inTransit) do
        local u = Unit.getByName(unitName)
        if not u or not u:isExist() then
            for jtacName, _ in pairs(grp._jtacUnits or {}) do
                jm:deregisterJTAC(jtacName)
                ctld.utils.log("INFO", "cleanupDeadTransports: JTAC '%s' deregistered (orphan)", jtacName)
            end
            self._inTransit[unitName] = nil
            ctld.utils.log("INFO", "cleanupDeadTransports: removed stale entry for '%s'", unitName)
        end
    end
end

-- ============================================================
-- Private helpers
-- ============================================================

-- Returns the maximum number of troops this aircraft type can carry.
function CTLDTroopManager:_transportLimit(typeName)
    local byType = ctld.gs("transportLimitByType")
    if byType and byType[typeName] then return byType[typeName] end
    return ctld.gs("numberOfTroops") or 10
end

-- Returns true if unit is in the air (AGL > 2 m).
function CTLDTroopManager:_isInAir(unit)
    local pt   = unit:getPoint()
    local gndH = land.getHeight({ x = pt.x, y = pt.z })  -- vec2: y = world-Z
    return (pt.y - gndH) > 2.0
end

-- Returns true if fast-rope conditions are met.
function CTLDTroopManager:_safeToFastRope(unit)
    if not ctld.gs("enableFastRopeInsertion") then return false end
    local maxH   = (ctld.gs("fastRopeMaximumHeight") or 18.28) + 3.0
    local pt     = unit:getPoint()
    local gndH   = land.getHeight({ x = pt.x, y = pt.z })  -- vec2: y = world-Z
    local altAGL = pt.y - gndH
    local vel    = unit:getVelocity()
    local speed  = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
    return altAGL <= maxH and speed < 2.2
end

-- Returns total alive unit count for all dropped groups of given coalition.
function CTLDTroopManager:_countDroppedTroops(coalition)
    local count = 0
    for _, name in ipairs(self._droppedGroups[coalition]) do
        local g = Group.getByName(name)
        if g and g:isExist() then
            count = count + #g:getUnits()
        end
    end
    return count
end

-- Returns { groupName, group, distM } for the nearest dropped group within maxExtractDistance, or nil.
function CTLDTroopManager:_findNearestDropped(unit, coalition)
    local pt      = unit:getPoint()
    local maxDist = ctld.gs("maxExtractDistance") or 125
    local best, bestDist = nil, maxDist

    for _, name in ipairs(self._droppedGroups[coalition]) do
        local g = Group.getByName(name)
        if g and g:isExist() and #g:getUnits() > 0 then
            local leader = g:getUnit(1)
            if leader then
                local gpt  = leader:getPoint()
                local dist = math.sqrt((pt.x - gpt.x)^2 + (pt.z - gpt.z)^2)
                if dist < bestDist then
                    bestDist = dist
                    best = { groupName = name, group = g, distM = dist }
                end
            end
        end
    end
    return best
end

-- Removes a group name from the coalition's dropped list.
function CTLDTroopManager:_removeFromDropped(coalition, groupName)
    local list = self._droppedGroups[coalition]
    for i, name in ipairs(list) do
        if name == groupName then
            table.remove(list, i)
            self._droppedTemplates[groupName] = nil
            return
        end
    end
end

-- Returns a display name for the unit (player name or callsign).
function CTLDTroopManager:_callsign(unit)
    local player = unit:getPlayerName()
    return (player and player ~= "") and player or unit:getTypeName()
end

-- ============================================================
-- Menu action handlers
-- ============================================================

-- "Unload / Extract Troops" button:
--   On ground + nearest dropped group + no troops → embarkFromField
--   Has troops + in TRZ pickup-only               → returnToTroopZone
--   Has troops + in TRZ with objectiveFlag        → disembark (flag incremented)
--   Has troops + not in any TRZ                   → disembark to combat
function CTLDTroopManager:_menuUnloadOrExtract(unit)
    local unitName  = unit:getName()
    local coalition = unit:getCoalition()
    local zm        = CTLDZoneManager.getInstance()
    local inAir     = self:_isInAir(unit)

    -- Ground + extractable group nearby + no troops onboard → embarkFromField
    if not inAir and not self:hasTroops(unitName) then
        local nearest = self:_findNearestDropped(unit, coalition)
        if nearest then
            self:embarkFromField(unit)
            return
        end
    end

    -- Has troops: TRZ with objectiveFlag takes priority over pickup-only TRZ.
    -- Mixed TRZ (hasPickup + hasExtract) → disembark to increment objective flag.
    -- Pickup-only TRZ → returnToTroopZone to restore pickup stock.
    if self:hasTroops(unitName) then
        local exzZone = zm:isUnitInZone(unitName, "extract")
        if exzZone then
            self:disembark(unit)
        else
            local pkzZone = zm:isUnitInZone(unitName, "pickup")
            if pkzZone then
                self:returnToTroopZone(unit, pkzZone)
            else
                self:disembark(unit)
            end
        end
        return
    end

    -- In air, no troops: check if there are groups to extract nearby (hint to land)
    if inAir then
        local nearest = self:_findNearestDropped(unit, coalition)
        if nearest then
            trigger.action.outTextForGroup(unit:getGroup():getID(),
                ctld.tr("Land near troops to extract them (%1m away).", math.floor(nearest.distM)), 10)
            return
        end
    end

    -- No troops, on ground, no nearby group
    trigger.action.outTextForGroup(unit:getGroup():getID(),
        ctld.tr("No troops onboard and no extractable troops nearby."), 10)
end

function CTLDTroopManager:_menuCheckCargo(unit)
    local unitName = unit:getName()
    local group    = self._inTransit[unitName]
    local msg
    if group then
        msg = ctld.tr("Cargo: [%1] — %2 troops, %3 kg",
            group.templateName, group.unitTotal, math.floor(group.weight))
    else
        msg = ctld.tr("No troops onboard.")
    end
    trigger.action.outTextForGroup(unit:getGroup():getID(), msg, 10)
end

-- ============================================================
-- Feature A — Virtual parachute
-- ============================================================

--- Parachute troops currently loaded on a transport.
-- Altitude AGL is checked at call time. If below parachuteMinAltitudeTroops,
-- a message is sent to the group and nothing happens.
-- Each unit in the group gets its own independent landing position.
-- The DCS ground group is spawned with all unit positions after descentTime.
-- Publishes OnTroopsDeployed (trigger="parachute") immediately,
-- and OnTroopsParachuteLanded after descentTime.
-- @param transport  Unit    DCS transport unit
-- @param playerObj  table   CTLDPlayer-like {groupId, unitName}
function CTLDTroopManager:parachuteTroops(transport, playerObj)
    local dropPos     = transport:getPoint()
    local groundUnder = land.getHeight({ x = dropPos.x, y = dropPos.z })
    local altAGL      = dropPos.y - groundUnder
    local minAlt      = ctld.gs("parachuteMinAltitudeTroops") or 50

    if altAGL < minAlt then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Altitude too low for parachute drop. Minimum: %dm AGL (current: %dm AGL)"),
                math.floor(minAlt), math.floor(altAGL)), 10)
        return
    end

    local troopGroup = self._inTransit[playerObj.unitName]
    if not troopGroup then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No troops onboard."), 8)
        return
    end

    local descentRate = ctld.gs("parachuteDescentRateTroops") or 5
    local unitDefs    = {}
    local landPositions = {}

    -- Resolve unit type from template registry (fallback to generic infantry)
    local template    = troopGroup.templateKey and CTLDObjectRegistry._db[troopGroup.templateKey]
    local unitCount   = troopGroup.unitTotal or 1
    local unitType    = (template and template.units and template.units[1] and template.units[1].type)
                        or "Soldier AK"

    -- Compute one landing position per unit
    local firstDescentTime = nil
    for i = 1, unitCount do
        local landPos, descentTime = ctld.utils.calcDropPosition(transport, descentRate)
        table.insert(landPositions, landPos)
        unitDefs[i] = {
            type    = unitType,
            name    = troopGroup.templateName .. "_unit" .. i,
            x       = landPos.x,
            y       = landPos.z,   -- DCS ground group: position.y = world Z axis
            heading = math.random(0, 360) * math.pi / 180,
        }
        if i == 1 then firstDescentTime = descentTime end
    end

    local descentTime = firstDescentTime or
        select(2, ctld.utils.calcDropPosition(transport, descentRate))

    -- Unload from transport cargo
    self._inTransit[playerObj.unitName] = nil

    local dropData = {
        type          = "troop",
        unitName      = troopGroup.templateName,
        dropPosition  = dropPos,
        landPositions = landPositions,
        altitude      = altAGL,
        descentTime   = descentTime,
        transport     = transport,
        player        = playerObj.unitName,
    }
    self._parachuteEffect:onStart(dropData)

    EventDispatcher.getInstance():publish("OnTroopsDeployed", {
        troops          = troopGroup,
        carrierUnitName = transport:getName(),
        player          = playerObj.unitName,
        trigger         = "parachute",
        destination     = { type = "combat", troopZone = nil },
        timestamp       = timer.getAbsTime(),
    })

    -- Capture for timer closure
    local _troopGroup   = troopGroup
    local _unitDefs     = unitDefs
    local _landPositions = landPositions
    local _dropData     = dropData
    local _coalition    = playerObj.coalition or 2

    timer.scheduleFunction(function()
        local country = coalition.getCountryCoalition and coalition.getCountryCoalition(_coalition) or _coalition
        local spawnedGroup = coalition.addGroup(country, Group.Category.GROUND, {
            name  = _troopGroup.templateName,
            task  = "Ground Nothing",
            units = _unitDefs,
        })

        local grp = Group.getByName(_troopGroup.templateName)
        if grp then
            table.insert(self._droppedGroups[_coalition] or {}, _troopGroup.templateName)
        end

        self._parachuteEffect:onLanded(_dropData)

        EventDispatcher.getInstance():publish("OnTroopsParachuteLanded", {
            troops        = _troopGroup,
            spawnedGroup  = spawnedGroup,
            positions     = _landPositions,
            transport     = transport:getName(),
            player        = playerObj.unitName,
            startAltitude = altAGL,
            timestamp     = timer.getAbsTime(),
        })
    end, {}, timer.getTime() + descentTime)
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Build the "Troop Commands" F10 submenu for a player (called once at spawn).
-- Creates the submenu container then delegates to refreshMenuSection for content.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDTroopManager:buildMenuSection(playerObj, menu)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.troops) then return end

    local root     = ctld.tr("CTLD")
    local troopSub = ctld.tr("Troop Commands")
    -- Create the container node (idempotent). Content is populated by refreshMenuSection.
    menu:addSubMenu({ root }, troopSub, { order = 20 })
    self:refreshMenuSection(playerObj)
end

--- Rebuild the "Troop Commands" menu branch for playerObj.
-- Called on S_EVENT_LAND and S_EVENT_TAKEOFF to reflect the player's current
-- state (in air / on ground / zone membership).
-- @param playerObj CTLDPlayer
function CTLDTroopManager:refreshMenuSection(playerObj)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.troops) then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root     = ctld.tr("CTLD")
    local troopSub = ctld.tr("Troop Commands")

    -- Clear dynamic content; the "Troop Commands" submenu container is preserved.
    menu:clearBranch({ root, troopSub })

    local unit  = Unit.getByName(playerObj.unitName)
    local inAir = not unit or self:_isInAir(unit)

    if not inAir and unit then
        local pt = unit:getPoint()

        -- "Unload / Extract" — ground only
        local hasTroops   = self:hasTroops(playerObj.unitName)
        local hasNearby   = self:_findNearestDropped(unit, playerObj.coalition) ~= nil
        if hasTroops or hasNearby then
            menu:addCommand({ root, troopSub }, ctld.tr("Unload / Extract Troops"),
                function(arg)
                    local u = Unit.getByName(arg.unitName)
                    if not u then return end
                    CTLDTroopManager.getInstance():_menuUnloadOrExtract(u)
                end,
                { unitName = playerObj.unitName })
        end

        -- "Load from X" — one submenu per TRZ the player is physically inside
        local limit = self:_transportLimit(playerObj.typeName)

        for _, zone in pairs(CTLDZoneManager.getInstance():getTroopZonesForCoalition(playerObj.coalition)) do
            if zone:hasPickup() and zone:isInZone(pt) then
                local zName   = zone.zoneName   -- short name used for getTroopZone() lookup in callback
                local zoneSub = string.format(ctld.tr("Load from %s"), "TRZ_" .. zName)
                -- Stock available in this zone (unlimited if pickMaxStock==0)
                local zoneStock = (zone.pickMaxStock == 0) and math.huge or zone.pickCurrentStock
                menu:addSubMenu({ root, troopSub }, zoneSub)
                for _, tmpl in ipairs(self._templates) do
                    local sideOk  = (tmpl.side == nil or tmpl.side == playerObj.coalition)
                    local sizeOk  = (tmpl.total <= limit)
                    local stockOk = (tmpl.total <= zoneStock)
                    if not tmpl.disabled and sideOk and sizeOk and stockOk then
                        local capturedTmpl  = tmpl
                        local capturedZName = zName
                        menu:addCommand({ root, troopSub, zoneSub },
                            ctld.tr("Load ") .. tmpl.name,
                            function(arg)
                                local u = Unit.getByName(arg.unitName)
                                if not u then return end
                                local z = CTLDZoneManager.getInstance():getTroopZone(arg.zoneName)
                                if not z then
                                    trigger.action.outTextForGroup(u:getGroup():getID(),
                                        ctld.tr("Zone not found."), 10)
                                    return
                                end
                                CTLDTroopManager.getInstance():embarkFromTroopZone(u, z, arg.tmpl)
                            end,
                            { unitName = playerObj.unitName, zoneName = capturedZName, tmpl = capturedTmpl })
                    end
                end
            end
        end

        -- "Check Troops Onboard"
        menu:addCommand({ root, troopSub }, ctld.tr("Check Troops Onboard"),
            function(arg)
                local u = Unit.getByName(arg.unitName)
                if not u then return end
                local tm    = CTLDTroopManager.getInstance()
                local group = tm._inTransit[arg.unitName]
                if group then
                    trigger.action.outTextForGroup(u:getGroup():getID(),
                        ctld.tr("Onboard: %1 (%2 troops)", group.templateName, group.unitTotal), 10)
                else
                    trigger.action.outTextForGroup(u:getGroup():getID(),
                        ctld.tr("No troops onboard."), 10)
                end
            end,
            { unitName = playerObj.unitName })

        -- "Parachute Troops" — if capable
        local acts2 = (ctld.gs("unitActions") or {})[playerObj.typeName]
        if acts2 and acts2.canParachute then
            menu:addCommand({ root, troopSub }, ctld.tr("Parachute Troops"),
                function(arg)
                    local transport = Unit.getByName(arg.unitName)
                    if not transport then return end
                    CTLDTroopManager.getInstance():parachuteTroops(transport, arg)
                end,
                { unitName = playerObj.unitName, groupId = playerObj.groupId,
                  coalition = playerObj.coalition })
        end
    end

    menu:refresh()
    ctld.utils.log("INFO", "CTLDTroopManager:refreshMenuSection — unit=%s inAir=%s",
        playerObj.unitName, tostring(inAir))
end

-- ============================================================
-- Public ctld.* API — LoadableGroup wrappers
-- ============================================================

--- Create a custom loadable group template.
-- @param config table  { name, composition={inf,mg,at,aa,mortar,jtac}, side }
-- @return boolean, string|nil
function ctld.createLoadableGroup(config)
    return CTLDTroopManager.getInstance():createLoadableGroup(config)
end

--- Remove a loadable group template (standard or custom).
-- @param name string
-- @return boolean, string|nil
function ctld.removeLoadableGroup(name)
    return CTLDTroopManager.getInstance():removeLoadableGroup(name)
end

--- Edit a custom loadable group template.
-- Standard templates are refused.
-- @param name   string
-- @param config table  { composition={...}, side }
-- @return boolean, string|nil
function ctld.editLoadableGroup(name, config)
    return CTLDTroopManager.getInstance():editLoadableGroup(name, config)
end

--- Hide a template from the F10 menu.
-- @param name string
-- @return boolean, string|nil
function ctld.disableLoadableGroup(name)
    return CTLDTroopManager.getInstance():disableLoadableGroup(name)
end

--- Restore a disabled template in the F10 menu.
-- @param name string
-- @return boolean, string|nil
function ctld.enableLoadableGroup(name)
    return CTLDTroopManager.getInstance():enableLoadableGroup(name)
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Resolve a count or composition table to the closest available template.
-- integer → template whose total is nearest; table {inf,mg,...} → sum totals then match.
-- @param coalitionId number  (unused — templates are coalition-agnostic)
-- @param number      number|table
-- @return table|nil  template
function CTLDTroopManager:_resolveTemplateForLegacy(coalitionId, number)
    if #self._templates == 0 then return nil end
    if type(number) == "table" then
        local total = 0
        for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
            total = total + (number[role] or 0)
        end
        number = total
    end
    local n = tonumber(number) or 1
    local best, bestDelta = nil, math.huge
    for _, tmpl in ipairs(self._templates) do
        if not tmpl.disabled then
            local delta = math.abs((tmpl.total or 0) - n)
            if delta < bestDelta then bestDelta = delta; best = tmpl end
        end
    end
    return best
end

--- Spawn a deployable troop group at a DCS trigger zone (MM DO SCRIPT).
-- @param side        string         "red" | "blue"
-- @param number      number|table   troop count or composition {inf=N,mg=N,...}
-- @param triggerName string         DCS trigger zone name
-- @param radius      number         random spread radius in metres (0 = at center)
-- @return boolean
function CTLDTroopManager:spawnGroupAtTrigger(side, number, triggerName, radius)
    local trig = trigger.misc.getZone(triggerName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDTroopManager:spawnGroupAtTrigger — zone not found: %s", tostring(triggerName))
        return false
    end
    local p2 = { x = trig.point.x, y = trig.point.z }
    local pt = { x = p2.x, y = land.getHeight(p2), z = p2.y }
    return self:spawnGroupAtPoint(side, number, pt, radius)
end

--- Spawn a deployable troop group at a Vec3 point (MM DO SCRIPT).
-- The closest template by unit count is used; group is registered as droppable.
-- @param side    string         "red" | "blue"
-- @param number  number|table   troop count or composition table
-- @param point   table          vec3 {x, y, z}
-- @param radius  number         random spread radius in metres
-- @return boolean
function CTLDTroopManager:spawnGroupAtPoint(side, number, point, radius)
    local coalitionId = (side == "red") and coalition.side.RED or coalition.side.BLUE
    local countryId   = (coalitionId == coalition.side.RED) and country.id.RUSSIA or country.id.USA
    radius = math.max(0, radius or 0)

    local tmpl = self:_resolveTemplateForLegacy(coalitionId, number)
    if not tmpl then
        ctld.utils.log("ERROR", "CTLDTroopManager:spawnGroupAtPoint — no template available")
        return false
    end

    local dcsGroup = CTLDObjectRegistry.spawnObject(
        tmpl._dbKey, coalitionId, countryId,
        point.x, point.z, 0,
        { circleRadius = radius }
    )
    if not dcsGroup then
        ctld.utils.log("ERROR", "CTLDTroopManager:spawnGroupAtPoint — spawnObject failed for key '%s'", tostring(tmpl._dbKey))
        return false
    end
    table.insert(self._droppedGroups[coalitionId], dcsGroup:getName())
    ctld.utils.log("INFO", "CTLDTroopManager:spawnGroupAtPoint — '%s' spawned (%s, %d units)",
        dcsGroup:getName(), side, tmpl.total)
    return true
end

--- Pre-load a named transport with troops, replacing any existing cargo.
-- Uses the template closest to number for the transport's coalition.
-- @param unitName string         DCS unit name of the transport
-- @param number   number|table   troop count or composition
-- @param troops   boolean        legacy param (ignored — always loads infantry template)
-- @return boolean
function CTLDTroopManager:preLoadTransport(unitName, number, troops)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDTroopManager:preLoadTransport — unit not found: %s", tostring(unitName))
        return false
    end
    local coalitionId = unit:getCoalition()
    local tmpl = self:_resolveTemplateForLegacy(coalitionId, number)
    if not tmpl then
        ctld.utils.log("ERROR", "CTLDTroopManager:preLoadTransport — no template for '%s'", unitName)
        return false
    end
    local weight = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        weight = weight + (tmpl[role] or 0) * (CTLDTroopManager._ROLE_WEIGHTS[role] or 109)
    end

    local _aliveUnits = {}
    local _jtacUnits  = {}
    local idx = 0
    for _, role in ipairs(CTLDTroopManager._ROLE_ORDER) do
        local n = tmpl[role] or 0
        for i = 1, n do
            idx = idx + 1
            local slotName = string.format("%s_u%d", tmpl.name, idx)
            _aliveUnits[slotName] = idx
            if role == "jtac" then
                _jtacUnits[slotName] = true
            end
        end
    end

    self._inTransit[unitName] = CTLDTroopGroup:new({
        templateKey  = tmpl._dbKey,
        templateName = tmpl.name,
        unitTotal    = tmpl.total,
        weight       = weight,
        coalitionId  = coalitionId,
        countryId    = unit:getCountry(),
        state        = CTLDTroopGroup.STATE.TRZ_LOADED,
        _aliveUnits  = _aliveUnits,
        _jtacUnits   = _jtacUnits,
    })
    self:_updateWeight(unitName)
    ctld.utils.log("INFO", "CTLDTroopManager:preLoadTransport — '%s' loaded [%s]", unitName, tmpl.name)
    return true
end

--- Force-deploy all troops from a named transport.
-- @param unitName string  DCS unit name
-- @return boolean
function CTLDTroopManager:unloadTransport(unitName)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDTroopManager:unloadTransport — unit not found: %s", tostring(unitName))
        return false
    end
    if not self:hasTroops(unitName) then return false end
    return self:deploy(unit)
end

--- Force-load troops into a named transport from the nearest active pickup zone.
-- Uses the first available template. No-op if no pickup zone found.
-- @param unitName string  DCS unit name
-- @return boolean
function CTLDTroopManager:loadTransport(unitName)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        ctld.utils.log("WARN", "CTLDTroopManager:loadTransport — unit not found: %s", tostring(unitName))
        return false
    end
    local zone = CTLDZoneManager.getInstance():getTroopZoneForUnit(unitName)
    if not zone or not zone:hasPickup() then
        ctld.utils.log("WARN", "CTLDTroopManager:loadTransport — no pickup zone for '%s'", unitName)
        return false
    end
    local tmpl = self._templates[1]
    if not tmpl then return false end
    return self:embarkFromTroopZone(unit, zone, tmpl)
end

--- Unload troops from a named AI transport when an enemy is detected within distance.
-- No-op for player-controlled units. Requires CTLDJTACDetector (LOS check).
-- @param unitName string  DCS unit name
-- @param distance number  detection radius in metres
-- @return boolean  true if troops were unloaded
function CTLDTroopManager:unloadInProximityToEnemy(unitName, distance)
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then return false end
    local player = unit:getPlayerName()
    if player and player ~= "" then return false end  -- AI only
    if not self:hasTroops(unitName) then return false end
    local enemy = CTLDJTACDetector.findNearestVisibleEnemy(unit, "all", distance)
    if not enemy then return false end
    return self:deploy(unit)
end

--- Start a recurring watcher counting dropped groups in a zone, writing DCS flags.
-- Reschedules every 5 seconds. Call once from a DO SCRIPT trigger.
-- @param zoneName string          DCS trigger zone name
-- @param blueFlag number|string   flag for BLUE group count (nil = skip)
-- @param redFlag  number|string   flag for RED group count (nil = skip)
function CTLDTroopManager:startGroupCountWatcher(zoneName, blueFlag, redFlag)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDTroopManager:startGroupCountWatcher — zone not found: %s", tostring(zoneName))
        return
    end
    local center = { x = trig.point.x, y = trig.point.y, z = trig.point.z }
    local radius = trig.radius
    local self_ref = self
    local function _tick()
        local blueCount, redCount = 0, 0
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.BLUE] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() and #g:getUnits() > 0 then
                local u = g:getUnit(1)
                if u and ctld.utils.getDistance("groupWatcher", u:getPoint(), center) <= radius then
                    blueCount = blueCount + 1
                end
            end
        end
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.RED] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() and #g:getUnits() > 0 then
                local u = g:getUnit(1)
                if u and ctld.utils.getDistance("groupWatcher", u:getPoint(), center) <= radius then
                    redCount = redCount + 1
                end
            end
        end
        if blueFlag then trigger.action.setUserFlag(blueFlag, blueCount) end
        if redFlag  then trigger.action.setUserFlag(redFlag,  redCount)  end
        timer.scheduleFunction(function()
            self_ref:startGroupCountWatcher(zoneName, blueFlag, redFlag)
        end, nil, timer.getTime() + 5)
    end
    _tick()
end

--- Start a recurring watcher counting dropped units in a zone, writing DCS flags.
-- @param zoneName string          DCS trigger zone name
-- @param blueFlag number|string   flag for BLUE unit count (nil = skip)
-- @param redFlag  number|string   flag for RED unit count (nil = skip)
function CTLDTroopManager:startUnitCountWatcher(zoneName, blueFlag, redFlag)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDTroopManager:startUnitCountWatcher — zone not found: %s", tostring(zoneName))
        return
    end
    local center = { x = trig.point.x, y = trig.point.y, z = trig.point.z }
    local radius = trig.radius
    local self_ref = self
    local function _tick()
        local blueCount, redCount = 0, 0
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.BLUE] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() then
                for _, u in ipairs(g:getUnits()) do
                    if u:isExist() and ctld.utils.getDistance("unitWatcher", u:getPoint(), center) <= radius then
                        blueCount = blueCount + 1
                    end
                end
            end
        end
        for _, name in ipairs(self_ref._droppedGroups[coalition.side.RED] or {}) do
            local g = Group.getByName(name)
            if g and g:isExist() then
                for _, u in ipairs(g:getUnits()) do
                    if u:isExist() and ctld.utils.getDistance("unitWatcher", u:getPoint(), center) <= radius then
                        redCount = redCount + 1
                    end
                end
            end
        end
        if blueFlag then trigger.action.setUserFlag(blueFlag, blueCount) end
        if redFlag  then trigger.action.setUserFlag(redFlag,  redCount)  end
        timer.scheduleFunction(function()
            self_ref:startUnitCountWatcher(zoneName, blueFlag, redFlag)
        end, nil, timer.getTime() + 5)
    end
    _tick()
end

-- End : CTLD_troop.lua
-- ====================================================================================================
-- Start : CTLD_crate.lua
-- ============================================================
-- CTLD_crate.lua
-- CTLDCrate entity + CTLDCrateManager singleton
--
-- Dependencies: CTLDConfig (ctld.gs), CTLDUtils, EventDispatcher
--
-- Crate lifecycle states:
--   spawned  : on ground, freshly created (never moved)
--   loaded   : inside / attached to a transport
--   falling  : in air, descending (drop or parachute)
--   landed   : on ground after a transport cycle
--   unpacked : contents deployed (terminal state)
--
-- spawnMethod values:
--   crate_spawn   : spawned from F10 menu (logistics pool)
--   vehicle_pack  : result of packing a vehicle
--   mission_maker : pre-placed by mission maker (detected via INIT-B)
--
-- NOTE: Feature A (virtual parachute) stubs are present but
--       not implemented. Search "Feature A" to locate them.
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDCrate  (entity)
-- ============================================================

CTLDCrate = class()

CTLDCrate.STATE = {
    SPAWNED  = "spawned",
    LOADED   = "loaded",
    FALLING  = "falling",
    LANDED   = "landed",
    UNPACKED = "unpacked",
}

CTLDCrate.SPAWN_METHOD = {
    CRATE_SPAWN   = "crate_spawn",
    VEHICLE_PACK  = "vehicle_pack",
    MISSION_MAKER = "mission_maker",
    MENU_CTLD     = "menu_ctld",
}

--- Constructor.
-- @param data table:
--   crateName (string)          DCS unitName of the StaticObject
--   descriptor (table)          CTLD crate descriptor (from spawnableCrates)
--   spawnMethod (string)        CTLDCrate.SPAWN_METHOD.*
--   position (vec3)
--   coalition (number)          coalition.side.*
--   heading (number|nil)        radians, defaults to 0
--   spawnedBy (string|nil)      player name if spawned via menu
--   dcsStatic (StaticObject|nil)
function CTLDCrate:init(data)
    self.crateName    = data.crateName
    self.descriptor   = data.descriptor
    self.state        = CTLDCrate.STATE.SPAWNED
    self.spawnMethod  = data.spawnMethod
    self.spawnedBy    = data.spawnedBy or nil
    self.spawnTime    = timer.getAbsTime()
    self.position     = data.position
    self.heading      = data.heading or 0
    self.coalition    = data.coalition
    self.loadedBy     = nil
    self.loadTime     = nil
    self.dcsStatic    = data.dcsStatic or nil
    self.modelKey     = data.modelKey  or "load"
    self.canBeUnpacked = true
    -- Feature A: virtual parachute
    self.isParachuting          = false
    self.parachuteStartAltitude = nil
    self.estimatedLandingTime   = nil
    self.fromParachute          = false   -- true → eligible for autoUnpack on landing
    -- Feature B: virtual slingload
    self.inTransitOnSlingload   = false
    self.timestamp              = timer.getAbsTime()
end

--- Load the crate into a transport unit.
-- @param transport Unit
function CTLDCrate:load(transport)
    self.state    = CTLDCrate.STATE.LOADED
    self.loadedBy = transport
    self.loadTime = timer.getAbsTime()
end

--- Unload the crate to the ground (transport is landed).
-- @param position vec3
function CTLDCrate:unload(position)
    self.state    = CTLDCrate.STATE.LANDED
    self.position = position
    self.loadedBy = nil
    self.loadTime = nil
end

--- Drop the crate in flight (transitions to falling).
-- @param position vec3  current air position at drop time
function CTLDCrate:drop(position)
    self.state    = CTLDCrate.STATE.FALLING
    self.position = position
    self.loadedBy = nil
    self.loadTime = nil
end

--- [Feature A stub] Start virtual parachute descent.
-- @param altitude number  current altitude AGL (metres)
function CTLDCrate:startParachute(altitude)
    -- TODO Feature A: implement parachute physics (descent rate, lateral drift)
    self.state                   = CTLDCrate.STATE.FALLING
    self.isParachuting           = true
    self.parachuteStartAltitude  = altitude
end

--- Crate touches the ground (after falling or parachuting).
-- @param position vec3
function CTLDCrate:land(position)
    self.state         = CTLDCrate.STATE.LANDED
    self.position      = position
    self.isParachuting = false
end

--- Mark crate as unpacked (contents deployed).
function CTLDCrate:unpack()
    self.state = CTLDCrate.STATE.UNPACKED
end

--- Destroy the associated DCS static object.
function CTLDCrate:destroy()
    if self.dcsStatic and self.dcsStatic:isExist() then
        self.dcsStatic:destroy()
    end
    self.dcsStatic = nil
end

--- Returns true if the crate is on the ground and interactable.
function CTLDCrate:isOnGround()
    if self.state ~= CTLDCrate.STATE.SPAWNED
       and self.state ~= CTLDCrate.STATE.LANDED then
        return false
    end
    -- Also verify the DCS static still physically exists (guards against crates
    -- destroyed by combat before S_EVENT_DEAD could unregister them).
    if self.dcsStatic then
        return self.dcsStatic:isExist()
    end
    -- No DCS ref (parachuted crate landing pending): trust state only
    return true
end

--- Returns true if the crate is currently in a transport.
function CTLDCrate:isLoaded()
    return self.state == CTLDCrate.STATE.LOADED
end

--- Returns true if this crate can be unpacked.
-- A complete crate set anywhere on the ground can be unpacked at any time.
function CTLDCrate:canUnpack()
    if not self:isOnGround()  then return false end
    if not self.canBeUnpacked then return false end
    return true
end

-- ============================================================
-- ============================================================
-- CTLDSmokeManager  (Feature H — Smoke auto-resume)
-- Singleton. Tracks smokes dropped via CTLD menus per player.
-- When a player enables auto-resume, their smokes are re-triggered
-- every smokeAutoResumeInterval seconds (default 270s, DCS lasts ~5min).
-- ============================================================

CTLDSmokeManager = class()
local _smInstance = nil

function CTLDSmokeManager.getInstance()
    if _smInstance == nil then
        _smInstance = setmetatable({}, CTLDSmokeManager)
        -- Per-player state: { active=bool, smokes=[{pos,color,launchTime}] }
        _smInstance._players = {}
        -- Start the periodic check (every 15s — lightweight, no re-trigger unless interval reached)
        timer.scheduleFunction(function(_, t)
            CTLDSmokeManager.getInstance():_tick()
            return t + 15
        end, nil, timer.getTime() + 15)
    end
    return _smInstance
end

--- Returns true if the player has auto-resume enabled.
function CTLDSmokeManager:isActive(playerName)
    local p = self._players[playerName]
    if p == nil then return ctld.gs("smokeAutoResume") == true end
    return p.active == true
end

--- Toggle auto-resume for a player. Returns new state (bool).
-- Deactivating clears the stored smoke list so stale smokes are not
-- replayed if the player re-activates later.
function CTLDSmokeManager:toggle(playerName)
    if not self._players[playerName] then
        self._players[playerName] = { active = false, smokes = {} }
    end
    local newState = not self._players[playerName].active
    self._players[playerName].active = newState
    if not newState then
        self._players[playerName].smokes = {}
    end
    return newState
end

--- Register a smoke dropped by a player (called from doSmoke).
-- @param playerName string
-- @param pos        table  {x,y,z} world position (on ground)
-- @param color      number trigger.smokeColor.*
function CTLDSmokeManager:registerSmoke(playerName, pos, color)
    if not self._players[playerName] then
        self._players[playerName] = { active = ctld.gs("smokeAutoResume") == true, smokes = {} }
    end
    local list = self._players[playerName].smokes
    list[#list + 1] = { pos = pos, color = color, launchTime = timer.getTime() }
end

--- Remove all tracked smokes for a player (e.g. on disconnect).
function CTLDSmokeManager:clearSmokes(playerName)
    if self._players[playerName] then
        self._players[playerName].smokes = {}
    end
end

--- Periodic tick: re-trigger smokes whose interval has elapsed (per active player).
function CTLDSmokeManager:_tick()
    local interval = ctld.gs("smokeAutoResumeInterval") or 270
    local now      = timer.getTime()
    for playerName, pState in pairs(self._players) do
        if pState.active then
            local list    = pState.smokes
            local newList = {}
            for _, entry in ipairs(list) do
                if now - entry.launchTime >= interval then
                    -- Re-trigger and reset the timer
                    pcall(trigger.action.smoke, entry.pos, entry.color)
                    ctld.utils.log("INFO", "CTLDSmokeManager: auto-resume smoke for '%s'", playerName)
                    newList[#newList + 1] = { pos = entry.pos, color = entry.color, launchTime = now }
                else
                    newList[#newList + 1] = entry
                end
            end
            pState.smokes = newList
        end
    end
end

-- ============================================================
-- CTLDCrateManager  (singleton)
-- ============================================================

CTLDCrateManager = class()

local _cmInstance = nil

function CTLDCrateManager.getInstance()
    if _cmInstance == nil then
        _cmInstance = setmetatable({}, CTLDCrateManager)
        _cmInstance.crates            = {}   -- [crateName] = CTLDCrate
        _cmInstance._parachuteEffect  = CTLDNullParachuteEffect:new()
        _cmInstance._hoverStatus      = {}   -- [unitName] = secondsRemaining
        _cmInstance._nativeCrateLink  = {}   -- [crateName] = {lx,ly,lz} local-frame offset at DCS-native load time
        local pm = CTLDPlayerManager.getInstance()
        pm:registerMenuSection({ key = "crates", manager = _cmInstance, method = "buildMenuSection",  configKey = "enableCrates",    order = 40 })
        pm:registerMenuSection({ key = "smoke",  manager = _cmInstance, method = "buildSmokeSection", configKey = "enableSmokeDrop", order = 80 })
        -- Refresh "Load Crate" submenu for all players near a crate when it appears or disappears.
        local ed = EventDispatcher.getInstance()
        ed:subscribe("OnCrateSpawned", function(payload)
            CTLDCrateManager.getInstance():_refreshNearbyPlayers(payload.position)
        end)
        ed:subscribe("OnCrateCleared", function(payload)
            CTLDCrateManager.getInstance():_refreshNearbyPlayers(payload.position)
        end)
        -- Feature B: start hover-slingload polling (1s tick)
        timer.scheduleFunction(function()
            CTLDCrateManager.getInstance():checkHoverStatus()
        end, {}, timer.getTime() + 1)
        -- Detect crates destroyed by combat (S_EVENT_DEAD on the static object).
        local ok, bridge = pcall(CTLDDCSEventBridge.getInstance)
        if ok and bridge then
            bridge:register(_cmInstance, world.event.S_EVENT_DEAD, "onCrateDead")
        end
        -- Pre-process spawnableCrates config (two-pass: singleCrates + auto singleTypeSets + mixedSets validation)
        _cmInstance:_processSpawnableCrates()
    end
    return _cmInstance
end

--- Pre-process spawnableCrates config into an internal structure used by the menu builder.
-- Two-pass:
--   Pass 1 — separate singleCrates (weight field) from mixedSets (mixedSet field).
--   Pass 2 — auto-generate singleTypeSet for each singleCrate with cratesRequired > 1
--             when enableAllCrates AND singleCrate.showSets are both true (default).
-- Pass 3 — validate each mixedSet: all weights must resolve to a known singleCrate in
--           the same category; invalid mixedSets are excluded and trigger a MM warning.
-- Results stored in self._processedCrates[category] and self._weightIndex[weight].
function CTLDCrateManager:_processSpawnableCrates()
    local spawnableCrates = ctld.gs("spawnableCrates") or {}
    local showCrateSets   = ctld.gs("enableAllCrates") ~= false
    local allSuffix       = " - " .. ctld.tr("All crates")

    self._processedCrates = {}
    self._weightIndex     = {}
    local warnings        = {}

    for category, entries in pairs(spawnableCrates) do
        local singleCrates  = {}
        local mixedSets     = {}
        local catWeightIdx  = {}

        -- Pass 1: separate entries by type
        for _, entry in ipairs(entries) do
            if entry.weight then
                table.insert(singleCrates, entry)
                catWeightIdx[entry.weight]    = entry
                self._weightIndex[entry.weight] = entry
            elseif entry.mixedSet then
                table.insert(mixedSets, entry)
            else
                ctld.logWarning("_processSpawnableCrates: entry in '%s' has neither weight nor mixedSet — skipped", category)
            end
        end

        -- Pass 2: generate singleTypeSet for qualifying singleCrates
        local processedSingle = {}
        for _, sc in ipairs(singleCrates) do
            local entry = { singleCrate = sc }
            local cr    = sc.cratesRequired or 1
            if cr > 1 and showCrateSets and (sc.showSets ~= false) then
                local weights = {}
                for i = 1, cr do weights[i] = sc.weight end
                entry.singleTypeSet = {
                    multiple       = weights,
                    desc           = sc.desc .. allSuffix,
                    side           = sc.side,
                    isJTAC         = sc.isJTAC,
                    _autoGenerated = true,
                }
            end
            table.insert(processedSingle, entry)
        end

        -- Pass 3: validate mixedSets
        local processedMixed = {}
        for _, ms in ipairs(mixedSets) do
            local valid = true
            for _, w in ipairs(ms.mixedSet) do
                if not catWeightIdx[w] then
                    local msg = string.format(
                        "CTLD config error: mixedSet '%s' references weight %.4f not found in category '%s'",
                        tostring(ms.desc), w, category)
                    ctld.logWarning(msg)
                    table.insert(warnings, msg)
                    valid = false
                end
            end
            if valid then
                -- Build processed entry: alias mixedSet → multiple for spawn compatibility
                local proc = {}
                for k, v in pairs(ms) do proc[k] = v end
                proc.multiple = ms.mixedSet
                table.insert(processedMixed, proc)
            end
        end

        self._processedCrates[category] = {
            singleCrates = processedSingle,
            mixedSets    = processedMixed,
        }
    end

    -- Display MM startup warnings if any validation errors found
    if #warnings > 0 then
        local msg = "CTLD — spawnableCrates config errors:\n" .. table.concat(warnings, "\n")
        timer.scheduleFunction(function()
            trigger.action.outText(msg, 30)
        end, {}, timer.getTime() + 5)
    end
end

--- Refresh the "Load Crate" submenu for all players within 200 m of a position.
-- Called on OnCrateSpawned and OnCrateCleared so every nearby transport sees
-- the current list regardless of who triggered the action.
-- @param position vec3  reference point (crate position)
function CTLDCrateManager:_refreshNearbyPlayers(position)
    if not position then return end
    local pm = CTLDPlayerManager.getInstance()
    for unitName in pairs(pm._players) do
        local unit = Unit.getByName(unitName)
        if unit and unit:isExist() then
            local dist = ctld.utils.getDistance("_refreshNearbyPlayers", unit:getPoint(), position)
            if dist <= 300 then
                self:refreshLoadCrateSectionForUnit(unitName)
                self:refreshUnpackSectionForUnit(unitName)
            end
        end
    end
end

--- Refresh the "Load Crate" submenu for a single player looked up by unit name.
-- @param unitName string
function CTLDCrateManager:refreshLoadCrateSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshLoadCrateSection(playerObj) end
end

--- Rebuild the "Load Crate" dynamic submenu for playerObj.
-- Groups available crates within 50 m by descriptor type with count.
-- Called on land, crate spawn, crate cleared, and after each load action.
-- @param playerObj CTLDPlayer
function CTLDCrateManager:refreshLoadCrateSection(playerObj)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local cratesSub = ctld.tr("Crate Commands")
    local loadSub   = ctld.tr("Load Crate")

    menu:clearBranch({ root, cratesSub, loadSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, cratesSub, loadSub },
            ctld.tr("Land to load crates"), function() end, {})
        menu:refresh()
        return
    end

    -- Group nearby crates (50 m) by descriptor type
    local nearby = self:getCratesInRange(transport:getPoint(), 50)
    local byType = {}   -- [desc] = { count, descriptor }
    for _, crate in ipairs(nearby) do
        local desc = crate.descriptor and crate.descriptor.desc or "Unknown"
        if not byType[desc] then
            byType[desc] = { count = 0, descriptor = crate.descriptor }
        end
        byType[desc].count = byType[desc].count + 1
    end

    if not next(byType) then
        menu:addCommand({ root, cratesSub, loadSub },
            ctld.tr("No crates within 50m"), function() end, {})
    else
        for desc, data in pairs(byType) do
            local label = string.format("%s (%d)", desc, data.count)
            menu:addCommand({ root, cratesSub, loadSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    if ctld.utils.inAir(t) then
                        trigger.action.outTextForGroup(t:getGroup():getID(),
                            ctld.tr("You must land before you can load a crate!"), 10)
                        return
                    end
                    local limits   = ctld.gs("internalCargoLimits") or {}
                    local capacity = limits[t:getTypeName()] or 1
                    local onboard  = 0
                    local mgr = CTLDCrateManager.getInstance()
                    for _, c in pairs(mgr.crates) do
                        if c:isLoaded() and c.loadedBy == t then onboard = onboard + 1 end
                    end
                    if onboard >= capacity then
                        trigger.action.outTextForGroup(t:getGroup():getID(),
                            ctld.tr("Maximum number of crates are on board!"), 10)
                        return
                    end
                    local candidates = mgr:getCratesInRange(t:getPoint(), 50)
                    local best, bestDist = nil, math.huge
                    for _, c in ipairs(candidates) do
                        if c.descriptor and c.descriptor.desc == arg.crateDesc then
                            local d = ctld.utils.getDistance("loadCrate", t:getPoint(), c.position)
                            if d < bestDist then bestDist = d; best = c end
                        end
                    end
                    if not best then
                        trigger.action.outTextForGroup(t:getGroup():getID(),
                            ctld.tr("No crates within 50m to load!"), 10)
                        mgr:refreshLoadCrateSectionForUnit(arg.unitName)
                        return
                    end
                    mgr:loadCrate(best.crateName, t)
                    trigger.action.outTextForGroup(t:getGroup():getID(),
                        ctld.tr("Loaded %1 crate!", best.descriptor.desc), 10)
                end,
                { unitName = playerObj.unitName, crateDesc = desc })
        end
    end
    menu:refresh()
end

--- Refresh the "Unpack Crate" submenu for a single player by unit name.
-- @param unitName string
function CTLDCrateManager:refreshUnpackSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshUnpackSection(playerObj) end
end

--- Rebuild the "Unpack Crate" dynamic submenu for playerObj.
-- Lists assembleable crate sets (count >= cratesRequired) within 300 m.
-- Each entry spawns the vehicle at unpack time.
-- Called on land, crate spawn, crate cleared.
-- @param playerObj CTLDPlayer
function CTLDCrateManager:refreshUnpackSection(playerObj)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local cratesSub = ctld.tr("Crate Commands")
    local unpackSub = ctld.tr("Unpack Crate")

    menu:clearBranch({ root, cratesSub, unpackSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, cratesSub, unpackSub },
            ctld.tr("Land to unpack crates"), function() end, {})
        menu:refresh()
        return
    end

    local nearby = self:getCratesInRange(transport:getPoint(), 300)

    -- FOB sentinel (unit = "FOB"): handled by CTLDFOBManager, not spawned as vehicles.
    local FOB_SENTINELS = { ["FOB"] = true }

    -- Group ground crates by descriptor.unit. FOB sentinels are excluded from this table.
    local byUnit    = {}   -- [unitType] = { count, descriptor }
    local unitOrder = {}
    local fobCount  = 0
    for _, crate in ipairs(nearby) do
        if crate:isOnGround() and crate.canBeUnpacked
            and crate.descriptor and crate.descriptor.unit
        then
            local ut = crate.descriptor.unit
            if FOB_SENTINELS[ut] then
                fobCount = fobCount + 1
            else
                if not byUnit[ut] then
                    byUnit[ut] = { count = 0, descriptor = crate.descriptor }
                    table.insert(unitOrder, ut)
                end
                byUnit[ut].count = byUnit[ut].count + 1
            end
        end
    end

    local hasAny = false

    -- Standard vehicle unpack entries (non-FOB)
    for _, ut in ipairs(unitOrder) do
        local info     = byUnit[ut]
        local required = info.descriptor.cratesRequired or 1
        if info.count >= required then
            hasAny = true
            local label = string.format("%s (%d/%d)", info.descriptor.desc, info.count, required)
            menu:addCommand({ root, cratesSub, unpackSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    local gid = t:getGroup():getID()
                    if ctld.utils.inAir(t) then
                        trigger.action.outTextForGroup(gid,
                            ctld.tr("You must land before unpacking crates!"), 10)
                        return
                    end
                    local mgr   = CTLDCrateManager.getInstance()
                    local nearC = mgr:getCratesInRange(t:getPoint(), 300)
                    -- Collect crates for unpack
                    local toUnpack = {}
                    for _, c in ipairs(nearC) do
                        if c:isOnGround() and c.canBeUnpacked
                            and c.descriptor
                            and c.descriptor.unit == arg.unitType
                        then
                            table.insert(toUnpack, c)
                            if #toUnpack >= arg.cratesRequired then break end
                        end
                    end
                    if #toUnpack < arg.cratesRequired then
                        trigger.action.outTextForGroup(gid,
                            ctld.tr("Not enough crates nearby to unpack!"), 10)
                        mgr:refreshUnpackSectionForUnit(arg.unitName)
                        return
                    end
                    -- Delegate to AA assembly manager if this crate belongs to an AA template.
                    -- CTLDCrateAssemblyManager handles repair/rearm/assembly with correct
                    -- DCS type names and its own 100m offset + 50m radius placement.
                    local aaMgr = CTLDCrateAssemblyManager.getInstance()
                    if aaMgr:tryUnpackOrRepair(t, toUnpack[1], mgr.crates) then
                        -- AA manager consumed the action — also destroy the other collected crates
                        -- (tryUnpackOrRepair only destroys what it assembles internally).
                        -- Note: for single-crate AA parts tryUnpackOrRepair already handles destruction.
                        return
                    end

                    -- Standard (non-AA) path: unpack crates, spawn vehicle ≥ 50 m away.
                    for _, c in ipairs(toUnpack) do
                        mgr:unpackCrate(c.crateName, t)
                    end
                    local MIN_UNPACK_DIST = 50
                    local safeDist = math.max(
                        MIN_UNPACK_DIST,
                        (ctld.utils.getSecureDistanceFromUnit(arg.unitName) or 10) + 5)
                    local spawnInfo = ctld.utils.getSpawnObjectPositions(t, 1, safeDist)
                    local spawnPos  = spawnInfo.positions[1]
                    local desc = arg.descriptor
                    if desc and desc.unit and spawnPos then
                        local coa = arg.coalition
                        local cId = (coa == coalition.side.RED) and country.id.RUSSIA or country.id.USA
                        mgr:_spawnUnpacked(desc, spawnPos, coa, cId, playerObj.unitName)
                    end
                    trigger.action.outTextForGroup(gid,
                        ctld.tr("%1 unpacked successfully!", arg.descriptor.desc), 10)
                end,
                {
                    unitName       = playerObj.unitName,
                    groupId        = playerObj.groupId,
                    coalition      = playerObj.coalition,
                    unitType       = ut,
                    cratesRequired = required,
                    descriptor     = info.descriptor,
                })
        end
    end

    -- FOB unpack entry: delegate to CTLDFOBManager (handles its own crate counting & guards)
    if fobCount > 0 then
        hasAny = true
        local fobDesc     = CTLDCrateManager.getInstance():findDescriptorByUnitType("FOB")
        local fobRequired = (fobDesc and fobDesc.cratesRequired) or 3
        local fobLabel    = string.format("%s (%d/%d)", ctld.tr("Build FOB"), fobCount, fobRequired)
        menu:addCommand({ root, cratesSub, unpackSub }, fobLabel,
            function(arg)
                local t = Unit.getByName(arg.unitName)
                if not (t and t:isExist()) then return end
                CTLDFOBManager.getInstance():unpackFOBCrates(t, arg.unitName)
            end,
            { unitName = playerObj.unitName })
    end

    if not hasAny then
        menu:addCommand({ root, cratesSub, unpackSub },
            ctld.tr("No complete crate sets nearby"), function() end, {})
    end
    menu:refresh()
end

--- Replace the parachute visual effect handler.
-- @param effect CTLDParachuteEffect
function CTLDCrateManager:setParachuteEffect(effect)
    self._parachuteEffect = effect
end

-- ============================================================
-- Feature B — Virtual Slingload
-- ============================================================

--- Return the first slingloaded crate for a given transport, or nil.
-- @param transport Unit
-- @return CTLDCrate or nil
function CTLDCrateManager:_getSlingloadedCrate(transport)
    for _, crate in pairs(self.crates) do
        if crate.inTransitOnSlingload and crate.loadedBy == transport then
            return crate
        end
    end
    return nil
end

--- Polling tick (1 s). Called by the timer loop started in getInstance().
-- For each active player with canSlingload=true and in-air transport:
--   1. Overspeed check: if speed > maxSlingloadSpeed → crate lost.
--   2. Hover pickup: find nearest eligible ground crate, count down hoverTime,
--      then hook it (load + destroy DCS static + publish OnCrateLoaded).
function CTLDCrateManager:checkHoverStatus()
    -- Reschedule unconditionally
    timer.scheduleFunction(function()
        CTLDCrateManager.getInstance():checkHoverStatus()
    end, {}, timer.getTime() + 1)

    -- Scan for crates destroyed by combat (S_EVENT_DEAD not reliable for statics).
    -- isOnGround() now checks dcsStatic:isExist(), so a stale SPAWNED crate whose
    -- static was destroyed will return false — unregister it and refresh nearby menus.
    for name, crate in pairs(self.crates) do
        if (crate.state == CTLDCrate.STATE.SPAWNED or crate.state == CTLDCrate.STATE.LANDED)
            and crate.dcsStatic
            and not crate.dcsStatic:isExist()
        then
            local pos = crate.position
            self:_unregister(name)
            ctld.utils.log("INFO",
                "CTLDCrateManager:checkHoverStatus — unregistered dead static crate: %s", name)
            if pos then self:_refreshNearbyPlayers(pos) end
        end
    end

    -- DCS-native cargo detection (always, independent of slingload config)
    self:_checkNativeDCSCargo()

    if ctld.gs("enableHoverSlingload") ~= true then return end

    local unitActions = ctld.gs("unitActions")        or {}
    local cargoLimits = ctld.gs("internalCargoLimits") or {}
    local maxDist     = ctld.gs("maxDistanceFromCrate") or 5.5
    local minH        = ctld.gs("minimumHoverHeight")   or 7.5
    local maxH        = ctld.gs("maximumHoverHeight")   or 12.0
    local hoverTime   = ctld.gs("hoverTime")            or 10
    local maxSpeed    = ctld.gs("maxSlingloadSpeed")    or 50

    local players = CTLDPlayerManager.getInstance()._players

    for unitName, playerObj in pairs(players) do
        local acts = unitActions[playerObj.typeName]
        if acts and acts.canSlingload then
            local transport = Unit.getByName(unitName)
            if transport and transport:isExist() and ctld.utils.inAir(transport) then

                -- 1. Overspeed check
                local vel   = transport:getVelocity()
                local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z)
                if speed > maxSpeed then
                    local lost = self:_getSlingloadedCrate(transport)
                    if lost then
                        lost.inTransitOnSlingload = false
                        lost:destroy()
                        self:_unregister(lost.crateName)
                        self:_publish("OnCrateLost", {
                            crate     = lost,
                            crateName = lost.crateName,
                            coalition = lost.coalition,
                            transport = transport,
                            trigger   = "slingload_overspeed",
                            timestamp = timer.getAbsTime(),
                        })
                        trigger.action.outTextForGroup(playerObj.groupId,
                            string.format(ctld.tr("Too fast! Slingloaded crate lost: %s"), lost.descriptor.desc), 10)
                        CTLDPlayerManager.getInstance():refreshForUnit(unitName)
                    end
                    self._hoverStatus[unitName] = nil

                else
                    -- 2. Hover pickup (only if below capacity)
                    local count = 0
                    for _, c in pairs(self.crates) do
                        if c.inTransitOnSlingload and c.loadedBy == transport then
                            count = count + 1
                        end
                    end
                    local capacity = cargoLimits[playerObj.typeName] or 1

                    if count < capacity then
                        local transportPos  = transport:getPoint()
                        local nearestCrate  = nil
                        local nearestDist   = math.huge
                        local warnTooLow    = false
                        local warnTooHigh   = false

                        for _, crate in pairs(self.crates) do
                            if crate:isOnGround()
                                and crate.descriptor
                                and crate.descriptor.unit ~= "FOB"
                            then
                                local cratePos = (crate.dcsStatic and crate.dcsStatic:isExist())
                                    and crate.dcsStatic:getPoint()
                                    or  crate.position
                                local dist = ctld.utils.getDistance("checkHoverStatus", transportPos, cratePos)
                                if dist < maxDist then
                                    local heightDiff = transportPos.y - cratePos.y
                                    if heightDiff >= minH and heightDiff <= maxH then
                                        if dist < nearestDist then
                                            nearestCrate = crate
                                            nearestDist  = dist
                                        end
                                    elseif heightDiff < minH then
                                        warnTooLow = true
                                    else
                                        warnTooHigh = true
                                    end
                                end
                            end
                        end

                        if nearestCrate then
                            if self._hoverStatus[unitName] == nil then
                                self._hoverStatus[unitName] = hoverTime
                            end
                            self._hoverStatus[unitName] = self._hoverStatus[unitName] - 1
                            if self._hoverStatus[unitName] > 0 then
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(
                                        ctld.tr("Hovering above %s crate.\n\nHold hover for %d seconds!\n\nIf the countdown stops you're too far away!"),
                                        nearestCrate.descriptor.desc,
                                        self._hoverStatus[unitName]), 10, true)
                            else
                                self._hoverStatus[unitName] = nil
                                nearestCrate.inTransitOnSlingload = true
                                nearestCrate:load(transport)
                                if nearestCrate.dcsStatic and nearestCrate.dcsStatic:isExist() then
                                    nearestCrate.dcsStatic:destroy()
                                    nearestCrate.dcsStatic = nil
                                end
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(ctld.tr("Slingloaded %s crate!"), nearestCrate.descriptor.desc), 10)
                                self:_publish("OnCrateLoaded", {
                                    crate           = nearestCrate,
                                    crateName       = nearestCrate.crateName,
                                    carrierUnitName = transport:getName(),
                                    coalition       = nearestCrate.coalition,
                                    descriptor      = nearestCrate.descriptor,
                                    trigger         = "slingload",
                                    timestamp       = timer.getAbsTime(),
                                })
                                CTLDPlayerManager.getInstance():refreshForUnit(unitName)
                            end
                        else
                            if warnTooLow then
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(ctld.tr("Too low to hook crate.\n\nHold hover for %d seconds"), hoverTime), 5, true)
                            elseif warnTooHigh then
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    string.format(ctld.tr("Too high to hook crate.\n\nHold hover for %d seconds"), hoverTime), 5, true)
                            end
                            self._hoverStatus[unitName] = nil
                        end
                    else
                        self._hoverStatus[unitName] = nil
                    end
                end

            else
                -- Not in air: reset hover counter
                self._hoverStatus[unitName] = nil
            end
        end
    end
end

--- Return true if world-space point `pt` is inside the bounding box of `unitPos`.
-- unitPos : result of unit:getPosition() = { p=Vec3, x=Vec3, y=Vec3, z=Vec3 }
-- bbox    : { min=Vec3, max=Vec3 } in local coords (from unit:getDesc().box)
-- margin  : extra metres added on every face (default 0)
local function _pointInBBox(unitPos, bbox, pt, margin)
    margin = margin or 0
    local dx = pt.x - unitPos.p.x
    local dy = pt.y - unitPos.p.y
    local dz = pt.z - unitPos.p.z
    local lx = dx * unitPos.x.x + dy * unitPos.x.y + dz * unitPos.x.z
    local ly = dx * unitPos.y.x + dy * unitPos.y.y + dz * unitPos.y.z
    local lz = dx * unitPos.z.x + dy * unitPos.z.y + dz * unitPos.z.z
    return lx >= (bbox.min.x - margin) and lx <= (bbox.max.x + margin)
       and ly >= (bbox.min.y - margin) and ly <= (bbox.max.y + margin)
       and lz >= (bbox.min.z - margin) and lz <= (bbox.max.z + margin)
end

--- Detect DCS-native cargo load/unload via bounding-box containment (1 s tick).
-- Called from checkHoverStatus() unconditionally.
--
-- No S_EVENT_CARGO_LOADED / S_EVENT_CARGO_UNLOADED exists in the DCS API.
-- Detection is purely positional:
--   LOAD  : crate.dcsStatic:getPoint() is inside the transport's 3-D bounding box.
--           Works while the aircraft is still on the ground (before takeoff),
--           so CTLD marks the crate as taken before any other transport sees it.
--   UNLOAD: crate state is LOADED (via dcs_native, so dcsStatic still exists),
--           and the static's current position is now OUTSIDE the transport's bbox.
--
-- CTLD-managed loads call crate:destroy() → dcsStatic = nil: those crates are
-- silently skipped here (outer check `dcsStatic and dcsStatic:isExist()`).
function CTLDCrateManager:_checkNativeDCSCargo()
    local dynamicUnits = ctld.gs("dynamicCargoUnits") or {}
    if #dynamicUnits == 0 then return end

    -- Build candidate transport list (ALL dynamic transports, ground OR air).
    -- We pre-fetch position and bbox so we don't call getPosition()/getDesc()
    -- more than once per transport per tick.
    local pm         = CTLDPlayerManager.getInstance()
    local transports = {}   -- array of { transport, unitName, playerObj, unitPos, bbox }
    for unitName, playerObj in pairs(pm._players) do
        local transport = Unit.getByName(unitName)
        if transport and transport:isExist() and self:_isDynamicCapable(transport) then
            local desc = transport:getDesc()
            if desc and desc.box then
                transports[#transports + 1] = {
                    transport = transport,
                    unitName  = unitName,
                    playerObj = playerObj,
                    unitPos   = transport:getPosition(),
                    bbox      = desc.box,
                }
            end
        end
    end

    for _, crate in pairs(self.crates) do
        local dcsStatic = crate.dcsStatic
        if dcsStatic and dcsStatic:isExist() then
            local cratePos = dcsStatic:getPoint()

            -- ── LOAD detection ─────────────────────────────────────────────
            -- ── LOAD detection ─────────────────────────────────────────────
            -- Crate is on ground AND its static is inside a transport's bbox.
            -- 0.5 m margin to account for attachment offsets.
            if crate:isOnGround() then
                for _, entry in ipairs(transports) do
                    if _pointInBBox(entry.unitPos, entry.bbox, cratePos, 0.5) then
                        -- Memorize local-frame offset for drift-based unload detection.
                        local up = entry.unitPos
                        local dx = cratePos.x - up.p.x
                        local dy = cratePos.y - up.p.y
                        local dz = cratePos.z - up.p.z
                        self._nativeCrateLink[crate.crateName] = {
                            lx = dx * up.x.x + dy * up.x.y + dz * up.x.z,
                            ly = dx * up.y.x + dy * up.y.y + dz * up.y.z,
                            lz = dx * up.z.x + dy * up.z.y + dz * up.z.z,
                        }
                        crate:load(entry.transport)
                        self:_publish("OnCrateLoaded", {
                            crate           = crate,
                            crateName       = crate.crateName,
                            carrierUnitName = entry.unitName,
                            coalition       = crate.coalition,
                            descriptor      = crate.descriptor,
                            method          = "dcs_native",
                            timestamp       = timer.getAbsTime(),
                        })
                        pm:refreshForUnit(entry.unitName)
                        self:refreshUnpackSectionForUnit(entry.unitName)
                        local ref = self._nativeCrateLink[crate.crateName]
                        ctld.utils.log("INFO",
                            "CTLDCrateManager: DCS native LOAD — crate=%s carrier=%s lx=%.2f ly=%.2f lz=%.2f",
                            crate.crateName, entry.unitName, ref.lx, ref.ly, ref.lz)
                        local _descLabel = crate.descriptor and crate.descriptor.desc or crate.crateName
                        trigger.action.outTextForGroup(entry.playerObj.groupId,
                            string.format("[CTLD] Crate loaded (DCS native): %s", _descLabel), 8)
                        break
                    end
                end

            -- ── UNLOAD detection ───────────────────────────────────────────
            -- Crate is LOADED and dcsStatic is still alive → DCS-native path.
            -- (CTLD-managed loads destroy the static → dcsStatic = nil, never reach here.)
            -- Detect unload by local-frame offset drift: recompute {lx,ly,lz} each tick
            -- and compare to linkOffsetRef memorised at load time.
            -- DCS places the released crate *behind* the aircraft (collision avoidance),
            -- so the offset changes immediately on release — seuil 1 m is sufficient.
            elseif crate:isLoaded() then
                local transport = crate.loadedBy
                if not transport or not transport:isExist() then
                    -- Transport destroyed while crate was natively loaded: reset.
                    self._nativeCrateLink[crate.crateName] = nil
                    crate.position     = cratePos
                    crate.state        = CTLDCrate.STATE.LANDED
                    crate.loadedBy     = nil
                    crate.loadTime     = nil
                    crate.fromParachute = false
                    ctld.utils.log("INFO",
                        "CTLDCrateManager: DCS native UNLOAD (transport lost) — crate=%s",
                        crate.crateName)
                else
                    local ref = self._nativeCrateLink[crate.crateName]
                    if ref then
                        local up = transport:getPosition()
                        local dx = cratePos.x - up.p.x
                        local dy = cratePos.y - up.p.y
                        local dz = cratePos.z - up.p.z
                        local lx = dx * up.x.x + dy * up.x.y + dz * up.x.z
                        local ly = dx * up.y.x + dy * up.y.y + dz * up.y.z
                        local lz = dx * up.z.x + dy * up.z.y + dz * up.z.z
                        local dlx = lx - ref.lx
                        local dly = ly - ref.ly
                        local dlz = lz - ref.lz
                        local drift = math.sqrt(dlx*dlx + dly*dly + dlz*dlz)
                        if drift > 1.0 then
                            local carrierName = transport:getName()
                            local playerObj   = pm:getPlayer(carrierName)
                            -- Determine if transport is airborne at release time
                            local tp        = transport:getPoint()
                            local groundH   = land.getHeight({ x = tp.x, z = tp.z })
                            local inFlight  = (tp.y - groundH) > 5
                            self._nativeCrateLink[crate.crateName] = nil
                            crate.position = cratePos
                            crate.state    = CTLDCrate.STATE.LANDED
                            crate.loadedBy = nil
                            crate.loadTime = nil
                            if inFlight then
                                crate.fromParachute = true
                            end
                            self:_publish("OnCrateUnloaded", {
                                crate      = crate,
                                crateName  = crate.crateName,
                                coalition  = crate.coalition,
                                descriptor = crate.descriptor,
                                method     = "dcs_native",
                                timestamp  = timer.getAbsTime(),
                            })
                            if playerObj then
                                pm:refreshForUnit(carrierName)
                                self:refreshUnpackSectionForUnit(carrierName)
                                self:refreshLoadCrateSection(playerObj)
                                self:refreshRequestEquipmentSection(playerObj)
                            end
                            ctld.utils.log("INFO",
                                "CTLDCrateManager: DCS native UNLOAD — crate=%s drift=%.2f inFlight=%s fromParachute=%s",
                                crate.crateName, drift, tostring(inFlight), tostring(crate.fromParachute))
                            local _descLabel2 = crate.descriptor and crate.descriptor.desc or crate.crateName
                            local _unloadMsg  = inFlight
                                and string.format("[CTLD] Crate dropped (DCS native, airborne): %s", _descLabel2)
                                or  string.format("[CTLD] Crate unloaded (DCS native): %s", _descLabel2)
                            if playerObj then
                                trigger.action.outTextForGroup(playerObj.groupId, _unloadMsg, 8)
                            end
                            if crate.fromParachute then
                                self:_checkAutoUnpack(crate)
                            end
                        end
                    end
                end
            end
        end
    end
end

--- Release the slingloaded crate safely (transport at or near ground, AGL ≤ maximumHoverHeight).
-- Refuses if transport AGL > maximumHoverHeight with an informational message.
-- Transitions crate: loaded → landed. Spawns at a position offset ahead of the transport.
-- Publishes OnCrateUnloaded(trigger="slingload_release").
-- @param transport    Unit
-- @param playerObj    table   {groupId, unitName}
function CTLDCrateManager:releaseSlingload(transport, playerObj)
    local crate = self:_getSlingloadedCrate(transport)
    if not crate then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No slingloaded crate on board."), 8)
        return
    end

    local pos      = transport:getPoint()
    local groundH  = land.getHeight({ x = pos.x, y = pos.z })
    local agl      = pos.y - groundH
    local maxRelH  = ctld.gs("maximumHoverHeight") or 12.0

    if agl > maxRelH then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Too high to release slingload. Descend below %dm AGL (current: %dm AGL)."),
                math.floor(maxRelH), math.floor(agl)), 8)
        return
    end

    -- Spawn position: directly below transport on terrain
    local spawnPos = { x = pos.x, y = groundH, z = pos.z }
    crate.inTransitOnSlingload = false
    -- unloadCrate: transitions state, respawns static, publishes OnCrateUnloaded + OnCrateSpawned
    self:unloadCrate(crate.crateName, spawnPos, "slingload_release")
    trigger.action.outTextForGroup(playerObj.groupId,
        string.format(ctld.tr("%s crate safely released."), crate.descriptor.desc), 10)
    CTLDPlayerManager.getInstance():refreshForUnit(playerObj.unitName)
end

--- Cut the slingload (emergency drop, any altitude).
-- AGL > 40m → crate is destroyed (too high, impact damage).
-- AGL ≤ 40m → crate lands at a position computed from transport inertia (no parachute delay).
-- Publishes OnCrateUnloaded(trigger="slingload_cut") or OnCrateLost(trigger="slingload_cut_impact").
-- @param transport    Unit
-- @param playerObj    table   {groupId, unitName}
function CTLDCrateManager:cutSlingload(transport, playerObj)
    local crate = self:_getSlingloadedCrate(transport)
    if not crate then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No slingloaded crate on board."), 8)
        return
    end

    local pos      = transport:getPoint()
    local groundH  = land.getHeight({ x = pos.x, y = pos.z })
    local agl      = pos.y - groundH

    crate.inTransitOnSlingload = false

    if agl > 40.0 then
        -- Too high: crate destroyed on impact
        local lostPos = crate.position
        crate:destroy()
        self:_unregister(crate.crateName)
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Too high! %s crate destroyed on impact."), crate.descriptor.desc), 10)
        self:_publish("OnCrateLost", {
            crate     = crate,
            crateName = crate.crateName,
            coalition = crate.coalition,
            transport = transport,
            trigger   = "slingload_cut_impact",
            timestamp = timer.getAbsTime(),
        })
        self:_publish("OnCrateCleared", {
            crateName  = crate.crateName,
            position   = lostPos,
            coalition  = crate.coalition,
            descriptor = crate.descriptor,
            reason     = "destroyed",
            timestamp  = timer.getAbsTime(),
        })
    else
        -- Drop with inertia drift (reuses FA calcDropPosition, descentRate=0 → immediate land)
        local landPos, _ = ctld.utils.calcDropPosition(transport, 0)
        crate:land(landPos)
        -- TODO: re-spawn DCS static at landPos (requires coalition.addStaticObject — pending Hoggit verification)
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("%s crate dropped below you."), crate.descriptor.desc), 10)
        self:_publish("OnCrateUnloaded", {
            crate           = crate,
            crateName       = crate.crateName,
            position        = landPos,
            coalition       = crate.coalition,
            method          = "slingload_cut",
            trigger         = "slingload_cut",
            timestamp       = timer.getAbsTime(),
        })
        -- Crate landed: notify nearby players it is loadable.
        self:_publish("OnCrateSpawned", {
            crate      = crate,
            crateName  = crate.crateName,
            position   = landPos,
            coalition  = crate.coalition,
            descriptor = crate.descriptor,
            spawnedBy  = nil,
            spawnMethod = "slingload_cut",
            timestamp  = timer.getAbsTime(),
        })
    end
    CTLDPlayerManager.getInstance():refreshForUnit(playerObj.unitName)
end

-- ============================================================
-- Internal helpers
-- ============================================================

local _log = ctld.utils.log

function CTLDCrateManager:_register(crate)
    self.crates[crate.crateName] = crate
end

--- S_EVENT_DEAD handler: remove a crate destroyed by combat from the registry.
-- Without this, the crate remains in self.crates with state SPAWNED, causing
-- getCratesInRange to count it and the Unpack menu to show wrong counts (e.g. 3/3
-- when only 2 physical crates exist).
function CTLDCrateManager:onCrateDead(event)
    if not event or not event.initiator then return end
    local ok, name = pcall(function() return event.initiator:getName() end)
    if not ok or not name then return end
    local crate = self.crates[name]
    if not crate then return end
    local pos = crate.dcsStatic and crate.dcsStatic:isExist()
        and crate.dcsStatic:getPoint() or nil
    self:_unregister(name)
    ctld.utils.log("INFO", "CTLDCrateManager:onCrateDead — crate destroyed by combat: %s", name)
    if pos then
        self:_refreshNearbyPlayers(pos)
    end
end

function CTLDCrateManager:_unregister(crateName)
    self.crates[crateName] = nil
end

function CTLDCrateManager:_publish(eventName, payload)
    EventDispatcher.getInstance():publish(eventName, payload)
end

-- ============================================================
-- Public API
-- ============================================================

--- Return true if the unit type is listed in dynamicCargoUnits (native DCS cargo system).
-- @param unit DCS Unit
-- @return bool
function CTLDCrateManager:_isDynamicCapable(unit)
    local typeLower = string.lower(unit:getTypeName())
    for _, name in ipairs(ctld.gs("dynamicCargoUnits") or {}) do
        if string.find(typeLower, string.lower(name), 1, true) then
            return true
        end
    end
    return false
end

--- Resolve the spawnableCratesModels key for a given transport unit.
-- Returns "dynamic" if the unit is in dynamicCargoUnits and slingLoad is off,
-- "sling" if slingLoad is enabled, "load" otherwise.
-- @param unit DCS Unit
-- @return string  "load" | "sling" | "dynamic"
function CTLDCrateManager:_crateModelKey(unit)
    if ctld.gs("slingLoad") then return "sling" end
    if self:_isDynamicCapable(unit) then return "dynamic" end
    return "load"
end

--- Spawn a new crate from the F10 menu or as the result of packing a vehicle.
-- Uses coalition.addStaticObject (Hoggit: DCS_func_addStaticObject).
-- @param descriptor  table         CTLD crate descriptor (from spawnableCrates)
-- @param position    vec3
-- @param coalitionId number        coalition.side.*
-- @param spawnedBy   string|nil    player/trigger name
-- @param spawnMethod string        CTLDCrate.SPAWN_METHOD.*
-- @param countryId   number|nil    DCS country id; if nil, derived from coalition
-- @param modelKey    string|nil    key in spawnableCratesModels ("load"|"sling"|"dynamic"); auto if nil
-- @return CTLDCrate or nil
--- Create one DCS static cargo object and return its name and handle.
-- Shared by spawnCrate (new crate) and _spawnStatic (crate returning to ground).
-- @param weight      number   cargo mass in kg
-- @param position    vec3     world position {x, y, z}
-- @param coalitionId number   coalition.side.*
-- @param countryId   number|nil  DCS country id; derived from coalitionId if nil
-- @param modelKey    string|nil  key in spawnableCratesModels; auto if nil
-- @param label       string|nil  human-readable content name (e.g. "FOB Crate")
--                               shown in the DCS cargo interface and F10 list.
--                               Sanitised: spaces→_, special chars stripped.
-- @return string name, StaticObject|nil  (nil if dynAddStatic failed)
function CTLDCrateManager:_spawnStatic(weight, position, coalitionId, countryId, modelKey, label)
    local models = ctld.gs("spawnableCratesModels") or {}
    local key    = modelKey or (ctld.gs("slingLoad") and "sling" or "load")
    local model  = models[key] or models["load"] or {}

    local cId = countryId
    if not cId then
        cId = (coalitionId == coalition.side.RED) and country.id.RUSSIA or country.id.USA
    end

    local uid  = ctld.utils.getNextUniqId()
    local name
    if label and label ~= "" then
        -- Sanitise: keep alphanumeric, dash, underscore; replace spaces with _
        local safe = label:gsub("%s+", "_"):gsub("[^%w%-%_]", "")
        name = string.format("CTLD_%s_%d", safe, uid)
    else
        name = string.format("CTLD_Crate_%d", uid)
    end
    local data = {
        name     = name,
        x        = position.x,
        y        = position.z,   -- dynAddStatic maps y → DCS world-Z axis
        heading  = 0,
        type     = model.type     or "ammo_cargo",
        canCargo = model.canCargo or false,
        mass     = weight,
        country  = cId,
        dead     = false,
    }
    if model.shape_name then data.shape_name = model.shape_name end

    local ok, err = pcall(function() ctld.utils.dynAddStatic("CTLDCrateManager:_spawnStatic", data) end)
    if not ok then
        _log("CTLDCrateManager:_spawnStatic - dynAddStatic failed: " .. tostring(err), "WARNING")
        return name, nil
    end
    return name, StaticObject.getByName(name)
end

function CTLDCrateManager:spawnCrate(descriptor, position, coalitionId, spawnedBy, spawnMethod, countryId, modelKey)
    if not (descriptor and position) then
        _log("CTLDCrateManager:spawnCrate - missing descriptor or position", "WARNING")
        return nil
    end

    local crateName, dcsStatic = self:_spawnStatic(
        descriptor.weight, position, coalitionId, countryId, modelKey, descriptor.desc)
    if not dcsStatic then return nil end

    local models  = ctld.gs("spawnableCratesModels") or {}
    local usedKey = modelKey or (ctld.gs("slingLoad") and "sling" or "load")
    local crate = CTLDCrate:new({
        crateName   = crateName,
        descriptor  = descriptor,
        spawnMethod = spawnMethod or CTLDCrate.SPAWN_METHOD.CRATE_SPAWN,
        position    = position,
        heading     = 0,
        coalition   = coalitionId,
        spawnedBy   = spawnedBy,
        dcsStatic   = dcsStatic,
        modelKey    = (models[usedKey] and usedKey) or "load",
    })
    self:_register(crate)

    self:_publish("OnCrateSpawned", {
        crate       = crate,
        crateName   = crateName,
        descriptor  = descriptor,
        position    = position,
        coalition   = coalitionId,
        spawnedBy   = spawnedBy,
        spawnMethod = crate.spawnMethod,
        timestamp   = timer.getAbsTime(),
    })

    timer.scheduleFunction(function()
        self:_refreshNearbyPlayers(position)
    end, {}, timer.getTime() + 0.001)

    return crate
end

--- Recreate the DCS static for a crate returning to ground (static was destroyed on load).
-- Generates a new unique name, re-indexes self.crates, updates crate.crateName/dcsStatic.
-- @param crate    CTLDCrate
-- @param position vec3
-- @return bool
function CTLDCrateManager:_respawnStatic(crate, position)
    local label = crate.descriptor and crate.descriptor.desc or nil
    local newName, dcsStatic = self:_spawnStatic(
        crate.descriptor.weight, position, crate.coalition, nil, crate.modelKey, label)
    if not dcsStatic then return false end

    self.crates[crate.crateName] = nil
    crate.crateName = newName
    crate.dcsStatic = dcsStatic
    self.crates[newName] = crate
    return true
end

--- Spawn N crates in a straight line from a transport unit.
-- The axis direction is chosen randomly within the front sector for standard
-- units, or within the rear sector for native-cargo-capable units, so that
-- successive multi-crate spawns land at different angles and do not overlap.
--   Front sector : [-45°, +45°]  relative to unit heading (axisOffsetDeg 315..45)
--   Rear  sector : [135°, 225°]  relative to unit heading (axisOffsetDeg 135..225)
--
-- @param descriptors  table   ordered list of descriptor tables (one per crate)
-- @param transport    Unit    the requesting/packing transport unit
-- @param coalitionId  number  coalition.side.*
-- @param spawnedBy    string  unit name for attribution
-- @param spawnMethod  string  CTLDCrate.SPAWN_METHOD.*
-- @return number spawned count, table spawnInfo {positions, clock, distance}
function CTLDCrateManager:spawnCratesAligned(descriptors, transport, coalitionId, spawnedBy, spawnMethod)
    -- Detect native-cargo-capable transport (UH-1H, CH-47, Mi-8, etc.)
    local isDynamic = self:_isDynamicCapable(transport)
    local modelKey  = self:_crateModelKey(transport)

    -- Random axis within the appropriate sector (degrees relative to unit forward)
    local axisOffsetDeg
    if isDynamic then
        axisOffsetDeg = ctld.utils.RandomReal("spawnCratesAligned", 135, 225)  -- rear sector
    else
        -- Front sector wraps: pick randomly in [-45, +45], then normalise to [0, 360)
        local raw = ctld.utils.RandomReal("spawnCratesAligned", -45, 45)
        axisOffsetDeg = (raw + 360) % 360
    end

    local safeDist  = (ctld.utils.getSecureDistanceFromUnit(transport:getName()) or 10) + 5
    local spacing   = (ctld.gs and ctld.gs("crateSpacing")) or 5
    local n         = #descriptors
    local spawnInfo = ctld.utils.getSpawnObjectPositions(transport, n, safeDist, spacing, axisOffsetDeg)
    local spawned   = 0
    for i, descriptor in ipairs(descriptors) do
        local pos = spawnInfo.positions[i]
        if descriptor and pos then
            if self:spawnCrate(descriptor, pos, coalitionId, spawnedBy, spawnMethod, nil, modelKey) then
                spawned = spawned + 1
            end
        end
    end
    return spawned, spawnInfo
end

--- Register a crate pre-placed by the mission maker (called from INIT-B).
-- @param obj  StaticObject  DCS cargo static (already filtered: isExist + Category==6 + Cargos==true)
-- @param desc table         result of obj:getDesc()
function CTLDCrateManager:registerMMCrate(obj, desc)
    local crateName = obj:getName()

    if self.crates[crateName] then
        _log("CTLDCrateManager:registerMMCrate - already registered: " .. crateName, "WARNING")
        return
    end

    local typeName   = desc.typeName
    local descriptor = self:findDescriptorByTypeName(typeName)

    if descriptor == nil then
        _log("CTLDCrateManager:registerMMCrate - unknown cargo type '"
            .. tostring(typeName) .. "' (" .. crateName .. ") — skipped", "WARNING")
        return
    end

    local crate = CTLDCrate:new({
        crateName   = crateName,
        descriptor  = descriptor,
        spawnMethod = CTLDCrate.SPAWN_METHOD.MISSION_MAKER,
        spawnedBy   = nil,
        position    = obj:getPoint(),
        heading     = 0,
        coalition   = obj:getCoalition(),
        dcsStatic   = obj,
    })

    self:_register(crate)
    _log("CTLDCrateManager:registerMMCrate - registered '" .. crateName
        .. "' type='" .. tostring(typeName) .. "'", "INFO")

    self:_publish("OnMMCrateDetected", {
        crate       = crate,
        crateName   = crateName,
        descriptor  = descriptor,
        position    = crate.position,
        coalition   = crate.coalition,
        timestamp   = timer.getAbsTime(),
    })
end

--- Get a crate by its DCS unit name.
-- @param crateName string
-- @return CTLDCrate or nil
function CTLDCrateManager:getCrateByName(crateName)
    return self.crates[crateName]
end

--- Get all crates on the ground within a radius of a position.
-- @param position vec3
-- @param radius   number  metres
-- @return table of CTLDCrate
function CTLDCrateManager:getCratesInRange(position, radius)
    local result = {}
    for _, crate in pairs(self.crates) do
        if crate:isOnGround() then
            -- Prefer live DCS static position: covers crates moved by native DCS
            -- cargo system (dropped at a different location than original spawn).
            local cratePos = crate.position
            if crate.dcsStatic and crate.dcsStatic:isExist() then
                cratePos = crate.dcsStatic:getPoint()
            end
            if ctld.utils.getDistance("CTLDCrateManager:getCratesInRange", position, cratePos) <= radius then
                table.insert(result, crate)
            end
        end
    end
    return result
end

--- Load a crate into a transport unit.
-- Transitions crate: spawned|landed → loaded.
-- Publishes OnCrateLoaded.
-- @param crateName string
-- @param transport Unit
function CTLDCrateManager:loadCrate(crateName, transport)
    local crate = self.crates[crateName]
    if not crate then
        _log("CTLDCrateManager:loadCrate - crate not found: " .. tostring(crateName), "WARNING")
        return
    end
    if not crate:isOnGround() then
        _log("CTLDCrateManager:loadCrate - crate not on ground: " .. crateName, "WARNING")
        return
    end
    local pos = crate.position   -- capture before state change
    crate:load(transport)
    crate:destroy()              -- remove DCS static from ground
    self:_publish("OnCrateLoaded", {
        crate           = crate,
        crateName       = crateName,
        carrierUnitName = transport:getName(),
        coalition       = crate.coalition,
        descriptor      = crate.descriptor,
        timestamp       = timer.getAbsTime(),
    })
    self:_publish("OnCrateCleared", {
        crateName  = crateName,
        position   = pos,
        coalition  = crate.coalition,
        descriptor = crate.descriptor,
        reason     = "loaded",
        timestamp  = timer.getAbsTime(),
    })
end

--- Unload a crate to the ground (transport has landed).
-- Transitions crate: loaded → landed.
-- Publishes OnCrateUnloaded.
-- @param crateName string
-- @param position  vec3
-- @param method    string  "menu_ctld" | "dcs_native_unload"
function CTLDCrateManager:unloadCrate(crateName, position, method)
    local crate = self.crates[crateName]
    if not crate then return end
    crate:unload(position)
    -- Recreate DCS static on the ground (was destroyed when loaded)
    self:_respawnStatic(crate, position)
    -- Use the updated crateName (may have changed in _respawnStatic)
    local newName = crate.crateName
    self:_publish("OnCrateUnloaded", {
        crate           = crate,
        crateName       = newName,
        position        = position,
        coalition       = crate.coalition,
        method          = method or "menu_ctld",
        timestamp       = timer.getAbsTime(),
    })
    -- Crate returned to ground: notify nearby players it is loadable again.
    self:_publish("OnCrateSpawned", {
        crate      = crate,
        crateName  = newName,
        position   = position,
        coalition  = crate.coalition,
        descriptor = crate.descriptor,
        spawnedBy  = nil,
        spawnMethod = "unload",
        timestamp  = timer.getAbsTime(),
    })
end

--- Unpack a crate (contents deployed).
-- Transitions crate: spawned|landed → unpacked.
-- Publishes OnCrateUnpacked.
-- Spawn logic is delegated to the relevant manager based on descriptor type.
-- @param crateName string
-- @param unpacker  Unit  player unit requesting unpack
function CTLDCrateManager:unpackCrate(crateName, unpacker)
    local crate = self.crates[crateName]
    if not crate then return end
    if not crate:isOnGround() then
        _log("CTLDCrateManager:unpackCrate - crate not on ground: " .. crateName, "WARNING")
        return
    end
    local pos = crate.position   -- capture before state change
    crate:unpack()
    self:_publish("OnCrateUnpacked", {
        crate           = crate,
        crateName       = crateName,
        descriptor      = crate.descriptor,
        position        = pos,
        coalition       = crate.coalition,
        carrierUnitName = unpacker and unpacker:getName() or nil,
        timestamp       = timer.getAbsTime(),
    })
    self:_publish("OnCrateCleared", {
        crateName  = crateName,
        position   = pos,
        coalition  = crate.coalition,
        descriptor = crate.descriptor,
        reason     = "unpacked",
        timestamp  = timer.getAbsTime(),
    })
    crate:destroy()
    self:_unregister(crateName)
end

--- Destroy and remove a crate from the registry.
-- @param crateName string
function CTLDCrateManager:destroyCrate(crateName)
    local crate = self.crates[crateName]
    if not crate then return end
    local pos  = crate.position
    local coal = crate.coalition
    local desc = crate.descriptor
    crate:destroy()
    self:_unregister(crateName)
    self:_publish("OnCrateCleared", {
        crateName  = crateName,
        position   = pos,
        coalition  = coal,
        descriptor = desc,
        reason     = "destroyed",
        timestamp  = timer.getAbsTime(),
    })
end

--- Find a CTLD descriptor by the DCS unit field (vehicle typeName for pack lookup).
-- Uses self._weightIndex (singleCrates only) built by _processSpawnableCrates.
-- @param typeName string  DCS typeName (e.g. "M-1 Abrams")
-- @return descriptor table or nil
function CTLDCrateManager:findDescriptorByUnitType(typeName)
    if not typeName then return nil end
    if self._weightIndex then
        for _, descriptor in pairs(self._weightIndex) do
            if descriptor.unit == typeName then return descriptor end
        end
        return nil
    end
    -- Fallback: raw config scan (before _processSpawnableCrates ran)
    local spawnableCrates = ctld.gs("spawnableCrates")
    if not spawnableCrates then return nil end
    for _, category in pairs(spawnableCrates) do
        for _, descriptor in ipairs(category) do
            if descriptor.unit == typeName then return descriptor end
        end
    end
    return nil
end

--- Find a CTLD descriptor matching a DCS typeName (unit or type field).
-- Uses self._weightIndex (singleCrates only) built by _processSpawnableCrates.
-- @param typeName string  DCS typeName (e.g. "M92_Ammo_Pallet")
-- @return descriptor table or nil
function CTLDCrateManager:findDescriptorByTypeName(typeName)
    if not typeName then return nil end
    if self._weightIndex then
        for _, descriptor in pairs(self._weightIndex) do
            if descriptor.unit == typeName or descriptor.type == typeName then
                return descriptor
            end
        end
        return nil
    end
    -- Fallback: raw config scan (before _processSpawnableCrates ran)
    local spawnableCrates = ctld.gs("spawnableCrates")
    if not spawnableCrates then return nil end
    for _, category in pairs(spawnableCrates) do
        for _, descriptor in ipairs(category) do
            if descriptor.unit == typeName or descriptor.type == typeName then
                return descriptor
            end
        end
    end
    return nil
end

--- Check if enough crates of the same type are assembled nearby to unpack.
-- Searches for crates with the same descriptor.unit within radius, including crate itself.
-- @param crate   CTLDCrate  reference crate
-- @param radius  number     search radius in metres (default 100)
-- @return boolean, table    ready flag + list of assembled crates (length == cratesRequired)
function CTLDCrateManager:checkAssemblyReady(crate, radius)
    radius = radius or 100
    local required = (crate.descriptor and crate.descriptor.cratesRequired) or 1
    if required <= 1 then
        return true, { crate }
    end

    local function _livePos(c)
        if c.dcsStatic and c.dcsStatic:isExist() then return c.dcsStatic:getPoint() end
        return c.position
    end
    local refPos = _livePos(crate)

    local assembled = {}
    for _, c in pairs(self.crates) do
        if c:isOnGround()
            and c.descriptor
            and c.descriptor.unit == crate.descriptor.unit
            and ctld.utils.getDistance("CTLDCrateManager:checkAssemblyReady", refPos, _livePos(c)) <= radius
        then
            table.insert(assembled, c)
            if #assembled == required then
                return true, assembled
            end
        end
    end
    return false, assembled
end

--- Drop a crate from a transport in flight.
-- Below maxDropHeight → crate lands safely.
-- Above maxDropHeight → crate is destroyed (impact damage).
-- Publishes OnCrateUnloaded (method="drop") on safe landing,
-- or OnCrateDestroyed (reason="drop_impact") on destruction.
-- @param crateName     string
-- @param altitudeAGL   number  metres above ground level at drop time
function CTLDCrateManager:dropCrate(crateName, altitudeAGL)
    local crate = self.crates[crateName]
    if not crate then return end
    if not crate:isLoaded() then
        _log("CTLDCrateManager:dropCrate - crate not loaded: " .. tostring(crateName), "WARNING")
        return
    end

    local maxDropHeight = ctld.gs("maxDropHeight") or 7.5

    if altitudeAGL <= maxDropHeight then
        -- Safe drop: crate lands at current position
        local pos = crate.position
        crate:land(pos)
        self:_publish("OnCrateUnloaded", {
            crate           = crate,
            crateName       = crateName,
            position        = pos,
            coalition       = crate.coalition,
            method          = "drop",
            timestamp       = timer.getAbsTime(),
        })
    else
        -- Too high: crate destroyed on impact
        _log("CTLDCrateManager:dropCrate - destroyed on impact (alt=" .. tostring(altitudeAGL) .. "m): " .. crateName, "INFO")
        self:_publish("OnCrateDestroyed", {
            crate     = crate,
            crateName = crateName,
            coalition = crate.coalition,
            reason    = "drop_impact",
            timestamp = timer.getAbsTime(),
        })
        crate:destroy()
        self:_unregister(crateName)
    end
end

--- S_EVENT_BIRTH handler: register cargo statics that spawn via late activation.
-- Registered in CTLDDCSEventBridge by CTLDCoreManager.
function CTLDCrateManager:onBirth(event)
    local obj = event.initiator
    if not (obj and obj.isExist and obj:isExist()) then return end
    if Object.getCategory(obj) ~= 6 then return end
    local desc = obj:getDesc()
    if not (desc and desc.attributes and desc.attributes.Cargos == true) then return end
    local unitName = obj:getName()
    -- Skip CTLD-managed crates: S_EVENT_BIRTH may fire before _register() is called
    -- (synchronous dispatch in some DCS versions), so the prefix check is more reliable
    -- than getCrateByName() alone.
    if string.sub(unitName, 1, 5) == "CTLD_" then return end
    if self:getCrateByName(unitName) then return end   -- already registered
    self:registerMMCrate(obj, desc)
end

--- Spawn the DCS object described by a crate descriptor and activate its post-spawn role.
-- Uniform path for all standard (non-AA, non-FOB) unpack outcomes:
--   build unitDef (ctld.utils.buildGroupUnitDef)
--   → spawn       (ctld.utils.spawnFromDescriptor)
--   → post-spawn  (_dispatchPostSpawn)
--   → refresh     (refreshLoadSectionForUnit on playerName)
-- JTAC_dropEnabled is checked here for air JTAC descriptors.
-- @param desc       table    crate descriptor { unit, spawnAs, isJTAC, … }
-- @param pos        vec3     world spawn position
-- @param coa        number   coalition.side.*
-- @param cId        number   country.id.*
-- @param playerName string   unit name of the player who unpacked (optional — triggers menu refresh)
function CTLDCrateManager:_spawnUnpacked(desc, pos, coa, cId, playerName)
    if not (desc and desc.unit and pos) then return end

    local spawnAs = desc.spawnAs or "GROUND"
    local isAir   = spawnAs ~= "GROUND" and spawnAs ~= "STATIC"

    if isAir and ctld.gs("JTAC_dropEnabled") == false then
        ctld.utils.log("INFO", "CTLDCrateManager:_spawnUnpacked — JTAC_dropEnabled=false, skipped")
        return
    end

    local gid   = ctld.utils.getNextUniqId()
    local uid   = ctld.utils.getNextUniqId()
    local gname = isAir
        and string.format("CTLD_AIR_%d", gid)
        or  string.format("CTLD_UNP_%d", uid)

    local unitDef = ctld.utils.buildGroupUnitDef(desc, pos, gname, gid, uid)
    local ok, err = ctld.utils.spawnFromDescriptor(desc, cId, unitDef)
    if not ok then
        local errStr = type(err) == "table" and ctld.utils.p(err) or tostring(err)
        ctld.utils.log("WARNING", "CTLDCrateManager:_spawnUnpacked — spawn failed: " .. errStr)
        return
    end

    if not isAir then
        EventDispatcher.getInstance():publish("OnGroundUnitSpawned", {
            vehicleType = desc.unit,
            position    = pos,
            coalitionId = coa,
            timestamp   = timer.getAbsTime(),
        })
    end

    self:_dispatchPostSpawn(desc, gname)

    if playerName then
        CTLDVehicleSpawner.getInstance():refreshLoadSectionForUnit(playerName)
        CTLDVehicleSpawner.getInstance():refreshPackSectionForUnit(playerName)
    end
end

--- Activate post-spawn role behaviors for an unpacked crate.
-- Called after successful spawn regardless of unit type.
-- Add new role activations here as new crate types are introduced.
-- @param desc   table  crate descriptor
-- @param gname  string spawned DCS group name
function CTLDCrateManager:_dispatchPostSpawn(desc, gname)
    if desc.isJTAC then
        CTLDJTACManager.get():startLase(gname, nil, nil, nil, nil, nil, desc.specificParams)
        -- Register in CTLDVehicleSpawner so load/unload can suspend/resume JTAC lasing.
        CTLDVehicleSpawner.getInstance():registerJTACVehicle(gname, desc.unit, nil, nil)
    elseif (desc.spawnAs == nil or desc.spawnAs == "GROUND") and desc.unit then
        -- Register ground vehicles in CTLDVehicleSpawner so Load/Unload menu can track them.
        CTLDVehicleSpawner.getInstance():registerJTACVehicle(gname, desc.unit, nil, nil)
    end
end

--- Cleanup: destroy all tracked crates.
-- Called on mission end or full reset.
function CTLDCrateManager:cleanup()
    for crateName, _ in pairs(self.crates) do
        self:destroyCrate(crateName)
    end
    self.crates = {}
end

-- ============================================================
-- F10 Menu sections
-- ============================================================

--- Parachute all crates loaded by a transport.
-- Altitude AGL is checked at call time. If below parachuteMinAltitudeCrates, a message
-- is sent to the player's group and nothing else happens.
-- For each loaded crate: computes an independent landing position, schedules a timer
-- to land it after descent, fires events.
-- Publishes OnCrateParachuting immediately (per crate) and OnCrateParachuteLanded
-- after descentTime (per crate).
-- @param transport    Unit    DCS transport unit
-- @param playerObj    table   CTLDPlayer-like {groupId, unitName}
function CTLDCrateManager:parachuteCrates(transport, playerObj)
    local dropPos     = transport:getPoint()
    local groundUnder = land.getHeight({ x = dropPos.x, y = dropPos.z })
    local altAGL      = dropPos.y - groundUnder
    local minAlt      = ctld.gs("parachuteMinAltitudeCrates") or 30

    if altAGL < minAlt then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Altitude too low for parachute drop. Minimum: %dm AGL (current: %dm AGL)"),
                math.floor(minAlt), math.floor(altAGL)), 10)
        return
    end

    local descentRate = ctld.gs("parachuteDescentRateCrates") or 5
    local loaded      = {}
    for _, crate in pairs(self.crates) do
        if crate:isLoaded() and crate.loadedBy == transport then
            table.insert(loaded, crate)
        end
    end

    if #loaded == 0 then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No crates loaded."), 8)
        return
    end

    for _, crate in ipairs(loaded) do
        local landPos, descentTime = ctld.utils.calcDropPosition(transport, descentRate)
        crate:startParachute(altAGL)
        crate.estimatedLandingTime = timer.getAbsTime() + descentTime

        local dropData = {
            type          = "crate",
            unitName      = crate.crateName,
            dropPosition  = dropPos,
            landPositions = { landPos },
            altitude      = altAGL,
            descentTime   = descentTime,
            transport     = transport,
            player        = playerObj.unitName,
        }
        self._parachuteEffect:onStart(dropData)

        self:_publish("OnCrateParachuting", {
            crate           = crate,
            crateName       = crate.crateName,
            descriptor      = crate.descriptor,
            dropPosition    = dropPos,
            landingPosition = landPos,
            altitude        = altAGL,
            descentTime     = descentTime,
            carrierUnitName = transport:getName(),
            player          = playerObj.unitName,
            timestamp       = timer.getAbsTime(),
        })

        -- Capture loop variables for the timer closure
        local _crate    = crate
        local _landPos  = landPos
        local _dropData = dropData
        timer.scheduleFunction(function()
            _crate.fromParachute = true
            _crate:land(_landPos)
            self._parachuteEffect:onLanded(_dropData)
            self:_publish("OnCrateParachuteLanded", {
                crate           = _crate,
                crateName       = _crate.crateName,
                descriptor      = _crate.descriptor,
                position        = _landPos,
                coalition       = _crate.coalition,
                startAltitude   = altAGL,
                carrierUnitName = transport:getName(),
                player          = playerObj.unitName,
                timestamp       = timer.getAbsTime(),
            })
            self:_checkAutoUnpack(_crate)
        end, {}, timer.getTime() + descentTime)
    end
end

--- Auto-unpack a set of parachuted crates when all required crates have landed.
-- Called after each parachuted crate lands (CTLD virtual or DCS-native airborne release).
-- Scans self.crates for LANDED + fromParachute=true crates of the same descriptor.unit
-- within autoUnpackRadiusParachute. If count >= cratesRequired the vehicle is spawned at
-- the centroid of the collected crates. No player is required.
-- @param landedCrate CTLDCrate  the crate that just landed
function CTLDCrateManager:_checkAutoUnpack(landedCrate)
    local desc = landedCrate.descriptor
    if not desc or not desc.unit then return end
    local required = desc.cratesRequired or 1
    local radius   = ctld.gs("autoUnpackRadiusParachute") or 1000
    local refPos   = landedCrate.position
    if not refPos then return end

    -- Collect eligible crates: LANDED + fromParachute=true + same unit type + in radius
    local candidates = {}
    for _, crate in pairs(self.crates) do
        if crate.fromParachute
            and crate:isOnGround()
            and crate.canBeUnpacked
            and crate.descriptor
            and crate.descriptor.unit == desc.unit
        then
            local cp = crate.position
            if cp then
                local dx = cp.x - refPos.x
                local dz = cp.z - refPos.z
                if math.sqrt(dx*dx + dz*dz) <= radius then
                    table.insert(candidates, crate)
                end
            end
        end
    end

    if #candidates < required then return end

    -- Take the first N crates (required count)
    local toUnpack = {}
    for i = 1, required do
        toUnpack[i] = candidates[i]
    end

    -- Compute centroid of selected crates
    local sumX, sumY, sumZ = 0, 0, 0
    for _, c in ipairs(toUnpack) do
        sumX = sumX + c.position.x
        sumY = sumY + c.position.y
        sumZ = sumZ + c.position.z
    end
    local centroid = {
        x = sumX / required,
        y = sumY / required,
        z = sumZ / required,
    }

    -- Determine country from coalition (mirrors standard unpack logic)
    local coa = landedCrate.coalition
    local cId = (coa == coalition.side.RED) and country.id.RUSSIA or country.id.USA

    -- Unpack each crate (destroy static, publish OnCrateUnpacked + OnCrateCleared)
    for _, c in ipairs(toUnpack) do
        self:unpackCrate(c.crateName, nil)
    end

    -- Spawn vehicle at centroid (no player context)
    self:_spawnUnpacked(desc, centroid, coa, cId, nil)

    ctld.utils.log("INFO",
        "CTLDCrateManager: auto-unpack (parachute) — type=%s required=%d centroid=(%.0f,%.0f,%.0f)",
        desc.unit, required, centroid.x, centroid.y, centroid.z)
end

--- Returns true if a crate descriptor entry has the JTAC role.
-- For single crates: checks desc.isJTAC == true.
-- For multi-crates:  resolves each weight to its descriptor; true if any has isJTAC == true.
-- @param desc  table  entry from spawnableCrates (may have .unit or .multiple)
local function _crateIsJTAC(desc)
    if desc.isJTAC then return true end
    if desc.multiple then
        local mgr = CTLDCrateManager.getInstance()
        for _, w in ipairs(desc.multiple) do
            local d = mgr:findDescriptorByWeight(w)
            if d and d.isJTAC then return true end
        end
    end
    return false
end

--- Build "Request Equipment" + "Crate Commands" F10 submenus for a player.
-- Requires enableCrates = true (configKey gate) AND unitActions.crates = true.
-- Sub-entries:
--   Request Equipment → per LGZ → per category → per crate (filtered by coalition + JTAC flag)
--   Crate Commands → Load/Drop/Unpack/List
--                  → List FOBs         if enabledFOBBuilding
--                  → Pack Vehicle (container, populated dynamically) if enablePackingVehicles
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
--- Rebuild the "Request Equipment" submenu branch for playerObj.
-- Shows only logistic zones where the player is currently located (cratesPickup).
-- Called on build, land, and takeoff.
-- @param playerObj CTLDPlayer
function CTLDCrateManager:refreshRequestEquipmentSection(playerObj)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root     = ctld.tr("CTLD")
    local spawnSub = ctld.tr("Request Equipment")
    menu:clearBranch({ root, spawnSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, spawnSub }, ctld.tr("Land near logistics to request equipment"),
            function() end, {})
        menu:refresh()
        return
    end

    local zm      = CTLDZoneManager.getInstance()
    local lgZones = zm:getLogisticZonesAtPoint(transport:getPoint(), playerObj.coalition, "cratesPickup")

    if not next(lgZones) then
        menu:addCommand({ root, spawnSub }, ctld.tr("No logistics in range"),
            function() end, {})
        menu:refresh()
        return
    end

    local jtacOk      = ctld.gs("JTAC_dropEnabled") == true
    local showSets    = ctld.gs("enableAllCrates") ~= false
    local processed   = self._processedCrates or {}

    -- Shared spawn callback: handles both single crate (arg.unit) and set (arg.multiple).
    local function spawnFn(arg)
        local t = Unit.getByName(arg.unitName)
        if not (t and t:isExist()) then return end
        if ctld.utils.inAir(t) then
            trigger.action.outTextForGroup(t:getGroup():getID(),
                ctld.tr("You must be landed to request a crate."), 10)
            return
        end
        local selZone = CTLDZoneManager.getInstance():getLogisticZone(arg.zoneName)
        if not (selZone and selZone.active and selZone:isAlive()
                and selZone:isInZone(t:getPoint())) then
            trigger.action.outTextForGroup(t:getGroup():getID(),
                ctld.tr("You are not close enough to friendly logistics to get a crate!"), 10)
            return
        end
        local safeDist = (ctld.utils.getSecureDistanceFromUnit(arg.unitName) or 10) + 5
        local mgr      = CTLDCrateManager.getInstance()
        local gid      = t:getGroup():getID()
        if arg.multiple then
            local descriptors = {}
            for _, weight in ipairs(arg.multiple) do
                local d = mgr:findDescriptorByWeight(weight)
                if d then table.insert(descriptors, d) end
            end
            local spawned, spawnInfo = mgr:spawnCratesAligned(
                descriptors, t, arg.coalition, arg.unitName, CTLDCrate.SPAWN_METHOD.MENU_CTLD)
            if spawned > 0 then
                trigger.action.outTextForGroup(gid,
                    ctld.tr("%1 crates have been brought out at your %2 o'clock",
                        spawned, spawnInfo.clock), 20)
            end
        else
            local mKey      = mgr:_crateModelKey(t)
            local spawnInfo = ctld.utils.getSpawnObjectPositions(t, 1, safeDist)
            local pos       = spawnInfo.positions[1]
            local descriptor = mgr:findDescriptorByTypeName(arg.unit)
            if descriptor then
                local spawned = mgr:spawnCrate(descriptor, pos, arg.coalition, arg.unitName,
                    CTLDCrate.SPAWN_METHOD.MENU_CTLD, nil, mKey)
                if spawned then
                    trigger.action.outTextForGroup(gid,
                        ctld.tr("A %1 crate weighing %2 kg has been brought out and is at your %3 o'clock ",
                            descriptor.desc, descriptor.weight, spawnInfo.clock), 20)
                end
            end
        end
    end

    for _, lgz in ipairs(lgZones) do
        local lgzName = lgz.name
        menu:addSubMenu({ root, spawnSub }, lgzName)
        for category, data in pairs(processed) do
            menu:addSubMenu({ root, spawnSub, lgzName }, category)
            local crateOrder = 0

            -- singleCrates, each immediately followed by its singleTypeSet (if visible)
            for _, entry in ipairs(data.singleCrates) do
                local sc     = entry.singleCrate
                local sideOk = (sc.side == nil) or (sc.side == playerObj.coalition)
                if sideOk and (not _crateIsJTAC(sc) or jtacOk) then
                    crateOrder = crateOrder + 1
                    menu:addCommand({ root, spawnSub, lgzName, category }, sc.desc,
                        spawnFn,
                        { unit = sc.unit, zoneName = lgzName, unitName = playerObj.unitName,
                          coalition = playerObj.coalition },
                        { order = crateOrder })

                    local sts = entry.singleTypeSet
                    if sts and (not _crateIsJTAC(sts) or jtacOk) then
                        crateOrder = crateOrder + 1
                        menu:addCommand({ root, spawnSub, lgzName, category }, sts.desc,
                            spawnFn,
                            { multiple = sts.multiple, zoneName = lgzName, unitName = playerObj.unitName,
                              coalition = playerObj.coalition },
                            { order = crateOrder })
                    end
                end
            end

            -- mixedSets at the end (shown only when enableAllCrates is true)
            if showSets then
                for _, ms in ipairs(data.mixedSets) do
                    local sideOk = (ms.side == nil) or (ms.side == playerObj.coalition)
                    if sideOk and (not _crateIsJTAC(ms) or jtacOk) then
                        crateOrder = crateOrder + 1
                        menu:addCommand({ root, spawnSub, lgzName, category }, ms.desc,
                            spawnFn,
                            { multiple = ms.multiple, zoneName = lgzName, unitName = playerObj.unitName,
                              coalition = playerObj.coalition },
                            { order = crateOrder })
                    end
                end
            end
        end
    end
    menu:refresh()
end

function CTLDCrateManager:buildMenuSection(playerObj, menu)
    local unitActions = ctld.gs("unitActions") or {}
    local actions     = unitActions[playerObj.typeName]
    if not (playerObj.isTransport and actions and actions.crates) then return end

    local root     = ctld.tr("CTLD")
    local spawnSub = ctld.tr("Request Equipment")
    menu:addSubMenu({ root }, spawnSub, { order = 40 })
    self:refreshRequestEquipmentSection(playerObj)

    -- Crate Commands
    local cratesSub = ctld.tr("Crate Commands")
    menu:addSubMenu({ root }, cratesSub, { order = 50 })

    local loadSub = ctld.tr("Load Crate")
    menu:addSubMenu({ root, cratesSub }, loadSub, { order = 10 })
    self:refreshLoadCrateSection(playerObj)

    menu:addCommand({ root, cratesSub }, ctld.tr("Drop Crate(s)"),
        function(arg)
            local t = Unit.getByName(arg.unitName)
            if not (t and t:isExist()) then return end
            local gid = t:getGroup():getID()
            if ctld.utils.inAir(t) then
                trigger.action.outTextForGroup(gid,
                    ctld.tr("You must land before dropping crates!"), 10)
                return
            end
            -- Collect all crates loaded on this transport
            local mgr     = CTLDCrateManager.getInstance()
            local loaded  = {}
            for _, c in pairs(mgr.crates) do
                if c:isLoaded() and c.loadedBy and c.loadedBy:getName() == t:getName() then
                    table.insert(loaded, c)
                end
            end
            if #loaded == 0 then
                trigger.action.outTextForGroup(gid,
                    ctld.tr("No crates on board to drop."), 10)
                return
            end
            -- Compute aligned drop positions (one per crate)
            local safeDist  = (ctld.utils.getSecureDistanceFromUnit(arg.unitName) or 10) + 5
            local spacing   = (ctld.gs and ctld.gs("crateSpacing")) or 5
            local typeLower = string.lower(t:getTypeName())
            local vList     = (ctld.gs and ctld.gs("vehicleTransportEnabled")) or {}
            local isDynamic = false
            for _, name in ipairs(vList) do
                if string.find(typeLower, string.lower(name), 1, true) then
                    isDynamic = true; break
                end
            end
            local axis
            if isDynamic then
                axis = ctld.utils.RandomReal("dropCrates", 135, 225)
            else
                axis = (ctld.utils.RandomReal("dropCrates", -45, 45) + 360) % 360
            end
            local spawnInfo = ctld.utils.getSpawnObjectPositions(t, #loaded, safeDist, spacing, axis)
            for i, c in ipairs(loaded) do
                local pos = spawnInfo.positions[i]
                if pos then
                    local groundY = land.getHeight({ x = pos.x, y = pos.z })
                    mgr:unloadCrate(c.crateName, { x = pos.x, y = groundY, z = pos.z }, "drop")
                end
            end
            trigger.action.outTextForGroup(gid,
                ctld.tr("%1 crate(s) dropped at your %2 o'clock", #loaded, spawnInfo.clock), 10)
        end,
        { unitName = playerObj.unitName })

    local unpackSub = ctld.tr("Unpack Crate")
    menu:addSubMenu({ root, cratesSub }, unpackSub, { order = 20 })
    self:refreshUnpackSection(playerObj)

    menu:addCommand({ root, cratesSub }, ctld.tr("List Nearby Crates"),
        function(arg)
            local t = Unit.getByName(arg.unitName)
            if not (t and t:isExist()) then return end
            local gid  = t:getGroup():getID()
            local mgr  = CTLDCrateManager.getInstance()
            local nearby = mgr:getCratesInRange(t:getPoint(), 300)

            -- Group by descriptor.unit (or desc for crates with no vehicle)
            local byUnit    = {}   -- [key] = { desc, count, required }
            local unitOrder = {}
            for _, c in ipairs(nearby) do
                if c.descriptor then
                    local key      = c.descriptor.unit or c.descriptor.desc or "?"
                    local desc     = c.descriptor.desc or key
                    local required = c.descriptor.cratesRequired or 1
                    if not byUnit[key] then
                        byUnit[key] = { desc = desc, count = 0, required = required }
                        table.insert(unitOrder, key)
                    end
                    byUnit[key].count = byUnit[key].count + 1
                end
            end

            if #unitOrder == 0 then
                trigger.action.outTextForGroup(gid,
                    ctld.tr("No crates within 300m."), 10)
                return
            end

            local lines = { ctld.tr("Crates within 300m:") }
            for _, key in ipairs(unitOrder) do
                local info = byUnit[key]
                if info.count >= info.required then
                    table.insert(lines, ctld.tr("  %1: %2/%3 — READY", info.desc, info.count, info.required))
                else
                    table.insert(lines, ctld.tr("  %1: %2/%3 — incomplete", info.desc, info.count, info.required))
                end
            end
            trigger.action.outTextForGroup(gid, table.concat(lines, "\n"), 15)
        end,
        { unitName = playerObj.unitName })

    if ctld.gs("enablePackingVehicles") == true then
        local packSub   = ctld.tr("Pack Vehicle")
        menu:addSubMenu({ root, cratesSub }, packSub, { order = 99 })
        CTLDVehicleSpawner.getInstance():refreshPackSection(playerObj)
    end

    -- Parachute Crates: only if canParachute=true for this unit type
    if actions.canParachute then
        menu:addCommand({ root, cratesSub }, ctld.tr("Parachute Crates"),
            function(arg)
                local transport = Unit.getByName(arg.unitName)
                if not transport then return end
                CTLDCrateManager.getInstance():parachuteCrates(transport, arg)
            end,
            { unitName = playerObj.unitName, groupId = playerObj.groupId })
    end

    -- Release / Cut Slingload: only if canSlingload=true AND transport currently in air
    if actions.canSlingload then
        local transport = Unit.getByName(playerObj.unitName)
        if transport and transport:isExist() and ctld.utils.inAir(transport) then
            menu:addCommand({ root, cratesSub }, ctld.tr("Release Slingload"),
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not t then return end
                    CTLDCrateManager.getInstance():releaseSlingload(t, arg)
                end,
                { unitName = playerObj.unitName, groupId = playerObj.groupId })

            menu:addCommand({ root, cratesSub }, ctld.tr("Cut Slingload"),
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not t then return end
                    CTLDCrateManager.getInstance():cutSlingload(t, arg)
                end,
                { unitName = playerObj.unitName, groupId = playerObj.groupId })
        end
    end
end

--- Build "Smoke" F10 submenu for a player.
-- Requires enableSmokeDrop = true (configKey gate) AND isTransport.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDCrateManager:buildSmokeSection(playerObj, menu)
    if not playerObj.isTransport then return end

    local root     = ctld.tr("CTLD")
    local smokeSub = ctld.tr("Smoke")
    menu:addSubMenu({ root }, smokeSub, { order = 80 })

    local smMgr = CTLDSmokeManager.getInstance()

    local uName = playerObj.unitName

    local function doSmoke(arg)
        local unit = Unit.getByName(arg.unitName)
        if not (unit and unit:isExist()) then return end
        local pt  = unit:getPoint()
        local pos = { x = pt.x, y = land.getHeight({ x = pt.x, y = pt.z }), z = pt.z }
        trigger.action.smoke(pos, arg.color)
        trigger.action.outTextForCoalition(unit:getCoalition(),
            arg.unitName .. " dropped " .. arg.colorName .. " smoke.", 10)
        ctld.utils.log("INFO", "CTLDCrateManager:dropSmoke — %s %s", arg.unitName, arg.colorName)
        -- Feature H: always track the smoke so auto-resume can fire it
        -- even if the player activates the toggle after the drop.
        smMgr:registerSmoke(arg.unitName, pos, arg.color)
    end

    local function doToggleAutoResume(arg)
        local newState = smMgr:toggle(arg.unitName)
        local interval = ctld.gs("smokeAutoResumeInterval") or 270
        local msgKey   = newState
            and "Smoke auto-resume ON (%1s interval)"
            or  "Smoke auto-resume OFF"
        local msg = ctld.tr(msgKey):gsub("%%1", tostring(interval))
        local u = Unit.getByName(arg.unitName)
        local gid = u and u:getGroup() and u:getGroup():getID() or -1
        trigger.action.outTextForGroup(gid, msg, 10)
        ctld.utils.log("INFO", "CTLDSmokeManager: toggle for '%s' active=%s", arg.unitName, tostring(newState))
        -- Rebuild the full menu model (not just DCS layer) so the toggle label updates.
        -- refreshForUnit only replays the frozen memory model — buildMenu reconstructs it.
        local pm = CTLDPlayerManager.getInstance()
        if pm then
            local pObj = pm:getPlayer(arg.unitName)
            if pObj then pm:buildMenu(pObj) end
        end
    end

    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Red Smoke"),    doSmoke,
        { unitName = uName, color = trigger.smokeColor.Red,    colorName = "RED" })
    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Blue Smoke"),   doSmoke,
        { unitName = uName, color = trigger.smokeColor.Blue,   colorName = "BLUE" })
    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Orange Smoke"), doSmoke,
        { unitName = uName, color = trigger.smokeColor.Orange, colorName = "ORANGE" })
    menu:addCommand({ root, smokeSub }, ctld.tr("Drop Green Smoke"),  doSmoke,
        { unitName = uName, color = trigger.smokeColor.Green,  colorName = "GREEN" })

    -- Feature H: toggle auto-resume (label reflects current state per unit)
    local toggleLabel = smMgr:isActive(uName)
        and ctld.tr("Smoke Auto-Resume [deactivate]")
        or  ctld.tr("Smoke Auto-Resume [activate]")
    menu:addCommand({ root, smokeSub }, toggleLabel, doToggleAutoResume, { unitName = uName })
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Find a crate descriptor by weight number.
-- Uses self._weightIndex (O(1)) built by _processSpawnableCrates (singleCrates only).
-- @param weight number
-- @return table|nil  descriptor
function CTLDCrateManager:findDescriptorByWeight(weight)
    if not weight then return nil end
    if self._weightIndex then
        return self._weightIndex[weight]
    end
    -- Fallback: raw config scan (before _processSpawnableCrates ran)
    local spawnableCrates = ctld.gs("spawnableCrates")
    if not spawnableCrates then return nil end
    for _, category in pairs(spawnableCrates) do
        for _, descriptor in ipairs(category) do
            if descriptor.weight == weight then return descriptor end
        end
    end
    return nil
end

--- Spawn a crate at a DCS trigger zone (MM DO SCRIPT).
-- @param side   string   "red" | "blue"
-- @param weight number   crate weight (lookup key in spawnableCrates)
-- @param zone   string   DCS trigger zone name
-- @return CTLDCrate|nil
function CTLDCrateManager:spawnCrateAtZone(side, weight, zone)
    local trig = trigger.misc.getZone(zone)
    if not trig then
        ctld.utils.log("ERROR", "CTLDCrateManager:spawnCrateAtZone — zone not found: %s", tostring(zone))
        return nil
    end
    local descriptor = self:findDescriptorByWeight(weight)
    if not descriptor then
        ctld.utils.log("ERROR", "CTLDCrateManager:spawnCrateAtZone — no descriptor for weight=%s", tostring(weight))
        return nil
    end
    local p2  = { x = trig.point.x, y = trig.point.z }
    local pt  = { x = p2.x, y = land.getHeight(p2), z = p2.y }
    local cId = (side == "red") and coalition.side.RED or coalition.side.BLUE
    return self:spawnCrate(descriptor, pt, cId, nil, CTLDCrate.SPAWN_METHOD.MISSION_MAKER)
end

--- Spawn a crate at a Vec3 point (MM DO SCRIPT).
-- @param side   string   "red" | "blue"
-- @param weight number   crate weight
-- @param point  table    vec3 {x, y, z}
-- @param hdg    number   heading in degrees
-- @return CTLDCrate|nil
function CTLDCrateManager:spawnCrateAtPoint(side, weight, point, hdg)
    local descriptor = self:findDescriptorByWeight(weight)
    if not descriptor then
        ctld.utils.log("ERROR", "CTLDCrateManager:spawnCrateAtPoint — no descriptor for weight=%s", tostring(weight))
        return nil
    end
    local cId = (side == "red") and coalition.side.RED or coalition.side.BLUE
    return self:spawnCrate(descriptor, point, cId, nil, CTLDCrate.SPAWN_METHOD.MISSION_MAKER)
end

--- Start a recurring watcher that counts crates in a DCS zone and sets a DCS flag.
-- Reschedules every 5 seconds. Call once from a DO SCRIPT trigger.
-- @param zoneName   string          DCS trigger zone name
-- @param flagNumber number|string   DCS user flag to set to crate count
function CTLDCrateManager:startCrateCountWatcher(zoneName, flagNumber)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDCrateManager:startCrateCountWatcher — zone not found: %s", tostring(zoneName))
        return
    end
    local center = { x = trig.point.x, y = trig.point.y, z = trig.point.z }
    local radius = trig.radius
    local self_ref = self
    local function _tick()
        local count = 0
        for _, crate in pairs(self_ref.crates) do
            if crate:isOnGround() then
                if ctld.utils.getDistance("crateWatcher", crate.position, center) <= radius then
                    count = count + 1
                end
            end
        end
        trigger.action.setUserFlag(flagNumber, count)
        timer.scheduleFunction(function()
            self_ref:startCrateCountWatcher(zoneName, flagNumber)
        end, nil, timer.getTime() + 5)
    end
    _tick()
end

-- End : CTLD_crate.lua
-- ====================================================================================================
-- Start : CTLD_vehicle.lua
-- ============================================================
-- CTLD_vehicle.lua
-- CTLDVehicle entity + CTLDVehicleSpawner singleton
--
-- Vehicle lifecycle:
--   WAITING   — spawned on the ground, awaiting pick-up
--   LOADED    — loaded into a transport (DCS unit destroyed / bbox-tracked)
--   DELIVERED — unloaded from transport (DCS unit respawned)
--
-- Load methods:
--   "menu_ctld"  — virtual load via CTLD F10 menu: unit destroyed on load,
--                  respawned on unload using the original group / unit names
--   "dcs_native" — detected via bounding-box overlap with a C-130 / Il-76
--                  (vehicleTransportEnabled list)
--
-- Unload methods:
--   "menu_ctld"  — virtual unload: unit respawned near transport
--   "dcs_native" — bbox exit while transport is on the ground
--   "parachute"  — bbox exit while transport is airborne
--
-- Spawn position for spawnVehicleForTransport / unloadVehicle:
--   Uses the transport's own bounding box to compute a collision-free offset
--   (same logic as ctld.getSecureDistanceFromUnit), then places the unit in the
--   front sector (±45 ° of heading) of the transport.
--
-- Group / unit naming:
--   spawnVehicleForTransport assigns  groupName = "CTLD_VEH_<type>_<id>"
--   and                               unitName  = same as groupName
--   These names are preserved in spawnData and reused verbatim on unload so
--   that the unit re-appears under its original name on the F10 map.
--
-- Events published:
--   OnVehicleSpawnedForTransport  — vehicle spawned by spawnVehicleForTransport
--   OnVehicleLoaded               — vehicle loaded into a transport
--   OnVehicleUnloaded             — vehicle unloaded / dropped from a transport
--   OnVehicleDead                 — tracked vehicle destroyed (combat / accident)
--
-- Dependencies: class (lib/class.lua), ctld.utils, ctld.gs,
--               EventDispatcher, CTLDDCSEventBridge
-- DCS API: coalition, Group, Unit, land.getHeight, timer,
--          Unit:getTransformation, Unit:getDesc
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDVehicle  (entity)
-- ============================================================

CTLDVehicle = class()

--- Valid states (class-level constants).
CTLDVehicle.STATE = {
    WAITING   = "WAITING",
    LOADED    = "LOADED",
    DELIVERED = "DELIVERED",
}

--- Constructor.
-- @param data table
--   Required: id (string), vehicleType (string), spawner (DCS Unit),
--             logisticZone (CTLDLogisticZone|nil), countryId (number),
--             coalitionId (number), spawnData (table — see below)
--   spawnData:  { groupName, unitName, vehicleType, countryId, coalitionId }
--   Optional:   unit (DCS Unit)   — the live DCS unit when in WAITING state
function CTLDVehicle:init(data)
    self.id           = data.id
    self.vehicleType  = data.vehicleType
    self.state        = CTLDVehicle.STATE.WAITING
    self.unit         = data.unit         or nil
    self.spawner      = data.spawner      or nil
    self.logisticZone = data.logisticZone or nil
    self.spawnData    = data.spawnData           -- preserved for respawn on unload
    self.spawnTime    = timer.getTime()
    self.loadTime     = nil
    self.loadMethod   = nil
    self.loadTransportName = nil
end

--- Transition to a new state.  No validation — callers are responsible.
-- @param newState string  CTLDVehicle.STATE.*
function CTLDVehicle:setState(newState)
    self.state = newState
end

--- Returns the current state string.
function CTLDVehicle:getState()
    return self.state
end


-- ============================================================
-- CTLDVehicleSpawner  (singleton)
-- ============================================================

CTLDVehicleSpawner = class()
CTLDVehicleSpawner._instance = nil

function CTLDVehicleSpawner.getInstance()
    if not CTLDVehicleSpawner._instance then
        local o = setmetatable({}, CTLDVehicleSpawner)
        o:init()
        CTLDVehicleSpawner._instance = o
    end
    return CTLDVehicleSpawner._instance
end

function CTLDVehicleSpawner:init()
    self._vehicles        = {}   -- id         → CTLDVehicle
    self._unitToVehicle   = {}   -- unitName   → vehicleId   (reverse lookup)
    self._vehicleCount    = 0
    self._parachuteEffect = CTLDNullParachuteEffect:new()
    -- nativeTracked: transportName → { vehicleId, wasInBbox }
    -- populated by _checkNativeLoading to avoid re-firing on same entry
    self._nativeTracked = {}

    local ok, bridge = pcall(CTLDDCSEventBridge.getInstance)
    if ok and bridge then
        bridge:register(self, world.event.S_EVENT_DEAD, "onDead")
    end

    -- Start periodic native-load detection (1 s cadence)
    timer.scheduleFunction(function(_, t)
        local inst = CTLDVehicleSpawner._instance
        if inst then inst:_checkNativeLoading() end
        return t + 1
    end, nil, timer.getTime() + 1)

    CTLDPlayerManager.getInstance():registerMenuSection({
        key     = "vehicles",
        manager = self,
        method  = "buildMenuSection",
        order   = 30,
    })

    -- Pack menu refresh: detect inAir→landed transition every 3 s
    self._prevInAir = {}
    timer.scheduleFunction(function(_, t)
        local inst = CTLDVehicleSpawner._instance
        if inst then inst:_checkPackingLanding() end
        return t + 3
    end, nil, timer.getTime() + 3)

    -- Hover hint: notify player to land when hovering in slingload window above a WAITING vehicle
    self._hoverHintSent = {}  -- unitName → last hint time
    timer.scheduleFunction(function(_, t)
        local inst = CTLDVehicleSpawner._instance
        if inst then inst:_checkVehicleHoverHint() end
        return t + 5
    end, nil, timer.getTime() + 5)

    -- Auto-refresh Pack Vehicle menu when ground units appear or disappear nearby
    local ed = EventDispatcher.getInstance()
    ed:subscribe("OnGroundUnitSpawned", function(payload)
        if payload and payload.position then
            CTLDVehicleSpawner.getInstance():_refreshNearbyPackPlayers(payload.position)
        end
    end)
    ed:subscribe("OnGroundUnitRemoved", function(payload)
        if payload and payload.position then
            CTLDVehicleSpawner.getInstance():_refreshNearbyPackPlayers(payload.position)
        end
    end)
    -- Request Vehicle also triggers a pack-menu refresh (vehicle appears on ground)
    ed:subscribe("OnVehicleSpawnedForTransport", function(payload)
        if payload and payload.position then
            CTLDVehicleSpawner.getInstance():_refreshNearbyPackPlayers(payload.position)
        end
    end)

    -- Load / Unload vehicle: refresh both submenus for the transport player
    ed:subscribe("OnVehicleLoaded", function(payload)
        local t = payload and payload.transportUnitObject
        if t then
            local tName = t:getName()
            local inst  = CTLDVehicleSpawner.getInstance()
            inst:refreshLoadSectionForUnit(tName)
            inst:refreshUnloadSectionForUnit(tName)
        end
    end)
    ed:subscribe("OnVehicleUnloaded", function(payload)
        local t = payload and payload.transportUnitObject
        if t then
            local tName = t:getName()
            local inst  = CTLDVehicleSpawner.getInstance()
            inst:refreshLoadSectionForUnit(tName)
            inst:refreshUnloadSectionForUnit(tName)
        end
    end)

    ctld.utils.log("INFO", "CTLDVehicleSpawner: init complete")
end

-- ============================================================
-- Helpers (module-local)
-- ============================================================

--- Secure spawn offset in metres, derived from the transport's bounding box.
-- Mirrors ctld.getSecureDistanceFromUnit but works directly from a DCS Unit.
-- Falls back to 30 m if desc.box is unavailable.
local function _secureOffset(transport)
    local ok, box = pcall(function() return transport:getDesc().box end)
    if ok and box then
        return math.max(math.abs(box.max.x), math.abs(box.min.x)) + 5
    end
    return 30
end

--- Compute a spawn position in the front sector (±45 °) of transport.
-- @param transport DCS Unit
-- @return vec3
local function _computeSpawnPosition(transport)
    local hdg    = ctld.utils.getHeadingInRadians("CTLDVehicleSpawner._computeSpawnPosition",
                       transport, true)
    local offset = _secureOffset(transport)
    local angle  = ctld.utils.RandomReal("CTLDVehicleSpawner._computeSpawnPosition",
                       hdg - math.pi / 4, hdg + math.pi / 4)
    local pos    = transport:getPoint()
    local px     = pos.x + math.cos(angle) * offset
    local pz     = pos.z + math.sin(angle) * offset
    local py     = land.getHeight({ x = px, y = pz })
    return { x = px, y = py, z = pz }
end

--- True if a unit type name appears in the vehicleTransportEnabled config list.
local function _isNativeCargoCapable(unit)
    local typeLower = string.lower(unit:getTypeName())
    local list      = ctld.gs("vehicleTransportEnabled") or {}
    for _, name in ipairs(list) do
        if string.find(typeLower, string.lower(name), 1, true) then
            return true
        end
    end
    return false
end

-- ============================================================
-- spawnVehicleForTransport
-- ============================================================

--- Spawn a vehicle on the ground near a transport, in the front sector.
-- Creates a CTLDVehicle in WAITING state and publishes OnVehicleSpawnedForTransport.
--
-- @param vehicleType  string        DCS type name (e.g. "M1045 HMMWV TOW")
-- @param spawner      DCS Unit      transport aircraft requesting the vehicle
-- @param logisticZone table|nil     CTLDLogisticZone from which the request is made
-- @return CTLDVehicle or nil on spawn failure
function CTLDVehicleSpawner:spawnVehicleForTransport(vehicleType, spawner, logisticZone)
    self._vehicleCount = self._vehicleCount + 1
    local id       = string.format("veh_%d", self._vehicleCount)
    local baseName = string.format("CTLD_VEH_%s_%s", vehicleType, id)
    -- Replace characters that DCS does not accept in group/unit names
    baseName = baseName:gsub("[%s/\\]", "_")

    local spawnPos   = _computeSpawnPosition(spawner)
    local countryId  = spawner:getCountry()
    local spawnHdg   = ctld.utils.getHeadingInRadians(
                           "CTLDVehicleSpawner:spawnVehicleForTransport", spawner, true)

    local groupData = {
        visible  = true,
        hidden   = false,
        category = Group.Category.GROUND,
        country  = countryId,
        name     = baseName,
        task     = {},
        units    = {
            {
                type           = vehicleType,
                name           = baseName,
                x              = spawnPos.x,
                y              = spawnPos.z,   -- dynAdd: y == world Z
                heading        = spawnHdg,
                skill          = "Random",
                playerCanDrive = false,
            }
        },
    }

    local result = ctld.utils.dynAdd("CTLDVehicleSpawner:spawnVehicleForTransport", groupData)
    if not result then
        ctld.utils.log("ERROR",
            "CTLDVehicleSpawner: dynAdd failed for vehicle type=" .. tostring(vehicleType))
        return nil
    end

    local spawnedGroup = Group.getByName(result.name)
    local spawnedUnit  = spawnedGroup and spawnedGroup:getUnit(1) or nil

    local spawnData = {
        groupName   = baseName,
        unitName    = baseName,
        vehicleType = vehicleType,
        countryId   = countryId,
        coalitionId = spawner:getCoalition(),
    }

    local vehicle = CTLDVehicle:new({
        id           = id,
        vehicleType  = vehicleType,
        unit         = spawnedUnit,
        spawner      = spawner,
        logisticZone = logisticZone,
        spawnData    = spawnData,
    })

    self._vehicles[id] = vehicle
    if spawnedUnit then
        self._unitToVehicle[spawnedUnit:getName()] = id
    end

    EventDispatcher.getInstance():publish("OnVehicleSpawnedForTransport", {
        vehicleId    = id,
        vehicle      = spawnedUnit,
        vehicleType  = vehicleType,
        spawner      = spawner,
        logisticZone = logisticZone,
        spawnMethod  = "request_vehicle",
        position     = spawnPos,
        timestamp    = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner: spawned %s id=%s at (%.0f,%.0f,%.0f)",
        vehicleType, id, spawnPos.x, spawnPos.y, spawnPos.z))

    return vehicle
end

--- Register an externally-spawned JTAC vehicle (from unpack or Request JTAC Equipment)
-- into the CTLDVehicleSpawner registry so that load/unload can track it.
-- @param groupName   string   DCS group name of the spawned unit
-- @param vehicleType string   DCS type name
-- @param spawner     DCS Unit transport that requested it (or nil for unpack)
-- @param logisticZone table|nil
-- @return CTLDVehicle or nil
function CTLDVehicleSpawner:registerJTACVehicle(groupName, vehicleType, spawner, logisticZone)
    self._vehicleCount = self._vehicleCount + 1
    local id      = string.format("veh_%d", self._vehicleCount)
    local g       = Group.getByName(groupName)
    local unit    = g and g:getUnit(1) or nil
    local coa     = unit and unit:getCoalition() or (spawner and spawner:getCoalition() or 2)
    local country = unit and unit:getCountry()   or (spawner and spawner:getCountry()   or 2)

    local spawnData = {
        groupName   = groupName,
        unitName    = groupName,
        vehicleType = vehicleType,
        countryId   = country,
        coalitionId = coa,
    }

    local vehicle = CTLDVehicle:new({
        id           = id,
        vehicleType  = vehicleType,
        unit         = unit,
        spawner      = spawner,
        logisticZone = logisticZone,
        spawnData    = spawnData,
    })

    self._vehicles[id] = vehicle
    if unit then
        self._unitToVehicle[unit:getName()] = id
    end

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner:registerJTACVehicle — %s id=%s group=%s",
        vehicleType, id, groupName))
    return vehicle
end

--- Spawn a JTAC vehicle near a transport (Request JTAC Equipment menu action).
-- Delegates spawn to spawnVehicleForTransport then starts JTAC lasing.
-- @param vehicleType  string        DCS type name from JTAC_unitTypeNames
-- @param spawner      DCS Unit      requesting transport
-- @param logisticZone CTLDLogisticZone
-- @return CTLDVehicle or nil
function CTLDVehicleSpawner:spawnJTACVehicleForTransport(vehicleType, spawner, logisticZone)
    local vehicle = self:spawnVehicleForTransport(vehicleType, spawner, logisticZone)
    if not vehicle then return nil end
    -- Register as JTAC and start lasing
    CTLDJTACManager.get():startLase(vehicle.spawnData.groupName)
    return vehicle
end

-- ============================================================
-- loadVehicle
-- ============================================================

--- Load a vehicle into a transport.
-- The DCS unit is destroyed from the map.  spawnData is preserved for respawn.
-- Publishes OnVehicleLoaded.
--
-- @param vehicle   CTLDVehicle
-- @param transport DCS Unit
-- @param player    string|nil  player name
-- @param method    string      "menu_ctld" | "dcs_native"
function CTLDVehicleSpawner:loadVehicle(vehicle, transport, player, method)
    if vehicle:getState() ~= CTLDVehicle.STATE.WAITING then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:loadVehicle — vehicle "
            .. vehicle.id .. " not in WAITING state")
        return
    end

    -- Guard: enforce per-type vehicle capacity limit (menu_ctld only;
    -- dcs_native capacity is managed by DCS itself).
    if method == "menu_ctld" then
        local limits      = ctld.gs("internalCargoLimits") or {}
        local maxVehicles = limits[transport:getTypeName()] or 1
        local loaded      = self:findLoadedVehicles(transport)
        if #loaded >= maxVehicles then
            local pObj = CTLDPlayerManager.getInstance()._players[transport:getName()]
            if pObj then
                trigger.action.outTextForGroup(pObj.groupId,
                    string.format(ctld.tr("Cannot load more vehicles (max: %d)."), maxVehicles), 8)
            end
            ctld.utils.log("WARNING",
                "CTLDVehicleSpawner:loadVehicle — transport %s at vehicle capacity (%d)",
                transport:getName(), maxVehicles)
            return
        end
    end

    local unitPos = vehicle.unit and vehicle.unit:getPoint() or transport:getPoint()

    -- Suspend JTAC lasing if this vehicle is a registered JTAC (any load method).
    -- For menu_ctld: unit is about to be destroyed so lasing must stop immediately.
    -- For dcs_native: unit stays alive inside aircraft but lasing from inside a soute is nonsensical.
    local groupName = vehicle.spawnData and vehicle.spawnData.groupName
    if groupName then
        CTLDJTACManager.get():setJTACInTransit(groupName,
            { unitName = transport:getName(), playerName = player })
    end

    if method == "dcs_native" then
        -- DCS manages the unit physically (linked inside aircraft) — do not destroy it.
        -- Remove from reverse lookup so onDead doesn't misfire if DCS sends a stale event.
        if vehicle.unit then
            self._unitToVehicle[vehicle.unit:getName()] = nil
        end
    else
        -- Virtual load: destroy the DCS unit from the map.
        if vehicle.unit and vehicle.unit:isExist() then
            vehicle.unit:destroy()
            EventDispatcher.getInstance():publish("OnGroundUnitRemoved", {
                vehicleType = vehicle.vehicleType,
                position    = unitPos,
                reason      = "loaded",
                timestamp   = timer.getAbsTime(),
            })
        end
        if vehicle.unit then
            self._unitToVehicle[vehicle.unit:getName()] = nil
        end
        vehicle.unit = nil
    end

    vehicle.loadMethod        = method
    vehicle.loadTransportName = transport:getName()
    vehicle.loadTime          = timer.getTime()
    vehicle:setState(CTLDVehicle.STATE.LOADED)

    -- Update DCS internal cargo weight (menu_ctld only; dcs_native is physical).
    if method == "menu_ctld" then
        self:_updateVehicleCargo(transport:getName())
    end

    EventDispatcher.getInstance():publish("OnVehicleLoaded", {
        vehicleId            = vehicle.id,
        ctldVehicleObject    = vehicle,
        dcsUnitObject        = method == "dcs_native" and vehicle.unit or nil,
        vehicleType          = vehicle.vehicleType,
        transportUnitObject  = transport,
        player               = player,
        method               = method,
        spawnMethod          = "request_vehicle",
        position             = unitPos,
        transportPosition    = transport:getPoint(),
        timestamp            = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner: loaded %s id=%s method=%s into %s",
        vehicle.vehicleType, vehicle.id, method, transport:getName()))
end

-- ============================================================
-- unloadVehicle
-- ============================================================

--- Unload a vehicle from a transport.
-- For menu_ctld / parachute: respawns DCS unit near transport via dynAdd.
-- For dcs_native: DCS has already placed the unit on the ground — just refresh the ref.
-- Publishes OnVehicleUnloaded.
--
-- @param vehicle   CTLDVehicle
-- @param transport DCS Unit
-- @param player    string|nil
-- @param method    string      "menu_ctld" | "dcs_native" | "parachute"
function CTLDVehicleSpawner:unloadVehicle(vehicle, transport, player, method)
    if vehicle:getState() ~= CTLDVehicle.STATE.LOADED then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:unloadVehicle — vehicle "
            .. vehicle.id .. " not in LOADED state")
        return
    end

    local sd       = vehicle.spawnData
    local spawnPos = _computeSpawnPosition(transport)
    local unloadedUnit

    if method == "dcs_native" then
        -- DCS has already placed the unit on the ground — recover the live ref.
        local g = Group.getByName(sd.groupName)
        unloadedUnit = g and g:getUnit(1) or nil
    else
        -- Virtual unload: respawn unit near transport.
        local spawnHdg = ctld.utils.getHeadingInRadians(
                             "CTLDVehicleSpawner:unloadVehicle", transport, true)
        local groupData = {
            visible  = true,
            hidden   = false,
            category = Group.Category.GROUND,
            country  = sd.countryId,
            name     = sd.groupName,
            task     = {},
            units    = {
                {
                    type           = sd.vehicleType,
                    name           = sd.unitName,
                    x              = spawnPos.x,
                    y              = spawnPos.z,
                    heading        = spawnHdg,
                    skill          = "Random",
                    playerCanDrive = false,
                }
            },
        }
        local result = ctld.utils.dynAdd("CTLDVehicleSpawner:unloadVehicle", groupData)
        if not result then
            ctld.utils.log("ERROR", "CTLDVehicleSpawner:unloadVehicle — dynAdd failed for id="
                .. vehicle.id)
            return
        end
        local respawnedGroup = Group.getByName(result.name)
        unloadedUnit = respawnedGroup and respawnedGroup:getUnit(1) or nil
    end

    vehicle.unit = unloadedUnit
    -- Vehicle is physically back on the ground — return to WAITING so it can be re-loaded.
    -- DELIVERED is reserved for parachute delivery (_parachuteVehicle).
    vehicle:setState(CTLDVehicle.STATE.WAITING)

    -- Re-register reverse lookup
    if unloadedUnit then
        self._unitToVehicle[unloadedUnit:getName()] = vehicle.id
    end

    -- Update DCS internal cargo weight (dcs_native weight is managed by DCS itself).
    if method ~= "dcs_native" then
        self:_updateVehicleCargo(transport:getName())
    end

    -- Resume JTAC lasing if this vehicle is a registered JTAC.
    local groupName = sd and sd.groupName
    if groupName then
        CTLDJTACManager.get():resumeJTAC(groupName)
    end

    EventDispatcher.getInstance():publish("OnVehicleUnloaded", {
        vehicleId            = vehicle.id,
        ctldVehicleObject    = vehicle,
        dcsUnitObject        = unloadedUnit,
        vehicleType          = vehicle.vehicleType,
        transportUnitObject  = transport,
        player               = player,
        method               = method,
        spawnMethod          = "request_vehicle",
        position             = spawnPos,
        timestamp            = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", string.format(
        "CTLDVehicleSpawner: unloaded %s id=%s method=%s from %s",
        vehicle.vehicleType, vehicle.id, method, transport:getName()))
end

-- ============================================================
-- Bbox helpers (_worldToLocal, _isInBbox)
-- ============================================================

--- Convert a world-frame point to the local frame of a DCS unit.
-- @param worldPoint vec3  { x, y, z } in world coordinates
-- @param transform  table Unit:getTransformation() result
--                   { p={x,y,z}, x={x,y,z}, y={x,y,z}, z={x,y,z} }
-- @return vec3  local-frame coordinates
function CTLDVehicleSpawner:_worldToLocal(worldPoint, transform)
    local dx = worldPoint.x - transform.p.x
    local dy = worldPoint.y - transform.p.y
    local dz = worldPoint.z - transform.p.z
    return {
        x = dx * transform.x.x + dy * transform.x.y + dz * transform.x.z,
        y = dx * transform.y.x + dy * transform.y.y + dz * transform.y.z,
        z = dx * transform.z.x + dy * transform.z.y + dz * transform.z.z,
    }
end

--- True if a local-frame point lies within a DCS bounding box.
-- @param localPoint vec3  result of _worldToLocal
-- @param box        table desc.box  { min={x,y,z}, max={x,y,z} }
-- @return boolean
function CTLDVehicleSpawner:_isInBbox(localPoint, box)
    return  localPoint.x >= box.min.x and localPoint.x <= box.max.x
        and localPoint.y >= box.min.y and localPoint.y <= box.max.y
        and localPoint.z >= box.min.z and localPoint.z <= box.max.z
end

-- ============================================================
-- _checkNativeLoading  (periodic, every 1 s)
-- ============================================================

--- Periodic check for DCS-native C-130 / Il-76 bbox load / unload detection.
-- For every transport in vehicleTransportEnabled that exists on the map:
--   • WAITING vehicle enters bbox  → loadVehicle (method="dcs_native")
--   • LOADED  vehicle exits  bbox  → unloadVehicle (method depends on inAir flag)
function CTLDVehicleSpawner:_checkNativeLoading()
    local vehicleTransports = ctld.gs("vehicleTransportEnabled") or {}
    if #vehicleTransports == 0 then return end

    -- Collect all active WAITING vehicles with live units
    local waitingVehicles = {}
    for id, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.WAITING
            and veh.unit and veh.unit:isExist() then
            waitingVehicles[id] = veh
        end
    end

    -- Collect all LOADED vehicles tracked via dcs_native
    local nativeLoaded = {}
    for id, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.LOADED
            and veh.loadMethod == "dcs_native" then
            nativeLoaded[id] = veh
        end
    end

    if not next(waitingVehicles) and not next(nativeLoaded) then return end

    -- Iterate transports currently known as player units (via CTLDPlayerTracker)
    -- and check each capable-transport unit that we can find by name
    -- Simple approach: scan all groups of both coalitions for matching type
    for _, side in ipairs({ coalition.side.BLUE, coalition.side.RED }) do
        local groups = coalition.getGroups(side, Group.Category.AIRPLANE) or {}
        for _, grp in ipairs(groups) do
            local units = grp:getUnits() or {}
            for _, transport in ipairs(units) do
                if transport:isExist() and _isNativeCargoCapable(transport) then
                    local ok, transform = pcall(function()
                        return transport:getTransformation()
                    end)
                    local ok2, box
                    if ok and transform then
                        ok2, box = pcall(function()
                            return transport:getDesc().box
                        end)
                    end

                    if ok and transform and ok2 and box then
                        local tName = transport:getName()

                        -- Check WAITING vehicles for bbox entry
                        for id, veh in pairs(waitingVehicles) do
                            local uPos = veh.unit:getPoint()
                            local lp   = self:_worldToLocal(uPos, transform)
                            if self:_isInBbox(lp, box) then
                                -- Vehicle entered bbox → load
                                self:loadVehicle(veh, transport, nil, "dcs_native")
                                -- Track transport for exit detection
                                self._nativeTracked[tName] = self._nativeTracked[tName] or {}
                                self._nativeTracked[tName][id] = true
                                waitingVehicles[id] = nil  -- prevent double-fire
                            end
                        end

                        -- Check LOADED (native) vehicles for bbox exit
                        for id, veh in pairs(nativeLoaded) do
                            if veh.loadTransportName == tName then
                                -- Vehicle is LOADED but we can't query its position (unit destroyed)
                                -- Use the tracked entry: if transport still alive, consider still loaded
                                -- Exit is detected by the transport being gone or in a different state
                                -- NOTE: When DCS ejects cargo the unit reappears; we detect the
                                -- re-appearance via the unit's new existence on next tick.
                                -- For parachute / ground exit we check if the spawned unit exists again.
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- INIT-D — MM vehicle detection
-- ============================================================

--- Register a single live DCS Unit as a WAITING CTLDVehicle if its type
-- has a spawnableCrates descriptor and is not already tracked.
-- Called both at startup (scanMMVehicles) and on S_EVENT_BIRTH (late activation).
-- @param unit  DCS Unit
function CTLDVehicleSpawner:_registerMMVehicleUnit(unit)
    if not (unit and unit:isExist()) then return end
    local unitName = unit:getName()
    if self._unitToVehicle[unitName] then return end  -- already tracked

    local typeName   = unit:getTypeName()
    local descriptor = CTLDCrateManager.getInstance():findDescriptorByUnitType(typeName)
    if not descriptor then return end  -- not a CTLD-known vehicle type

    self._vehicleCount = self._vehicleCount + 1
    local id = string.format("veh_mm_%d", self._vehicleCount)

    local grp = unit:getGroup()
    local spawnData = {
        groupName   = grp and grp:getName() or unitName,
        unitName    = unitName,
        vehicleType = typeName,
        coalitionId = unit:getCoalition(),
        countryId   = unit:getCountry(),
    }

    local vehicle = CTLDVehicle:new({
        id          = id,
        vehicleType = typeName,
        unit        = unit,
        spawnData   = spawnData,
    })

    self._vehicles[id]          = vehicle
    self._unitToVehicle[unitName] = id

    ctld.utils.log("INFO",
        "CTLDVehicleSpawner: INIT-D registered MM vehicle id=%s type=%s unit=%s",
        id, typeName, unitName)
end

--- INIT-D: scan all active ground groups for MM-placed vehicles with CTLD descriptors.
-- Only registers units that are alive (isExist=true) — late-activation groups are skipped.
function CTLDVehicleSpawner:scanMMVehicles()
    local sides = { coalition.side.RED, coalition.side.BLUE }
    local count = 0
    for _, side in ipairs(sides) do
        local groups = coalition.getGroups(side, Group.Category.GROUND) or {}
        for _, grp in ipairs(groups) do
            for _, unit in ipairs(grp:getUnits() or {}) do
                if unit:isExist() then
                    local before = self._vehicleCount
                    self:_registerMMVehicleUnit(unit)
                    if self._vehicleCount > before then count = count + 1 end
                end
            end
        end
    end
    ctld.utils.log("INFO", "CTLDVehicleSpawner: INIT-D complete — %d MM vehicle(s) registered", count)
end

--- S_EVENT_BIRTH handler: register late-activation MM ground vehicles.
-- S_EVENT_BIRTH fires synchronously inside coalition.addGroup, before the calling
-- CTLD spawn function (spawnVehicleForTransport, registerJTACVehicle, etc.) has had
-- time to register the vehicle. Processing is therefore deferred by one frame via
-- timer.scheduleFunction so that all CTLD registrations complete first.
function CTLDVehicleSpawner:onBirth(event)
    if not event or not event.initiator then return end
    local ok, unit = pcall(function() return event.initiator end)
    if not ok or not unit then return end
    local okCat, cat = pcall(function() return Object.getCategory(unit) end)
    if not okCat or cat ~= Object.Category.UNIT then return end
    local okGrp, grp = pcall(function() return unit:getGroup() end)
    if not okGrp or not grp then return end
    if grp:getCategory() ~= Group.Category.GROUND then return end

    -- Capture ref for the deferred callback (unit object stays valid across frames).
    local capturedUnit = unit
    timer.scheduleFunction(function()
        local inst = CTLDVehicleSpawner._instance
        if inst then inst:_onBirthDeferred(capturedUnit) end
    end, nil, timer.getTime())
end

--- Deferred S_EVENT_BIRTH processing — runs one frame after the birth event.
-- By this point every CTLD spawn function has registered its vehicle in _vehicles,
-- so _unitToVehicle guards work correctly without any name-prefix assumptions.
function CTLDVehicleSpawner:_onBirthDeferred(unit)
    if not (unit and unit:isExist()) then return end
    local unitName = unit:getName()

    -- Already tracked by a CTLD spawn function — nothing to do.
    if self._unitToVehicle[unitName] then return end

    -- Post-unload MM vehicle respawn: _unitToVehicle was cleared on load but the
    -- CTLDVehicle object is still in _vehicles (state LOADED → WAITING after unload).
    for _, veh in pairs(self._vehicles) do
        if veh.spawnData and veh.spawnData.unitName == unitName then
            veh.unit = unit
            self._unitToVehicle[unitName] = veh.id
            ctld.utils.log("INFO",
                "CTLDVehicleSpawner:_onBirthDeferred — updated ref for existing vehicle id=%s unit=%s",
                veh.id, unitName)
            return
        end
    end

    -- Unknown unit — register as a new MM vehicle if it has a CTLD descriptor.
    self:_registerMMVehicleUnit(unit)
end

-- ============================================================
-- onDead  (S_EVENT_DEAD handler)
-- ============================================================

--- Handle S_EVENT_DEAD: if the dead unit is a tracked vehicle, publish OnVehicleDead.
-- Also handles transport destruction: if the dead unit is a transport carrying LOADED
-- vehicles, each vehicle is considered lost — JTAC is deregistered and OnVehicleDead
-- is published for each.
function CTLDVehicleSpawner:onDead(event)
    if not event or not event.initiator then return end
    local ok, unitName = pcall(function() return event.initiator:getName() end)
    if not ok then return end

    local vehicleId = self._unitToVehicle[unitName]
    if vehicleId then
        -- Dead unit is a tracked ground vehicle.
        local vehicle = self._vehicles[vehicleId]
        if not vehicle then return end

        local pos      = vehicle.unit and vehicle.unit:getPoint() or { x = 0, y = 0, z = 0 }
        local spawnedAt = vehicle.spawnTime or 0

        self._vehicles[vehicleId]    = nil
        self._unitToVehicle[unitName] = nil

        EventDispatcher.getInstance():publish("OnVehicleDead", {
            vehicleId     = vehicleId,
            vehicle       = event.initiator,
            vehicleType   = vehicle.vehicleType,
            coalition     = vehicle.spawnData and vehicle.spawnData.coalitionId or nil,
            position      = pos,
            durationAlive = timer.getTime() - spawnedAt,
            timestamp     = timer.getAbsTime(),
        })
        EventDispatcher.getInstance():publish("OnGroundUnitRemoved", {
            vehicleType = vehicle.vehicleType,
            position    = pos,
            reason      = "dead",
            timestamp   = timer.getAbsTime(),
        })

        ctld.utils.log("INFO", string.format(
            "CTLDVehicleSpawner: vehicle %s (%s) dead",
            vehicleId, vehicle.vehicleType))
        return
    end

    -- Dead unit is not a tracked vehicle — check if it is a transport carrying LOADED vehicles.
    -- Collect all vehicles loaded on this transport before iterating (safe pairs modification).
    local lost = {}
    for id, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.LOADED
            and veh.loadTransportName == unitName then
            table.insert(lost, { id = id, veh = veh })
        end
    end

    if #lost == 0 then return end

    local transportPos = { x = 0, y = 0, z = 0 }
    local ok2, pos2 = pcall(function() return event.initiator:getPoint() end)
    if ok2 and pos2 then transportPos = pos2 end

    local jtacMgr = CTLDJTACManager.get()
    for _, entry in ipairs(lost) do
        local id  = entry.id
        local veh = entry.veh

        -- Deregister JTAC silently (frees laser code + claim, no OnJTACDead).
        local gname = veh.spawnData and veh.spawnData.groupName
        if gname and jtacMgr.jtacs and jtacMgr.jtacs[gname] then
            jtacMgr:deregisterJTAC(gname)
        end

        -- Clear reverse lookup if still present (dcs_native load keeps unit alive briefly).
        if veh.unit then
            self._unitToVehicle[veh.unit:getName()] = nil
        end
        self._vehicles[id] = nil

        EventDispatcher.getInstance():publish("OnVehicleDead", {
            vehicleId     = id,
            vehicle       = nil,   -- unit was inside transport, no live DCS ref
            vehicleType   = veh.vehicleType,
            coalition     = veh.spawnData and veh.spawnData.coalitionId or nil,
            position      = transportPos,
            durationAlive = timer.getTime() - (veh.spawnTime or 0),
            timestamp     = timer.getAbsTime(),
        })

        ctld.utils.log("INFO", string.format(
            "CTLDVehicleSpawner: vehicle %s (%s) lost — transport %s destroyed",
            id, veh.vehicleType, unitName))
    end
end

-- ============================================================
-- Feature A — Virtual parachute
-- ============================================================

--- Replace the parachute visual effect handler.
-- @param effect CTLDParachuteEffect
function CTLDVehicleSpawner:setParachuteEffect(effect)
    self._parachuteEffect = effect
end

--- Parachute a vehicle currently loaded on a transport.
-- Altitude AGL is checked at call time. If below parachuteMinAltitudeVehicles,
-- a message is sent and nothing happens.
-- Computes landing position, unloads the vehicle from the transport,
-- fires OnVehicleParachuting, then after descentTime spawns the vehicle
-- at the computed position and fires OnVehicleParachuteLanded.
-- @param transport  Unit    DCS transport unit
-- @param vehicleId  number  vehicle ID to drop (first loaded vehicle if nil)
-- @param playerObj  table   CTLDPlayer-like {groupId, unitName, coalition}
function CTLDVehicleSpawner:parachuteVehicle(transport, vehicleId, playerObj)
    local dropPos     = transport:getPoint()
    local groundUnder = land.getHeight({ x = dropPos.x, y = dropPos.z })
    local altAGL      = dropPos.y - groundUnder
    local minAlt      = ctld.gs("parachuteMinAltitudeVehicles") or 30

    if altAGL < minAlt then
        trigger.action.outTextForGroup(playerObj.groupId,
            string.format(ctld.tr("Altitude too low for parachute drop. Minimum: %dm AGL (current: %dm AGL)"),
                math.floor(minAlt), math.floor(altAGL)), 10)
        return
    end

    -- Resolve vehicle: use provided vehicleId or find first vehicle loaded on this transport
    local vehicle
    if vehicleId then
        vehicle = self._vehicles[vehicleId]
    else
        for _, v in pairs(self._vehicles) do
            if v.state == CTLDVehicle.STATE.LOADED and v.loadTransportName == transport:getName() then
                vehicle = v
                break
            end
        end
    end

    if not vehicle then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("No vehicle loaded."), 8)
        return
    end

    local descentRate = ctld.gs("parachuteDescentRateVehicles") or 8
    local landPos, descentTime = ctld.utils.calcDropPosition(transport, descentRate)

    -- Unload from transport — vehicle will be re-spawned at landing position.
    -- State is set to WAITING (not DELIVERED) so the vehicle can be reloaded after landing.
    local spawnData = vehicle.spawnData
    vehicle:setState(CTLDVehicle.STATE.WAITING)
    vehicle.loadTransportName = nil
    vehicle.loadMethod        = nil

    local dropData = {
        type          = "vehicle",
        unitName      = vehicle.vehicleType,
        dropPosition  = dropPos,
        landPositions = { landPos },
        altitude      = altAGL,
        descentTime   = descentTime,
        transport     = transport,
        player        = playerObj.unitName,
    }
    self._parachuteEffect:onStart(dropData)

    EventDispatcher.getInstance():publish("OnVehicleParachuting", {
        vehicle              = vehicle,
        transport            = transport:getName(),
        player               = playerObj.unitName,
        altitude             = altAGL,
        dropPosition         = dropPos,
        estimatedLandingPos  = landPos,
        estimatedLandingTime = timer.getAbsTime() + descentTime,
        timestamp            = timer.getAbsTime(),
    })

    local _vehicle   = vehicle
    local _landPos   = landPos
    local _dropData  = dropData
    local _spawnData = spawnData
    timer.scheduleFunction(function()
        -- Spawn vehicle at computed landing position
        local spawnPos = { x = _landPos.x, y = _landPos.y, z = _landPos.z }
        if _spawnData then
            self:spawnVehicleAt(_spawnData, spawnPos)
        end

        -- Resume JTAC lasing if this vehicle is a registered JTAC (was set IN_TRANSIT on load).
        local gname = _spawnData and _spawnData.groupName
        if gname then
            local jtacMgr = CTLDJTACManager.get()
            if jtacMgr.jtacs and jtacMgr.jtacs[gname] then
                jtacMgr:resumeJTAC(gname)
            end
        end

        self._parachuteEffect:onLanded(_dropData)

        EventDispatcher.getInstance():publish("OnVehicleParachuteLanded", {
            vehicle       = _vehicle,
            position      = _landPos,
            transport     = transport:getName(),
            player        = playerObj.unitName,
            startAltitude = altAGL,
            timestamp     = timer.getAbsTime(),
        })
    end, {}, timer.getTime() + descentTime)
end

--- Low-level ground unit factory.
-- Calls ctld.utils.spawnFromDescriptor (GROUND) and publishes OnGroundUnitSpawned so that
-- nearby Pack Vehicle menus refresh automatically.
-- @param spawnData  table  { vehicleType, groupName, unitName, coalitionId, country }
-- @param position   vec3   world position {x, y, z}
function CTLDVehicleSpawner:_spawnGroundUnit(spawnData, position)
    if not spawnData then return end
    local cId     = spawnData.country or spawnData.coalitionId or 2
    local unitDef = {
        name    = spawnData.groupName or (spawnData.vehicleType .. "_spawn_" .. timer.getAbsTime()),
        task    = "Ground Nothing",
        units   = {{
            type    = spawnData.vehicleType,
            name    = spawnData.unitName or spawnData.vehicleType,
            x       = position.x,
            y       = position.z,
            heading = 0,
        }},
    }
    local ok, err = ctld.utils.spawnFromDescriptor(nil, cId, unitDef)
    if not ok then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:_spawnGroundUnit - spawnFromDescriptor failed: " .. tostring(err))
        return
    end
    EventDispatcher.getInstance():publish("OnGroundUnitSpawned", {
        vehicleType = spawnData.vehicleType,
        position    = position,
        coalitionId = spawnData.coalitionId or 2,
        timestamp   = timer.getAbsTime(),
    })
end

--- Spawn a vehicle at an explicit world position (used by unpack and parachute drop).
-- @param spawnData  table   vehicle spawn descriptor
-- @param position   vec3    world position {x, y, z}
function CTLDVehicleSpawner:spawnVehicleAt(spawnData, position)
    self:_spawnGroundUnit(spawnData, position)
end

--- Refresh Pack Vehicle and Load Vehicle menus for all players within
-- maximumDistancePackableUnitsSearch of a position.
-- @param position vec3
function CTLDVehicleSpawner:_refreshNearbyPackPlayers(position)
    if not position then return end
    local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
    local pm      = CTLDPlayerManager.getInstance()
    for unitName in pairs(pm._players) do
        local unit = Unit.getByName(unitName)
        if unit and unit:isExist() then
            if ctld.utils.getDistance("_refreshNearbyPackPlayers", unit:getPoint(), position) <= maxDist then
                self:refreshPackSectionForUnit(unitName)
                self:refreshLoadSectionForUnit(unitName)
            end
        end
    end
end

-- ============================================================
-- F10 Menu section
-- ============================================================

-- ============================================================
-- Pack Vehicle
-- ============================================================

--- Detect inAir→landed transition for each player and refresh their menu.
-- Mirrors ctld.updatePackMenuOnlanding; called every 3 s from init timer.
function CTLDVehicleSpawner:_checkPackingLanding()
    if ctld.gs("enablePackingVehicles") ~= true then return end
    local players = CTLDPlayerManager.getInstance()._players
    for unitName, _ in pairs(players) do
        local unit = Unit.getByName(unitName)
        if unit and unit:isExist() then
            local inAirNow = ctld.utils.inAir(unit)
            if self._prevInAir[unitName] == true and not inAirNow then
                CTLDPlayerManager.getInstance():refreshForUnit(unitName)
            end
            self._prevInAir[unitName] = inAirNow
        else
            self._prevInAir[unitName] = nil
        end
    end
end

--- Periodic hint: send "Land to load vehicles" when a canCarryVehicles player hovers
-- between 3 m and maximumHoverHeight above a WAITING vehicle.
-- Called every 5 s; per-player cooldown of 30 s.
function CTLDVehicleSpawner:_checkVehicleHoverHint()
    local now      = timer.getTime()
    local cooldown = 30
    local minH     = 3.0
    local maxH     = ctld.gs("maximumHoverHeight") or 12.0
    local maxDist  = 5.0  -- tight horizontal window for hover detection
    local players  = CTLDPlayerManager.getInstance()._players

    for unitName, playerObj in pairs(players) do
        if playerObj.canCarryVehicles then
            local unit = Unit.getByName(unitName)
            if unit and unit:isExist() and ctld.utils.inAir(unit) then
                local lastHint = self._hoverHintSent[unitName] or 0
                if (now - lastHint) >= cooldown then
                    local tPos = unit:getPoint()
                    for _, veh in pairs(self._vehicles) do
                        if veh:getState() == CTLDVehicle.STATE.WAITING
                            and veh.unit and veh.unit:isExist() then
                            local vPos  = veh.unit:getPoint()
                            local dist2d = ctld.utils.getDistance(
                                "CTLDVehicleSpawner:_checkVehicleHoverHint", tPos, vPos)
                            local altDiff = tPos.y - vPos.y
                            if dist2d <= maxDist and altDiff >= minH and altDiff <= maxH then
                                self._hoverHintSent[unitName] = now
                                trigger.action.outTextForGroup(playerObj.groupId,
                                    ctld.tr("Land to load vehicles"), 8)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

--- Return packable vehicles within maximumDistancePackableUnitsSearch of a transport.
-- Searches ground units of the same coalition; matches DCS typeName against spawnableCrates[*].unit.
-- @param transport DCS Unit
-- @return table  array of { unitName (string), descriptor (table) }
function CTLDVehicleSpawner:findPackableVehicles(transport)
    local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
    local coa     = transport:getCoalition()
    local tPos    = transport:getPoint()
    local result  = {}

    local groups = coalition.getGroups(coa, Group.Category.GROUND) or {}
    for _, grp in ipairs(groups) do
        for _, unit in ipairs(grp:getUnits() or {}) do
            -- Use Unit.getByName for a fresh registry lookup instead of unit:isExist()
            -- on a stale group-iteration reference.  coalition.getGroups() may still
            -- return groups containing units that were destroy()-ed in the same tick;
            -- Unit.getByName returns nil for such units immediately after destroy().
            local uName   = unit:getName()
            local liveRef = Unit.getByName(uName)
            if liveRef and liveRef:isExist() then
                local dist = ctld.utils.getDistance(
                    "CTLDVehicleSpawner:findPackableVehicles", tPos, liveRef:getPoint())
                if dist <= maxDist then
                    local descriptor = CTLDCrateManager.getInstance()
                        :findDescriptorByUnitType(liveRef:getTypeName())
                    if descriptor then
                        table.insert(result, { unitName = uName, descriptor = descriptor })
                    end
                end
            end
        end
    end
    return result
end

--- Pack a vehicle back into crate(s).
-- Destroys the vehicle DCS unit and spawns cratesRequired static crates near the transport.
-- Front sector (heli) or rear sector (C-130/Il-76, dynamic cargo capable).
-- Publishes OnVehiclePacked and refreshes the player menu.
-- @param transportUnitName  string
-- @param packableUnitName   string
-- @param playerObj          table  { groupId, unitName, coalition }
function CTLDVehicleSpawner:packVehicle(transportUnitName, packableUnitName, playerObj)
    local transport = Unit.getByName(transportUnitName)
    if not (transport and transport:isExist()) then
        ctld.utils.log("WARNING", "CTLDVehicleSpawner:packVehicle - transport not found: "
            .. tostring(transportUnitName))
        return
    end

    local packableUnit = Unit.getByName(packableUnitName)
    if not (packableUnit and packableUnit:isExist()) then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("Vehicle no longer exists."), 8)
        return
    end

    local descriptor = CTLDCrateManager.getInstance()
        :findDescriptorByUnitType(packableUnit:getTypeName())
    if not descriptor then
        trigger.action.outTextForGroup(playerObj.groupId, ctld.tr("Cannot pack this vehicle type."), 8)
        return
    end

    local isDynamic    = _isNativeCargoCapable(transport)
    local hdg          = ctld.utils.getHeadingInRadians("CTLDVehicleSpawner:packVehicle", transport, true)
    local offset       = _secureOffset(transport)
    local cratesReq    = descriptor.cratesRequired or 1
    local modelKey     = isDynamic and "dynamic" or "load"
    local coa          = transport:getCoalition()
    local cId          = transport:getCountry()
    local tPos         = transport:getPoint()
    local packPos      = packableUnit:getPoint()   -- capture before destroy

    -- Silently deregister JTAC before destroy to prevent false OnJTACDead event.
    local packGroup = packableUnit:getGroup()
    if packGroup then
        CTLDJTACManager.get():deregisterJTAC(packGroup:getName())
    end

    packableUnit:destroy()
    EventDispatcher.getInstance():publish("OnGroundUnitRemoved", {
        vehicleType = packableUnit:getTypeName(),
        position    = packPos,
        reason      = "packed",
        timestamp   = timer.getAbsTime(),
    })

    -- Spawn crates in a straight line; spawnCratesAligned picks a random axis
    -- within the front sector (standard) or rear sector (native-cargo-capable).
    local descriptors = {}
    for _ = 1, cratesReq do table.insert(descriptors, descriptor) end
    CTLDCrateManager.getInstance():spawnCratesAligned(
        descriptors, transport, coa,
        playerObj and playerObj.unitName or nil,
        CTLDCrate.SPAWN_METHOD.VEHICLE_PACK)

    trigger.action.outTextForGroup(playerObj.groupId,
        string.format(ctld.tr("%s packed into %d crate(s)."), descriptor.desc, cratesReq), 10)

    EventDispatcher.getInstance():publish("OnVehiclePacked", {
        vehicleType  = packableUnit:getTypeName(),
        descriptor   = descriptor,
        transport    = transportUnitName,
        player       = playerObj and playerObj.unitName or nil,
        cratesSpawned = cratesReq,
        timestamp    = timer.getAbsTime(),
    })

    -- Defer menu rebuild by one frame: coalition.getGroups() has a 1-frame lag after
    -- unit:destroy(), so a same-tick rebuild would still find the (now dead) unit and
    -- re-add it to the Pack Vehicle menu, causing a "Vehicle no longer exists" error
    -- when the player clicks it later.
    local _tName = transportUnitName
    timer.scheduleFunction(function()
        CTLDPlayerManager.getInstance():refreshForUnit(_tName)
    end, nil, timer.getTime())
end

--- Refresh the "Pack Vehicle" submenu for a single player by unit name.
-- @param unitName string
function CTLDVehicleSpawner:refreshPackSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshPackSection(playerObj) end
end

--- Rebuild the "Pack Vehicle" dynamic submenu for playerObj.
-- Scans for packable ground vehicles within maximumDistancePackableUnitsSearch.
-- Called on menu build, on land, and after vehicle spawn (unpack).
-- @param playerObj CTLDPlayer
function CTLDVehicleSpawner:refreshPackSection(playerObj)
    if ctld.gs("enablePackingVehicles") ~= true then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local cratesSub = ctld.tr("Crate Commands")
    local packSub   = ctld.tr("Pack Vehicle")

    menu:clearBranch({ root, cratesSub, packSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, cratesSub, packSub },
            ctld.tr("Land to pack vehicles"), function() end, {})
        menu:refresh()
        return
    end

    local packable = self:findPackableVehicles(transport)
    if #packable == 0 then
        menu:addCommand({ root, cratesSub, packSub },
            ctld.tr("No packable vehicles nearby"), function() end, {})
    else
        for _, v in ipairs(packable) do
            menu:addCommand({ root, cratesSub, packSub }, v.descriptor.desc,
                function(arg)
                    CTLDVehicleSpawner.getInstance():packVehicle(
                        arg.transportName, arg.packableUnitName, arg)
                end,
                { transportName    = playerObj.unitName,
                  packableUnitName = v.unitName,
                  groupId          = playerObj.groupId,
                  unitName         = playerObj.unitName,
                  coalition        = playerObj.coalition })
        end
    end
    menu:refresh()
end

-- ============================================================
-- GAP-1 — Load / Unload vehicle via menu
-- ============================================================

--- Return loadable (WAITING) vehicles within maximumDistancePackableUnitsSearch of a transport.
-- Performs a lazy unit-reference resolution for vehicles registered before their DCS group
-- was fully available (coalition.addGroup has a 1-frame delay before Group.getByName works).
-- @param transport DCS Unit
-- @return table  array of CTLDVehicle
function CTLDVehicleSpawner:findLoadableVehicles(transport)
    local maxDist = ctld.gs("maximumDistancePackableUnitsSearch") or 200
    local tPos    = transport:getPoint()
    local result  = {}
    for id, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.WAITING then
            -- Lazy resolve: unit ref may be nil if registered before DCS group was ready.
            if not veh.unit and veh.spawnData and veh.spawnData.groupName then
                local g = Group.getByName(veh.spawnData.groupName)
                local u = g and g:getUnit(1) or nil
                if u and u:isExist() then
                    veh.unit = u
                    self._unitToVehicle[u:getName()] = id
                end
            end
            if veh.unit and veh.unit:isExist() then
                local dist = ctld.utils.getDistance(
                    "CTLDVehicleSpawner:findLoadableVehicles", tPos, veh.unit:getPoint())
                if dist <= maxDist then
                    table.insert(result, veh)
                end
            end
        end
    end
    return result
end

--- Return vehicles currently LOADED on a transport (by unit name).
-- @param transport DCS Unit
-- @return table  array of CTLDVehicle
function CTLDVehicleSpawner:findLoadedVehicles(transport)
    local tName  = transport:getName()
    local result = {}
    for _, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.LOADED
            and veh.loadTransportName == tName then
            table.insert(result, veh)
        end
    end
    return result
end

--- Compute total weight of menu_ctld-loaded vehicles on a transport and
--- apply it to the DCS internal cargo weight so the aircraft cannot take off
--- when overloaded.  dcs_native vehicles are excluded: DCS already manages
--- their physical weight internally.
--- @param transportUnitName string
function CTLDVehicleSpawner:_updateVehicleCargo(transportUnitName)
    local weights = ctld.gs("vehiclesWeight") or {}
    local total   = 0
    for _, veh in pairs(self._vehicles) do
        if veh:getState() == CTLDVehicle.STATE.LOADED
            and veh.loadTransportName == transportUnitName
            and veh.loadMethod == "menu_ctld" then
            local w = weights[veh.vehicleType] or 2500
            total   = total + w
        end
    end
    trigger.action.setUnitInternalCargo(transportUnitName, total)
    ctld.utils.log("INFO",
        "CTLDVehicleSpawner: setUnitInternalCargo %s = %d kg (vehicles)",
        transportUnitName, total)
end

--- Rebuild the "Load / Extract Vehicles" dynamic submenu for playerObj.
-- Transport must be landed; lists nearby WAITING vehicles.
-- @param playerObj CTLDPlayer
function CTLDVehicleSpawner:refreshLoadSection(playerObj)
    if not playerObj.canCarryVehicles then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root    = ctld.tr("CTLD")
    local vehSub  = ctld.tr("Vehicle Commands")
    local loadSub = ctld.tr("Load / Extract Vehicles")

    menu:clearBranch({ root, vehSub, loadSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, vehSub, loadSub },
            ctld.tr("Land to load vehicles"), function() end, {})
        menu:refresh()
        return
    end

    local loadable = self:findLoadableVehicles(transport)
    if #loadable == 0 then
        menu:addCommand({ root, vehSub, loadSub },
            ctld.tr("No vehicles nearby"), function() end, {})
    else
        for _, veh in ipairs(loadable) do
            local desc  = CTLDCrateManager.getInstance():findDescriptorByUnitType(veh.vehicleType)
            local label = desc and desc.desc or veh.vehicleType
            menu:addCommand({ root, vehSub, loadSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    local v = CTLDVehicleSpawner.getInstance()._vehicles[arg.vehicleId]
                    if not v or v:getState() ~= CTLDVehicle.STATE.WAITING then
                        trigger.action.outTextForGroup(arg.groupId,
                            ctld.tr("Vehicle no longer available."), 8)
                        return
                    end
                    CTLDVehicleSpawner.getInstance():loadVehicle(v, t, arg.unitName, "menu_ctld")
                    CTLDPlayerManager.getInstance():refreshForUnit(arg.unitName)
                end,
                { unitName  = playerObj.unitName,
                  groupId   = playerObj.groupId,
                  vehicleId = veh.id,
                  coalition = playerObj.coalition })
        end
    end
    menu:refresh()
end

--- Rebuild the "Unload Vehicles" dynamic submenu for playerObj.
-- Transport must be landed; lists vehicles currently LOADED on this transport.
-- @param playerObj CTLDPlayer
function CTLDVehicleSpawner:refreshUnloadSection(playerObj)
    if not playerObj.canCarryVehicles then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root      = ctld.tr("CTLD")
    local vehSub    = ctld.tr("Vehicle Commands")
    local unloadSub = ctld.tr("Unload Vehicles")

    menu:clearBranch({ root, vehSub, unloadSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, vehSub, unloadSub },
            ctld.tr("Land to unload vehicles"), function() end, {})
        menu:refresh()
        return
    end

    local loaded = self:findLoadedVehicles(transport)
    if #loaded == 0 then
        menu:addCommand({ root, vehSub, unloadSub },
            ctld.tr("No vehicle loaded."), function() end, {})
    else
        for _, veh in ipairs(loaded) do
            local desc  = CTLDCrateManager.getInstance():findDescriptorByUnitType(veh.vehicleType)
            local label = desc and desc.desc or veh.vehicleType
            menu:addCommand({ root, vehSub, unloadSub }, label,
                function(arg)
                    local t = Unit.getByName(arg.unitName)
                    if not (t and t:isExist()) then return end
                    local v = CTLDVehicleSpawner.getInstance()._vehicles[arg.vehicleId]
                    if not v or v:getState() ~= CTLDVehicle.STATE.LOADED then
                        trigger.action.outTextForGroup(arg.groupId,
                            ctld.tr("Vehicle no longer loaded."), 8)
                        return
                    end
                    CTLDVehicleSpawner.getInstance():unloadVehicle(v, t, arg.unitName, "menu_ctld")
                    CTLDPlayerManager.getInstance():refreshForUnit(arg.unitName)
                end,
                { unitName  = playerObj.unitName,
                  groupId   = playerObj.groupId,
                  vehicleId = veh.id,
                  coalition = playerObj.coalition })
        end
    end
    menu:refresh()
end

--- Refresh the "Load / Extract Vehicles" submenu for a player by unit name.
-- @param unitName string
function CTLDVehicleSpawner:refreshLoadSectionForUnit(unitName)
    ctld.utils.log("INFO", string.format("CTLDVehicleSpawner:refreshLoadSectionForUnit unitName=%s", unitName))
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshLoadSection(playerObj) end
end

--- Refresh the "Unload Vehicles" submenu for a player by unit name.
-- @param unitName string
function CTLDVehicleSpawner:refreshUnloadSectionForUnit(unitName)
    local playerObj = CTLDPlayerManager.getInstance()._players[unitName]
    if playerObj then self:refreshUnloadSection(playerObj) end
end

--- Build the "Vehicle Commands" F10 submenu for a player.
-- Added only when the unit can carry vehicles (canCarryVehicles = true).
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDVehicleSpawner:buildMenuSection(playerObj, menu)
    if not playerObj.canCarryVehicles then return end

    local root   = ctld.tr("CTLD")
    local vehSub = ctld.tr("Vehicle Commands")
    menu:addSubMenu({ root }, vehSub, { order = 30 })

    -- Dynamic load submenu (rebuilt by refreshLoadSection)
    menu:addSubMenu({ root, vehSub }, ctld.tr("Load / Extract Vehicles"))
    self:refreshLoadSection(playerObj)

    -- Dynamic unload submenu (rebuilt by refreshUnloadSection)
    menu:addSubMenu({ root, vehSub }, ctld.tr("Unload Vehicles"))
    self:refreshUnloadSection(playerObj)

    -- Parachute Vehicle: only if canParachute=true for this unit type
    local acts = (ctld.gs("unitActions") or {})[playerObj.typeName]
    if acts and acts.canParachute then
        menu:addCommand({ root, vehSub }, ctld.tr("Parachute Vehicle"),
            function(arg)
                local transport = Unit.getByName(arg.unitName)
                if not transport then return end
                CTLDVehicleSpawner.getInstance():parachuteVehicle(transport, nil, arg)
            end,
            { unitName = playerObj.unitName, groupId = playerObj.groupId,
              coalition = playerObj.coalition })
    end
end

-- End : CTLD_vehicle.lua
-- ====================================================================================================
-- Start : CTLD_fob.lua
-- ============================================================
-- CTLD_fob.lua
-- CTLDFOB entity + CTLDFOBManager singleton
--
-- FOB lifecycle:
--   1. Player collects FOB crates near a logistics zone.
--   2. Player flies to the target area and calls unpackFOBCrates().
--   3. FOB crates are destroyed; buildTimeFOB seconds later fobScene
--      spawns (outpost + watchtower) at 100 m / 12 o'clock of the transport.
--   4. CTLDZoneManager registers the FOB position as a logistic zone.
--   5. CTLDBeaconManager drops an infinite-battery FOB beacon.
--   6. If troopPickupAtFOB, the FOB is also tracked as a troop-pickup point.
--   7. S_EVENT_DEAD on any scene object triggers integrity check;
--      if alive fraction < (1 - fobDestructionThreshold) → FOB destroyed.
--
-- Events published:
--   OnFOBDeployed   — when the scene completes and the FOB is fully active
--   OnFOBDestroyed  — when integrity threshold is breached
--
-- Dependencies: class (lib/class.lua), CTLDUtils (ctld.utils),
--               CTLDConfig (ctld.gs), EventDispatcher,
--               CTLDCrateManager, CTLDZoneManager, CTLDBeaconManager,
--               CTLDSceneManager, CTLDDCSEventBridge
-- DCS API: Unit.getByName, land.getHeight, timer, trigger.action
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDFOB  (entity)
-- ============================================================

CTLDFOB = class()

--- Constructor.
-- @param data table
--   Required: fobId, name, coalitionId, position (vec3), countryId
--   Optional: sceneObjects (array of DCS StaticObject), beacon (CTLDBeacon)
function CTLDFOB:init(data)
    self.fobId        = data.fobId
    self.name         = data.name
    self.coalitionId  = data.coalitionId
    self.countryId    = data.countryId
    self.position     = data.position       -- centroid vec3
    self.sceneObjects = data.sceneObjects or {}
    self.beacon       = data.beacon or nil
    self.spawnTime    = timer.getAbsTime()
end

--- True if at least one scene object is still alive.
function CTLDFOB:isAlive()
    for _, obj in ipairs(self.sceneObjects) do
        if obj and obj:isExist() then return true end
    end
    return false
end

--- Alive fraction of scene objects (0.0–1.0). Returns 0 if no objects tracked.
function CTLDFOB:getIntegrityPercent()
    local total = #self.sceneObjects
    if total == 0 then return 0 end
    local alive = 0
    for _, obj in ipairs(self.sceneObjects) do
        if obj and obj:isExist() then alive = alive + 1 end
    end
    return alive / total
end


-- ============================================================
-- CTLDFOBManager  (singleton)
-- ============================================================

CTLDFOBManager = class()
CTLDFOBManager._instance = nil

function CTLDFOBManager.getInstance()
    if not CTLDFOBManager._instance then
        local o = setmetatable({}, CTLDFOBManager)
        o:init()
        CTLDFOBManager._instance = o
    end
    return CTLDFOBManager._instance
end

function CTLDFOBManager:init()
    self._fobs        = {}   -- fobId  → CTLDFOB
    self._fobCount    = 0
    self._objectToFOB = {}   -- DCS object name → fobId  (reverse lookup for onDead)

    local ok, bridge = pcall(CTLDDCSEventBridge.getInstance)
    if ok and bridge then
        bridge:register(self, world.event.S_EVENT_DEAD, "onDead")
    end

    CTLDPlayerManager.getInstance():registerMenuSection({
        key       = "fobs",
        manager   = self,
        method    = "buildMenuSection",
        configKey = "enabledFOBBuilding",
        order     = 60,
    })

    ctld.utils.log("INFO", "CTLDFOBManager: init complete")
end

-- ============================================================
-- Helpers
-- ============================================================

--- Compute the centroid 100 m at 12 o'clock from a transport unit.
local function _computeCentroid(transport)
    local pt  = transport:getPoint()
    local hdg = ctld.utils.getHeadingInRadians("CTLDFOBManager._computeCentroid", transport, true)
    local fx  = pt.x + math.cos(hdg) * 100
    local fz  = pt.z + math.sin(hdg) * 100
    return { x = fx, y = land.getHeight({ x = fx, y = fz }), z = fz }
end

--- Collect FOB crates on the ground within radius metres of position.
-- The FOB sentinel value is unit = "FOB" (set in spawnableCrates descriptor).
-- Returns { crates=[], total }.
local function _collectFOBCrates(position, coalitionId, radius)
    local cm     = CTLDCrateManager.getInstance()
    local nearby = cm:getCratesInRange(position, radius)
    local result = { crates = {}, total = 0 }

    for _, crate in ipairs(nearby) do
        if crate.coalition == coalitionId then
            local unit = crate.descriptor and crate.descriptor.unit
            if unit == "FOB" then
                result.total = result.total + 1
                result.crates[#result.crates + 1] = crate
            end
        end
    end

    return result
end

--- True if position is inside any active logistic zone for coalitionId.
local function _isInLogisticZone(position, coalitionId)
    local zm = CTLDZoneManager.getInstance()
    return zm:getLogisticZoneAtPoint(position, coalitionId) ~= nil
end

--- True if position is closer than fobMinDistanceFromZones to any logistic zone.
local function _isTooCloseToZone(position, coalitionId)
    local minDist = ctld.gs("fobMinDistanceFromZones") or 500
    local zm      = CTLDZoneManager.getInstance()
    for _, zone in ipairs(zm:getLogisticZonesForCoalition(coalitionId)) do
        if ctld.utils.getDistance("_isTooCloseToZone", position, zone:getCenter()) < minDist then
            return true
        end
    end
    return false
end

-- ============================================================
-- Core action: unpack FOB crates → schedule build
-- ============================================================

--- Called from F10 menu when a player attempts to unpack FOB crates.
-- @param transport DCS Unit
-- @param player    string  player name (display only)
function CTLDFOBManager:unpackFOBCrates(transport, player)
    if not ctld.gs("enabledFOBBuilding") then return end

    local gid = transport:getGroup():getID()

    -- Guard: airborne
    if ctld.utils.inAir(transport) then
        trigger.action.outTextForGroup(gid,
            ctld.tr("You must be on the ground to deploy a FOB."), 10)
        return
    end

    local pos         = transport:getPoint()
    local coalitionId = transport:getCoalition()

    -- Guard: not enough crates (checked first for clearer feedback)
    local fobDesc    = CTLDCrateManager.getInstance():findDescriptorByUnitType("FOB")
    local required   = (fobDesc and fobDesc.cratesRequired) or 3
    local collected  = _collectFOBCrates(pos, coalitionId, 750)
    if collected.total < required then
        trigger.action.outTextForGroup(gid,
            ctld.tr("FOB needs %1 crate(s) within 750 m - only %2 found.",
                required, collected.total), 15)
        return
    end

    -- Guard: inside existing logistic zone
    if _isInLogisticZone(pos, coalitionId) then
        trigger.action.outTextForGroup(gid,
            ctld.tr("You can't deploy a FOB here! Take it to where it's needed."), 20)
        return
    end

    -- Guard: too close to another zone
    if _isTooCloseToZone(pos, coalitionId) then
        local minDist = ctld.gs("fobMinDistanceFromZones") or 500
        trigger.action.outTextForGroup(gid,
            ctld.tr("FOB deployment blocked: move at least %1 m away from existing logistic zone.",
                minDist), 20)
        return
    end

    -- Destroy crates
    local cm          = CTLDCrateManager.getInstance()
    local cratesUsed  = {}
    for _, crate in ipairs(collected.crates) do
        cratesUsed[#cratesUsed + 1] = {
            crateName  = crate.crateName,
            descriptor = crate.descriptor,
        }
        cm:destroyCrate(crate.crateName)
    end

    -- Pre-compute centroid (100 m / 12 o'clock from transport NOW, not after buildTime)
    local centroid    = _computeCentroid(transport)
    local buildTime   = ctld.gs("buildTimeFOB") or 120
    local countryId   = transport:getCountry()
    local transName   = transport:getName()
    local self_ref    = self

    -- Visual feedback
    trigger.action.outTextForCoalition(coalitionId,
        ctld.tr("%1 started building a FOB (%2 crate(s)). Ready in %3 seconds.",
            player, #cratesUsed, buildTime), 10)

    -- Schedule scene spawn
    timer.scheduleFunction(function()
        local transport2 = Unit.getByName(transName)
        if not transport2 or not transport2:isExist() then
            -- Transport left; use a minimal proxy (coalition/country from cache)
            -- The scene will use params.centroid for positioning.
            transport2 = transport  -- stale ref — only coalition/country are read by scene engine
        end

        CTLDSceneManager.getInstance():playScene(
            transport2,
            "fobScene",
            { player = player, centroid = centroid },
            function(scene)
                self_ref:_onFOBBuilt(scene, transName, player, centroid, coalitionId, countryId, cratesUsed)
            end
        )
    end, nil, timer.getTime() + buildTime)
end

-- ============================================================
-- Post-scene callback
-- ============================================================

--- Called by fobScene's onComplete when all steps have finished.
function CTLDFOBManager:_onFOBBuilt(scene, transportName, player, centroid, coalitionId, countryId, cratesUsed)
    self._fobCount = self._fobCount + 1
    local fobId    = string.format("fob_%03d", self._fobCount)
    local fobName  = string.format("Deployed FOB #%d", self._fobCount)

    -- Collect spawned DCS objects from the scene
    local sceneObjects = scene._spawnedObjs or {}

    -- Build CTLDFOB entity
    local fob = CTLDFOB:new({
        fobId        = fobId,
        name         = fobName,
        coalitionId  = coalitionId,
        countryId    = countryId,
        position     = centroid,
        sceneObjects = sceneObjects,
    })

    -- Register reverse-lookup for onDead integrity tracking
    for _, obj in ipairs(sceneObjects) do
        if obj and obj:isExist() then
            self._objectToFOB[obj:getName()] = fobId
        end
    end

    self._fobs[fobId] = fob

    -- Register as logistic zone
    local logRadius = ctld.gs("fobLogisticZoneRadius") or 150
    CTLDZoneManager.getInstance():registerFOBAsLogistic(fobName, centroid, logRadius, coalitionId)

    -- Drop FOB beacon (infinite battery).
    -- Beacon is placed in the open space between container and watchtower:
    -- 20 m at 158° from the scene heading (same direction as watchtower step,
    -- but short enough to stay clear of both buildings).
    local transport = Unit.getByName(transportName)
    if transport and transport:isExist() and CTLDBeaconManager then
        local hdg        = scene._refHdgRad or 0
        local angleRad   = hdg + math.rad(158)
        local leftRad    = hdg - math.pi / 2   -- perpendicular left from heli heading
        local beaconPos  = {
            x = centroid.x + math.cos(angleRad) * 20 + math.cos(leftRad) * 7,
            y = centroid.y,
            z = centroid.z + math.sin(angleRad) * 20 + math.sin(leftRad) * 7,
        }
        local beacon = CTLDBeaconManager.getInstance():dropBeacon(transport, player, true, beaconPos)
        fob.beacon = beacon
    end

    -- Troop pickup at FOB
    if ctld.gs("troopPickupAtFOB") then
        fob._troopPickup = true
    end

    ctld.utils.log("INFO",
        "CTLDFOBManager: FOB '%s' deployed at (%.0f, %.0f) by '%s'",
        fobName, centroid.x, centroid.z, player)

    EventDispatcher.getInstance():publish("OnFOBDeployed", {
        fob = {
            fobId      = fobId,
            name       = fobName,
            coalitionId= coalitionId,
        },
        cratesUsed       = cratesUsed,
        totalCratesUsed  = #cratesUsed,
        position         = centroid,
        sceneObjects     = sceneObjects,
        logisticZone     = {
            name   = fobName,
            radius = logRadius,
            type   = "static",
        },
        player    = player,
        timestamp = timer.getAbsTime(),
    })
end

-- ============================================================
-- S_EVENT_DEAD — integrity check
-- ============================================================

function CTLDFOBManager:onDead(event)
    local obj = event.initiator
    if not obj then return end
    local objName = obj:getName()

    local fobId = self._objectToFOB[objName]
    if not fobId then return end

    local fob = self._fobs[fobId]
    if not fob then return end

    local threshold = ctld.gs("fobDestructionThreshold") or 0.5
    local integrity = fob:getIntegrityPercent()

    ctld.utils.log("INFO",
        "CTLDFOBManager: FOB '%s' scene object '%s' dead — integrity %.0f%%",
        fob.name, objName, integrity * 100)

    if integrity < (1 - threshold) then
        -- Killer info is not reliably available from S_EVENT_DEAD alone.
        local killerUnit      = nil
        local killerCoalition = nil
        self:_destroyFOB(fob, killerUnit, killerCoalition, integrity)
    end
end

--- Cleanup a destroyed FOB: remove logistic zone, publish event, unregister.
function CTLDFOBManager:_destroyFOB(fob, killerUnit, killerCoalition, integrityPercent)
    local objectsTotal     = #fob.sceneObjects
    local objectsDestroyed = objectsTotal - math.floor(integrityPercent * objectsTotal + 0.5)
    local durationAlive    = timer.getAbsTime() - fob.spawnTime

    -- Remove logistic zone
    CTLDZoneManager.getInstance():unregisterLogistic(fob.name)

    -- Clean reverse-lookup
    for _, obj in ipairs(fob.sceneObjects) do
        if obj then self._objectToFOB[obj:getName()] = nil end
    end

    -- Remove from registry
    self._fobs[fob.fobId] = nil

    ctld.utils.log("INFO",
        "CTLDFOBManager: FOB '%s' destroyed (%.0f%% integrity, alive %.0fs)",
        fob.name, (integrityPercent or 0) * 100, durationAlive)

    EventDispatcher.getInstance():publish("OnFOBDestroyed", {
        fob = {
            fobId      = fob.fobId,
            name       = fob.name,
            coalitionId= fob.coalitionId,
        },
        position = fob.position,
        destruction = {
            killerUnit         = killerUnit,
            killerCoalition    = killerCoalition,
            objectsDestroyed   = objectsDestroyed,
            objectsTotal       = objectsTotal,
            destructionThreshold = ctld.gs("fobDestructionThreshold") or 0.5,
            integrityPercent   = integrityPercent or 0,
        },
        logisticZone = { name = fob.name, wasActive = true },
        durationAlive = durationAlive,
        timestamp     = timer.getAbsTime(),
    })
end

-- ============================================================
-- Query API
-- ============================================================

--- Return all active FOBs for a coalition.
-- @param coalitionId number  coalition.side.*
-- @return table  array of CTLDFOB
function CTLDFOBManager:getFOBsForCoalition(coalitionId)
    local result = {}
    for _, fob in pairs(self._fobs) do
        if fob.coalitionId == coalitionId then
            result[#result + 1] = fob
        end
    end
    return result
end

--- True if point is within fobTroopPickupRadius of any troop-pickup FOB.
-- @param point       vec3
-- @param coalitionId number
-- @return boolean
function CTLDFOBManager:isInFOBTroopZone(point, coalitionId)
    local radius = ctld.gs("fobTroopPickupRadius") or 150
    for _, fob in pairs(self._fobs) do
        if fob.coalitionId == coalitionId and fob._troopPickup and fob:isAlive() then
            if ctld.utils.getDistance(point, fob.position) <= radius then
                return true
            end
        end
    end
    return false
end

--- Display active (alive) FOB positions to the transport's group.
-- Shows: name, coords, integrity%, beacon freqs if present.
-- Destroyed FOBs are silently omitted.
-- @param transport DCS Unit
function CTLDFOBManager:listFOBs(transport)
    local coalitionId = transport:getCoalition()
    local gid         = transport:getGroup():getID()
    local all         = self:getFOBsForCoalition(coalitionId)

    -- Keep only alive FOBs
    local fobs = {}
    for _, fob in ipairs(all) do
        if fob:isAlive() then fobs[#fobs + 1] = fob end
    end

    if #fobs == 0 then
        trigger.action.outTextForGroup(gid, ctld.tr("No active FOBs."), 15)
        return
    end

    local lines = { ctld.tr("FOB Positions:") }
    for _, fob in ipairs(fobs) do
        local lat, lon = coord.LOtoLL(fob.position)
        local latLon   = ctld.utils.tostringLL(
            "CTLDFOBManager:listFOBs", lat, lon, 3, ctld.gs("location_DMS") or false)
        local integrity = string.format("%.0f%%", fob:getIntegrityPercent() * 100)
        local line      = string.format("  %s — %s — %s", fob.name or fob.fobId, latLon, integrity)
        if fob.beacon then
            line = line .. string.format(
                "\n    VHF %.1f kHz / UHF %.1f MHz / FM %.1f MHz",
                fob.beacon.vhf / 1000,
                fob.beacon.uhf / 1000000,
                fob.beacon.fm  / 1000000)
        end
        lines[#lines + 1] = line
    end
    trigger.action.outTextForGroup(gid, table.concat(lines, "\n"), 20)
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Build the "FOBs List" F10 submenu (CTLD > FOBs List).
-- Registered with CTLDPlayerManager, gated by enabledFOBBuilding.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDFOBManager:buildMenuSection(playerObj, menu)
    local root   = ctld.tr("CTLD")
    local fobSub = ctld.tr("FOBs List")
    menu:addSubMenu({ root }, fobSub, { order = 60 })

    menu:addCommand({ root, fobSub }, ctld.tr("List active FOBs"),
        function(arg)
            local t = Unit.getByName(arg.unitName)
            if not (t and t:isExist()) then return end
            CTLDFOBManager.getInstance():listFOBs(t)
        end,
        { unitName = playerObj.unitName })
end

-- End : CTLD_fob.lua
-- ====================================================================================================
-- Start : CTLD_aasystem.lua
-- ============================================================
-- CTLD_aasystem.lua
-- CTLDCrateAssemblyManager singleton
--
-- Manages multi-part AA system assembly, rearm, and repair.
-- Supported systems: HAWK, Patriot, NASAMS, BUK, KUB, S-300.
--
-- Spawn geometry:
--   All parts are placed relative to the unpacking transport unit
--   (same pattern as CTLD_fob.lua: reference point at 100 m / 12 o'clock
--   of the transport, then parts arranged in a circle of radius spawnRadius
--   around that reference).  This avoids terrain issues caused by scattered
--   crate positions.
--
-- Usage (called by M7 menu):
--   local aam = CTLDCrateAssemblyManager.getInstance()
--   local handled = aam:tryUnpackOrRepair(heliUnit, crate, allCrates, radius)
--   -- if handled == false, caller falls through to standard unpack.
--
-- Events published:
--   OnAASystemDeployed  — full system assembled for the first time
--   OnAASystemRearmed   — extra launchers added to an existing complete system
--   OnAASystemRepaired  — damaged system respawned in place
--
-- Config keys: aaLaunchers, AASystemLimitRED, AASystemLimitBLUE,
--              AASystemCrateStacking
--
-- Dependencies: class (lib/class.lua), ctld.utils, ctld.gs,
--               EventDispatcher
-- DCS API: Unit, Group, land.getHeight, timer, trigger.action
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- AA system templates (static data — mission-maker can override
-- CTLDCrateAssemblyManager.TEMPLATES before init if needed).
-- Structure mirrors source ctld.AASystemTemplate.
-- ============================================================

CTLDCrateAssemblyManager = class()
CTLDCrateAssemblyManager._instance = nil

--- Static template table.  Each entry:
--   name    string   system display name
--   count   number   unique part types required for a complete system
--   parts   array    { name, desc, launcher?, amount?, NoCrate? }
--     name     DCS type name of the ground unit
--     desc     human-readable label (for "missing" messages)
--     launcher true   → this part is the "launcher" (used for rearm detection)
--     amount   number → override spawn count per template (default 1, or aaLaunchers for launchers)
--     NoCrate  true   → part is spawned without a crate (always found)
--   repair  string   DCS type name of the repair crate unit for this system
CTLDCrateAssemblyManager.TEMPLATES = {
    {
        name  = "HAWK AA System",
        count = 5,
        parts = {
            { name = "Hawk ln",   desc = "HAWK Launcher",     launcher = true },
            { name = "Hawk tr",   desc = "HAWK Track Radar",  amount = 2 },
            { name = "Hawk sr",   desc = "HAWK Search Radar", amount = 2 },
            { name = "Hawk pcp",  desc = "HAWK PCP",          NoCrate = true },
            { name = "Hawk cwar", desc = "HAWK CWAR",         amount = 2, NoCrate = true },
        },
        repair = "HAWK Repair",
    },
    {
        name  = "Patriot AA System",
        count = 4,
        parts = {
            { name = "Patriot ln",  desc = "Patriot Launcher",               launcher = true, amount = 8 },
            { name = "Patriot ECS", desc = "Patriot Control Unit" },
            { name = "Patriot str", desc = "Patriot Search and Track Radar", amount = 2 },
            { name = "Patriot AMG", desc = "Patriot AMG DL relay",           NoCrate = true },
        },
        repair = "Patriot Repair",
    },
    {
        name  = "NASAMS AA System",
        count = 3,
        parts = {
            { name = "NASAMS_LN_C",          desc = "NASAMS Launcher 120C",     launcher = true },
            { name = "NASAMS_Radar_MPQ64F1", desc = "NASAMS Search/Track Radar" },
            { name = "NASAMS_Command_Post",  desc = "NASAMS Command Post" },
        },
        repair = "NASAMS Repair",
    },
    {
        name  = "BUK AA System",
        count = 3,
        parts = {
            { name = "SA-11 Buk LN 9A310M1", desc = "BUK Launcher",    launcher = true },
            { name = "SA-11 Buk CC 9S470M1", desc = "BUK CC Radar" },
            { name = "SA-11 Buk SR 9S18M1",  desc = "BUK Search Radar" },
        },
        repair = "BUK Repair",
    },
    {
        name  = "KUB AA System",
        count = 2,
        parts = {
            { name = "Kub 2P25 ln",  desc = "KUB Launcher", launcher = true },
            { name = "Kub 1S91 str", desc = "KUB Radar" },
        },
        repair = "KUB Repair",
    },
    {
        name  = "S-300 AA System",
        count = 6,
        parts = {
            { name = "S-300PS 5P85C ln", desc = "S-300 Grumble TEL C",         launcher = true, amount = 1 },
            { name = "S-300PS 5P85D ln", desc = "S-300 Grumble TEL D",         NoCrate = true,  amount = 2 },
            { name = "S-300PS 40B6M tr", desc = "S-300 Grumble Flap Lid-A TR" },
            { name = "S-300PS 40B6MD sr",desc = "S-300 Grumble Clam Shell SR" },
            { name = "S-300PS 64H6E sr", desc = "S-300 Grumble Big Bird SR" },
            { name = "S-300PS 54K6 cp",  desc = "S-300 Grumble C2" },
        },
        repair = "S-300 Repair",
    },
}

-- ============================================================
-- Singleton
-- ============================================================

function CTLDCrateAssemblyManager.getInstance()
    if not CTLDCrateAssemblyManager._instance then
        local o = setmetatable({}, CTLDCrateAssemblyManager)
        o:init()
        CTLDCrateAssemblyManager._instance = o
    end
    return CTLDCrateAssemblyManager._instance
end

function CTLDCrateAssemblyManager:init()
    -- groupName → { details = [{point,unit,name,hdg}], template = template }
    self._completeSystems = {}
    ctld.utils.log("INFO", "CTLDCrateAssemblyManager: init complete")
end

-- ============================================================
-- Module-local helpers
-- ============================================================

local _SPAWN_RADIUS  = 50   -- metres, circle radius for unit placement around reference
local _REARM_DIST    = 300  -- metres, max dist to existing system for rearm
local _ASSEMBLY_DIST = 500  -- metres, max crate-to-reference dist for assembly

--- Compute the reference spawn origin: 100 m at 12 o'clock from the transport.
-- Mirrors _computeCentroid in CTLD_fob.lua.
local function _computeOrigin(transport)
    local pt  = transport:getPoint()
    local hdg = ctld.utils.getHeadingInRadians(
                    "CTLDCrateAssemblyManager._computeOrigin", transport, true)
    local fx  = pt.x + math.cos(hdg) * 100
    local fz  = pt.z + math.sin(hdg) * 100
    return { x = fx, y = land.getHeight({ x = fx, y = fz }), z = fz }
end

--- Return the launcher part name for a template, or nil.
local function _getLauncherUnit(template)
    for _, part in ipairs(template.parts) do
        if part.launcher then return part.name end
    end
    return nil
end

-- ============================================================
-- Public helpers
-- ============================================================

--- Find the AA template that owns a given DCS unit type name.
-- Checks both part names and the repair unit name.
-- @param unitName string   DCS type name (from crate descriptor.unit)
-- @return table|nil        template entry from TEMPLATES, or nil
function CTLDCrateAssemblyManager:getTemplateForUnit(unitName)
    if not unitName then return nil end
    for _, tmpl in ipairs(CTLDCrateAssemblyManager.TEMPLATES) do
        if tmpl.repair == unitName then return tmpl end
        for _, part in ipairs(tmpl.parts) do
            if part.name == unitName then return tmpl end
        end
    end
    return nil
end

--- Count complete active AA systems for a given coalition.
-- A system is complete when its group is still alive and contains the
-- required number of unique part types.
-- @param coalitionId number  coalition.side.*
-- @return number
function CTLDCrateAssemblyManager:countComplete(coalitionId)
    local count = 0
    for groupName, entry in pairs(self._completeSystems) do
        local grp = Group.getByName(groupName)
        if grp and grp:getCoalition() == coalitionId then
            local units = grp:getUnits() or {}
            local uniqueTypes = {}
            for _, u in ipairs(units) do
                if u:getLife() > 0 then
                    uniqueTypes[u:getTypeName()] = true
                end
            end
            local typeCount = 0
            for _ in pairs(uniqueTypes) do typeCount = typeCount + 1 end
            if typeCount >= entry.template.count then
                count = count + 1
            end
        end
    end
    return count
end

--- Return the config limit for a coalition.
-- @param coalitionId number
-- @return number
function CTLDCrateAssemblyManager:getAllowedCount(coalitionId)
    if coalitionId == coalition.side.BLUE then
        return ctld.gs("AASystemLimitBLUE") or 20
    end
    return ctld.gs("AASystemLimitRED") or 20
end

-- ============================================================
-- Main entry point
-- ============================================================

--- Try to handle an unpack action as an AA system operation.
-- Called by the M7 menu controller before falling through to standard unpack.
--
-- @param heli      Unit        transport unit performing the action
-- @param crate     CTLDCrate   the nearest crate (already confirmed on ground)
-- @param allCrates table       CTLDCrateManager.crates  (name → CTLDCrate)
-- @param radius    number|nil  search radius for nearby crates (default 500 m)
-- @return boolean  true if an AA action was performed (caller must not unpack further)
function CTLDCrateAssemblyManager:tryUnpackOrRepair(heli, crate, allCrates, radius)
    if not crate or not crate.descriptor then return false end

    local unitName = crate.descriptor.unit
    local template = self:getTemplateForUnit(unitName)
    if not template then return false end

    if unitName == template.repair then
        self:_repair(heli, crate, template)
    else
        self:_assemble(heli, crate, allCrates, template, radius or _ASSEMBLY_DIST)
    end
    return true
end

-- ============================================================
-- _assemble  (new deployment or rearm path)
-- ============================================================

--- Main assembly logic: collect nearby parts, check completeness, spawn.
-- First tries the rearm path if the nearest crate is a launcher and a
-- complete system exists within rearm distance.
-- @param heli      Unit
-- @param crate     CTLDCrate   nearest crate (the one the player is at)
-- @param allCrates table       name → CTLDCrate
-- @param template  table
-- @param radius    number      part search radius in metres
function CTLDCrateAssemblyManager:_assemble(heli, crate, allCrates, template, radius)
    -- Rearm path: launcher crate + existing complete system nearby
    if crate.descriptor.unit == _getLauncherUnit(template) then
        if self:_rearm(heli, crate, allCrates, template) then return end
    end

    -- Compute reference origin (100 m / 12 o'clock of heli)
    local origin = _computeOrigin(heli)

    -- ---- Collect all on-ground crates that are parts of this template ----
    -- systemParts[partName] = { desc, launcher, amount, NoCrate, found, required, crates[] }
    local systemParts = {}
    for _, part in ipairs(template.parts) do
        systemParts[part.name] = {
            desc     = part.desc,
            launcher = part.launcher,
            amount   = part.amount,
            NoCrate  = part.NoCrate,
            found    = part.NoCrate and 1 or 0,
            required = 1,
            crates   = {},
        }
    end

    for _, c in pairs(allCrates) do
        if c:isOnGround() and c.descriptor then
            local pName = c.descriptor.unit
            if systemParts[pName] then
                local dist = ctld.utils.getDistance(
                    "CTLDCrateAssemblyManager:_assemble",
                    origin, c.position)
                if dist <= radius then
                    local sp = systemParts[pName]
                    -- First occurrence: read cratesRequired from descriptor
                    if sp.found == 0 then
                        sp.required = c.descriptor.cratesRequired or 1
                    end
                    sp.found = sp.found + 1
                    table.insert(sp.crates, c)
                end
            end
        end
    end

    -- ---- Check completeness, build missing-parts message ----
    local missingTxt = ""
    for _, part in ipairs(template.parts) do
        local sp = systemParts[part.name]
        if sp.found < sp.required then
            missingTxt = missingTxt .. ctld.tr("Missing %1\n", "Missing " .. sp.desc .. "\n")
        end
    end

    if missingTxt ~= "" then
        trigger.action.outTextForGroup(
            heli:getGroup():getID(),
            ctld.tr("Cannot build %1\n%2\n\nOr the crates are not close enough together",
                    "Cannot build " .. template.name .. "\n" .. missingTxt ..
                    "\nOr the crates are not close enough together"),
            20)
        return
    end

    -- ---- Check system limit ----
    local coalitionId   = heli:getCoalition()
    local active        = self:countComplete(coalitionId)
    local allowed       = self:getAllowedCount(coalitionId)
    if active + 1 > allowed then
        trigger.action.outTextForGroup(
            heli:getGroup():getID(),
            ctld.tr("Out of parts for AA Systems. Current limit is %1\n",
                    "Out of parts for AA Systems. Current limit is " .. allowed),
            10)
        return
    end

    -- ---- Compute spawn positions relative to origin ----
    local positions, types, headings = self:_buildSpawnArrays(template, systemParts, origin, heli)

    -- ---- Destroy consumed crates ----
    local stacking = ctld.gs("AASystemCrateStacking") or false
    for _, part in ipairs(template.parts) do
        local sp = systemParts[part.name]
        if not sp.NoCrate then
            local amountFactor = stacking
                and (sp.found - sp.found % sp.required)
                or 1
            local toDelete  = amountFactor * sp.required
            local deleted   = 0
            for _, c in ipairs(sp.crates) do
                if deleted >= toDelete then break end
                c:destroy()
                deleted = deleted + 1
            end
        end
    end

    -- ---- Spawn group ----
    local spawnedGroup = self:_spawnGroup(heli, positions, types, headings)
    if not spawnedGroup then
        ctld.utils.log("ERROR", "CTLDCrateAssemblyManager:_assemble — spawnGroup failed for " .. template.name)
        return
    end

    self._completeSystems[spawnedGroup:getName()] = {
        details  = self:_getDetails(spawnedGroup, template),
        template = template,
    }

    EventDispatcher.getInstance():publish("OnAASystemDeployed", {
        systemName  = template.name,
        groupName   = spawnedGroup:getName(),
        heli        = heli,
        coalition   = coalitionId,
        position    = origin,
        timestamp   = timer.getAbsTime(),
    })

    trigger.action.outTextForCoalition(
        coalitionId,
        string.format("%s successfully deployed a full %s in the field.\n\nAA Active System limit: %d\nActive: %d",
            heli:getName(), template.name, allowed, active + 1),
        10)

    ctld.utils.log("INFO", string.format(
        "CTLDCrateAssemblyManager: deployed %s group=%s coalition=%d",
        template.name, spawnedGroup:getName(), coalitionId))
end

-- ============================================================
-- _rearm  (add launchers to existing complete system)
-- ============================================================

--- Add launcher crates to an existing complete system within rearm distance.
-- @param heli      Unit
-- @param crate     CTLDCrate   launcher crate
-- @param allCrates table
-- @param template  table
-- @return boolean  true if rearm was performed
function CTLDCrateAssemblyManager:_rearm(heli, crate, allCrates, template)
    local nearest = self:_findNearest(heli, template)
    if not nearest or nearest.dist > _REARM_DIST then return false end

    local grp   = nearest.group
    local units = grp:getUnits() or {}

    -- Collect current unit positions/types/headings from the live group
    local uniqueTypes = {}
    local points, types, headings = {}, {}, {}
    for _, u in ipairs(units) do
        if u:getLife() > 0 then
            uniqueTypes[u:getTypeName()] = true
            table.insert(points,   u:getPoint())
            table.insert(types,    u:getTypeName())
            table.insert(headings, ctld.utils.getHeadingInRadians(
                "CTLDCrateAssemblyManager:_rearm", u, true))
        end
    end

    local typeCount = 0
    for _ in pairs(uniqueTypes) do typeCount = typeCount + 1 end
    if typeCount < template.count then return false end  -- system not complete

    -- Destroy old group
    self._completeSystems[grp:getName()] = nil
    grp:destroy()

    -- Respawn with same positions/types/headings (fully rearmed)
    local spawnedGroup = self:_spawnGroup(heli, points, types, headings)
    if not spawnedGroup then
        ctld.utils.log("ERROR", "CTLDCrateAssemblyManager:_rearm — spawnGroup failed")
        return false
    end

    self._completeSystems[spawnedGroup:getName()] = {
        details  = self:_getDetails(spawnedGroup, template),
        template = template,
    }

    -- Destroy launcher crate
    crate:destroy()

    EventDispatcher.getInstance():publish("OnAASystemRearmed", {
        systemName = template.name,
        groupName  = spawnedGroup:getName(),
        heli       = heli,
        coalition  = heli:getCoalition(),
        timestamp  = timer.getAbsTime(),
    })

    trigger.action.outTextForCoalition(
        heli:getCoalition(),
        string.format("%s successfully rearmed a full %s in the field",
            heli:getName(),
            template.name),
        20)

    ctld.utils.log("INFO", "CTLDCrateAssemblyManager: rearmed " .. template.name)
    return true
end

-- ============================================================
-- _repair  (respawn damaged system in place)
-- ============================================================

--- Repair a damaged AA system: respawn it at the same positions/headings.
-- @param heli      Unit
-- @param crate     CTLDCrate   repair crate
-- @param template  table
function CTLDCrateAssemblyManager:_repair(heli, crate, template)
    local nearest = self:_findNearest(heli, template)
    if not nearest or nearest.dist > _REARM_DIST then
        trigger.action.outTextForGroup(
            heli:getGroup():getID(),
            string.format("Cannot repair %s. No damaged %s within %dm",
                template.name, template.name, _REARM_DIST),
            10)
        return
    end

    local entry   = self._completeSystems[nearest.group:getName()]
    local oldGrp  = nearest.group

    local points, types, headings = {}, {}, {}
    for _, detail in ipairs(entry.details) do
        table.insert(points,   detail.point)
        table.insert(types,    detail.unit)
        table.insert(headings, detail.hdg)
    end

    -- Destroy old (damaged) group
    self._completeSystems[oldGrp:getName()] = nil
    oldGrp:destroy()

    local spawnedGroup = self:_spawnGroup(heli, points, types, headings)
    if not spawnedGroup then
        ctld.utils.log("ERROR", "CTLDCrateAssemblyManager:_repair — spawnGroup failed")
        return
    end

    self._completeSystems[spawnedGroup:getName()] = {
        details  = self:_getDetails(spawnedGroup, template),
        template = template,
    }

    crate:destroy()

    EventDispatcher.getInstance():publish("OnAASystemRepaired", {
        systemName = template.name,
        groupName  = spawnedGroup:getName(),
        heli       = heli,
        coalition  = heli:getCoalition(),
        timestamp  = timer.getAbsTime(),
    })

    trigger.action.outTextForCoalition(
        heli:getCoalition(),
        string.format("%s successfully repaired a full %s in the field.",
            heli:getName(),
            template.name),
        10)

    ctld.utils.log("INFO", "CTLDCrateAssemblyManager: repaired " .. template.name)
end

-- ============================================================
-- Internal helpers
-- ============================================================

--- Find the nearest complete AA system of a given template type
-- that belongs to the same coalition as heli.
-- @param heli      Unit
-- @param template  table
-- @return table|nil  { group=Group, dist=number }
function CTLDCrateAssemblyManager:_findNearest(heli, template)
    local best     = nil
    local bestDist = -1
    local heliPos  = heli:getPoint()

    for groupName, entry in pairs(self._completeSystems) do
        if entry.template.name == template.name then
            local grp = Group.getByName(groupName)
            if grp and grp:getCoalition() == heli:getCoalition() then
                local units = grp:getUnits() or {}
                for _, u in ipairs(units) do
                    if u:getLife() > 0 then
                        local d = ctld.utils.getDistance(
                            "CTLDCrateAssemblyManager:_findNearest",
                            u:getPoint(), heliPos)
                        if d and (bestDist < 0 or d < bestDist) then
                            bestDist = d
                            best     = grp
                        end
                        break
                    end
                end
            end
        end
    end

    if best then return { group = best, dist = bestDist } end
    return nil
end

--- Capture current positions/types/headings of all alive units in a group.
-- Used to persist state for repair.
-- @param group    DCS Group
-- @param template table
-- @return array   { point, unit, name, hdg }
function CTLDCrateAssemblyManager:_getDetails(group, template)
    local details = {}
    local units   = group:getUnits() or {}
    for _, u in ipairs(units) do
        table.insert(details, {
            point = u:getPoint(),
            unit  = u:getTypeName(),
            name  = u:getName(),
            hdg   = ctld.utils.getHeadingInRadians(
                        "CTLDCrateAssemblyManager:_getDetails", u, true),
        })
    end
    return details
end

--- Build parallel position/type/heading arrays for dynAdd from systemParts.
-- All positions are relative to origin (100 m / 12 o'clock of transport).
-- Parts are arranged in a circle of radius _SPAWN_RADIUS around origin;
-- multiple units of the same part are evenly distributed around the circle.
-- NoCrate parts use random offsets within spawnRadius from origin.
-- @param template    table
-- @param systemParts table  name → { found, required, NoCrate, amount, ... }
-- @param origin      vec3   reference spawn point (from _computeOrigin)
-- @param heli        Unit   used to get heading for NoCrate offset direction
-- @return positions[], types[], headings[]
function CTLDCrateAssemblyManager:_buildSpawnArrays(template, systemParts, origin, heli)
    local positions = {}
    local types     = {}
    local headings  = {}

    local aaLaunchers  = ctld.gs("aaLaunchers") or 3
    local stacking     = ctld.gs("AASystemCrateStacking") or false
    local arcRad       = math.pi * 2
    -- Distribute each template part across equal arc segments so parts
    -- don't pile up on each other.  Index tracks arc offset per call.
    local partIndex    = 0
    local partCount    = #template.parts

    for _, part in ipairs(template.parts) do
        local sp = systemParts[part.name]

        -- Compute amountFactor (stacking multiplier)
        local amountFactor = 1
        if stacking and not sp.NoCrate and sp.required > 0 then
            amountFactor = sp.found - (sp.found % sp.required)
            if amountFactor < 1 then amountFactor = 1 end
        end

        -- Compute partAmount
        local partAmount = 1
        if part.amount then
            partAmount = part.amount
        elseif part.launcher then
            partAmount = aaLaunchers
        end
        partAmount = partAmount * amountFactor

        -- Arc base for this part (evenly spaced around circle)
        local arcBase = (arcRad / partCount) * partIndex

        if partAmount == 1 then
            local angle = arcBase
            local px = origin.x + math.cos(angle) * _SPAWN_RADIUS
            local pz = origin.z + math.sin(angle) * _SPAWN_RADIUS
            local py = land.getHeight({ x = px, y = pz })
            table.insert(positions, { x = px, y = py, z = pz })
            table.insert(types,     part.name)
            table.insert(headings,  angle)
        else
            local step = arcRad / partAmount
            for i = 1, partAmount do
                local angle = ((step * (i - 1)) + arcBase) % arcRad
                local px = origin.x + math.cos(angle) * _SPAWN_RADIUS
                local pz = origin.z + math.sin(angle) * _SPAWN_RADIUS
                local py = land.getHeight({ x = px, y = pz })
                table.insert(positions, { x = px, y = py, z = pz })
                table.insert(types,     part.name)
                table.insert(headings,  angle)
            end
        end

        partIndex = partIndex + 1
    end

    return positions, types, headings
end

--- Spawn a multi-unit ground group via dynAdd.
-- @param heli      Unit    used for country and coalition
-- @param positions array   vec3 per unit
-- @param types     array   DCS type name per unit
-- @param headings  array   radians per unit
-- @return DCS Group or nil
function CTLDCrateAssemblyManager:_spawnGroup(heli, positions, types, headings)
    if #positions == 0 then return nil end

    local baseName  = types[1] .. "_CTLD_AA_" .. tostring(math.floor(timer.getAbsTime()))
    local groupData = {
        visible  = false,
        hidden   = false,
        category = Group.Category.GROUND,
        country  = heli:getCountry(),
        name     = baseName,
        task     = {},
        units    = {},
    }

    for i, pos in ipairs(positions) do
        local hdg = headings[i] or 0
        groupData.units[i] = {
            type           = types[i],
            name           = string.format("CTLD_AA_%s_%d", types[i]:gsub("[%s/\\]", "_"), i),
            x              = pos.x,
            y              = pos.z,   -- dynAdd convention: y == world Z
            heading        = hdg,
            skill          = "High",
            playerCanDrive = false,
        }
    end

    local result = ctld.utils.dynAdd("CTLDCrateAssemblyManager:_spawnGroup", groupData)
    if not result then return nil end
    return Group.getByName(result.name)
end

-- End : CTLD_aasystem.lua
-- ====================================================================================================
-- Start : CTLD_beacon.lua
-- ============================================================
-- CTLD_beacon.lua
-- CTLDBeacon entity + CTLDBeaconManager singleton
--
-- Dependencies : class (lib/class.lua), CTLDUtils (ctld.utils),
--                CTLDConfig (ctld.gs), EventDispatcher
-- DCS API      : coalition.addGroup, Group.getByName, trigger.action,
--                coord.LOtoLL, coord.LLtoMGRS, timer, land.getHeight
--
-- Beacon lifecycle:
--   dropped  : 3 TACAN_beacon units spawned, radio transmissions started
--   active   : refresh every beaconRefreshInterval seconds
--   destroyed: battery depleted OR < 3 units alive → cleanup + free freqs
--   removed  : manual removal by player within 500m
--
-- Frequency pools (recycled when < 3 free):
--   VHF : 200–1250 kHz  (10 kHz steps below 850, 50 kHz above)
--   UHF : 220–399 MHz   (0.5 MHz steps)
--   FM  : 30–76 MHz     (formula: (100*f + 10*s + t) * 100 kHz)
--
-- Radio transmission modes:
--   VHF : mode 0 (AM), sound = radioSound
--   UHF : mode 0 (AM), sound = radioSoundFC3 (silent — FC3 aircraft)
--   FM  : mode 1 (FM), sound = radioSound
--
-- Draw layer:
--   Per-player toggle. Each beacon draws 2 circles + 1 text label.
--   Mark IDs: beaconId*10+1 (outer), *10+2 (inner), *10+3 (text).
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDBeacon  (entity)
-- ============================================================

CTLDBeacon = class()

--- Constructor.
-- @param data table
--   Required : beaconName, name, coalition, position
--              vhfGroupName, uhfGroupName, fmGroupName
--              vhf (Hz), uhf (Hz), fm (Hz)
--              batteryEndTime (-1 = infinite), spawnTime
-- @param data.isFOB bool  (default false)
function CTLDBeacon:init(data)
    self.beaconName    = data.beaconName     -- unique key (vhfGroupName)
    self.name          = data.name           -- display name ("Beacon #3")
    self.coalitionId   = data.coalitionId
    self.position      = data.position

    self.vhfGroupName  = data.vhfGroupName
    self.uhfGroupName  = data.uhfGroupName
    self.fmGroupName   = data.fmGroupName

    self.vhf           = data.vhf
    self.uhf           = data.uhf
    self.fm            = data.fm

    self.batteryEndTime= data.batteryEndTime  -- timer.getTime() + duration, or -1
    self.spawnTime     = data.spawnTime       -- timer.getAbsTime() at drop
    self.isFOB         = data.isFOB or false
end

--- True if the beacon battery is still alive (or infinite).
function CTLDBeacon:isBatteryAlive()
    return self.batteryEndTime == -1 or timer.getTime() < self.batteryEndTime
end

--- Number of still-alive DCS units for this beacon (0–3).
function CTLDBeacon:countAliveUnits()
    local n = 0
    for _, gname in ipairs({ self.vhfGroupName, self.uhfGroupName, self.fmGroupName }) do
        local g = Group.getByName(gname)
        if g and g:getUnits() and #g:getUnits() == 1 then n = n + 1 end
    end
    return n
end

--- Battery remaining in seconds. Returns math.huge for infinite beacons.
function CTLDBeacon:batteryRemaining()
    if self.batteryEndTime == -1 then return math.huge end
    return math.max(0, self.batteryEndTime - timer.getTime())
end

--- Formatted frequency string for display.
-- "245.00 kHz - 350.50 / 45.20 MHz"
function CTLDBeacon:freqText()
    return string.format("%.2f kHz - %.2f / %.2f MHz",
        self.vhf / 1000, self.uhf / 1000000, self.fm / 1000000)
end

--- Formatted MGRS string for the beacon position.
function CTLDBeacon:mgrsCoords()
    local lat, lon = coord.LOtoLL(self.position)
    local mgrs     = coord.LLtoMGRS(lat, lon)
    return string.format("%s %s %s",
        mgrs.UTMZone .. mgrs.MGRSDigraph,
        string.sub(mgrs.Easting,  1, 5),
        string.sub(mgrs.Northing, 1, 5))
end


-- ============================================================
-- CTLDBeaconManager  (singleton)
-- ============================================================

CTLDBeaconManager = class()
CTLDBeaconManager._instance = nil

function CTLDBeaconManager.getInstance()
    if not CTLDBeaconManager._instance then
        local o = setmetatable({}, CTLDBeaconManager)
        o:init()
        CTLDBeaconManager._instance = o
    end
    return CTLDBeaconManager._instance
end

function CTLDBeaconManager:init()
    self._beacons         = {}   -- beaconName -> CTLDBeacon
    self._beaconCount     = 0    -- monotonic counter for display names
    self._layerState      = {}   -- playerName -> { enabled=bool, marks={} }
    -- Mark IDs are allocated from ctld.utils.getNextMarkId() (app-wide monotonic counter)

    -- Frequency pools
    self._freeVHF  = {}
    self._usedVHF  = {}
    self._freeUHF  = {}
    self._usedUHF  = {}
    self._freeFM   = {}
    self._usedFM   = {}
    self:_buildFreqPools()

    if ctld.gs("enabledRadioBeaconDrop") then
        self:_scheduleRefresh()
    end

    CTLDPlayerManager.getInstance():registerMenuSection({
        key       = "beacons",
        manager   = self,
        method    = "buildMenuSection",
        configKey = "enabledRadioBeaconDrop",
        order     = 60,
    })
    ctld.utils.log("INFO", "CTLDBeaconManager: init complete")
end

-- ============================================================
-- Frequency pools
-- ============================================================

-- Known NDB frequencies to skip in VHF pool (kHz → × 1000 = Hz).
-- These match existing NDB beacons on DCS maps (Caucasus, Nevada, etc.)
-- and would interfere if used for CTLD radio beacons.
CTLDBeaconManager._ndbSkip = {
    745, 381, 384, 300.50, 312.5, 1175, 342, 735, 353.00, 440,
    795, 525, 520, 690, 625, 291.5, 435, 309.50, 920, 1065,
    274, 312.50, 580, 602, 297.50, 750, 485, 950, 214,
    1025, 730, 995, 455, 307, 670, 329, 395, 770,
    380, 705, 300.5, 507, 740, 1030, 515,
    330, 309.5, 348, 462, 905, 352, 1210, 942, 435, 324,
    320, 420, 311, 389, 396, 862, 680, 297.5, 920, 662,
    866, 907, 309.5, 822, 515, 470, 342, 1182, 309.5, 720, 528,
    337, 312.5, 830, 740, 309.5, 641, 312, 722, 682, 1050,
    1116, 935, 1000, 430, 577, 326,
}

function CTLDBeaconManager:_buildFreqPools()
    -- Build NDB skip set for fast lookup (Hz values)
    local skipSet = {}
    for _, kHz in ipairs(CTLDBeaconManager._ndbSkip) do
        skipSet[kHz * 1000] = true
    end

    -- VHF: 200–840 kHz by 10 kHz (skipping NDB), then 850–1250 kHz by 50 kHz (skipping NDB)
    for f = 200000, 840000, 10000 do
        if not skipSet[f] then self._freeVHF[#self._freeVHF + 1] = f end
    end
    for f = 850000, 1250000, 50000 do
        if not skipSet[f] then self._freeVHF[#self._freeVHF + 1] = f end
    end

    -- UHF: 220–398.5 MHz by 0.5 MHz (stops before 399 MHz, matching source)
    local f = 220000000
    while f < 399000000 do
        self._freeUHF[#self._freeUHF + 1] = f
        f = f + 500000
    end

    -- FM: (100*f + 10*s + t) * 100000 Hz, f=3..7, s=0..5, t=0..9
    for f = 3, 7 do
        for s = 0, 5 do
            for t = 0, 9 do
                self._freeFM[#self._freeFM + 1] = (100 * f + 10 * s + t) * 100000
            end
        end
    end
end

--- Draw one frequency from a pool, recycling used if < 3 free.
-- @param free  table (pool of free freqs)
-- @param used  table (pool of used freqs)
-- @return number frequency (Hz)
function CTLDBeaconManager:_pickFreq(free, used)
    if #free <= 3 then
        for _, f in ipairs(used) do free[#free + 1] = f end
        for k in pairs(used) do used[k] = nil end
    end
    local idx  = math.random(#free)
    local freq = table.remove(free, idx)
    used[#used + 1] = freq
    return freq
end

--- Return all three frequencies for a new beacon.
function CTLDBeaconManager:_assignFrequencies()
    return {
        vhf = self:_pickFreq(self._freeVHF, self._usedVHF),
        uhf = self:_pickFreq(self._freeUHF, self._usedUHF),
        fm  = self:_pickFreq(self._freeFM,  self._usedFM),
    }
end

--- Return frequencies to their free pools.
function CTLDBeaconManager:_freeFrequencies(beacon)
    self._freeVHF[#self._freeVHF + 1] = beacon.vhf
    self._freeUHF[#self._freeUHF + 1] = beacon.uhf
    self._freeFM[#self._freeFM + 1]   = beacon.fm
    -- Remove from used tables
    for _, pool in ipairs({ {self._usedVHF, beacon.vhf},
                             {self._usedUHF, beacon.uhf},
                             {self._usedFM,  beacon.fm} }) do
        for i = #pool[1], 1, -1 do
            if pool[1][i] == pool[2] then table.remove(pool[1], i); break end
        end
    end
end

-- ============================================================
-- Spawn helpers
-- ============================================================

--- Spawn one TACAN_beacon DCS group at position for a given country.
-- Returns the spawned Group, or nil on failure.
function CTLDBeaconManager:_spawnBeaconUnit(point, countryId, displayName)
    local uid = ctld.utils.getNextUniqId()
    local groupData = {
        visible  = false,
        hidden   = false,
        category = Group.Category.GROUND,
        country  = countryId,
        name     = "CTLDBeacon-" .. uid,
        task     = {},
        units    = {
            {
                type           = "TACAN_beacon",
                name           = "CTLDBeaconUnit-" .. uid .. " [" .. displayName .. "]",
                x              = point.x,
                y              = point.z,   -- DCS ground unit: y = world Z
                heading        = 0,
                playerCanDrive = true,
                skill          = "Excellent",
            }
        },
    }
    local result = ctld.utils.dynAdd("CTLDBeaconManager:_spawnBeaconUnit", groupData)
    if not result then
        ctld.utils.log("ERROR", "CTLDBeaconManager: dynAdd failed for beacon unit")
        return nil
    end
    return Group.getByName(result.name)
end

--- Start (or restart) radio transmissions for a beacon's three groups.
function CTLDBeaconManager:_startTransmissions(beacon)
    local soundNormal = "l10n/DEFAULT/" .. (ctld.gs("radioSound")    or "beacon.ogg")
    local soundSilent = "l10n/DEFAULT/" .. (ctld.gs("radioSoundFC3") or "beaconsilent.ogg")

    local entries = {
        { groupName = beacon.vhfGroupName, freq = beacon.vhf, mode = 0, sound = soundNormal },
        { groupName = beacon.uhfGroupName, freq = beacon.uhf, mode = 0, sound = soundSilent },
        { groupName = beacon.fmGroupName,  freq = beacon.fm,  mode = 1, sound = soundNormal },
    }

    for _, e in ipairs(entries) do
        local g = Group.getByName(e.groupName)
        if g and g:getUnits() and #g:getUnits() == 1 then
            local unit = g:getUnit(1)
            -- Set ROE: weapon hold
            g:getController():setOption(
                AI.Option.Ground.id.ROE,
                AI.Option.Ground.val.ROE.WEAPON_HOLD)
            trigger.action.stopRadioTransmission(e.groupName)
            trigger.action.radioTransmission(
                e.sound, unit:getPoint(), e.mode, true, e.freq, 1000, e.groupName)
        end
    end
end

--- Stop transmissions and destroy all three DCS groups for a beacon.
function CTLDBeaconManager:_destroyBeaconUnits(beacon)
    for _, gname in ipairs({ beacon.vhfGroupName, beacon.uhfGroupName, beacon.fmGroupName }) do
        local g = Group.getByName(gname)
        if g then
            trigger.action.stopRadioTransmission(gname)
            g:destroy()
        end
    end
end

-- ============================================================
-- Public actions
-- ============================================================

--- Drop a radio beacon at position, spawned by transport.
-- @param transport  Unit   DCS transport unit
-- @param player     string playerName
-- @param isFOB      bool   (default false)
-- @return CTLDBeacon or nil
function CTLDBeaconManager:dropBeacon(transport, player, isFOB, overridePosition)
    if not ctld.gs("enabledRadioBeaconDrop") then
        ctld.utils.log("WARN", "CTLDBeaconManager:dropBeacon — beacons disabled in config")
        return nil
    end

    local coalitionId= transport:getCoalition()
    local countryId  = transport:getCountry()

    -- When the transport is on the ground, offset the beacon behind the aircraft
    -- to avoid spawning the ground unit inside the aircraft's collision box.
    local point
    if overridePosition then
        point = overridePosition
    else
        local tPos = transport:getPoint()
        if not ctld.utils.inAir(transport) then
            -- Compute safe offset from bounding box (same method as crate spawn).
            local okBox, box = pcall(function() return transport:getDesc().box end)
            local offset = (okBox and box)
                and (math.max(math.abs(box.max.x), math.abs(box.min.x)) + 5)
                or 20
            local hdg = ctld.utils.getHeadingInRadians(
                "CTLDBeaconManager:dropBeacon", transport, true)
            -- Place beacon directly behind the aircraft (heading + π).
            local angle = hdg + math.pi
            local px = tPos.x + math.cos(angle) * offset
            local pz = tPos.z + math.sin(angle) * offset
            local py = land.getHeight({ x = px, y = pz })
            point = { x = px, y = py, z = pz }
        else
            point = tPos
        end
    end

    local freqs = self:_assignFrequencies()

    self._beaconCount = self._beaconCount + 1
    local displayName = "Beacon #" .. self._beaconCount
    local freqText    = string.format("%.2f kHz - %.2f / %.2f MHz",
        freqs.vhf / 1000, freqs.uhf / 1000000, freqs.fm / 1000000)

    local vhfGroup = self:_spawnBeaconUnit(point, countryId, displayName .. " VHF " .. freqText)
    local uhfGroup = self:_spawnBeaconUnit(point, countryId, displayName .. " UHF " .. freqText)
    local fmGroup  = self:_spawnBeaconUnit(point, countryId, displayName .. " FM "  .. freqText)

    if not (vhfGroup and uhfGroup and fmGroup) then
        ctld.utils.log("ERROR", "CTLDBeaconManager:dropBeacon — spawn failed for '%s'", displayName)
        return nil
    end

    local batteryMins = ctld.gs("deployedBeaconBattery") or 30
    local batteryEnd  = isFOB and -1 or (timer.getTime() + batteryMins * 60)

    local beacon = CTLDBeacon:new({
        beaconName    = vhfGroup:getName(),
        name          = displayName,
        coalitionId   = coalitionId,
        position      = point,
        vhfGroupName  = vhfGroup:getName(),
        uhfGroupName  = uhfGroup:getName(),
        fmGroupName   = fmGroup:getName(),
        vhf           = freqs.vhf,
        uhf           = freqs.uhf,
        fm            = freqs.fm,
        batteryEndTime= batteryEnd,
        spawnTime     = timer.getAbsTime(),
        isFOB         = isFOB or false,
    })

    self._beacons[beacon.beaconName] = beacon
    -- Delay transmissions by 1s: DCS coalition.addGroup leaves units uninitialized for ~1s;
    -- calling radioTransmission immediately yields an invalid position (0,0,0 or stale).
    local bname = beacon.beaconName
    timer.scheduleFunction(function()
        local b = CTLDBeaconManager.getInstance()._beacons[bname]
        if b then CTLDBeaconManager.getInstance():_startTransmissions(b) end
    end, nil, timer.getTime() + 1)

    -- Notify coalition
    trigger.action.outTextForCoalition(coalitionId,
        ctld.tr("Navigation beacon deployed - %1", freqText), 20)

    -- Update active layers
    self:_addBeaconToLayers(beacon)

    EventDispatcher.getInstance():publish("OnBeaconDropped", {
        player     = player,
        playerUnit = transport,
        coalition  = coalitionId,
        beacon     = self:_beaconPayload(beacon),
        timestamp  = timer.getAbsTime(),
    })

    return beacon
end

--- Remove the closest beacon to transport (manual removal).
-- @param transport Unit   DCS transport unit
-- @param player    string playerName
function CTLDBeaconManager:removeClosestBeacon(transport, player)
    local pos        = transport:getPoint()
    local coalitionId= transport:getCoalition()
    local maxDist    = 500

    local closest, closestDist = nil, math.huge
    for _, beacon in pairs(self._beacons) do
        if beacon.coalitionId == coalitionId then
            local d = ctld.utils.getDistance("CTLDBeaconManager", pos, beacon.position)
            if d < closestDist and d <= maxDist then
                closest, closestDist = beacon, d
            end
        end
    end

    if not closest then
        trigger.action.outText(ctld.tr("No Radio Beacons within 500m."), 10)
        return
    end

    local remaining = closest:batteryRemaining()
    self:_destroyBeaconUnits(closest)
    self:_freeFrequencies(closest)
    self:_removeBeaconFromLayers(closest)
    self._beacons[closest.beaconName] = nil

    trigger.action.outTextForCoalition(coalitionId,
        ctld.tr("Radio beacon removed - %1", closest:freqText()), 20)

    EventDispatcher.getInstance():publish("OnBeaconRemoved", {
        player     = player,
        playerUnit = transport,
        coalition  = coalitionId,
        beacon     = {
            beaconName    = closest.beaconName,
            name          = closest.name,
            position      = closest.position,
            mgrsCoords    = closest:mgrsCoords(),
            frequencies   = { vhf = closest.vhf, uhf = closest.uhf, fm = closest.fm },
            battery       = { remainingTime = remaining, wasInfinite = closest.isFOB },
            distance      = closestDist,
        },
        reason           = "manual",
        frequenciesFreed = { vhf = closest.vhf, uhf = closest.uhf, fm = closest.fm },
        timestamp        = timer.getAbsTime(),
    })
end

--- List active beacons for the coalition of transport to player screen.
-- @param transport Unit
function CTLDBeaconManager:listBeacons(transport)
    local coalitionId = transport:getCoalition()
    local lines = {}
    for _, beacon in pairs(self._beacons) do
        if beacon.coalitionId == coalitionId then
            lines[#lines + 1] = beacon.name .. ": " .. beacon:freqText()
        end
    end
    local msg = #lines > 0
        and (ctld.tr("Radio Beacons:") .. "\n" .. table.concat(lines, "\n"))
        or   ctld.tr("No Active Radio Beacons")
    trigger.action.outTextForGroup(transport:getGroup():getID(), msg, 20)
end

--- Toggle the beacon map layer for a player.
-- @param player    string playerName
-- @param transport Unit
function CTLDBeaconManager:toggleLayer(player, transport)
    if not ctld.gs("beaconLayerEnabled") then return end

    local coalitionId = transport:getCoalition()
    if not self._layerState[player] then
        self._layerState[player] = { enabled = false, marks = {} }
    end

    local state    = self._layerState[player]
    local previous = state.enabled
    state.enabled  = not state.enabled

    local beaconsDisplayed = {}
    if state.enabled then
        for _, beacon in pairs(self._beacons) do
            if beacon.coalitionId == coalitionId then
                local mid = self:_nextMark()
                self:_drawBeaconIcon(beacon, mid)
                state.marks[#state.marks + 1] = { beaconName = beacon.beaconName, markId = mid }
                beaconsDisplayed[#beaconsDisplayed + 1] = {
                    beaconName = beacon.beaconName, name = beacon.name,
                    position   = beacon.position, mgrsCoords = beacon:mgrsCoords(),
                    frequencies= { vhf=beacon.vhf, uhf=beacon.uhf, fm=beacon.fm },
                    markId     = mid,
                }
            end
        end
        trigger.action.outTextForGroup(transport:getGroup():getID(),
            ctld.tr("Beacon layer enabled. %1 beacon(s).", #beaconsDisplayed), 10)
    else
        for _, mark in ipairs(state.marks) do self:_removeMarkId(mark.markId) end
        state.marks = {}
        trigger.action.outTextForGroup(transport:getGroup():getID(),
            ctld.tr("Beacon layer disabled."), 10)
    end

    EventDispatcher.getInstance():publish("OnBeaconLayerToggled", {
        player            = player,
        playerUnit        = transport,
        coalition         = coalitionId,
        previousState     = previous,
        newState          = state.enabled,
        action            = state.enabled and "enabled" or "disabled",
        beaconsDisplayed  = beaconsDisplayed,
        totalBeaconsDisplayed = #beaconsDisplayed,
        timestamp         = timer.getAbsTime(),
    })
end

-- ============================================================
-- Refresh schedule
-- ============================================================

function CTLDBeaconManager:_scheduleRefresh()
    local interval = ctld.gs("beaconRefreshInterval") or 60
    local self_ref = self
    local function refresh()
        self_ref:_refreshAll()
        timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
    end
    timer.scheduleFunction(refresh, nil, timer.getTime() + interval)
end

function CTLDBeaconManager:_refreshAll()
    local refreshed, destroyed = {}, {}

    for beaconName, beacon in pairs(self._beacons) do
        local alive     = beacon:countAliveUnits()
        local batOk     = beacon:isBatteryAlive()
        local keepBeacon= (alive == 3 and batOk)

        if keepBeacon then
            self:_startTransmissions(beacon)
            refreshed[#refreshed + 1] = {
                beaconName          = beacon.beaconName,
                name                = beacon.name,
                position            = beacon.position,
                frequencies         = { vhf=beacon.vhf, uhf=beacon.uhf, fm=beacon.fm },
                battery             = {
                    remainingTime    = beacon:batteryRemaining(),
                    percentRemaining = beacon.isFOB and 1.0 or
                        beacon:batteryRemaining() / ((ctld.gs("deployedBeaconBattery") or 30) * 60),
                    infinite         = beacon.isFOB,
                },
                transmissionsActive = true,
                unitsAlive          = alive,
            }
        else
            local reason = (not batOk) and "battery_depleted" or "unit_destroyed"
            self:_destroyBeaconUnits(beacon)
            self:_freeFrequencies(beacon)
            self:_removeBeaconFromLayers(beacon)
            self._beacons[beaconName] = nil

            destroyed[#destroyed + 1] = beacon

            EventDispatcher.getInstance():publish("OnBeaconDestroyed", {
                beacon = {
                    beaconName    = beacon.beaconName,
                    name          = beacon.name,
                    position      = beacon.position,
                    mgrsCoords    = beacon:mgrsCoords(),
                    frequencies   = { vhf=beacon.vhf, uhf=beacon.uhf, fm=beacon.fm },
                    battery       = {
                        remainingTime = beacon:batteryRemaining(),
                        duration      = (ctld.gs("deployedBeaconBattery") or 30) * 60,
                        infinite      = beacon.isFOB,
                    },
                    unitsAlive    = alive,
                    durationAlive = timer.getAbsTime() - beacon.spawnTime,
                },
                reason           = reason,
                frequenciesFreed = { vhf=beacon.vhf, uhf=beacon.uhf, fm=beacon.fm },
                coalition        = beacon.coalitionId,
                timestamp        = timer.getAbsTime(),
            })
        end
    end

    -- No-op: don't fire event if nothing happened
    if #refreshed == 0 and #destroyed == 0 then return end

    EventDispatcher.getInstance():publish("OnBeaconRefreshed", {
        beacons               = refreshed,
        totalBeaconsRefreshed = #refreshed,
        totalBeaconsDestroyed = #destroyed,
        timestamp             = timer.getAbsTime(),
    })
end

-- ============================================================
-- Draw layer helpers
-- ============================================================

function CTLDBeaconManager:_nextMark()
    return ctld.utils.getNextMarkId()
end

function CTLDBeaconManager:_drawBeaconIcon(beacon, markId)
    local pos    = beacon.position
    local radius = ctld.gs("beaconIconRadius") or 25
    local color  = ctld.gs("beaconIconColor")  or { 1.0, 0.5, 0.0, 1.0 }
    local fill   = { color[1], color[2], color[3], 0.2 }
    local p      = { x = pos.x, y = 0, z = pos.z }

    -- Outer circle
    trigger.action.circleToAll(-1, markId * 10 + 1, p, radius,
        color, fill, 1, true, "Radio Beacon")
    -- Inner circle (solid fill)
    trigger.action.circleToAll(-1, markId * 10 + 2, p, radius * 0.5,
        color, color, 1, true, "")
    -- Text label
    local pText = { x = pos.x, y = 0, z = pos.z + radius + 10 }
    trigger.action.textToAll(-1, markId * 10 + 3, pText,
        { 1.0, 1.0, 1.0, 1.0 }, { 0.0, 0.0, 0.0, 0.7 },
        ctld.gs("beaconTextSize") or 12, true,
        beacon.name .. "\n" .. beacon:mgrsCoords())
end

function CTLDBeaconManager:_removeMarkId(markId)
    for i = 1, 3 do
        trigger.action.removeMark(markId * 10 + i)
    end
end

--- Add a newly-dropped beacon to all active layers of the same coalition.
function CTLDBeaconManager:_addBeaconToLayers(beacon)
    if not ctld.gs("beaconAutoRefreshLayer") then return end
    for _, state in pairs(self._layerState) do
        if state.enabled then
            -- We cannot know the coalition of the layer owner here without extra state.
            -- Conservative: add to all active layers and let the draw API handle visibility (-1=all).
            local mid = self:_nextMark()
            self:_drawBeaconIcon(beacon, mid)
            state.marks[#state.marks + 1] = { beaconName = beacon.beaconName, markId = mid }
        end
    end
end

--- Remove a beacon's marks from all active layers.
function CTLDBeaconManager:_removeBeaconFromLayers(beacon)
    for _, state in pairs(self._layerState) do
        if state.enabled then
            for i = #state.marks, 1, -1 do
                if state.marks[i].beaconName == beacon.beaconName then
                    self:_removeMarkId(state.marks[i].markId)
                    table.remove(state.marks, i)
                end
            end
        end
    end
end

-- ============================================================
-- Internal payload builder
-- ============================================================

function CTLDBeaconManager:_beaconPayload(beacon)
    local battMins = (ctld.gs("deployedBeaconBattery") or 30) * 60
    return {
        beaconName  = beacon.beaconName,
        name        = beacon.name,
        position    = beacon.position,
        mgrsCoords  = beacon:mgrsCoords(),
        frequencies = {
            vhf = beacon.vhf, vhfGroup = beacon.vhfGroupName,
            uhf = beacon.uhf, uhfGroup = beacon.uhfGroupName,
            fm  = beacon.fm,  fmGroup  = beacon.fmGroupName,
        },
        battery = {
            startTime = beacon.spawnTime,
            endTime   = beacon.batteryEndTime == -1 and -1
                        or (beacon.spawnTime + battMins),
            duration  = battMins,
            infinite  = beacon.isFOB,
        },
        isFOB = beacon.isFOB,
    }
end

-- ============================================================
-- Query API
-- ============================================================

--- Return all active beacons for a coalition.
function CTLDBeaconManager:getBeaconsForCoalition(coalitionId)
    local result = {}
    for _, beacon in pairs(self._beacons) do
        if beacon.coalitionId == coalitionId then
            result[#result + 1] = beacon
        end
    end
    return result
end

--- Return CTLDBeacon by beaconName, or nil.
function CTLDBeaconManager:getBeacon(beaconName)
    return self._beacons[beaconName]
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Build the "Radio Beacons" F10 submenu for a player.
-- Requires enabledRadioBeaconDrop = true (configKey gate) AND isTransport.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDBeaconManager:buildMenuSection(playerObj, menu)
    if not playerObj.isTransport then return end

    local root      = ctld.tr("CTLD")
    local beaconSub = ctld.tr("Radio Beacons")
    menu:addSubMenu({ root }, beaconSub, { order = 60 })

    menu:addCommand({ root, beaconSub }, ctld.tr("Drop Beacon"),
        function(arg)
            local transport = Unit.getByName(arg.unitName)
            if transport then CTLDBeaconManager.getInstance():dropBeacon(transport, nil, false) end
        end,
        { unitName = playerObj.unitName })

    menu:addCommand({ root, beaconSub }, ctld.tr("Remove Closest Beacon"),
        function(arg)
            local transport = Unit.getByName(arg.unitName)
            if transport then CTLDBeaconManager.getInstance():removeClosestBeacon(transport, nil) end
        end,
        { unitName = playerObj.unitName })

    menu:addCommand({ root, beaconSub }, ctld.tr("List Beacons"),
        function(arg)
            local transport = Unit.getByName(arg.unitName)
            if transport then CTLDBeaconManager.getInstance():listBeacons(transport) end
        end,
        { unitName = playerObj.unitName })
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Create a radio beacon at a DCS trigger zone (MM DO SCRIPT, no transport required).
-- coalitionStr: "red" | "blue". batteryLife: minutes (nil = config default).
-- name: display name (nil = auto-generated "Beacon #N").
-- @param zoneName    string   DCS trigger zone name
-- @param coalitionStr string  "red" | "blue"
-- @param batteryLife number|nil  battery life in minutes
-- @param name        string|nil  display name
-- @return CTLDBeacon|nil
function CTLDBeaconManager:createAtZone(zoneName, coalitionStr, batteryLife, name)
    local trig = trigger.misc.getZone(zoneName)
    if not trig then
        ctld.utils.log("ERROR", "CTLDBeaconManager:createAtZone — zone not found: %s", tostring(zoneName))
        return nil
    end
    local p2 = { x = trig.point.x, y = trig.point.z }
    local pt = { x = p2.x, y = land.getHeight(p2), z = p2.y }
    local coalitionId = (coalitionStr == "red") and coalition.side.RED or coalition.side.BLUE
    local countryId   = (coalitionId == coalition.side.RED) and country.id.RUSSIA or country.id.USA

    local freqs = self:_assignFrequencies()
    self._beaconCount = self._beaconCount + 1

    if not name or name == "" then name = "Beacon #" .. self._beaconCount end

    local freqText = string.format("%.2f kHz - %.2f / %.2f MHz",
        freqs.vhf / 1000, freqs.uhf / 1000000, freqs.fm / 1000000)

    local vhfGroup = self:_spawnBeaconUnit(pt, countryId, name .. " VHF " .. freqText)
    local uhfGroup = self:_spawnBeaconUnit(pt, countryId, name .. " UHF " .. freqText)
    local fmGroup  = self:_spawnBeaconUnit(pt, countryId, name .. " FM "  .. freqText)

    if not (vhfGroup and uhfGroup and fmGroup) then
        ctld.utils.log("ERROR", "CTLDBeaconManager:createAtZone — spawn failed for '%s'", name)
        return nil
    end

    local batteryMins = batteryLife or ctld.gs("deployedBeaconBattery") or 30
    local batteryEnd  = timer.getTime() + batteryMins * 60

    local beacon = CTLDBeacon:new({
        beaconName     = vhfGroup:getName(),
        name           = name,
        coalitionId    = coalitionId,
        position       = pt,
        vhfGroupName   = vhfGroup:getName(),
        uhfGroupName   = uhfGroup:getName(),
        fmGroupName    = fmGroup:getName(),
        vhf            = freqs.vhf,
        uhf            = freqs.uhf,
        fm             = freqs.fm,
        batteryEndTime = batteryEnd,
        spawnTime      = timer.getAbsTime(),
        isFOB          = false,
    })

    self._beacons[beacon.beaconName] = beacon
    local bname2 = beacon.beaconName
    timer.scheduleFunction(function()
        local b = CTLDBeaconManager.getInstance()._beacons[bname2]
        if b then CTLDBeaconManager.getInstance():_startTransmissions(b) end
    end, nil, timer.getTime() + 1)
    self:_addBeaconToLayers(beacon)

    trigger.action.outTextForCoalition(coalitionId,
        name .. "\n" .. freqText, 20)

    EventDispatcher.getInstance():publish("OnBeaconDropped", {
        player     = "MissionMaker",
        playerUnit = nil,
        coalition  = coalitionId,
        beacon     = self:_beaconPayload(beacon),
        timestamp  = timer.getAbsTime(),
    })

    ctld.utils.log("INFO", "CTLDBeaconManager:createAtZone — '%s' at zone '%s'", name, zoneName)
    return beacon
end

-- End : CTLD_beacon.lua
-- ====================================================================================================
-- Start : CTLD_recon.lua
-- ============================================================
-- CTLD_recon.lua
-- CTLDReconRenderer (static) + CTLDReconManager (singleton)
--
-- SCOPE: RECON is exclusively for displaying ENEMY unit information
-- detected via Line-of-Sight (LOS) from an allied unit.
-- It must NOT be used to display friendly assets (FOBs, zones, beacons…).
-- Those belong in their own manager menus.
--
-- Dependencies : class (lib/class.lua), CTLDUtils (ctld.utils),
--                CTLDConfig (ctld.gs), EventDispatcher
-- DCS API      : coalition.getGroups, Unit.getByName, land.getHeight,
--                land.isVisible (via ctld.utils.getUnitsLOS),
--                trigger.action, timer, missionCommands
--
-- Recon workflow:
--   1. Player enables one or more layers (Layers submenu)
--   2. Player scans → LOS check via ctld.utils.getUnitsLOS()
--      → Draw API icons per layer type on F10 map
--   3. Optional: Auto-Refresh every reconRefreshInterval seconds
--      → tracks moved/new/lost targets
--   4. Hide All Targets → remove marks, stop timer
--
-- Layers (per-player state):
--   infantry, ground_vehicles, air_defense, aircraft, helicopters, ships
--
-- Icons (CTLDReconRenderer):
--   Each target gets a markId; elements at markId*10+1..3
--   infantry   : circle + cross (2 lines)
--   vehicle    : rectangle + diagonal
--   aa         : triangle (3 lines)
--   aircraft   : cross (2 lines) + small circle
--   helicopter : circle + H shape (2 lines)
--   ship       : elongated rectangle + bow lines
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDReconRenderer  (static table — no instance)
-- ============================================================

CTLDReconRenderer = {}

--- Remove all draw elements for a markId (3 sub-elements max).
function CTLDReconRenderer.removeIcon(markId)
    if not markId then return end
    for i = 1, 3 do
        trigger.action.removeMark(markId * 10 + i)
    end
end

--- Infantry icon: circle + horizontal + vertical cross (⊕).
function CTLDReconRenderer.drawInfantryIcon(pos, markId, color)
    local r    = 30 * (ctld.gs("reconIconScale") or 1.0)
    local fill = { color[1], color[2], color[3], 0.3 }
    local p    = { x = pos.x, y = 0, z = pos.z }
    trigger.action.circleToAll(-1, markId * 10 + 1, p, r, color, fill, 1, true, "Infantry")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - r, y = 0, z = pos.z }, { x = pos.x + r, y = 0, z = pos.z },
        color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3,
        { x = pos.x, y = 0, z = pos.z - r }, { x = pos.x, y = 0, z = pos.z + r },
        color, 1, true, "")
end

--- Vehicle icon: rectangle + diagonal (▭╱).
function CTLDReconRenderer.drawVehicleIcon(pos, markId, color)
    local s    = 40 * (ctld.gs("reconIconScale") or 1.0)
    local hs   = s / 2
    local fill = { color[1], color[2], color[3], 0.3 }
    trigger.action.rectToAll(-1, markId * 10 + 1,
        { x = pos.x - hs, y = 0, z = pos.z - hs },
        { x = pos.x + hs, y = 0, z = pos.z + hs },
        color, fill, 1, true, "Vehicle")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - hs, y = 0, z = pos.z - hs },
        { x = pos.x + hs, y = 0, z = pos.z + hs },
        color, 1, true, "")
end

--- AA icon: filled circle (background) + 2 lines forming an apex (△ without base).
-- 3-slot budget: slot1=filled circle, slot2=left side, slot3=right side.
-- The apex shape (^) makes it recognisable as a pointed/AA symbol on the fill background.
function CTLDReconRenderer.drawAAIcon(pos, markId, color)
    local s    = 35 * (ctld.gs("reconIconScale") or 1.0)
    local hs   = s / 2
    local fill = { color[1], color[2], color[3], 0.3 }
    local apex = { x = pos.x,      y = 0, z = pos.z + hs }
    local bl   = { x = pos.x - hs, y = 0, z = pos.z - hs }
    local br   = { x = pos.x + hs, y = 0, z = pos.z - hs }
    trigger.action.circleToAll(-1, markId * 10 + 1,
        { x = pos.x, y = 0, z = pos.z }, hs * 0.9,
        color, fill, 1, true, "AA")
    trigger.action.lineToAll(-1, markId * 10 + 2, bl, apex, color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3, apex, br, color, 1, true, "")
end

--- Aircraft icon: perpendicular cross (2 lines) + small center circle.
function CTLDReconRenderer.drawAircraftIcon(pos, markId, color)
    local s  = 40 * (ctld.gs("reconIconScale") or 1.0)
    local hs = s / 2
    trigger.action.lineToAll(-1, markId * 10 + 1,
        { x = pos.x,      y = 0, z = pos.z + hs },
        { x = pos.x,      y = 0, z = pos.z - hs },
        color, 1, true, "Aircraft")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - hs, y = 0, z = pos.z },
        { x = pos.x + hs, y = 0, z = pos.z },
        color, 1, true, "")
    trigger.action.circleToAll(-1, markId * 10 + 3,
        { x = pos.x, y = 0, z = pos.z }, hs * 0.35,
        color, color, 1, true, "")
end

--- Helicopter icon: circle + H shape (2 vertical bars).
function CTLDReconRenderer.drawHelicopterIcon(pos, markId, color)
    local r    = 25 * (ctld.gs("reconIconScale") or 1.0)
    local fill = { color[1], color[2], color[3], 0.3 }
    trigger.action.circleToAll(-1, markId * 10 + 1,
        { x = pos.x, y = 0, z = pos.z }, r, color, fill, 1, true, "Helicopter")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x - r * 0.4, y = 0, z = pos.z - r * 0.5 },
        { x = pos.x - r * 0.4, y = 0, z = pos.z + r * 0.5 },
        color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3,
        { x = pos.x + r * 0.4, y = 0, z = pos.z - r * 0.5 },
        { x = pos.x + r * 0.4, y = 0, z = pos.z + r * 0.5 },
        color, 1, true, "")
end

--- Ship icon: elongated rectangle + bow arrow (2 lines converging to point).
function CTLDReconRenderer.drawShipIcon(pos, markId, color)
    local sw   = 50 * (ctld.gs("reconIconScale") or 1.0)
    local sh   = 20 * (ctld.gs("reconIconScale") or 1.0)
    local fill = { color[1], color[2], color[3], 0.3 }
    trigger.action.rectToAll(-1, markId * 10 + 1,
        { x = pos.x - sw / 2, y = 0, z = pos.z - sh / 2 },
        { x = pos.x + sw / 2, y = 0, z = pos.z + sh / 2 },
        color, fill, 1, true, "Ship")
    trigger.action.lineToAll(-1, markId * 10 + 2,
        { x = pos.x + sw / 2,           y = 0, z = pos.z - sh / 2 },
        { x = pos.x + sw / 2 + sh / 2,  y = 0, z = pos.z },
        color, 1, true, "")
    trigger.action.lineToAll(-1, markId * 10 + 3,
        { x = pos.x + sw / 2,           y = 0, z = pos.z + sh / 2 },
        { x = pos.x + sw / 2 + sh / 2,  y = 0, z = pos.z },
        color, 1, true, "")
end

--- Dispatch icon creation to the correct draw function.
-- @param target table  { position, layer }
-- @param markId number
function CTLDReconRenderer.createIcon(target, markId)
    local r   = target.layer.iconRenderer
    local pos = target.position
    -- Color follows detected unit's coalition (RED=1, BLUE=2, NEUTRAL=0).
    -- Shape already distinguishes layer type, so color conveys coalition.
    local COALITION_COLORS = {
        [0] = { 0.70, 0.70, 0.70, 1.0 },  -- neutral  → grey
        [1] = { 1.00, 0.15, 0.15, 1.0 },  -- RED      → red
        [2] = { 0.15, 0.40, 1.00, 1.0 },  -- BLUE     → blue
    }
    local col = COALITION_COLORS[target.coalition] or target.layer.color
    if     r == "infantry"   then CTLDReconRenderer.drawInfantryIcon(pos, markId, col)
    elseif r == "vehicle"    then CTLDReconRenderer.drawVehicleIcon(pos, markId, col)
    elseif r == "aa"         then CTLDReconRenderer.drawAAIcon(pos, markId, col)
    elseif r == "aircraft"   then CTLDReconRenderer.drawAircraftIcon(pos, markId, col)
    elseif r == "helicopter" then CTLDReconRenderer.drawHelicopterIcon(pos, markId, col)
    elseif r == "ship"       then CTLDReconRenderer.drawShipIcon(pos, markId, col)
    else
        -- Fallback: plain circle
        local fill = { col[1], col[2], col[3], 0.3 }
        trigger.action.circleToAll(-1, markId * 10 + 1,
            { x = pos.x, y = 0, z = pos.z }, 30, col, fill, 1, true, "")
    end
end


-- ============================================================
-- CTLDReconManager  (singleton)
-- ============================================================

CTLDReconManager = class()
CTLDReconManager._instance = nil

function CTLDReconManager.getInstance()
    if not CTLDReconManager._instance then
        local o = setmetatable({}, CTLDReconManager)
        o:init()
        CTLDReconManager._instance = o
    end
    return CTLDReconManager._instance
end

function CTLDReconManager:init()
    self._activeScans  = {}   -- player -> scan state
    self._playerLayers = {}   -- player -> array of layer copies
    -- Mark IDs are allocated from ctld.utils.getNextMarkId() (app-wide monotonic counter)

    CTLDPlayerManager.getInstance():registerMenuSection({
        key       = "recon",
        manager   = self,
        method    = "buildMenuSection",
        configKey = "reconF10Menu",
        order     = 70,
    })
    ctld.utils.log("INFO", "CTLDReconManager: init complete")
end

-- ============================================================
-- Default layer definitions
-- ============================================================

-- DCS attribute names (case-sensitive, from DCS unit type tables)
-- Layer order matters: _matchLayer returns the FIRST matching layer.
-- More specific attributes must come before broader ones to avoid misclassification:
--   "Air Defence" ⊂ "Vehicles"  → air_defense before ground_vehicles
--   "Helicopters" ⊂ "Planes"    → helicopters before aircraft
CTLDReconManager._defaultLayers = {
    {
        layerId      = "infantry",
        name         = "Infantry",
        enabled      = false,
        color        = { 0.29, 0.56, 0.89, 1.0 },
        filterAttrib = "Infantry",
        iconRenderer = "infantry",
    },
    {
        layerId      = "air_defense",
        name         = "Air Defense (AA)",
        enabled      = false,
        color        = { 0.91, 0.30, 0.24, 1.0 },
        filterAttrib = "Air Defence",  -- more specific than "Vehicles"
        iconRenderer = "aa",
    },
    {
        layerId      = "ground_vehicles",
        name         = "Ground Vehicles",
        enabled      = false,
        color        = { 0.31, 0.78, 0.47, 1.0 },
        filterAttrib = "Vehicles",
        iconRenderer = "vehicle",
    },
    {
        layerId      = "helicopters",
        name         = "Helicopters",
        enabled      = false,
        color        = { 0.90, 0.49, 0.13, 1.0 },
        filterAttrib = "Helicopters",  -- more specific than "Planes"
        iconRenderer = "helicopter",
    },
    {
        layerId      = "aircraft",
        name         = "Aircraft",
        enabled      = false,
        color        = { 0.95, 0.77, 0.06, 1.0 },
        filterAttrib = "Planes",
        iconRenderer = "aircraft",
    },
    {
        layerId      = "ships",
        name         = "Ships",
        enabled      = false,
        color        = { 0.20, 0.60, 0.86, 1.0 },
        filterAttrib = "Ships",
        iconRenderer = "ship",
    },
}

-- ============================================================
-- Layer management (per-player)
-- ============================================================

-- Returns or lazily initializes the per-player layer array.
function CTLDReconManager:_getPlayerLayers(player)
    if not self._playerLayers[player] then
        local layers = {}
        for _, def in ipairs(CTLDReconManager._defaultLayers) do
            layers[#layers + 1] = {
                layerId      = def.layerId,
                name         = def.name,
                enabled      = def.enabled,
                color        = def.color,
                filterAttrib = def.filterAttrib,
                iconRenderer = def.iconRenderer,
            }
        end
        self._playerLayers[player] = layers
    end
    return self._playerLayers[player]
end

-- Returns the layer object for layerId in player's list, or nil.
function CTLDReconManager:_findLayer(player, layerId)
    for _, layer in ipairs(self:_getPlayerLayers(player)) do
        if layer.layerId == layerId then return layer end
    end
    return nil
end

-- Returns list of enabled layers for player.
function CTLDReconManager:_enabledLayers(player)
    local result = {}
    for _, layer in ipairs(self:_getPlayerLayers(player)) do
        if layer.enabled then result[#result + 1] = layer end
    end
    return result
end

-- ============================================================
-- LOS scan helpers
-- ============================================================

-- Returns enemy unit name list for all relevant categories.
function CTLDReconManager:_getEnemyUnitNames(coalitionId)
    local enemySide = coalitionId == coalition.side.BLUE
                      and coalition.side.RED
                      or  coalition.side.BLUE
    return ctld.utils.getUnitsListNamesByCategory(
        "CTLDReconManager:_getEnemyUnitNames",
        enemySide,
        {
            Group.Category.GROUND,
            Group.Category.AIRPLANE,
            Group.Category.HELICOPTER,
            Group.Category.SHIP,
        })
end

--- Find the highest-priority layer matching a unit's attributes.
--- Uses the FULL ordered layer list so that priority (air_defense > ground_vehicles,
--- helicopters > aircraft) is always respected regardless of which layers are enabled.
--- Returns the layer only if it is currently enabled; returns nil otherwise.
--- This prevents a unit from "falling through" to a lower-priority layer when its
--- best-match layer is disabled (e.g. Mi-8MT must not show as Aircraft when
--- Helicopters layer is OFF; ZU-23 must not show as Vehicle when AA layer is OFF).
function CTLDReconManager:_matchLayer(unit, allLayers)
    for _, layer in ipairs(allLayers) do
        local ok, has = pcall(function() return unit:hasAttribute(layer.filterAttrib) end)
        if ok and has then
            return layer.enabled and layer or nil
        end
    end
    return nil
end

-- Allocate next unique mark ID (delegates to shared app-wide counter).
function CTLDReconManager:_nextMark()
    return ctld.utils.getNextMarkId()
end

-- Core LOS scan. Returns array of target records.
-- altoffset = 180 matches source/CTLD_recon.lua ctld.utils.getUnitsLOS call.
function CTLDReconManager:_scanLOS(playerUnit, enabledLayers, searchRadius)
    local enemyNames = self:_getEnemyUnitNames(playerUnit:getCoalition())
    if #enemyNames == 0 then return {} end

    local los = ctld.utils.getUnitsLOS(
        "CTLDReconManager:_scanLOS",
        { playerUnit:getName() },
        180,
        enemyNames,
        180,
        searchRadius)

    local targets   = {}
    local playerPos = playerUnit:getPoint()

    if los then
        for _, entry in ipairs(los) do
            if entry.vis then
                for _, unit in ipairs(entry.vis) do
                    local layer = self:_matchLayer(unit, enabledLayers)
                    if layer then
                        local uPos = unit:getPoint()
                        targets[#targets + 1] = {
                            unit      = unit,
                            unitName  = unit:getName(),
                            unitType  = unit:getTypeName(),
                            coalition = unit:getCoalition(),
                            position  = uPos,
                            distance  = ctld.utils.getDistance(
                                "CTLDReconManager:_scanLOS", playerPos, uPos),
                            layer     = layer,
                            los       = true,
                        }
                    end
                end
            end
        end
    end

    return targets
end

-- Remove all Draw API icons from a scan's target list.
function CTLDReconManager:_removeAllMarks(scan)
    for _, tgt in ipairs(scan.targets) do
        CTLDReconRenderer.removeIcon(tgt.markId)
    end
end

-- ============================================================
-- Public actions
-- ============================================================

--- Scan and start RECON with auto-refresh (menu F10 "RECON [Start]").
-- Also called internally on layer toggle while RECON is active (re-scan with updated layers).
-- @param playerUnit DCS Unit
-- @param player     string  playerName
function CTLDReconManager:scan(playerUnit, player)
    if not ctld.gs("reconEnabled") then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("RECON is disabled (set reconEnabled=true in config)."), 10)
        return
    end

    -- Altitude check (AGL)
    local pos    = playerUnit:getPoint()
    local ground = land.getHeight({ x = pos.x, y = pos.z })
    local agl    = pos.y - ground
    local minAlt = ctld.gs("reconMinAltitude") or 50
    if agl < minAlt then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("Altitude too low for recon scan (min %1 m)", minAlt), 10)
        return
    end

    -- Cancel previous auto-refresh timer and remove marks BEFORE any early-return check.
    -- This ensures that toggling the last active layer OFF immediately clears the map,
    -- rather than waiting for the next _doRefresh() tick.
    local prevScan = self._activeScans[player]
    if prevScan then
        if prevScan.refreshTimer then timer.removeFunction(prevScan.refreshTimer) end
        self:_removeAllMarks(prevScan)
        self._activeScans[player] = nil
    end

    local enabledLayers = self:_enabledLayers(player)
    if #enabledLayers == 0 then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("No recon layers enabled. Activate layers first."), 10)
        self:_rebuildReconBranch(player, playerUnit)
        return
    end

    local radius  = ctld.gs("reconSearchRadius") or 5000
    -- Pass ALL layers (not just enabled) so _matchLayer can enforce priority correctly.
    local targets = self:_scanLOS(playerUnit, self:_getPlayerLayers(player), radius)

    -- Create icons + count per layer
    local targetsByLayer = {}
    for _, tgt in ipairs(targets) do
        local mid = self:_nextMark()
        tgt.markId = mid
        CTLDReconRenderer.createIcon(tgt, mid)
        local lid = tgt.layer.layerId
        targetsByLayer[lid] = (targetsByLayer[lid] or 0) + 1
    end

    self._activeScans[player] = {
        playerUnit   = playerUnit,
        coalition    = playerUnit:getCoalition(),
        targets      = targets,
        layers       = enabledLayers,
        autoRefresh  = false,
        refreshTimer = nil,
    }

    -- Build activeLayers payload
    local activeLayersPayload = {}
    for _, l in ipairs(enabledLayers) do
        activeLayersPayload[#activeLayersPayload + 1] = {
            layerId = l.layerId, name = l.name, enabled = true, color = l.color
        }
    end

    EventDispatcher.getInstance():publish("OnReconScan", {
        player               = player,
        playerUnit           = playerUnit,
        coalition            = playerUnit:getCoalition(),
        position             = pos,
        altitude             = agl,
        searchRadius         = radius,
        activeLayers         = activeLayersPayload,
        targets              = targets,
        targetsByLayer       = targetsByLayer,
        totalTargetsDetected = #targets,
        totalMarksCreated    = #targets,
        autoRefresh          = true,
        timestamp            = timer.getAbsTime(),
    })

    -- Auto-refresh always enabled when RECON starts.
    -- Pass _fromScan=true so enableAutoRefresh skips its own rebuild
    -- (scan() already calls _rebuildReconBranch below).
    self:enableAutoRefresh(playerUnit, player, true)

    -- Single menu rebuild after scan (covers both start and layer-toggle re-scan).
    self:_rebuildReconBranch(player, playerUnit)
end

--- Stop RECON for player (menu F10 "RECON [Stop]").
-- Stops auto-refresh timer, removes all marks, sets RECON to idle state.
-- Layer enabled/disabled states are preserved for the next Start.
-- @param playerUnit DCS Unit
-- @param player     string
function CTLDReconManager:stopScan(playerUnit, player)
    local scan = self._activeScans[player]
    if not scan then return end

    local refreshStopped = scan.autoRefresh
    if scan.refreshTimer then
        timer.removeFunction(scan.refreshTimer)
        scan.refreshTimer = nil
    end

    local marksRemoved = {}
    for _, tgt in ipairs(scan.targets) do
        CTLDReconRenderer.removeIcon(tgt.markId)
        marksRemoved[#marksRemoved + 1] = {
            markId    = tgt.markId,
            unitType  = tgt.unitType,
            layer     = { layerId = tgt.layer.layerId, name = tgt.layer.name },
            position  = tgt.position,
            wasActive = true,
        }
    end
    self._activeScans[player] = nil

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Recon stopped. %1 targets hidden.", #marksRemoved), 10)

    EventDispatcher.getInstance():publish("OnReconHideTargets", {
        player            = player,
        playerUnit        = playerUnit,
        coalition         = playerUnit:getCoalition(),
        marksRemoved      = marksRemoved,
        totalMarksRemoved = #marksRemoved,
        refreshStopped    = refreshStopped,
        timestamp         = timer.getAbsTime(),
    })

    -- Rebuild menu: RECON [Start] + all layer labels switch to (X) suffix.
    self:_rebuildReconBranch(player, playerUnit)
end

--- Enable auto-refresh (menu F10 "Auto-Refresh: [OFF]" → ON).
-- @param playerUnit DCS Unit
-- @param player     string
-- @param _fromScan  boolean  internal flag — skip menu rebuild when called from scan()
function CTLDReconManager:enableAutoRefresh(playerUnit, player, _fromScan)
    local scan = self._activeScans[player]
    if not scan then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
            ctld.tr("No active recon scan. Use 'Scan Area' first."), 10)
        return
    end
    if scan.autoRefresh then return end

    local interval = ctld.gs("reconRefreshInterval") or 10
    scan.autoRefresh = true

    local self_ref = self
    local pName    = player
    local uName    = playerUnit:getName()
    scan.refreshTimer = timer.scheduleFunction(function(_, t)
        self_ref:_doRefresh(pName, uName, t)
    end, nil, timer.getTime() + interval)

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Auto-refresh enabled. Targets update every %1 s.", interval), 10)

    EventDispatcher.getInstance():publish("OnReconAutoRefreshEnabled", {
        player          = player,
        playerUnit      = playerUnit,
        coalition       = playerUnit:getCoalition(),
        previousState   = false,
        newState        = true,
        targetsCount    = #scan.targets,
        refreshInterval = interval,
        timestamp       = timer.getAbsTime(),
    })

    if not _fromScan then
        self:_rebuildReconBranch(player, playerUnit)
    end
end

--- Disable auto-refresh (menu F10 "Auto-Refresh: [ON]" → OFF).
-- @param playerUnit DCS Unit
-- @param player     string
function CTLDReconManager:disableAutoRefresh(playerUnit, player)
    local scan = self._activeScans[player]
    if not scan or not scan.autoRefresh then return end

    local interval = ctld.gs("reconRefreshInterval") or 10
    scan.autoRefresh = false
    if scan.refreshTimer then
        timer.removeFunction(scan.refreshTimer)
        scan.refreshTimer = nil
    end

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Auto-refresh disabled. Current targets frozen on map."), 10)

    EventDispatcher.getInstance():publish("OnReconAutoRefreshDisabled", {
        player          = player,
        playerUnit      = playerUnit,
        coalition       = playerUnit:getCoalition(),
        previousState   = true,
        newState        = false,
        targetsCount    = #scan.targets,
        refreshInterval = interval,
        timestamp       = timer.getAbsTime(),
    })

    self:_rebuildReconBranch(player, playerUnit)
end

--- Toggle a recon layer ON/OFF for a player.
-- If a scan is active, re-scans immediately with updated layer set.
-- @param player     string
-- @param playerUnit DCS Unit
-- @param layerId    string
function CTLDReconManager:toggleLayer(player, playerUnit, layerId)
    local layer = self:_findLayer(player, layerId)
    if not layer then
        ctld.utils.log("WARN", "CTLDReconManager:toggleLayer: unknown layerId '%s'", tostring(layerId))
        return
    end

    layer.enabled = not layer.enabled
    local state   = layer.enabled and "ON" or "OFF"

    trigger.action.outTextForGroup(playerUnit:getGroup():getID(),
        ctld.tr("Recon layer '%1': %2", layer.name, state), 10)

    -- Immediate re-scan if scan is active (applies new layer state).
    -- scan() handles its own menu rebuild so we skip the extra call below.
    local didScan = false
    if self._activeScans[player] then
        self:scan(playerUnit, player)
        didScan = true
    end

    EventDispatcher.getInstance():publish("OnReconLayerToggled", {
        layerId   = layer.layerId,
        layerName = layer.name,
        visible   = layer.enabled,
        coalition = playerUnit:getCoalition(),
        player    = player,
        timestamp = timer.getAbsTime(),
    })

    -- Only rebuild menu if scan() didn't already do it.
    if not didScan then
        self:_rebuildReconBranch(player, playerUnit)
    end
end

-- ============================================================
-- Auto-refresh timer callback
-- ============================================================

--- Called by timer.scheduleFunction every reconRefreshInterval seconds.
-- @param playerName string
-- @param unitName   string  (DCS unit name, for re-lookup after tick)
function CTLDReconManager:_doRefresh(playerName, unitName, _t)
    local scan = self._activeScans[playerName]
    if not scan or not scan.autoRefresh then return end

    local playerUnit = Unit.getByName(unitName)
    if not playerUnit or not playerUnit:isExist() then
        -- Player gone — cleanup silently
        self:_removeAllMarks(scan)
        self._activeScans[playerName] = nil
        return
    end

    local radius         = ctld.gs("reconSearchRadius") or 5000
    -- Use full layer list so _matchLayer enforces priority on disabled layers.
    local currentTargets = self:_scanLOS(playerUnit, self:_getPlayerLayers(playerName), radius)

    -- Index previous targets by unitName
    local prevIndex = {}
    for _, tgt in ipairs(scan.targets) do
        prevIndex[tgt.unitName] = tgt
    end

    local newTargets   = {}
    local movedTargets = {}
    local lostTargets  = {}

    for _, tgt in ipairs(currentTargets) do
        local prev = prevIndex[tgt.unitName]
        if not prev then
            -- New target
            local mid = self:_nextMark()
            tgt.markId = mid
            CTLDReconRenderer.createIcon(tgt, mid)
            tgt.status = "new"
            newTargets[#newTargets + 1] = tgt
        else
            local d = ctld.utils.getDistance(
                "CTLDReconManager:_doRefresh", prev.position, tgt.position)
            if d > 5 then
                -- Moved: remove old icon (invalidates its DCS ID permanently),
                -- allocate a fresh ID for the new icon (DCS IDs must never be reused).
                CTLDReconRenderer.removeIcon(prev.markId)
                local newMid = self:_nextMark()
                tgt.markId = newMid
                CTLDReconRenderer.createIcon(tgt, newMid)
                tgt.status        = "moved"
                tgt.hasMoved      = true
                tgt.distanceMoved = d
                movedTargets[#movedTargets + 1] = {
                    unit          = tgt.unit,
                    unitName      = tgt.unitName,
                    unitType      = tgt.unitType,
                    positionOld   = prev.position,
                    positionNew   = tgt.position,
                    distanceMoved = d,
                    markId        = newMid,
                }
            else
                -- Carry forward the existing markId so stopScan/removeAllMarks can remove it.
                tgt.markId = prev.markId
                tgt.status = "existing"
            end
            prevIndex[tgt.unitName] = nil
        end
    end

    -- Remaining in prevIndex = lost (out of LOS or dead)
    for uName, prevTgt in pairs(prevIndex) do
        local reason = "out_of_los"
        if not prevTgt.unit:isExist() then reason = "dead" end
        CTLDReconRenderer.removeIcon(prevTgt.markId)
        lostTargets[#lostTargets + 1] = {
            unit     = prevTgt.unit,
            unitName = uName,
            unitType = prevTgt.unitType,
            reason   = reason,
            markId   = prevTgt.markId,
        }
    end

    -- Update scan state
    scan.targets     = currentTargets
    scan.playerUnit  = playerUnit

    -- Re-schedule next refresh
    local interval = ctld.gs("reconRefreshInterval") or 10
    local self_ref = self
    local pName    = playerName
    local uNameRef = unitName
    scan.refreshTimer = timer.scheduleFunction(function(_, t)
        self_ref:_doRefresh(pName, uNameRef, t)
    end, nil, timer.getTime() + interval)

    EventDispatcher.getInstance():publish("OnReconScanRefresh", {
        player                = playerName,
        playerUnit            = playerUnit,
        coalition             = playerUnit:getCoalition(),
        position              = playerUnit:getPoint(),
        altitude              = playerUnit:getPoint().y,
        activeLayers          = scan.layers,
        targets               = currentTargets,
        newTargets            = newTargets,
        movedTargets          = movedTargets,
        lostTargets           = lostTargets,
        totalTargetsCurrent   = #currentTargets,
        totalTargetsNew       = #newTargets,
        totalTargetsMoved     = #movedTargets,
        totalTargetsLost      = #lostTargets,
        marksCreated          = #newTargets,
        marksUpdated          = #movedTargets,
        marksRemoved          = #lostTargets,
        timestamp             = timer.getAbsTime(),
    })
end

-- ============================================================
-- Query API
-- ============================================================

--- Return current scan state for player, or nil.
-- @param player string
-- @return table|nil  { playerUnit, coalition, targets, layers, autoRefresh, refreshTimer }
function CTLDReconManager:getActiveScan(player)
    return self._activeScans[player]
end

--- Return per-player layers array.
-- @param player string
-- @return table  array of layer objects
function CTLDReconManager:getPlayerLayers(player)
    return self:_getPlayerLayers(player)
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Internal: add all RECON commands to an already-existing RECON submenu node.
-- "RECON [Start/Stop]": single toggle entry for RECON active state.
-- Layer labels: [activate/deactivate] when RECON active, [activate/deactivate (X)] when idle.
-- @param menu     ctld.Menu
-- @param unitName string  used as DCS unit key and player-state key
function CTLDReconManager:_addReconCommands(menu, unitName)
    local root      = ctld.tr("CTLD")
    local reconSub  = ctld.tr("RECON")
    local isActive  = self._activeScans[unitName] ~= nil

    -- RECON [Start] / RECON [Stop] — single start/stop toggle.
    local reconLabel = isActive and ctld.tr("RECON [Stop]") or ctld.tr("RECON [Start]")
    menu:addCommand({ root, reconSub }, reconLabel,
        function(arg)
            local unit = Unit.getByName(arg.unitName)
            if not unit then return end
            local rmgr = CTLDReconManager.getInstance()
            if rmgr._activeScans[arg.unitName] then
                rmgr:stopScan(unit, arg.unitName)
            else
                rmgr:scan(unit, arg.unitName)
            end
        end,
        { unitName = unitName })

    -- Per-layer toggles.
    -- RECON active  : "Layer [activate]"      / "Layer [deactivate]"
    -- RECON idle    : "Layer [activate (X)]"  / "Layer [deactivate (X)]"
    -- (X) signals the toggle prepares for next Start but has no immediate map effect.
    local layers = self:_getPlayerLayers(unitName)
    for _, layer in ipairs(layers) do
        local actionBase = layer.enabled and ctld.tr("deactivate") or ctld.tr("activate")
        local action     = isActive and actionBase or (actionBase .. " (X)")
        local label      = string.format("%s [%s]", layer.name, action)
        menu:addCommand({ root, reconSub }, label,
            function(arg)
                local unit = Unit.getByName(arg.unitName)
                if unit then
                    CTLDReconManager.getInstance():toggleLayer(arg.unitName, unit, arg.layerId)
                end
            end,
            { unitName = unitName, layerId = layer.layerId })
    end
end

--- Internal: clear the RECON branch commands and re-add them with current state labels.
-- Call after any state change: scan start/stop, layer toggle.
-- @param unitName  string  player/unit key
-- @param playerUnit DCS Unit object
function CTLDReconManager:_rebuildReconBranch(unitName, playerUnit)
    local menu = ctld.MenuManager:getInstance():getMenuByUnitName(unitName)
    if not menu then return end
    local root     = ctld.tr("CTLD")
    local reconSub = ctld.tr("RECON")
    menu:clearBranch({ root, reconSub })
    self:_addReconCommands(menu, unitName)
    menu:refresh()
end

--- Build the "RECON" F10 submenu for a player.
-- Requires reconF10Menu = true (configKey gate).
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDReconManager:buildMenuSection(playerObj, menu)
    local root     = ctld.tr("CTLD")
    local reconSub = ctld.tr("RECON")
    menu:addSubMenu({ root }, reconSub, { order = 70 })
    self:_addReconCommands(menu, playerObj.unitName)
end

-- End : CTLD_recon.lua
-- ====================================================================================================
-- Start : CTLD_jtac.lua
-- ============================================================
-- CTLD_jtac.lua
-- CTLDJTAC entity + CTLDJTACDetector helpers + CTLDJTACManager singleton
--
-- Dependencies : CTLDConfig (ctld.gs), CTLDUtils, EventDispatcher
-- DCS API      : coalition.addGroup, Group, Unit, Spot, land, world,
--                atmosphere, trigger.action, timer
--
-- JTAC is a feature, not a unit type. It applies to:
--   - ground infantry  (loadable group with jtac=N soldier)
--   - ground vehicle   (crate descriptor with jtac=true)
--   - flying AI drone  (crate descriptor with jtac=true, isFlying=true)
--
-- JTAC lifecycle states:
--   idle       : spawned, no target acquired
--   lasing     : actively lasing a target
--   orbiting   : flying JTAC orbiting a target (implies lasing)
--   in_transit : ground JTAC embarked in a transport
--   dead       : unit destroyed
--
-- Detection: crate descriptor.jtac == true   (no separate jtacUnitTypes table)
-- Laser pool: sequential 1111–1688 (assigned on spawn, freed on death)
-- Timings   : JTAC_laseIntervalSeconds / JTAC_searchIntervalSeconds (config)
-- DCS bug   : coalition.addGroup leaves group empty for ~1s →
--             first _autoLaseLoop is delayed +1s (preserved from source)
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- CTLDJTAC  (entity)
-- ============================================================

CTLDJTAC = class()

CTLDJTAC.STATE = {
    IDLE       = "idle",
    LASING     = "lasing",
    ORBITING   = "orbiting",
    IN_TRANSIT = "in_transit",
    DEAD       = "dead",
}

-- Reasons passed to stopLase() and _stopLaseAndPublish()
CTLDJTAC.STOP_REASON = {
    TARGET_LOST   = "target_lost",
    TARGET_DESTROYED = "target_destroyed",
    STANDBY_MODE  = "standby_mode",
    IN_TRANSIT    = "jtac_in_transit",
    DEAD          = "jtac_dead",
}

-- Lock mode values (mirrors JTAC_lock config)
CTLDJTAC.LOCK_MODE = {
    ALL     = "all",
    VEHICLE = "vehicle",
    TROOP   = "troop",
}

--- Constructor.
-- @param data table:
--   groupName    (string)   DCS group name
--   laserCode    (number)   assigned laser code (1111-1688)
--   isFlying     (boolean)  drone/aircraft vs ground
--   isInfantry   (boolean)  infantry vs vehicle (ground only)
--   coalitionId  (number)   coalition.side.*
--   smokeEnabled (boolean)  auto-smoke on target
--   smokeColor   (number)   trigger.smokeColor.*
--   lockMode     (string)   "all" | "vehicle" | "troop"
function CTLDJTAC:init(data)
    self.groupName    = data.groupName
    -- unitName: set for infantry JTACs within a composite troop group (unit-keyed registry).
    -- nil for drone/vehicle JTACs (group-keyed registry). Drives Unit.getByName() path in _autoLaseLoop.
    self.unitName     = data.unitName    or nil
    self.laserCode    = data.laserCode
    self.isFlying     = data.isFlying    or false
    self.isInfantry   = data.isInfantry  or false
    self.coalitionId  = data.coalitionId
    self.smokeEnabled = data.smokeEnabled or false
    self.smokeColor   = data.smokeColor  or trigger.smokeColor.Red
    self.lockMode     = data.lockMode    or "all"
    self.state        = CTLDJTAC.STATE.IDLE

    self.radio = CTLDJTACDetector.calculateFMRadio(data.groupName, data.laserCode)

    self.currentTarget  = nil   -- { unitName, unitType, unitId, position, laseStartTime }
    self.laserSpot      = nil
    self.irSpot         = nil

    -- Flying JTACs only: orbit params from crate specificParams + spawn position
    self.orbitParams          = data.orbitParams or nil  -- { speed, alti, orbitRadiusNoLase, orbitRadiusOnLase }
    self.initialPosition      = nil   -- captured at T+2s after spawn
    self.initialRoute         = nil   -- waypoint table built by _setOrbitRoute; replayed on target loss
    self.initialRouteAssigned = false -- true once _setOrbitRoute has been called; prevents re-assignment on every tick
    self.orbitStartTime       = nil
    -- onTargetOrbit: true only while drone executes a Circle pushTask on top of its initial Mission route
    -- (i.e. state==ORBITING, = "orbitingToFollowLasedTarget"). false = drone on initial waypoint loop (IDLE).
    self.onTargetOrbit        = false
    self._routeRefreshId      = nil

    -- Target selection (1 = auto mode, string = manually selected unitName)
    self.selectedTarget = 1

    -- Per-JTAC special options (toggled via F10 menu)
    self.standbyMode         = false
    self.laseSpotCorrections = false
end

--- Begin lasing a new target.
-- @param target    table  { dcsUnit, unitName, unitType, unitId, position }
-- @param laserSpot DCS Spot object (laser)
-- @param irSpot    DCS Spot object (IR)
function CTLDJTAC:startLase(target, laserSpot, irSpot)
    self.currentTarget = {
        unitName      = target.unitName,
        unitType      = target.unitType,
        unitId        = target.unitId,
        position      = target.position,
        laseStartTime = timer.getAbsTime(),
    }
    self.laserSpot = laserSpot
    self.irSpot    = irSpot
    -- Keep ORBITING state if already orbiting; otherwise go LASING
    if self.state ~= CTLDJTAC.STATE.ORBITING then
        self.state = CTLDJTAC.STATE.LASING
    end
end

--- Stop lasing and destroy DCS spots.
-- @param reason string  CTLDJTAC.STOP_REASON.*
function CTLDJTAC:stopLase(reason)
    if self.laserSpot then self.laserSpot:destroy(); self.laserSpot = nil end
    if self.irSpot    then self.irSpot:destroy();    self.irSpot    = nil end
    self.currentTarget = nil
    -- Keep ORBITING state intact — _orbitLoop handles the ORBITING→IDLE transition
    if self.state == CTLDJTAC.STATE.LASING then
        self.state = CTLDJTAC.STATE.IDLE
    end
end

--- Update laser/IR spot position (moving target).
-- @param targetPos table {x, y, z}
function CTLDJTAC:updateLaseSpot(targetPos)
    if self.laserSpot then self.laserSpot:setPoint(targetPos) end
    if self.irSpot    then self.irSpot:setPoint(targetPos)    end
    if self.currentTarget then
        self.currentTarget.position = targetPos
    end
end

--- Flying JTAC: begin orbiting.
-- @param t number  timer.getTime() at orbit start
function CTLDJTAC:startOrbit(t)
    self.state        = CTLDJTAC.STATE.ORBITING
    self.orbitStartTime = t or timer.getTime()
end

--- Flying JTAC: stop orbiting, return to IDLE.
function CTLDJTAC:stopOrbit()
    self.state          = CTLDJTAC.STATE.IDLE
    self.orbitStartTime = nil
end

--- Ground JTAC: mark as embarked in a transport.
function CTLDJTAC:setInTransit()
    self:stopLase(CTLDJTAC.STOP_REASON.IN_TRANSIT)
    self.state = CTLDJTAC.STATE.IN_TRANSIT
end

--- Mark JTAC as dead and clean up spots.
function CTLDJTAC:kill()
    self:stopLase(CTLDJTAC.STOP_REASON.DEAD)
    self.state = CTLDJTAC.STATE.DEAD
end

--- Destroy DCS group + spots.
function CTLDJTAC:destroy()
    self:stopLase(CTLDJTAC.STOP_REASON.DEAD)
    local g = Group.getByName(self.groupName)
    if g then g:destroy() end
end


-- ============================================================
-- CTLDJTACDetector  (static helpers — no instance)
-- ============================================================

CTLDJTACDetector = {}

--- Compute FM radio frequency from laser code.
-- Formula from CTLD_jtac.lua source (ctld.JTACAutoLase, lines 72-74):
--   freq = 30 + floor((code-1000)/100) + ((code-1000) mod 100) * 0.05
-- Range: laser 1111–1688 → FM ~31.5–40.4 MHz
-- @param groupName string
-- @param laserCode number
-- @return table { name, freq (string MHz), mod } or nil
function CTLDJTACDetector.calculateFMRadio(groupName, laserCode)
    local code = tonumber(laserCode)
    if not code or code < 1111 or code > 1688 then return nil end
    local laserB  = math.floor((code - 1000) / 100)
    local laserCD = code - 1000 - laserB * 100
    local freq    = tostring(30 + laserB + laserCD * 0.05)
    return { name = groupName, freq = freq, mod = "fm" }
end

--- Find all visible enemies for a JTAC unit, sorted by priority then distance.
-- Uses world.searchObjects (sphere) + land.isVisible (LOS, +2m Y offset).
-- Priority tiers: hpriority(1) > priority(2) > Air Defence(3) > standard(4).
-- Returns a sorted list so callers can iterate for target deconfliction.
-- API: world.searchObjects — verified Hoggit 2026-04-01
-- API: land.isVisible      — verified CTLD_jtac.lua source
-- @param jtacUnit    DCS Unit object
-- @param lockMode    string  "all" | "vehicle" | "troop"
-- @param maxDistance number  metres
-- @return table  sorted array of { dcsUnit, unitName, unitType, unitId, position, priority, distance }
function CTLDJTACDetector.findAllVisibleEnemies(jtacUnit, lockMode, maxDistance)
    if not jtacUnit or not jtacUnit:isExist() then return {} end

    local jtacPos  = jtacUnit:getPoint()
    local jtacCoal = jtacUnit:getCoalition()
    local offsetA  = { x = jtacPos.x, y = jtacPos.y + 2, z = jtacPos.z }
    local results  = {}

    world.searchObjects(
        Object.Category.UNIT,
        { id = world.VolumeType.SPHERE, params = { point = jtacPos, radius = maxDistance } },
        function(unit, _)
            if unit:getCoalition() == jtacCoal then return true end
            if not unit:isExist() or unit:getLife() <= 1 then return true end

            local attrs      = unit:getDesc().attributes or {}
            local isVehicle  = attrs["Vehicles"] == true or attrs["Armored vehicles"] == true
            local isInfantry = attrs["Infantry"] == true
            if lockMode == CTLDJTAC.LOCK_MODE.VEHICLE and not isVehicle  then return true end
            if lockMode == CTLDJTAC.LOCK_MODE.TROOP   and not isInfantry then return true end

            -- LOS check (+2m height offset — avoids terrain/hull occlusion at ground level)
            local unitPos = unit:getPoint()
            local offsetB = { x = unitPos.x, y = unitPos.y + 2, z = unitPos.z }
            if not land.isVisible(offsetA, offsetB) then return true end

            local dist     = ctld.utils.getDistance("CTLDJTACDetector.findAllVisibleEnemies", jtacPos, unitPos)
            local name     = unit:getName()
            local typeName = unit:getTypeName()
            local priority
            if string.find(name, "hpriority") or string.find(typeName, "hpriority") then
                priority = 1
            elseif string.find(name, "priority") or string.find(typeName, "priority") then
                priority = 2
            elseif attrs["Air Defence"] == true then
                priority = 3
            else
                priority = 4
            end

            results[#results + 1] = {
                dcsUnit  = unit,
                unitName = name,
                unitType = typeName,
                unitId   = unit:getID(),
                position = unitPos,
                priority = priority,
                distance = dist,
            }
            return true
        end,
        nil
    )

    table.sort(results, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        return a.distance < b.distance
    end)

    return results
end

--- Find the nearest visible enemy for a JTAC unit.
-- Thin wrapper around findAllVisibleEnemies — returns only the first (best) candidate.
-- @param jtacUnit    DCS Unit object
-- @param lockMode    string  "all" | "vehicle" | "troop"
-- @param maxDistance number  metres
-- @return table or nil  { dcsUnit, unitName, unitType, unitId, position, priority, distance }
function CTLDJTACDetector.findNearestVisibleEnemy(jtacUnit, lockMode, maxDistance)
    return CTLDJTACDetector.findAllVisibleEnemies(jtacUnit, lockMode, maxDistance)[1]
end

--- Line-of-sight check (convenience wrapper).
-- API: land.isVisible — verified CTLD_jtac.lua source
-- @param posA table {x,y,z}
-- @param posB table {x,y,z}
-- @return boolean
function CTLDJTACDetector.checkLOS(posA, posB)
    return land.isVisible(posA, posB)
end

--- Compute predictive laser-spot correction for a moving target.
-- Compensates target velocity (+1.0s anticipation) and wind (-1.05s).
-- API: atmosphere.getWind — verified CTLD_jtac.lua source
-- @param targetPos      table {x,y,z}
-- @param targetVelocity table {x,y,z}  Unit:getVelocity()
-- @param wind           table {x,y,z}  atmosphere.getWind(pos)
-- @return table {x,y,z}
function CTLDJTACDetector.calculateCorrectedSpot(targetPos, targetVelocity, wind)
    return {
        x = targetPos.x + targetVelocity.x * 1.0 - wind.x * 1.05,
        y = targetPos.y,
        z = targetPos.z + targetVelocity.z * 1.0 - wind.z * 1.05,
    }
end


-- ============================================================
-- CTLDJTACMessage  (static — message builder)
-- ============================================================

CTLDJTACMessage = {}

--- Build short + full notification strings from a structured context.
-- All i18n calls are co-located here. No message logic elsewhere.
--
-- Supported events:
--   "new_target"        JTAC locks a new target
--   "target_reacquired" manually-selected target back in LOS
--   "target_lost"       target alive but LOS broken
--   "target_destroyed"  target confirmed dead
--   "kia"               JTAC unit destroyed
--   "no_targets"        search loop found nothing (optional use)
--
-- @param ctx table:
--   event       (string)       one of the events above
--   jtacName    (string)       JTAC group name
--   targetType  (string|nil)   DCS typeName of target
--   laserCode   (number|nil)   assigned laser code
--   positionStr (string|nil)   pre-formatted MGRS/DMS string
--   wasSelected (boolean)      target was manually selected by player
--   standby     (boolean)      standby mode active (laser off)
--
-- @return table { short (string), full (string) }
--   short : concise, suitable for SRS read-out (no coords)
--   full  : detailed, displayed on screen (includes code + position)
function CTLDJTACMessage.build(ctx)
    local name  = ctx.jtacName   or "JTAC"
    local ttype = ctx.targetType or ctld.i18n_translate("unknown")
    local code  = ctx.laserCode  and tostring(ctx.laserCode) or ctld.i18n_translate("UNKNOWN")
    local pos   = ctx.positionStr or ""

    local codePosStr = ctld.i18n_translate(". CODE: %1. POSITION: %2", code, pos)

    local short, full

    if ctx.event == "new_target" then
        local verb = ctx.standby
            and ctld.i18n_translate("standing by on")
            or  ctld.i18n_translate("lasing")
        if ctx.wasSelected then
            short = ctld.i18n_translate("%1, selected %2 %3", name, verb, ttype)
        else
            short = ctld.i18n_translate("%1, %2 new target, %3", name, verb, ttype)
        end
        full = short .. codePosStr

    elseif ctx.event == "target_reacquired" then
        short = ctld.i18n_translate("%1, selected target reacquired, %2", name, ttype)
        full  = short .. codePosStr

    elseif ctx.event == "target_lost" then
        if ctx.wasSelected then
            short = ctld.i18n_translate("%1, selected target lost, temporarily lasing %2", name, ttype)
        else
            short = ctld.i18n_translate("%1, target lost.", name)
        end
        full = short

    elseif ctx.event == "target_destroyed" then
        if ctx.wasSelected then
            short = ctld.i18n_translate("%1, selected target destroyed.", name)
        else
            short = ctld.i18n_translate("%1, target destroyed.", name)
        end
        full = short

    elseif ctx.event == "kia" then
        short = ctld.i18n_translate("JTAC %1 KIA!", name)
        full  = short

    elseif ctx.event == "no_targets" then
        short = ctld.i18n_translate("%1, no targets in range.", name)
        full  = short

    else
        short = name .. " " .. tostring(ctx.event)
        full  = short
    end

    return { short = short, full = full }
end


-- ============================================================
-- CTLDJTACManager  (singleton)
-- ============================================================

CTLDJTACManager = class()
CTLDJTACManager._instance = nil

--- Return (or create) the singleton instance.
function CTLDJTACManager.get()
    if not CTLDJTACManager._instance then
        local o          = setmetatable({}, CTLDJTACManager)
        o.jtacs          = {}
        o._laserPool     = {}
        o._pendingJTACs  = {}
        o._orbitScheduleId = nil
        -- Target deconfliction: { [enemyUnitName] = jtacKey } — tracks targets currently being lased.
        -- Prevents multiple concurrent JTACs from lasing the same target.
        o._claimedTargets = {}
        o:_initLaserPool()
        CTLDJTACManager._instance = o
        CTLDPlayerManager.getInstance():registerMenuSection({
            key       = "jtac",
            manager   = o,
            method    = "buildMenuSection",
            configKey = "JTAC_jtacStatusF10",
            order     = 90,
        })
    end
    return CTLDJTACManager._instance
end

--- Spawn a JTAC from an unpacked crate.
-- The DCS group must already exist in the world (spawned by CTLDCrateManager).
-- DCS bug workaround: first _autoLaseLoop is delayed +1s (group units empty on spawn).
-- @param groupName string   DCS group name
-- @param cfg       table    { laserCode, smokeEnabled, smokeColor, lockMode }  (all optional)
-- @param spawner   table    { playerName, unitName, unitId, coalition }
-- @return CTLDJTAC or nil
function CTLDJTACManager:spawnJTAC(groupName, cfg, spawner)
    local dcsGroup = Group.getByName(groupName)
    if not dcsGroup then
        ctld.logError("CTLDJTACManager:spawnJTAC — group not found: " .. tostring(groupName))
        return nil
    end

    -- Resolve or assign laser code
    local laserCode = cfg and cfg.laserCode
    if not laserCode then
        laserCode = self:_assignLaserCode()
    end
    if not laserCode then
        ctld.logError("CTLDJTACManager:spawnJTAC — laser code pool exhausted")
        return nil
    end

    local coalitionId = dcsGroup:getCoalition()

    -- Unit may be nil for ~1s after spawn (DCS bug); classify defensively
    local dcsUnit    = dcsGroup:getUnits()[1]
    local isFlying   = false
    local isInfantry = false
    if dcsUnit then
        local attrs  = dcsUnit:getDesc().attributes or {}
        isFlying     = attrs["Planes"] == true or attrs["Helicopters"] == true
        isInfantry   = attrs["Infantry"] == true
    end

    -- Explicit false from caller must not be overridden by config (boolean or-pattern trap)
    local smokeEnabled
    if cfg and cfg.smokeEnabled ~= nil then
        smokeEnabled = cfg.smokeEnabled
    elseif coalitionId == coalition.side.RED then
        smokeEnabled = ctld.gs("JTAC_smokeOn_RED") or false
    else
        smokeEnabled = ctld.gs("JTAC_smokeOn_BLUE") or false
    end
    local smokeColor
    if cfg and cfg.smokeColor ~= nil then
        smokeColor = cfg.smokeColor
    elseif coalitionId == coalition.side.RED then
        smokeColor = ctld.gs("JTAC_smokeColour_RED") or trigger.smokeColor.Red
    else
        smokeColor = ctld.gs("JTAC_smokeColour_BLUE") or trigger.smokeColor.Red
    end
    local lockMode = (cfg and cfg.lockMode) or ctld.gs("JTAC_lock") or "all"

    local jtac = CTLDJTAC:new({
        groupName    = groupName,
        laserCode    = laserCode,
        isFlying     = isFlying,
        isInfantry   = isInfantry,
        coalitionId  = coalitionId,
        smokeEnabled = smokeEnabled,
        smokeColor   = smokeColor,
        lockMode     = lockMode,
        orbitParams  = cfg and cfg.orbitParams,
    })

    self.jtacs[groupName] = jtac

    -- DCS bug: coalition.addGroup leaves the group empty for ~1s after spawn.
    -- isFlying may be false if the unit wasn't readable yet. Schedule a T+2s retry
    -- that re-classifies the unit and starts orbit loop if needed.
    local function _tryInitFlying()
        local mgr = CTLDJTACManager.get()
        local j   = mgr.jtacs[groupName]
        if not j then return end
        local g = Group.getByName(groupName)
        if not g then return end
        local u = g:getUnits()[1]
        if not u then return end

        -- Re-classify if isFlying was missed at registration time
        if not j.isFlying then
            local attrs = u:getDesc().attributes or {}
            if attrs["Planes"] == true or attrs["Helicopters"] == true then
                j.isFlying = true
            end
        end

        -- Capture initial position
        if j.isFlying and not j.initialPosition then
            j.initialPosition = u:getPoint()
        end

        -- Start orbit loop if not already running
        if j.isFlying and not mgr._orbitScheduleId then
            mgr._orbitScheduleId = timer.scheduleFunction(
                function(_, t) return CTLDJTACManager.get():_orbitLoop(t) end,
                nil,
                timer.getTime() + 3
            )
        end
    end

    _tryInitFlying()
    -- Always schedule retry: covers DCS 1s delay even when immediate call succeeds partially
    timer.scheduleFunction(function() _tryInitFlying() end, nil, timer.getTime() + 2)

    -- DCS spawn bug: delay first auto-lase loop by 1s so group:getUnits()[1] is populated
    timer.scheduleFunction(
        function(gn, t) return CTLDJTACManager.get():_autoLaseLoop(gn, t) end,
        groupName,
        timer.getTime() + 1
    )

    -- Publish event (dcsUnit may be nil within the 1s DCS spawn window — acceptable)
    self:_publishEvent("OnJTACSpawned", {
        jtac = {
            groupName  = groupName,
            groupId    = dcsGroup:getID(),
            unitName   = dcsUnit and dcsUnit:getName()    or groupName,
            unitId     = dcsUnit and dcsUnit:getID()      or nil,
            unitType   = dcsUnit and dcsUnit:getTypeName() or nil,
            coalition  = coalitionId,
            position   = dcsUnit and dcsUnit:getPoint()   or nil,
            isFlying   = isFlying,
            isInfantry = isInfantry,
            route      = jtac.initialRoute,
        },
        spawner      = spawner,
        laserCode    = laserCode,
        smokeEnabled = smokeEnabled,
        smokeColor   = smokeColor,
        lockMode     = lockMode,
        radio        = jtac.radio,
        timestamp    = timer.getAbsTime(),
    })

    return jtac
end

--- Get a JTAC entity by DCS group name.
-- @param groupName string
-- @return CTLDJTAC or nil
function CTLDJTACManager:getJTACByName(groupName)
    return self.jtacs[groupName]
end

--- Mark a ground JTAC as in-transit (called by CTLDTroopManager / CTLDVehicleSpawner).
-- @param groupName string   JTAC group name
-- @param transport table    { unitName, playerName }
function CTLDJTACManager:setJTACInTransit(groupName, transport)
    local jtac = self.jtacs[groupName]
    if not jtac or jtac.state == CTLDJTAC.STATE.DEAD then return end

    jtac:setInTransit()

    self:_publishEvent("OnJTACInTransit", {
        jtac      = { groupName = groupName, coalition = jtac.coalitionId },
        transport = transport,
        timestamp = timer.getAbsTime(),
    })
end

--- Silently deregister a JTAC (vehicle repacked into crates).
-- Stops lasing, frees laser code, removes from registry.
-- Does NOT publish OnJTACDead — repack is not a combat death.
-- @param groupName string
function CTLDJTACManager:deregisterJTAC(groupName)
    local jtac = self.jtacs[groupName]
    if not jtac then return end
    -- Release active target claim (stopLase below does not call _stopLaseAndPublish)
    if jtac.currentTarget then
        self:_releaseTarget(jtac.currentTarget.unitName)
    end
    local jtacKey = jtac.unitName or groupName
    self:_releaseAllTargetsFor(jtacKey)  -- belt-and-suspenders: clear any stale claims
    jtac:stopLase(CTLDJTAC.STOP_REASON.IN_TRANSIT)
    self:_freeLaserCode(jtac.laserCode)
    self.jtacs[groupName] = nil
    ctld.utils.log("INFO", "CTLDJTACManager:deregisterJTAC — '%s' silently deregistered", groupName)
end

--- Resume auto-lase for a JTAC after vehicle unload.
-- Restores state to IDLE and restarts the _autoLaseLoop.
-- @param groupName string
function CTLDJTACManager:resumeJTAC(groupName)
    local jtac = self.jtacs[groupName]
    if not jtac then return end
    jtac.state = CTLDJTAC.STATE.IDLE
    self:startLase(groupName)
    ctld.utils.log("INFO", "CTLDJTACManager:resumeJTAC — '%s' resumed after unload", groupName)
end

--- Smoke current target on demand (F10 menu action).
-- Applies JTAC_smokeMarginOfError offset.
-- @param groupName string
function CTLDJTACManager:requestSmoke(groupName)
    local jtac = self.jtacs[groupName]
    if not jtac or not jtac.currentTarget then return end

    local targetPos = jtac.currentTarget.position
    local margin    = ctld.gs("JTAC_smokeMarginOfError") or 50
    local smokePos  = {
        x = targetPos.x + math.random(-margin, margin),
        y = targetPos.y + (ctld.gs("JTAC_smokeOffset_y") or 2),
        z = targetPos.z + math.random(-margin, margin),
    }

    trigger.action.smoke(smokePos, jtac.smokeColor)

    self:_publishEvent("OnJTACSmokeTarget", {
        jtac          = { groupName = groupName, coalition = jtac.coalitionId },
        target        = { unitName = jtac.currentTarget.unitName, position = targetPos },
        smokePosition = smokePos,
        smokeColor    = jtac.smokeColor,
        timestamp     = timer.getAbsTime(),
    })
end

--- Called when a JTAC unit is destroyed (routed from CTLDDCSEventBridge / S_EVENT_DEAD).
-- @param groupName string
-- @param killer    table or nil  { unitName, playerName }
function CTLDJTACManager:killJTAC(groupName, killer)
    local jtac = self.jtacs[groupName]
    if not jtac then return end

    local lastTarget = jtac.currentTarget
    jtac:kill()

    local kiaMsg = CTLDJTACMessage.build({ event = "kia", jtacName = groupName })
    ctld.utils.notifyCoalition(kiaMsg.full, 10, jtac.coalitionId, jtac.radio, kiaMsg.short)

    self:_publishEvent("OnJTACDead", {
        jtac = {
            groupName = groupName,
            coalition = jtac.coalitionId,
            laserCode = jtac.laserCode,
        },
        killer      = killer,
        lastTarget  = lastTarget,
        timestamp   = timer.getAbsTime(),
    })

    self:_freeLaserCode(jtac.laserCode)
    self.jtacs[groupName] = nil
end

-- ============================================================
-- Legacy-compatible public API (called by compat/legacy_api.lua)
-- ============================================================

--- Spawn a flying JTAC from an unpacked crate and start auto-lase.
-- Orchestrates: ctld.utils.buildGroupUnitDef → spawnFromDescriptor → startLase.
-- Can also be called from legacy DO SCRIPT (ctld.JTACAutoLase wrapper path).
-- @param transport  Unit    transport unit (player helicopter)
-- @param position   vec3    horizontal spawn position {x, y, z} (y = ground level)
-- @param descriptor table   crate descriptor { unit, spawnAs, isJTAC, ... }
-- @param countryId  number  country.id.*
-- @return boolean  true if spawn succeeded
function CTLDJTACManager:deployAirJTAC(transport, position, descriptor, countryId)
    if not (ctld.gs("JTAC_dropEnabled") ~= false) then
        ctld.utils.log("INFO", "CTLDJTACManager:deployAirJTAC — JTAC_dropEnabled=false, skipped")
        return false
    end
    -- Default spawnAs to "AIRPLANE" when field absent (legacy compat)
    local desc  = descriptor.spawnAs and descriptor or { spawnAs = "AIRPLANE", unit = descriptor.unit, isJTAC = true }
    local gid   = ctld.utils.getNextUniqId()
    local uid   = ctld.utils.getNextUniqId()
    local gname = string.format("CTLD_AIR_%d", gid)
    local unitDef = ctld.utils.buildGroupUnitDef(desc, position, gname, gid, uid)
    local cId = countryId or country.id.USA
    local ok, err = ctld.utils.spawnFromDescriptor(desc, cId, unitDef)
    if not ok then
        local errStr = type(err) == "table" and ctld.utils.p(err) or tostring(err)
        ctld.utils.log("WARNING",
            "CTLDJTACManager:deployAirJTAC — spawnFromDescriptor failed: " .. errStr)
        return false
    end
    self:startLase(gname, nil, nil, nil, nil, nil, descriptor.specificParams)
    ctld.utils.log("INFO",
        string.format("CTLDJTACManager:deployAirJTAC — spawned %s as %s spawnAs=%s",
            gname, descriptor.unit, desc.spawnAs))
    return true
end

--- Activate auto-lase for an existing DCS JTAC group (MM DO SCRIPT).
-- Equivalent to legacy ctld.JTACAutoLase(). Wraps spawnJTAC with converted params.
-- @param groupName  string   DCS group name
-- @param laserCode  number   laser code 1111-1688 (nil = auto-assigned)
-- @param smoke      boolean  enable smoke on target
-- @param lock       string   "all" | "vehicle" | "troop" (nil = "all")
-- @param colour     number   trigger.smokeColor.* (nil = Red)
-- @param radio      table    { freq, mod, name } (nil = auto)
-- @param orbitParams table   { speed, alti, orbitRadiusNoLase, orbitRadiusOnLase } (nil = config defaults)
-- @return CTLDJTAC|nil
function CTLDJTACManager:autoLase(groupName, laserCode, smoke, lock, colour, radio, orbitParams)
    if self.jtacs[groupName] then
        ctld.utils.log("WARN", "CTLDJTACManager:autoLase — JTAC already active: %s", groupName)
        return self.jtacs[groupName]
    end
    local cfg = {
        laserCode    = laserCode and tonumber(laserCode) or nil,
        smokeEnabled = smoke == true,
        lockMode     = (lock == "vehicle" or lock == "troop") and lock or "all",
        smokeColor   = colour or trigger.smokeColor.Red,
        radio        = radio,
        orbitParams  = orbitParams,
    }
    return self:spawnJTAC(groupName, cfg, nil)
end

--- Activate auto-lase with a 1-second delay (legacy ctld.JTACStart behaviour).
-- @param groupName  string
-- @param laserCode  number
-- @param smoke      boolean
-- @param lock       string
-- @param colour     number
-- @param radio      table
-- @param orbitParams table  { speed, alti, orbitRadiusNoLase, orbitRadiusOnLase } (nil = config defaults)
function CTLDJTACManager:startLase(groupName, laserCode, smoke, lock, colour, radio, orbitParams)
    timer.scheduleFunction(
        function(args, t)
            CTLDJTACManager.get():autoLase(
                args[1], args[2], args[3], args[4], args[5], args[6], args[7])
        end,
        { groupName, laserCode, smoke, lock, colour, radio, orbitParams },
        timer.getTime() + 1
    )
end

--- Register and start auto-lase for a JTAC infantry unit within a composite troop group.
-- Unlike spawnJTAC/startLase (which operate on single-unit DCS groups keyed by groupName),
-- this function targets a specific DCS unit by unitName (part of a composite group).
-- Registry key: unitName. Auto-lase loop uses Unit.getByName() instead of Group.getByName().
-- Death detection: handled by S_EVENT_DEAD → onUnitDead → deregisterJTAC (no killJTAC).
-- @param unitName  string   DCS unit name (JTAC-role infantry in a composite troop group)
-- @param cfg       table    { laserCode, smokeEnabled, smokeColor, lockMode } (all optional)
-- @return CTLDJTAC or nil
function CTLDJTACManager:startLaseTroopUnit(unitName, cfg)
    if self.jtacs[unitName] then
        ctld.utils.log("WARN", "CTLDJTACManager:startLaseTroopUnit — already active: %s", unitName)
        return self.jtacs[unitName]
    end

    local dcsUnit = Unit.getByName(unitName)
    if not dcsUnit or not dcsUnit:isExist() then
        ctld.utils.log("WARN", "CTLDJTACManager:startLaseTroopUnit — unit not found: %s", tostring(unitName))
        return nil
    end

    local laserCode = (cfg and cfg.laserCode) or self:_assignLaserCode()
    if not laserCode then
        ctld.logError("CTLDJTACManager:startLaseTroopUnit — laser code pool exhausted")
        return nil
    end

    local coalitionId = dcsUnit:getCoalition()
    local attrs       = dcsUnit:getDesc().attributes or {}
    local isInfantry  = attrs["Infantry"] == true

    local smokeEnabled
    if cfg and cfg.smokeEnabled ~= nil then
        smokeEnabled = cfg.smokeEnabled
    elseif coalitionId == coalition.side.RED then
        smokeEnabled = ctld.gs("JTAC_smokeOn_RED") or false
    else
        smokeEnabled = ctld.gs("JTAC_smokeOn_BLUE") or false
    end

    local smokeColor
    if cfg and cfg.smokeColor ~= nil then
        smokeColor = cfg.smokeColor
    elseif coalitionId == coalition.side.RED then
        smokeColor = ctld.gs("JTAC_smokeColour_RED") or trigger.smokeColor.Red
    else
        smokeColor = ctld.gs("JTAC_smokeColour_BLUE") or trigger.smokeColor.Red
    end

    local lockMode = (cfg and cfg.lockMode) or ctld.gs("JTAC_lock") or "all"

    local jtac = CTLDJTAC:new({
        groupName    = unitName,   -- registry key (= unitName for troop JTACs)
        unitName     = unitName,   -- marks as unit-keyed; drives Unit.getByName() in _autoLaseLoop
        laserCode    = laserCode,
        isFlying     = false,
        isInfantry   = isInfantry,
        coalitionId  = coalitionId,
        smokeEnabled = smokeEnabled,
        smokeColor   = smokeColor,
        lockMode     = lockMode,
    })

    self.jtacs[unitName] = jtac

    timer.scheduleFunction(
        function(un, t) return CTLDJTACManager.get():_autoLaseLoop(un, t) end,
        unitName,
        timer.getTime() + 1
    )

    self:_publishEvent("OnJTACSpawned", {
        jtac = {
            groupName  = unitName,
            unitName   = unitName,
            laserCode  = laserCode,
            coalition  = coalitionId,
            isFlying   = false,
            isInfantry = isInfantry,
        },
        timestamp = timer.getAbsTime(),
    })

    ctld.utils.log("INFO",
        "CTLDJTACManager:startLaseTroopUnit — '%s' registered (code=%d)", unitName, laserCode)
    return jtac
end

--- Stop auto-lase for a JTAC group without firing the Dead event.
-- Sets the JTAC to standby mode; the auto-lase loop will stop lasing and idle.
-- @param groupName string
function CTLDJTACManager:stopAutoLase(groupName)
    local jtac = self.jtacs[groupName]
    if not jtac then
        ctld.utils.log("WARN", "CTLDJTACManager:stopAutoLase — JTAC not found: %s", tostring(groupName))
        return
    end
    jtac.standbyMode = true
    ctld.utils.log("INFO", "CTLDJTACManager:stopAutoLase — '%s' set to standby", groupName)
end

--- Destroy all active JTACs and reset state.
function CTLDJTACManager:cleanup()
    for _, jtac in pairs(self.jtacs) do
        jtac:destroy()
    end
    self.jtacs           = {}
    self._claimedTargets = {}
    self._laserPool      = {}
    self:_initLaserPool()
    self._orbitScheduleId = nil
end


-- ──────────────────────────────────────────────────
-- Private
-- ──────────────────────────────────────────────────

--- Main auto-lase loop for one JTAC. Self-rescheduling via timer.scheduleFunction.
-- Interval: JTAC_laseIntervalSeconds when lasing, JTAC_searchIntervalSeconds when searching.
-- @param groupName string
-- @param t         number  timer.getTime() at call time (provided by scheduleFunction)
-- @return number or nil    next schedule time (nil stops the loop)
function CTLDJTACManager:_autoLaseLoop(groupName, t)
    local jtac = self.jtacs[groupName]
    if not jtac then return nil end
    if jtac.state == CTLDJTAC.STATE.DEAD then return nil end

    local searchInterval = ctld.gs("JTAC_searchIntervalSeconds")
    local laseInterval   = ctld.gs("JTAC_laseIntervalSeconds")

    -- In transit: unit intentionally absent from map — do not probe DCS group existence.
    -- (virtual load: unit destroyed; dcs_native load: unit inside aircraft — both absent from ground)
    if jtac.state == CTLDJTAC.STATE.IN_TRANSIT then
        return t + searchInterval
    end

    -- Standby mode: stop lasing if active, wait
    if jtac.standbyMode then
        if jtac.currentTarget then
            self:_stopLaseAndPublish(jtac, CTLDJTAC.STOP_REASON.STANDBY_MODE)
        end
        return t + searchInterval
    end

    -- Resolve JTAC unit:
    --   unit-keyed (infantry in composite troop group): Unit.getByName(jtac.unitName)
    --   group-keyed (drone, vehicle — single-unit DCS group): Group.getByName():getUnits()[1]
    local jtacUnit
    if jtac.unitName then
        jtacUnit = Unit.getByName(jtac.unitName)
        if not jtacUnit or not jtacUnit:isExist() then
            -- Unit dead — S_EVENT_DEAD → onUnitDead → deregisterJTAC already handles cleanup.
            -- Just stop the loop; do NOT call killJTAC (would destroy the whole composite group).
            return nil
        end
    else
        local dcsGroup = Group.getByName(groupName)
        if not dcsGroup or not dcsGroup:isExist() then
            self:killJTAC(groupName, nil)
            return nil
        end
        jtacUnit = dcsGroup:getUnits()[1]
        if not jtacUnit or not jtacUnit:isExist() then
            -- Unit gone but group still reported alive — treat as dead
            self:killJTAC(groupName, nil)
            return nil
        end
    end

    -- ── Check existing target ──────────────────────────────────
    if jtac.currentTarget then
        local targetUnit = Unit.getByName(jtac.currentTarget.unitName)

        -- Target destroyed?
        if not targetUnit or not targetUnit:isExist() or targetUnit:getLife() <= 1 then
            self:_stopLaseAndPublish(jtac, CTLDJTAC.STOP_REASON.TARGET_DESTROYED)
            -- Fall through to search below
        else
            -- LOS still valid?
            local jtacPos   = jtacUnit:getPoint()
            local targetPos = targetUnit:getPoint()
            local offsetA   = { x = jtacPos.x,   y = jtacPos.y   + 2, z = jtacPos.z   }
            local offsetB   = { x = targetPos.x, y = targetPos.y + 2, z = targetPos.z }

            if not CTLDJTACDetector.checkLOS(offsetA, offsetB) then
                self:_stopLaseAndPublish(jtac, CTLDJTAC.STOP_REASON.TARGET_LOST)
                -- Fall through to search below
            else
                -- Target still valid — update spot position
                local correctedPos = targetPos
                if jtac.laseSpotCorrections then
                    local vel  = targetUnit:getVelocity()
                    local wind = atmosphere.getWind(targetPos)
                    correctedPos = CTLDJTACDetector.calculateCorrectedSpot(targetPos, vel, wind)
                end
                jtac:updateLaseSpot(correctedPos)

                self:_publishEvent("OnJTACTargetLased", {
                    jtac   = { groupName = groupName, unitName = jtacUnit:getName(), coalition = jtac.coalitionId },
                    target = { unitName = jtac.currentTarget.unitName, position = correctedPos },
                    laserCode = jtac.laserCode,
                    timestamp = timer.getAbsTime(),
                })
                return t + laseInterval
            end
        end
    end

    -- ── Search for new target (with deconfliction) ────────────
    -- findAllVisibleEnemies returns candidates sorted by priority then distance.
    -- With deconfliction enabled, iterate until a non-claimed target is found.
    -- jtacKey identifies this JTAC's slot in _claimedTargets.
    local jtacKey    = jtac.unitName or groupName
    local candidates = CTLDJTACDetector.findAllVisibleEnemies(
        jtacUnit, jtac.lockMode, ctld.gs("JTAC_maxDistance"))
    local found = nil

    if ctld.gs("JTAC_targetDeconfliction") ~= false then
        for _, candidate in ipairs(candidates) do
            if not self._claimedTargets[candidate.unitName] then
                found = candidate
                break
            end
        end
    else
        found = candidates[1]
    end

    if not found then
        return t + searchInterval
    end

    -- Claim the target before creating DCS spots — prevents a concurrent JTAC loop
    -- from selecting the same target in the same scheduler tick.
    self:_claimTarget(jtacKey, found.unitName)

    -- Stop ground unit movement while lasing.
    -- Use jtacUnit:getGroup() — works for both unit-keyed (infantry) and group-keyed (vehicle/drone)
    -- paths, because dcsGroup is scoped to the else-block above and not accessible here.
    if not jtac.isFlying then
        local stopGroup = jtacUnit:getGroup()
        if stopGroup then trigger.action.groupStopMoving(stopGroup) end
    end

    -- Compute lase position (with correction if enabled)
    local lasePos = found.position
    if jtac.laseSpotCorrections then
        local vel  = found.dcsUnit:getVelocity()
        local wind = atmosphere.getWind(found.position)
        lasePos = CTLDJTACDetector.calculateCorrectedSpot(found.position, vel, wind)
    end

    -- Create DCS Spot objects
    -- API: Spot.createLaser, Spot.createInfraRed — verified CTLD_jtac.lua source
    local spotOffset = { x = 0, y = 2, z = 0 }
    local laserSpot  = Spot.createLaser(jtacUnit, spotOffset, lasePos, jtac.laserCode)
    local irSpot     = Spot.createInfraRed(jtacUnit, spotOffset, lasePos)

    jtac:startLase(found, laserSpot, irSpot)

    -- Auto-smoke on target
    if jtac.smokeEnabled then
        trigger.action.smoke(lasePos, jtac.smokeColor)
    end

    -- Build and send player notification
    local msg = CTLDJTACMessage.build({
        event       = "new_target",
        jtacName    = groupName,
        targetType  = found.unitType,
        laserCode   = jtac.laserCode,
        positionStr = ctld.utils.getPositionString(found.dcsUnit),
        wasSelected = (jtac.selectedTarget == found.unitName),
        standby     = jtac.standbyMode,
    })
    ctld.utils.notifyCoalition(msg.full, 10, jtac.coalitionId, jtac.radio, msg.short)

    self:_publishEvent("OnJTACLaseStart", {
        jtac = {
            groupName = groupName,
            unitName  = jtacUnit:getName(),
            position  = jtacUnit:getPoint(),
            coalition = jtac.coalitionId,
        },
        target = {
            unitName            = found.unitName,
            unitId              = found.unitId,
            unitType            = found.unitType,
            coalition           = found.dcsUnit:getCoalition(),
            position            = found.position,
            priority            = found.priority,
            selectionMethod     = "auto_nearest",
            wasManuallySelected = false,
        },
        laserCode   = jtac.laserCode,
        lockMode    = jtac.lockMode,
        distance    = found.distance,
        lineOfSight = true,
        radio       = jtac.radio,
        message     = msg,
        timestamp   = timer.getAbsTime(),
    })

    return t + laseInterval
end

--- Shared orbit loop for all flying JTACs. Runs every 3 seconds.
-- Handles: orbit start, orbit update (every 60s), orbit stop + backToRoute.
-- API: Unit:getController():popTask(), Group:getController():pushTask()
--      verified CTLD_jtac.lua source (ctld.StartOrbitGroup / backToRoute)
-- @param t number  timer.getTime()
-- @return number or nil
function CTLDJTACManager:_orbitLoop(t)
    if ctld.gs("enableAutoOrbitingFlyingJtacOnTarget") == false then
        return t + 3  -- autoOrbit disabled
    end
    local hasFlying = false
    for groupName, jtac in pairs(self.jtacs) do
        if jtac.isFlying and jtac.state ~= CTLDJTAC.STATE.DEAD then
            self:_updateOrbit(groupName, jtac, t)
            hasFlying = true
        end
    end
    if not hasFlying then
        self._orbitScheduleId = nil
        return nil
    end
    return t + 3
end

--- Update orbit state for one flying JTAC.
-- Legacy pattern (pushTask/popTask):
--   • spawn → setTask(Mission loop) — initial circular route with SwitchWaypoint
--   • target acquired → pushTask(Orbit/Circle) — stacks on top of route
--   • target lost     → popTask()              — DCS restores the Mission route underneath
-- jtac.onTargetOrbit tracks which mode is active.
function CTLDJTACManager:_updateOrbit(groupName, jtac, t)
    local hasCurrent    = jtac.currentTarget ~= nil
    local inOrbit       = jtac.state == CTLDJTAC.STATE.ORBITING
    local onTargetOrbit = jtac.onTargetOrbit == true

    local dcsGroup = Group.getByName(groupName)
    if not dcsGroup then return end
    local jtacUnit = dcsGroup:getUnits()[1]
    if not jtacUnit then return end

    -- onTargetOrbit (not inOrbit/state) is the discriminator for all branches:
    --   false = drone on initial waypoint loop (or just spawned)
    --   true  = drone has a Circle pushTask on top of its initial Mission route

    if hasCurrent and not onTargetOrbit then
        -- Target acquired (or re-acquired after recovery) — pushTask Circle on initial route
        local targetUnit = Unit.getByName(jtac.currentTarget.unitName)
        if not targetUnit or not targetUnit:isExist() then return end

        local rOnLase = jtac.orbitParams and jtac.orbitParams.orbitRadiusOnLase or ctld.gs("JTAC_droneRadius") or 1000
        self:_setOrbitTask(dcsGroup, jtacUnit, targetUnit:getPoint(), jtac.orbitParams, rOnLase)
        jtac.onTargetOrbit = true
        jtac:startOrbit(t)

        self:_publishEvent("OnJTACOrbitStart", {
            jtac      = { groupName = groupName, coalition = jtac.coalitionId },
            target    = { unitName = jtac.currentTarget.unitName, position = jtac.currentTarget.position },
            timestamp = timer.getAbsTime(),
        })

    elseif hasCurrent and onTargetOrbit then
        -- Already on target orbit — update centre every 60s if target moved
        if jtac.orbitStartTime and (t - jtac.orbitStartTime) >= 60 then
            local targetUnit = Unit.getByName(jtac.currentTarget.unitName)
            if targetUnit and targetUnit:isExist() then
                local rOnLase = jtac.orbitParams and jtac.orbitParams.orbitRadiusOnLase or ctld.gs("JTAC_droneRadius") or 1000
                self:_setOrbitTask(dcsGroup, jtacUnit, targetUnit:getPoint(), jtac.orbitParams, rOnLase)
                jtac.orbitStartTime = t
            end
        end

    elseif not hasCurrent and onTargetOrbit then
        -- Target lost/destroyed:
        --   1. popTask on group controller → removes the pushed Circle orbit
        --   2. setTask(Mission) on group controller → replays stored initial route
        -- Both operate on group controller (same level as pushTask in _setOrbitTask).
        dcsGroup:getController():popTask()
        if jtac.initialRoute then
            dcsGroup:getController():setTask({
                id     = "Mission",
                params = { route = { points = jtac.initialRoute } },
            })
            ctld.utils.log("INFO", "[JTAC] _updateOrbit: target lost, route restored for %s", groupName)
        end
        jtac.onTargetOrbit = false
        jtac:stopOrbit()   -- back to IDLE: ORBITING is reserved for "following a lased target"

    elseif not hasCurrent and not inOrbit and not jtac.initialRouteAssigned then
        -- Just spawned, initialPosition captured — assign initial looping route (once only)
        if jtac.initialPosition then
            local rNoLase = jtac.orbitParams and jtac.orbitParams.orbitRadiusNoLase or ctld.gs("JTAC_droneRadius") or 1000
            self:_setOrbitRoute(dcsGroup, groupName, jtac.initialPosition, jtac.orbitParams, rNoLase)
            jtac.initialRouteAssigned = true
            jtac.onTargetOrbit        = false
            -- state stays IDLE: drone is "on route", not orbiting a target
        end
    end
end

--- Build and assign a looping circular Mission route as initial orbit.
-- Uses SwitchWaypoint on last WP to loop back to WP 1 (same as legacy editor route).
-- @param dcsGroup    DCS Group
-- @param groupName   string
-- @param center      vec3 or vec2  orbit center (= initialPosition)
-- @param orbitParams table or nil
-- @param radius      number meters (informational — DCS turn physics control effective radius)
local ORBIT_ROUTE_PTS = 8   -- 8 waypoints = 45° segments, reasonable turn radius
function CTLDJTACManager:_setOrbitRoute(dcsGroup, groupName, center, orbitParams, radius)
    local speedKmh = orbitParams and orbitParams.speed or 100
    local altiAGL  = orbitParams and orbitParams.alti  or ctld.gs("JTAC_droneAltitude") or 4000
    local vec2     = ctld.utils.makeVec2FromVec3OrVec2("_setOrbitRoute", center)
    local cx, cz   = vec2.x, vec2.y
    local terrainH = land.getHeight({ x = cx, y = cz })
    local altASL   = terrainH + altiAGL
    local speedMs  = speedKmh / 3.6
    local n        = ORBIT_ROUTE_PTS

    -- Find nearest WP to drone current position → start there
    local u = dcsGroup:getUnits()[1]
    local nearestIdx = 1
    if u then
        local upos = u:getPoint()
        local minD = math.huge
        for i = 1, n do
            local angle = 2 * math.pi * (i - 1) / n
            local dx = (cx + radius * math.cos(angle)) - upos.x
            local dz = (cz + radius * math.sin(angle)) - upos.z
            local d  = dx*dx + dz*dz
            if d < minD then minD = d; nearestIdx = i end
        end
    end

    -- Build n WPs with empty tasks, then rotate so nearest WP is first.
    -- SwitchWaypoint is placed on rotated[n] AFTER rotation so it always lands
    -- on the physically-last WP regardless of nearestIdx.
    local pts = {}
    for i = 1, n do
        local angle = 2 * math.pi * (i - 1) / n
        pts[i] = {
            x            = cx + radius * math.cos(angle),
            y            = cz + radius * math.sin(angle),
            alt          = altASL,
            alt_type     = "BARO",
            speed        = speedMs,
            speed_locked = true,
            type         = "Turning Point",
            action       = "Turning Point",
            ETA          = 0,
            ETA_locked   = false,
            task         = { id = "ComboTask", params = { tasks = {} } },
        }
    end

    -- Rotate so nearest WP is first → drone heads straight to it
    local rotated = {}
    for i = 1, n do
        rotated[i] = pts[((nearestIdx + i - 2) % n) + 1]
    end

    -- Attach SwitchWaypoint to the last rotated WP so the full circle loops correctly
    rotated[n].task = {
        id     = "ComboTask",
        params = {
            tasks = {
                [1] = {
                    enabled = true,
                    auto    = false,
                    id      = "WrappedAction",
                    number  = 1,
                    params  = {
                        action = {
                            id     = "SwitchWaypoint",
                            params = { goToWaypointIndex = 1, fromWaypointIndex = n },
                        },
                    },
                },
            },
        },
    }

    -- Store route for explicit replay on target loss (popTask is unreliable)
    local jtac = self.jtacs[groupName]
    if jtac then jtac.initialRoute = rotated end

    dcsGroup:getController():setTask({
        id     = "Mission",
        params = { route = { points = rotated } },
    })
    ctld.utils.log("INFO", "[JTAC] _setOrbitRoute %s center(%.0f,%.0f) r=%d altASL=%.0f start_wp=%d",
        groupName, cx, cz, radius, altASL, nearestIdx)
end

--- Push an Orbit/Circle task on top of the initial Mission route (legacy pushTask pattern).
-- popTask() first removes any previously pushed orbit, then pushTask() adds the new one.
-- The initial Mission route remains in the task stack — popTask() restores it on target loss.
-- @param dcsGroup    DCS Group
-- @param jtacUnit    DCS Unit  (used for popTask on the unit controller)
-- @param center      vec3 or vec2  orbit center (target position)
-- @param orbitParams table or nil  { speed(km/h), alti(m AGL) }
-- @param _radius     number  unused (DCS Circle radius is speed-controlled)
function CTLDJTACManager:_setOrbitTask(dcsGroup, jtacUnit, center, orbitParams, _radius)
    local orbitPoint = ctld.utils.makeVec2FromVec3OrVec2("_setOrbitTask", center)
    local speedKmh = orbitParams and orbitParams.speed or 100
    local altiAGL  = orbitParams and orbitParams.alti  or ctld.gs("JTAC_droneAltitude") or 4000
    local terrainH = land.getHeight({ x = orbitPoint.x, y = orbitPoint.y })
    local orbit = {
        id     = "Orbit",
        params = {
            pattern  = "Circle",
            point    = orbitPoint,
            altitude = terrainH + altiAGL,
            speed    = speedKmh / 3.6,
        },
    }
    -- Push orbit on GROUP controller so GROUP setTask(Mission) can cleanly replace it.
    -- popTask on UNIT first removes any stale unit-level task before group-level push.
    jtacUnit:getController():popTask()
    dcsGroup:getController():pushTask(orbit)
end

--- Record that jtacKey is actively lasing enemyUnitName.
-- Prevents other JTACs from selecting the same target.
-- @param jtacKey      string  unitName (infantry) or groupName (vehicle/drone)
-- @param enemyUnitName string  DCS unit name of the lased target
function CTLDJTACManager:_claimTarget(jtacKey, enemyUnitName)
    self._claimedTargets[enemyUnitName] = jtacKey
    ctld.utils.log("INFO", "[JTAC] claim: '%s' → '%s'", jtacKey, enemyUnitName)
end

--- Release the claim on a target (called when lasing stops for any reason).
-- @param enemyUnitName string
function CTLDJTACManager:_releaseTarget(enemyUnitName)
    if self._claimedTargets[enemyUnitName] then
        ctld.utils.log("INFO", "[JTAC] release claim on '%s' (was: '%s')",
            enemyUnitName, tostring(self._claimedTargets[enemyUnitName]))
        self._claimedTargets[enemyUnitName] = nil
    end
end

--- Release all target claims owned by jtacKey (called on deregister/cleanup).
-- Collects keys first to avoid mutating the table during iteration (Lua 5.1).
-- @param jtacKey string
function CTLDJTACManager:_releaseAllTargetsFor(jtacKey)
    local toRemove = {}
    for enemyUnitName, owner in pairs(self._claimedTargets) do
        if owner == jtacKey then
            toRemove[#toRemove + 1] = enemyUnitName
        end
    end
    for _, enemyUnitName in ipairs(toRemove) do
        self._claimedTargets[enemyUnitName] = nil
    end
    if #toRemove > 0 then
        ctld.utils.log("INFO", "[JTAC] _releaseAllTargetsFor '%s': %d claim(s) released", jtacKey, #toRemove)
    end
end

--- Stop lasing and publish OnJTACLaseStop event.
-- @param jtac   CTLDJTAC
-- @param reason string
function CTLDJTACManager:_stopLaseAndPublish(jtac, reason)
    local prevTarget = jtac.currentTarget
    -- Release target claim before stopLase() nils currentTarget
    if prevTarget then
        self:_releaseTarget(prevTarget.unitName)
    end
    jtac:stopLase(reason)

    -- Notify player on target events (not on internal transitions like standby/transit)
    if reason == CTLDJTAC.STOP_REASON.TARGET_LOST or reason == CTLDJTAC.STOP_REASON.TARGET_DESTROYED then
        local msg = CTLDJTACMessage.build({
            event       = reason,
            jtacName    = jtac.groupName,
            targetType  = prevTarget and prevTarget.unitType or nil,
            wasSelected = prevTarget ~= nil and (prevTarget.unitName == jtac.selectedTarget),
        })
        ctld.utils.notifyCoalition(msg.full, 10, jtac.coalitionId, jtac.radio, msg.short)
    end

    self:_publishEvent("OnJTACLaseStop", {
        jtac = {
            groupName = jtac.groupName,
            coalition = jtac.coalitionId,
            laserCode = jtac.laserCode,
        },
        target = prevTarget and {
            unitName          = prevTarget.unitName,
            unitType          = prevTarget.unitType,
            lastKnownPosition = prevTarget.position,
        } or nil,
        reason    = reason,
        timestamp = timer.getAbsTime(),
    })
end

--- Fill the laser pool with all valid codes (1111–1688). Called at init and cleanup.
function CTLDJTACManager:_initLaserPool()
    self._laserPool = {}
    for code = 1111, 1688 do
        self._laserPool[#self._laserPool + 1] = code
    end
end

--- Assign next laser code from the pool. O(1) — removes from tail.
-- @return number or nil  (nil = pool exhausted)
function CTLDJTACManager:_assignLaserCode()
    return table.remove(self._laserPool)
end

--- Return a laser code to the pool.
-- @param code number
function CTLDJTACManager:_freeLaserCode(code)
    if code then
        self._laserPool[#self._laserPool + 1] = code
    end
end

--- Publish an event via EventDispatcher.
function CTLDJTACManager:_publishEvent(eventName, payload)
    EventDispatcher.getInstance():publish(eventName, payload)
end

--- Register a pre-placed MM JTAC group (reuses spawnJTAC logic).
-- Called by CTLDCoreManager:_initMMJTACs() for active groups,
-- and by onBirth() for late-activation groups.
-- @param group Group  DCS group object (must be active and exist)
-- @return CTLDJTAC or nil
function CTLDJTACManager:registerMMJTAC(group)
    return self:spawnJTAC(group:getName(), nil, "mission_maker")
end

--- Mark a JTAC group as pending late activation.
-- @param groupName string
function CTLDJTACManager:markPendingJTAC(groupName)
    self._pendingJTACs[groupName] = true
end

--- Return true if groupName is marked as pending.
-- @param groupName string
-- @return boolean
function CTLDJTACManager:_isPendingJTAC(groupName)
    return self._pendingJTACs[groupName] == true
end

--- Clear the pending flag for groupName.
-- @param groupName string
function CTLDJTACManager:_clearPendingJTAC(groupName)
    self._pendingJTACs[groupName] = nil
end

--- S_EVENT_BIRTH handler: activate pending late-activation JTAC groups.
-- Registered in CTLDDCSEventBridge by CTLDCoreManager.
function CTLDJTACManager:onBirth(event)
    local unit = event.initiator
    if not unit then return end
    local group = (unit.getGroup and unit:getGroup()) or nil
    if not group then return end
    local groupName = group:getName()
    if self:_isPendingJTAC(groupName) then
        self:registerMMJTAC(group)
        self:_clearPendingJTAC(groupName)
    end
end

-- ============================================================
-- F10 Menu section
-- ============================================================

--- Rebuild the "Request JTAC Equipment" dynamic submenu for playerObj.
-- Shows available types when landed in a logistics zone; placeholder otherwise.
-- Called from buildMenuSection and on landing/takeoff/FOB events.
-- @param playerObj CTLDPlayer
function CTLDJTACManager:refreshJtacEquipmentSection(playerObj)
    if ctld.gs("JTAC_dropEnabled") == false then return end
    if not playerObj.isTransport then return end
    local typeNames = (ctld.gs("JTAC_unitTypeNames") or {})[playerObj.coalition] or {}
    if #typeNames == 0 then return end

    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root   = ctld.tr("CTLD")
    local jtacSub = ctld.tr("JTAC")
    local reqSub  = ctld.tr("Request JTAC Equipment")
    menu:clearBranch({ root, jtacSub, reqSub })

    local transport = Unit.getByName(playerObj.unitName)
    if not (transport and transport:isExist()) or ctld.utils.inAir(transport) then
        menu:addCommand({ root, jtacSub, reqSub },
            ctld.tr("Land near logistics to request equipment"), function() end, {})
        menu:refresh()
        return
    end

    local zm   = CTLDZoneManager.getInstance()
    local zone = zm:getLogisticZoneAtPoint(transport:getPoint(), playerObj.coalition)
    if not zone then
        menu:addCommand({ root, jtacSub, reqSub },
            ctld.tr("No logistics in range"), function() end, {})
        menu:refresh()
        return
    end

    for _, typeName in ipairs(typeNames) do
        menu:addCommand({ root, jtacSub, reqSub }, typeName,
            function(arg)
                local t = Unit.getByName(arg.unitName)
                if not (t and t:isExist()) then return end
                local z = CTLDZoneManager.getInstance()
                    :getLogisticZoneAtPoint(t:getPoint(), arg.coalition)
                if not z then
                    trigger.action.outTextForGroup(arg.groupId,
                        ctld.tr("You are not close enough to friendly logistics."), 10)
                    return
                end
                local vehicle = CTLDVehicleSpawner.getInstance()
                    :spawnJTACVehicleForTransport(arg.typeName, t, z)
                if vehicle then
                    trigger.action.outTextForGroup(arg.groupId,
                        string.format(ctld.tr("%s is ready for pickup."), arg.typeName), 10)
                end
            end,
            { unitName  = playerObj.unitName,
              groupId   = playerObj.groupId,
              coalition = playerObj.coalition,
              typeName  = typeName })
    end
    menu:refresh()
end

--- Build the "JTAC" F10 submenu for a player.
-- Requires JTAC_jtacStatusF10 = true (configKey gate).
-- Adds "JTAC Status" command + per-active-JTAC submenus for player coalition.
-- On JTAC state changes (spawn/dead/transit), CTLDPlayerManager:refreshAll()
-- triggers a full wipe+rebuild, keeping this content current.
-- @param playerObj CTLDPlayer
-- @param menu      ctld.Menu
function CTLDJTACManager:buildMenuSection(playerObj, menu)
    local root    = ctld.tr("CTLD")
    local jtacSub = ctld.tr("JTAC")
    menu:addSubMenu({ root }, jtacSub, { order = 90 })

    -- Request JTAC Equipment: dynamic section rebuilt on landing/takeoff/FOB events
    if ctld.gs("JTAC_dropEnabled") ~= false and playerObj.isTransport then
        local typeNames = (ctld.gs("JTAC_unitTypeNames") or {})[playerObj.coalition] or {}
        if #typeNames > 0 then
            menu:addSubMenu({ root, jtacSub }, ctld.tr("Request JTAC Equipment"))
            self:refreshJtacEquipmentSection(playerObj)
        end
    end

    menu:addCommand({ root, jtacSub }, ctld.tr("JTAC Status"),
        function(arg)
            local mgr   = CTLDJTACManager.get()
            local lines = {}
            for gname, j in pairs(mgr.jtacs) do
                if j.coalitionId == arg.coalition and j.state ~= CTLDJTAC.STATE.DEAD then
                    local target = j.currentTarget and j.currentTarget.unitName or ctld.tr("no target")
                    table.insert(lines, string.format("%s [%s] → %s (code %s)",
                        gname, tostring(j.state), target, tostring(j.laserCode or "?")))
                end
            end
            local msg = #lines > 0 and table.concat(lines, "\n") or ctld.tr("No active JTACs.")
            trigger.action.outTextForGroup(arg.groupId, msg, 15)
        end,
        { groupId = playerObj.groupId, coalition = playerObj.coalition })

    -- Per-active-JTAC submenus for this coalition
    for groupName, jtac in pairs(self.jtacs) do
        if jtac.coalitionId == playerObj.coalition and jtac.state ~= CTLDJTAC.STATE.DEAD then
            menu:addSubMenu({ root, jtacSub }, groupName)

            if ctld.gs("JTAC_allowStandbyMode") then
                menu:addCommand({ root, jtacSub, groupName }, ctld.tr("Toggle Lasing"),
                    function(arg)
                        ctld.utils.log("INFO", "Toggle Lasing for " .. arg.groupName)
                    end,
                    { groupName = groupName })
            end

            if ctld.gs("JTAC_allowSmokeRequest") then
                menu:addCommand({ root, jtacSub, groupName }, ctld.tr("Request Smoke on Target"),
                    function(arg)
                        CTLDJTACManager.get():requestSmoke(arg.groupName)
                    end,
                    { groupName = groupName })
            end

            if ctld.gs("JTAC_allow9Line") then
                menu:addCommand({ root, jtacSub, groupName }, ctld.tr("Request 9-Line"),
                    function(arg)
                        ctld.utils.log("INFO", "9-Line for " .. arg.groupName)
                    end,
                    { groupName = groupName })
            end
        end
    end
end

-- End : CTLD_jtac.lua
-- ====================================================================================================
-- Start : CTLD_player.lua
---@diagnostic disable
-- ============================================================
-- CTLD_player.lua
-- CTLDPlayer entity + CTLDPlayerManager singleton
--
-- CTLDPlayer       : immutable identity snapshot (unit name, group, coalition,
--                    type, capabilities) plus mutable cargo state
--                    (loaded crates / vehicles / troops).
-- CTLDPlayerManager: lifecycle (enter/leave unit), F10 menu orchestration,
--                    cargo state tracking via EventDispatcher subscriptions.
--
-- DCS events consumed (via CTLDDCSEventBridge):
--   S_EVENT_PLAYER_ENTER_UNIT → onPlayerEnterUnit(event)
--   S_EVENT_PLAYER_LEAVE_UNIT → onPlayerLeaveUnit(event)
--
-- CTLD events consumed (via EventDispatcher):
--   OnVehicleLoaded   { transportUnitObject, ctldVehicleObject } → add to loadedVehicles
--   OnVehicleUnloaded { transportUnitObject, ctldVehicleObject } → remove from loadedVehicles
--   OnCrateLoaded     { carrierUnitName, crate }                → add to loadedCrates
--
-- Events published: none.
--
-- Dependencies: class (lib/class.lua), CTLDUtils (ctld.utils),
--               CTLDConfig (ctld.gs), EventDispatcher, CTLDDCSEventBridge,
--               ctld.MenuManager (CTLD_menu.lua)
-- DCS API: unit:getName, unit:getGroup, unit:getTypeName, unit:getCoalition,
--          unit:getPlayerName, unit:isExist,
--          missionCommands.removeItemForGroup, trigger.action.outTextForGroup
-- ============================================================

ctld = ctld or {}

-- ============================================================
-- CTLDPlayer  (entity)
-- ============================================================

CTLDPlayer = class()

--- Constructor.
-- @param data table  Required fields:
--   unitName, groupId, groupName, coalition, typeName, isTransport, canCarryVehicles
function CTLDPlayer:init(data)
    self.unitName         = data.unitName
    self.groupId          = data.groupId
    self.groupName        = data.groupName
    self.coalition        = data.coalition
    self.typeName         = data.typeName
    self.isTransport      = data.isTransport      or false
    self.canCarryVehicles = data.canCarryVehicles  or false
    self.loadedTroops     = {}
    self.loadedCrates     = {}
    self.loadedVehicles   = {}
end

--- Append a CTLDVehicle to the loaded vehicles list.
-- @param ctldVehicleObject CTLDVehicle
function CTLDPlayer:addLoadedVehicle(ctldVehicleObject)
    table.insert(self.loadedVehicles, ctldVehicleObject)
end

--- Remove a CTLDVehicle from the loaded list (matched by object identity).
-- @param ctldVehicleObject CTLDVehicle
function CTLDPlayer:removeLoadedVehicle(ctldVehicleObject)
    for i, v in ipairs(self.loadedVehicles) do
        if v == ctldVehicleObject then
            table.remove(self.loadedVehicles, i)
            return
        end
    end
end

--- Append a CTLDCrate to the loaded crates list.
-- @param ctldCrateObject CTLDCrate
function CTLDPlayer:addLoadedCrate(ctldCrateObject)
    table.insert(self.loadedCrates, ctldCrateObject)
end

--- Remove a CTLDCrate from the loaded list (matched by object identity).
-- @param ctldCrateObject CTLDCrate
function CTLDPlayer:removeLoadedCrate(ctldCrateObject)
    for i, c in ipairs(self.loadedCrates) do
        if c == ctldCrateObject then
            table.remove(self.loadedCrates, i)
            return
        end
    end
end

-- ============================================================
-- CTLDPlayerManager  (singleton)
-- ============================================================

CTLDPlayerManager = class()
CTLDPlayerManager._instance = nil

--- Return (or create) the singleton instance.
function CTLDPlayerManager.getInstance()
    if not CTLDPlayerManager._instance then
        local o = setmetatable({}, CTLDPlayerManager)
        o:init()
        CTLDPlayerManager._instance = o
    end
    return CTLDPlayerManager._instance
end

function CTLDPlayerManager:init()
    self._players      = {}   -- unitName → CTLDPlayer
    self._menuSections = {}   -- ordered list of { key, manager, method, configKey, order }

    -- Register for DCS player slot events
    local bridge = CTLDDCSEventBridge.getInstance()
    bridge:register(self, world.event.S_EVENT_PLAYER_ENTER_UNIT, "onPlayerEnterUnit")
    bridge:register(self, world.event.S_EVENT_PLAYER_LEAVE_UNIT, "onPlayerLeaveUnit")

    -- Subscribe to CTLD cargo events to maintain per-player cargo state
    local ed = EventDispatcher.getInstance()

    ed:subscribe("OnVehicleLoaded", function(p)
        if not p or not p.transportUnitObject then return end
        local playerObj = self:getPlayer(p.transportUnitObject:getName())
        if not playerObj then return end
        if p.ctldVehicleObject then
            playerObj:addLoadedVehicle(p.ctldVehicleObject)
        end
        self:refreshForUnit(playerObj.unitName)
    end)

    ed:subscribe("OnVehicleUnloaded", function(p)
        if not p or not p.transportUnitObject then return end
        local playerObj = self:getPlayer(p.transportUnitObject:getName())
        if not playerObj then return end
        if p.ctldVehicleObject then
            playerObj:removeLoadedVehicle(p.ctldVehicleObject)
        end
        self:refreshForUnit(playerObj.unitName)
    end)

    ed:subscribe("OnCrateLoaded", function(p)
        if not p or not p.carrierUnitName then return end
        local playerObj = self:getPlayer(p.carrierUnitName)
        if not playerObj then return end
        if p.crate then playerObj:addLoadedCrate(p.crate) end
        self:refreshForUnit(playerObj.unitName)
        -- Crate is now inside the aircraft: remove it from the Unpack menu immediately
        CTLDCrateManager.getInstance():refreshUnpackSectionForUnit(p.carrierUnitName)
    end)

    -- When a FOB is deployed, refresh Request Equipment for all grounded players
    -- who may now be within the new FOB logistic zone.
    ed:subscribe("OnFOBDeployed", function(_p)
        local crateMgr = CTLDCrateManager.getInstance()
        local jtacMgr  = CTLDJTACManager.get()
        for _, playerObj in pairs(self._players) do
            local unit = Unit.getByName(playerObj.unitName)
            if unit and unit:isExist() and not ctld.utils.inAir(unit) then
                crateMgr:refreshRequestEquipmentSection(playerObj)
                jtacMgr:refreshJtacEquipmentSection(playerObj)
            end
        end
    end)

    ctld.utils.log("INFO", "CTLDPlayerManager: init complete")
end

--- Build menus for any players already occupying slots when CTLD loads.
-- Called once at init(); uses coalition.getPlayers() to enumerate connected players.
function CTLDPlayerManager:_scanExistingPlayers()
    local count = 0
    for _, side in ipairs({ coalition.side.RED, coalition.side.BLUE }) do
        local units = coalition.getPlayers(side) or {}
        for _, unit in ipairs(units) do
            if unit:isExist() and unit:getPlayerName() then
                local unitName = unit:getName()
                if not self._players[unitName] then
                    -- Simulate the enter-unit event
                    self:onPlayerEnterUnit({ initiator = unit })
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        ctld.utils.log("INFO", "CTLDPlayerManager: built menu for %d pre-existing player(s)", count)
    end
end

--- DCS S_EVENT_PLAYER_ENTER_UNIT handler.
-- Creates a CTLDPlayer and builds the F10 CTLD menu.
-- AI units (no playerName) are silently ignored.
-- @param event table  DCS event { initiator = Unit, ... }
function CTLDPlayerManager:onPlayerEnterUnit(event)
    local unit = event and event.initiator
    if not unit or not unit:isExist() then return end
    if not unit:getPlayerName() then return end   -- skip AI

    local unitName = unit:getName()
    local group    = unit:getGroup()
    if not group then
        ctld.utils.log("WARNING", "CTLDPlayerManager:onPlayerEnterUnit — no group for " .. unitName)
        return
    end

    local isTransport, canCarryVehicles = self:_detectCapabilities(unit)

    local playerObj = CTLDPlayer:new({
        unitName         = unitName,
        groupId          = group:getID(),
        groupName        = group:getName(),
        coalition        = unit:getCoalition(),
        typeName         = unit:getTypeName(),
        isTransport      = isTransport,
        canCarryVehicles = canCarryVehicles,
    })

    self._players[unitName] = playerObj
    self:buildMenu(playerObj)

    ctld.utils.log("INFO", string.format(
        "CTLDPlayerManager: enter unit=%s type=%s transport=%s vehicles=%s",
        unitName, playerObj.typeName,
        tostring(isTransport), tostring(canCarryVehicles)))
end

--- DCS S_EVENT_PLAYER_LEAVE_UNIT handler.
-- Removes the CTLDPlayer and wipes the F10 CTLD menu.
-- @param event table  DCS event { initiator = Unit, ... }
function CTLDPlayerManager:onPlayerLeaveUnit(event)
    local unit = event and event.initiator
    if not unit then return end
    local unitName  = unit:getName()
    local playerObj = self._players[unitName]
    if not playerObj then return end

    local mmgr     = ctld.MenuManager:getInstance()
    local menuData = mmgr.menus and mmgr.menus[playerObj.groupId]
    if menuData then
        for _, item in ipairs(menuData.children or {}) do
            missionCommands.removeItemForGroup(playerObj.groupId, { item.name })
        end
        mmgr.menus[playerObj.groupId] = nil
    end
    self._players[unitName] = nil

    ctld.utils.log("INFO", "CTLDPlayerManager: leave unit=" .. unitName)
end

--- DCS S_EVENT_LAND handler — rebuild troop menu section for landing unit.
-- Delayed 1 s: S_EVENT_LAND fires before the aircraft has fully settled,
-- so _isInAir() may still return true at the exact moment of the event.
function CTLDPlayerManager:onLand(event)
    local unit = event and event.initiator
    if not unit then return end
    local unitName  = unit:getName()
    local playerObj = self._players[unitName]
    if not playerObj then return end
    local captured = playerObj
    timer.scheduleFunction(function()
        CTLDTroopManager.getInstance():refreshMenuSection(captured)
        CTLDCrateManager.getInstance():refreshRequestEquipmentSection(captured)
        CTLDCrateManager.getInstance():refreshLoadCrateSection(captured)
        CTLDCrateManager.getInstance():refreshUnpackSection(captured)
        CTLDVehicleSpawner.getInstance():refreshPackSection(captured)
        CTLDJTACManager.get():refreshJtacEquipmentSection(captured)
    end, nil, timer.getTime() + 1)
end

--- DCS S_EVENT_TAKEOFF handler — rebuild troop menu section for departing unit.
function CTLDPlayerManager:onTakeoff(event)
    local unit = event and event.initiator
    if not unit then return end
    local playerObj = self._players[unit:getName()]
    if not playerObj then return end
    CTLDTroopManager.getInstance():refreshMenuSection(playerObj)
    CTLDCrateManager.getInstance():refreshRequestEquipmentSection(playerObj)
    CTLDJTACManager.get():refreshJtacEquipmentSection(playerObj)
end

--- Register a menu section contributed by a manager.
-- Called by each manager in its own init(), before any player enters a unit.
-- sectionDef = {
--   key       = string      unique identifier, e.g. "troops", "beacons"
--   manager   = object      manager instance
--   method    = string      method name: manager[method](manager, playerObj, menu)
--   configKey = string|nil  ctld.gs(configKey) must be true to activate; nil = always active
--   order     = number|nil  render position (ascending); nil = appended last
-- }
-- Idempotent: duplicate keys are silently ignored.
function CTLDPlayerManager:registerMenuSection(sectionDef)
    if not sectionDef or not sectionDef.key then return end
    for _, s in ipairs(self._menuSections) do
        if s.key == sectionDef.key then return end
    end
    table.insert(self._menuSections, sectionDef)
    ctld.utils.log("INFO", "CTLDPlayerManager: registered menu section '%s'", sectionDef.key)
end

--- Return the CTLDPlayer for unitName, or nil if not tracked.
-- @param unitName string
-- @return CTLDPlayer or nil
function CTLDPlayerManager:getPlayer(unitName)
    return self._players[unitName]
end

--- Build (or rebuild) the full F10 CTLD menu for a player.
-- Wipes and reconstructs atomically via ctld.MenuManager.
-- Sections are contributed by managers registered via registerMenuSection().
-- Each section is rendered only when its configKey (if any) resolves to true.
-- @param playerObj CTLDPlayer
function CTLDPlayerManager:buildMenu(playerObj)
    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:createMenuForGroup(playerObj.groupId)
    if not menu then
        ctld.utils.log("WARNING", "CTLDPlayerManager:buildMenu — cannot create menu for group "
            .. tostring(playerObj.groupId))
        return
    end

    -- Reset memory model before rebuilding so sections don't accumulate on successive calls.
    menu.children  = {}
    menu._lookup   = {}
    menu.nextItemId = 1

    local root     = ctld.tr("CTLD")
    local gid      = playerObj.groupId
    local unitName = playerObj.unitName

    -- Root submenu "CTLD" at F1 slot (order 10)
    menu:addSubMenu({}, root, { order = 10 })

    -- "Check Cargo" — queries crates and troops loaded on this transport
    menu:addCommand({ root }, ctld.tr("Check Cargo"),
        function()
            local transport = Unit.getByName(unitName)
            local lines     = {}
            local total     = 0

            -- Crates loaded on this transport — grouped by descriptor.desc
            -- Compare by unit name, not object identity (DCS userdata equality is unreliable)
            local crateMgr   = CTLDCrateManager.getInstance()
            local crateCount = {}   -- desc → { count, totalWeight }
            local crateOrder = {}   -- preserve insertion order for deterministic output
            for _, c in pairs(crateMgr.crates) do
                if c:isLoaded() and c.loadedBy and c.loadedBy:getName() == unitName then
                    local desc   = (c.descriptor and c.descriptor.desc) or "?"
                    local weight = (c.descriptor and c.descriptor.weight) or 0
                    if not crateCount[desc] then
                        crateCount[desc] = { count = 0, totalWeight = 0 }
                        table.insert(crateOrder, desc)
                    end
                    crateCount[desc].count       = crateCount[desc].count + 1
                    crateCount[desc].totalWeight = crateCount[desc].totalWeight + weight
                    total = total + weight
                end
            end
            for _, desc in ipairs(crateOrder) do
                local info = crateCount[desc]
                table.insert(lines,
                    ctld.tr("%1: %2 crate(s) onboard (%3 kg)", desc, info.count, info.totalWeight))
            end

            -- Troops loaded on this transport
            local troopMgr = CTLDTroopManager.getInstance()
            local tGroup   = troopMgr:getInTransit(unitName)
            if tGroup then
                table.insert(lines, ctld.tr("%1 troop(s) onboard (%2 kg)", tGroup.unitTotal, tGroup.weight))
                total = total + tGroup.weight
            end

            -- Whole vehicles loaded on this transport (GAP-1)
            if transport then
                local vehSpawner = CTLDVehicleSpawner.getInstance()
                local loadedVehs = vehSpawner:findLoadedVehicles(transport)
                local vehCount = {}
                local vehOrder = {}
                for _, v in ipairs(loadedVehs) do
                    local vt = v.vehicleType or "?"
                    if not vehCount[vt] then
                        vehCount[vt] = 0
                        table.insert(vehOrder, vt)
                    end
                    vehCount[vt] = vehCount[vt] + 1
                end
                local vWeights = ctld.gs("vehiclesWeight") or {}
                for _, vt in ipairs(vehOrder) do
                    local count = vehCount[vt]
                    local w     = (vWeights[vt] or 2500) * count
                    total = total + w
                    table.insert(lines, ctld.tr("%1: %2 vehicle(s) onboard", vt, count))
                end
            end

            local msg
            if #lines == 0 then
                msg = ctld.tr("No cargo on board.")
            else
                table.insert(lines, ctld.tr("Total cargo weight: %1 kg", total))
                msg = table.concat(lines, "\n")
            end
            trigger.action.outTextForGroup(gid, msg, 10)
        end, {})

    -- Registered sections sorted by order field
    local sorted = {}
    for _, s in ipairs(self._menuSections) do table.insert(sorted, s) end
    table.sort(sorted, function(a, b)
        return (a.order or math.huge) < (b.order or math.huge)
    end)

    for _, section in ipairs(sorted) do
        local active = true
        if section.configKey then
            active = ctld.gs(section.configKey) == true
        end
        if active then
            local fn = section.manager[section.method]
            if fn then
                fn(section.manager, playerObj, menu)
            else
                ctld.utils.log("WARN", "CTLDPlayerManager:buildMenu — section '%s' method '%s' not found",
                    section.key, tostring(section.method))
            end
        end
    end

    menu:refresh()
end

--- Refresh the F10 menu for a single player unit.
-- @param unitName string
function CTLDPlayerManager:refreshForUnit(unitName)
    local playerObj = self._players[unitName]
    if not playerObj then return end
    ctld.MenuManager:getInstance():refreshMenuForGroup(playerObj.groupId)
end

--- Refresh F10 menus for all currently tracked players.
function CTLDPlayerManager:refreshAll()
    for unitName in pairs(self._players) do
        self:refreshForUnit(unitName)
    end
end

-- ============================================================
-- Private helpers
-- ============================================================

--- Detect transport and vehicle-carry capabilities from a unit.
-- isTransport      : typeName has an entry in ctld.gs("unitActions") map.
-- canCarryVehicles : typeName matches (case-insensitive substring) an entry
--                   in the ctld.gs("vehicleTransportEnabled") list.
-- @param unit DCS Unit
-- @return isTransport bool, canCarryVehicles bool
function CTLDPlayerManager:_detectCapabilities(unit)
    local typeName    = unit:getTypeName()
    local typeLower   = string.lower(typeName)
    local unitActions = ctld.gs("unitActions") or {}
    local isTransport = (unitActions[typeName] ~= nil)

    local canCarryVehicles  = false
    local vehicleTransports = ctld.gs("vehicleTransportEnabled") or {}
    for _, name in ipairs(vehicleTransports) do
        if string.find(typeLower, string.lower(name), 1, true) then
            canCarryVehicles = true
            break
        end
    end

    return isTransport, canCarryVehicles
end

-- End : CTLD_player.lua
-- ====================================================================================================
-- Start : CTLD_core.lua
-- ============================================================
-- CTLD_core.lua
-- Core infrastructure: EventDispatcher, CTLDDCSEventBridge,
-- CTLDPlayerTracker, CTLDCoreManager
--
-- Dependencies : class (lib/class.lua), CTLDUtils (ctld.utils),
--                CTLDCrateManager, CTLDJTACManager
-- DCS API      : world.addEventHandler, coalition.getPlayers,
--                coalition.getStaticObjects, coalition.getGroups,
--                Object.getCategory, timer.scheduleFunction
--
-- Initialisation order (called by CTLD_userConfig or entry point):
--   1. CTLDDCSEventBridge.getInstance()   -- registers world.addEventHandler
--   2. CTLDPlayerTracker.getInstance()    -- subscribes to player events + scan
--   3. CTLDCoreManager.getInstance()      -- INIT-B (crates) + INIT-C (JTACs)
--   4. other managers as needed
-- ============================================================

---@diagnostic disable
ctld = ctld or {}


-- ============================================================
-- EventDispatcher  (singleton — CTLD internal pub/sub only)
-- ============================================================
-- Routes CTLD business events (OnCrateLoaded, OnTroopsDeployed, …).
-- DCS engine events NEVER pass through here; they go through CTLDDCSEventBridge.

EventDispatcher = class()
EventDispatcher._instance = nil

--- Return (or create) the singleton instance.
function EventDispatcher.getInstance()
    if not EventDispatcher._instance then
        local o = setmetatable({}, EventDispatcher)
        o:init()
        EventDispatcher._instance = o
    end
    return EventDispatcher._instance
end

function EventDispatcher:init()
    self._listeners = {}
end

--- Subscribe callback to a named CTLD event.
-- The same callback may be registered multiple times; each registration
-- produces one additional call on publish.  Callers are responsible for
-- avoiding duplicate subscriptions.
-- @param eventName  string
-- @param callback   function  receives the payload table
function EventDispatcher:subscribe(eventName, callback)
    if type(callback) ~= "function" then return end
    if not self._listeners[eventName] then
        self._listeners[eventName] = {}
    end
    table.insert(self._listeners[eventName], callback)
end

--- Unsubscribe a specific callback (last-registered occurrence removed first).
-- @param eventName string
-- @param callback  function  exact reference used at subscribe time
function EventDispatcher:unsubscribe(eventName, callback)
    local subs = self._listeners[eventName]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == callback then
            table.remove(subs, i)
            return
        end
    end
end

--- Remove all subscribers for an event (e.g. on module teardown).
-- @param eventName string
function EventDispatcher:unsubscribeAll(eventName)
    self._listeners[eventName] = nil
end

--- Publish a CTLD event.  Dispatch list is copied before iteration so that
-- a callback may safely subscribe/unsubscribe during dispatch.
-- @param eventName string
-- @param payload   table
function EventDispatcher:publish(eventName, payload)
    local subs = self._listeners[eventName]
    if not subs or #subs == 0 then return end
    local dispatch = {}
    for i = 1, #subs do dispatch[i] = subs[i] end
    for i = 1, #dispatch do
        local ok, err = pcall(dispatch[i], payload)
        if not ok then
            ctld.utils.log("ERROR",
                "EventDispatcher:publish [%s] callback error: %s", eventName, tostring(err))
        end
    end
end


-- ============================================================
-- CTLDDCSEventBridge  (singleton — single world.addEventHandler)
-- ============================================================
-- Receives all DCS engine events and routes them to registered managers.
-- Each manager registers via bridge:register(target, eventId, "methodName").
-- The bridge does NO filtering beyond event id — filtering is each manager's job.

CTLDDCSEventBridge = class()
CTLDDCSEventBridge._instance = nil

--- Return (or create) the singleton instance.
-- world.addEventHandler is called exactly once, at first getInstance().
function CTLDDCSEventBridge.getInstance()
    if not CTLDDCSEventBridge._instance then
        local o = setmetatable({}, CTLDDCSEventBridge)
        o:init()
        CTLDDCSEventBridge._instance = o
    end
    return CTLDDCSEventBridge._instance
end

function CTLDDCSEventBridge:init()
    self._handlers = {}   -- eventId (number) -> list of { target, method }
    world.addEventHandler(self)
    ctld.utils.log("INFO", "CTLDDCSEventBridge: world.addEventHandler registered")
end

--- Register a manager method to be called for a DCS event id.
-- @param target   object   manager instance (self receiver)
-- @param eventId  number   world.event.S_EVENT_* constant
-- @param method   string   method name on target
function CTLDDCSEventBridge:register(target, eventId, method)
    if not self._handlers[eventId] then
        self._handlers[eventId] = {}
    end
    table.insert(self._handlers[eventId], { target = target, method = method })
end

--- DCS engine callback — do NOT rename.
function CTLDDCSEventBridge:onEvent(event)
    local list = self._handlers[event.id]
    if not list then return end
    for _, entry in ipairs(list) do
        local ok, err = pcall(entry.target[entry.method], entry.target, event)
        if not ok then
            ctld.utils.log("ERROR",
                "CTLDDCSEventBridge:onEvent handler error [%s / eventId=%s]: %s",
                tostring(entry.method), tostring(event.id), tostring(err))
        end
    end
end


-- ============================================================
-- CTLDPlayerTracker  (singleton — human slot tracking, no MIST)
-- ============================================================
-- Maintains a double-index of connected human players:
--   _byUnit[unitName]     -> playerName
--   _byPlayer[playerName] -> { unitName, coalition }
--
-- Sources:
--   S_EVENT_PLAYER_ENTER_UNIT / LEAVE_UNIT  (primary, event-driven)
--   S_EVENT_BIRTH                           (backup for first joiner)
--   coalition.getPlayers() scan             (safety net during first 3 min)

CTLDPlayerTracker = class()
CTLDPlayerTracker._instance = nil

--- Return (or create) the singleton instance.
-- CTLDDCSEventBridge must be initialised before calling this.
function CTLDPlayerTracker.getInstance()
    if not CTLDPlayerTracker._instance then
        local o = setmetatable({}, CTLDPlayerTracker)
        o:init()
        CTLDPlayerTracker._instance = o
    end
    return CTLDPlayerTracker._instance
end

function CTLDPlayerTracker:init()
    self._byUnit   = {}   -- unitName   -> playerName
    self._byPlayer = {}   -- playerName -> { unitName, coalition }

    local bridge = CTLDDCSEventBridge.getInstance()
    bridge:register(self, world.event.S_EVENT_PLAYER_ENTER_UNIT, "onPlayerEnterUnit")
    bridge:register(self, world.event.S_EVENT_PLAYER_LEAVE_UNIT, "onPlayerLeaveUnit")
    bridge:register(self, world.event.S_EVENT_BIRTH,             "onBirth")

    -- Immediate scan: catch slots already occupied at init time
    self:_scanAllSlots()

    -- Repeated scans for 3 min to recover slots missed before bridge was ready
    -- (DCS may fire S_EVENT_BIRTH before world.addEventHandler is registered)
    local startTime = timer.getTime()
    local self_ref  = self
    local function securityScan()
        self_ref:_scanAllSlots()
        if timer.getTime() - startTime < 180 then
            return timer.getTime() + 30   -- reschedule every 30 s
        end
        -- After 3 min: event-driven tracking is sufficient
    end
    timer.scheduleFunction(securityScan, nil, timer.getTime() + 5)

    ctld.utils.log("INFO", "CTLDPlayerTracker: init complete")
end

-- DCS event handlers -------------------------------------------

function CTLDPlayerTracker:onPlayerEnterUnit(event)
    local unit = event.initiator
    if not unit then return end
    local playerName = unit:getPlayerName()
    if not playerName then return end
    local unitName = unit:getName()
    local coal     = unit:getCoalition()
    self._byUnit[unitName]     = playerName
    self._byPlayer[playerName] = { unitName = unitName, coalition = coal }
end

function CTLDPlayerTracker:onPlayerLeaveUnit(event)
    local unit = event.initiator
    if not unit then return end
    local unitName   = unit:getName()
    local playerName = self._byUnit[unitName]
    if playerName then
        self._byUnit[unitName]     = nil
        self._byPlayer[playerName] = nil
    end
end

--- Backup handler: catches first joiner if PLAYER_ENTER_UNIT was missed.
function CTLDPlayerTracker:onBirth(event)
    local unit = event.initiator
    if not (unit and unit.getPlayerName) then return end
    local playerName = unit:getPlayerName()
    if not playerName then return end
    local unitName = unit:getName()
    if self._byUnit[unitName] then return end   -- already tracked
    local coal = unit:getCoalition()
    self._byUnit[unitName]     = playerName
    self._byPlayer[playerName] = { unitName = unitName, coalition = coal }
end

-- Internal scan ----------------------------------------------------

--- Active scan via coalition.getPlayers() — idempotent, adds missing entries only.
function CTLDPlayerTracker:_scanAllSlots()
    for _, side in ipairs({ coalition.side.RED, coalition.side.BLUE }) do
        local units = coalition.getPlayers(side) or {}
        for _, unit in ipairs(units) do
            local playerName = unit:getPlayerName()
            if playerName then
                local unitName = unit:getName()
                if not self._byUnit[unitName] then
                    local coal = unit:getCoalition()
                    self._byUnit[unitName]     = playerName
                    self._byPlayer[playerName] = { unitName = unitName, coalition = coal }
                end
            end
        end
    end
end

-- Public API -------------------------------------------------------

--- Return the playerName occupying unitName, or nil if AI/unoccupied.
-- @param unitName string
-- @return string or nil
function CTLDPlayerTracker:getPlayerByUnit(unitName)
    return self._byUnit[unitName]
end

--- Return { unitName, coalition } for playerName, or nil if not connected.
-- @param playerName string
-- @return table or nil
function CTLDPlayerTracker:getUnitByPlayer(playerName)
    return self._byPlayer[playerName]
end

--- Return all connected players as a list of { playerName, unitName, coalition }.
-- @return table
function CTLDPlayerTracker:getAllPlayers()
    local result = {}
    for playerName, data in pairs(self._byPlayer) do
        result[#result + 1] = {
            playerName = playerName,
            unitName   = data.unitName,
            coalition  = data.coalition,
        }
    end
    return result
end

--- Return true if unitName is currently occupied by a human player.
-- @param unitName string
-- @return boolean
function CTLDPlayerTracker:isPlayerUnit(unitName)
    return self._byUnit[unitName] ~= nil
end


-- ============================================================
-- CTLDCoreManager  (singleton — startup orchestrator)
-- ============================================================
-- Runs INIT-B (MM crates), INIT-C (MM JTACs) and INIT-D (MM vehicles) at startup.
-- Registers late-activation handlers for crates, JTACs and vehicles in the bridge.
--
-- INIT-A (AI transports) is deferred to CTLDTransportManager (not yet implemented).

CTLDCoreManager = class()
CTLDCoreManager._instance = nil

--- Return (or create) the singleton instance.
-- CTLDDCSEventBridge, CTLDPlayerTracker, CTLDCrateManager and CTLDJTACManager
-- must all be available before calling this.
function CTLDCoreManager.getInstance()
    if not CTLDCoreManager._instance then
        local o = setmetatable({}, CTLDCoreManager)
        o:init()
        CTLDCoreManager._instance = o
    end
    return CTLDCoreManager._instance
end

function CTLDCoreManager:init()
    local bridge = CTLDDCSEventBridge.getInstance()

    -- Register late-activation handlers
    bridge:register(CTLDCrateManager.getInstance(),    world.event.S_EVENT_BIRTH, "onBirth")
    bridge:register(CTLDJTACManager.get(),             world.event.S_EVENT_BIRTH, "onBirth")
    bridge:register(CTLDVehicleSpawner.getInstance(),  world.event.S_EVENT_BIRTH, "onBirth")

    -- Register land/takeoff for dynamic troop menu rebuild
    bridge:register(CTLDPlayerManager.getInstance(), world.event.S_EVENT_LAND,    "onLand")
    bridge:register(CTLDPlayerManager.getInstance(), world.event.S_EVENT_TAKEOFF, "onTakeoff")

    -- Troop unit death: keep _aliveUnits / _jtacUnits in sync with DCS reality
    local okTM, tm = pcall(CTLDTroopManager.getInstance)
    if okTM then
        bridge:register(tm, world.event.S_EVENT_DEAD, "onUnitDead")
        ctld.utils.log("INFO", "CTLDCoreManager: CTLDTroopManager S_EVENT_DEAD bridge registered")
    end

    -- INIT-B: detect cargo statics placed by the mission maker
    self:_initMMCrates()

    -- INIT-C: detect JTAC groups pre-placed by the mission maker
    self:_initMMJTACs()

    -- INIT-D: detect ground vehicles placed by the mission maker
    CTLDVehicleSpawner.getInstance():scanMMVehicles()

    -- INIT-A: detect AI transport units (TODO — requires CTLDTransportManager)
    -- self:_initAITransports()

    ctld.utils.log("INFO", "CTLDCoreManager: init complete (INIT-B + INIT-C + INIT-D)")
end

-- INIT-B -----------------------------------------------------------

--- Scan all coalition statics for cargo objects placed by the mission maker.
-- Delegates to CTLDCrateManager:registerMMCrate() for each detected cargo.
-- API note: coalition.getStaticObjects() may return destroyed objects (DCS bug)
--           → filtered by isExist().  Object.getCategory() == 6 == CARGO.
function CTLDCoreManager:_initMMCrates()
    local sides = { coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL }
    local count = 0
    for _, side in ipairs(sides) do
        local statics = coalition.getStaticObjects(side) or {}
        for _, obj in ipairs(statics) do
            if obj:isExist() and Object.getCategory(obj) == 6 then
                local desc = obj:getDesc()
                if desc and desc.attributes and desc.attributes.Cargos == true then
                    CTLDCrateManager.getInstance():registerMMCrate(obj, desc)
                    count = count + 1
                end
            end
        end
    end
    ctld.utils.log("INFO", "CTLDCoreManager: INIT-B complete — %d MM crate(s) detected", count)
end

-- INIT-C -----------------------------------------------------------

--- Scan all coalition ground groups for JTAC groups pre-placed by the mission maker.
-- Delegates to CTLDJTACManager for active groups; marks late-activation groups pending.
-- API note: coalition.getGroups() may return destroyed groups (DCS bug)
--           → filtered by isExist().  Only RED and BLUE (no NEUTRAL support).
function CTLDCoreManager:_initMMJTACs()
    local sides = { coalition.side.RED, coalition.side.BLUE }
    local count = 0
    for _, side in ipairs(sides) do
        local groups = coalition.getGroups(side) or {}
        for _, group in ipairs(groups) do
            if group:isExist() and self:_isJTACGroup(group) then
                -- isActive() only exists on ME-placed groups; dynamically spawned groups (coalition.addGroup)
                -- do not have this method → guard with pcall, default to true (already active).
                local ok, isAct = pcall(function() return group:isActive() end)
                if not ok then isAct = true end
                if isAct then
                    CTLDJTACManager.get():registerMMJTAC(group)
                else
                    -- Late activation: will be picked up by onBirth handler
                    CTLDJTACManager.get():markPendingJTAC(group:getName())
                end
                count = count + 1
            end
        end
    end
    ctld.utils.log("INFO", "CTLDCoreManager: INIT-C complete — %d MM JTAC group(s) detected", count)
end

--- Return true if group should be managed as a JTAC by CTLD.
-- Detection rule (new OOP system — no separate jtacUnitTypes table):
--   Group name contains "jtac" (case-insensitive).
-- Convention: MM must name JTAC groups with "jtac" in the name
--   (e.g. "jtac_blue_1", "JTAC_Red_Drone").
-- @param group Group  DCS group object
-- @return boolean
function CTLDCoreManager:_isJTACGroup(group)
    return group:getName():lower():find("jtac") ~= nil
end

-- End : CTLD_core.lua
-- ====================================================================================================
-- Start : scenes/CTLD_farpScene.lua
---@diagnostic disable
-- CTLD_farpScene.lua
-- FARP deployment scene — spawns a functional Forward Arming and Refueling Point.
--
-- Reference point: 50 m at 12 o'clock from the trigger unit (prescript step 0).
-- All subsequent object offsets are relative to that reference point.
--
-- Objects registered (all in CTLDObjectRegistry):
--   SINGLE_HELIPAD    — landing pad (logistic zone anchor)     at ref point
--   FARP_Tent         — crew tent                              30 m / 90°
--   FARP_Ammo_Storage — ammunition dump                        30 m / 135°
--   Windsock          — wind indicator / logistic unit marker  15 m / 270°
--   Fuel_Truck        — coalition-aware fuel truck             35 m / 225°
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager, CTLDUtils
-- ====================================================================================================

local farpScene = {}
farpScene.name = "farpScene"

farpScene.steps = {

    -- ----------------------------------------------------------------
    -- Step 0: prescript — move reference point 50 m ahead of the heli.
    -- All subsequent polar offsets are relative to this new origin.
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            local hdg = ctld.utils.getHeadingInRadians("farpScene.prescript", ctx.unit, true)
            local pt  = ctx.unit:getPoint()
            local fx  = pt.x + math.cos(hdg) * 50
            local fz  = pt.z + math.sin(hdg) * 50
            ctx.scene._refX   = fx
            ctx.scene._refZ   = fz
            ctx.scene._refAlt = land.getHeight({ x = fx, y = fz })
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 1: FARP helipad — at the reference point.
    -- ----------------------------------------------------------------
    {
        registryKey              = "SINGLE_HELIPAD",
        polar                    = { distance = 0, angle = 0 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 2: Command tent — 30 m right of helipad.
    -- ----------------------------------------------------------------
    {
        registryKey              = "FARP_Tent",
        polar                    = { distance = 30, angle = 90 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 3: Ammo storage — 30 m at 135° from helipad.
    -- ----------------------------------------------------------------
    {
        registryKey              = "FARP_Ammo_Storage",
        polar                    = { distance = 30, angle = 135 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 4: Windsock — 15 m left of helipad.
    -- ----------------------------------------------------------------
    {
        registryKey              = "Windsock",
        polar                    = { distance = 15, angle = 270 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 5: Fuel truck — 35 m at 225° from helipad.
    -- ----------------------------------------------------------------
    {
        registryKey              = "Fuel_Truck",
        polar                    = { distance = 35, angle = 225 },
        delayAfterPreviousStep   = 1,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },
}

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(farpScene)

-- End : scenes/CTLD_farpScene.lua
-- ====================================================================================================
-- Start : scenes/CTLD_fobScene.lua
---@diagnostic disable
-- ============================================================
-- CTLD_fobScene.lua
-- FOB deployment scene — spawns an outpost container + watchtower.
--
-- Spawn position:
--   Step 0 (prescript): if ctx.scene._params.centroid is provided, use it
--   as the reference point (pre-computed by CTLDFOBManager at build start,
--   100 m at 12 o'clock from the transport).  Otherwise compute it live from
--   the trigger unit (fallback for ad-hoc calls).
--
-- Steps:
--   0 — prescript: override scene reference point (func-only, no delay)
--   1 — FOB_container  at polar(0, 0°)  relative to reference point
--   2 — FOB_watchtower at polar(39, 158°) relative to reference point
--   3 — completion message (func-only)
--
-- ctx.scene._params expected keys (all optional):
--   centroid   vec3   pre-computed spawn position (set by CTLDFOBManager)
--   player     string display name in the completion message
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager, CTLDUtils
-- DCS API: land.getHeight, trigger.action.outTextForCoalition
-- ============================================================

local fobScene = {}
fobScene.name = "fobScene"

fobScene.steps = {

    -- ----------------------------------------------------------------
    -- Step 0: prescript — override reference point.
    -- Uses params.centroid when set; otherwise computes 100 m ahead.
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            local centroid = ctx.scene._params and ctx.scene._params.centroid
            if centroid then
                ctx.scene._refX   = centroid.x
                ctx.scene._refZ   = centroid.z
                ctx.scene._refAlt = centroid.y
            else
                -- Fallback: compute 100 m at 12 o'clock from the trigger unit.
                local pt  = ctx.unit:getPoint()
                local hdg = ctld.utils.getHeadingInRadians("fobScene.prescript", ctx.unit, true)
                local fx  = pt.x + math.cos(hdg) * 100
                local fz  = pt.z + math.sin(hdg) * 100
                ctx.scene._refX   = fx
                ctx.scene._refZ   = fz
                ctx.scene._refAlt = land.getHeight({ x = fx, y = fz })
            end
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 1: FOB outpost container (STATIC) — at reference point.
    -- ----------------------------------------------------------------
    {
        registryKey              = "FOB_container",
        polar                    = { distance = 0, angle = 0 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 2: Watchtower (STATIC) — ~39 m at 158° from reference.
    -- Reproduces the legacy offset: x+14.86 m, z-36.57 m (polar approx).
    -- ----------------------------------------------------------------
    {
        registryKey              = "FOB_watchtower",
        polar                    = { distance = 39, angle = 158 },
        delayAfterPreviousStep   = 2,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
    },

    -- ----------------------------------------------------------------
    -- Step 3: Completion message (func-only).
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            local player = (ctx.scene._params and ctx.scene._params.player)
                           or ctx.unit:getName()
            trigger.action.outTextForCoalition(
                ctx.scene._coalitionId,
                ctld.tr("FOB established by %1 - logistics hub now active.", player),
                10)
        end,
    },
}

-- ============================================================
-- Self-registration
-- ============================================================

CTLDSceneManager.getInstance():registerSceneModel(fobScene)

-- End : scenes/CTLD_fobScene.lua
-- ====================================================================================================
-- Start : scenes/CTLD_mineFieldScene.lua
---@diagnostic disable
-- CTLD_mineFieldScene.lua
-- Minefield scene model — migrated from source_scene_ini/mineFieldSceneDatas.lua.
--
-- Changes vs. original:
--   - mist.dynAddStatic()        → CTLDObjectRegistry.spawnObject("Landmine", ...)
--   - coalitionId undefined bug  → triggerUnitObj:getCoalition()
--   - _spawnedGroup global leak  → local variable
--   - func step signature updated to (triggerUnitObj, spawnedObj, step)
--   - Registration: CTLDSceneManager.getInstance():registerSceneModel(...)
--   - Layout: quinconce (staggered) pattern — odd rows N mines, even rows N-1 mines offset cs/2
--
-- Dependencies: CTLDUtils, CTLDObjectRegistry, CTLDSceneManager
-- DCS API: trigger.action.outText
-- ====================================================================================================

local mineFieldScene = {}
mineFieldScene.name = "mineField"

mineFieldScene.stepsDatas = {
    -- Step 1: deploy minefield (func-only — positions computed inside)
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            local success, result = mineFieldScene.setLandMine(ctx.unit, 20, 5, 15, 6, 12)
            if trigger and trigger.action and trigger.action.outText then
                trigger.action.outText(
                    ctld.tr("--- mineField Deployed by %1 ---", ctx.unit:getName()), 10)
            end
            return success, result
        end,
    },
}

-- ====================================================================================================
-- mineFieldScene.setLandMine
-- Computes a quinconce (staggered) grid of landmine positions relative to triggerUnitObj
-- and spawns them.
--
-- Layout (nbMinesColumns >= 2):
--   odd rows  : N mines,   centered
--   even rows : N-1 mines, shifted laterally by colSpacing/2
--
-- Special cases:
--   nbMines == 1                  → single mine, diamond F10 marker
--   nbMinesColumns < 2            → straight forward column, no stagger
--
-- @param triggerUnitObj                   DCS Unit object
-- @param distanceOf1stMineFromHeliInMeter number  distance from unit to first row (metres)
-- @param nbMinesColumns                   number  mines per odd (full) row
-- @param nbMinesPerColumns                number  total number of rows
-- @param distanceBetweenColumnsInMeters   number  lateral spacing between adjacent mines (metres)
-- @param distanceBetweenLinesInMeters     number  forward spacing between rows (metres)
-- @return boolean, table|string  success flag + spawned object array or error message
-- ====================================================================================================
function mineFieldScene.setLandMine(triggerUnitObj, distanceOf1stMineFromHeliInMeter, nbMinesColumns, nbMinesPerColumns,
                                    distanceBetweenColumnsInMeters, distanceBetweenLinesInMeters)
    if not triggerUnitObj then
        return false, "ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0"
    end

    local triggerUnitPosition     = triggerUnitObj:getPosition()
    local triggerUnitHeadingInRad = ctld.utils.getHeadingInRadians(
                                        "mineFieldScene.setLandMine", triggerUnitObj, true)
    local coalitionId             = triggerUnitObj:getCoalition()
    local countryId               = triggerUnitObj:getCountry()

    local nbMines     = nbMinesColumns * nbMinesPerColumns
    local spawnedObjs = {}

    if nbMines <= 0 then
        return false, "ERROR mineFieldScene.setLandMine(): no triggerUnitObj or nbLines <= 0"
    end

    distanceBetweenLinesInMeters = distanceBetweenLinesInMeters or 12

    local vec3Points1To4 = {}
    local unitVec2       = { x = triggerUnitPosition.p.x, y = triggerUnitPosition.p.z }

    -- Spawn a single mine at a Vec2 position {x, y}
    local function spawnAt(pos)
        local obj = CTLDObjectRegistry.spawnObject(
            "Landmine", coalitionId, countryId,
            pos.x, pos.y, 0, nil)
        if obj then
            spawnedObjs[#spawnedObjs + 1] = obj
        end
    end

    if nbMines == 1 then
        -- ----------------------------------------------------------------
        -- Single mine — diamond F10 marker
        -- ----------------------------------------------------------------
        local pt = ctld.utils.GetRelativeVec2Coords(
            unitVec2, triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)
        spawnAt(pt)
        -- Square aligned with aircraft heading (3m half-side)
        local half = 3
        local fwd  = ctld.utils.GetRelativeVec2Coords(pt, triggerUnitHeadingInRad,  half,  0)
        local bwd  = ctld.utils.GetRelativeVec2Coords(pt, triggerUnitHeadingInRad, -half,  0)
        local tl   = ctld.utils.GetRelativeVec2Coords(fwd, triggerUnitHeadingInRad, -half, 90)
        local tr   = ctld.utils.GetRelativeVec2Coords(fwd, triggerUnitHeadingInRad,  half, 90)
        local br   = ctld.utils.GetRelativeVec2Coords(bwd, triggerUnitHeadingInRad,  half, 90)
        local bl   = ctld.utils.GetRelativeVec2Coords(bwd, triggerUnitHeadingInRad, -half, 90)
        vec3Points1To4[1] = { x = tl.x, y = 0, z = tl.y }
        vec3Points1To4[2] = { x = tr.x, y = 0, z = tr.y }
        vec3Points1To4[3] = { x = br.x, y = 0, z = br.y }
        vec3Points1To4[4] = { x = bl.x, y = 0, z = bl.y }

    elseif nbMinesColumns < 2 then
        -- ----------------------------------------------------------------
        -- Single column: straight forward line, no stagger
        -- ----------------------------------------------------------------
        local refPoint = ctld.utils.GetRelativeVec2Coords(
            unitVec2, triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)
        for r = 1, nbMinesPerColumns do
            local pos = ctld.utils.GetRelativeVec2Coords(
                refPoint, triggerUnitHeadingInRad,
                (r - 1) * distanceBetweenLinesInMeters, 0)
            spawnAt(pos)
        end
        local lastPos = ctld.utils.GetRelativeVec2Coords(
            refPoint, triggerUnitHeadingInRad,
            (nbMinesPerColumns - 1) * distanceBetweenLinesInMeters, 0)
        vec3Points1To4[1] = { x = refPoint.x - 3, y = 0, z = refPoint.y }
        vec3Points1To4[2] = { x = refPoint.x + 3, y = 0, z = refPoint.y }
        vec3Points1To4[3] = { x = lastPos.x  + 3, y = 0, z = lastPos.y  }
        vec3Points1To4[4] = { x = lastPos.x  - 3, y = 0, z = lastPos.y  }

    else
        -- ----------------------------------------------------------------
        -- Quinconce (staggered) layout — nbMinesColumns >= 2
        --   odd rows  (r=1,3,...) : N mines,   leftmost at -halfWidth
        --   even rows (r=2,4,...) : N-1 mines, leftmost at -halfWidth + cs/2
        -- ----------------------------------------------------------------
        local refPoint  = ctld.utils.GetRelativeVec2Coords(
            unitVec2, triggerUnitHeadingInRad,
            distanceOf1stMineFromHeliInMeter, 0)
        local halfWidth = ((nbMinesColumns - 1) / 2) * distanceBetweenColumnsInMeters

        for r = 1, nbMinesPerColumns do
            local rowCenter = ctld.utils.GetRelativeVec2Coords(
                refPoint, triggerUnitHeadingInRad,
                (r - 1) * distanceBetweenLinesInMeters, 0)

            local minesInRow, leftmostLateral
            if r % 2 == 1 then
                -- Odd row: full width
                minesInRow      = nbMinesColumns
                leftmostLateral = -halfWidth
            else
                -- Even row: one mine less, shifted right by cs/2
                minesInRow      = nbMinesColumns - 1
                leftmostLateral = -halfWidth + distanceBetweenColumnsInMeters / 2
            end

            for col = 1, minesInRow do
                local lateralOffset = leftmostLateral + (col - 1) * distanceBetweenColumnsInMeters
                local pos = ctld.utils.GetRelativeVec2Coords(
                    rowCenter, triggerUnitHeadingInRad, lateralOffset, 90)
                spawnAt(pos)
            end
        end

        -- Bounding rectangle corners (based on full-row lateral extent)
        local lastRowCenter = ctld.utils.GetRelativeVec2Coords(
            refPoint, triggerUnitHeadingInRad,
            (nbMinesPerColumns - 1) * distanceBetweenLinesInMeters, 0)
        local tl = ctld.utils.GetRelativeVec2Coords(refPoint,      triggerUnitHeadingInRad, -halfWidth, 90)
        local tr = ctld.utils.GetRelativeVec2Coords(refPoint,      triggerUnitHeadingInRad,  halfWidth, 90)
        local br = ctld.utils.GetRelativeVec2Coords(lastRowCenter, triggerUnitHeadingInRad,  halfWidth, 90)
        local bl = ctld.utils.GetRelativeVec2Coords(lastRowCenter, triggerUnitHeadingInRad, -halfWidth, 90)
        vec3Points1To4[1] = { x = tl.x, y = 0, z = tl.y }
        vec3Points1To4[2] = { x = tr.x, y = 0, z = tr.y }
        vec3Points1To4[3] = { x = br.x, y = 0, z = br.y }
        vec3Points1To4[4] = { x = bl.x, y = 0, z = bl.y }
    end

    -- Draw bounding quadrilateral on the F10 map (unless disabled in config)
    local lastSpawned = spawnedObjs[#spawnedObjs]
    if lastSpawned and ctld.gs("showMinefieldOnF10Map") ~= false then
        ctld.utils.drawQuad(coalitionId, vec3Points1To4, lastSpawned:getName())
    end

    return true, spawnedObjs
end

-- ====================================================================================================
-- mineFieldScene.setLandMineAuto
-- Parametric minefield: derives column count and row count automatically from a target area
-- (width × length in metres) and a desired total mine count, then delegates to setLandMine.
--
-- The layout is always quinconce (staggered rows):
--   odd rows  : N mines
--   even rows : N-1 mines, laterally offset by colSpacing/2
-- Total for N cols and R rows: T(N,R) = R*N - floor(R/2)
--
-- The algorithm finds the (N, R) pair whose T(N,R) is closest to nbMines while respecting
-- the requested aspect ratio (width/length).  Column and line spacings are derived from the
-- dimensions: cs = width/(N-1),  ls = length/(R-1).
--
-- @param triggerUnitObj  DCS Unit object — defines origin and heading
-- @param distFromUnit    number  forward distance (m) from unit to first mine row
-- @param widthMeters     number  lateral extent of the minefield (m)
-- @param lengthMeters    number  forward extent of the minefield (m)
-- @param nbMines         number  desired number of mines
-- @return boolean, table|string  success flag + spawned object array or error message
--
-- Example (MM usage):
--   local ok, result = mineFieldScene.setLandMineAuto(transport, 30, 50, 80, 40)
--   -- lays ~40 mines in a 50 m wide × 80 m long staggered field starting 30 m ahead
-- ====================================================================================================
function mineFieldScene.setLandMineAuto(triggerUnitObj, distFromUnit, widthMeters, lengthMeters, nbMines)
    if not triggerUnitObj then
        return false, "ERROR mineFieldScene.setLandMineAuto(): triggerUnitObj is nil"
    end
    if not nbMines or nbMines < 1 then
        return false, "ERROR mineFieldScene.setLandMineAuto(): nbMines must be >= 1"
    end
    if not widthMeters or widthMeters <= 0 or not lengthMeters or lengthMeters <= 0 then
        return false, "ERROR mineFieldScene.setLandMineAuto(): widthMeters and lengthMeters must be > 0"
    end

    -- Single mine: bypass layout computation
    if nbMines == 1 then
        return mineFieldScene.setLandMine(triggerUnitObj, distFromUnit, 1, 1, widthMeters, lengthMeters)
    end

    -- T(N,R) = R*N - floor(R/2)  →  R ≈ nbMines / (N - 0.5)
    local function countForNR(N, R)
        return R * N - math.floor(R / 2)
    end

    -- Estimate N from aspect ratio; clamp to [2, 50]
    local N0 = math.max(2, math.min(50, math.floor(math.sqrt(nbMines * widthMeters / lengthMeters) + 0.5)))

    local bestN, bestR, bestDiff = N0, 1, math.huge
    for _, N in ipairs({ N0 - 1, N0, N0 + 1 }) do
        if N >= 2 then
            local R = math.max(1, math.min(200, math.floor(nbMines / (N - 0.5) + 0.5)))
            for _, Rc in ipairs({ R - 1, R, R + 1 }) do
                if Rc >= 1 then
                    local diff = math.abs(countForNR(N, Rc) - nbMines)
                    if diff < bestDiff then
                        bestDiff, bestN, bestR = diff, N, Rc
                    end
                end
            end
        end
    end

    local cs = widthMeters  / (bestN - 1)
    local ls = lengthMeters / math.max(1, bestR - 1)

    return mineFieldScene.setLandMine(triggerUnitObj, distFromUnit, bestN, bestR, cs, ls)
end

-- ====================================================================================================
-- Self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(mineFieldScene)

-- End : scenes/CTLD_mineFieldScene.lua
-- ====================================================================================================
-- Start : compat/legacy_api.lua
-- ============================================================
-- src/compat/legacy_api.lua
-- Legacy API compatibility wrappers — CTLD v1 → v2
--
-- Provides the original ctld.* function signatures used in
-- mission DO SCRIPT triggers, forwarding each call to the
-- corresponding v2 manager with a deprecation warning.
--
-- Deprecation warnings are logged at WARNING level so they
-- appear in both DCS.log and ctld.log (if enabled).
--
-- NOTE: ctld.spawnCrateAtZone / ctld.spawnCrateAtPoint delegate
-- to CTLDCrateManager:spawnCrate() (implemented, uses ctld.utils.dynAddStatic).
--
-- NOTE: ctld.addCallback() is not wrapped — use
-- EventDispatcher:subscribe(eventName, handler) instead.
-- See documentation/migration-v2.md for the full migration guide.
--
-- Load order: after all managers (last in listToMerge.txt,
-- before CTLD_userConfig.lua).
-- ============================================================

---@diagnostic disable
ctld = ctld or {}

-- ============================================================
-- Troops / Transport
-- ============================================================

--- @deprecated Use CTLDTroopManager:spawnGroupAtTrigger()
function ctld.spawnGroupAtTrigger(_groupSide, _number, _triggerName, _searchRadius)
    ctld.logWarning("DEPRECATED: ctld.spawnGroupAtTrigger — use CTLDTroopManager:spawnGroupAtTrigger()")
    CTLDTroopManager.getInstance():spawnGroupAtTrigger(_groupSide, _number, _triggerName, _searchRadius)
end

--- @deprecated Use CTLDTroopManager:spawnGroupAtPoint()
function ctld.spawnGroupAtPoint(_groupSide, _number, _point, _searchRadius)
    ctld.logWarning("DEPRECATED: ctld.spawnGroupAtPoint — use CTLDTroopManager:spawnGroupAtPoint()")
    CTLDTroopManager.getInstance():spawnGroupAtPoint(_groupSide, _number, _point, _searchRadius)
end

--- @deprecated Use CTLDTroopManager:preLoadTransport()
function ctld.preLoadTransport(_unitName, _number, _troops)
    ctld.logWarning("DEPRECATED: ctld.preLoadTransport — use CTLDTroopManager:preLoadTransport()")
    CTLDTroopManager.getInstance():preLoadTransport(_unitName, _number, _troops)
end

--- @deprecated Use CTLDTroopManager:unloadTransport()
function ctld.unloadTransport(_unitName)
    ctld.logWarning("DEPRECATED: ctld.unloadTransport — use CTLDTroopManager:unloadTransport()")
    CTLDTroopManager.getInstance():unloadTransport(_unitName)
end

--- @deprecated Use CTLDTroopManager:loadTransport()
function ctld.loadTransport(_unitName)
    ctld.logWarning("DEPRECATED: ctld.loadTransport — use CTLDTroopManager:loadTransport()")
    CTLDTroopManager.getInstance():loadTransport(_unitName)
end

--- @deprecated Use CTLDTroopManager:unloadInProximityToEnemy()
function ctld.unloadInProximityToEnemy(_unitName, _distance)
    ctld.logWarning("DEPRECATED: ctld.unloadInProximityToEnemy — use CTLDTroopManager:unloadInProximityToEnemy()")
    return CTLDTroopManager.getInstance():unloadInProximityToEnemy(_unitName, _distance)
end

-- ============================================================
-- Zones
-- ============================================================

--- @deprecated Use CTLDZoneManager:setTroopZoneActive()
function ctld.activatePickupZone(_zoneName)
    ctld.logWarning("DEPRECATED: ctld.activatePickupZone — use CTLDZoneManager:setTroopZoneActive(name, true)")
    CTLDZoneManager.getInstance():setTroopZoneActive(_zoneName, true)
end

--- @deprecated Use CTLDZoneManager:setTroopZoneActive()
function ctld.deactivatePickupZone(_zoneName)
    ctld.logWarning("DEPRECATED: ctld.deactivatePickupZone — use CTLDZoneManager:setTroopZoneActive(name, false)")
    CTLDZoneManager.getInstance():setTroopZoneActive(_zoneName, false)
end

--- @deprecated Use CTLDZoneManager:changeRemainingGroups()
function ctld.changeRemainingGroupsForPickupZone(_zoneName, _amount)
    ctld.logWarning("DEPRECATED: ctld.changeRemainingGroupsForPickupZone — use CTLDZoneManager:changeRemainingGroups()")
    CTLDZoneManager.getInstance():changeRemainingGroups(_zoneName, _amount)
end

--- @deprecated Use CTLDZoneManager:activateWaypointZone()
function ctld.activateWaypointZone(_zoneName)
    ctld.logWarning("DEPRECATED: ctld.activateWaypointZone — use CTLDZoneManager:activateWaypointZone()")
    CTLDZoneManager.getInstance():activateWaypointZone(_zoneName)
end

--- @deprecated Use CTLDZoneManager:deactivateWaypointZone()
function ctld.deactivateWaypointZone(_zoneName)
    ctld.logWarning("DEPRECATED: ctld.deactivateWaypointZone — use CTLDZoneManager:deactivateWaypointZone()")
    CTLDZoneManager.getInstance():deactivateWaypointZone(_zoneName)
end

--- @deprecated Use CTLDZoneManager:createExtractZone()
function ctld.createExtractZone(_zone, _flagNumber, _smoke)
    ctld.logWarning("DEPRECATED: ctld.createExtractZone — use CTLDZoneManager:createExtractZone()")
    CTLDZoneManager.getInstance():createExtractZone(_zone, _flagNumber, _smoke)
end

--- @deprecated Use CTLDZoneManager:removeExtractZone()
function ctld.removeExtractZone(_zone, _flagNumber)
    ctld.logWarning("DEPRECATED: ctld.removeExtractZone — use CTLDZoneManager:removeExtractZone()")
    CTLDZoneManager.getInstance():removeExtractZone(_zone, _flagNumber)
end

--- @deprecated Use CTLDTroopManager:startGroupCountWatcher()
function ctld.countDroppedGroupsInZone(_zone, _blueFlag, _redFlag)
    ctld.logWarning("DEPRECATED: ctld.countDroppedGroupsInZone — use CTLDTroopManager:startGroupCountWatcher()")
    CTLDTroopManager.getInstance():startGroupCountWatcher(_zone, _blueFlag, _redFlag)
end

--- @deprecated Use CTLDTroopManager:startUnitCountWatcher()
function ctld.countDroppedUnitsInZone(_zone, _blueFlag, _redFlag)
    ctld.logWarning("DEPRECATED: ctld.countDroppedUnitsInZone — use CTLDTroopManager:startUnitCountWatcher()")
    CTLDTroopManager.getInstance():startUnitCountWatcher(_zone, _blueFlag, _redFlag)
end

-- ============================================================
-- Crates
-- ============================================================

--- @deprecated Use CTLDCrateManager:spawnCrateAtZone()
-- NOTE: non-functional until CTLDCrateManager:spawnCrate() is implemented.
function ctld.spawnCrateAtZone(_side, _weight, _zone)
    ctld.logWarning("DEPRECATED: ctld.spawnCrateAtZone — use CTLDCrateManager:spawnCrateAtZone()")
    return CTLDCrateManager.getInstance():spawnCrateAtZone(_side, _weight, _zone)
end

--- @deprecated Use CTLDCrateManager:spawnCrateAtPoint()
-- NOTE: non-functional until CTLDCrateManager:spawnCrate() is implemented.
function ctld.spawnCrateAtPoint(_side, _weight, _point, _hdg)
    ctld.logWarning("DEPRECATED: ctld.spawnCrateAtPoint — use CTLDCrateManager:spawnCrateAtPoint()")
    return CTLDCrateManager.getInstance():spawnCrateAtPoint(_side, _weight, _point, _hdg)
end

--- @deprecated Use CTLDCrateManager:startCrateCountWatcher()
function ctld.cratesInZone(_zone, _flagNumber)
    ctld.logWarning("DEPRECATED: ctld.cratesInZone — use CTLDCrateManager:startCrateCountWatcher()")
    CTLDCrateManager.getInstance():startCrateCountWatcher(_zone, _flagNumber)
end

-- ============================================================
-- Beacons
-- ============================================================

--- @deprecated Use CTLDBeaconManager:createAtZone()
function ctld.createRadioBeaconAtZone(_zone, _coalition, _batteryLife, _name)
    ctld.logWarning("DEPRECATED: ctld.createRadioBeaconAtZone — use CTLDBeaconManager:createAtZone()")
    CTLDBeaconManager.getInstance():createAtZone(_zone, _coalition, _batteryLife, _name)
end

-- ============================================================
-- JTAC
-- ============================================================

--- @deprecated Use CTLDJTACManager:autoLase()
function ctld.JTACAutoLase(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
    ctld.logWarning("DEPRECATED: ctld.JTACAutoLase — use CTLDJTACManager:autoLase()")
    CTLDJTACManager.get():autoLase(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
end

--- @deprecated Use CTLDJTACManager:startLase()
function ctld.JTACStart(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
    ctld.logWarning("DEPRECATED: ctld.JTACStart — use CTLDJTACManager:startLase()")
    CTLDJTACManager.get():startLase(_jtacGroupName, _laserCode, _smoke, _lock, _colour, _radio)
end

--- @deprecated Use CTLDJTACManager:stopAutoLase()
function ctld.JTACAutoLaseStop(_jtacGroupName)
    ctld.logWarning("DEPRECATED: ctld.JTACAutoLaseStop — use CTLDJTACManager:stopAutoLase()")
    CTLDJTACManager.get():stopAutoLase(_jtacGroupName)
end

-- End : compat/legacy_api.lua
-- ====================================================================================================
-- Start : CTLD_userConfig.lua
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

-- ============================================================
-- SECTION 1 — SCALAR PARAMETERS (bool / number / string)
-- Comment / uncomment individual lines to override defaults.
-- ============================================================
ctld.yamlConfigDatas = [[

# ============================================================
# General
# ============================================================

# Enable verbose debug logging to CTLD.log.
# Requires a non-sanitized DCS installation (io + lfs must be available).
# Leave false in production missions.
# ctld.debug: false

# Override the log file path (CTLD.log location).
# Leave empty to use the default DCS Saved Games folder.
# ctld.ctldLogPath:

# Enable the CTLD status entry in the F10 menu.
# ctld.CTLD_ctldStatusF10: true

# Identify CTLD-capable transports by DCS aircraft type (true) or by unit name (false).
# When false, only units listed in transportPilotNames will get CTLD menus.
# ctld.addPlayerAircraftByType: true

# Show coordinates as Degrees-Minutes-Seconds (DMS) instead of Degrees-Decimal-Minutes.
# ctld.location_DMS: false

# Suppress all smoke at pickup / drop-off zones, regardless of per-zone settings.
# ctld.disableAllSmoke: false

# Workaround for a DCS crash that occurs when a static object is destroyed.
# Set to true only if you observe random crashes when crates are unpacked.
# ctld.staticBugWorkaround: false


# ============================================================
# Logistics
# ============================================================

# Maximum distance (m) between the transport and a logistic zone to allow crate
# spawning or loading operations.
# ctld.maximumDistanceLogistic: 200

# Minimum distance (m) from a friendly pickup zone at which a crate may be deployed.
# ctld.minimumDeployDistance: 1000


# ============================================================
# Crates
# ============================================================

# Master switch — set to false to disable the entire crate system.
# ctld.enableCrates: true

# Show "All crates" shortcut entries in the F10 menu (spawns every component of a
# multi-crate system at once).
# ctld.enableAllCrates: true

# Enable hover-based slingload pickup (pilot must hover above a crate at the correct
# altitude).  Set to false to allow loading via the F10 menu only.
# ctld.enableHoverSlingload: true

# Allow crate loading via the F10 menu in addition to hover.  Useful when flying
# fixed-wing aircraft that cannot hover.
# ctld.loadCrateFromMenu: true

# Enable the "Drop Smoke" F10 menu entry.
# ctld.enableSmokeDrop: true

# Enable DCS native slingload weight simulation.
# WARNING: some DCS versions crash with slingload enabled — if crashes occur set this
# to false and rely on the virtual hover system instead.
# When true, also set staticBugWorkaround to false.
# ctld.slingLoad: false

# Maximum horizontal speed (m/s) allowed while carrying a virtual slingloaded crate.
# Exceeding this speed causes the crate to detach and fall.
# ctld.maxSlingloadSpeed: 50

# Minimum time (s) a player must wait after spawning a crate before spawning another.
# ctld.crateWaitTime: 40



# ============================================================
# Hover parameters (virtual slingload pickup)
# ============================================================

# Minimum AGL height (m) required to initiate a hover pickup.
# ctld.minimumHoverHeight: 7.5

# Maximum AGL height (m) at which a hover pickup is still valid.
# ctld.maximumHoverHeight: 12.0

# Maximum horizontal distance (m) between the transport and the crate centre
# for a hover pickup to count.
# ctld.maxDistanceFromCrate: 5.5

# Time (s) the pilot must maintain a valid hover before the crate is loaded.
# ctld.hoverTime: 10


# ============================================================
# Troops
# ============================================================

# Default number of troops loaded per transport (also acts as maximum group size
# unless overridden per aircraft type in unitLoadLimits).
# ctld.numberOfTroops: 10

# Maximum distance (m) from the transport to a troop group to allow extraction.
# ctld.maxExtractDistance: 125

# Maximum distance (m) deployed troops will search for an enemy unit.
# ctld.maximumSearchDistance: 4000

# Maximum distance (m) deployed troops will move from their drop point if no enemy
# is in range.
# ctld.maximumMoveDistance: 2000

# Allow pilots to insert troops via fast-rope.
# ctld.enableFastRopeInsertion: true

# Maximum safe AGL height (m) for fast-rope (not rappel) insertion — 60 ft default.
# ctld.fastRopeMaximumHeight: 18.28

# Spawn a friendly RPG soldier with every deployed coalition infantry group.
# ctld.spawnRPGWithCoalition: true

# Spawn a Stinger (BLUE) or Igla (RED) MANPAD soldier with groups of 6 or more.
# ctld.spawnStinger: false

# Allow AI transports to randomly pick up infantry teams at pickup zones.
# ctld.allowRandomAiTeamPickups: false


# ============================================================
# Infantry weight simulation
# Each soldier's weight is randomised between 90 % and 120 % of SOLDIER_WEIGHT,
# then the kit and role-specific equipment weights are added on top.
# These values affect whether a group fits inside a transport (unitLoadLimits).
# ============================================================

# Base body weight per soldier (kg) before randomisation.
# ctld.SOLDIER_WEIGHT: 80

# Helmet + backpack weight per soldier (kg).
# ctld.KIT_WEIGHT: 20

# Standard infantry rifle kit weight (kg).
# ctld.RIFLE_WEIGHT: 5

# AA soldier MANPAD tube weight (kg).
# ctld.MANPAD_WEIGHT: 18

# AT soldier RPG launcher + rocket weight (kg).
# ctld.RPG_WEIGHT: 7.6

# Machine-gunner weapon + 200-round belt weight (kg).
# ctld.MG_WEIGHT: 10

# Mortar servant tube + shells weight (kg).
# ctld.MORTAR_WEIGHT: 26

# JTAC laser designator + radio + binoculars weight (kg).
# ctld.JTAC_WEIGHT: 15


# ============================================================
# FOB (Forward Operating Base)
# ============================================================

# Enable FOB building from crates.
# ctld.enabledFOBBuilding: true

# Time (s) to build the FOB after the last required crate is unpacked.
# ctld.buildTimeFOB: 120

# Allow troops to be picked up at a deployed FOB.
# ctld.troopPickupAtFOB: true

# Minimum distance (m) from any existing logistic zone at which a FOB may be deployed.
# ctld.fobMinDistanceFromZones: 500

# Radius (m) of the logistic zone created around a deployed FOB.
# ctld.fobLogisticZoneRadius: 150

# Fraction of scene objects that must be destroyed before the FOB is considered lost.
# 0.0 = lost if anything is destroyed ; 1.0 = lost only when everything is destroyed.
# ctld.fobDestructionThreshold: 0.5

# Radius (m) within which troops can board a transport at a FOB.
# ctld.fobTroopPickupRadius: 150


# ============================================================
# Parachute — virtual parachute drop (Feature A)
# ============================================================

# Minimum AGL altitude (m) required to initiate a parachute drop for crates.
# ctld.parachuteMinAltitudeCrates: 30

# Minimum AGL altitude (m) required to initiate a parachute drop for troops.
# ctld.parachuteMinAltitudeTroops: 50

# Minimum AGL altitude (m) required to initiate a parachute drop for vehicles.
# ctld.parachuteMinAltitudeVehicles: 30

# Vertical descent speed (m/s) for parachuted crates (slower = more accurate landing).
# ctld.parachuteDescentRateCrates: 5

# Vertical descent speed (m/s) for parachuted troops.
# ctld.parachuteDescentRateTroops: 5

# Vertical descent speed (m/s) for parachuted vehicles (heavier loads fall faster).
# ctld.parachuteDescentRateVehicles: 8

# Forward drift factor : fraction of the transport's current speed applied as
# forward inertia to each dropped unit (0.0 = no drift ; 1.0 = full speed drift).
# ctld.parachuteInertiaFactor: 0.3

# Minimum random lateral drift (m) applied per unit during a parachute drop.
# ctld.parachuteLateralDriftMin: 10

# Maximum random lateral drift (m) applied per unit during a parachute drop.
# ctld.parachuteLateralDriftMax: 80

# Search radius (m) used when auto-unpacking parachuted crates after landing.
# Larger than the normal unpack radius to account for dispersion during descent.
# ctld.autoUnpackRadiusParachute: 1000


# ============================================================
# Beacons
# ============================================================

# Allow pilots to deploy radio beacons.
# ctld.enabledRadioBeaconDrop: true

# Battery life (minutes) of a deployed beacon before it stops transmitting.
# ctld.deployedBeaconBattery: 30

# Sound file used for FOB / beacon audio.  Must be added to the mission (.miz) file.
# ctld.radioSound: beacon.ogg

# Silent sound file used for FC3 aircraft so they do not hear all coalition beacons.
# ctld.radioSoundFC3: beaconsilent.ogg


# ============================================================
# AA systems (multi-crate assembly)
# ============================================================

# Default number of launchers added to an AA system when no amount is specified
# in its assembly template.
# ctld.aaLaunchers: 3

# Maximum number of fully functional AA systems that RED / BLUE can have deployed
# simultaneously.  Players can still receive crates beyond the limit, but cannot
# unpack them until an existing system is destroyed.
# ctld.AASystemLimitRED: 20
# ctld.AASystemLimitBLUE: 20

# Enable crate stacking : bringing N times the required crates spawns N times the
# launchers.  Example : 2 × Patriot launcher crates → 2 launchers in the group.
# ctld.AASystemCrateStacking: false


# ============================================================
# JTAC
# ============================================================

# Maximum number of JTAC units that each side may have active at the same time.
# ctld.JTAC_LIMIT_RED: 10
# ctld.JTAC_LIMIT_BLUE: 10

# Allow pilots to spawn JTAC units from the F10 crate menu.
# ctld.JTAC_dropEnabled: true

# Maximum lasing distance (m) — targets beyond this range are ignored.
# ctld.JTAC_maxDistance: 10000

# Which ground unit types the JTAC will track and lase.
# "vehicle" — armoured vehicles only
# "troop"   — infantry only
# "all"     — any ground unit
# ctld.JTAC_lock: all

# Show the JTAC status entry in the F10 menu.
# ctld.JTAC_jtacStatusF10: true

# Include the target's coordinates in JTAC messages.
# ctld.JTAC_location: true

# Allow pilots to toggle a JTAC's lasing on and off (standby mode).
# ctld.JTAC_allowStandbyMode: true

# Enable laser-spot lead correction : the JTAC attempts to lead moving targets,
# accounting for wind and target speed.  Most useful against moving heavy armour.
# ctld.JTAC_laseSpotCorrections: true

# Allow pilots to request a smoke marker on the JTAC's current target.
# ctld.JTAC_allowSmokeRequest: true

# Allow pilots to request a 9-Line from a JTAC.
# ctld.JTAC_allow9Line: true

# Enable target smoke for RED JTACs.
# ctld.JTAC_smokeOn_RED: false

# Enable target smoke for BLUE JTACs.
# ctld.JTAC_smokeOn_BLUE: false

# Smoke colour used by RED JTACs.
# 0=Green  1=Red  2=White  3=Orange  4=Blue
# ctld.JTAC_smokeColour_RED: 4

# Smoke colour used by BLUE JTACs.
# 0=Green  1=Red  2=White  3=Orange  4=Blue
# ctld.JTAC_smokeColour_BLUE: 1

# Maximum allowed error radius (m) when placing smoke on a target.
# ctld.JTAC_smokeMarginOfError: 50

# Smoke position offsets from the exact target point (metres).
# _x = East offset ; _y = vertical offset (Up) ; _z = North offset.
# ctld.JTAC_smokeOffset_x: 0.0
# ctld.JTAC_smokeOffset_y: 2.0
# ctld.JTAC_smokeOffset_z: 0.0

# Reschedule delay (s) for the auto-lase loop when actively lasing a target.
# ctld.JTAC_laseIntervalSeconds: 15

# Reschedule delay (s) for the auto-lase loop when searching for a target.
# ctld.JTAC_searchIntervalSeconds: 10

# Orbit radius (m) used by drone JTAC units around their target.
# ctld.JTAC_droneRadius: 1000

# Orbit altitude (m) for drone JTAC units.
# ctld.JTAC_droneAltitude: 7000


# ============================================================
# Recon
# ============================================================

# Enable the RECON submenu in the F10 CTLD menu.
# ctld.reconF10Menu: true

# Master switch — set to true to activate RECON functionality.
# When false, the Scan Area command does nothing even if the menu is visible.
# ctld.reconEnabled: false

# LOS detection radius (m) around the scanning unit.
# All enemy units within this radius are tested for line-of-sight.
# ctld.reconSearchRadius: 5000

# Minimum AGL altitude (m) required to perform a scan.
# The pilot must be at or above this height, otherwise the scan is rejected.
# ctld.reconMinAltitude: 50

# Auto-refresh interval (s) between successive target position updates.
# Decrease to track fast-moving targets more accurately (increases CPU load).
# ctld.reconRefreshInterval: 10

# Icon size multiplier applied to all RECON icons on the F10 map.
# 1.0 = default sizes (infantry=30m, vehicle=40m, aa=35m, aircraft=40m,
#        helicopter=25m, ship=50×20m).  Use 2.0 to double all icon sizes.
# ctld.reconIconScale: 1.0


# ============================================================
# Minefield
# ============================================================

# Draw a bounding quad on the F10 map when a minefield is deployed.
# ctld.showMinefieldOnF10Map: true


# ============================================================
# Vehicles / pack
# ============================================================

# Allow pilots to pack nearby vehicles into crates using the F10 menu.
# ctld.enablePackingVehicles: true

# Maximum distance (m) from the transport in which packable vehicles are searched.
# ctld.maximumDistancePackableUnitsSearch: 200

]]

-- ============================================================
-- SECTION 2 — COMPLEX TABLES
-- These cannot be expressed as YAML key:value pairs.
-- They are applied directly on the CTLDConfig instance.
-- Each table REPLACES the default entirely when uncommented.
-- ============================================================

---@diagnostic disable-next-line: unused-local
local _cfg = CTLDConfig.get()

-- ============================================================
-- Aircraft types allowed to use CTLD
-- Used when ctld.addPlayerAircraftByType = true.
-- Comment / uncomment entries to suit your mission's aircraft.
-- ============================================================
-- _cfg.settings["aircraftTypeTable"] = {
--     -- ── Helicopters ────────────────────────────────────────
--     "Mi-8MT",
--     "Mi-24P",
--     "UH-1H",
--     "CH-47Fbl1",
--     -- "Ka-50",
--     -- "Ka-50_3",
--     -- "SA342L",
--     -- "SA342M",
--     -- "SA342Mistral",
--     -- "SA342Minigun",
--
--     -- ── Fixed-wing ─────────────────────────────────────────
--     "C-130J-30",
--
--     -- ── Mods ───────────────────────────────────────────────
--     -- "Hercules",
--     -- "UH-60L",
--     -- "Bronco-OV-10A",
-- }

-- ============================================================
-- Transport pilot / unit names authorised to carry CTLD
-- Used when ctld.addPlayerAircraftByType = false, or for AI.
-- Add any DCS unit name from the Mission Editor here.
-- ============================================================
-- _cfg.settings["transportPilotNames"] = {
--     -- ── Player helicopter slots ────────────────────────────
--     "helicargo1",  "helicargo2",  "helicargo3",  "helicargo4",  "helicargo5",
--     "helicargo6",  "helicargo7",  "helicargo8",  "helicargo9",  "helicargo10",
--     "helicargo11", "helicargo12", "helicargo13", "helicargo14", "helicargo15",
--     "helicargo16", "helicargo17", "helicargo18", "helicargo19", "helicargo20",
--     "helicargo21", "helicargo22", "helicargo23", "helicargo24", "helicargo25",
--
--     -- ── MEDEVAC — BLUE ────────────────────────────────────
--     "MEDEVAC BLUE #1",  "MEDEVAC BLUE #2",  "MEDEVAC BLUE #3",
--     "MEDEVAC BLUE #4",  "MEDEVAC BLUE #5",  "MEDEVAC BLUE #6",
--     "MEDEVAC BLUE #7",  "MEDEVAC BLUE #8",  "MEDEVAC BLUE #9",
--     "MEDEVAC BLUE #10", "MEDEVAC BLUE #11", "MEDEVAC BLUE #12",
--
--     -- ── MEDEVAC — RED ─────────────────────────────────────
--     "MEDEVAC RED #1",  "MEDEVAC RED #2",  "MEDEVAC RED #3",
--     "MEDEVAC RED #4",  "MEDEVAC RED #5",  "MEDEVAC RED #6",
--
--     -- ── MEDEVAC — both sides ──────────────────────────────
--     "MEDEVAC #1", "MEDEVAC #2", "MEDEVAC #3",
--
--     -- ── AI transport slots ────────────────────────────────
--     "transport1",  "transport2",  "transport3",  "transport4",  "transport5",
--     "transport6",  "transport7",  "transport8",  "transport9",  "transport10",
--     "transport11", "transport12", "transport13", "transport14", "transport15",
-- }

-- ============================================================
-- Pickup zones
-- Each entry: { "zone_or_ship_name", "smoke_color", limit, "active", side [, flag] }
--
--   "zone_or_ship_name" : ME trigger zone name, or DCS unit name of a ship
--   "smoke_color"       : "green"|"red"|"white"|"orange"|"blue"|"none"
--   limit               : -1 = unlimited ; N = max groups that can be loaded
--                         (dropping a group back adds one to the count)
--   "active"            : "yes" = available at mission start
--                         "no"  = deactivated — use ctld.activatePickupZone() to enable
--   side                : 0 = both coalitions ; 1 = RED only ; 2 = BLUE only
--   flag (optional)     : DCS flag number where remaining group count is stored
-- ============================================================
-- _cfg.settings["pickupZones"] = {
--     { "pickzone1",   "blue",   -1, "yes", 0 },
--     { "pickzone2",   "red",    -1, "yes", 0 },
--     { "pickzone3",   "none",   -1, "yes", 0 },
--     { "pickzone4",   "none",   -1, "yes", 0 },
--     { "pickzone5",   "none",   -1, "yes", 0 },
--     { "pickzone6",   "none",   -1, "yes", 0 },
--     { "pickzone7",   "none",   -1, "yes", 0 },
--     { "pickzone8",   "none",   -1, "yes", 0 },
--     { "pickzone9",   "none",    5, "yes", 1 }, -- 5 groups max, RED only
--     { "pickzone10",  "none",   10, "yes", 2 }, -- 10 groups max, BLUE only
--     { "pickzone11",  "blue",   20, "no",  2 }, -- starts inactive, BLUE only
--     { "pickzone12",  "red",    20, "no",  1 }, -- starts inactive, RED only
--     { "pickzone13",  "none",   -1, "yes", 0 },
--     { "pickzone14",  "none",   -1, "yes", 0 },
--     { "pickzone15",  "none",   -1, "yes", 0 },
--     { "pickzone16",  "none",   -1, "yes", 0 },
--     { "pickzone17",  "none",   -1, "yes", 0 },
--     { "pickzone18",  "none",   -1, "yes", 0 },
--     { "pickzone19",  "none",    5, "yes", 0 },
--     { "pickzone20",  "none",   10, "yes", 0, 1000 }, -- remaining count stored in flag 1000
--     { "USA Carrier", "blue",   10, "yes", 0, 1001 }, -- ship: use DCS unit name
-- }

-- ============================================================
-- Drop-off zones (AI transports auto-unload when inside the zone)
-- Each entry: { "zone_name", "smoke_color", side }
--   side : 0 = both ; 1 = RED ; 2 = BLUE
-- ============================================================
-- _cfg.settings["dropOffZones"] = {
--     { "dropzone1",  "green",  2 },
--     { "dropzone2",  "blue",   2 },
--     { "dropzone3",  "orange", 2 },
--     { "dropzone4",  "none",   2 },
--     { "dropzone5",  "none",   1 },
--     { "dropzone6",  "none",   1 },
--     { "dropzone7",  "none",   1 },
--     { "dropzone8",  "none",   1 },
--     { "dropzone9",  "none",   1 },
--     { "dropzone10", "none",   1 },
-- }

-- ============================================================
-- Waypoint zones (AI routing — transport will fly to each active
-- waypoint zone in sequence before reaching the drop-off zone)
-- Each entry: { "zone_name", "smoke_color", "active", side }
-- ============================================================
-- _cfg.settings["wpZones"] = {
--     { "wpzone1",  "green",  "yes", 2 },
--     { "wpzone2",  "blue",   "yes", 2 },
--     { "wpzone3",  "orange", "yes", 2 },
--     { "wpzone4",  "none",   "yes", 2 },
--     { "wpzone5",  "none",   "yes", 2 },
--     { "wpzone6",  "none",   "yes", 1 },
--     { "wpzone7",  "none",   "yes", 1 },
--     { "wpzone8",  "none",   "yes", 1 },
--     { "wpzone9",  "none",   "yes", 1 },
--     { "wpzone10", "none",   "no",  0 }, -- inactive at start ; both sides
-- }

-- ============================================================
-- Extractable groups
-- DCS group names that can be extracted by a transport.
-- ============================================================
-- _cfg.settings["extractableGroups"] = {
--     "extract1",  "extract2",  "extract3",  "extract4",  "extract5",
--     "extract6",  "extract7",  "extract8",  "extract9",  "extract10",
--     "extract11", "extract12", "extract13", "extract14", "extract15",
--     "extract16", "extract17", "extract18", "extract19", "extract20",
--     "extract21", "extract22", "extract23", "extract24", "extract25",
-- }

-- ============================================================
-- Logistic units — unit names near which crate spawning is allowed.
-- When a logistic unit is destroyed, crate spawning at its location stops.
-- ============================================================
-- _cfg.settings["logisticUnits"] = {
--     "logistic1",  "logistic2",  "logistic3",  "logistic4",  "logistic5",
--     "logistic6",  "logistic7",  "logistic8",  "logistic9",  "logistic10",
--     "logistic11", "logistic12", "logistic13", "logistic14", "logistic15",
--     "logistic16", "logistic17", "logistic18", "logistic19", "logistic20",
-- }

-- ============================================================
-- Vehicle transport — aircraft types allowed to carry vehicles
-- (loads vehicles onto the transport, then deploys them at the destination)
-- ============================================================
-- _cfg.settings["vehicleTransportEnabled"] = {
--     "C-130J-30",
--     "76MD",      -- IL-76 (note: the mod spells the dash differently)
--     -- "Hercules",
--     -- "CH-47Fbl1",
-- }

-- ============================================================
-- Dynamic cargo units — aircraft types that use the native DCS
-- cargo system (creates a DCS cargo static that can be loaded
-- with the standard DCS slingload / cargo interface)
-- ============================================================
-- _cfg.settings["dynamicCargoUnits"] = {
--     "CH-47Fbl1",
--     "UH-1H",
--     "Mi-8MT",
--     "Mi-24P",
--     "C-130J-30",
-- }

-- ============================================================
-- Unit load limits — maximum group size (number of soldiers)
-- that each aircraft type can carry.  Groups larger than the
-- limit will not appear as available for loading.
-- ============================================================
-- _cfg.settings["unitLoadLimits"] = {
--     -- ── Helicopters ────────────────────────────────────────
--     ["Mi-8MT"]    = 16,
--     ["Mi-24P"]    = 10,
--     ["UH-1H"]     = 8,
--     ["CH-47Fbl1"] = 33,
--
--     -- ── Fixed-wing ─────────────────────────────────────────
--     ["C-130J-30"] = 80,
--
--     -- ── Mods ───────────────────────────────────────────────
--     -- ["Hercules"] = 30,
--     -- ["UH-60L"]   = 12,
--
--     -- ── Light aircraft (set to 1 or 2 for recon/observer) ──
--     -- ["SA342L"]      = 4,
--     -- ["SA342M"]      = 4,
--     -- ["SA342Mistral"] = 4,
--     -- ["SA342Minigun"] = 3,
-- }

-- ============================================================
-- Internal cargo limits — maximum number of crates a single
-- aircraft can carry at the same time (internal load).
-- ============================================================
-- _cfg.settings["internalCargoLimits"] = {
--     ["Mi-8MT"]    = 2,
--     ["CH-47Fbl1"] = 8,
--     ["C-130J-30"] = 20,
-- }

-- ============================================================
-- Unit actions — per-aircraft-type capability flags.
-- Omit an aircraft type to use the default (crates=true, troops=true).
--
--   crates       : can spawn, load and unpack crates
--   troops       : can load and deploy infantry groups
--   canParachute : enables "Parachute Crates/Troops/Vehicle" F10 entries (Feature A)
--   canSlingload : enables hover-pickup polling and "Release/Cut Slingload" menus (Feature B)
--                  — set true for helicopters, false for fixed-wing aircraft
-- ============================================================
-- _cfg.settings["unitActions"] = {
--     -- ── Helicopters ────────────────────────────────────────
--     ["Mi-8MT"]    = { crates = true,  troops = true,  canParachute = false, canSlingload = true  },
--     ["Mi-24P"]    = { crates = true,  troops = true,  canParachute = false, canSlingload = false },
--     ["UH-1H"]     = { crates = true,  troops = true,  canParachute = false, canSlingload = true  },
--     ["CH-47Fbl1"] = { crates = true,  troops = true,  canParachute = false, canSlingload = true  },
--     -- ["Ka-50"]       = { crates = true,  troops = false, canParachute = false, canSlingload = true  },
--     -- ["Ka-50_3"]     = { crates = true,  troops = false, canParachute = false, canSlingload = true  },
--     -- ["SA342L"]      = { crates = false, troops = true,  canParachute = false, canSlingload = false },
--     -- ["SA342M"]      = { crates = false, troops = true,  canParachute = false, canSlingload = false },
--     -- ["SA342Mistral"] = { crates = false, troops = true, canParachute = false, canSlingload = false },
--     -- ["SA342Minigun"] = { crates = false, troops = true, canParachute = false, canSlingload = false },
--
--     -- ── Fixed-wing ─────────────────────────────────────────
--     ["C-130J-30"] = { crates = true,  troops = true,  canParachute = false, canSlingload = false },
--
--     -- ── Mods ───────────────────────────────────────────────
--     -- ["Hercules"]    = { crates = true,  troops = true,  canParachute = false, canSlingload = false },
--     -- ["UH-60L"]      = { crates = true,  troops = true,  canParachute = false, canSlingload = true  },
-- }

-- ============================================================
-- Vehicles that can be loaded onto RED / BLUE vehicle transports.
-- The "vehicleTransportEnabled" aircraft must be in range.
-- ============================================================
-- _cfg.settings["vehiclesForTransportRED"]  = { "BRDM-2", "BTR_D" }
-- _cfg.settings["vehiclesForTransportBLUE"] = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" }

-- ============================================================
-- Vehicle weights (kg) used to determine if a transport can carry a vehicle.
-- Add any DCS unit type that appears in vehiclesForTransportRED/BLUE.
-- ============================================================
-- _cfg.settings["vehiclesWeight"] = {
--     ["BRDM-2"]               = 7000,
--     ["BTR_D"]                = 8000,
--     ["M1045 HMMWV TOW"]      = 3220,
--     ["M1043 HMMWV Armament"] = 2500,
-- }

-- ============================================================
-- Infantry spawn cap — cumulative limit on the number of troops
-- that can be loaded aboard transports across the whole mission.
-- { redLimit, blueLimit }  —  0 = no limit.
-- Example: { 200, 200 } caps each side at 200 troops total.
-- ============================================================
-- _cfg.settings["nbLimitSpawnedTroops"] = { 0, 0 }

-- ============================================================
-- Loadable troop groups
-- Defines the infantry group templates shown in the F10 "Troops" menu.
-- Each entry replaces/adds one loadable group template.
--
-- Fields:
--   name   : label shown in the F10 menu
--   inf    : number of standard riflemen
--   mg     : number of M249 / PKM machine-gunners
--   at     : number of RPG anti-tank soldiers
--   aa     : number of Stinger / Igla MANPAD soldiers
--   mortar : number of 2B11 mortar crews
--   jtac   : number of JTAC soldiers (auto-lase when deployed)
--   side   : 1 = RED only ; 2 = BLUE only ; omit = both coalitions
-- ============================================================
-- _cfg.settings["loadableGroups"] = {
--     { name = "Standard Group",             inf = 6, mg = 2, at = 2 },
--     { name = "Anti Air",                   inf = 2, aa = 3 },
--     { name = "Anti Tank",                  inf = 2, at = 6 },
--     { name = "Mortar Squad",               mortar = 6 },
--     { name = "JTAC Group",                 inf = 4, jtac = 1 },
--     { name = "Single JTAC",                jtac = 1 },
--     { name = "2x Standard Groups",         inf = 12, mg = 4, at = 4 },
--     { name = "2x Anti Air",                inf = 4,  aa = 6 },
--     { name = "2x Anti Tank",               inf = 4,  at = 12 },
--     { name = "2x Standard + 2x Mortar",    inf = 12, mg = 4, at = 4, mortar = 12 },
--     { name = "3x Standard Groups",         inf = 18, mg = 6, at = 6 },
--     { name = "3x Anti Air",                inf = 6,  aa = 9 },
--     { name = "3x Anti Tank",               inf = 6,  at = 18 },
--     { name = "3x Mortar Squad",            mortar = 18 },
--     { name = "5x Mortar Squad",            mortar = 30 },
--     -- { name = "Red Mortar Squad", mortar = 5, side = 1 }, -- RED only
-- }

-- ============================================================
-- Spawnable crates — F10 crate menu catalogue
--
-- The table is keyed by sub-menu name.  Each sub-menu contains
-- one or more crate descriptor entries.
--
-- Crate descriptor fields:
--   weight        (number) : unique kg value used as lookup key — MUST be unique
--   desc          (string) : label shown in the F10 menu
--   unit          (string) : DCS unit type name spawned when the crate is unpacked
--   cratesRequired (number): number of identical crates that must be assembled
--                            within 100 m of each other to build the unit (default 1)
--   side          (number) : 1 = RED only ; 2 = BLUE only ; omit = both coalitions
--   multiple      (table)  : list of weights — shortcut entry that spawns all listed
--                            crates at once (no weight/unit fields needed here)
-- ============================================================
-- _cfg.settings["spawnableCrates"] = {
--
--     ["Combat Vehicles"] = {
--         --- BLUE
--         { weight = 1000.01,                                   desc = "Humvee - MG",                      unit = "M1043 HMMWV Armament", side = 2 },
--         { weight = 1000.02,                                   desc = "Humvee - TOW",                     unit = "M1045 HMMWV TOW",      side = 2, cratesRequired = 2 },
--         { multiple = { 1000.02, 1000.02 },                    desc = "Humvee - TOW - All crates",        side = 2 },
--         { weight = 1000.03,                                   desc = "Light Tank - MRAP",                unit = "MaxxPro_MRAP",         side = 2, cratesRequired = 2 },
--         { multiple = { 1000.03, 1000.03 },                    desc = "Light Tank - MRAP - All crates",   side = 2 },
--         { weight = 1000.04,                                   desc = "Med Tank - LAV-25",                unit = "LAV-25",               side = 2, cratesRequired = 3 },
--         { multiple = { 1000.04, 1000.04, 1000.04 },           desc = "Med Tank - LAV-25 - All crates",   side = 2 },
--         { weight = 1000.05,                                   desc = "Heavy Tank - Abrams",              unit = "M-1 Abrams",           side = 2, cratesRequired = 4 },
--         { multiple = { 1000.05, 1000.05, 1000.05, 1000.05 }, desc = "Heavy Tank - Abrams - All crates", side = 2 },
--         --- RED
--         { weight = 1000.11,                                   desc = "BTR-D",                            unit = "BTR_D",                side = 1 },
--         { weight = 1000.12,                                   desc = "BRDM-2",                           unit = "BRDM-2",               side = 1 },
--     },
--
--     ["Support"] = {
--         --- BLUE
--         { weight = 1001.01,                                   desc = "Hummer - JTAC",                    unit = "Hummer",               side = 2, cratesRequired = 2 },
--         { multiple = { 1001.01, 1001.01 },                    desc = "Hummer - JTAC - All crates",       side = 2 },
--         { weight = 1001.02,                                   desc = "M-818 Ammo Truck",                 unit = "M 818",                side = 2, cratesRequired = 2 },
--         { multiple = { 1001.02, 1001.02 },                    desc = "M-818 Ammo Truck - All crates",    side = 2 },
--         { weight = 1001.03,                                   desc = "M-978 Tanker",                     unit = "M978 HEMTT Tanker",    side = 2, cratesRequired = 2 },
--         { multiple = { 1001.03, 1001.03 },                    desc = "M-978 Tanker - All crates",        side = 2 },
--         --- RED
--         { weight = 1001.11,                                   desc = "SKP-11 - JTAC",                    unit = "SKP-11",               side = 1 },
--         { weight = 1001.12,                                   desc = "Ural-375 Ammo Truck",              unit = "Ural-375",             side = 1, cratesRequired = 2 },
--         { multiple = { 1001.12, 1001.12 },                    desc = "Ural-375 Ammo Truck - All crates", side = 1 },
--         { weight = 1001.13,                                   desc = "KAMAZ Ammo Truck",                 unit = "KAMAZ Truck",          side = 1, cratesRequired = 2 },
--         --- Both
--         { weight = 1001.21,                                   desc = "EWR Radar",                        unit = "FPS-117",              cratesRequired = 3 },
--         { multiple = { 1001.21, 1001.21, 1001.21 },           desc = "EWR Radar - All crates" },
--         { weight = 1001.22,                                   desc = "FOB Crate",                        unit = "FOB",          side = nil, cratesRequired = 3 },
--     },
--
--     ["Artillery"] = {
--         --- BLUE
--         { weight = 1002.01,                                   desc = "MLRS",                       unit = "MLRS",         side = 2, cratesRequired = 3 },
--         { multiple = { 1002.01, 1002.01, 1002.01 },           desc = "MLRS - All crates",          side = 2 },
--         { weight = 1002.02,                                   desc = "SpGH DANA",                  unit = "SpGH_Dana",    side = 2, cratesRequired = 3 },
--         { multiple = { 1002.02, 1002.02, 1002.02 },           desc = "SpGH DANA - All crates",     side = 2 },
--         { weight = 1002.03,                                   desc = "T155 Firtina",               unit = "T155_Firtina", side = 2, cratesRequired = 3 },
--         { multiple = { 1002.03, 1002.03, 1002.03 },           desc = "T155 Firtina - All crates",  side = 2 },
--         { weight = 1002.04,                                   desc = "Howitzer M-109",             unit = "M-109",        side = 2, cratesRequired = 3 },
--         { multiple = { 1002.04, 1002.04, 1002.04 },           desc = "Howitzer M-109 - All crates", side = 2 },
--         --- RED
--         { weight = 1002.11,                                   desc = "SPH 2S19 Msta",              unit = "SAU Msta",     side = 1, cratesRequired = 3 },
--         { multiple = { 1002.11, 1002.11, 1002.11 },           desc = "SPH 2S19 Msta - All crates", side = 1 },
--     },
--
--     ["SAM short range"] = {
--         --- BLUE
--         { weight = 1003.01,                                   desc = "M1097 Avenger",              unit = "M1097 Avenger",       side = 2, cratesRequired = 3 },
--         { multiple = { 1003.01, 1003.01, 1003.01 },           desc = "M1097 Avenger - All crates", side = 2 },
--         { weight = 1003.02,                                   desc = "M48 Chaparral",              unit = "M48 Chaparral",       side = 2, cratesRequired = 2 },
--         { multiple = { 1003.02, 1003.02 },                    desc = "M48 Chaparral - All crates", side = 2 },
--         { weight = 1003.03,                                   desc = "Roland ADS",                 unit = "Roland ADS",          side = 2, cratesRequired = 3 },
--         { multiple = { 1003.03, 1003.03, 1003.03 },           desc = "Roland ADS - All crates",    side = 2 },
--         { weight = 1003.04,                                   desc = "Gepard AAA",                 unit = "Gepard",              side = 2, cratesRequired = 3 },
--         { multiple = { 1003.04, 1003.04, 1003.04 },           desc = "Gepard AAA - All crates",    side = 2 },
--         { weight = 1003.05,                                   desc = "LPWS C-RAM",                 unit = "HEMTT_C-RAM_Phalanx", side = 2, cratesRequired = 3 },
--         { multiple = { 1003.05, 1003.05, 1003.05 },           desc = "LPWS C-RAM - All crates",    side = 2 },
--         --- RED
--         { weight = 1003.11,                                   desc = "9K33 Osa",                   unit = "Osa 9A33 ln",         side = 1, cratesRequired = 3 },
--         { multiple = { 1003.11, 1003.11, 1003.11 },           desc = "9K33 Osa - All crates",      side = 1 },
--         { weight = 1003.12,                                   desc = "9P31 Strela-1",              unit = "Strela-1 9P31",       side = 1, cratesRequired = 3 },
--         { multiple = { 1003.12, 1003.12, 1003.12 },           desc = "9P31 Strela-1 - All crates", side = 1 },
--         { weight = 1003.13,                                   desc = "9K35M Strela-10",            unit = "Strela-10M3",         side = 1, cratesRequired = 3 },
--         { multiple = { 1003.13, 1003.13, 1003.13 },           desc = "9K35M Strela-10 - All crates", side = 1 },
--         { weight = 1003.14,                                   desc = "9K331 Tor",                  unit = "Tor 9A331",           side = 1, cratesRequired = 3 },
--         { multiple = { 1003.14, 1003.14, 1003.14 },           desc = "9K331 Tor - All crates",     side = 1 },
--         { weight = 1003.15,                                   desc = "2K22 Tunguska",              unit = "2S6 Tunguska",        side = 1, cratesRequired = 3 },
--         { multiple = { 1003.15, 1003.15, 1003.15 },           desc = "2K22 Tunguska - All crates", side = 1 },
--     },
--
--     ["SAM mid range"] = {
--         --- BLUE — HAWK system
--         { weight = 1004.01,                                   desc = "HAWK Launcher",               unit = "Hawk ln",              side = 2 },
--         { weight = 1004.02,                                   desc = "HAWK Search Radar",           unit = "Hawk sr",              side = 2 },
--         { weight = 1004.03,                                   desc = "HAWK Track Radar",            unit = "Hawk tr",              side = 2 },
--         { weight = 1004.04,                                   desc = "HAWK PCP",                   unit = "Hawk pcp",             side = 2 },
--         { weight = 1004.05,                                   desc = "HAWK CWAR",                  unit = "Hawk cwar",            side = 2 },
--         { weight = 1004.06,                                   desc = "HAWK Repair",                unit = "HAWK Repair",          side = 2 },
--         { multiple = { 1004.01, 1004.02, 1004.03 },           desc = "HAWK - All crates",           side = 2 },
--         --- BLUE — NASAMS system
--         { weight = 1004.11,                                   desc = "NASAMS Launcher 120C",        unit = "NASAMS_LN_C",          side = 2 },
--         { weight = 1004.12,                                   desc = "NASAMS Search/Track Radar",   unit = "NASAMS_Radar_MPQ64F1", side = 2 },
--         { weight = 1004.13,                                   desc = "NASAMS Command Post",         unit = "NASAMS_Command_Post",  side = 2 },
--         { weight = 1004.14,                                   desc = "NASAMS Repair",              unit = "NASAMS Repair",        side = 2 },
--         { multiple = { 1004.11, 1004.12, 1004.13 },           desc = "NASAMS - All crates",         side = 2 },
--         --- RED — KUB system
--         { weight = 1004.21,                                   desc = "KUB Launcher",               unit = "Kub 2P25 ln",          side = 1 },
--         { weight = 1004.22,                                   desc = "KUB Radar",                  unit = "Kub 1S91 str",         side = 1 },
--         { weight = 1004.23,                                   desc = "KUB Repair",                 unit = "KUB Repair",           side = 1 },
--         { multiple = { 1004.21, 1004.22 },                    desc = "KUB - All crates",            side = 1 },
--         --- RED — BUK system
--         { weight = 1004.31,                                   desc = "BUK Launcher",               unit = "SA-11 Buk LN 9A310M1", side = 1 },
--         { weight = 1004.32,                                   desc = "BUK Search Radar",           unit = "SA-11 Buk SR 9S18M1",  side = 1 },
--         { weight = 1004.33,                                   desc = "BUK CC Radar",               unit = "SA-11 Buk CC 9S470M1", side = 1 },
--         { weight = 1004.34,                                   desc = "BUK Repair",                 unit = "BUK Repair",           side = 1 },
--         { multiple = { 1004.31, 1004.32, 1004.33 },           desc = "BUK - All crates",            side = 1 },
--     },
--
--     ["SAM long range"] = {
--         --- BLUE — Patriot system
--         { weight = 1005.01,                                   desc = "Patriot Launcher",            unit = "Patriot ln",        side = 2 },
--         { weight = 1005.02,                                   desc = "Patriot Radar",               unit = "Patriot str",       side = 2 },
--         { weight = 1005.03,                                   desc = "Patriot ECS",                 unit = "Patriot ECS",       side = 2 },
--         { weight = 1005.06,                                   desc = "Patriot AMG (optional)",      unit = "Patriot AMG",       side = 2 },
--         { weight = 1005.07,                                   desc = "Patriot Repair",              unit = "Patriot Repair",    side = 2 },
--         { multiple = { 1005.01, 1005.02, 1005.03 },           desc = "Patriot - All crates",        side = 2 },
--         --- RED — S-300 system
--         { weight = 1005.11,                                   desc = "S-300 TEL C",                 unit = "S-300PS 5P85C ln",  side = 1 },
--         { weight = 1005.12,                                   desc = "S-300 Flap Lid-A TR",         unit = "S-300PS 40B6M tr",  side = 1 },
--         { weight = 1005.13,                                   desc = "S-300 Clam Shell SR",         unit = "S-300PS 40B6MD sr", side = 1 },
--         { weight = 1005.14,                                   desc = "S-300 Big Bird SR",           unit = "S-300PS 64H6E sr",  side = 1 },
--         { weight = 1005.15,                                   desc = "S-300 C2",                    unit = "S-300PS 54K6 cp",   side = 1 },
--         { weight = 1005.16,                                   desc = "S-300 Repair",                unit = "S-300 Repair",      side = 1 },
--         { multiple = { 1005.11, 1005.12, 1005.13, 1005.14, 1005.15 }, desc = "S-300 - All crates", side = 1 },
--     },
--
--     ["Drone"] = {
--         --- BLUE
--         { weight = 1006.01,                                   desc = "MQ-9 Reaper - JTAC",         unit = "MQ-9 Reaper",    side = 2 },
--         --- RED
--         { weight = 1006.11,                                   desc = "RQ-1A Predator - JTAC",      unit = "RQ-1A Predator", side = 1 },
--     },
-- }

-- ============================================================
-- Crate 3D model templates
-- Controls which DCS static object model is spawned for each
-- crate usage type.
--
-- Three slots:
--   "load"    : crate spawned for standard hover / menu loading
--               (canCargo = false : not a real DCS slingload cargo)
--   "sling"   : crate spawned when ctld.slingLoad = true
--               (canCargo = true  : DCS native cargo physics)
--   "dynamic" : crate spawned when the aircraft is in dynamicCargoUnits
--               (canCargo = true  : DCS native cargo physics)
--
-- Available DCS cargo models and their type strings:
--   model shape               | type
--   ─────────────────────────────────────────────────────────
--   ammo_box_cargo            | ammo_cargo         (default load)
--   bw_container_cargo        | container_cargo    (default sling)
--   iso_container_cargo       | iso_container
--   iso_container_small_cargo | iso_container_small
--   ab-212_cargo              | uh1h_cargo
--   barrels_cargo             | barrels_cargo
--   fueltank_cargo            | fueltank_cargo
--   oiltank_cargo             | oiltank_cargo
--   pipes_big_cargo           | pipes_big_cargo
--   pipes_small_cargo         | pipes_small_cargo
--   tetrapod_cargo            | tetrapod_cargo
--   trunks_long_cargo         | trunks_long_cargo
--   trunks_small_cargo        | trunks_small_cargo
--   f_bar_cargo               | f_bar_cargo
-- ============================================================
-- _cfg.settings["spawnableCratesModels"] = {
--     ["load"] = {
--         category   = "Cargos",
--         type       = "ammo_cargo",
--         canCargo   = false,
--     },
--     ["sling"] = {
--         category   = "Cargos",
--         shape_name = "bw_container_cargo",
--         type       = "container_cargo",
--         canCargo   = true,
--     },
--     ["dynamic"] = {
--         category   = "Cargos",
--         type       = "ammo_cargo",
--         canCargo   = true,
--     },
-- }

-- ============================================================
-- AUTO-START
-- Boots all CTLD singletons after config is applied.
-- Set ctld.dontInitialize = true in your mission script BEFORE
-- loading CTLD_Next.lua if you need to call ctld.initialize()
-- manually (e.g. to run additional setup between loading and starting).
-- ============================================================

---@diagnostic disable-next-line: lowercase-global
function ctld.initialize()
    CTLDConfig.get():load()
    ctld.utils.initLog()

    -- Boot all domain managers first so they can register their menu sections.
    -- Order matters: PlayerManager must be up before any other manager calls
    -- registerMenuSection(), and _scanExistingPlayers() must run last so all
    -- sections are registered before menus are built for pre-existing players.
    CTLDPlayerManager.getInstance()   -- creates _menuSections registry
    CTLDZoneManager.getInstance()
    CTLDTroopManager.getInstance()    -- registers "troops" section
    CTLDCrateManager.getInstance()    -- registers "crates" + "smoke" sections
    CTLDVehicleSpawner.getInstance()  -- registers "vehicles" section
    CTLDFOBManager.getInstance()
    CTLDBeaconManager.getInstance()   -- registers "beacons" section
    CTLDReconManager.getInstance()    -- registers "recon" section
    CTLDJTACManager.get()             -- registers "jtac" section
    CTLDCrateAssemblyManager.getInstance()
    CTLDCoreManager.getInstance()     -- INIT-B (MM crates) + INIT-C (MM JTACs)

    -- Now that all sections are registered, build menus for any player
    -- already in a slot (no retroactive S_EVENT_PLAYER_ENTER_UNIT).
    CTLDPlayerManager.getInstance():_scanExistingPlayers()

    ctld.utils.log("INFO", "CTLD initialized.")
end

if ctld.dontInitialize then
    ctld.utils.log("INFO", "CTLD auto-start skipped (ctld.dontInitialize=true). Call ctld.initialize() manually.")
else
    ctld.initialize()
end

-- End : CTLD_userConfig.lua
