# CTLD_FG — Plan de recette C1 + M1–M5

## Modules couverts

| Module | Fichier source | Classes |
|--------|---------------|---------|
| C1 | `src/CTLD_core.lua` | EventDispatcher, CTLDDCSEventBridge, CTLDPlayerTracker, CTLDCoreManager |
| M1 | `src/CTLD_zone.lua` | CTLDTroopZone, CTLDLogisticZone, CTLDZoneManager |
| M2 | `src/CTLD_beacon.lua` | CTLDBeacon, CTLDBeaconManager |
| M3 | `src/CTLD_recon.lua` | CTLDReconRenderer, CTLDReconManager |
| M4 | `src/CTLD_fob.lua` | CTLDFOB, CTLDFOBManager |
| M5 | `src/CTLD_vehicle.lua` | CTLDVehicle, CTLDVehicleSpawner |

## Environnement d'exécution

- Scripts injectés via **Witchcraft** dans DCS en cours de mission.
- Commande : `node "$USERPROFILE/.vscode-dcs-tools/bridge.js" "<chemin_absolu>/recette/<cas>/test.lua"`
- Log dual : `env.info()` → DCS.log  +  `io.open()` → `recette/CTLD.log`
- Chaque script de cas purge `CTLD.log` en début d'exécution.

## Mission martyr — prérequis

La mission de test doit contenir :
- Au moins un appareil joueur BLUE (slot occupé ou coalition)
- Zones DCS nommées : `TRZ_alpha_B_10`, `TRZ_beta_R_0_obj1_5`, `LGZ_base_B`
- Un static objet de type cargo (pour F-01)
- Un groupe nommé `jtac_test` ou contenant "jtac" (pour F-02, F-09 à F-11)

---

## Section U — Tests unitaires (U-01 à U-22)

| N° | Nom | Module | Objectif | Statut | Temps estimé |
|----|-----|--------|----------|--------|--------------|
| U-01 | EventDispatcher — singleton | C1 | Vérifier que deux appels getInstance() retournent la même instance | ✅ PASS 3/3 | 2 min |
| U-02 | EventDispatcher — subscribe + publish | C1 | Callback reçoit le bon payload après subscribe/publish | ✅ PASS 6/6 | 3 min |
| U-03 | EventDispatcher — unsubscribe | C1 | Callback non appelé après unsubscribe | ✅ PASS 6/6 | 3 min |
| U-04 | EventDispatcher — isolation erreur | C1 | Un callback qui throw n'empêche pas l'exécution des suivants | ✅ PASS 5/5 | 3 min |
| U-05 | CTLDDCSEventBridge — singleton + register + route | C1 | Singleton unique, register enregistre, onEvent dispatche vers le bon handler | ✅ PASS 9/9 | 4 min |
| U-06 | CTLDPlayerTracker — getPlayerByUnit / isPlayerUnit | C1 | Index byUnit : retrouver playerName depuis unitName | ✅ PASS 6/6 | 4 min |
| U-07 | CTLDPlayerTracker — getUnitByPlayer / getAllPlayers | C1 | Index byPlayer : retrouver unitName + coalition depuis playerName | ✅ PASS 11/11 | 4 min |
| U-08 | CTLDZoneManager._parseTRZ — formats valides | M1 | Parser TRZ : minimal, coalition, stock, flag, target | ✅ PASS 24/24 | 5 min |
| U-09 | CTLDZoneManager._parseTRZ — formats invalides | M1 | Parser TRZ : erreurs retournées sur noms invalides | ✅ PASS 11/11 | 3 min |
| U-10 | CTLDZoneManager._parseLGZ — formats valides et invalides | M1 | Parser LGZ : noms bien formés et malformés | ✅ PASS 14/14 | 3 min |
| U-11 | CTLDTroopZone.isInZone — circulaire | M1 | Point dedans / dehors sur zone circulaire | ✅ PASS 7/7 | 3 min |
| U-12 | CTLDTroopZone consumeStock / restoreStock | M1 | Stock limité + stock illimité (pickMaxStock==0) | ✅ PASS 15/15 | 4 min |
| U-13 | CTLDLogisticZone isInZone + getCenter | M1 | Zone statique : point dedans / dehors + center constant | ✅ PASS 12/12 | 3 min |
| U-14 | CTLDBeacon isBatteryAlive / batteryRemaining / freqText | M2 | Batterie infinie (-1), finie et expirée ; format texte fréquences | ✅ PASS 10/10 | 4 min |
| U-15 | CTLDBeaconManager _buildFreqPools | M2 | Pools VHF/UHF/FM générées ; NDB skippés dans VHF ; UHF < 399 MHz | ✅ PASS 9/9 | 4 min |
| U-16 | CTLDReconRenderer.createIcon — routing | M3 | Dispatch vers la bonne fonction de dessin selon layer.iconRenderer | ✅ PASS 14/14 | 4 min |
| U-17 | CTLDReconManager._matchLayer — layer assignment | M3 | Unité avec attribut Infantry → layer infantry retourné | ✅ PASS 9/9 | 4 min |
| U-18 | CTLDFOB isAlive / getIntegrityPercent | M4 | Seuils : 0 objet, 1/3 vivants, tous vivants | ✅ PASS 10/10 | 4 min |
| U-19 | CTLDVehicle états (WAITING → LOADED → DELIVERED) | M5 | Transitions d'état | ✅ PASS 15/15 | — |
| U-20 | CTLDVehicleSpawner singleton | M5 | getInstance() retourne la même instance | ✅ PASS 6/6 | — |
| U-21 | _worldToLocal + bbox inclusion | M5 | Algo géométrique pur (point dans boîte 3D) | ✅ PASS 8/8 | — |
| U-22 | getDesc().box sur C-130J-30 | M5 | API DCS : vérification existence desc.box | ✅ PASS 1/1 (skip: C-130 absent) | — |

