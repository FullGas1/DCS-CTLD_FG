# JTAC Lifecycle & State Transitions Analysis

> Status: IN PROGRESS — à compléter après corrections bugs B1-B4 + cleanup menu drone
> Date: 2026-05-01

---

## 1. Les 3 types de JTAC — Annihilabilité vs Loadabilité

| Type | Catégorie DCS | Spawnable entier (menu) | Spawnable par crate | Packable (annihilable) | Loadable (embarquable) |备注 |
|------|--------------|------------------------|--------------------|----------------------|----------------------|-----|
| **Troop** (infanterie) | GROUND (Group) | Non | Oui — crate infantry | Non | Oui — `_inTransit` | Route `loadFromZone`→`deploy()` |
| **Vehicle** (Hummer/SKP-11) | GROUND (Group) | Oui — `spawnVehicleForTransport` | Oui — unpack | Oui — `packVehicle` → `deregisterJTAC` | Oui — `loadVehicle` (virtuel + DCS native) | Route directe `spawnJTACVehicleForTransport` |
| **Drone** (MQ-9/RQ-1A) | GROUND via `spawnVehicleForTransport` mais spawnAs AIRPLANE via crate | Oui — `spawnVehicleForTransport` (si category=GND) / `deployAirJTAC` (si AIRPLANE) | Oui — drone crate | Non (aircraft) | Non — aéronefs ne sont pas cargaable dans CTLD | `spawnAs = "AIRPLANE"` via crate; menu Request JTAC Equipment liste ces types MAIs ils ne sont pas cargaables |

---

## 2. Spawn methods détaillées par type

### A. JTAC Troop (infantry group with jtac=N in loadableGroups)

| Méthode | Code path | DCS group créé | JTAC registered par |
|---------|-----------|---------------|-------------------|
| Load via TRZ → deploy | `loadFromZone()` → `deploy()` | Oui, dans `deploy()` → `spawnObject()` | `deploy()` → `startLase(groupName)` |
| Extract dropped group | `extract()` | Non — groupes déjà spawnés | N/A — le groupe a déjà son entry dans `jtacs[]` |

**Note**: `loadFromZone` ne crée pas de JTAC directement — elle stocke un `CTLDTroopGroup` dans `_inTransit`. Le JTAC n'est créé que lors du `deploy()` (spawn DCS group + startLase).

### B. JTAC Vehicle (ground vehicle, isJTAC=true in spawnableCrates OR JTAC_unitTypeNames)

| Méthode | Code path | JTAC registered | Notes |
|---------|-----------|----------------|-------|
| **Request JTAC Equipment** (menu entier) | `spawnJTACVehicleForTransport()` → `spawnVehicleForTransport()` + `registerJTACVehicle()` + `startLase()` | `registerJTACVehicle()` + `startLase()` dans `spawnJTACVehicleForTransport` | Spawnne le véhicule au sol, immediately lasing |
| **Unpack crate isJTAC=true (GROUND)** | `_spawnUnpacked()` → `_dispatchPostSpawn()` → `registerJTACVehicle()` + `startLase()` | `_dispatchPostSpawn()` appelle `startLase()` + `registerJTACVehicle()` | Route standard unpack |

### C. JTAC Drone (aéronef AI, isJTAC=true, spawnAs=AIRPLANE)

| Méthode | Code path | JTAC registered | Notes |
|---------|-----------|----------------|-------|
| **Request JTAC Equipment** (menu — PROBLÉMATIQUE) | `spawnJTACVehicleForTransport()` avec typeName="MQ-9 Reaper" → category=GROUND → spawns GROUND group with AIRPLANE type | `startLase()` | CATEGORY MISMATCH: drone listed in `JTAC_unitTypeNames` as GROUND category but is AIRPLANE type |
| **Unpack drone crate** | `_spawnUnpacked()` → `_dispatchPostSpawn()` | `_dispatchPostSpawn()` only for ground, skips for AIRPLANE → JTAC NOT started automatically from crate unpack | Air JTAC must be spawned via `deployAirJTAC()` or menu Request JTAC Equipment (problématique) |
| **deployAirJTAC()** | `deployAirJTAC()` → `spawnFromDescriptor()` + `startLase()` | `startLase()` called directly in `deployAirJTAC()` | Correct path for air JTAC |

