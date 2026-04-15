# DCS-CTLD Modernization Plan

> **This is the single source of truth for all ongoing work.**
> Status: **In Progress** | Branch: `feature_modularisation_and_Config` → target `master` | Target: CTLD v2.0

---

## Vision

Rewrite CTLD as a modern, modular, and testable Lua project while
preserving backward compatibility with existing missions.
Deliverable: single `.lua` file produced by `merger_V2/merge_CTLD.ps1`.

---

## Architectural decisions

| # | Topic | Decision |
| - | ----- | -------- |
| 1 | Module split | ✅ **Done** — `src/` files concatenated → `CTLD_futur.lua` by `merger_V2/merge_CTLD.ps1`. Order: `merger_V2/listToMerge.txt` |
| 2 | OOP | ✅ **Done** — `src/lib/class.lua` created (P1). All entity classes refactored. |
| 3 | MIST | ✅ **Done** — all `mist.*` calls replaced by `ctld.utils.*`. No active `mist.*` call in `src/` |
| 4 | Legacy API | ⚪ Planned — wrappers in `src/compat/legacy_api.lua` (Phase 4). Long term v3: removed |
| 5 | Lua env | Lua 5.1 DCS sandbox, desanitized server (`io`, `os`, `lfs` accessible) |
| 6 | Testing | ⚪ Planned — busted + DCS/MIST mocks in CI + in-game test missions (Phase 5) |
| 7 | Docs | 🟡 Partial — `documentation/` in-repo started. MkDocs future. |
| 8 | i18n | ✅ **Done** — `src/CTLD_i18n*.lua` (EN/FR/ES/KO), `ctld.tr()` at all sites, generator `merger_V2/generate_i18n_dicts.ps1` |
| 9 | Branching | Feature branches `feature/<description>`. `master` stays stable |
| 10 | Events | ✅ **Done** — 38 CTLD events specified. EventDispatcher ✅. CTLDDCSEventBridge ✅. StateManager + Coalition supprimés (absorbés par managers). C1 impl ✅ [2026-04-02]. |
| 11 | Scenes | ✅ **Done** — `src/scenes/` (9 files). Auto-register via `CTLDSceneManager.getInstance():registerSceneModel(...)` |
| 12 | Registry | ✅ **Done** — `src/lib/CTLD_objectRegistry.lua` relocated. Scope: spawn descriptors + scenes only. |
| 13 | Core bridge | ✅ **Done** — `CTLDDCSEventBridge` + `CTLDPlayerTracker` specs validated. C1 impl ✅ [2026-04-02]. |
| 14 | Review | Ongoing — for every implemented file: analyse → propose improvements → validate → fix before moving on |

---

## Progress overview

| Phase | Description | Status |
| ----- | ----------- | ------ |
| **0** | Specification & Architecture | ✅ 100% — all events + features specs done |
| **1** | Dead code cleanup (`source/`) | ⚪ To do (non-blocking) |
| **2** | Module split + OOP (`src/`) | ✅ ~100% impl ✅ / R1-R5 ✅ / FA+FB+FC+FD+FE ✅ / scenes fob/farp ✅ / Q1 ✅ [2026-04-15] / Q2-Q5 pending |
| **3** | MIST middleware | ✅ Done |
| **4** | Legacy API compatibility | ⚪ After Phase 2 |
| **5** | Unit tests (busted) | ⚪ After Phase 2 |
| **6** | CI infrastructure | ✅ Done — `.github/workflows/ci.yml` (lint + build) [2026-04-15] |
| **7** | i18n cleanup + tooling | ✅ Done |
| **8** | Documentation | 🟡 Partial |

---

## PRIORITY ORDER — Next steps

