# CTLD v2 — Developer Guide

## 1. Repository structure

```
src/              Source modules (OOP, one class per file)
  lib/            Shared micro-libraries (class.lua, objectRegistry, parachute)
  scenes/         Scene data files (auto-registered at load time)
  compat/         Legacy v1 API wrappers (thin delegates, deprecated)
source/           Reference — original monolithic v1 CTLD.lua (read-only)
tools/
  merger_V2/      Build tooling: merge src/ → CTLD_futur.lua
  CTLD_loader.lua Dev loader for Witchcraft (live DCS injection)
tests/            busted unit tests (no DCS required)
  helpers/        DCS stubs + module loader
  specs/          *_spec.lua test files
recette/          Witchcraft integration tests (requires live DCS mission)
docs/             This guide + missionmaker_guide.md + specs/
assets/           Audio files (beacon.ogg)
missions/         Demo and test .miz files
```

---

## 2. Architecture overview

CTLD v2 uses a **singleton manager** pattern: one manager per domain, each
accessed via `Manager.getInstance()`. Managers communicate exclusively through
the internal event bus `EventDispatcher`.

```
CTLDCoreManager          ← orchestrator, owns init sequence
CTLDPlayerManager        ← tracks connected players, owns F10 menu
CTLDZoneManager          ← pickup / extract / waypoint zones
CTLDTroopManager         ← troops boarding / deploying / extracting
CTLDCrateManager         ← crate spawn / load / unload / assembly
CTLDVehicleSpawner       ← vehicle request / pack
CTLDFOBManager           ← FOB construction pipeline
CTLDBeaconManager        ← radio beacons
CTLDJTACManager          ← JTAC auto-lase / orbit
CTLDReconManager         ← recon layer + F10 map marks
CTLDCrateAssemblyManager ← AA system assembly
CTLDSceneManager         ← scene engine (FARP, FOB, minefield…)
CTLDDCSEventBridge       ← single DCS event handler, routes to managers
CTLDPlayerTracker        ← player connect/disconnect tracking (no MIST)
```

Configuration is read-only via `ctld.gs("paramName")` — never call
`config:getSetting()` directly.

---

## 3. Adding a new module

1. Create `src/CTLD_mymodule.lua` using the class pattern:

```lua
local CTLDMyManager = createClass("CTLDMyManager")
CTLDMyManager._instance = nil

function CTLDMyManager.getInstance()
    if not CTLDMyManager._instance then
        CTLDMyManager._instance = CTLDMyManager:new()
        CTLDMyManager._instance:init()
    end
    return CTLDMyManager._instance
end

function CTLDMyManager:init()
    -- setup
end
```

2. Add the filename to `tools/merger_V2/listToMerge.txt` in dependency order.
3. Add a `dofile(SRC .. "CTLD_mymodule.lua")` line in `tools/CTLD_loader.lua`
   at the same position.
4. Update `tests/helpers/loader.lua` with the same `dofile` line.
5. Write busted specs in `tests/specs/mymodule_spec.lua`.

---

## 4. Events

Publish:
```lua
EventDispatcher.getInstance():publish("OnMySomethingHappened", {
    unitName = "...",
    coalition = coalition.side.BLUE,
})
```

Subscribe (from another manager or external script):
```lua
EventDispatcher.getInstance():subscribe("OnMySomethingHappened", function(evt)
    -- evt.unitName, evt.coalition
end)
```

Full event catalogue: `docs/specs/CTLD_Events.md`

---

## 5. Build

**Local (Windows):**
```
cd tools/merger_V2
./merger.cmd
```
Output: `CTLD_futur.lua` at repo root (gitignored).

**CI (GitHub Actions):** automatic on push — see `.github/workflows/ci.yml`.

---

## 6. Testing

**busted (unit, no DCS):**
```
busted tests/specs/
```
Requires `luarocks install busted`.

**Witchcraft (integration, requires live DCS mission):**
```
node "%USERPROFILE%/.vscode-dcs-tools/bridge.js" "C:/path/to/recette/F-xx/test.lua"
```
Results in `recette/CTLD.log`.

---

## 7. Migration v1 → v2

### 7.1 Wrapper principle

All 22 v1 global functions (`ctld.spawnGroupAtTrigger`, `ctld.JTACAutoLase`,
etc.) are preserved as thin wrappers in `src/compat/legacy_api.lua`. Each
wrapper:
- Calls the equivalent v2 manager method
- Logs a deprecation warning to `ctld.log`

No behaviour change — existing missions continue to work unchanged.

### 7.2 Migration table