---

## 3. Modes de drop et gestion JTAC

### Terminologie des drops

| Terme | Description | Unit DCS |
|--------|-------------|----------|
| **Drop Virtuel CTLD** | `Drop Crate(s)` menu — unload crates from transport to ground | Static objects (crates) |
| **Parachute Virtuel CTLD** | `Parachute Crates` — crates fall with parachute effect | Static objects (crates) |
| **Parachute Vehicle Virtuel CTLD** | `Parachute Vehicle` — vehicle falls with parachute effect | DCS ground unit respawned at landing |
| **Unpack (crate)** | `Unpack Crate` menu — destroys crate, spawns vehicle/group | DCS unit (vehicle or group) |
| **DCS Native Load** | Vehicle enters transport bbox (C-130, CH-47F) | DCS unit stays alive (linked in aircraft) |
| **DCS Native Unload** | Vehicle exits transport bbox | DCS unit reappears on ground |

### JTAC Vehicle — Transitions par mode de drop

```
[GROUND VEHICLE JTAC — spawnAs=nil ou GROUND]

PATH 1: Unpack crate isJTAC=true (spawnAs=GROUND)
  unpack → _spawnUnpacked(spawnAs=GROUND) → _dispatchPostSpawn() → startLase() + registerJTACVehicle()
  État: jtacs[gname]=entity, LASING/IDLE ✅

  → LOAD (menu): loadVehicle(method=menu_ctld)
      setJTACInTransit(gname) → state=IN_TRANSIT, jtacs[gname]=nil (laser FREED)
      vehicle.unit:DESTROY() (DCS unit destroyed)
      ✅ Correct

  → LOAD (DCS native, C-130): loadVehicle(method=dcs_native)
      setJTACInTransit(gname) → state=IN_TRANSIT, jtacs[gname]=nil (laser FREED)
      vehicle.unit stays alive (linked in aircraft)
      ✅ Correct

  → UNLOAD (menu): unloadVehicle(method=menu_ctld)
      dynAdd() → respawn new DCS unit
      resumeJTAC(gname) → jtacs[gname]=entity, IDLE → startLase() → LASING
      ✅ Correct (new groupName if dynAdd renames, but spawnData.groupName is original)

  → UNLOAD (DCS native): unloadVehicle(method=dcs_native)
      DCS unit already on ground → Group.getByName(spawnData.groupName) → found
      resumeJTAC(gname) → jtacs[gname]=entity, startLase()
      ✅ Correct

  → PACK (menu): packVehicle()
      deregisterJTAC(gname) → state=DEAD, jtacs[gname]=nil, laser FREED
      vehicle.unit:DESTROY()
      ✅ Correct

PATH 2: Request JTAC Equipment — spawnVehicleForTransport (ground vehicle, entire)
  spawnVehicleForTransport(typeName) → dynAdd GROUND group
  → registerJTACVehicle() → vehicle registered in _vehicles (not in jtacs yet)
  → startLase() in spawnJTACVehicleForTransport
  État: jtacs[gname]=entity, LASING ✅

  Transitions from this point are identical to PATH 1 (LOAD/UNLOAD/PACK same code paths)
```

### JTAC Troop — Transitions par mode

