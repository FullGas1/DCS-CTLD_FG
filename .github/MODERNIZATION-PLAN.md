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
| **2** | Module split + OOP (`src/`) | 🟡 ~65% (C1+M1–M5 done, M6–M7+features pending) |
| **3** | MIST middleware | ✅ Done |
| **4** | Legacy API compatibility | ⚪ After Phase 2 |
| **5** | Unit tests (busted) | ⚪ After Phase 2 |
| **6** | CI infrastructure | 🟡 Build script done |
| **7** | i18n cleanup + tooling | ✅ Done |
| **8** | Documentation | 🟡 Partial |

---

## PRIORITY ORDER — Next steps

```text
✅ P1  src/lib/class.lua + refactor 4 files + relocate objectRegistry  [DONE]
✅ C1  src/CTLD_core.lua (EventDispatcher + CTLDDCSEventBridge + CTLDPlayerTracker + CTLDCoreManager)  [2026-04-02]
✅ M1  src/CTLD_zone.lua  [2026-04-02]
✅ M2  src/CTLD_beacon.lua  [2026-04-02]
✅ M3  src/CTLD_recon.lua  [2026-04-02]
✅ M4  src/CTLD_fob.lua   [2026-04-03]
✅ M5  src/CTLD_vehicle.lua  [2026-04-07]
🟡 M6  src/CTLD_aasystem.lua
🟡 M7  src/CTLD_player.lua
⚪  Q1  src/compat/legacy_api.lua      [after Phase 2 complete]
⚪  Q2  tests/ busted                  [after Phase 2 complete]
⚪  Q3  GitHub Actions CI              [after tests]
⚪  Q4  source/ dead code cleanup      [non-blocking, before v2 release]
⚪  Q5  documentation complete         [ongoing]
-- Specs manquantes (Phase 0 restante, non bloquantes pour C1) --
✅  S1  Feature A spec (virtual parachute)  [validé 2026-04-02]
✅  S2  Feature C spec (OnMMCrateDetected event)  [validé 2026-04-02]
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
| `src/scenes/CTLD_mineFieldScene.lua` | mineFieldScene | 2026-03-28 |
| `src/scenes/CTLD_farpScene.lua` | farpScene | 2026-04-01 |
| `src/scenes/CTLD_fobScene.lua` | fobScene | 2026-04-03 (rewritten) |
| `src/scenes/CTLD_aaHawkScene.lua` | aaHawkScene | 2026-04-01 |
| `src/scenes/CTLD_aaPatriotScene.lua` | aaPatriotScene | 2026-04-01 |
| `src/scenes/CTLD_aaNasamScene.lua` | aaNasamScene | 2026-04-01 |
| `src/scenes/CTLD_aaBukScene.lua` | aaBukScene | 2026-04-01 |
| `src/scenes/CTLD_aaKubScene.lua` | aaKubScene | 2026-04-01 |
| `src/scenes/CTLD_aaS300Scene.lua` | aaS300Scene | 2026-04-01 |

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
| M6 | `src/CTLD_aasystem.lua` | CTLDCrateAssemblyManager | ⚪ | — |
| M7 | `src/CTLD_player.lua` | CTLDPlayer | ⚪ | — |

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

| Module | Events | Impl file | Spec | Status |
| ------ | ------ | --------- | ---- | ------ |
| Crates | 6 ✅ | `src/CTLD_crate.lua` ✅ | ✅ | ✅ Done |
| Troops | 6 ✅ | `src/CTLD_troop.lua` ✅ | ✅ | ✅ Done |
| JTAC | 9 ✅ | `src/CTLD_jtac.lua` ✅ | ✅ | ✅ Done |
| Beacons | 5 ✅ | `src/CTLD_beacon.lua` ✅ | ✅ | ✅ Done |
| Recon | 4 ✅ | `src/CTLD_recon.lua` ✅ | ✅ | ✅ Done |
| Zones | 2 ✅ | `src/CTLD_zone.lua` ✅ | ✅ | ✅ Done |
| Vehicles | 3 ✅ | `src/CTLD_vehicle.lua` ✅ | ✅ | ✅ Done [2026-04-07] |
| FOB | 3 ✅ | `src/CTLD_fob.lua` ✅ | ✅ | ✅ Done |
| Core Init | 1 ✅ | `src/CTLD_core.lua` ✅ | ✅ | ✅ Done |
| Scenes | — | `src/scenes/` (9 files) ✅ | ✅ | ✅ Done |
| i18n | — | `src/CTLD_i18n*.lua` ✅ | ✅ | ✅ Done |
| Config | — | `src/CTLD_config.lua` ✅ | ✅ | ✅ Done |

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