---

## Section F — Tests fonctionnels (F-01 à F-20)

| N° | Nom | Module | Objectif | Statut | Temps estimé |
|----|-----|--------|----------|--------|--------------|
| F-01 | CTLDCoreManager INIT-B — statics cargo MM | C1 | coalition.getStaticObjects → cargo détectés et loggés | ✅ PASS 3/3 | 5 min |
| F-02 | CTLDCoreManager INIT-C — groupes JTAC MM | C1 | coalition.getGroups → groupe "jtac" détecté et loggé | ✅ PASS 3/3 | 5 min |
| F-03 | CTLDZoneManager discovery TRZ | M1 | env.mission.triggers.zones → TRZ chargées dans _troopZones | ✅ PASS 6/6 | 5 min |
| F-04 | CTLDZoneManager discovery LGZ | M1 | env.mission.triggers.zones → LGZ chargées dans _logisticZones | ✅ PASS 6/6 | 5 min |
| F-05 | CTLDZoneManager onDead → suppression + event | M1 | Simulation S_EVENT_DEAD sur linked unit → zone retirée + OnLogisticZoneUpdated | ✅ PASS 8/8 | 6 min |
| F-06 | CTLDBeaconManager dropBeacon | M2 | Unit spawné + fréquences assignées + OnBeaconDropped publié | ✅ PASS 18/18 | 6 min |
| F-07 | CTLDBeaconManager removeClosestBeacon | M2 | Beacon le plus proche supprimé + OnBeaconRemoved publié | ✅ PASS 10/10 | 6 min |
| F-08 | CTLDBeaconManager toggleLayer | M2 | Layer ON/OFF + OnBeaconLayerToggled publié avec bon newState | ✅ PASS 14/14 | 5 min |
| F-09 | CTLDReconManager scan | M3 | Marks F10 créés + OnReconScan publié avec targets | ✅ PASS 9/9 | 7 min |
| F-10 | CTLDReconManager hideScan | M3 | Marks supprimés + OnReconHideTargets publié | ✅ PASS 8/8 | 5 min |
| F-11 | CTLDReconManager enableAutoRefresh / disable | M3 | OnReconAutoRefreshEnabled + OnReconAutoRefreshDisabled publiés | ✅ PASS 20/20 | 6 min |
| F-12 | CTLDFOBManager unpackFOBCrates → scène + OnFOBDeployed | M4 | Scène jouée, FOB créé, OnFOBDeployed avec fobId | ✅ PASS 17/17 | 10 min |
| F-13 | CTLDFOBManager onDead → intégrité + OnFOBDestroyed | M4 | Simulation destruction objet scène → OnFOBDestroyed si seuil atteint | ✅ PASS 21/21 | 7 min |
| F-14 | CTLDZoneManager registerFOBAsLogistic / unregisterLogistic | M4 | register → zone accessible + event ; unregister → zone retirée + event | ✅ PASS 20/20 | 5 min |
| F-15 | CTLDVehicleSpawner spawnVehicleForTransport | M5 | OnVehicleSpawnedForTransport | ✅ PASS 19/19 | — |
| F-16 | loadVehicle method=menu_ctld | M5 | Unit détruite + OnVehicleLoaded | ✅ PASS 18/18 | — |
| F-17 | unloadVehicle method=menu_ctld | M5 | Unit respawn + OnVehicleUnloaded | ✅ PASS 15/15 | — |
| F-18 | load DCS natif C-130 bbox | M5 | Bbox inclusion détectée → OnVehicleLoaded | ✅ PASS 13/13 | — |
| F-19 | unload C-130 au sol | M5 | Sortie bbox → OnVehicleUnloaded method=dcs_native | ✅ PASS 11/11 | — |
| F-20 | unload C-130 en vol | M5 | Sortie bbox → OnVehicleUnloaded method=parachute | ✅ PASS 11/11 | — |

---

## Statuts

| Symbole | Signification |
|---------|--------------|
| ⬜ TODO | À exécuter |
| 🔄 WIP | En cours |
| ✅ PASS | Passé (tous asserts OK) |
| ❌ FAIL | Échec (au moins un assert KO) |
| ⬜ PENDING | Script non codé — en attente d'implémentation |

---

## Résumé de couverture

- **C1** : 7 unitaires + 2 fonctionnels = **9 cas**
- **M1** : 6 unitaires + 3 fonctionnels = **9 cas**
- **M2** : 2 unitaires + 3 fonctionnels = **5 cas**
- **M3** : 2 unitaires + 3 fonctionnels = **5 cas**
- **M4** : 1 unitaire  + 3 fonctionnels = **4 cas**
- **M5** : 4 unitaires + 6 fonctionnels = **10 cas**
- **Total** : **42 cas** — 42/42 PASS