```
[TROOP JTAC — loadableGroups with jtac=N]

PATH 1: Load via TRZ → Deploy
  loadFromZone(template) → _inTransit[unitName] = CTLDTroopGroup(hasJtac=true)
  (no JTAC spawned yet at this point)

  → DEPLOY (transport lands, drops troops):
      spawnObject() → DCS group created
      group:deploy() → group.hasJtac=true → startLase(groupName) → jtacs[gname]=entity, LASING
      ✅ Correct

  → EXTRACT (transport lands, picks up dropped group):
      nearest.group:destroy() → DCS group destroyed
      _removeFromDropped() → removed from _droppedGroups
      (What happens to jtacs[gname]?)

  ❓ B2 À VÉRIFIER:
      Does nearest.group:destroy() trigger S_EVENT_DEAD for the group?
      If yes → CTLDCoreManager._isJTACGroup() detection → killJTAC()
      If no → orphan in jtacs[]

PATH 2: Parachute Troops
  parachuteTroops() → drops loaded CTLDTroopGroup from transport
  → group:deploy() called for each group (hasJtac handled same as PATH 1 deploy)
  ✅ Same as DEPLOY for JTAC handling

PATH 3: Unpack crate with isJTAC infantry (crate contains infantry group)
  _spawnUnpacked(desc, spawnAs=GROUND) → _dispatchPostSpawn()
  → For infantry JTAC: NO special JTAC handling in _dispatchPostSpawn
    (only desc.isJTAC for vehicle triggers startLase)
  → Troop JTAC activation must come from a different path
  ❓ Où le JTAC troop est-il démarré après unpack crate?
```

### JTAC Drone — Transitions par mode

```
[DRONE JTAC — spawnAs=AIRPLANE, isJTAC=true]

PATH 1: Unpack drone crate
  _spawnUnpacked(desc, spawnAs=AIRPLANE) → isAir=true
  → _dispatchPostSpawn() SKIPPED (only for ground vehicles)
  → JTAC NOT started automatically
  ❓ COMMENT LE DRONE JTAC EST-IL ACTIVÉ?
      Possible: deployAirJTAC() called separately?
      Or: the crate "Request Equipment" path for air?

PATH 2: Request JTAC Equipment (menu — PROBLEMATIC)
  spawnJTACVehicleForTransport("MQ-9 Reaper", ...) → dynAdd(category=GROUND, type="MQ-9 Reaper")
  → CATEGORY MISMATCH: DCS might not allow this
  → startLase() called → JTAC created with wrong category
  ⚠️ PROBLÉMATIQUE À CORRIGER

PATH 3: deployAirJTAC() (correct path for drone)
  deployAirJTAC() → spawnFromDescriptor(AIRPLANE) + startLase()
  État: jtacs[gname]=entity, ORBITING ✅

  → Drone destroyed (S_EVENT_DEAD): killJTAC(gname) → state=DEAD, jtacs[gname]=nil
  ✅ Correct

  IN_TRANSIT: N/A — drones cannot be loaded onto transports
```

---

## 4. Bugs critiques à corriger

### B1 — JTAC Troop: JTAC不应该laser depuis le transport au BOARD
**Statut**: ❓ À VÉRIFIER — `loadFromZone` ne spawn pas de DCS group. Le JTAC n'est pas encore actif au BOARD. Le vrai problème est peut-être au DEPLOY où le JTAC est lancé immédiatement après spawn.

### B2 — JTAC Troop: orphan JTAC après EXTRACT
**Statut**: ❓ DÉPEND DE S_EVENT_DEAD
- `nearest.group:destroy()` génère-t-il S_EVENT_DEAD pour le group ?
- CTLDCoreManager._isJTACGroup() détecte-t-il le group comme JTAC (via groupName substring "jtac") ?
- Si oui → killJTAC() appelé proprement
- Si non → orphan dans jtacs[]

### B3 — JTAC Troop DEPLOY: startLase appelé sur groupe pas encore alive
**Statut**: ❓ VÉRIFIER — y a-t-il un délai entre spawnObject() et startLase() dans deploy()?

### B4 — Troop JTAC: détection hasJtac incohérente
**Statut**: ⚠️ CODE À RISQUE
- `extract()` ligne 689: `hasJtac = nearest.groupName:lower():find("jtac") ~= nil` (substring)
- `deploy()` ligne 566: `if group.hasJtac then` (flag du template, setté via loadableGroups)
- Ces deux méthodes différentes peuvent donner des résultats différents pour le même groupe

