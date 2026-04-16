# CTLD_FG — Plan de recette C1 + M1–M10 + R1–R5 + FA–FD + scenes fob/farp

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
| FB | `src/CTLD_crate.lua` | CTLDCrateManager — virtual slingload (hover pickup + release/cut) |
| M8 | `src/CTLD_menu.lua` | ctld.Menu, ctld.MenuManager |
| M9 | `src/CTLD_utils.lua` | ctld.utils.* (math, vecteurs, géométrie, données) |
| M10 | `src/scenes/CTLD_mineFieldScene.lua` | mineFieldScene (setLandMine, auto-registration) |

## Environnement d'exécution

- Scripts injectés via **Witchcraft** dans DCS en cours de mission.
- Commande : `node "$USERPROFILE/.vscode-dcs-tools/bridge.js" "<chemin_absolu>/recette/<cas>/test.lua"`
- Log dual : `env.info()` → DCS.log  +  `io.open()` → `recette/CTLD.log`
- Chaque script de cas purge `CTLD.log` en début d'exécution.
- **Purge des objets DCS** entre tests visuels : `node bridge.js recette/purge_scene.lua` — détruit tous les statics/groupes spawnés par les scènes (prefixes SINGLE_HELIPAD, FOB_Outpost, CTLDBeacon, etc.).

## Mission martyr — prérequis

La mission de test doit contenir :
- Au moins un appareil joueur BLUE (slot occupé ou coalition)
- Zones DCS nommées : `TRZ_alpha_B_10`, `TRZ_beta_R_0_obj1_5`, `LGZ_base_B`
- Un static objet de type cargo (pour F-01)
- Un groupe nommé `jtac_test` ou contenant "jtac" (pour F-02, F-09 à F-11)

---