```text
── FONDATIONS IMPLÉMENTÉES, RECETTE COMPLÈTE ─────────────────────────────────
✅ P1  src/lib/class.lua + objectRegistry          recette: N/A (lib interne)
✅ C1  src/CTLD_core.lua                           recette: 9/9  100% [2026-04-02]
✅ M1  src/CTLD_zone.lua                           recette: 9/9  100% [2026-04-02]
✅ M2  src/CTLD_beacon.lua                         recette: 5/5  100% [2026-04-02]
✅ M3  src/CTLD_recon.lua                          recette: 5/5  100% [2026-04-02]
✅ M4  src/CTLD_fob.lua                            recette: 4/4 + F-90/F-93 visual ✅ 100% [2026-04-14]
✅ M5  src/CTLD_vehicle.lua                        recette: 10/10 100% [2026-04-07]
✅ M6  src/CTLD_aasystem.lua                       recette: 6/6  100% [2026-04-07]
✅ M7  src/CTLD_player.lua                         recette: 7/7  100% [2026-04-07]

── IMPLÉMENTÉS — RECETTE MANQUANTE ──────────────────────────────────────────
✅ R1  src/CTLD_crate.lua  (CTLDCrate + CTLDCrateManager)
       recette: 11/11  100% [2026-04-07]
       bugfixes: getDistance caller manquant dans getCratesInRange + checkAssemblyReady

✅ R2  src/CTLD_troop.lua  (CTLDTroopGroup + CTLDTroopManager)
       recette: 8/8  100% [2026-04-07]

✅ R3  src/CTLD_jtac.lua  (CTLDJTAC + CTLDJTACManager)
       recette: 8/8  100% [2026-04-07]

✅ R4  src/CTLD_sceneManager.lua  (CTLDSceneManager)
       recette: 7/7  100% [2026-04-14]
         U-43: singleton + registerSceneModel  9/9
         U-44: CtldScene step execution engine  8/8
         F-42: playScene guards  4/4
         F-43: FARP Alpha structure validation  11/11
         F-44: fobScene self-registration  10/10
         F-90: fobScene structure + spawn visuel  18/18 PASS ✅ [2026-04-14]
         F-91: farpScene structure + spawn visuel  24/24 PASS ✅ [2026-04-14]
         bugfix: CTLD_farpScene.lua — stepsDatas→steps, polar.dist→polar.distance, prescript 50m ref point
         F-92: FOB beacon au centroid (overridePosition)  13/13 PASS ✅ [2026-04-14]
         bugfix: CTLD_beacon.lua — dropBeacon overridePosition param (supprime getPointAt12Oclock inexistant)
         bugfix: CTLD_fob.lua — beacon spawné au centroid FOB, pas sous le transport
         F-93: FOB flow complet (fobScene + beacon)  visual ✅ [2026-04-14]

✅ R5  src/CTLD_menu.lua + CTLD_player.lua + tous managers  (buildMenu Option D)  [2026-04-08]
       Architecture: registerMenuSection() + configKey gateway + order sort
       Fix: CTLDTroopManager._instance migré de local→public + init() appelé dans getInstance()
       Recette: F-48→F-56 45/45 PASS ✅ + F-45→F-47 visual checks ✅ 3/3 PASS [2026-04-08]

── FEATURES À IMPLÉMENTER ───────────────────────────────────────────────────
✅  FD  Feature D — Custom LoadableGroups API (CTLDTroopManager)
        implémenté dans _registerTemplates() — validé R2 [2026-04-07]

✅  FC  Feature C — MM crate detection (INIT-B OnMMCrateDetected)
        registerMMCrate() + OnMMCrateDetected ajouté — validé F-41 [2026-04-07]

✅  FE  Feature E — CTLD log file dédié (ctld.utils.log → ctld.log)
        implémenté dans CTLD_utils.lua (initLog/log/closeLog/reopenLogAppend) [2026-04-07]

✅  FA  Feature A — Virtual parachute (crates + troops + vehicles)  [2026-04-08]
        CTLDParachuteEffect + NullParachuteEffect (src/lib/)
        ctld.utils.calcDropPosition() ajouté (CTLD_utils.lua)
        8 params parachute + canParachute dans unitActions (CTLD_config.lua)
        parachuteCrates/Troops/Vehicle() + menus F10 conditionnels (canParachute)
        spawnVehicleAt() ajouté à CTLDVehicleSpawner
        Recette FA: F-57→F-64 33/33 PASS ✅ [2026-04-08]
        Fix: groupName→templateName, vehicle:transit()→setState(DELIVERED), carrierUnitName→loadTransportName

✅  FB  Feature B — Virtual slingload  [2026-04-08]
        CTLDCrateManager: checkHoverStatus() polling 1s, releaseSlingload(), cutSlingload()
        canSlingload dans unitActions, maxSlingloadSpeed param, inTransitOnSlingload flag
        P1 overspeed loss, P3 Release/Cut menus distincts, P2 inertia drift (calcDropPosition)
        Recette FB: F-65→F-71 22/22 PASS ✅ [2026-04-08]

── APRÈS PHASE 2 COMPLÈTE ───────────────────────────────────────────────────
✅  Q1  src/compat/legacy_api.lua  [2026-04-15]
        22 wrappers (Troops×6, Zones×10, Crates×3, Beacons×1, JTAC×3) — thin delegates
        Bugfix: CTLDTroopManager:deploy() exzZone.flagName → exzZone.objectiveFlag
        New: CTLDZoneManager:isUnitInZone() (méthode manquante appelée par deploy)
        Nouvelles méthodes managers: TroopManager×8, ZoneManager×6, CrateManager×4,
          BeaconManager×1, JTACManager×3
        Pack Vehicle implémenté (gap critique comblé) [2026-04-15]:
          CTLDCrateManager:spawnCrate() — coalition.addStaticObject, model auto (load/sling/dynamic),
            OnCrateSpawned publié, crate enregistrée
          CTLDCrateManager:findDescriptorByUnitType() — lookup par champ unit dans spawnableCrates
          CTLDVehicleSpawner:findPackableVehicles(transport) — scan ground units coalition,
            filtre par maximumDistancePackableUnitsSearch, match descriptor par typeName
          CTLDVehicleSpawner:packVehicle(transportName, packableUnitName, playerObj) —
            destroy vehicle, spawn cratesRequired crates (secteur avant hélico / arrière C-130),
            OnVehiclePacked publié, menu rafraîchi
          CTLDVehicleSpawner:_checkPackingLanding() — timer 3s, transition inAir→landed → refreshForUnit
          Menu F10 "Pack Vehicle" (sous Crate Commands) — populé dynamiquement avec véhicules packables
        Recette Q1: U-81→U-83 (62/62) + F-94→F-99 (86/86) = 148/148 PASS ✅
⚪  Q2  tests/ busted complets
✅  Q3  GitHub Actions CI  [2026-04-15]
        .github/workflows/ci.yml créé
        Job 1 — lua-lint : choco install lua 5.4 → loadfile() syntax-check sur tous src/**/*.lua
        Job 2 — build    : merge PowerShell (replique merger.cmd sans pause interactif) → CTLD_futur.lua
          - fichiers manquants (AA scenes, userConfig) → warning seulement (parité merger.cmd)
          - artifact uploadé 7 jours (actions/upload-artifact@v4)
        Triggers : push sur master + feature_* , PR vers master
⚪  Q4  source/ dead code cleanup (non-bloquant)
⚪  Q5  documentation complète
        ⚪  Q5-A  documentation/missionmaker_guide.md — section Legacy API
                   Objectif : guide MM expliquant les 22 fonctions legacy encore utilisables
                   Contenu requis :
                     - Avertissement dépréciation + lien vers EventDispatcher pour addCallback
                     - Tableau des 22 fonctions : signature legacy → équivalent v2
                     - 1 exemple d'utilisation par groupe (Troops, Zones, Crates, Beacon, JTAC)
                     - Note sur pack vehicle (ctld.spawnCrateAtZone/Point maintenant fonctionnel)
                   Statut : ⚪ À faire

        ⚪  Q5-B  documentation/dev-guide.md (ou migration-v2.md) — section Legacy API
                   Objectif : guide développeur pour migrer un script v1 vers l'API v2 native
                   Contenu requis :
                     - Principe des wrappers (thin delegate + logWarning)
                     - Tableau de migration : ctld.XXX → Manager:method() pour chaque wrapper
                     - Exemple de migration complet (DO SCRIPT v1 → v2)
                     - Explication du remplacement de ctld.addCallback par EventDispatcher:subscribe()
                     - Note sur pack vehicle : CTLDVehicleSpawner:packVehicle() + findPackableVehicles()
                   Statut : ⚪ À faire
```