### B5 — JTAC Drone: Request JTAC Equipment menu liste des drones non cargaables
**Statut**: ⚠️ BUG CONFIRMÉ
- `JTAC_unitTypeNames` contient "MQ-9 Reaper" et "RQ-1A Predator" (aircraft)
- Menu `refreshJtacEquipmentSection` affiche ces types
- spawnVehicleForTransport() crée un groupe GROUND avec un type AIRPLANE → CATEGORY MISMATCH
- Les drones ne peuvent pas être chargés dans un transport → menu trompeur
- **Action**: supprimer les drones de `JTAC_unitTypeNames` (laisser que Hummer/SKP-11)

### B6 — Drone JTAC: unpack crate ne démarre pas le JTAC automatiquement
**Statut**: ⚠️ BUG CONFIRMÉ
- `_dispatchPostSpawn()` ne traite QUE les desc.isJTAC ground vehicles
- Pour les drones (`spawnAs=AIRPLANE`), la fonction ne fait rien
- Le drone est spawned mais le JTAC n'est pas démarré
- L'activation JTAC pour drone doit passer par `deployAirJTAC()` ou par un autre chemin menu

### B7 — JTAC Vehicle DCS native: vehicle.unit reste alive après loadVehicle dcs_native
**Statut**: ✅ GÉRÉ — `loadVehicle` avec `method="dcs_native"` ne détruit PAS le unit (ligne 438-443). Unit stays alive but invisible. `setJTACInTransit` appelé → state=IN_TRANSIT, jtacs[]=nil. C'est correct.

### B8 — Parachute Vehicle: véhicule delivered après parachute — que se passe-t-il pour le JTAC?
**Statut**: ❓ À VÉRIFIER
- `parachuteVehicle()` → vehicle:setState(DELIVERED) → `_parachuteEffect:onStart()` → timer.scheduleFunction(onLanded)
- `onLanded` est un no-op dans CTLDNullParachuteEffect
- Où le véhicule est-il réellement respawné après le parachute?
- Le véhicule reste dans l'état DELIVERED jusqu'à uneventuelle action de unload

---

## 5. Points à vérifier dans le code

### A. extract() / S_EVENT_DEAD / killJTAC
- `nearest.group:destroy()` → génère S_EVENT_GROUP_DEAD ou S_EVENT_DEAD par unité?
- `_isJTACGroup()` dans CTLDCoreManager: comment détecte-t-il un JTAC group?
- Le handler S_EVENT_DEAD dans CTLDDCSEventBridge — route-t-il vers `killJTAC` pour les groups?

### B. Deploy timing pour JTAC Troop
- Y a-t-il un `timer.scheduleFunction` pour démarrer le JTAC après le spawn du DCS group?
- Le code actuel appelle `startLase()` synchronement après `spawnObject()` → risque de group pas encore prêt

### C. Drone unpack — activation JTAC
- Quel code path active le JTAC quand un drone crate est unpacké?
- `_dispatchPostSpawn` skip pour les air vehicles — est-ce intentionnel?

### D. Parachute vehicle delivered — respawn
- Où le véhicule delivered est-il réellement respawné (après la chute)?
- Y a-t-il un handler pour `OnVehicleParachuting` qui complète le cycle?

---

## 6. Tableau synthétique des transitions par type

### JTAC TROOP (infantry, hasJtac=true in loadableGroups)

| Transition | Trigger | state avant | state après | jtacs[] | laserCode | DCS group | Action JTAC |
|-----------|---------|------------|------------|---------|-----------|-----------|------------|
| BOARD (loadFromZone) | Menu → TRZ | N/A | N/A | N/A | N/A | Pas encore créé | Aucun — group pas encore spawné |
| DEPLOY | Menu → transport posé | N/A | IDLE | Créé | Alloué | Spawned par spawnObject() | startLase() → LASING |
| Parachute Deploy | Menu → Altitude OK | N/A | IDLE | Créé | Alloué | Spawned par spawnObject() | startLase() → LASING |
| EXTRACT | Menu → transport posé | LASING/IDLE | DEAD? | ❓ | ❓ | nearest.group:destroy() | Dépend de S_EVENT_DEAD → killJTAC ou orphan |
| Troop destroyed (combat) | S_EVENT_DEAD | LASING/IDLE | DEAD | nil | freed | Détruit | killJTAC() |
| Troop dead (S_EVENT_DEAD) | DCS event | any | DEAD | nil | freed | N/A | killJTAC() |

