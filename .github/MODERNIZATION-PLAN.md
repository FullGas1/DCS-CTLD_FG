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
         Old recette: 8/8  100% [2026-04-07] (basic lifecycle — PRE-refactor)
         Refactor done [2026-05-02]: terminologie + états rename + _aliveUnits/_jtacUnits +
         S_EVENT_DEAD sync + deregisterJTAC × N + multi-JTAC + orphan cleanup
         New recette: `recette/scenarios/scenarioTroopsFullCycle_v2.lua` (8 steps) — ✅ 8/8 PASS [2026-05-04]
         Re-validated: startLaseTroopUnit unit-keyed path — ✅ 8/8 PASS [2026-05-04]
         Validated: BUG-02 (wasJtac before _removeDeadUnit), BUG-03 (_syncFromDCSGroup real DCS names), BUG-04/06/07/08
         ✅ BUGFIX: menu "Load from X" — (A) libellé [2026-05-04]
               Affiche désormais "TRZ_" .. zoneName (ex. "TRZ_pz1") : court et sans ambiguïté avec une LGZ.
               Le callback conserve `zoneName` (nom court) pour getTroopZone().
         🔧 BUGFIX PENDING: menu "Load from X" — (B) filtre LGZ_ absent
               Le menu peut afficher des zones LGZ_ superposées à une TRZ_ (pas des pickup troops).
               Filtrer sur `zone:hasPickup() == true` déjà en place (ligne 1399) — à confirmer en test
               avec mission ayant une LGZ_ superposée à une TRZ_.

✅ R3  src/CTLD_jtac.lua  (CTLDJTAC + CTLDJTACManager)
       recette: 8/8  100% [2026-04-07]
       ✅ BUGFIX: JTAC troop unit-level lasing [2026-05-05]
         Les JTACs des groupes de troupes sont suivis et gérés AU NIVEAU UNITÉ (unitName),
         et non au niveau groupe DCS (groupName), car ils font partie d'un groupe composite
         multi-unités (inf + jtac ensemble). Conséquence :
           • `startLase(groupName)` → `spawnJTAC` → `Group.getByName(groupName)` → nil (unitName ≠ groupName)
             Le lasing ne démarrait jamais sur un disembark de troupes.
           • `_autoLaseLoop` : `dcsGroup:getUnits()[1]` cible la mauvaise unité.
           • `deregisterJTAC(jtacName)` dans embarkFromField/returnToTroopZone : sans effet
             car jtacs[unitName] n'existait jamais.
         Corrections :
           • `CTLDJTAC:init()` : nouveau champ `unitName` (nil = group-keyed, set = unit-keyed)
           • `CTLDJTACManager:startLaseTroopUnit(unitName)` : nouvelle méthode unit-keyed
             (Unit.getByName, jtacs[unitName], loop via _autoLaseLoop)
           • `_autoLaseLoop` : branche unitName → Unit.getByName() ; mort = return nil sans killJTAC
             (S_EVENT_DEAD → onUnitDead → deregisterJTAC gère déjà la mort)
           • `disembark()` : startLase(jtacName) → startLaseTroopUnit(jtacName)
           • `_autoLaseLoop` (groupStopMoving) : `dcsGroup` portée locale au bloc else — hors portée
             à la ligne groupStopMoving → nil crash. Fix : `jtacUnit:getGroup()` (fonctionne pour les
             deux chemins, unit-keyed et group-keyed).
           • `CTLDCoreManager:_initMMJTACs()` : `group:isActive()` non défini sur les groupes créés
             dynamiquement (coalition.addGroup). Fix : pcall avec fallback `true`.

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

✅  FG  STEP 2 — Bug troop JTAC : hasJtac → startLase non implémenté en OOP [2026-04-26]
        Fix: CTLDTroopManager:deploy(), si group.hasJtac → CTLDJTACManager:startLase()
        Recette: scenario_troop_jtac.lua — 2/2 PASS [2026-04-26]

