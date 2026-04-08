# CTLD_FG — Plan de recette C1 + M1–M7

## Modules couverts

| Module | Fichier source | Classes |
|--------|---------------|---------|
| C1 | `src/CTLD_core.lua` | EventDispatcher, CTLDDCSEventBridge, CTLDPlayerTracker, CTLDCoreManager |
| M1 | `src/CTLD_zone.lua` | CTLDTroopZone, CTLDLogisticZone, CTLDZoneManager |
| M2 | `src/CTLD_beacon.lua` | CTLDBeacon, CTLDBeaconManager |
| M3 | `src/CTLD_recon.lua` | CTLDReconRenderer, CTLDReconManager |
| M4 | `src/CTLD_fob.lua` | CTLDFOB, CTLDFOBManager |
| M5 | `src/CTLD_vehicle.lua` | CTLDVehicle, CTLDVehicleSpawner |
| M6 | `src/CTLD_aasystem.lua` | CTLDCrateAssemblyManager |
| M7 | `src/CTLD_player.lua` | CTLDPlayer, CTLDPlayerManager |
| R4 | `src/CTLD_sceneManager.lua` | CtldScene, CTLDSceneManager + fobScene (auto-enregistrement) |
| R5 | `src/CTLD_player.lua` + tous managers | buildMenu() Option D — registerMenuSection + config-variant |

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
| U-23 | CTLDCrateAssemblyManager singleton + getTemplateForUnit | M6 | Singleton unique, template trouvé pour parts/repair/nil | ✅ PASS 16/16 | — |
| U-24 | countComplete + getAllowedCount + guards | M6 | 0 sans systèmes, config limits, tryUnpackOrRepair guards | ✅ PASS 11/11 | — |
| U-25 | _buildSpawnArrays géométrie | M6 | Positions distinctes, counts corrects KUB et NASAMS | ✅ PASS 13/13 | — |
| U-26 | CTLDPlayer entity — construct + cargo helpers | M7 | Propriétés init correctes, add/removeLoadedVehicle/Crate | ✅ PASS 20/20 | — |
| U-27 | CTLDPlayerManager singleton + getPlayer nil | M7 | getInstance() idempotent, getPlayer inconnu == nil | ✅ PASS 5/5 | — |
| U-28 | _detectCapabilities — isTransport + canCarryVehicles | M7 | UH-1H/Hercules/F-16C_50 détectés correctement | ✅ PASS 6/6 | — |
| U-29 | onPlayerEnterUnit + onPlayerLeaveUnit état _players | M7 | Player créé puis supprimé, propriétés correctes | ✅ PASS 9/9 | — |
| U-30 | CTLDCrate états + helpers | R1 | SPAWNED→LOADED→LANDED→UNPACKED, isOnGround/isLoaded | ✅ PASS 22/22 | — |
| U-31 | canUnpack logique | R1 | forceCrateToBeMoved, canBeUnpacked, isOnGround guards | ✅ PASS 7/7 | — |
| U-32 | CTLDCrateManager singleton + getCrateByName + getCratesInRange | R1 | Singleton, lookup, filtre distance | ✅ PASS 9/9 | — |
| U-33 | findDescriptorByTypeName | R1 | Match typeName dans spawnableCrates, nil si inconnu | ✅ PASS 9/9 | — |
| U-34 | checkAssemblyReady | R1 | cratesRequired=1 toujours ready, =2 avec/sans crate manquante | ✅ PASS 9/9 | — |
| U-35 | CTLDTroopGroup entity — init + états + transitions | R2 | LOADED→DEPLOYED→EXTRACTED, isInTransit, deploy(nil) EXZ | ✅ PASS 19/19 | — |
| U-36 | CTLDTroopManager singleton + _registerTemplates | R2 | getInstance() idempotent, templates → db entries, total/hasJtac | ✅ PASS 17/17 | — |
| U-37 | hasTroops / getInTransit / getWeight | R2 | Lookup direct, absent/présent, suppression | ✅ PASS 10/10 | — |
| U-38 | _transportLimit | R2 | Default numberOfTroops + byType override | ✅ PASS 8/8 | — |
| U-39 | CTLDJTAC entity — init + transitions d'états | R3 | IDLE→LASING→ORBITING→IN_TRANSIT→DEAD, updateLaseSpot | ✅ PASS 25/25 | — |
| U-40 | CTLDJTACDetector.calculateFMRadio | R3 | Formule FM, limites 1111-1688, edge cases | ✅ PASS 11/11 | — |
| U-41 | CTLDJTACDetector.calculateCorrectedSpot | R3 | Algo pur: anticipation vel + correction vent | ✅ PASS 9/9 | — |
| U-42 | CTLDJTACManager singleton + laser pool | R3 | getInstance idempotent, pool 578 codes, assign/free | ✅ PASS 12/12 | — |
| U-43 | CTLDSceneManager singleton + registerSceneModel | R4 | getInstance idempotent, register/guards/getModel, built-in FARP Alpha | ✅ PASS 9/9 | — |
| U-44 | CtldScene step execution engine — func-only, delay=0 | R4 | 3 steps en ordre, onComplete appelé, _params transmis | ✅ PASS 8/8 | — |