## Section U — Tests unitaires (U-01 à U-80)

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
| U-54 | CTLDObjectRegistry get() + findByDCSType() | P1 | Lookup direct + reverse lookup par DCS typeName + nil guards | ✅ PASS 14/14 | — |
| U-55 | CTLDObjectRegistry spawnObject() STATIC | P1 | coalition.addStaticObject appelé, champs injectés, overrides, unknown key nil | ✅ PASS 16/16 | — |
| U-56 | CTLDObjectRegistry spawnObject() GROUND | P1 | 3 unités, coalition-aware unitType BLUE/RED, rotation heading 0° et 90° | ✅ PASS 13/13 | — |
| U-57 | ctld.MenuManager singleton | M8 | getInstance() idempotent — même instance retournée | ✅ PASS 3/3 | — |
| U-58 | createMenuForGroup | M8 | Succès, idempotence, guards (nil / string) | ✅ PASS 6/6 | — |
| U-59 | _sortByOrder | M8 | Tri ascendant par order, sans-order → fin | ✅ PASS 7/7 | — |
| U-60 | addSubMenu succès + idempotence + opts | M8 | Création nœud, idempotence, opts order/enabled | ✅ PASS 10/10 | — |
| U-61 | addSubMenu guards | M8 | name nil, parent=command node → failure | ✅ PASS 4/4 | — |
| U-62 | addCommand succès + guards | M8 | Succès, anyArgument nil→{}, guards fn/arg/name invalides | ✅ PASS 9/9 | — |
| U-63 | clearBranch | M8 | Vide children, container intact, guards | ✅ PASS 7/7 | — |
| U-64 | setBranchEnabled | M8 | Toggle true/false, guard path inconnu | ✅ PASS 6/6 | — |
| U-65 | removeMenuBranch | M8 | Suppression + removedCount, root guard, path inconnu | ✅ PASS 8/8 | — |
| U-66 | _rebuildPagedChildren pagination | M8 | ≤10 inline, 11→9+NextPage+2, 20→deux niveaux | ✅ PASS 6/6 | — |
| U-67 | ctld.utils math utilities | M9 | round, radianToDegree, normalizeHeadingInDegrees, kmphToMps | ✅ PASS 14/14 | — |
| U-68 | vec3Mag + get2DDist + getDistance | M9 | Triangle 3-4-5, Vec2 input, guards nil→0 | ✅ PASS 11/11 | — |
| U-69 | addVec3 + subVec3 + multVec3 | M9 | Opérations vectorielles, nil guards | ✅ PASS 13/13 | — |
| U-70 | makeVec3FromVec2OrVec3 + makeVec2FromVec3OrVec2 | M9 | Conversions Vec2↔Vec3, passthrough, nil→nil | ✅ PASS 14/14 | — |
| U-71 | rotateVec3 + polarToCartesian | M9 | Heading 0°/90° exacts ; polarToCartesian distance×2 | ✅ PASS 13/13 | — |
| U-72 | deepCopy + isValueInIpairTable + countTableEntries + getNextUniqId | M9 | Copie indépendante, lookup, count, compteur monotone | ✅ PASS 16/16 | — |
| U-73 | zoneToVec3 branche table | M9 | {point=}, {x,y,z} direct, nil→nil | ✅ PASS 8/8 | — |
| U-74 | mineFieldScene structure + auto-registration | M10 | Modèle 'mineField' enregistré dans CTLDSceneManager, stepsDatas, setLandMine | ✅ PASS 7/7 | — |
| U-75 | mineFieldScene.setLandMine guards | M10 | nil unit → false ; nbMinesColumns=0 + unit réel → false | ✅ PASS 5/5 | — |
| U-76 | createLoadableGroup — valid cases | FD | Minimal (1 champ), full (6 champs), side=nil ; total/hasJtac/_dbKey/ObjectRegistry | ✅ PASS 21/21 | — |
| U-77 | createLoadableGroup — guard cases | FD | nil config, no name, empty name, no composition, zero composition, duplicate std, duplicate custom | ✅ PASS 15/15 | — |
| U-78 | removeLoadableGroup | FD | Remove custom + clear ObjectRegistry, remove standard, not-found error | ✅ PASS 12/12 | — |
| U-79 | editLoadableGroup | FD | Edit composition + side, recompute total/hasJtac, refuse standard, not-found, zero composition | ✅ PASS 21/21 | — |
| U-80 | disableLoadableGroup / enableLoadableGroup | FD | Toggle disabled, template count unchanged, not-found error | ✅ PASS 15/15 | — |
| U-81 | CTLDTroopManager:_resolveTemplateForLegacy | Q1 | int exact/closest, table sum, disabled template skippé, no templates → nil | ✅ PASS 14/14 | — |
| U-82 | CTLDCrateManager:findDescriptorByUnitType | Q1 | match typeName, nil si inconnu, BLUE only invisible RED | ✅ PASS 25/25 | — |
| U-83 | CTLDVehicleSpawner:findPackableVehicles | Q1 | scan ground units coalition, filtre distance, exclude transport | ✅ PASS 23/23 | — |
| U-84 | CTLDConfig singleton pattern | Config | get() × 2 → même instance, isLoaded, mutation partagée | ✅ PASS 5/5 | — |
| U-85 | CTLDConfig load() idempotency | Config | 2nd load() retourne tôt, mutation préservée | ✅ PASS 4/4 | — |
| U-86 | CTLDConfig getSetting() defaults | Config | 10 valeurs par défaut clés vérifiées | ✅ PASS 10/10 | — |
| U-87 | ctld.gs() shortcut | Config | 3 clés connues + clé inconnue → nil | ✅ PASS 4/4 | — |
| U-88 | CTLDConfig.to_type() | Config | bool/int/float/string/quotes | ✅ PASS 8/8 | — |
| U-89 | CTLDConfig.parseYAML() | Config | k/v simple, types, dotted keys, multi-line, empty | ✅ PASS 9/9 | — |
| U-90 | CTLDi18n — audit() exists | i18n | ctld.i18n_audit + ctld.i18n_auditAll existent et sont appelables | ✅ PASS 4/4 | — |
| U-91 | CTLDi18n — audit() structure | i18n | audit("fr") → table avec version_match, en_version, lang_version, missing, untranslated | ✅ PASS 8/8 | — |
| U-92 | CTLDi18n — audit() lang inconnue | i18n | audit("zz") → nil + string d'erreur contenant le code langue | ✅ PASS 4/4 | — |
| U-93 | CTLDi18n — audit() détecte clé manquante | i18n | mock: supprimer clé FR → missing contient la clé, untranslated ne la contient pas | ✅ PASS 4/4 | — |
| U-94 | CTLDi18n — audit() détecte clé non traduite | i18n | mock: FR[key]=EN[key] → untranslated contient la clé, missing ne la contient pas | ✅ PASS 4/4 | — |
| U-95 | CTLDi18n — audit() détecte version mismatch | i18n | mock: FR version="0.0" → version_match=false ; restore → version_match=true | ✅ PASS 5/5 | — |
| U-96 | CTLDi18n — auditAll() | i18n | fr+es+ko présents, "en" absent, chaque entrée a la structure attendue | ✅ PASS 14/14 | — |