✅  FG  STEP 3 — JTAC InTransit : suspend/resume cycle + Request JTAC Vehicle menu [2026-04-27]
        Implémentations :
          • setJTACInTransit() appelé dans loadVehicle avant destroy/suspend
          • _autoLaseLoop : check IN_TRANSIT AVANT Group.getByName (anti-faux killJTAC)
          • deregisterJTAC() : silencieux, sans OnJTACDead — appelé dans packVehicle avant destroy
          • resumeJTAC() : relance autoLaseLoop après unload, laser code préservé
          • spawnJTACVehicleForTransport() : spawn + startLase combiné
          • registerJTACVehicle() : enregistre un véhicule JTAC externe dans CTLDVehicleSpawner
          • Menu F10 "Request JTAC Vehicle" : sous JTAC Commands, par coalition (JTAC_unitTypeNames)
          • JTAC_droneRadius + JTAC_droneAltitude + JTAC_unitTypeNames dans bloc [9] config
        Crates JTAC confirmées isJTAC=true (parité legacy jtacUnitTypes "SKP","Hummer","MQ","RQ") :
          • weight=1001.01 Hummer - JTAC        (unit="Hummer",        side=2, isJTAC=true)
          • weight=1001.11 SKP-11 - JTAC        (unit="SKP-11",        side=1, isJTAC=true)
          • weight=1006.01 MQ-9 Reaper - JTAC   (unit="MQ-9 Reaper",   side=2, isJTAC=true)
          • weight=1006.11 RQ-1A Predator - JTAC (unit="RQ-1A Predator", side=1, isJTAC=true)
        ✅ F-110: config JTAC_unitTypeNames — 10/10 PASS [2026-04-27]
        ✅ F-111: spawnJTACVehicleForTransport + registerJTACVehicle + deregister — 6/6 PASS [2026-04-27]
        ✅ F-112: deregisterJTAC anti-false-KIA + laser pool freed + idempotent — 7/7 PASS [2026-04-27]
        ⬜ F-113: virtual load/unload suspend+resume — différé (C-130J-30 requis)
        ⬜ F-114: DCS native bbox load/unload — différé (C-130J-30 ou CH-47Fbl1 requis)

✅  FG  Troop lifecycle rewrite — terminologie, états, transitions [2026-05-02]
         Schema: `docs/assets/troops_jtac_lifecycle.svg`
         Terminologierename :
           • loadFromZone() / load()         → embarkFromTroopZone()
           • deploy() / unload()             → disembark()  (alias `deploy = disembark` pendant transition)
           • extract()                       → embarkFromField()
           • returnToBase()                 → returnToTroopZone()
           • dispatchToEXZ() (cas spécial)  → dispatchToEXZ() (inchangé)
         États rename :
           • LOADED      → TRZ_LOADED  (virtual, pas de DCS group)
           • EXTRACTED   → FIELD_LOADED (DCS group destroy, mémoire préservée)
           • RETURNED_TO_PICKUP → RETURNED_TO_TRZ
           • DEPLOYED (silent) → DEPLOYED_EXZ (comptage flag, pas de spawn)
         CTLDTroopGroup:_aliveUnits map[unitName] = dcsUnit (référence DCS, pas index)
         CTLDTroopGroup:_jtacUnits map[unitName] = true (JTAC units only)
         S_EVENT_DEAD sync : CTLDTroopManager:onUnitDead() + _findGroupByAliveUnit()
           met à jour _aliveUnits / _jtacUnits à chaque mort d'unité dans un deployed group
           + deregisterJTAC() si l'unité était un JTAC.
         Bridge: CTLDDCSEventBridge → CTLDTroopManager:onUnitDead() (world.event.S_EVENT_DEAD)
         [2026-05-02]

✅  FG  Multi-JTAC per troop group — N instances instead of boolean [2026-05-02]
         template jtac=N → N JTAC instances on disembark()
         CTLDTroopGroup._jtacUnits = { [unitName] = true } — populated on disembark()
         CTLDTroopManager:disembark() :
           1. group:hasAliveJtac() (ex-boolean hasJtac)
           2. loop sur _jtacUnits → startLase() × N par unité JTAC
         preLoadTransport : _aliveUnits / _jtacUnits construits depuis template (suppression hasJtac)
         [2026-05-02]

✅  FG  JTAC lifecycle in troop transitions — deregisterJTAC on all exit paths [2026-05-02]
         embarkFromField() (FIELD_LOADED) :
           → loop sur _jtacUnits → deregisterJTAC() × N AVANT group:destroy()
           → sinon S_EVENT_DEAD trigger killJTAC() (fausse mort combat)
         returnToTroopZone() :
           → loop sur _jtacUnits → deregisterJTAC() × N AVANT de niler _inTransit[unitName]
           → sinon JTAC zombies dans CTLDJTACManager.jtacs
         disembark() after FIELD_LOADED :
           → startLase() × N pour chaque JTAC alive dans _jtacUnits (1ère fois)
         [2026-05-02]

✅  FG  Transport destroyed with FIELD_LOADED troops — orphan JTAC cleanup [2026-05-02]
         Contexte : transport détruit en vol → cleanupDeadTransports() nil _inTransit[unitName]
         Solution : cleanupDeadTransports() boucle sur _inTransit[deadUnit]._jtacUnits
           → deregisterJTAC() pour chaque JTAC avant de niler _inTransit[unitName]
         [2026-05-02]

