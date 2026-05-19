# DCS-CTLD Next

Complete Troops and Logistics Deployment for DCS World — **v2 modular rewrite**

> **Looking for the legacy v1 documentation?** See [README_old.md](README_old.md).

---

## License

Originally created by Ciribob, maintained by Zip and the [VEAF Team](https://www.veaf.org).

Open-source and free (use, modify, fork, even commercial profit). Credit is appreciated.
Reach out to [Zip on Discord](https://discordapp.com/users/421317390807203850) to participate.
[Buy me a coffee](https://coff.ee/veaf_zip) if you'd like to support the work.

---

## Contents

- [Features](#features)
- [Installation](#installation)
  - [Static load (production)](#static-load-production)
  - [Dynamic load (development)](#dynamic-load-development)
  - [Required sound files](#required-sound-files)
- [Configuration](#configuration)
  - [Language](#language)
  - [Pickup and Dropoff Zones](#pickup-and-dropoff-zones)
  - [Waypoint Zones](#waypoint-zones)
  - [Transport Unit Setup](#transport-unit-setup)
  - [Logistic Units](#logistic-units)
  - [Spawnable Crates](#spawnable-crates)
  - [Custom Troop Templates](#custom-troop-templates)
  - [JTAC Configuration](#jtac-configuration)
  - [Parachute Configuration](#parachute-configuration)
  - [Slingload Configuration](#slingload-configuration)
  - [FOB Configuration](#fob-configuration)
- [Mission Editor Script Functions](#mission-editor-script-functions)
  - [Troops](#troops)
  - [Zones](#zones)
  - [Crates](#crates)
  - [JTAC](#jtac)
  - [Beacons](#beacons)
- [Subscribing to CTLD Events](#subscribing-to-ctld-events)
- [In-Game F10 Menu](#in-game-f10-menu)
- [Troop Operations](#troop-operations)
- [Crate Operations](#crate-operations)
- [Virtual Parachute Drop](#virtual-parachute-drop)
- [Virtual Slingload](#virtual-slingload)
- [Forward Operating Base (FOB)](#forward-operating-base-fob)
- [FARP Deployment](#farp-deployment)
- [Radio Beacons](#radio-beacons)
- [JTAC Auto-Lase](#jtac-auto-lase)
- [Recon and Target Marking](#recon-and-target-marking)
- [AA System Construction](#aa-system-construction)
- [Vehicle Pack](#vehicle-pack)
- [Migration from v1](#migration-from-v1)
- [Developer Guide](#developer-guide)

---

## Features

- **Troops** — load, transport and deploy infantry groups via F10 menu; configurable group compositions (inf / MG / AT / AA / mortar)
- **Vehicles** — load light vehicles into C-130 / IL-76 class aircraft
- **Crates** — spawn, hover-load, drop, and unpack supply crates to build vehicles and AA systems
- **Vehicle Pack** — pack a ground vehicle into crates for air transport, then reassemble it on the other side
- **Virtual Parachute** — drop troops, crates or vehicles by parachute with realistic wind drift simulation
- **Virtual Slingload** — simulate cargo sling loading without DCS sling-load physics bugs (hover detection, overspeed loss, inertia drift on release)
- **FOB Construction** — assemble a Forward Operating Base from dropped crates; becomes a new spawn and logistics point
- **FARP Deployment** — deploy a Forward Arming and Refuelling Point using a helicopter-carried crate sequence
- **Radio Beacons** — deploy homing beacons (VHF / UHF / FM) usable by all ADF-capable aircraft; battery timer; F10 map markers
- **JTAC Auto-Lase** — deploy JTAC units that auto-lase the nearest enemy, mark with smoke, give 9-lines, orbit (drones), optional SRS speech
- **Recon** — scan areas for enemy contacts and display them as F10 map markers
- **AA Systems** — multi-crate assembly: HAWK (3 crates), KUB (2 crates), Stinger/Igla; repair crates; configurable limits per coalition
- **Waypoint Zones** — automatically route deployed troops to an objective marker
- **Extract Zones** — count troops rescued to a zone; drive DCS flag triggers
- **i18n** — English (default), French, Spanish, Korean; fully translatable via key files
- **No MIST dependency** — v2 runs standalone (all MIST utilities replaced internally)
- **Events API** — 38 typed events via `EventDispatcher`; subscribe per-event with callbacks
- **CI-built** — every commit produces a validated `CTLD_Next.lua`; releases published on GitHub Releases

---

## Installation

### Static load (production)

1. Download `CTLD_Next.lua` from the [latest GitHub Release](../../releases/latest).
2. In the DCS Mission Editor, add a **MISSION START → DO SCRIPT FILE** trigger pointing to `CTLD_Next.lua`.
3. Optionally add a second trigger loading your `CTLD_userConfig.lua` (configuration overrides).

### Dynamic load (development)

For live development without rebuilding the `.miz` each time:

1. Set `CTLD_SOURCE_PATH` in `tools/CTLD_loader.lua` to the absolute path of your local `src/` directory.
2. In the Mission Editor, add a **DO SCRIPT FILE** trigger pointing to `tools/CTLD_loader.lua`.
3. Reload the mission in DCS (`Left Shift + R`) after editing source files.

### Required sound files

Beacon homing requires two audio files in the mission. Add two **Sound to Country** actions (pick an unused country like Australia so no player hears them at mission start):

| File | Purpose |
|------|---------|
| `assets/beacon.ogg` | Main beacon tone (heard by most aircraft ADF) |
| `assets/beaconsilent.ogg` | Silent beacon (FC3 aircraft — prevents audio bleed) |

If these files are missing, radio beacons will not work.

---

## Configuration

All configuration lives in `CTLD_userConfig.lua` (or in a DO SCRIPT block after the main script). Every parameter is read via `ctld.gs("paramName")` internally — never call `config:getSetting()` directly.

### Language

```lua
ctld.language = "en"   -- "en" | "fr" | "es" | "ko"
```

### Pickup and Dropoff Zones

Pickup zones are trigger zones (or ship unit names) where transport units can load troops and crates. Name the trigger zone to match an entry in `ctld.pickupZones`.

```lua
-- { "Zone name or Ship Unit Name", "smoke color", limit (-1 = unlimited), "ACTIVE (yes/no)", side (0=both / 1=RED / 2=BLUE), flagNumber (optional) }
ctld.pickupZones = {
    { "pickzone1",  "blue",  -1, "yes", 0 },
    { "pickzone2",  "red",   -1, "yes", 0 },
    { "pickzone3",  "none",  -1, "yes", 0 },
    { "pickzone9",  "none",   5, "yes", 1 },    -- limit 5 groups, RED only
    { "pickzone10", "none",  10, "yes", 2 },    -- limit 10 groups, BLUE only
    { "pickzone11", "blue",  20, "no",  2 },    -- starts inactive
    { "USA Carrier","blue",  10, "yes", 0, 1001 }, -- ship unit name, stores count in flag 1001
}
```

Smoke colours: `"green"` `"red"` `"white"` `"orange"` `"blue"` `"none"`

Disable all smoke globally: `ctld.disableAllSmoke = true`

Dropoff zones trigger AI units to automatically unload troops:

```lua
-- { "Zone name", "smoke color", side (1=RED / 2=BLUE / 0=both) }
ctld.dropOffZones = {
    { "dropzone1", "green",  2 },
    { "dropzone2", "blue",   2 },
    { "dropzone5", "none",   1 },
}
```

AI transport units auto-load at pickup zones and auto-unload at dropoff zones without needing to stop. Aircraft must be on the ground.

### Waypoint Zones

Dropped or spawned troops automatically move toward the center of an active waypoint zone if their coalition matches.

```lua
-- { "Zone name", "smoke color", "ACTIVE (yes/no)", side (0=both / 1=RED / 2=BLUE) }
ctld.wpZones = {
    { "wpzone1", "green", "yes", 2 },
    { "wpzone2", "none",  "no",  1 },   -- starts inactive
}
```

Activate / deactivate at runtime: see [Mission Editor Script Functions](#zones).

### Transport Unit Setup

**Auto-registration (recommended):** enable `ctld.addPlayerAircraftByType = true` — CTLD automatically registers any human player boarding an aircraft type listed in `ctld.aircraftTypeTable`. No manual name list needed.

**Manual registration:** add the **Pilot Name** (unit name in ME) to `ctld.transportPilotNames`:

```lua
ctld.transportPilotNames = {
    "helicargo1",
    "helicargo2",
    "helicargo3",
    "c130pilot1",
}
```

> Each player transport should be in its own group (single unit). Otherwise other players in the same group receive radio commands they should not have.

AI transport units auto-load and auto-unload when inside the appropriate zones.

**Vehicles in cargo aircraft** — list the vehicle types loadable into large transport aircraft:

```lua
ctld.vehiclesForTransportBLUE = { "M1045 HMMWV TOW", "M1043 HMMWV Armament" }
ctld.vehiclesForTransportRED  = { "BRDM-2", "BTR_D" }
```

### Logistic Units

Transport helicopters can spawn crates when within `ctld.maximumDistanceLogistic` (default 200 m) of a logistic unit. Any static object can serve as a logistics point.

```lua
ctld.logisticUnits = {
    "logistic1",
    "logistic2",
    "logistic3",
}
```

### Spawnable Crates

Crates are identified by weight (must be unique). The weight determines what unit assembles on unpacking.

```lua
ctld.spawnableCrates = {
    ["Ground Forces"] = {
        { weight = 1400, desc = "HMMWV - TOW",  unit = "M1045 HMMWV TOW",     side = 2 },
        { weight = 1200, desc = "HMMWV - MG",   unit = "M1043 HMMWV Armament", side = 2 },
        { weight = 1700, desc = "BTR-D",         unit = "BTR_D",                side = 1 },
        { weight = 1900, desc = "BRDM-2",        unit = "BRDM-2",               side = 1 },
        { weight = 1100, desc = "HMMWV - JTAC",  unit = "Hummer",               side = 2 },
        { weight = 1500, desc = "SKP-11 - JTAC", unit = "SKP-11",               side = 1 },
        { weight = 200,  desc = "2B11 Mortar",   unit = "2B11 mortar" },
        { weight = 500,  desc = "SPH 2S19 Msta", unit = "SAU Msta",             side = 1, cratesRequired = 3 },
        { weight = 501,  desc = "M-109",         unit = "M-109",                side = 2, cratesRequired = 3 },
    },
    ["AA Crates"] = {
        { weight = 210, desc = "Stinger",           unit = "Stinger manpad",    side = 2 },
        { weight = 215, desc = "Igla",              unit = "SA-18 Igla manpad", side = 1 },
        -- HAWK System (3 crates required, assembled by CTLDCrateAssemblyManager)
        { weight = 1000, desc = "HAWK Launcher",    unit = "Hawk ln",           side = 2 },
        { weight = 1010, desc = "HAWK Search Radar",unit = "Hawk sr",           side = 2 },
        { weight = 1020, desc = "HAWK Track Radar", unit = "Hawk tr",           side = 2 },
        { weight = 1021, desc = "HAWK Repair",      unit = "HAWK Repair",       side = 2 },
        -- KUB System (2 crates required)
        { weight = 1026, desc = "KUB Launcher",     unit = "Kub 2P25 ln",       side = 1 },
        { weight = 1027, desc = "KUB Radar",        unit = "Kub 1S91 str",      side = 1 },
        { weight = 1025, desc = "KUB Repair",       unit = "KUB Repair",        side = 1 },
    },
}
```

`cratesRequired` forces assembly of N identical crates within 100 m before the unit can be unpacked. Omit for single-crate items. Do not use on HAWK / KUB (they use a multi-type assembly system).

AA system limits per coalition:

```lua
ctld.AASystemLimitRED  = 20
ctld.AASystemLimitBLUE = 20
```

### Custom Troop Templates

Define custom infantry group compositions for loading at pickup zones:

```lua
ctld.loadableGroups = {
    { name = "Assault Squad", side = 2, inf = 4, mg = 2, at = 2, aa = 1, mortar = 1 },
    { name = "Recon Team",    side = 2, inf = 2, mg = 1 },
    { name = "AT Section",    side = 1, at = 4, inf = 2 },
}
```

These appear as sub-menu entries when loading troops from a pickup zone.

### JTAC Configuration

```lua
ctld.JTAC_LIMIT_RED       = 10     -- max JTAC crates for RED
ctld.JTAC_LIMIT_BLUE      = 10     -- max JTAC crates for BLUE
ctld.JTAC_dropEnabled     = true   -- allow JTAC crate spawn from F10 menu
ctld.JTAC_maxDistance     = 10000  -- JTAC line-of-sight range (meters)

ctld.JTAC_smokeOn_RED     = true
ctld.JTAC_smokeOn_BLUE    = true
ctld.JTAC_smokeColour_RED = 4      -- 0=Green 1=Red 2=White 3=Orange 4=Blue
ctld.JTAC_smokeColour_BLUE= 1

ctld.JTAC_smokeOffset_x   = 0.0   -- smoke offset from target (meters)
ctld.JTAC_smokeOffset_z   = 0.0

ctld.JTAC_jtacStatusF10   = true   -- F10 JTAC Status menu
ctld.JTAC_location        = true   -- include target coords in JTAC message
ctld.location_DMS         = false  -- DMS format instead of decimal degrees
ctld.JTAC_lock            = "all"  -- "vehicle" | "troop" | "all"

ctld.JTAC_allowStandbyMode     = true  -- toggle lasing on/off via F10
ctld.JTAC_laseSpotCorrections  = true  -- lead-target correction (wind + speed)
ctld.JTAC_allowSmokeRequest    = true  -- manual smoke request via F10
ctld.JTAC_allow9Line           = true  -- 9-line request via F10

ctld.enableAutoOrbitingFlyingJtacOnTarget = false  -- drone JTACs orbit over lased target
```

### Parachute Configuration

Virtual parachute drop simulates wind drift for crates, troops and vehicles.

```lua
ctld.enableParachuteDrop    = true   -- master switch
ctld.parachuteWindFactor    = 1.0    -- 1.0 = realistic drift; increase for more drift
ctld.parachuteDriftSeconds  = 30     -- simulated fall duration (seconds)
ctld.parachuteMinAltitude   = 200    -- minimum altitude (meters) to enable chute
ctld.parachuteMaxAltitude   = 8000   -- maximum altitude for drop
ctld.parachuteGroupSpread   = 50     -- dispersion radius for troop groups (meters)
```

Enable per-unit-type in `ctld.unitActions`:

```lua
ctld.unitActions["UH-1H"] = { canParachute = true, ... }
```

### Slingload Configuration

Virtual slingload uses hover detection instead of DCS sling physics (avoids crash bugs).

```lua
ctld.slingLoad              = false   -- false = virtual hover-load; true = real DCS slingload
ctld.minimumHoverHeight     = 7.5     -- minimum hover altitude for pick-up (meters)
ctld.maximumHoverHeight     = 12.0    -- maximum hover altitude
ctld.maxDistanceFromCrate   = 5.5     -- maximum horizontal distance from crate center
ctld.hoverTime              = 10      -- seconds to hold hover to complete load
ctld.maxSlingloadSpeed      = 80      -- max speed in km/h before crate is lost (virtual mode)
```

### FOB Configuration

```lua
ctld.enabledFOBBuilding    = true   -- enable FOB construction
ctld.cratesRequiredForFOB  = 3      -- large crates needed; small crates count as 1/3
ctld.troopPickupAtFOB      = true   -- troops can be picked up at a built FOB
ctld.buildTimeFOB          = 120    -- FOB construction delay (seconds)
ctld.radioSound            = "beacon.ogg"
ctld.radioSoundFC3         = "beaconsilent.ogg"
ctld.deployedBeaconBattery = 30     -- beacon battery life (minutes)
```

---

## Mission Editor Script Functions

### Troops

**Preload an AI transport with troops:**
```lua
CTLDTroopManager.getInstance():preLoadTransport("helicargo1", 10)
-- legacy: ctld.preLoadTransport("helicargo1", 10, true)
```

**Spawn extractable group at a trigger zone:**
```lua
-- Simple count
ctld.spawnGroupAtTrigger("blue", 10, "spawnTrigger", 1000)

-- Custom composition
ctld.spawnGroupAtTrigger("blue", { mg=1, at=2, aa=1, inf=4, mortar=1 }, "spawnTrigger", 2000)
```

**Spawn extractable group at a point:**
```lua
ctld.spawnGroupAtPoint("red", 10, { x=1, y=2, z=3 }, 1000)
```

**Register pre-placed groups as extractable (CTLD_userConfig.lua):**
```lua
-- Groups placed in the Mission Editor that players can extract via F10 menu
_cfg.settings["extractableGroups"] = {
    "rescue_team_alpha",
    "downed_pilot_1",
}
```

These groups are registered at CTLD init. Any group not found at that time is skipped.

**Force load / unload an AI unit:**
```lua
ctld.loadTransport("helicargo1")
ctld.unloadTransport("helicargo1")
```

**Auto-unload near enemies (continuous trigger):**
```lua
ctld.unloadInProximityToEnemy("helicargo1", 500)  -- 500 m search radius
```

### Zones

**Activate / deactivate a pickup zone:**
```lua
ctld.activatePickupZone("pickzone3")
ctld.deactivatePickupZone("pickzone3")
```

**Change remaining groups at a pickup zone:**
```lua
ctld.changeRemainingGroupsForPickupZone("pickzone1",  5)   -- add 5 groups
ctld.changeRemainingGroupsForPickupZone("pickzone1", -3)   -- remove 3 groups
```

**Activate / deactivate a waypoint zone:**
```lua
ctld.activateWaypointZone("wpzone1")
ctld.deactivateWaypointZone("wpzone1")
```

**Create an extract zone** (troops dropped here disappear; flag counts them):
```lua
ctld.createExtractZone("extractzone1", 2, -1)
-- param 1: trigger zone name
-- param 2: flag number to accumulate troop count
-- param 3: smoke colour (0=Green … 4=Blue; -1=none)

ctld.removeExtractZone("extractzone1", 2)
```

**Count extractable units / groups in a zone (continuous trigger):**
```lua
ctld.countDroppedUnitsInZone( "zoneName", blueFlag, redFlag)
ctld.countDroppedGroupsInZone("zoneName", blueFlag, redFlag)
```

### Crates

**Watch a zone and store crate count in a flag (continuous trigger):**
```lua
ctld.cratesInZone("crateZone", 1)   -- stores count in flag 1 every 5 s
```

**Spawn a crate at a trigger zone:**
```lua
-- side: "blue" or "red"
-- weight: must match an entry in ctld.spawnableCrates
ctld.spawnCrateAtZone("blue", 500, "crateSpawnTrigger")
ctld.spawnCrateAtZone("red",  500, "crateSpawnTrigger")
```

**Spawn a crate at a point:**
```lua
ctld.spawnCrateAtPoint("blue", 500, { x=20, y=10, z=20 })
-- tip: Unit.getByName("pilotName"):getPoint() gives a valid point
```

### JTAC

**Activate a mission-editor JTAC:**
```lua
ctld.JTACAutoLase("JTAC1", 1688)                          -- default smoke + all targets
ctld.JTACAutoLase("JTAC1", 1688, false, "all")            -- no smoke, all targets
ctld.JTACAutoLase("JTAC1", 1688, true,  "vehicle")        -- smoke on, vehicles only
ctld.JTACAutoLase("JTAC1", 1688, true,  "troop",   1)     -- smoke on, troops only, Red smoke
ctld.JTACAutoLase("JTAC1", 1688, true,  "all",     4,     -- Blue smoke + SRS radio
    { freq = "251.50", mod = "AM", name = "JTAC one" })
```

`JTAC1` is the **group name** in the Mission Editor. The group must contain exactly one unit.

**Stop auto-lase:**
```lua
ctld.JTACAutoLaseStop("JTAC1")
```

> JTAC units deployed by crate unpack auto-activate immediately and need no DO SCRIPT call.

**Unit priority targeting** — include `"hpriority"` or `"priority"` in the DCS unit name to affect which target the JTAC locks first. High-priority units are lased before medium-priority units, which come before everything else.

**SRS speech** requires `DCS-SimpleTextToSpeech.lua` loaded with `STTS.DIRECTORY` and `STTS.SRS_PORT` set. If configured, the JTAC speaks 9-lines and target data over the computed FM frequency (30 MHz + code formula) or the `_radio` parameter frequency.

### Beacons

**Create a radio beacon at a trigger zone:**
```lua
ctld.createRadioBeaconAtZone("beaconZoneBlue", "blue", 20)
-- param 3: duration in minutes
-- optional param 4: beacon name shown in F10 list
```

The beacon broadcasts on HF/FM, UHF and VHF simultaneously. Frequencies are drawn from coalition pools.

---

## Subscribing to CTLD Events

v2 replaces the v1 catch-all `ctld.addCallback` with typed subscriptions. Each event fires only the relevant handlers — no `if/elseif` chain required.

```lua
-- v1 (deprecated — still works via legacy wrapper)
ctld.addCallback(function(event)
    if event.id == ctld.events.S_EVENT_CRATE_SPAWNED then ... end
end)

-- v2 (preferred)
EventDispatcher.getInstance():subscribe("OnCrateSpawned", function(evt)
    -- evt.crateName, evt.coalition, evt.spawnedBy, evt.position
    trigger.action.outText("Crate spawned: " .. evt.crateName, 10)
end)
```

Full event catalogue: [`docs/specs/CTLD_Events.md`](docs/specs/CTLD_Events.md)

Selected events:

| Event | Key fields |
|-------|-----------|
| `OnCrateSpawned` | `crateName`, `coalition`, `spawnedBy`, `position` |
| `OnCrateLoaded` | `crateName`, `transportName`, `playerName` |
| `OnCrateUnpacked` | `unitName`, `unitType`, `builtBy`, `position` |
| `OnVehiclePacked` | `vehicleName`, `vehicleType`, `packedBy` |
| `OnTroopsBoarded` | `groupName`, `transportName`, `troopCount` |
| `OnTroopsDeployed` | `groupName`, `deployedBy`, `position` |
| `OnTroopsExtracted` | `groupName`, `extractedBy`, `extractZone` |
| `OnFOBDeployed` | `fobName`, `position`, `coalition` |
| `OnBeaconDropped` | `beaconId`, `frequency`, `modulation`, `coalition` |
| `OnJTACLaseStart` | `jtacName`, `targetName`, `laserCode` |
| `OnMMCrateDetected` | `staticName`, `position` |

---

## In-Game F10 Menu

The CTLD F10 menu is built dynamically per transport unit. It only shows actions that are currently possible (e.g. "Unload Troops" only appears when troops are aboard).

Menu structure:

```
F10 Other / [Transport Name]
├── Troop Commands
│   ├── Load Troops          (at pickup zone)
│   ├── Load [Custom Group]  (custom template entries)
│   ├── Unload Troops        (on ground with troops aboard)
│   ├── Parachute Troops     (in air, if canParachute enabled)
│   └── Fast Rope Troops     (low altitude, if enabled)
├── Crate Commands
│   ├── Spawn Crate          (at logistic zone: sub-menu by category)
│   ├── Load Crate           (hover above crate, or menu if loadCrateFromMenu=true)
│   ├── Drop Crate           (releases loaded crate)
│   ├── Unpack Crate         (on ground, assembles unit)
│   ├── Slingload Release    (virtual sling: release in flight)
│   ├── Slingload Cut        (virtual sling: emergency cut)
│   └── Pack Vehicle         (pack a nearby ground vehicle into crates)
├── JTAC Commands
│   ├── Spawn JTAC           (at logistic zone)
│   └── JTAC Status          (all active JTACs)
├── FOB Commands
│   ├── Spawn FOB Crate      (at logistic zone)
│   └── Build FOB            (when enough FOB crates dropped)
├── FARP Commands
│   └── Deploy FARP          (scene: sequence of static spawns around heli)
├── Beacon Commands
│   └── Drop Beacon
└── Smoke Commands
    └── Drop Smoke
```

---

## Troop Operations

**Loading** — land (or hover, for helicopters) inside a pickup zone. Select **Load Troops** from the F10 menu. AI transports load automatically on entering a zone.

**Default group composition** (when `ctld.numberOfTroops` ≥ 6):
- 2 × MG soldiers (M249 / AKS-74)
- 2 × RPG soldiers (or AT)
- 1 × Stinger / Igla (if `ctld.spawnStinger = true`)
- Remainder: standard infantry

**Custom templates** — configure `ctld.loadableGroups` for named groups with exact compositions (see [Custom Troop Templates](#custom-troop-templates)).

**Deploying** — land at the destination. Select **Unload Troops**. Troops spawn around the aircraft with a search radius of `ctld.maximumSearchDistance` for enemies.

**Fast rope** — at low altitude (`ctld.fastRopeMaximumHeight`, default 18 m), troops are deployed directly below the helicopter without landing.

**Parachute** — in flight above `ctld.parachuteMinAltitude`, select **Parachute Troops**. Each soldier drifts individually based on wind and fall time.

---

## Crate Operations

**Spawn** — at a logistic unit, select **Spawn Crate → [Category] → [Crate type]**.

**Load (virtual hover-load)** — hover between `ctld.minimumHoverHeight` and `ctld.maximumHoverHeight` within `ctld.maxDistanceFromCrate` of the crate for `ctld.hoverTime` seconds. Menu option also available if `ctld.loadCrateFromMenu = true`.

**Drop** — select **Drop Crate** in flight. With virtual slingload active, the crate drifts from the drop point based on speed and altitude (inertia simulation).

**Unpack** — land near a dropped crate. Select **Unpack Crate** — the crate is replaced by the corresponding unit. Multi-crate items (e.g. SPH requiring 3 crates) require all crates within 100 m before unpacking.

---

## Virtual Parachute Drop

When `ctld.enableParachuteDrop = true` and the unit type has `canParachute = true`:

- The menu shows **Parachute [Troops / Crate / Vehicle]** when airborne above `ctld.parachuteMinAltitude`.
- Each item drifts individually: wind vector × `ctld.parachuteWindFactor` × `ctld.parachuteDriftSeconds`.
- Troops land dispersed within `ctld.parachuteGroupSpread` meters of each other.

---

## Virtual Slingload

When `ctld.slingLoad = false` (default):

1. Hover above the crate within height/distance tolerances for `ctld.hoverTime` seconds → crate auto-loads.
2. In flight, select **Slingload Release** to drop the crate at the current position; the crate drifts forward based on current speed and altitude.
3. Select **Slingload Cut** to drop immediately (emergency; crate falls straight down).
4. If airspeed exceeds `ctld.maxSlingloadSpeed` km/h, the crate is lost.

When `ctld.slingLoad = true`: DCS native sling physics are used (may cause crashes on some versions).

---

## Forward Operating Base (FOB)

A FOB provides a new crate spawn point and optionally a troop pickup point anywhere on the map.

1. Load FOB crates at a logistic zone (large crates require large aircraft; small crates count as 1/3).
2. Drop `ctld.cratesRequiredForFOB` large crates (or equivalent in small) within 100 m of each other.
3. Select **Build FOB** — after `ctld.buildTimeFOB` seconds, the FOB spawns with a radio beacon.
4. The built FOB appears in F10 as a new logistic point for crate spawning.
5. If `ctld.troopPickupAtFOB = true`, troops can also be loaded there.

Event `OnFOBDeployed` fires when construction completes.

---

## FARP Deployment

A FARP (Forward Arming and Refuelling Point) is deployed as a scene: a sequence of static objects (helipads, fuel trucks, shelters) spawn around the helicopter.

1. At a logistic zone, spawn and load a FARP crate.
2. Fly to the desired deployment site and land.
3. Select **Deploy FARP** — the scene executes step-by-step over several seconds.
4. The deployed FARP becomes active in DCS for rearming and refuelling.

---

## Radio Beacons

Beacons broadcast on HF/FM, UHF and VHF simultaneously. Frequencies are drawn from coalition pools to avoid conflicts.

**Deploying via F10** — land (or hover), select **Drop Beacon** from the menu. The beacon appears on the F10 map.

**Deploying via script** — `ctld.createRadioBeaconAtZone("zone", "blue", 30, "Waypoint Alpha")`

**Battery life** — configured by `ctld.deployedBeaconBattery` (minutes). After expiry the beacon stops transmitting; deploy a new one.

**ADF tuning by aircraft:**

| Aircraft | Band | Notes |
|----------|------|-------|
| A-10C/II | UHF | ADF page in EHSI |
| Ka-50 | UHF | ARK-22 |
| Mi-8 / Mi-24 | VHF/FM | ARC-9 |
| UH-1H | VHF | ADF |
| All others | FM | Tune to displayed frequency |

---

## JTAC Auto-Lase

**Mission-editor JTACs** — place the JTAC unit in a dedicated single-unit group. Activate via `ctld.JTACAutoLase("GroupName", laserCode)`. See full syntax in [Mission Editor Script Functions → JTAC](#jtac).

**Crate-deployed JTACs** — spawn a JTAC crate (`HMMWV - JTAC` or `SKP-11 - JTAC`), drop it, and unpack it. The JTAC auto-activates immediately.

**Target priority** — include `hpriority` or `priority` in the unit name (Mission Editor) to control lasing order.

**F10 menu** — if `ctld.JTAC_jtacStatusF10 = true`, a **JTAC Status** entry lists all active JTACs, their target, laser code and options (toggle lasing, request smoke, request 9-line).

**Drone orbit** — if `ctld.enableAutoOrbitingFlyingJtacOnTarget = true`, flying JTAC units (drones) orbit above their lased target; they return to their flight plan when no target is visible.

---

## Recon and Target Marking

CTLD includes a recon layer that places enemy contacts as F10 map markers.

**Activate via F10** — select **Recon Scan** from the transport menu. Contacts within scan range appear as icons on the F10 map.

**Auto-refresh** — enable periodic re-scan via **Toggle Auto-Refresh** in the F10 menu.

**Events fired:**

| Event | When |
|-------|------|
| `OnReconScan` | Manual scan triggered |
| `OnReconScanRefresh` | Auto-refresh cycle |
| `OnReconLayerToggled` | Map layer shown/hidden |

---

## AA System Construction

Multi-crate AA systems are assembled by `CTLDCrateAssemblyManager`. All required crates must be dropped within 100 m of each other.

| System | Side | Crates required |
|--------|------|-----------------|
| HAWK | BLUE | Launcher + Search Radar + Track Radar |
| KUB | RED | Launcher + Radar |
| Stinger MANPAD | BLUE | 1 crate |
| Igla MANPAD | RED | 1 crate |

**Rearming** — drop an additional Launcher crate near an assembled system and unpack it to rearm.

**Repair** — drop a dedicated Repair crate near the damaged system and unpack it.

**Limits** — `ctld.AASystemLimitRED` and `ctld.AASystemLimitBLUE` cap the number of fully functional systems per coalition.

---

## Vehicle Pack

Pack a ground vehicle into crates for air transport, then reassemble it on the other side.

**Packing:**
1. Land near a packable vehicle (within `ctld.maximumDistancePackableUnitsSearch` meters).
2. The F10 menu shows **Pack Vehicle → [vehicle name]** under Crate Commands.
3. Selecting it destroys the vehicle and spawns the required number of crates around the helicopter.

**Unpacking:**
1. Drop the crates at the destination.
2. Land near them and select **Unpack Crate** — the vehicle reassembles.

Event `OnVehiclePacked` fires on successful pack.

---

## Migration from v1

All 22 legacy `ctld.*` functions are preserved as thin wrappers in `src/compat/legacy_api.lua`. Each wrapper logs a deprecation warning and delegates to the equivalent v2 manager method. **Existing missions continue to work without changes.**

Selected migration table (full table in [`docs/dev-guide.md`](docs/dev-guide.md)):

| v1 call | v2 equivalent |
|---------|--------------|
| `ctld.spawnGroupAtTrigger(name, zone, side)` | `CTLDTroopManager.getInstance():spawnGroupAtTrigger(...)` |
| `ctld.JTACAutoLase(group, code, smoke)` | `CTLDJTACManager.getInstance():autoLase(...)` |
| `ctld.spawnCrateAtZone(type, zone, side)` | `CTLDCrateManager.getInstance():spawnCrateAtZone(...)` |
| `ctld.activatePickupZone(zone)` | `CTLDZoneManager.getInstance():activatePickupZone(zone)` |
| `ctld.addCallback(fn)` | `EventDispatcher.getInstance():subscribe("OnEventName", fn)` |

For the full migration guide including the v1 `addCallback` → typed events transition, see [`docs/dev-guide.md §7`](docs/dev-guide.md).

---

## Developer Guide

See [`docs/dev-guide.md`](docs/dev-guide.md) for:

- Repository structure (`src/`, `tests/`, `tools/`, `docs/`, `source/`)
- Architecture overview (singleton managers, EventDispatcher)
- How to add a new module
- Event pub/sub patterns
- Build instructions (local `merger.cmd`, CI via GitHub Actions)
- Unit testing with busted (no DCS required)
- Full v1 → v2 migration guide

**Build locally:**
```
cd tools/merger_V2
./merger.cmd
```
Output: `CTLD_Next.lua` at repo root.

**CI:** every push to `master` or `feature_*` branches runs Lua lint, merge build, and busted tests automatically. Every `v*` tag creates a GitHub Release with `CTLD_Next.lua` attached.
