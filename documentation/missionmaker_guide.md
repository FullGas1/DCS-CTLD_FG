# CTLD — Mission Maker Guide

> This document is a living reference, updated progressively as features are developed.
> It covers what mission makers need to know to configure and extend CTLD in their missions.

---

## Table of Contents

1. [Configuration](#1-configuration)
2. [Translations & Localisation](#2-translations--localisation)
3. [Scene Deployment](#3-scene-deployment)
4. [Zone Setup](#4-zone-setup)
5. [Troop Transport](#5-troop-transport)

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
A scene is defined as an ordered list of **steps**.  Each step is one of three types:

#### Polar step — deterministic position
Object is spawned at a fixed distance and angle relative to the helicopter's position and heading (snapshot taken at unpack time).

| Field | Type | Description |
|---|---|---|
| `objectsDescDbKey` | string | Key of the object to spawn (see table below) |
| `polar` | table | `{ distance=N, angle=N }` — distance in metres, angle in degrees relative to aircraft heading |
| `relativeHeadingInDegrees` | number | Heading of the spawned object relative to aircraft heading |
| `relativeAltitudeInMeters` | number | Altitude offset from helicopter altitude |
| `delayAfterPreviousStep` | number | Seconds to wait after this step before triggering the next |
| `func` | function *(optional)* | Callback `function(unit, spawnedObj, step)` executed after spawn |

#### Axis step — random-axis position
Object(s) are spawned along a randomly chosen axis radiating from the helicopter.  Useful when the mission maker wants placement that looks natural without hard-coding a bearing.

| Field | Type | Description |
|---|---|---|
| `objectsDescDbKey` | string | Key of the object to spawn |
| `axis` | table | `{ count=N, safeDistance=N, spacing=N }` — number of objects, distance to first object (m), spacing between objects (m) |
| `delayAfterPreviousStep` | number | Seconds to wait before next step |
| `func` | function *(optional)* | Callback `function(unit, spawnedObj, step)` — `spawnedObj` is the last object spawned |

#### Func-only step — no spawn
No object is spawned; only the callback runs.  Use for completion messages, warehouse stocking, zone registration, etc.

| Field | Type | Description |
|---|---|---|
| `delayAfterPreviousStep` | number | Seconds to wait before next step |
| `func` | function | Callback `function(unit, spawnedObj, step)` — `spawnedObj` is always `nil` |

All positioning is computed automatically relative to the helicopter's position and heading at the moment of unpacking. Coalition (BLUE/RED) is resolved automatically for coalition-aware objects (vehicles, infantry).

### What you need to do as a mission maker

**Step 1** — Declare your scene model in a mission script loaded after CTLD:
```lua
local myScene = {
    name  = "My FARP",
    steps = {
        -- polar step: helipad 100 m ahead, facing south relative to helicopter
        { objectsDescDbKey = "SINGLE_HELIPAD", polar = { distance=100, angle=0   },
          relativeHeadingInDegrees=180, relativeAltitudeInMeters=0, delayAfterPreviousStep=0 },
        -- polar step: tent 130 m ahead-right, 3 s after helipad
        { objectsDescDbKey = "FARP_Tent",      polar = { distance=130, angle=5   },
          relativeHeadingInDegrees=90,  relativeAltitudeInMeters=0, delayAfterPreviousStep=3 },
        -- axis step: scatter 3 ammo crates randomly around the helicopter
        { objectsDescDbKey = "ammo_cargo", axis = { count=3, safeDistance=30, spacing=8 },
          delayAfterPreviousStep=5 },
        -- func-only step: print completion message
        { delayAfterPreviousStep=0,
          func = function(unit, spawnedObj, step)
              trigger.action.outText("FARP ready at " .. unit:getName(), 10)
              return true
          end },
    },
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

## 4. Zone Setup

CTLD zones are declared directly in the **DCS Mission Editor** by naming your trigger zones with a structured convention. No scripting is required.

### 4.1 Naming convention

The zone name encodes its type and all parameters, separated by `_`.

> **Rule:** The `_` character is the field separator. It is **forbidden** inside any field value (zone name, flag name, etc.).

```
TYPE_name_param1_param2_..._paramN
```

CTLD reads all trigger zone names at mission start, parses those that match a known prefix, and registers them automatically.

### 4.2 Zone types and schemas

| Prefix | Zone type | Schema |
|---|---|---|
| `PKZ` | Pickup zone (troops) | `PKZ_name_smoke_limit_active_side` |
| `DOZ` | Drop-off zone | `DOZ_name_smoke_side` |
| `WPZ` | Waypoint zone | `WPZ_name_smoke_active_side` |
| `EXZ` | Extract zone | `EXZ_name_smoke` |
| `LGZ` | Logistic zone | `LGZ_name_side` |

**Parameter values:**

| Parameter | Values |
|---|---|
| `smoke` | `-1` none · `0` green · `1` red · `2` white · `3` orange · `4` blue |
| `limit` | `-1` unlimited · or any integer ≥ 1 |
| `active` | `1` active · `0` inactive at start |
| `side` | `0` both · `1` red · `2` blue |

> **Uniqueness:** two zones of the same prefix cannot share the same `name`. CTLD will report a conflict at startup.

---

### 4.3 PKZ — Pickup zone (troops only)

Players must land inside a pickup zone to load troops into their aircraft. The zone has a group limit: once depleted, no more troops can be loaded from it until groups are returned (unload inside the zone) or the counter is reset by a mission trigger.

**Schema:** `PKZ_name_smoke_limit_active_side`

| Example name | Meaning |
|---|---|
| `PKZ_base1_0_-1_1_2` | Pickup zone "base1", green smoke, unlimited, active, blue only |
| `PKZ_fob2_-1_5_1_0` | Pickup zone "fob2", no smoke, max 5 groups, active, both sides |
| `PKZ_staging_1_10_0_1` | Pickup zone "staging", red smoke, max 10 groups, **inactive at start**, red only |

> An inactive zone (`active=0`) can be activated at runtime via a DCS trigger calling:
> ```lua
> CTLDZoneManager.getInstance():setZoneActive("staging", "pickup", true)
> ```

---

### 4.4 DOZ — Drop-off zone

Marks a designated drop-off area. Triggers automatic troop unload for AI transport aircraft that land inside. Human players see a smoke signal marking the zone.

**Schema:** `DOZ_name_smoke_side`

| Example name | Meaning |
|---|---|
| `DOZ_objective1_0_2` | Drop-off "objective1", green smoke, blue only |
| `DOZ_frontline_-1_0` | Drop-off "frontline", no smoke, both sides |

---

### 4.5 WPZ — Waypoint zone

When troops are deployed (fast-rope or unload) at a point that falls **inside** an active waypoint zone, they automatically march toward the **centre** of the zone instead of searching for the nearest enemy. Use this to direct freshly deployed troops toward a tactical objective.

**Schema:** `WPZ_name_smoke_active_side`

| Example name | Meaning |
|---|---|
| `WPZ_hill47_3_1_2` | Waypoint zone "hill47", orange smoke, active, blue only |
| `WPZ_bridge_-1_0_0` | Waypoint zone "bridge", no smoke, inactive at start, both sides |

> Activate or deactivate a waypoint zone at runtime to redirect troops during a mission phase:
> ```lua
> CTLDZoneManager.getInstance():setZoneActive("bridge", "waypoint", true)
> ```

---

### 4.6 EXZ — Extract zone

An extract zone silently **counts** the troops dropped inside it and stores the total in a DCS flag, instead of spawning them into combat. Use this as a mission scoring or phase-trigger mechanism.

**Schema:** `EXZ_name_smoke`

**Flag name:** automatically generated as `NAME_FLG` (uppercased).

| Example name | DCS flag created | Meaning |
|---|---|---|
| `EXZ_recup1_-1` | `RECUP1_FLG` | Extract zone "recup1", no smoke. Flag counts evacuated troops. |
| `EXZ_cas2_0` | `CAS2_FLG` | Extract zone "cas2", green smoke. |

> In the Mission Editor, use a **ONCE** condition trigger: `Flag RECUP1_FLG >= 20` to fire an action when 20 troops have been evacuated.

> The flag starts at 0 when the mission loads. Each troop dropped in the zone increments it by 1.

---

### 4.7 LGZ — Logistic zone

Defines a logistics base. Players must be inside a logistic zone to spawn crates from the F10 menu. Logistic zone resources are **unlimited** (only rate-limited: one crate every 40 seconds per player). The zone radius is set directly in the DCS trigger zone editor.

**Schema:** `LGZ_name_side`

| Example name | Meaning |
|---|---|
| `LGZ_depot1_2` | Logistic zone "depot1", blue only |
| `LGZ_farp_main_0` | Logistic zone "farp_main"… **INVALID** — `_` is forbidden inside `name`. Use `LGZ_farpmain_0` instead. |

> **FOBs** deployed during the mission automatically register as logistic zones — no configuration needed.

---

### 4.8 Startup validation report

At mission start, CTLD checks all trigger zone names and produces a **single merged report** if any issues are found. The report appears as an in-game message (visible in the Mission Editor when running a test) and is written to the DCS log.

Example report:
```
[CTLD] Zone name validation report — 2 issue(s):
  ERROR PKZ_base1_blue_X_1_2          expected 6 fields (prefix_name_smoke_limit_active_side), got 6
  ERROR EXZ_recup1_-1                 duplicate name 'recup1' for prefix EXZ (flag conflict: RECUP1_FLG)
```

Fix the names in the Mission Editor and re-run. No scripting needed.

---

### 4.9 Debug log (developers / mission testers)

Enable the dedicated CTLD log file to isolate CTLD messages from the DCS standard log:

```lua
-- CTLD_userConfig.lua
ctld.yamlConfigDatas = [[
  ctld.debug: true
  ctld.ctldLogPath: "C:\\Users\\aling\\github\\FullGas1\\DCS-CTLD_FG\\"
]]
```

CTLD writes all its log output to `<ctldLogPath>CTLD.log`. The DCS standard log is unaffected.

> **Requirement: desanitized DCS.** File I/O (`io.open`) is blocked on standard sanitized DCS installations. Keep `ctld.debug: false` (the default) on those machines — CTLD will log to the standard DCS log only and will not crash.

---

## 5. Troop Transport

### Overview

CTLD transports infantry teams between pickup zones (PKZ) and combat areas. The full cycle is:

```
PKZ (load) → aircraft → combat area (fast-rope / drop)
                      → EXZ (extraction zone, flag count only)
                      → PKZ (return to base, restores pool)
```

Troops are **never** physically on board the aircraft as DCS units — they are held in memory until deployed.

---

### F10 menu — "Troop Transport"

The menu appears automatically for all transport-capable aircraft inside or near a PKZ zone.

```
Troop Transport
  ├── Unload / Extract Troops     ← context-sensitive (see below)
  ├── Load Standard Group
  ├── Load Anti Air
  ├── ...
  ├── [Next page]                 ← appears if more than 9 templates
  └── Check Cargo
```

**"Unload / Extract Troops" behaviour (priority order):**

| Condition | Action |
|---|---|
| On ground + friendly dropped group nearby + no troops onboard | Extract group from combat |
| Has troops onboard + inside a PKZ zone | Return troops to base (restores zone pool) |
| Has troops onboard + not in PKZ | Fast-rope (if conditions met) or drop into combat / EXZ |

---

### Configuring loadable groups

Define the infantry templates available to players in `CTLD_userConfig.lua`:

```lua
ctld.loadableGroups = {
    { name = "Standard Group",  inf = 6, mg = 2, at = 2 },
    { name = "Anti Air",        inf = 2, aa = 3 },
    { name = "Anti Tank",       inf = 2, at = 6 },
    { name = "Mortar Squad",    mortar = 6 },
    { name = "JTAC Group",      inf = 4, jtac = 1 },
    { name = "Single JTAC",     jtac = 1 },
    -- side = 1 → RED only, side = 2 → BLUE only, omit for both
    { name = "BLUE Stingers",   inf = 2, aa = 4, side = 2 },
}
```

**Role keys:**

| Key | Unit type (BLUE / RED) | Equipment weight |
|---|---|---|
| `inf` | Soldier M4 GRG / Infantry AK | +5 kg |
| `mg` | Soldier M249 / Paratrooper AKS-74 | +10 kg |
| `at` | Paratrooper RPG-16 (both sides) | +7.6 kg |
| `aa` | Soldier stinger / SA-18 Igla manpad | +18 kg |
| `mortar` | 2B11 mortar (both sides) | +26 kg |
| `jtac` | Same model as `inf`, name tagged "JTAC" | +15+5 kg |

> A template with `jtac > 0` automatically triggers JTAC lasing upon deployment (laser code attributed by CTLDJtacManager).

---

### Key configuration parameters

| Parameter | Default | Description |
|---|---|---|
| `numberOfTroops` | `10` | Max troops per transport (applies to all aircraft unless overridden per type) |
| `enableFastRopeInsertion` | `true` | Allow fast-rope deployment (altitude + speed conditions required) |
| `fastRopeMaximumHeight` | `18.28` | Max AGL height (m) for fast-rope (≈ 60 ft) |
| `spawnDistanceInCircle` | `10` | Extra distance (m) added to aircraft safe-distance for the troop formation circle radius |
| `maxExtractDistance` | `125` | Max radius (m) to search for extractable friendly groups |
| `nbLimitSpawnedTroops` | `{0, 0}` | `{red, blue}` — max simultaneous troops in the field per coalition. `0` = unlimited |

**Per-aircraft type capacity override** (optional):

```lua
ctld.transportLimitByType = {
    ["UH-1H"]       = 8,
    ["CH-47D"]      = 30,
    ["Mi-8MT"]      = 12,
}
```

If a type is not listed, `numberOfTroops` applies.

---

### Troop formation at drop point

When troops are deployed, CTLD spawns the DCS group in a **circle** centred on the drop point. The radius is:

```
circleRadius = aircraft bounding-box half-length + ctld.gs("spawnDistanceInCircle")
```

This ensures infantry never spawns inside or under the aircraft. Larger aircraft (CH-47, C-130) automatically produce a larger circle. Units are evenly distributed around the circumference and all face the same heading as the deploying aircraft.

---

### Fast-rope conditions

Fast-rope deploys troops while the aircraft is still airborne. Conditions:

- `enableFastRopeInsertion = true`
- AGL altitude ≤ `fastRopeMaximumHeight + 3 m`
- Ground speed < 2.2 m/s (≈ 8 km/h)

If conditions are not met while airborne, CTLD refuses deployment and shows an error message. Land the aircraft to drop troops unconditionally.

---

### Extract zones (EXZ)

When troops are deployed inside an EXZ zone, **no DCS group is spawned**. Instead, the troop count is added to the zone's DCS flag. Use this to score evacuations or trigger mission phases.

See [§4.6 EXZ](#46-exz--extract-zone) for zone naming and flag conventions.

---

*— End of current content — further chapters to be added progressively —*