### JTAC VEHICLE (ground, isJTAC=true, spawnAs=nil ou GROUND)

| Transition | Trigger | state avant | state après | jtacs[] | laserCode | DCS unit | Action JTAC |
|-----------|---------|------------|------------|---------|-----------|-----------|------------|
| Unpack crate | Unpack menu | N/A | IDLE | Créé | Alloué | Spawned via dynAdd | startLase() |
| Request JTAC Equip | Menu JTAC → Request Equipment | N/A | IDLE | Créé | Alloué | Spawned via spawnVehicleForTransport | startLase() dans spawnJTACVehicleForTransport |
| LOAD menu_ctld | Menu → Load Vehicle | IDLE/LASING | IN_TRANSIT | nil | FREED | vehicle.unit:destroy() | setJTACInTransit() → stopLase + jtacs[]=nil |
| LOAD dcs_native | Vehicle enters transport bbox | IDLE/LASING | IN_TRANSIT | nil | FREED | Unit stays alive (linked) | setJTACInTransit() → stopLase + jtacs[]=nil |
| UNLOAD menu_ctld | Menu → Unload Vehicle | IN_TRANSIT | IDLE | Recréé | Alloué | dynAdd respawn new unit | resumeJTAC() → startLase() |
| UNLOAD dcs_native | Vehicle exits transport bbox | IN_TRANSIT | IDLE | Recréé | Alloué | Unit already on ground | resumeJTAC() → startLase() |
| PARACHUTE DROP | Menu → Parachute Vehicle | LOADED/DELIVERED | DELIVERED | nil? | ? | Unit? | ❓ onLanded handler缺失 |
| PACK | Menu → Pack Vehicle | IDLE/LASING | DEAD | nil | FREED | vehicle.unit:destroy() | deregisterJTAC() → silent, no OnJTACDead |
| Vehicle destroyed (combat) | S_EVENT_DEAD | any | DEAD | nil | freed | Détruit | killJTAC() |

### JTAC DRONE (air, spawnAs=AIRPLANE, isJTAC=true)

| Transition | Trigger | state avant | state après | jtacs[] | laserCode | DCS group | Action JTAC |
|-----------|---------|------------|------------|---------|-----------|-----------|------------|
| Unpack drone crate | Unpack menu | N/A | ❓ | ❌ | ❌ | Spawned (spawnAs=AIRPLANE) | JTAC NOT started automatically ❌ |
| Request JTAC Equip (PROBLEMATIC) | Menu | N/A | IDLE/ORBITING | Créé | Alloué | GROUND category mismatch | startLase() mais spawnAs AIRPLANE |
| deployAirJTAC() | Menu FOB ou unpack | N/A | ORBITING | Créé | Alloué | AIRPLANE via spawnFromDescriptor | startLase() → ORBITING ✅ |
| Drone destroyed (combat) | S_EVENT_DEAD | ORBITING/LASING | DEAD | nil | freed | Détruit | killJTAC() |

---

## 7. Actions de cleanup identifiées

### Action 1: Supprimer drones de JTAC_unitTypeNames
**Fichier**: `src/CTLD_config.lua` ligne 370-373
**Changement**: Retirer "MQ-9 Reaper" et "RQ-1A Predator" de `JTAC_unitTypeNames`
**Raison**: Les drones ne sont pas cargaables dans un transport, le menu Request JTAC Equipment est trompeur pour ces types
**Note**: Les drones JTAC sont quand même disponibles via le système de crate standard (spawnAs=AIRPLANE dans spawnableCrates)

### Action 2: Vérifier/Corriger drone unpack path
**Question**: Comment un drone JTAC doit-il être activé après unpack de ses crates?
- Option A: `_dispatchPostSpawn` handles air JTAC via `deployAirJTAC()`
- Option B: Ajouter un menu séparé pour activer le JTAC drone après unpack
- Option C: Modifier `_dispatchPostSpawn` pour appeler `deployAirJTAC()` pour les air vehicles

