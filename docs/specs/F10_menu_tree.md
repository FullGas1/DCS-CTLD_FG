# Arbre complet du menu F10 CTLD

> **Source analysée** : `old/CTLD_menus.lua` + `source/CTLD_recon.lua` — branche `feature_modularisation_and_Config`
>
> **Conventions** :
> - `[COND: x]` — entrée affichée uniquement si la condition x est vraie
> - `[PAG: N/p]` — pagination active : N entrées max par page, suivie d'une entrée **"Next page >"** si dépassement
> - `→ fct()` — fonction Lua appelée au clic

---

## Bloc 1 — Menu transport

Construit par `ctld.addTransportF10MenuOptions()` lors de l'entrée d'un joueur dans une unité de type transport.
Affiché uniquement pour les unités dont le `typeName` est référencé dans `ctld.unitActions`.

```
F10 > CTLD
│
├── Check Cargo                               → ctld.checkTroopStatus
│
├── Troop Transport                           [COND: unitActions.troops == true]
│   ├── Unload / Extract Troops               → ctld.unloadExtractTroops
│   ├── Load <nom_groupe_1>                   → ctld.loadTroopsFromZone   ┐ filtrés par coalition
│   ├── Load <nom_groupe_2>                   → ctld.loadTroopsFromZone   │ et transportLimit
│   ├── ...                                                               │
│   └── Next page >                                          [PAG: 9/p]  ┘
│
├── Vehicle / FOB Transport                   [COND: unitActions.troops ET ctld.unitCanCarryVehicles]
│   ├── Unload Vehicles                       → ctld.unloadTroops
│   ├── Load / Extract Vehicles               → ctld.loadTroopsFromZone
│   ├── Load / Unload FOB Crate               → ctld.loadUnloadFOBCrate  [COND: enabledFOBBuilding ET NOT staticBugWorkaround]
│   └── Check Cargo                           → ctld.checkTroopStatus
│
├── Crates: Vehicle / FOB / Drone             [COND: enableCrates ET unitActions.crates ET NOT unitCanCarryVehicles]
│   ├── <Categorie_1>                         ┐ catégories triées alphabétiquement
│   │   ├── <desc_crate>                      │ → ctld.spawnCrate(weight)
│   │   ├── * <desc_multi_crate> (N)          │   filtré : side, isJTAC/JTAC_dropEnabled,
│   │   ├── ...                               │            multiple/enableAllCrates
│   │   └── Next page >              [PAG: 10/p par catégorie]
│   ├── <Categorie_2>                         │
│   │   └── ...                               │
│   └── Next page >                  [PAG: 10 catégories/p]
│
├── CTLD Commands                             [COND: (enabledFOBBuilding OU enableCrates) ET unitActions.crates]
│   ├── Load Nearby Crate(s)                  → ctld.loadNearbyCrate     [COND: loadCrateFromMenu]
│   ├── Drop Crate(s)                         → ctld.dropSlingCrate      [COND: loadCrateFromMenu OU hoverPickup]
│   ├── Unpack Any Crate                      [ÉVOLUTION] sous-menu dynamique des objets unpackables à proximité
│   │   ├── <desc_crate_1>                    → ctld.unpackCrate(crateWeight)  ┐ 1 entrée par type de crate
│   │   ├── <desc_crate_2>                    → ctld.unpackCrate(crateWeight)  │ détecté dans le périmètre
│   │   └── Next page >                                             [PAG: 10/p] ┘
│   ├── List Nearby Crates                    → ctld.listNearbyCrates
│   ├── List FOBs                             → ctld.listFOBS            [COND: enabledFOBBuilding]
│   └── Pack Vehicles                         [COND: enablePackingVehicles — DYNAMIQUE, refresh à l'atterrissage]
│       ├── pack <nom_unité_1>                → ctld.packVehicleRequest   ┐
│       ├── pack <nom_unité_2>                → ctld.packVehicleRequest   │ [PAG: 10/p]
│       └── Next page >                                                    ┘
│
├── Smoke Markers                             [COND: enableSmokeDrop]
│   ├── Drop Red Smoke                        → ctld.dropSmoke(RED)
│   ├── Drop Blue Smoke                       → ctld.dropSmoke(BLUE)
│   ├── Drop Orange Smoke                     → ctld.dropSmoke(ORANGE)
│   └── Drop Green Smoke                      → ctld.dropSmoke(GREEN)
│
└── Radio Beacons                             [COND: enabledRadioBeaconDrop]
    ├── List Beacons                          → ctld.listRadioBeacons
    ├── Drop Beacon                           → ctld.dropRadioBeacon
    └── Remove Closest Beacon                 → ctld.removeRadioBeacon
```

---

## Bloc 2 — Menu JTAC

