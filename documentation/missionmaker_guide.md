# CTLD — Mission Maker Guide

> This document is a living reference, updated progressively as features are developed.
> It covers what mission makers need to know to configure and extend CTLD in their missions.

---

## Table of Contents

1. [Configuration](#1-configuration)
2. [Translations & Localisation](#2-translations--localisation)
3. [Scene Deployment](#3-scene-deployment)

---

## 1. Configuration

### Overview

CTLD comes with sensible defaults for all parameters. As a mission maker, you never need to touch the internal source files. All customisation is done in a single file: **`CTLD_userConfig.lua`**, loaded by your mission via a `DO SCRIPT FILE` trigger at mission start, **after** CTLD itself is loaded.

`CTLD_userConfig.lua` is free-form Lua: you only override what you want to change. Anything not declared keeps its default value.

### How configuration works internally

On startup, `CTLDConfig` loads all default values. It then reads `ctld.yamlConfigDatas` (the content of your `CTLD_userConfig.lua`) and applies your overrides on top of the defaults. Throughout the CTLD codebase, every parameter is accessed via:

```lua
ctld.gs("parameterName")   -- the only authorised access form
```

### Load order in the mission editor

Your triggers must fire in this order:

| Order | Action | File |
|---|---|---|
| 1 | DO SCRIPT FILE | `CTLD_userConfig.lua` |
| 2 | DO SCRIPT FILE | `CTLD.lua` (or `CTLD_loader.lua` in dev) |

### Customising parameters — `CTLD_userConfig.lua`

Only declare the parameters you want to override. Example:

```lua
-- CTLD_userConfig.lua
-- Only override what differs from the defaults.

ctld = ctld or {}
ctld.yamlConfigDatas = [[

ctld.enablePackingVehicles: true
ctld.maximumDistancePackableUnitsSearch: 350
ctld.cratesRequiredForFOB: 2
ctld.numberOfTroops: 8
ctld.maximumDistanceLogistic: 300
ctld.slingLoad: true

]]
```

Each line follows the pattern `ctld.parameterName: value`.

### Key configuration parameters

#### General behaviour

| Parameter | Default | Description |
|---|---|---|
| `enableCrates` | `true` | Enable crate spawning and unpacking |
| `enableAllCrates` | `true` | Show "all crates" shortcut menu entries |
| `slingLoad` | `false` | Use DCS sling-load physics instead of hover simulation |
| `hoverPickup` | `true` | Allow crate loading by hovering |
| `loadCrateFromMenu` | `true` | Allow crate loading via F10 menu |
| `forceCrateToBeMoved` | `true` | Crate must be moved at least once before unpacking |
| `disableAllSmoke` | `false` | Globally disable all smoke signals |

#### Distances (metres)

| Parameter | Default | Description |
|---|---|---|
| `maximumDistanceLogistic` | `200` | Max distance from logistics unit to load/spawn a crate |
| `maxExtractDistance` | `125` | Max distance from vehicle to troops for extraction |
| `maximumSearchDistance` | `4000` | Max distance for AI troops to search for enemies |
| `maximumMoveDistance` | `2000` | Max distance for AI troops to move from drop point |
| `minimumDeployDistance` | `1000` | Min distance from a friendly pickup zone to deploy a crate |
| `maximumDistancePackableUnitsSearch` | `200` | Max distance to search for packable vehicles |

#### Troops

| Parameter | Default | Description |
|---|---|---|
| `numberOfTroops` | `10` | Default / max troop group size per transport |
| `enableFastRopeInsertion` | `true` | Allow fast-rope deployment |
| `fastRopeMaximumHeight` | `18.28` | Max height (m) for fast-rope insertion |
| `spawnRPGWithCoalition` | `true` | Spawn a friendly RPG unit with coalition forces |
| `spawnStinger` | `false` | Spawn a Stinger/Igla soldier with groups of 6+ |

#### FOB

| Parameter | Default | Description |
|---|---|---|
| `enabledFOBBuilding` | `true` | Allow FOB construction from crates |
| `cratesRequiredForFOB` | `3` | Number of large crates to build a FOB |
| `troopPickupAtFOB` | `true` | Allow troop pickup at built FOBs |
| `buildTimeFOB` | `120` | FOB construction time (seconds) |
| `crateWaitTime` | `40` | Cooldown between crate spawns (seconds) |

#### Vehicles & packing

| Parameter | Default | Description |
|---|---|---|
| `enablePackingVehicles` | `true` | Allow vehicles to be packed back into crates |
| `vehiclesForTransportBLUE` | `{...}` | Vehicle types loadable onto BLUE fixed-wing transports |
| `vehiclesForTransportRED` | `{...}` | Vehicle types loadable onto RED fixed-wing transports |

#### AA systems

| Parameter | Default | Description |
|---|---|---|
| `AASystemLimitBLUE` | `20` | Max active AA systems for BLUE |
| `AASystemLimitRED` | `20` | Max active AA systems for RED |
| `AASystemCrateStacking` | `false` | Allow multiple crate sets to add extra launchers |
| `aaLaunchers` | `3` | Default number of launchers per AA system |

#### Beacons

| Parameter | Default | Description |
|---|---|---|
| `enabledRadioBeaconDrop` | `true` | Allow beacon deployment |
| `deployedBeaconBattery` | `30` | Beacon battery life (minutes) |
| `radioSound` | `"beacon.ogg"` | Sound file for beacon (must be added to mission) |

#### JTAC

| Parameter | Default | Description |
|---|---|---|
| `JTAC_LIMIT_BLUE` | `10` | Max JTAC crates for BLUE |
| `JTAC_LIMIT_RED` | `10` | Max JTAC crates for RED |
| `JTAC_dropEnabled` | `true` | Allow JTAC crate spawn from F10 |
| `JTAC_maxDistance` | `10000` | JTAC line-of-sight range (metres) |
| `JTAC_lock` | `"all"` | Lock target type: `"vehicle"`, `"troop"`, or `"all"` |
| `JTAC_allowStandbyMode` | `true` | Allow toggling lasing on/off |
| `JTAC_allow9Line` | `true` | Allow 9-line requests |

#### RECON

| Parameter | Default | Description |
|---|---|---|
| `reconF10Menu` | `true` | Enable the RECON F10 menu |
| `reconLosSearchRadius` | `2000` | RECON line-of-sight search radius (metres) |
| `reconLosMarkRadius` | `100` | RECON mark radius on F10 map (metres) |

### Customising spawnable crates

You can add new crate categories or entries without touching the defaults:

```lua
ctld = ctld or {}
ctld.yamlConfigDatas = [[...]]   -- your param overrides above

-- Add a new crate category (runs after CTLD loads)
ctld.spawnableCrates["My Vehicles"] = {
    { weight = 2000.01, desc = "My Custom Truck", unit = "Ural-375", side = 1 },
    { weight = 2000.02, desc = "My Custom Humvee", unit = "M1043 HMMWV Armament", side = 2, cratesRequired = 2 },
}
```

> **Weight uniqueness:** each crate `weight` value must be globally unique across all categories — CTLD uses it as the crate identifier. Use values outside the `1000–1006` range to avoid conflicts with built-in crates.

---

## 2. Translations & Localisation

### Available languages

CTLD ships with four built-in dictionaries:

| Code | Language |
|---|---|
| `en` | English (reference) |
| `fr` | French |
| `es` | Spanish |
| `ko` | Korean |

### Selecting a language

Open `source_futur/CTLD_i18n.lua` and uncomment the desired language line:

```lua
ctld.i18n_lang = "en"
--ctld.i18n_lang = "fr"
--ctld.i18n_lang = "es"
--ctld.i18n_lang = "ko"
```

Only one line should be active at a time. This file is intentionally separate from the main scripts so that non-developer translators can edit it without touching any logic.

### Fallback chain

If a translation key is missing or empty in the active language, CTLD falls back automatically:

1. Active language dictionary
2. English dictionary
3. The key itself (= the English text)

A message is **never** empty or nil.

### Overriding specific translations from your mission

You can override any translation string directly in `CTLD_userConfig.lua`, without modifying any CTLD source file:

```lua
-- CTLD_userConfig.lua
ctld = ctld or {}

-- Override specific translations for the active language
ctld.i18n_overrides = {
    fr = {
        ["Pack Vehicles"]   = "Empaqueter vehicules",
        ["Drop Beacon"]     = "Poser balise radio",
    },
    en = {
        ["CTLD Commands"]   = "Helicopter Commands",
    },
}
```

Overrides are applied at startup on top of the built-in dictionaries. You can override any language independently of the active language selector.

### Adding a new language

1. Create `source_futur/CTLD_i18n_XX.lua` following the English file as a template.
2. Add `CTLD_i18n_XX.lua` to `merger_futur/listToMerge.txt` (after the other dict files).
3. Rerun `merger_futur/generate_loader.cmd` to update the dev loader.
4. Activate the new language in `CTLD_i18n.lua`.
5. Run `merger_futur/generate_i18n_dicts.ps1` to check for missing keys.

---

## 3. Scene Deployment

### What it is
A **Scene** is a sequenced, time-delayed deployment of multiple DCS objects (statics and/or ground groups) triggered automatically when a player unpacks a designated crate. It allows mission makers to simulate realistic deployments — a FARP materializing piece by piece, a minefield being laid out — without any scripting beyond declaring the scene model.

### How it works
A scene is defined as an ordered list of **steps**. Each step specifies:
- `objectsDescDbKey` — the DCS object to spawn (key into the built-in objects database)
- `polar` — position relative to the deploying helicopter: `{ distance (m), angle (°) }`
- `relativeHeadingInDegrees` — heading of the spawned object
- `delayAfterPreviousStep` — seconds to wait after the previous step
- `func` *(optional)* — a Lua callback executed after the object spawns (e.g. stock a FARP warehouse)

All positioning is computed automatically by CTLD relative to the helicopter's position and heading at the moment of unpacking. Coalition (BLUE/RED) is resolved automatically for coalition-aware objects (vehicles, infantry).

### What you need to do as a mission maker

**Step 1** — Declare your scene model in a mission script loaded before CTLD:
```lua
local myScene = {
    name = "My FARP",
    stepsDatas = {
        { objectsDescDbKey = "SINGLE_HELIPAD", polar = { distance=100, angle=0   }, relativeHeadingInDegrees=180, delayAfterPreviousStep=0 },
        { objectsDescDbKey = "FARP_Tent",      polar = { distance=130, angle=5   }, relativeHeadingInDegrees=90,  delayAfterPreviousStep=3 },
        { objectsDescDbKey = "Fuel_Truck",     polar = { distance=110, angle=350 }, relativeHeadingInDegrees=0,   delayAfterPreviousStep=5 },
    }
}
CTLDSceneManager.getInstance():registerSceneModel(myScene)
```

**Step 2** — Add a crate entry in `CTLD_userConfig.lua` using the exact scene name as the `unit` field:
```lua
ctld.spawnableCrates["My Deployments"] = {
    { weight = 1008.01, desc = "My FARP", unit = "My FARP", cratesRequired = 1 },
}
```

**Step 3** — In the mission, make sure the crate is available at a logistics zone. Players load the crate, fly to the desired location, unpack it — the scene plays automatically.

### Available objects (`objectsDescDbKey`)
`FARP`, `SINGLE_HELIPAD`, `FARP_Tent`, `FARP_Ammo_Storage`, `Fuel_Truck`, `repare_Truck`, `FARP_Security_Guard`, `barrels_cargo`, `ammo_cargo`, `Cargo06`, `NF-2_LightOn`, `Windsock`, `Tower Crane`, `us carrier shooter`
> `Farp_FG_Petit_Helipad` requires a specific external mod — only use if the mod is installed on all clients.

### Built-in scenes (ready to use)
| Scene name | Description |
|---|---|
| `FARP Alpha` | Full FARP deployment: helipad, tent, ammo dump, fuel truck, repair truck, security squad, décor |
| `mineField` | Lays a configurable grid of landmines in front of the helicopter, marked on the F10 map |
| `FOB` | Forward Operating Base: outpost structure + watchtower, deployed from FOB crates |

---
*— End of current content — further chapters to be added progressively —*