⬜  FG  TROOPS — Refonte complète CTLDTroopGroup/CTLDTroopManager [2026-05-04]
        Regroupe 4 évolutions identifiées + 4 bugs critiques découverts en révision de code.

        A. Terminologie actions / états — clarification
           Actions (transitions) :
             embarkFromTroopZone()   = charger depuis une TRZ (au sol dans zone)
             disembark()             = déposer sur le terrain (fast-rope / ground drop)
             embarkFromField()       = récupérer depuis le terrain (group DCS existant)
             returnToTroopZone()     = ramener à la TRZ (restaure le stock)
             dispatchToEXZ()         = dépôt silencieux dans une EXZ_ (flag++)
           États CTLDTroopGroup.STATE :
             TRZ_LOADED    = à bord, chargé depuis TRZ (aucun DCS group)
             DEPLOYED      = au sol en tant que DCS group actif
             FIELD_LOADED  = à bord, récupéré depuis le terrain (DCS group détruit, mémoire préservée)
             DEPLOYED_EXZ  = dépôt silencieux EXZ_ (aucun DCS group, flag incrémenté)
             RETURNED_TO_TRZ = retourné à la TRZ, instance à discarder
           Note: supprimer STATE.EXTRACTED (n'existe pas dans l'enum, cf. BUG-01 ci-dessous).

        B. Multi-JTAC : identification fiable post-spawn
           Problème : _jtacUnits utilise des noms de slot template ("JTAC Group 2_u5") qui
           ne correspondent pas aux noms DCS réels après coalition.addGroup → startLase() échoue.
           Solution : après disembark() + _syncFromDCSGroup(), identifier les JTACs par le
           namePrefix "JTAC" des unités DCS (convention définie dans _registerOneTemplate) et
           reconstruire _jtacUnits avec les vrais noms DCS. Supprimer le mécanisme true→gname
           dans _syncFromDCSGroup (source d'incohérence de valeur dans la map).

        C. Mémoire de groupe après embarkFromField (field pickup préserve l'état)
           embarkFromField() doit reconstruire _aliveUnits/_jtacUnits depuis les unités DCS
           vivantes au moment du pickup, PAS depuis le template d'origine.
           → Group avec 2 JTAC dont 1 mort → field pickup → CTLDTroopGroup avec 1 seul JTAC.
           → Disembark suivant : respawn uniquement les unités encore vivantes.
           Actuellement : templateName est mis à gname (nom DCS), pas au nom template d'origine.
           Fix : préserver templateName = _droppedTemplates[nearest.groupName] → nom template.
           Fix : poids = somme des vrais poids rôles des unités restantes (pas 130 kg flat).

        D. Multi-JTAC : aucun lasing de la même cible par deux JTACs simultanés (option)
           Config : JTAC_noSameTargetLasing (bool, défaut false).
           Si true : avant startLase(), CTLDJTACManager vérifie si la target potentielle
           est déjà lasée par un autre JTAC du même groupe (ou de tout groupe).
           Chaque JTAC cherche alors une target non encore lasée à portée.
           Faisabilité DCS : vérifier si plusieurs Spot sur la même Unit sont possibles
           → si oui, le flag est utile ; si DCS rejette silencieusement le 2e Spot, c'est un
           bug natif hors périmètre. À vérifier sur Hoggit avant implémentation.

⬜  FG  JTAC menu toggles — Toggle Lasing + laseSpotCorrections
        Deux items de menu non implémentés dans CTLDJTACManager:buildMenuSection :
          1. "Toggle Lasing" (JTAC_allowStandbyMode) — CTLD_jtac.lua:1331
             • Callback actuel = stub log("INFO", ...) uniquement
             • À implémenter : CTLDJTACManager:toggleStandby(groupName, player)
               → bascule jtac.standbyMode + outText état → rebuild menu JTAC
             • Label à conformiser : `[activate]` si standbyMode=false / `[deactivate]` si true
             • _rebuildJTACBranch(unitName) nécessaire (pattern identique RECON)
          2. laseSpotCorrections (JTAC_laseSpotCorrections) — absent du menu F10
             • Config existe, logique codée, mais jamais exposé côté pilote
             • À ajouter : entrée par JTAC dans sous-menu groupName
               → CTLDJTACManager:toggleSpotCorrections(groupName, player)
             • Label dynamique : `[activate]` / `[deactivate]` selon jtac.laseSpotCorrections
        Séquence : implémenter toggleStandby + toggleSpotCorrections → _rebuildJTACBranch → recette

⬜  FG  JTAC InTransit — recettes live manquantes + cas option A/B/C MM-placed vehicle
        À revenir quand modules C-130J-30 ou CH-47Fbl1 disponibles :
          • F-113 + F-114 (voir ci-dessus)
        Question spec non tranchée :
          • Cas 3 (MM-placed vehicle chargé) — critère isJTAC au load :
            A = nom groupe contient "jtac"
            B = typename dans JTAC_unitTypeNames
            C = A OU B
          → Trancher avant d'implémenter le hook load dans CTLDVehicleSpawner pour ce cas.

✅  FG  GAP-1 — Load / Unload vehicle menu  [2026-04-30]
         findLoadableVehicles + refreshLoadSection + findLoadedVehicles + refreshUnloadSection
         buildMenuSection : deux sous-menus dynamiques (pattern refreshPackSection)
         JTAC : setJTACInTransit / resumeJTAC déjà dans loadVehicle / unloadVehicle
         Refresh : OnVehicleLoaded / OnVehicleUnloaded + _refreshNearbyPackPlayers étendu
         i18n : 6 clés EN/FR/ES/KO ajoutées
         Recette : F-120 (9/9) + F-121 (6/6) + F-122 (6/6) = 21/21 PASS — UH-1H
         Bugfix [2026-04-29] : UH-1H + Mi-8 ajoutés vehicleTransportEnabled ; _dispatchPostSpawn
         enregistre les véhicules GROUND dans CTLDVehicleSpawner (F-123 2/2 PASS)
         Fix [2026-04-30] : _spawnUnpacked — après registerJTACVehicle, appel de
         refreshLoadSectionForUnit + refreshPackSectionForUnit(playerName) → menu Load ET Pack
         rafraîchis après unpack sans re-entry F10 (F-124 1/1 PASS live)

⬜  FG  GAP-2 — Auto-unpack post-parachute crates (subscriber manquant)
        Contexte : config autoUnpackRadiusParachute=1000m existe et OnCrateParachuteLanded est
        publié par parachutesCrates(), mais AUCUN subscriber ne déclenche l'unpack automatique.
        À implémenter :
          • Subscribe à OnCrateParachuteLanded dans CTLDCrateManager (ou CTLDCrateAssemblyManager)
          • À la réception : scanner les crates au sol dans autoUnpackRadiusParachute autour
            du point d'atterrissage → si crateSet complet trouvé → unpackCrate() automatique
          • Publier OnCrateUnpacked normalement (startLase si isJTAC)
          • Config : autoUnpackRadiusParachute (déjà existant, défaut 1000m)

⬜  FG  Spawn/load/drop direct de véhicule sans crate (use case Request Vehicle pur)
        Use case : spawn d'un véhicule via "Request Vehicle" (logistic zone) → load dans transport
        → drop à un autre endroit, sans aucune crate intermédiaire.
        Points à valider :
          • CTLDVehicleSpawner.spawnVehicleForTransport() → loadVehicle() → unloadVehicle() :
            cycle complet sans passer par spawnableCrates / unpack
          • Menu F10 "Load Vehicle" / "Unload Vehicle" : visibilité, déclenchement, guard zones
          • État CTLDVehicle : WAITING → LOADED → DELIVERED (pas de WAITING_FOR_UNPACK)
          • Recette end-to-end (Witchcraft ou sandbox) à créer

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
• Troops full cycle (2 JTAC) — `recette/scenarios/scenarioTroopsFullCycle.lua` (created ⬜ pending exec) :
               - Créer template de test `jtac = 2` (2 JTAC soldiers dans le group)
               - embarkFromTroopZone() → TRZ_LOADED (log state)
               - disembark() 1er déploiement → DCS group spawn, 2 JTAC instances créées
                 → vérifier _jtacUnits map contient 2 entries, startLase() ×2 appelé
               - Simuler destruction de l'unité JTAC N°2 (S_EVENT_DEAD injecté)
                 → _jtacUnits mis à jour (1 entry restante), _aliveUnits mis à jour
                 → deregisterJTAC() appelé pour l'unité détruite, laser pool -1
               - embarkFromField() → FIELD_LOADED
                 → deregisterJTAC() appelé pour le JTAC restant (alive) AVANT group:destroy()
                 → group:destroy() ne déclenche PAS killJTAC (JTAC déjà deregistré)
               - disembark() après field → DCS group respawn avec 1 seul JTAC alive
                 → resumeJTAC() appelé pour le JTAC vivant
               - returnToTroopZone() → RETURNED_TO_TRZ
                 → deregisterJTAC() appelé pour le JTAC restant, stock TRZ restauré
          • Beacon radio — vérification des 3 émetteurs :
              - VHF (200–1250 kHz AM) : entendu sur ADF + aiguille ADF pointe vers balise
              - UHF (220–399 MHz AM) : entendu par modules FC3 (son beaconsilent.ogg)
              - FM  (30–76 MHz FM)   : bip entendu sur radio FM hélico full fidelity (UH-1H ARC-131)
                                       + indicateur de cap FM actif en mode DF
              Vérification : drop beacon depuis hélico → log fréquences → positionner à 500m
              → accordes successives sur chaque freq → confirmer réception bip + comportement
              navigation (ADF pour VHF, homing pour FM). Test post-fix délai 1s.

        À planifier après STEP 2+3 terminés.

✅  FG  Refonte système spawnableCrates — singleTypeSets auto + mixedSet [2026-04-26]
        - Suppression ~25 entrées multiple={w,w,...} manuelles dans config
        - Renommage multiple → mixedSet pour sets multi-types (HAWK, NASAMS, KUB, BUK, Patriot, S-300)
        - showSets=false sur FOB Crate (sentinel), enableAllCrates garde global
        - _processSpawnableCrates() : 3 passes (séparation / auto-génération / validation)
        - singleTypeSet auto-généré : desc = sc.desc + ctld.tr("All crates"), adjacent dans menu
        - mixedSet validé : weights résolus dans catégorie, entrée bloquée + alerte MM si manquant
        - findDescriptorByWeight/ByTypeName/ByUnitType : O(1) via _weightIndex
        - Ordre menu garanti : singleCrates (+ singleTypeSet adjacent) → mixedSets en fin
        - Recette visuelle ✅ PASS [2026-04-26] F-109

⬜  FG  Beacon FM — remplacer radioTransmission par activateBeacon HOMER pour canal FM
        Diagnostic confirmé : trigger.action.radioTransmission mode=1 (FM) ne produit pas un
        signal carrier FM reçu par le module UH-1H (ARC-131 / ARN-83). Le VHF AM fonctionne
        car il passe par l'ADF (chemin audio séparé). radioTransmission FM = audio overlay sans
        carrier FM réel → invisible pour les radios FM full fidelity.
        Solution : activer un beacon natif DCS type HOMER (type=8) sur l'unité FM via
        Unit:getController():setCommand({id="ActivateBeacon", params={type=8, ...}})
        Paramètres à vérifier sur Hoggit avant implémentation :
          - type = 8 (BEACON_TYPE_HOMER) pour FM homing
          - system, AA, callsign : valeurs exactes à confirmer
          - 1 beacon max par unité → utiliser l'unité FM dédiée, VHF/UHF gardent radioTransmission
        radioTransmission reste pour VHF (ADF, fonctionne) et UHF (son silencieux FC3).
        ⚠️ POINT CRITIQUE à vérifier AVANT d'implémenter :
          "un seul beacon actif à la fois" = par unité ou global mission ?
          - Si par unité → OK : chaque balise CTLD a sa propre unité FM dédiée
          - Si global mission → activateBeacon inutilisable pour CTLD (N FOBs simultanés impossibles)
            → fallback obligatoire : solution B (boucle timer pulsée par unité FM)
        Test : spawner 2 balises FM sur freq différentes, vérifier réception simultanée des 2.
        → VÉRIFIER API Hoggit avant de coder : https://wiki.hoggitworld.com/view/DCS_command_activateBeacon

✅  FG  Mark IDs — compteur global monotonique app-wide [2026-04-27]
        ctld.utils.getNextMarkId() / MarkIdCounter : compteur partagé par Recon, Beacon, drawQuad.
        Fix bugs :
          - CTLDReconManager._nextMark() + CTLDBeaconManager._nextMark() : délèguent désormais
            à getNextMarkId() (suppression des compteurs locaux démarrant à 1 → collisions silencieuses)
          - drawQuad : utilise getNextMarkId() au lieu de getNextUniqId() (séparation mark/unit IDs)
          - _doRefresh moved-target : alloue un nouveau markId après removeIcon (DCS invalide
            définitivement tout ID passé à removeMark — réutilisation = mark invisible)
        Recette F-115 : 11/11 PASS [2026-04-27]

⬜  FG  Shutdown propre des boucles timer.scheduleFunction à la réinjection CTLD_Next
        Contexte : réinjection Witchcraft d'un CTLD_Next.lua dans une mission qui tourne déjà
        redéclare les singletons mais NE peut PAS annuler les boucles schedulées de l'ancienne instance.
        Risques identifiés :
          - Boucles zombies avec référence à l'ancienne instance (closures self capturé)
          - Double rebuild de menu F10 en parallèle → arborescence corrompue (observé [2026-05-04])
          - Beacon refresh loop : boucle infinie SANS guard return nil, functionId NON stocké
            → aucune possibilité d'annulation → risque accumulatif à chaque réinjection
        Audit des boucles actuelles :
          - _orbitLoop (CTLD_jtac) : ✅ functionId stocké dans _orbitScheduleId → removeFunction possible
          - _autoLaseLoop (CTLD_jtac) : ✅ guard return nil si JTAC absent du manager → auto-stop
          - beacon refresh (CTLD_beacon) : ❌ functionId non stocké + pas de guard → BUGFIX REQUIS
          - _tryInitFlying (CTLD_jtac) : ✅ one-shot
          - menu refresh (CTLD_player) : ✅ one-shot
        API à utiliser : timer.removeFunction(functionId) — annule une fonction schedulée via son ID
          https://wiki.hoggitworld.com/view/DCS_func_removeFunction
        Travaux à faire :
          (A) Stocker le functionId de la boucle beacon refresh → permettre son annulation
          (B) Ajouter guard return nil dans la beacon refresh loop (défense en profondeur)
          (C) Évaluer CTLDCoreManager:shutdown() pour arrêt propre de toutes les boucles
              avant réinjection (appel depuis un script Witchcraft dédié)
          (D) Bonne pratique recette : ne pas détruire de vrais groupes DCS dans les scénarios
              Witchcraft (déclenche S_EVENT_DEAD → rebuild menu concurrent)

⬜  FG  Feature F — RECON layer FARP/FOB ennemis persistants
        Objectif : détecter les FARP/FOB ennemis en LOS pendant un vol de reconnaissance et en garder
        la trace sur la F10 map même après que le scout s'est éloigné.
        Principes :
          • Nouveau layer RECON "farp_fob" scanné via coalition.getStaticObjects(enemySide)
          • Identification FARP/FOB par attributs DCS (à vérifier Hoggit : attributes.FARP, Helipad, etc.)
          • LOS check identique aux layers existants (getUnitsLOS, altoffset=180)
          • Persistance : les marques détectées sont stockées dans une table séparée de _activeScans
            → elles ne sont PAS effacées par les refreshs normaux du layer
          • Destruction : écoute S_EVENT_DEAD / S_EVENT_UNIT_LOST sur les statics → retire le mark
          • Feasibility : ✅ faisable avec les APIs existantes (getStaticObjects, getUnitsLOS, S_EVENT_DEAD)
        Spec + implémentation à planifier.

⬜  FG  Feature G — Toggle "Share my RECON to coalition"
        Objectif : permettre à un pilote de partager son scan RECON avec tous les joueurs BLUE.
        Contrainte DCS API : lineToAll/circleToAll/rectToAll n'acceptent que coalition (-1/0/1/2),
        pas de ciblage par joueur ou groupe. Impossible d'appliquer un filtre LOS par spectateur.
        Version faisable (simplifiée) :
          • Quand "Share RECON" activé : les icônes du joueur partageur sont dessinées avec
            coalition=2 (BLUE seulement) au lieu de -1, et restent jusqu'au prochain refresh
          • Les autres joueurs BLUE voient les icônes du partageur sans re-filtrage LOS
          • Pas de merge multi-joueur côté rendu (limitation DCS irréconciliable)
        À distinguer d'un éventuel "kneeboard" (infos coa friendly — scope différent, feature séparée).
        Spec + implémentation à planifier.

✅  FG  Feature H — Smoke auto-resume (toggle [activate]/[deactivate]) [2026-05-05]
        Objectif : simuler une durée de fumée perpétuelle en relançant automatiquement
        toutes les fumées actives avant leur expiration (~5 min DCS fixe).
        Comportement attendu :
          • Toggle F10 "Smoke Auto-Resume [activate]" / "[deactivate]" par joueur
            → label dynamique : [activate] quand désactivé, [deactivate] quand activé
            → scope : par joueur (chaque pilote gère ses propres smokes)
          • Quand activé : toutes les fumées lancées par ce joueur (position + couleur mémorisées)
            sont relancées automatiquement via trigger.action.smoke() juste avant l'expiration
          • Quand désactivé : les fumées en cours expirent naturellement + mémoire effacée
          • Stockage : { pos, color, launchTime } par smoke active ; timer périodique (15s) vérifie
            si launchTime + smokeAutoResumeInterval atteint → trigger.action.smoke(pos, color)
          • Une relance repart le compteur de la smoke relancée (launchTime = now)
          • Scope des smokes suivies : toutes celles déclenchées via le menu CTLD F10
            (Drop Smoke) — tracées systématiquement, le tick filtre sur active
        Config :
          • smokeAutoResume (bool, défaut false) — état initial global (surchargeable par joueur)
          • smokeAutoResumeInterval (int, défaut 270 s = 4min30) — délai avant relance
        Implémentation : CTLDSmokeManager singleton (src/CTLD_crate.lua) + buildSmokeSection
        Recette : diag_smoke_mgr.lua + diag_smoke_menu.lua ✅ PASS [2026-05-05]
        Validé en live DCS : smoke bleue persistante en boucle, menu label bascule, désactivation purge ✅

⬜  FG  Feature I — Route/behaviour assignment post-deploy (étude de faisabilité)
        Objectif : permettre d'assigner automatiquement une route ou un comportement prédéfini
        à un équipement ou des troupes au moment de leur dépose/unpack.
        Questions à étudier avant spec :
          • Faisabilité DCS API : Group.setTask / GroupAI / group:getController():setTask()
            pour les groupes spawnés via dynAdd/coalition.addGroup — vérifier Hoggit
          • Définition des pseudoRoutes : ex. "goToNearestEnemy", "goToNearestWPZ",
            "holdPosition", waypoints explicites {x,z}
          • Point d'injection pour crates : via crateSettings.specificParams dans spawnableCrates
            ex. spawnableCrates = { { ... , specificParams = { route = "goToNearestEnemy" } } }
          • Point d'injection pour troops : via le template loadableGroups, champ specificParams
            analogue — vérifier cohérence avec architecture CTLDTroopManager:deploy()
          • Timing : setTask doit être appelé au moins 1 frame après coalition.addGroup
            (même contrainte que _onBirthDeferred)
          • Scope : uniquement pour les unités spawnées par CTLD (unpack crate, deploy troops,
            unload vehicle) — pas pour les unités MM existantes
        Livrable attendu : note de faisabilité + spec si réalisable
        Spec + implémentation à planifier.

✅  FG  Feature J — JTAC target deconfliction (multi-JTAC, anti-doublon) [2026-05-04]
        Objectif : lorsque plusieurs JTACs actifs (infantry slot, vehicle, drone) sont concurrents
        et dans la portée d'une même cible ennemie, empêcher qu'ils lasent tous la même cible.
        La déconfliction doit rester compatible avec le renouvellement de cible après destruction :
        quand une cible est détruite, chaque JTAC doit automatiquement se repositionner sur une
        autre cible disponible (vivante, dans portée LOS, non claimée).

        Structure de données (minimaliste) :
          • Une seule table partagée dans CTLDJTACManager :
              `_claimedTargets` = { [unitName_cible] = jtacKey }
                → jtacKey = unitName (unit-keyed) ou groupName (group-keyed)
            Cette table est la liste des targets **en cours de lasing actif**.
            Aucune structure supplémentaire par JTAC n'est nécessaire.

        Comportement dans `_autoLaseLoop` :
          Phase RECHERCHE (pas de target courante) :
            1. Appeler `findAllVisibleEnemies()` → liste de candidats triée par distance
               (vivants + LOS + dans portée)
            2. Filtrer la liste : exclure les unitNames déjà présents dans `_claimedTargets`
            3. Prendre le premier candidat restant → claim + lase
               Si liste vide après filtre → return t + searchInterval
          Phase LASE (target courante valide) :
            4. Vérification cible existante inchangée (isExist, LOS) — comportement actuel conservé
            5. Si cible perdue (détruite OU hors LOS) — CAS CRITIQUE :
               → `_stopLaseAndPublish` → retire `_claimedTargets[cible]`
               → repasser immédiatement en Phase RECHERCHE (steps 1-3) dans le même cycle
          Note : c'est lors du step 5 (renouvellement de cible) que la déconfliction est
          la plus critique. Plusieurs JTACs perdant simultanément leur cible (ex. explosion)
          itèrent chacun la liste filtrée → chacun prend un candidat différent.

        Gestion du claim :
          • Claim posé : à l'instant où le JTAC démarre le lase sur une nouvelle cible
          • Claim levé : dans `_stopLaseAndPublish`, quelle que soit la raison
            (TARGET_DESTROYED, TARGET_LOST, STANDBY_MODE, UNIT_DEAD, etc.)
          • Claim levé aussi dans `deregisterJTAC` (pour toutes les entrées pointant ce JTAC)
          • Pas de TTL / expiry : le claim vit aussi longtemps que le lase est actif

        Refactoring requis :
          • `CTLDJTACDetector.findNearestVisibleEnemy()` → `findAllVisibleEnemies()`
            Retourne une table `{ {unitName, dcsUnit, position, distance}, ... }` triée par distance.
            Le caller (autoLaseLoop) fait l'itération et la sélection deconflictée.
          • Rétrocompatibilité : l'ancien `findNearestVisibleEnemy` peut devenir un thin wrapper
            appelant `findAllVisibleEnemies()[1]` pour les callsites existants non JTAC.

        Config :
          • `JTAC_targetDeconfliction` (bool, défaut true) — désactivable si mission = JTAC solo
          • `JTAC_deconflictPriority` = "distance" | "laserCode" (défaut "distance")
            → "distance" : le JTAC le plus proche de la cible gagne le claim en cas de race
            → "laserCode" : le code laser le plus bas gagne (ordre de spawn/inscription)
            Note : la race est peu probable en pratique (loops décalées), mais doit être gérée.

        Spec + implémentation à planifier.

⬜  FG  Feature K — JTAC vehicle in-transit lifecycle (idle/active on load/unload)
        Objectif : garantir que les JTACs de type vehicle (autoLase group-keyed) transitent
        correctement entre états LASING ↔ idle lors des opérations load/unload du transport,
        symétrique au comportement déjà implémenté pour les JTACs infantry (troop unit-keyed).

        Comportement attendu :
          • Load vehicle JTAC dans transport → JTAC passe en idle (stopAutoLase / standby)
            → claim libéré → target disponible pour d'autres JTACs
          • Unload vehicle JTAC → JTAC reprend l'autoLase (resumeJTAC ou startLase)
            → claim re-posé sur première target disponible non claimée
          • Si le transport est détruit pendant le transit → JTAC vehicle traité comme mort
            (deregisterJTAC → claim libéré)
          • Déconfliction Feature J s'applique identiquement aux JTACs vehicle

        ⚠️  Travaux séparés en deux flows distincts — traiter séquentiellement :

        FLOW 1 — JTAC vehicle via crates (spawn par unpack)
          Chemin : CTLDCrateManager:unpackCrate → _spawnUnpacked → _dispatchPostSpawn
                   → CTLDVehicleSpawner:loadVehicle / unloadVehicle
          Load variants à couvrir :
            • "menu_ctld"    : menu F10 Load Vehicle → unit détruite + respawn in transport
            • "dcs_native"   : unité entre dans bbox transport → _checkNativeLoading
          Unload variants à couvrir :
            • "menu_ctld"    : menu F10 Unload Vehicle → respawn near transport
            • "dcs_native"   : DCS place l'unité au sol (unload natif DCS)
            • "parachute"    : CTLDVehicleSpawner:parachuteVehicle → dépose aérienne CTLD simulée

        FLOW 2 — JTAC vehicle entier (MM-placed ou spawned, non issu de crate)
          Chemin : CTLDVehicleSpawner:loadVehicle / unloadVehicle (mêmes méthodes, vehicle pré-existant)
          Load variants : identiques FLOW 1 ("menu_ctld", "dcs_native")
          Unload variants : identiques FLOW 1 ("menu_ctld", "dcs_native", "parachute")
          Différence : pas de _spawnUnpacked, le CTLDVehicle est détecté MM ou via Request Equipment

        ⚠️  Hors scope (pas de JTAC concern) :
            • Crate parachute (CTLDCrateManager:parachuteCrates) → caisses, pas vehicles
            • Slingload (releaseSlingload / cutSlingload) → caisses uniquement
            • Parachutage DCS natif (S_EVENT_PARACHUTE_OPEN) → troops, pas vehicles

        Vérification à faire (commun aux deux flows) :
          1. loadVehicle → appelle-t-il stopAutoLase / idle JTAC ? (pour toutes méthodes)
          2. unloadVehicle → appelle-t-il resumeJTAC ? (pour toutes méthodes)
          3. Si transport détruit → JTAC vehicle traité comme mort ?
          4. Comparer avec flow infantry : embarkFromField → deregisterJTAC / disembark → startLaseTroopUnit

        Recette à créer :
          • Scénario Witchcraft Flow 1 : spawn JTAC via crate → load → idle → unload → lasing reprend
          • Scénario Witchcraft Flow 2 : JTAC vehicle MM → load → idle → unload → lasing reprend

⬜  FG  SVG troops transport flows — schéma visuel transport troupes
        Produire docs/assets/troops_transport_flows.svg au même format que transport_flows.svg
        (colonnes Méthode / Déclencheur / Posé requis / LGZ / État) couvrant :
          • Flow BOARD : héli posé + menu → troops embarquées
          • Flow DEPLOY : héli posé + menu → troops déployées (DZ) / LZ
          • Flow EXTRACT : héli en LZ + menu → troops récupérées
          • Parachute virtuel (Feature A) : altitude ≥ parachuteMinAltitudeTroops
          • DCS native slingload troops (si applicable)
          • JTAC annotations si une troupe déployée est JTAC
        Ajouter lien dans missionmaker_guide.md §5 (Troop Transport).

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
| Recon (`CTLD_recon.lua`) | ✅ | ✅ | ✅ | 100% | 5/5 PASS [2026-04-02] + F-116 6/6 visual PASS [2026-04-28] + F-117/F-118/F-119 19/19 PASS [2026-04-29] — reconEnabled=false message, toggle-OFF immédiat, AA icon fill+apex, layers scenario, reconIconScale |
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
| **Troop + JTAC Lifecycle** (`src/CTLD_troop.lua`) | ✅ impl | ✅ spec | ✅ 8/8 | 100% | ✅ Terminologie rename + États rename + _aliveUnits/_jtacUnits + S_EVENT_DEAD sync + deregisterJTAC × N + multi-JTAC N× + orphan cleanup [2026-05-02]. Recette: `recette/scenarios/scenarioTroopsFullCycle_v2.lua` 8/8 PASS [2026-05-04] |
| **Mise en conformité scénarios recette** | ✅ template | — | ⬜ 0% | — | Reformater tous les scénarios existants (`scenario_*.lua`, `scenarioTroopsFullCycle_A.lua`, etc.) pour conformité au nouveau template (pcall, check/assert, fail+traceback, log reset step 1, timer, return TAG+step+SUCCESS) — ⬜ pending [2026-05-04] |

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