| v1 call | v2 equivalent |
|---|---|
| `ctld.spawnGroupAtTrigger(name, zone, side)` | `CTLDTroopManager.getInstance():spawnGroupAtTrigger(name, zone, side)` |
| `ctld.spawnGroupAtPoint(name, point, side)` | `CTLDTroopManager.getInstance():spawnGroupAtPoint(name, point, side)` |
| `ctld.preLoadTransport(unit, group)` | `CTLDTroopManager.getInstance():preLoadTransport(unit, group)` |
| `ctld.unloadTransport(unit)` | `CTLDTroopManager.getInstance():unloadTransport(unit)` |
| `ctld.loadTransport(unit, group)` | `CTLDTroopManager.getInstance():loadTransport(unit, group)` |
| `ctld.unloadInProximityToEnemy(unit)` | `CTLDTroopManager.getInstance():unloadInProximityToEnemy(unit)` |
| `ctld.activatePickupZone(zone)` | `CTLDZoneManager.getInstance():activatePickupZone(zone)` |
| `ctld.deactivatePickupZone(zone)` | `CTLDZoneManager.getInstance():deactivatePickupZone(zone)` |
| `ctld.changeRemainingGroupsForPickupZone(zone, n)` | `CTLDZoneManager.getInstance():changeRemainingGroups(zone, n)` |
| `ctld.activateWaypointZone(zone)` | `CTLDZoneManager.getInstance():activateWaypointZone(zone)` |
| `ctld.deactivateWaypointZone(zone)` | `CTLDZoneManager.getInstance():deactivateWaypointZone(zone)` |
| `ctld.createExtractZone(name, pt, r, side)` | `CTLDZoneManager.getInstance():createExtractZone(name, pt, r, side)` |
| `ctld.removeExtractZone(zone)` | `CTLDZoneManager.getInstance():removeExtractZone(zone)` |
| `ctld.countDroppedGroupsInZone(zone)` | `CTLDZoneManager.getInstance():countDroppedGroupsInZone(zone)` |
| `ctld.countDroppedUnitsInZone(zone)` | `CTLDZoneManager.getInstance():countDroppedUnitsInZone(zone)` |
| `ctld.cratesInZone(zone)` | `CTLDCrateManager.getInstance():startCrateCountWatcher(zone)` |
| `ctld.spawnCrateAtZone(type, zone, side)` | `CTLDCrateManager.getInstance():spawnCrateAtZone(type, zone, side)` |
| `ctld.spawnCrateAtPoint(type, pt, side)` | `CTLDCrateManager.getInstance():spawnCrateAtPoint(type, pt, side)` |
| `ctld.createRadioBeaconAtZone(zone, side, freq, mod)` | `CTLDBeaconManager.getInstance():createAtZone(zone, side, freq, mod)` |
| `ctld.JTACAutoLase(group, code, smoke)` | `CTLDJTACManager.getInstance():autoLase(group, code, smoke)` |
| `ctld.JTACStart(unit, code, smoke)` | `CTLDJTACManager.getInstance():startLase(unit, code, smoke)` |
| `ctld.JTACAutoLaseStop(group)` | `CTLDJTACManager.getInstance():stopAutoLase(group)` |

### 7.3 Replacing ctld.addCallback

v1 used a single catch-all callback:
```lua
-- v1
ctld.addCallback(function(event)
    if event.id == ctld.events.S_EVENT_CRATE_SPAWNED then
        -- handle
    end
end)
```

v2 uses targeted subscriptions:
```lua
-- v2
EventDispatcher.getInstance():subscribe("OnCrateSpawned", function(evt)
    -- evt.crateName, evt.coalition, evt.spawnedBy, evt.position
end)
```

Benefits: no `if/elseif` chain, only the relevant handler fires, multiple
subscribers supported per event.

### 7.4 Complete migration example

**v1 DO SCRIPT:**
```lua
ctld.spawnGroupAtTrigger("Alpha Squad", "LZ_NORTH", coalition.side.BLUE)
ctld.JTACAutoLase("ENEMY_ARMOUR", 1688, true)
ctld.addCallback(function(e)
    if e.id == ctld.events.S_EVENT_TROOPS_DEPLOYED then
        trigger.action.outText("Troops landed!", 10)
    end
end)
```

**v2 equivalent:**
```lua
local tm  = CTLDTroopManager.getInstance()
local jtac = CTLDJTACManager.getInstance()
local ed  = EventDispatcher.getInstance()

tm:spawnGroupAtTrigger("Alpha Squad", "LZ_NORTH", coalition.side.BLUE)
jtac:autoLase("ENEMY_ARMOUR", 1688, true)
ed:subscribe("OnTroopsDeployed", function(evt)
    trigger.action.outText("Troops landed!", 10)
end)
```

### 7.5 Pack vehicle (new in v2)

v1 had no functional pack vehicle. v2 implements:

```lua
-- Find packable vehicles near a transport
local vehicles = CTLDVehicleSpawner.getInstance():findPackableVehicles(transportUnit)

-- Pack one (destroys the vehicle, spawns crates)
CTLDVehicleSpawner.getInstance():packVehicle(transportName, vehicleName, playerObj)
```

The F10 "Pack Vehicle" submenu is populated automatically when the transport
lands near a packable vehicle.