---

## Phase 0 — Specification & Architecture ✅ COMPLETE

### 0.1 — CTLD Events (38 events — 100%)

| Module | Events | Spec file |
| ------ | ------ | --------- |
| Crates | 6 ✅ | `Specs/project_ctld_events_crates_spec.md` |
| Troops | 6 ✅ | `Specs/project_ctld_events_troops_spec.md` |
| JTAC | 9 ✅ | `Specs/project_ctld_events_jtac_spec.md` |
| Beacons | 5 ✅ | `Specs/project_ctld_events_beacons_spec.md` |
| Recon | 4 ✅ | `Specs/project_ctld_events_recon_spec.md` |
| Zones + Vehicles + FOB | 6 ✅ | `Specs/project_ctld_events_zones_vehicles_fob_spec.md` |
| Core Init | 1 ✅ (OnMMCrateDetected) | covered by S2 — memory: project_feature_c_spec.md |
| **Total** | **38** | |

### 0.2 — Features

| ID | Feature | Status |
| -- | ------- | ------ |
| A | Virtual parachute drop (crates + troops + vehicles) | ✅ Spec validée (2026-04-02) — memory: project_feature_a_spec.md |
| B | Virtual slingload | ✅ Integrated in crates spec |
| C | MM crate detection at startup (INIT-B + OnMMCrateDetected) | ✅ Spec validée (2026-04-02) — memory: project_feature_c_spec.md |
| D | Custom LoadableGroups API for mission makers | ✅ Spec validated — to implement |
| E | Dedicated CTLD log file (`ctld.log`) | ⚪ To implement (spec in §2.6) |