---

## Section F — Tests fonctionnels (F-01 à F-36)

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
| F-21 | _assemble KUB complet | M6 | OnAASystemDeployed publié, countComplete==1, crates détruites | ✅ PASS 11/11 | — |
| F-22 | _assemble KUB incomplet | M6 | Pas de déploiement, pas de crates détruites | ✅ PASS 6/6 | — |
| F-23 | _repair KUB → OnAASystemRepaired | M6 | Repair crate détruite, système remplacé dans _completeSystems | ✅ PASS 14/14 | — |
| F-24 | onPlayerEnterUnit → menu créé | M7 | CTLDPlayer dans _players + sous-menu 'CTLD' dans ctld.MenuManager | ✅ PASS 6/6 | — |
| F-25 | OnVehicleLoaded/Unloaded → loadedVehicles | M7 | ctldVehicleObject ajouté puis retiré de player.loadedVehicles | ✅ PASS 6/6 | — |
| F-26 | onPlayerLeaveUnit → player + menu supprimés | M7 | getPlayer == nil après Leave, _players vide | ✅ PASS 5/5 | — |
| F-27 | registerMMCrate → crate enregistrée | R1 | Mock static cargo → getCrateByName retourne la crate | ✅ PASS 9/9 | — |
| F-28 | loadCrate → OnCrateLoaded | R1 | État LOADED + event publié avec payload correct | ✅ PASS 11/11 | — |
| F-29 | unloadCrate → OnCrateUnloaded | R1 | État LANDED + event publié method=menu_ctld | ✅ PASS 11/11 | — |
| F-30 | unpackCrate → OnCrateUnpacked + destroy | R1 | État UNPACKED + event + crate retirée du registry | ✅ PASS 10/10 | — |
| F-31 | dropCrate ≤ maxDropHeight → OnCrateUnloaded | R1 | Drop safe → method=drop, crate en LANDED | ✅ PASS 10/10 | — |
| F-32 | dropCrate > maxDropHeight → OnCrateDestroyed | R1 | Drop haute → reason=drop_impact, crate détruite | ✅ PASS 8/8 | — |
| F-33 | loadFromZone — guards + success | R2 | Guards coalition/active/limit/capacity + load OK + limit décrément | ✅ PASS 13/13 | — |
| F-34 | deploy — on ground, pas d'EXZ | R2 | spawnObject appelé, troupes vidées, groupe dans _droppedGroups | ✅ PASS 9/9 | — |
| F-35 | returnToBase | R2 | Troupes retournées, zone.limit incrémenté, unlimited inchangé | ✅ PASS 9/9 | — |
| F-36 | extract | R2 | Groupe mock nearby → état EXTRACTED, retiré de _droppedGroups | ✅ PASS 8/8 | — |
| F-37 | spawnJTAC + markPending | R3 | Mock group → OnJTACSpawned + registry + pending flags | ✅ PASS 13/13 | — |
| F-38 | setJTACInTransit → état + OnJTACInTransit | R3 | Lase stoppé, état IN_TRANSIT, payload correct, guards | ✅ PASS 9/9 | — |
| F-39 | requestSmoke → OnJTACSmokeTarget | R3 | Payload smokePos déterministe (margin=0), guards | ✅ PASS 11/11 | — |
| F-40 | killJTAC → OnJTACDead + laser libéré | R3 | État DEAD, registry vidé, laser pool +1, guards | ✅ PASS 11/11 | — |
| F-41 | registerMMCrate → OnMMCrateDetected | FC | Event publié avec payload correct, guards double/inconnu | ✅ PASS 9/9 | — |
| F-42 | playScene — guards | R4 | nil unit, dead unit, unknown model → nil ; valid call → scene | ✅ PASS 4/4 | — |
| F-43 | FARP Alpha scene — structure validation | R4 | 14 steps, registryKeys, types polar, func, delayAfterPreviousStep | ✅ PASS 11/11 | — |
| F-44 | fobScene auto-enregistrement | R4 | Absent avant dofile, présent après + 4 steps + clés correctes | ✅ PASS 10/10 | — |
| F-45 | buildMenu() initial — UH-1H + all ON | R5 | Menu F10 construit : FOB disabled, sections présentes — VISUAL CHECK | ⬜ TODO | — |
| F-46 | Double refresh() idempotent | R5 | Deuxième refresh() → menu identique — VISUAL CHECK | ⬜ TODO | — |
| F-47 | Enable FOB + clearBranch + pagination | R5 | FOB activé + Pack Vehicles 11 items → 9+NextPage — VISUAL CHECK | ⬜ TODO | — |
| F-48 | buildMenu() tous flags true — toutes sections | R5 | isTransport=true, canCarryVehicles=false : 8 sections + Pack Vehicle présents | ✅ PASS 10/10 | — |
| F-49 | enableCrates=false → Spawn Crates + Crate Commands absent | R5 | Smoke + Beacons + Troops toujours présents | ✅ PASS 5/5 | — |
| F-50 | enabledRadioBeaconDrop=false → Radio Beacons absent | R5 | Toutes autres sections présentes | ✅ PASS 5/5 | — |
| F-51 | reconF10Menu=false → RECON absent | R5 | Toutes autres sections présentes | ✅ PASS 4/4 | — |
| F-52 | JTAC_jtacStatusF10=false → JTAC absent | R5 | Toutes autres sections présentes | ✅ PASS 4/4 | — |
| F-53 | enabledFOBBuilding=false → List FOBs absent | R5 | Crate Commands présent, Pack Vehicle présent | ✅ PASS 3/3 | — |
| F-54 | enablePackingVehicles=false → Pack Vehicle absent | R5 | Crate Commands présent, List FOBs présent | ✅ PASS 3/3 | — |
| F-55 | non-transport → pas de sections transport | R5 | isTransport=false : Troops/Crates/Smoke/Beacons absents ; RECON+JTAC présents | ✅ PASS 8/8 | — |
| F-56 | canCarryVehicles=true → Vehicle Commands présent | R5 | UH-1H canCarryVehicles=true : Vehicle Commands + Troops + Crates présents | ✅ PASS 3/3 | — |
| F-57 | parachuteCrates — altitude OK | FA | OnCrateParachuting publié, crate FALLING, estimatedLandingTime set | ✅ PASS 7/7 | — |
| F-58 | parachuteCrates — altitude trop basse | FA | Aucun event, crate reste LOADED | ✅ PASS 3/3 | — |
| F-59 | parachuteTroops — altitude OK | FA | OnTroopsDeployed(trigger=parachute), groupe retiré du transport | ✅ PASS 4/4 | — |
| F-60 | parachuteTroops — altitude trop basse | FA | Aucun event, groupe intact dans _inTransit | ✅ PASS 2/2 | — |
| F-61 | parachuteVehicle — altitude OK | FA | OnVehicleParachuting publié, vehicle DELIVERED | ✅ PASS 6/6 | — |
| F-62 | parachuteVehicle — altitude trop basse | FA | Aucun event, vehicle reste LOADED | ✅ PASS 2/2 | — |
| F-63 | canParachute=false → menus parachute absents | FA | UH-1H canParachute=false : Parachute Crates/Troops/Vehicle absents | ✅ PASS 6/6 | — |
| F-64 | canParachute=true → menus parachute présents | FA | UH-1H canParachute=true : 3 menus présents | ✅ PASS 3/3 | — |

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
- **M6** : 3 unitaires + 3 fonctionnels = **6 cas**
- **M7** : 4 unitaires + 3 fonctionnels = **7 cas** ✅ PASS
- **R1** : 5 unitaires + 6 fonctionnels = **11 cas** ✅ PASS
- **R2** : 4 unitaires + 4 fonctionnels = **8 cas** ✅ PASS
- **R3** : 4 unitaires + 4 fonctionnels = **8 cas** ✅ PASS
- **R4** : 2 unitaires + 3 fonctionnels = **5 cas** ✅ PASS
- **R5** : 0 unitaires + 12 fonctionnels = **12 cas** ✅ PASS (F-45→F-47 visual ⬜, F-48→F-56 45/45 ✅)
- **FA** : 0 unitaires + 8 fonctionnels = **8 cas** ✅ PASS (F-57→F-64 33/33 ✅)
- **FC** : 1 fonctionnel = **1 cas** ✅ PASS
- **Total** : **108 cas** — 130/130 PASS (3 visual R5 ⬜ DCS requis)