### Action 3: Vérifier parachute vehicle delivered
**Question**: Comment le véhicule delivered par parachute est-il respawné au sol?
- Y a-t-il un subscriber à `OnVehicleParachuting` qui handles le respawn?
- Ou le véhicule delivered doit-il être unpacké après parachute?

---

## 8. Scénarios de recette nécessaires

### JTAC Troop
| ID | Scenario | Action | Vérifications |
|----|----------|--------|---------------|
| JTAC-T1 | BOARD troop JTAC | loadFromZone | Vérifier jtacs[] reste vide après load (JTAC pas encore actif) |
| JTAC-T2 | DEPLOY troop JTAC | deploy() | jtacs[gname] créé, state=IDLE, startLase appelé |
| JTAC-T3 | Parachute deploy troop JTAC | parachuteTroops() | same as DEPLOY |
| JTAC-T4 | EXTRACT troop JTAC | extract() | S_EVENT_DEAD → killJTAC OU orphan (à déterminer) |
| JTAC-T5 | Troop JTAC killed in combat | S_EVENT_DEAD | jtacs[gname]=nil, laser freed |

### JTAC Vehicle
| ID | Scenario | Action | Vérifications |
|----|----------|--------|---------------|
| JTAC-V1 | Unpack vehicle JTAC | Unpack crate | jtacs[gname] créé, state=IDLE |
| JTAC-V2 | Request JTAC Equipment | Menu Request Equipment | jtacs[gname] créé, state=IDLE, vehicle in _vehicles |
| JTAC-V3 | Load vehicle menu_ctld | Load Vehicle | setJTACInTransit → jtacs[]=nil, state=IN_TRANSIT |
| JTAC-V4 | Unload vehicle menu_ctld | Unload Vehicle | resumeJTAC → jtacs[gname] recréé, startLase |
| JTAC-V5 | Load vehicle dcs_native (C-130) | Drive into transport bbox | setJTACInTransit → jtacs[]=nil, unit stays alive |
| JTAC-V6 | Unload vehicle dcs_native | Exit transport bbox | resumeJTAC → jtacs[gname] recréé |
| JTAC-V7 | Pack vehicle JTAC | Pack Vehicle | deregisterJTAC → jtacs[]=nil, no OnJTACDead |
| JTAC-V8 | Vehicle JTAC destroyed in combat | S_EVENT_DEAD | killJTAC → jtacs[]=nil |

### JTAC Drone
| ID | Scenario | Action | Vérifications |
|----|----------|--------|---------------|
| JTAC-D1 | Unpack drone crate | Unpack drone crate | JTAC started? Or not? (BUG B6) |
| JTAC-D2 | deployAirJTAC() | Menu FOB ou autre | jtacs[gname] créé, ORBITING |
| JTAC-D3 | Drone target acquisition | Target enters LOS | ORBITING + lasing, drone follows target |
| JTAC-D4 | Drone target lost | Target destroyed / LOS lost | drone returns to orbit route |
| JTAC-D5 | Drone destroyed | S_EVENT_DEAD | killJTAC → jtacs[]=nil |
| JTAC-D6 | Drone in parachute vehicle (hypothétique) | Parachute vehicle | ? |

---

## 9. Questions ouvertes (pour investigation code)

1. `extract()` — le DCS group a-t-il un S_EVENT_DEAD quand `group:destroy()` est appelé?
2. CTLDCoreManager._isJTACGroup() — quelle méthode de détection? Par groupName substring?
3. `_dispatchPostSpawn` pour drones — ce code fait-il quelque chose ou est-il un no-op pour air vehicles?
4. `parachuteVehicle` → `onLanded` — y a-t-il un subscriber ou est-ce un no-op?
5. Pour les JTAC vehicles créés via `spawnVehicleForTransport`, le `spawnData.groupName` est-il préservé à l'unload pour le resumeJTAC?