### 0.3 — Architecture validated

- `CTLDObjectRegistry` scope rule: spawn descriptors + scenes only
- `CTLDCrateAssemblyManager`: AA system assembly manager name retained
- `CTLDDCSEventBridge`: single DCS event handler — spec in `Specs/project_dcs_event_bridge_spec.md`
- `CTLDPlayerTracker`: player tracking without MIST — spec in `Specs/project_ctld_player_tracker_spec.md`
- INIT-A: AI transport detection — spec in `Specs/project_ctld_init_a_spec.md`
- INIT-B: MM crate detection — spec in `Specs/project_ctld_init_b_spec.md`
- INIT-C: MM JTAC detection — spec in `Specs/project_ctld_init_c_spec.md`
- Init order: EventBridge → PlayerTracker → CoreManager (INIT-A/B/C) → other managers

### 0.4 — Build infrastructure ✅

- `merger_V2/merge_CTLD.ps1`: concatenates `src/` → `CTLD_futur.lua`
- `merger_V2/listToMerge.txt`: canonical load order
- `merger_V2/generate_loader.ps1`: generates `CTLD_loader.lua` for dev
- `merger_V2/generate_i18n_dicts.ps1`: syncs i18n keys across languages

---

## Phase 1 — Dead code cleanup (`source/`) ⚪ NON-BLOCKING

**When**: Before v2 release. Not blocking implementation.

| Task | Detail |
| ---- | ------ |
| 1.1 | Remove 18+ commented-out code blocks (see `AS-IS-ANALYSIS.md` §12) |
| 1.2 | Remove unused functions: `ctld.tools.getRelativeBearing`, `ctld.tools.isValueInIpairTable` |
| 1.3 | Remove state variables never read |
| 1.4 | Clean `--TODO`/`--FIXME`/debug markers |
| 1.5 | Validate: `test-mission.miz`, `test-dev-dynamic.miz` |

