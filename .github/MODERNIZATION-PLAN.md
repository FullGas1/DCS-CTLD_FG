# DCS-CTLD Modernization Plan

> **This is the single source of truth for all ongoing work.**
> Status: **In Progress** | Branch: `feature_modularisation_and_Config` → target `master` | Target: CTLD v2.0

---

## Vision

Rewrite CTLD as a modern, modular, and testable Lua project while
preserving backward compatibility with existing missions.
Deliverable: single `.lua` file produced by `tools/merger_V2/merge_CTLD.ps1`.

---

## Architectural decisions

| # | Topic | Decision |
| - | ----- | -------- |
| 1 | Module split | ✅ **Done** — `src/` files concatenated → `CTLD_Next.lua` by `tools/merger_V2/merge_CTLD.ps1`. Order: `tools/merger_V2/listToMerge.txt` |
| 2 | OOP | ✅ **Done** — `src/lib/class.lua` created (P1). All entity classes refactored. |
| 3 | MIST | ✅ **Done** — all `mist.*` calls replaced by `ctld.utils.*`. No active `mist.*` call in `src/` |
| 4 | Legacy API | ✅ **Done** — `src/compat/legacy_api.lua` (22 wrappers, thin delegates) [2026-04-15] |
| 5 | Lua env | Lua 5.1 DCS sandbox, desanitized server (`io`, `os`, `lfs` accessible) |
| 6 | Testing | ✅ **Done** — busted infrastructure in `tests/helpers/` + `tests/specs/` + CI job [2026-04-15] |
| 7 | Docs | ✅ **Done** — `docs/missionmaker_guide.md` (§1–16) + `docs/dev-guide.md` [2026-04-15] |
| 8 | i18n | ✅ **Done** — `src/CTLD_i18n*.lua` (EN/FR/ES/KO), `ctld.tr()` at all sites, generator `tools/merger_V2/generate_i18n_dicts.ps1` |
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
| **1** | Dead code cleanup (`source/`) | ✅ Done — 9 fichiers redondants supprimés, 3 références conservées [2026-04-16] |
| **2** | Module split + OOP (`src/`) | ✅ 100% — impl + recette + Q1–Q5 ✅ [2026-04-16] |
| **3** | MIST middleware | ✅ Done |
| **4** | Legacy API compatibility | ✅ Done — src/compat/legacy_api.lua, 22 wrappers [2026-04-15] |
| **5** | Unit tests (busted) | ✅ Infrastructure done — tests/helpers/ + tests/specs/ + CI job [2026-04-15] |
| **6** | CI infrastructure | ✅ Done — `.github/workflows/ci.yml` (lint + build + busted + release + docs) [2026-04-16] |
| **7** | i18n cleanup + tooling | ✅ Done |
| **8** | Documentation | ✅ Done — missionmaker_guide.md (§1–16) + dev-guide.md [2026-04-16] |

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

── FEATURES EN ATTENTE ──────────────────────────────────────────────────────
✅  FG  DCS native cargo detection — CTLD polling to detect std DCS load/unload
        No S_EVENT_CARGO_LOADED/UNLOADED in DCS API. Implemented in
        CTLDCrateManager:_checkNativeDCSCargo() called from checkHoverStatus() (1 s tick).
        LOAD: dcsStatic altitude rises > 3 m AND dynamic transport within 15 m.
        UNLOAD: crate.state LOADED, dcsStatic still alive (CTLD loads nil-ify it),
        distance from transport > 15 m. Publishes OnCrateLoaded/OnCrateUnloaded
        with method="dcs_native". Refreshes Unpack/LoadCrate/RequestEquipment menus.
        [2026-04-22]

✅  FG  JTAC drone orbit lifecycle — deployAirJTAC + initialRoute + autoOrbit + restore [2026-04-25]
        CTLDJTACManager:deployAirJTAC() spawns MQ-9/drone, isFlying detected via _tryInitFlying()
        with T+2s retry (DCS 1s spawn delay). _setOrbitRoute() builds 8-WP circular Mission route
        (SwitchWaypoint on rotated[n] for full-circle coverage). _updateOrbit() branches:
          • target acquired → GROUP pushTask(Circle) → onTargetOrbit=true (ORBITING)
          • target lost     → GROUP popTask() + GROUP setTask(initialRoute) → IDLE
        Validated F-106 [2026-04-25] via Witchcraft: full circle restoration confirmed.