---

## Section F — Tests fonctionnels (F-01 à F-105)

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
| F-45 | buildMenu() initial — UH-1H + all ON | R5 | Menu F10 construit : FOB disabled, sections présentes — VISUAL CHECK | ✅ PASS (visual) | — |
| F-46 | Double refresh() idempotent | R5 | Deuxième refresh() → menu identique — VISUAL CHECK | ✅ PASS (visual) | — |
| F-47 | Enable FOB + clearBranch + pagination | R5 | FOB activé + Pack Vehicles 11 items → 9+NextPage — VISUAL CHECK | ✅ PASS (visual) | — |
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
| F-65 | canSlingload=false → menus Release/Cut absents | FB | transport en vol, canSlingload=false : menus absents | ✅ PASS 2/2 | — |
| F-66 | canSlingload=true, transport au sol → menus absents | FB | inAir=false : Release/Cut absents | ✅ PASS 2/2 | — |
| F-67 | canSlingload=true, transport en vol → menus présents | FB | inAir=true : Release/Cut présents | ✅ PASS 2/2 | — |
| F-68 | checkHoverStatus — hover OK → OnCrateLoaded(slingload) | FB | hoverTime=1, hauteur et distance OK → hook + inTransitOnSlingload=true | ✅ PASS 4/4 | — |
| F-69 | checkHoverStatus — hauteur hors plage → pas d'accrochage | FB | transport trop haut → hoverStatus reset, crate intacte | ✅ PASS 4/4 | — |
| F-70 | releaseSlingload — AGL ≤ maxH → OnCrateUnloaded(slingload_release) | FB | AGL=8m ≤ 12m : release propre | ✅ PASS 4/4 | — |
| F-71 | cutSlingload — AGL > 40m → OnCrateLost(slingload_cut_impact) | FB | AGL=190m : crate détruite | ✅ PASS 4/4 | — |
| F-72 | refreshMenuForGroup séquence complète | M8 | create+addSubMenu+addCommand+refresh → missionCommands dans bon ordre | ✅ PASS 7/7 | — |
| F-73 | disabled nodes invisibles en DCS | M8 | setBranchEnabled(false)+refresh → pas d'appel DCS ; re-enable → apparaît | ✅ PASS 4/4 | — |
| F-74 | order détermine l'ordre de rendu DCS | M8 | 3 submenus ordre 30/10/20 → rendus 10/20/30 | ✅ PASS 4/4 | — |
| F-75 | clearBranch + repopulate + refresh | M8 | Pattern proximité : 3 nouvelles commandes, anciennes absentes | ✅ PASS 5/5 | — |
| F-76 | removeMenuBranch permanent — mémoire + _lookup | M8 | Nœud absent du parent + _lookup nettoyé | ✅ PASS 8/8 | — |
| F-77 | refreshMenuForGroup sans menu connu → failure | M8 | success=false + message + refreshedCount=0 | ✅ PASS 3/3 | — |
| F-81 | Pagination visuelle DCS F10 | M8 | 11 items → 9 en page 1 + "→ Next Page" → 2 items — VISUAL CHECK | ✅ PASS (visual) | — |
| F-82 | Ordering visuel DCS F10 | M8 | Submenus ordre 30/10/20 → rendus A→B→C dans F10 — VISUAL CHECK | ✅ PASS (visual) | — |
| F-78 | getCentroid | M9 | 4 points → centroïde x/z correct, empty→nil (mock land.getHeight) | ✅ PASS 8/8 | — |
| F-79 | calcDropPosition | M9 | descentTime==AGL/rate, position décalée selon vitesse (mock Unit) | ✅ PASS 5/5 | — |
| F-80 | getSpawnObjectPositions | M9 | n positions, structure {positions,clock,distance}, spacing vérifié | ✅ PASS 16/16 | — |
| F-83 | mineFieldScene setLandMine 1×1 single mine | M10 | 1 mine spawnée réelle + carré F10 — VISUAL CHECK | ✅ PASS 5/5 | — |
| F-84 | mineFieldScene setLandMine 5×15 quinconce | M10 | 68 mines quinconce + grand quad F10 — VISUAL CHECK | ✅ PASS 4/4 | — |
| F-85 | mineFieldScene setLandMine 4×3 quinconce | M10 | 11 mines quinconce + quad F10 — VISUAL CHECK | ✅ PASS 4/4 | — |
| F-86 | mineFieldScene showMinefieldOnF10Map config guard | M10 | drawQuad non appelé si false, appelé si true | ✅ PASS 4/4 | — |
| F-87 | mineFieldScene setLandMineAuto parametric | M10 | 50×80 ~40 mines, nbMines=1, guards — VISUAL CHECK | ✅ PASS 11/11 | — |
| F-88 | _loadUserConfig — ctld_config_user | FD | 3 customs créés, 2 standards désactivés, ObjectRegistry peuplé | ✅ PASS 18/18 | — |
| F-89 | buildMenu filtre disabled / side / capacity | FD | 2 Load visibles (Standard+BLUE Recon), 4 exclus (disabled×2, side×1, cap×1) | ✅ PASS 7/7 | — |
| F-90 | fobScene structure + spawn visuel | R4 | 4 steps, registryKeys, prescript, container + watchtower en mission | ✅ PASS 18/18 | — |
| F-91 | farpScene structure + spawn visuel | R4 | 6 steps (prescript+5), ref 50m devant hélico, tous objets relatifs au helipad | ✅ PASS 24/24 | — |
| F-92 | FOB beacon — dropBeacon au centroid | CTLD_fob+beacon | beacon spawné au centroid FOB (dx=0), batterie infinie, 3 groupes VHF/UHF/FM | ✅ PASS 13/13 | — |
| F-93 | FOB unpack complet — fobScene + beacon | CTLD_fob+beacon | flow complet _onFOBBuilt : container+watchtower+beacon au centroid ✅ visual | ✅ PASS visual | — |
| U-81 | _resolveTemplateForLegacy | Q1 | integer exact/closest, composition table, disabled skip, empty → nil | ✅ PASS 14/14 | — |
| U-82 | CTLDZoneManager new methods | Q1 | createExtractZone/removeExtractZone/changeRemainingGroups/isUnitInZone | ✅ PASS 25/25 | — |
| U-83 | CTLDCrateManager:spawnCrate + findDescriptorByUnitType | Q1 | coalition.addStaticObject, model selection, OnCrateSpawned, guards | ✅ PASS 23/23 | — |
| F-94 | Legacy API — Troops wrappers | Q1 | 6 wrappers : routing + deprecation warning | ✅ PASS 18/18 | — |
| F-95 | Legacy API — Zones wrappers | Q1 | 10 wrappers : routing correct vers CTLDZoneManager + CTLDTroopManager | ✅ PASS 23/23 | — |
| F-96 | Legacy API — Crates wrappers | Q1 | spawnCrateAtZone/Point functional + cratesInZone watcher | ✅ PASS 12/12 | — |
| F-97 | Legacy API — Beacon wrapper | Q1 | createRadioBeaconAtZone → createAtZone + warning | ✅ PASS 6/6 | — |
| F-98 | Legacy API — JTAC wrappers | Q1 | 3 wrappers JTACAutoLase/JTACStart/JTACAutoLaseStop | ✅ PASS 11/11 | — |
| F-99 | Pack Vehicle flow | Q1 | findPackableVehicles + packVehicle : destroy, spawnCrate, OnVehiclePacked, menu refresh | ✅ PASS 16/16 | — |
| F-100 | spawnCrate — VISUAL CHECK | Q1 | 2 statics réels (load + dynamic) ~30/60 m devant hélico, StaticObject.getByName ✅, OnCrateSpawned×2 | ✅ PASS 14/14 visual ✅ [2026-04-15] | — |
| F-101 | CTLDConfig userConfig override | Config | ctld.yamlConfigDatas → 3 settings overridés, 1 non-overridé intact, report string | ✅ PASS 6/6 | — |
| F-102 | CTLDConfig singleton reset + fresh defaults | Config | reset _instance → fresh load → defaults restaurés, isLoaded=true | ✅ PASS 5/5 | — |
| F-103 | CTLDi18n — ctld.tr() fallback chain | i18n | FR→EN→key, paramètres %1/%2, langue inconnue, clé inconnue | ✅ PASS 6/6 | — |
| F-104 | CTLDi18n — audit complet FR | i18n | audit("fr") : version_match, 0 missing (untranslated intentionnels loggés, pas d'échec) | ✅ PASS 4/4 | — |
| F-105 | CTLDi18n — audit complet ES+KO | i18n | audit("es") + audit("ko") : version_match, 0 missing, untranslated loggés | ✅ PASS 10/10 | — |

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

- **C1** : 7 unitaires + 2 fonctionnels = **9 cas** ✅ PASS [2026-04-02]
- **M1** : 6 unitaires + 3 fonctionnels = **9 cas** ✅ PASS [2026-04-02]
- **M2** : 2 unitaires + 3 fonctionnels = **5 cas** ✅ PASS [2026-04-02]
- **M3** : 2 unitaires + 3 fonctionnels = **5 cas** ✅ PASS [2026-04-02]
- **M4** : 1 unitaire  + 3 fonctionnels = **4 cas** ✅ PASS [2026-04-02]
- **M5** : 4 unitaires + 6 fonctionnels = **10 cas** ✅ PASS [2026-04-07]
- **M6** : 3 unitaires + 3 fonctionnels = **6 cas** ✅ PASS [2026-04-07]
- **M7** : 4 unitaires + 3 fonctionnels = **7 cas** ✅ PASS [2026-04-07]
- **R1** : 5 unitaires + 6 fonctionnels = **11 cas** ✅ PASS [2026-04-07]
- **R2** : 4 unitaires + 4 fonctionnels = **8 cas** ✅ PASS [2026-04-07]
- **R3** : 4 unitaires + 4 fonctionnels = **8 cas** ✅ PASS [2026-04-07]
- **R4** : 2 unitaires + 5 fonctionnels = **7 cas** ✅ PASS (F-90 18/18 + F-91 24/24 ✅ visual) [2026-04-14]
- **FOB beacon** : 2 fonctionnels = **2 cas** ✅ PASS (F-92 13/13 + F-93 visual ✅ — flow complet fobScene+beacon) [2026-04-14]
- **R5** : 0 unitaires + 12 fonctionnels = **12 cas** ✅ PASS (F-45→F-47 visual ✅, F-48→F-56 45/45 ✅) [2026-04-08]
- **FA** : 0 unitaires + 8 fonctionnels = **8 cas** ✅ PASS (F-57→F-64 33/33 ✅) [2026-04-08]
- **FB** : 0 unitaires + 7 fonctionnels = **7 cas** ✅ PASS (F-65→F-71 22/22 ✅) [2026-04-08]
- **FC** : 1 fonctionnel = **1 cas** ✅ PASS [2026-04-07]
- **ObjectRegistry** : 3 unitaires = **3 cas** ✅ PASS (U-54→U-56 43/43 ✅) [2026-04-08]
- **M8** : 10 unitaires + 8 fonctionnels = **18 cas** ✅ PASS (U-57→U-66 + F-72→F-77 97/97 ✅ + F-81→F-82 visual ✅) [2026-04-09]
- **M9** : 7 unitaires + 3 fonctionnels = **10 cas** ✅ PASS (U-67→U-73 + F-78→F-80 118/118 ✅) [2026-04-09]
- **M10** : 2 unitaires + 5 fonctionnels = **7 cas** ✅ PASS (U-74→U-75 12/12 ✅ + F-83→F-87 28/28 visual ✅) [2026-04-09]
- **FD** : 5 unitaires + 2 fonctionnels = **7 cas** ✅ PASS (U-76→U-80 + F-88→F-89 109/109 ✅) [2026-04-14]
- **Q1** : 3 unitaires + 7 fonctionnels = **10 cas** ✅ PASS (U-81→U-83 62/62 + F-94→F-100 100/100 ✅) [2026-04-15]
- **Config** : 6 unitaires + 2 fonctionnels = **8 cas** ✅ PASS (U-84→U-89 46/46 + F-101→F-102 11/11 ✅) [2026-04-16]
- **i18n** : 7 unitaires + 3 fonctionnels = **10 cas** ✅ PASS (U-90→U-96 43/43 + F-103→F-105 20/20 ✅) [2026-04-16]
- **Total** : **192 cas** — 914/914 PASS ✅

---

## Recettes restantes à générer

| Module | Fichier source | Priorité | Notes |
| --- | --- | --- | --- |
| ~~**CTLD_config.lua**~~ | ~~`src/CTLD_config.lua`~~ | ~~Basse~~ | ✅ Recette complète [2026-04-16] — U-84→U-89 + F-101→F-102 |
| ~~**CTLD_i18n.lua**~~ | ~~`src/CTLD_i18n.lua` + `CTLD_i18n_en.lua`~~ | ~~Basse~~ | ✅ Recette complète [2026-04-16] — U-90→U-96 + F-103→F-105 |
| ~~**CTLD_farpScene.lua**~~ | ~~`src/scenes/CTLD_farpScene.lua`~~ | ~~Moyenne~~ | ✅ Recette complète [2026-04-14] — F-91 22/22 PASS (bugfix stepsDatas→steps) |
| ~~**CTLD_fobScene.lua**~~ | ~~`src/scenes/CTLD_fobScene.lua`~~ | ~~Moyenne~~ | ✅ Recette complète [2026-04-14] — F-90 18/18 PASS |
| ~~**Feature D — LoadableGroups**~~ | ~~`src/CTLD_troop.lua`~~ | ~~Haute~~ | ✅ Recette complète [2026-04-14] — U-76→U-80 + F-88→F-89 |
| ~~**Q1 — Legacy API**~~ | ~~`src/compat/legacy_api.lua`~~ | ~~Haute~~ | ✅ Implémenté + recetté [2026-04-15] — 22 wrappers + packVehicle + spawnCrate, U-81→U-83 + F-94→F-99, 148/148 PASS |