---

## Phase 2 — Module split + OOP (`src/`) 🟡 IN PROGRESS

### 2.0 — OOP micro-framework ✅ DONE (P1)

Create `src/lib/class.lua`:

```lua
local function class(base)
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
```

Then refactor existing files to use it: `CTLD_crate.lua`, `CTLD_troop.lua`, `CTLD_jtac.lua`, `CTLD_sceneManager.lua`, `CTLD_objectRegistry.lua`.

### 2.1 — Implemented files ✅

| File | Classes | Date |
| ---- | ------- | ---- |
| `src/CTLD_config.lua` | CTLDConfig (singleton) | 2026-03-31 |
| `src/CTLD_objectRegistry.lua` | CTLDObjectRegistry | 2026-03-31 |
| `src/CTLD_crate.lua` | CTLDCrate, CTLDCrateManager | 2026-03-31 |
| `src/CTLD_troop.lua` | CTLDTroopGroup, CTLDTroopManager | 2026-03-31 |
| `src/CTLD_jtac.lua` | CTLDJTAC, CTLDJTACDetector, CTLDJTACMessage, CTLDJTACManager | 2026-04-01 |
| `src/CTLD_core.lua` | EventDispatcher, CTLDDCSEventBridge, CTLDPlayerTracker, CTLDCoreManager | 2026-04-02 |
| `src/CTLD_zone.lua` | CTLDTroopZone, CTLDLogisticZone, CTLDZoneManager | 2026-04-02 |
| `src/CTLD_beacon.lua` | CTLDBeacon, CTLDBeaconManager | 2026-04-02 |
| `src/CTLD_recon.lua` | CTLDReconRenderer, CTLDReconManager | 2026-04-02 |
| `src/CTLD_fob.lua` | CTLDFOB, CTLDFOBManager | 2026-04-03 |
| `src/scenes/CTLD_mineFieldScene.lua` | mineFieldScene, setLandMine, setLandMineAuto | 2026-04-09 — ✅ recette complète (U-74→U-75, F-83→F-87, visual ✅) |
| `src/scenes/CTLD_farpScene.lua` | farpScene | 2026-04-01 — ⚠️ recette visuelle requise |
| `src/scenes/CTLD_fobScene.lua` | fobScene | 2026-04-03 (rewritten) — ⚠️ recette visuelle requise |
| ~~`src/scenes/CTLD_aa*Scene.lua`~~ | ~~6 fichiers AA~~ | 🗑️ **Supprimés 2026-04-07** — compositions AA dans CTLDCrateAssemblyManager.TEMPLATES |

> **⚠️ Recette scènes** : chaque scène (farp, fob, mineField) nécessite une validation visuelle en mission DCS —
> vérifier que les objets apparaissent au bon endroit et dans le bon ordre.
> Les asserts Witchcraft couvrent la logique (events, états) mais **pas le rendu 3D**.
> Avant chaque test de scène : demander à l'utilisateur de confirmer visuellement le résultat dans DCS.

### 2.2 — Remaining files (priority order)