⬜  FG  FOB construction scene — animated build sequence (120 s)
        Animate fobScene over the full buildTimeFOB (120 s) duration instead of
        playing all steps immediately:
          - Spawn transition props at scene start: construction crane, worker
            characters around the site, scattered crates
          - Spread the permanent structure steps (container, watchtower, sandbags…)
            across the 120 s timeline
          - Destroy/remove all transition props (crane, characters, temp crates)
            at scene completion, leaving only the final FOB structure
        Implementation: add timed sub-steps in CTLD_fobScene.lua using the
        CtldScene step engine (timer offsets); transition props registered in
        scene._transitionObjs for cleanup in the onComplete callback.

✅  FG  STEP 1 — Factorisation rôle JTAC : isJTAC descriptor + suppression _jtacUnitTypes [2026-04-25]
        Périmètre :
          1. Ajouter isJTAC=true sur Hummer (1001.01) et SKP-11 (1001.11)
          2. Remplacer _isJTACUnitType(crate.unit) par crate.isJTAC==true dans le menu builder
             Pour les multi-crates (pas de champ unit): _multiIsJTAC(multiple) = true si au moins
             un weight de la liste résout vers un descriptor avec isJTAC=true (via findDescriptorByWeight)
          3. Supprimer _jtacUnitTypes locale + CTLDCrateManager:_isJTACUnitType()
          4. Supprimer jtacUnitTypes de ctld_config.lua + section userConfig (ou marquer deprecated)
        Priorité : HAUTE — prérequis pour les recettes JTAC sol

⬜  FG  STEP 2 — Bug troop JTAC : hasJtac → startLase non implémenté en OOP (PRIORITÉ APRÈS STEP 1)
        Bug parité legacy: deploy() d'un groupe avec hasJtac=true ne déclenche pas startLase.
        Legacy: après spawnDroppedGroup(), si _onboard.troops.jtac ou nom contient "jtac" →
        ctld.JTACStart(groupName, code). OOP: deploy() log seulement "JTAC group dropped" sans lase.
        Fix: dans CTLDTroopManager:deploy(), après spawn DCS, si group.hasJtac → CTLDJTACManager:startLase()
        Recette après fix (JTAC sol via troupes) :
          • Déployer "JTAC Group" (inf=4, jtac=1) → autoLase → menu JTAC F10
          • Déployer "Single JTAC" (jtac=1) → autoLase → menu JTAC F10

⬜  FG  STEP 3 — Recette fonctions JTAC sur véhicules sol (après STEP 1+2)
        ✅ Hummer (BLUE)  : Request Equipment → unpack → autoLase → menu JTAC F10 [2026-04-25] F-107
        ⬜ SKP-11 (RED)   : idem côté RED
        ⬜ Hummer IN_TRANSIT : embarquer dans hélico → état IN_TRANSIT → débarquer → IDLE
        ⬜ SKP-11 IN_TRANSIT : idem RED