Construit par `ctld.addJTACRadioCommand()`, appelé depuis `ctld.addOtherF10MenuOptions()` (polling toutes les **10 s**).
Visible pour **tous les joueurs** (transport et non-transport) de la même coalition que le JTAC.

```
F10 > <jtacMenuName>
│
├── JTAC Status                               → ctld.getJTACStatus
│
├── <NomGroupe_JTAC_1> Selection              [COND: jtacTargetsList >= 1 OU (currentTarget ET specialOptions)]
│   │
│   ├── Actions                               [COND: au moins 1 specialOption avec globalToggle == true]
│   │   ├── ENABLE <option>  /  DISABLE <option>   → specialOption.setter({value=true/false})
│   │   │   ou REQUEST <option>                     → specialOption.setter({value=false})
│   │   ├── ...
│   │   └── Next page >                    [PAG: 10/p]
│   │
│   ├── Reset TGT Selection                   → ctld.setJTACTarget(nil)
│   ├── <TypeCible_1>(N)                      → ctld.setJTACTarget   ┐ groupés par typeName,
│   ├── <TypeCible_2>(N)                      → ctld.setJTACTarget   │ hors cible courante
│   ├── ...                                                           │
│   └── Next page >                                        [PAG: 10/p]┘
│
├── <NomGroupe_JTAC_2> Selection
│   └── ...
│
└── Next Page >                               [PAG: 9 groupes JTAC/p — 1 slot réservé à "JTAC Status"]
```

---

## Bloc 3 — Menu RECON

Construit par `ctld.addReconRadioCommand()`, appelé depuis `ctld.addOtherF10MenuOptions()` (polling toutes les **10 s**).
Visible pour **tous les joueurs** si `ctld.reconF10Menu == true`.

```
F10 > <reconMenuName>
├── Show targets in LOS                       → ctld.showTargetsInLOS
├── Hide targets in LOS                       → ctld.hideTargetsInLOS
├── START autoRefresh targets in LOS          → toggle  [COND: autoRefresh non actif]
└── STOP autoRefresh targets in LOS           → toggle  [COND: autoRefresh actif]
```

---

## Bloc 4 — Menu minimal (joueurs non-transport, sans JTAC ni RECON)

Construit par `ctld.addRadioListCommand()` si `enabledRadioBeaconDrop == true` et que le groupe n'a pas déjà
reçu le menu CTLD complet (transport). Pas de sous-menu : entrée directement à la racine F10.

```
F10 (racine)
└── List Radio Beacons                        → ctld.listRadioBeacons
```

---

## Tableau de synthèse des paginations

| Localisation dans l'arbre | Seuil | Source des entrées |
|---|---|---|
| Troop Transport > Load … | **9/p** | `ctld.loadableGroups` filtrés par coalition et `transportLimit` |
| Crates > catégories | **10/p** | Clés de `ctld.spawnableCrates`, triées alphabétiquement |
| Crates > \<Catégorie\> > crates | **10/p** | Entrées filtrées : `side`, JTAC activé, flag `multiple`/`enableAllCrates` |
| CTLD Commands > Pack Vehicles | **10/p** | Unités dans le rayon `maximumDistancePackableUnitsSearch` à l'atterrissage |
| CTLD Commands > Unpack Any Crate | **10/p** | Types de crates unpackables détectés dans le périmètre au moment du clic |
| JTAC > groupes JTAC | **9/p** | Un slot est réservé à "JTAC Status" en page 1 |
| JTAC > \<Groupe\> > cibles | **10/p** | `jtacTargetsList`, groupés par `typeName`, hors cible courante |
| JTAC > \<Groupe\> > Actions | **10/p** | `ctld.jtacSpecialOptions` avec `globalToggle == true` |

---

## Notes pour la migration OOP

| Classe cible | Bloc(s) de menu à sa charge |
|---|---|
| `CTLDTroop` | "Troop Transport" (Load \<groupe\>, Unload/Extract) |
| `CTLDVehicle` | "Vehicle / FOB Transport", sous-menu dynamique "Pack Vehicles" (1er empaquetage ou ré-empaquetage) |
| `CTLDCrate` | "Crates: Vehicle / FOB / Drone", "CTLD Commands" (Load/Drop/Unpack/List) |
| `CTLDBeacon` | "Radio Beacons" (transport) + "List Radio Beacons" (non-transport) |
| `CTLDJtac` | Bloc JTAC complet |
| `CTLDRecon` | Bloc RECON complet |
| `CTLDPlayer` | Orchestration : détecte le type d'appareil, délègue la construction à chaque classe |

> Le sous-menu racine `CTLD` et l'entrée `Check Cargo` sont sous la responsabilité de `CTLDPlayer`,
> car ils existent indépendamment des capacités spécifiques de l'appareil.