| # | File | Classes | Status | Spec |
| - | ---- | ------- | ------ | ---- |
| P1 | `src/lib/class.lua` + `src/lib/CTLD_objectRegistry.lua` | — (OOP framework + registry relocation) | ✅ **Done** | — |
| C1 | `src/CTLD_core.lua` | CTLDCoreManager, CTLDDCSEventBridge, CTLDPlayerTracker, EventDispatcher | ✅ **Done** [2026-04-02] | — |
| M1 | `src/CTLD_zone.lua` | CTLDTroopZone, CTLDLogisticZone, CTLDZoneManager | ✅ **Done** [2026-04-02] | `Specs/project_ctld_events_zones_vehicles_fob_spec.md` |
| M2 | `src/CTLD_beacon.lua` | CTLDBeacon, CTLDBeaconManager | ✅ **Done** [2026-04-02] | `Specs/project_ctld_events_beacons_spec.md` |
| M3 | `src/CTLD_recon.lua` | CTLDReconRenderer, CTLDReconManager | ✅ **Done** [2026-04-02] | `Specs/project_ctld_events_recon_spec.md` |
| M4 | `src/CTLD_fob.lua` | CTLDFOB, CTLDFOBManager | ✅ **Done** | `Specs/project_ctld_events_zones_vehicles_fob_spec.md` |
| M5 | `src/CTLD_vehicle.lua` | CTLDVehicle, CTLDVehicleSpawner | ✅ **Done** [2026-04-07] | `Specs/project_ctld_events_zones_vehicles_fob_spec.md` |
| M6 | `src/CTLD_aasystem.lua` | CTLDCrateAssemblyManager | ✅ **Done** [2026-04-07] | — |
| M7 | `src/CTLD_player.lua` | CTLDPlayer, CTLDPlayerManager | ✅ **Done** [2026-04-07] | — |

### 2.3 — ~~CTLDCoalition~~ / ~~CTLDStateManager~~ — SUPPRIMÉS ✅

**Décision 2026-04-02** : ces deux classes sont supprimées du plan.

Les managers OOP absorbent naturellement l'état coalition sans couche intermédiaire :

- État coalition-splitté → convention uniforme `self._data = { [1]={}, [2]={} }` dans chaque manager
- Les 50+ branches `if coalition==1` du legacy disparaissent par construction (indexation directe par `coalitionId`)
- Pas de registre central nécessaire : chaque manager est propriétaire de son état

**C1 se réduit à 4 classes :** CTLDDCSEventBridge, CTLDPlayerTracker, CTLDCoreManager, EventDispatcher.

### 2.5 — Features implementation

| Feature | Depends on | Status |
| ------- | ---------- | ------ |
| B — Virtual slingload | CTLDCrateManager | ✅ Spec integrated |
| D — Custom LoadableGroups API | CTLDTroopManager (already implemented) | ⚪ To implement |
| C — MM crate detection | CTLDCoreManager INIT-B | ⚪ To specify fully |
| A — Virtual parachute (crates + troops + vehicles) | All managers | ⚪ To specify |
| E — Dedicated CTLD log file | CTLDUtils (`ctld.utils.log`) | ⚪ To implement |

### 2.6 — Feature E: Dedicated CTLD log file (`ctld.log`)

**Goal:** write all CTLD log messages to a dedicated file in addition to DCS.log, so developers can review CTLD output without filtering through the full DCS log.

**Behaviour:**

- All messages routed through `ctld.utils.log()` are written simultaneously to `DCS.log` (unchanged) and to `ctld.log`.
- `ctld.log` is located in the local repository root (same directory as the mission or the dev workspace). Exact path resolved via `lfs.writedir()` at init time.
- File is opened in append mode at CTLD init; closed (flushed) on each write to avoid data loss on crash.
- Each line: `[HH:MM:SS][LEVEL] message` (wall-clock time via `os.date`).

**Activation:**

- Config param: `CTLD_enableDevLog` (boolean, default `false`).
- When `false`: zero overhead, `io.open` is never called.
- Requires desanitized DCS server (`io` and `lfs` accessible). If `io` is not available and the param is `true`, a single DCS.log warning is emitted and the feature silently disables itself.

**Implementation location:** `ctld.utils.log()` in `src/CTLD_utils.lua` — add the file-write path alongside the existing `env.info` call.

**Config key to add in `CTLDConfig`:**

```lua
CTLD_enableDevLog = false,   -- developer only; requires desanitized server
```

---

## Phase 3 — MIST middleware ✅ COMPLETE

All `mist.*` API calls replaced by `ctld.utils.*` in `src/`.
Remaining "mist" occurrences in source are string literals in log messages only.

---

## Phase 4 — Legacy API compatibility ⚪ AFTER PHASE 2