⬜  FG  Bibliothèque de recettes fonctionnelles avancées — scénarios joueur end-to-end
        Objectif : créer une bibliothèque de scripts Lua injectables via Witchcraft qui reproduisent
        des séquences d'actions joueur réelles et vérifient leur bon déroulement.
        Contrairement aux tests unitaires (mocks Lua standalone), ces scénarios tournent en mission
        DCS réelle et valident le comportement observable de bout en bout.

        Architecture :
          • Répertoire : recette/scenarios/ (séparé des diag/)
          • Chaque scénario = script Lua autonome injectable via Witchcraft
          • Mode d'exécution : mission lancée en mode CTLD debug (ctld.debug = true)
          • Tous les messages outText envoyés à l'écran doivent AUSSI être insérés dans CTLD.log
            → ctld.utils.log("INFO", ...) systématique sur chaque point de contrôle
          • Traces techniques supplémentaires (positions, distances, états internes) injectées
            dans le script de test uniquement — jamais dans le code de production src/
          • Vérification : lecture de CTLD.log seule (pas d'assert runtime)

        Scénarios prioritaires :
          • JTAC sol (Hummer) : Request Equipment → unpack près ennemi → lasing actif
            → laser code dans log → menu JTAC F10 → 9-Line → Toggle Lase
          • Drone JTAC (MQ-9) : unpack → route initiale (orbite) → ennemi entre dans LOS
            → autoOrbit sur cible → cible mobile suivie → cible hors LOS → retour route initiale
          • Troupes JTAC : charger "JTAC Group" → déposer → lasing actif → menu JTAC F10
          • IN_TRANSIT : embarquer JTAC sol → log IN_TRANSIT → débarquer → lasing reprend

        À planifier après STEP 2+3 terminés.

⬜  FG  Refonte système multi-crates — génération automatique + redéfinition sémantique
        Problème actuel : deux sources de vérité indépendantes faciles à désynchroniser.
          Ex : Hummer cratesRequired=1, mais { multiple={1001.01, 1001.01} } en liste 2 → incohérence silencieuse.
        À DISCUTER avant implémentation — proposition MM à soumettre :

        Piste A (génération automatique des sets simples) :
          Garde config : showMultiCrateSets = true/false
          Si true, le menu builder génère automatiquement l'entrée "XX — All crates" à partir du
          descriptor de la crate individuelle et de son attribut cratesRequired, sans ligne `multiple`
          explicite dans la config. Supprime la redondance pour les sets mono-type.

        Piste B (réservation de `multiple` aux sets multi-types) :
          `multiple` n'est utilisé QUE pour les équipements nécessitant plusieurs types de crates
          distincts (ex: systèmes AA : {launcherA, launcherA, radarA, commA, commA}).
          Chaque type dans le set est défini par sa propre crate portant son cratesRequired.
          Le set décrit la COMPOSITION (quels types, combien de chaque), pas la répétition d'une même crate.

        → Faire de meilleures propositions au moment du traitement, analyser impacts sur
          unpack pipeline, menu builder, AA assembly manager, et cas bords (FOB, multi-type existants).

⬜  FG  Beacon FM — incompatibilité radioTransmission avec modules full fidelity (UH-1H etc.)
        Constat : trigger.action.radioTransmission mode=1 (FM) n'est pas reçu par l'ARC-131
        de l'UH-1H (et probablement d'autres modules full fidelity). Le VHF AM fonctionne
        via l'ADF natif, mais le FM homing (indicateur de cap) reste muet.
        Deux alternatives à évaluer et implémenter :
          A. trigger.action.activateBeacon (beacon natif DCS) — reconnu par tous les modules
             full fidelity, mais API différente et portée/comportement à vérifier sur Hoggit.
          B. Boucle timer Lua : transmitOn(freq, power) → timer.scheduleFunction 7s →
             stopTransmit → timer.scheduleFunction 1s → retour début. Simule le comportement
             d'une émission pulsée reconnue par les systèmes radio full fidelity.
             Avantage : ne nécessite pas de changer d'API DCS.
             Inconvénient : consomme des schedules timer, fréquence de cycle à caler.
        → Vérifier d'abord la doc Hoggit pour activateBeacon avant d'implémenter.