| Task | Detail |
| ---- | ------ |
| 4.1 | List all public `ctld.*` functions used in DO SCRIPT triggers (README reference) |
| 4.2 | Create `src/compat/legacy_api.lua` with wrappers |
| 4.3 | Each wrapper logs deprecation warning with new API name |
| 4.4 | `documentation/migration-v2.md`: old → new migration guide |

```lua
-- Example wrapper pattern:
function ctld.spawnCrateAtZone(_side, _weight, _zone)
    ctld.logWarning("DEPRECATED: use CTLDCrateManager:spawnAtZone()")
    return CTLDCrateManager.getInstance():spawnAtZone(_side, _weight, _zone)
end
```

---

## Phase 5 — Unit tests ⚪ AFTER PHASE 2

| Task | Detail |
| ---- | ------ |
| 5.1 | Set up busted (Lua 5.1) + luarocks |
| 5.2 | `test/mocks/dcs_env.lua`: stubs for `trigger`, `Unit`, `Group`, `coalition`, `land`, `timer`, `world`, `env` |
| 5.3 | Unit tests: `src/lib/class.lua`, `src/CTLD_utils.lua`, `src/CTLD_config.lua`, `src/compat/legacy_api.lua` |
| 5.4 | In-game test mission: troop/crate/JTAC/FOB/beacon flows |

---

## Phase 6 — CI infrastructure 🟡 PARTIAL

| Task | Status | Detail |
| ---- | ------ | ------ |
| 6.1 | ✅ Done | `merger_V2/merge_CTLD.ps1` → `CTLD_futur.lua` |
| 6.2 | ⚪ | GitHub Actions — run busted tests |
| 6.3 | ⚪ | GitHub Actions — build `CTLD_futur.lua` on push |
| 6.4 | ⚪ | GitHub Actions — release artifact on tag |
| 6.5 | ⚪ | GitHub Actions — MkDocs deploy to GitHub Pages |
| 6.6 | ✅ Done | i18n lint: `merger_V2/generate_i18n_dicts.ps1` |

---

## Phase 7 — i18n ✅ COMPLETE

| File | Content |
| ---- | ------- |
| `src/CTLD_i18n.lua` | Runtime engine: `ctld.tr()`, language selection, fallback EN |
| `src/CTLD_i18n_en.lua` | English reference keys (authoritative) |
| `src/CTLD_i18n_fr.lua` | French translations |
| `src/CTLD_i18n_es.lua` | Spanish translations |
| `src/CTLD_i18n_ko.lua` | Korean translations |
| `merger_V2/generate_i18n_dicts.ps1` | Key sync — detects drift between languages |

Rules: all player-visible strings use `ctld.tr()`. Key added to EN first, propagated by generator.

---

## Phase 8 — Documentation 🟡 PARTIAL

| Audience | File | Status |
| -------- | ---- | ------ |
| Mission maker | `documentation/missionmaker_guide.md` | 🟡 Started |
| Developer (CDC) | `documentation/CTLD_CDC.md` | 🟡 Substantial |
| Developer (menus) | `documentation/CTLD_Menu_Architecture.html` | ✅ Done |
| MkDocs / GitHub Pages | — | ⚪ To set up |

Remaining: complete missionmaker_guide (JTAC, crate config, LoadableGroups), player guide, migration-v2.md, MkDocs setup.

---

## Module completion status