⬜  FG  Mark IDs — vérifier compteur global à usage unique (app-wide monotonic)
        trigger.action.removeMark(id) : un ID supprimé ne peut JAMAIS être réutilisé dans
        la même mission (DCS l'ignore silencieusement). Vérifier que tout le code CTLD qui
        crée des marks (RECON layers, orbit debug, beacons…) utilise un compteur global
        monotoniquement croissant (type mIdx++) et jamais un compteur local réinitialisé.
        Priorité : layers RECON — le toggle ON/OFF supprime puis recrée les marks ; si l'ID
        est réutilisé, les marks ne réapparaissent pas → bug invisible.

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
✅  Q2  tests/ busted infrastructure  [2026-04-15]
        tests/helpers/dcs_stubs.lua — stubs DCS complets (coalition, Unit, Group, timer, trigger, Spot…)
        tests/helpers/loader.lua    — charge tous les modules src/ dans l'ordre listToMerge, idempotent
        tests/helpers/init.lua      — point d'entrée busted (référencé dans .busted)
        tests/specs/crate_manager_spec.lua — 8 specs findDescriptorByUnitType + spawnCrate
        .busted                     — config busted (pattern _spec, helper init.lua)
        Job 3 busted ajouté dans ci.yml (choco lua + luarocks install busted + busted tests/specs/)
        Note: busted non installé localement — validation uniquement via GitHub Actions CI

✅  Q3  GitHub Actions CI  [2026-04-15]
        .github/workflows/ci.yml créé
        Job 1 — lua-lint : choco install lua 5.4 → loadfile() syntax-check sur tous src/**/*.lua
        Job 2 — build    : merge PowerShell (replique merger.cmd sans pause interactif) → CTLD_Next.lua
          - fichiers manquants (AA scenes, userConfig) → warning seulement (parité merger.cmd)
          - artifact uploadé 7 jours (actions/upload-artifact@v4)
        Triggers : push sur master + feature_* , PR vers master
✅  Q4a Réorganisation arborescence repo  [2026-04-15]
        Suppressions : old/, merger/ (V1), src/tests/, conversation.text, witchcraft_test.lua
        Déplacements : merger_V2/ → tools/merger_V2/, CTLD_loader.lua → tools/,
          documentation/ + Specs/ → docs/, *.ogg → assets/, *.png → docs/,
          *.miz → missions/, CTLD.lua (v1) → source/
        .gitignore : ajout CTLD_Next.lua
        ci.yml : chemin corrigé tools/merger_V2/listToMerge.txt
✅  Q4b source/ dead code cleanup  [2026-04-16]
        Supprimés : CTLD_beacon.lua, CTLD_config.lua, CTLD_core.lua, CTLD_i18n.lua,
          CTLD_jtac.lua, CTLD_menu.lua, CTLD_recon.lua, CTLD_utils.lua, load_event.lua
        Conservés : CTLD.lua (référence v1 complète), CTLD_userConfig.lua, CTLD_loader.lua
✅  Q5  documentation complète  [2026-04-15]
        ✅  Q5-A  docs/missionmaker_guide.md — guide complet  [2026-04-15]
                   §1–9 existants + §10 Crates + §11 Vehicles + §12 FOB + §13 Beacons
                   + §14 JTAC + §15 Recon + §16 AA Systems
                   Chaque section : description bloc, actions (utilité/fonctionnement/activation/exemple),
                   paramètres config, events

        ✅  Q5-B  docs/dev-guide.md  [2026-04-15]
                   Sections : repo structure, architecture managers, new module howto,
                   events pub/sub, build + test workflow, migration v1→v2 (table 22 wrappers,
                   addCallback → subscribe, pack vehicle, exemple complet DO SCRIPT)
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
| D | Custom LoadableGroups API for mission makers | ✅ Implemented + recette [2026-04-14] |
| E | Dedicated CTLD log file (`ctld.log`) | ✅ Implemented + recette [2026-04-09] |

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

- `tools/merger_V2/merge_CTLD.ps1`: concatenates `src/` → `CTLD_Next.lua`
- `tools/merger_V2/listToMerge.txt`: canonical load order
- `tools/merger_V2/generate_loader.ps1`: generates `CTLD_loader.lua` for dev
- `tools/merger_V2/generate_i18n_dicts.ps1`: syncs i18n keys across languages

---

## Phase 1 — Dead code cleanup (`source/`) ✅ COMPLETE [2026-04-15]

Removed 9 redundant partial files (CTLD_beacon, CTLD_config, CTLD_core, CTLD_i18n, CTLD_jtac,
CTLD_menu, CTLD_recon, CTLD_utils, load_event). Retained 3 reference files:
`source/CTLD.lua` (full v1 monolith), `source/CTLD_userConfig.lua`, `source/CTLD_loader.lua`.

---

## Phase 2 — Module split + OOP (`src/`) ✅ COMPLETE [2026-04-15]

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
| `src/scenes/CTLD_farpScene.lua` | farpScene | 2026-04-14 — ✅ F-91 visual recette PASS |
| `src/scenes/CTLD_fobScene.lua` | fobScene | 2026-04-14 — ✅ F-90/F-93 visual recette PASS |
| ~~`src/scenes/CTLD_aa*Scene.lua`~~ | ~~6 fichiers AA~~ | 🗑️ **Supprimés 2026-04-07** — compositions AA dans CTLDCrateAssemblyManager.TEMPLATES |

> All scenes validated visually in DCS: farpScene ✅ F-91, fobScene ✅ F-90/F-93, mineFieldScene ✅ F-83–F-87 [2026-04-09/14].

### 2.2 — All files ✅ DONE

All P1/C1/M1–M7 classes implemented, recette 100%. See Module completion status table below.

### 2.3 — ~~CTLDCoalition~~ / ~~CTLDStateManager~~ — SUPPRIMÉS ✅

**Décision 2026-04-02** : ces deux classes sont supprimées du plan.

Les managers OOP absorbent naturellement l'état coalition sans couche intermédiaire :

- État coalition-splitté → convention uniforme `self._data = { [1]={}, [2]={} }` dans chaque manager
- Les 50+ branches `if coalition==1` du legacy disparaissent par construction (indexation directe par `coalitionId`)
- Pas de registre central nécessaire : chaque manager est propriétaire de son état

**C1 se réduit à 4 classes :** CTLDDCSEventBridge, CTLDPlayerTracker, CTLDCoreManager, EventDispatcher.

### 2.5 — Features ✅ ALL DONE

FA (parachute) ✅, FB (slingload) ✅, FC (MM crate detection) ✅, FD (LoadableGroups) ✅, FE (ctld.log) ✅

---

## Phase 3 — MIST middleware ✅ COMPLETE

All `mist.*` API calls replaced by `ctld.utils.*` in `src/`.
Remaining "mist" occurrences in source are string literals in log messages only.

---

## Phase 4 — Legacy API compatibility ✅ COMPLETE [2026-04-15]

22 wrappers in `src/compat/legacy_api.lua`. Migration guide in `docs/dev-guide.md` §7.
Each wrapper logs a deprecation warning and delegates to the v2 manager.

---

## Phase 5 — Unit tests ✅ Infrastructure done [2026-04-15]

| Task | Status | Detail |
| ---- | ------ | ------ |
| 5.1 | ✅ | busted config (`.busted`), CI job (choco lua + luarocks + busted) |
| 5.2 | ✅ | `tests/helpers/dcs_stubs.lua` — full DCS API stubs |
| 5.3 | ✅ (partial) | `tests/specs/crate_manager_spec.lua` (8 specs) — more specs pending |
| 5.4 | ✅ | In-game recette via Witchcraft (all modules 100%) |

---

## Phase 6 — CI infrastructure ✅ Core done [2026-04-15]

| Task | Status | Detail |
| ---- | ------ | ------ |
| 6.1 | ✅ Done | `tools/merger_V2/merge_CTLD.ps1` → `CTLD_Next.lua` |
| 6.2 | ✅ Done | GitHub Actions — run busted tests [2026-04-15] |
| 6.3 | ✅ Done | GitHub Actions — build `CTLD_Next.lua` on push [2026-04-15] |
| 6.4 | ✅ Done | GitHub Actions — release artifact on tag `v*` → GitHub Release + CTLD_Next.lua [2026-04-16] |
| 6.5 | ✅ Done | GitHub Actions — MkDocs deploy to GitHub Pages (push master → gh-pages) [2026-04-16] |
| 6.6 | ✅ Done | i18n lint: `tools/merger_V2/generate_i18n_dicts.ps1` |

---

## Phase 7 — i18n ✅ COMPLETE

| File | Content |
| ---- | ------- |
| `src/CTLD_i18n.lua` | Runtime engine: `ctld.tr()`, language selection, fallback EN |
| `src/CTLD_i18n_en.lua` | English reference keys (authoritative) |
| `src/CTLD_i18n_fr.lua` | French translations |
| `src/CTLD_i18n_es.lua` | Spanish translations |
| `src/CTLD_i18n_ko.lua` | Korean translations |
| `tools/merger_V2/generate_i18n_dicts.ps1` | Key sync — detects drift between languages |

Rules: all player-visible strings use `ctld.tr()`. Key added to EN first, propagated by generator.

---

## Phase 8 — Documentation ✅ COMPLETE [2026-04-15]

| Audience | File | Status |
| -------- | ---- | ------ |
| Mission maker | `docs/missionmaker_guide.md` | ✅ §1–16 complete |
| Developer | `docs/dev-guide.md` | ✅ Complete (architecture, new module, events, build, tests, migration v1→v2) |
| MkDocs / GitHub Pages | `mkdocs.yml` + `docs/index.md` | ✅ Done — CI job 6.5 (gh-deploy on push master) [2026-04-16] |

---

## Module completion status

| Module | Impl | Spec | Recette | % recette | Notes |
| ------ | ---- | ---- | ------- | --------- | ----- |
| Config (`CTLD_config.lua`) | ✅ | ✅ | ✅ | 100% | U-84→U-89 + F-101→F-102, 57/57 PASS [2026-04-16] |
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
| FOB (`CTLD_fob.lua`) | ✅ | ✅ | ✅ | 100% | 4/4 + F-90/F-93 visual ✅ [2026-04-14] |
| Vehicles (`CTLD_vehicle.lua`) | ✅ | ✅ | ✅ | 100% | 10/10 PASS [2026-04-07] |
| AA System (`CTLD_aasystem.lua`) | ✅ | ✅ | ✅ | 100% | 6/6 PASS [2026-04-07] |
| Player (`CTLD_player.lua`) | ✅ | ✅ | ✅ | 100% | 7/7 PASS [2026-04-07] |
| mineFieldScene | ✅ | ✅ | ✅ | 100% | U-74→U-75 + F-83→F-87, 40/40 PASS visual ✅ [2026-04-09] — quinconce + setLandMineAuto + showMinefieldOnF10Map |
| Scenes fob/farp | ✅ | ✅ | ✅ | 100% | F-90/F-91 visual ✅ [2026-04-14] |
| i18n | ✅ | ✅ | ✅ | 100% | U-90→U-96 + F-103→F-105, 63/63 PASS [2026-04-16] — ctld.i18n_audit/auditAll, fallback chain, completeness FR/ES/KO |
| ObjectRegistry (`lib/CTLD_objectRegistry.lua`) | ✅ | ✅ | ✅ | 100% | U-54→U-56 43/43 PASS [2026-04-08] |
| Feature A (parachute) | ✅ | ✅ | ✅ | 100% | F-57→F-64 33/33 PASS [2026-04-08] |
| Feature B (slingload) | ✅ | ✅ | ✅ | 100% | F-65→F-71 22/22 PASS [2026-04-08] |
| Feature C (MM crate) | ✅ | ✅ | ✅ | 100% | registerMMCrate + OnMMCrateDetected, F-41 PASS [2026-04-07] |
| Feature D (LoadableGroups) | ✅ | ✅ | ✅ | 100% | U-76→U-80 + F-88→F-89, 102/102 PASS [2026-04-14] |
| Feature E (CTLD log) | ✅ | ✅ | ✅ | 100% | initLog/log/closeLog dans CTLD_utils.lua — validé via utils recette M9 [2026-04-09] |

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
| Gameplay regressions after OOP refactor | High | Review discipline (analyse → fix) + Witchcraft recette |
| Legacy API coverage incomplete | Low | 22 wrappers done — all documented public functions covered |
| Scene positions incorrect | Low | Validated via F-90/F-91 visual recette in DCS |