| Module | Impl | Spec | Recette | % recette | Notes |
| ------ | ---- | ---- | ------- | --------- | ----- |
| Config (`CTLD_config.lua`) | ✅ | ✅ | ⚪ | 0% | lib interne, risque faible — recette à écrire |
| Utils (`CTLD_utils.lua`) | ✅ | N/A | ✅ | 100% | M9: U-67→U-73 + F-78→F-80, 118/118 PASS [2026-04-09] |
| Menu (`CTLD_menu.lua`) | ✅ | ✅ | ✅ | 100% | M8: U-57→U-66 + F-72→F-77 + F-81→F-82 visual ✅ [2026-04-09] |
| SceneManager (`CTLD_sceneManager.lua`) | ✅ | ✅ | ✅ | 100% | R4: U-43→U-44 + F-42→F-44, 2026-04-07 |
| **Crates** (`CTLD_crate.lua`) | ✅ | ✅ | ✅ | **100%** | R1 ✅ [2026-04-07] |
| **Troops** (`CTLD_troop.lua`) | ✅ | ✅ | ✅ | **100%** | R2 ✅ [2026-04-07] |
| **JTAC** (`CTLD_jtac.lua`) | ✅ | ✅ | ✅ | **100%** | R3 ✅ [2026-04-07] |
| Core (`CTLD_core.lua`) | ✅ | ✅ | ✅ | 100% | 9/9 PASS [2026-04-02] |
| Zones (`CTLD_zone.lua`) | ✅ | ✅ | ✅ | 100% | 9/9 PASS [2026-04-02] |
| Beacons (`CTLD_beacon.lua`) | ✅ | ✅ | ✅ | 100% | 5/5 PASS [2026-04-02] |
| Recon (`CTLD_recon.lua`) | ✅ | ✅ | ✅ | 100% | 5/5 PASS [2026-04-02] |
| FOB (`CTLD_fob.lua`) | ✅ | ✅ | ✅ | 100% | 4/4 PASS ⚠️ visuel scène [2026-04-03] |
| Vehicles (`CTLD_vehicle.lua`) | ✅ | ✅ | ✅ | 100% | 10/10 PASS [2026-04-07] |
| AA System (`CTLD_aasystem.lua`) | ✅ | ✅ | ✅ | 100% | 6/6 PASS [2026-04-07] |
| Player (`CTLD_player.lua`) | ✅ | ✅ | ✅ | 100% | 7/7 PASS [2026-04-07] |
| mineFieldScene | ✅ | ✅ | ✅ | 100% | U-74→U-75 + F-83→F-87, 40/40 PASS visual ✅ [2026-04-09] — quinconce + setLandMineAuto + showMinefieldOnF10Map |
| Scenes fob/farp | ✅ | ✅ | ⚪ | 0% | ⚠️ visuel DCS requis |
| i18n | ✅ | ✅ | N/A | — | outillage générateur ✅ |
| ObjectRegistry (`lib/CTLD_objectRegistry.lua`) | ✅ | ✅ | ✅ | 100% | U-54→U-56 43/43 PASS [2026-04-08] |
| Feature A (parachute) | ✅ | ✅ | ✅ | 100% | F-57→F-64 33/33 PASS [2026-04-08] |
| Feature B (slingload) | ✅ | ✅ | ✅ | 100% | F-65→F-71 22/22 PASS [2026-04-08] |
| Feature C (MM crate) | ✅ | ✅ | ✅ | 100% | registerMMCrate + OnMMCrateDetected, F-41 PASS [2026-04-07] |
| Feature D (LoadableGroups) | ✅ | ✅ | ✅ | 100% | U-76→U-80 + F-88→F-89, 102/102 PASS [2026-04-14] |
| Feature E (CTLD log) | ✅ | ✅ | ⚪ | ~80% | initLog/log/closeLog dans CTLD_utils.lua [2026-04-07] — recette indirecte |

---

## Branching strategy

```text
master (stable v1.x)
  └── feature_modularisation_and_Config  (v2 in progress)
        └── feature/<description>        (sub-features)
```

Tags: `v2.0-alpha.1`, `v2.0-beta.1`, `v2.0-rc.1`, `v2.0`

---

## Risks and mitigations

| Risk | Impact | Mitigation |
| ---- | ------ | ---------- |
| Gameplay regressions after OOP refactor | High | Review discipline (analyse → fix) + test missions |
| CTLDCoalition/StateManager scope too large | Medium | Implement incrementally within CTLDCore session |
| Legacy API coverage incomplete | Medium | README-driven: list all documented `ctld.*` functions |
| Scene positions incorrect (AA systems) | Low | Initial estimates — validate in test mission, adjust |
