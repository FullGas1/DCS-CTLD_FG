# CTLD_FG — Project State

**Last updated:** 2026-05-02 03:11

---

## Arrêtsession — contexte à reprendre demain

---

## Branche active
`kilo/feat/troop-lifecycle-rename-v3`

---

## Contexte : refonte cycle de vie troupes + multi-JTAC

### Objectif
Refonte complète du cycle de vie des troupes dans `CTLD_troop.lua` :
- Terminologie (embarkFromTroopZone / disembark / embarkFromField / returnToTroopZone / dispatchToEXZ)
- États : TRZ_LOADED / DEPLOYED / FIELD_LOADED / DEPLOYED_EXZ / RETURNED_TO_TRZ
- `_aliveUnits[unitName] = dcsUnit` et `_jtacUnits[unitName] = true`
- Multi-JTAC N× : `startLase()` par unité JTAC
- `deregisterJTAC()` sur TOUS les chemins de sortie
- `onUnitDead` via `S_EVENT_DEAD` → sync `_aliveUnits`/`_jtacUnits`

---

## Terminé ✅

| # | Fonctionnalité | Fichier | Ligne |
|---|----------------|---------|-------|
| ✅ | States TRZ_LOADED / DEPLOYED / FIELD_LOADED / DEPLOYED_EXZ / RETURNED_TO_TRZ | `src/CTLD_troop.lua` | 25-31 |
| ✅ | `_aliveUnits` / `_jtacUnits` dans `CTLDTroopGroup:init()` | `src/CTLD_troop.lua` | 54-55 |
| ✅ | `_initFromTemplate()` / `_syncFromDCSGroup()` / `_removeDeadUnit()` | `src/CTLD_troop.lua` | 92-122 |
| ✅ | `hasAliveJtac()` / `getJtacCount()` / `getAliveCount()` | `src/CTLD_troop.lua` | 78-87 |
| ✅ | `disembark()` + `setTRZLoaded()` + alias `deploy = disembark` | `src/CTLD_troop.lua` | 126-143 |
| ✅ | Rename loadFromZone→embarkFromTroopZone, deploy→disembark, extract→embarkFromField, returnToBase→returnToTroopZone | `src/CTLD_troop.lua` | — |
| ✅ | `embarkFromTroopZone` : build `_aliveUnits`/`_jtacUnits` depuis template | `src/CTLD_troop.lua` | 574-588 |
| ✅ | `embarkFromField` : sync + `deregisterJTAC` × N **AVANT** `group:destroy()` | `src/CTLD_troop.lua` | 820-825 |
| ✅ | `disembark` : `group:hasAliveJtac()` + `startLase()` par unité JTAC × N | `src/CTLD_troop.lua` | 679-686 |
| ✅ | `returnToTroopZone` : `deregisterJTAC` × N avant `_inTransit = nil` | `src/CTLD_troop.lua` | 753-756 |
| ✅ | `CTLDTroopManager:onUnitDead(unitName)` + `_findGroupByAliveUnit()` | `src/CTLD_troop.lua` | 796-847 |
| ✅ | Bridge `S_EVENT_DEAD` → `onUnitDead()` dans `CTLDCoreManager:init()` | `src/CTLD_core.lua` | 337-342 |
| ✅ | `cleanupDeadTransports` : orphan JTAC cleanup | `src/CTLD_troop.lua` | 860-871 |
| ✅ | `preLoadTransport` : `_aliveUnits`/`_jtacUnits` (suppression hasJtac) | `src/CTLD_troop.lua` | 1593-1618 |
| ✅ | `ctld.utils.log` : ouvre CTLD.log automatiquement si `ctld.debug = true` | `src/CTLD_utils.lua` | 1829+ |
| ✅ | `reopenLogAppend` : trigger aussi sur `ctld.debug == true` (runtime) | `src/CTLD_utils.lua` | 1844 |
| ✅ | Documentation `docs/missionmaker_guide.md` §5 (terminologie + SVG) | — | — |
| ✅ | Documentation `docs/dev-guide.md` §2 + §9 (lifecycle) | — | — |
| ✅ | SVG `docs/assets/troops_jtac_lifecycle.svg` | — | — |
| ✅ | MODERNIZATION-PLAN.md synchronisé | — | — |

---

## BLOQUÉ — À corriger avant reprise

### Bug critique : CTLD_Next.lua ne s'injecte plus

**Erreur :**
```
[string "witchcraft-exec"]:18071: attempt to call method 'isActive' (a nil value)
```

**Cause :** `_initMMJTACs()` appelle `group:isActive()` mais certains groupes retournés par `coalition.getGroups()` n'ont pas cette méthode (groupes late-activation ou已经在活跃).

**Fix à appliquer dans `src/CTLD_core.lua` ligne ~395 :**
```lua
-- AVANT (bug):
if group:isActive() then

-- APRÈS (fix):
if type(group.isActive) == "function" and group:isActive() then
```

**Fichier à modifier :** `src/CTLD_core.lua` ligne 395

---

## Reste à faire (après fix)

| # | Tâche | Blocking |
|---|-------|----------|
| ❌ | Fix `isActive()` dans `_initMMJTACs` → rebuild CTLD_Next.lua | 🔴 Bug bloquant |
| ❌ | Rebuild `CTLD_Next.lua` | 🔴 |
| ❌ | Tester injection + écrire dans `recette/CTLD.log` avec `ctld.debug = true` | 🔴 |
| ❌ | Recette `scenarioTroopsFullCycle.lua` (8 steps) via Witchcraft | 🔴 |
| ❌ | Vérifier que `preLoadTransport` / legacy_api.lua n'ont plus de `hasJtac` | 🟡 |
| ❌ | Vérifier call sites `deploy()` dans `legacy_api.lua` → `disembark()` | 🟡 |

---

## Scripts de test existants

| Fichier | Rôle | État |
|---------|------|------|
| `recette/scenarios/scenarioTroopsFullCycle.lua` | Recette 8 steps full lifecycle | ⬜ Pending (bloqué par bug isActive) |
| `recette/scenarios/scenario_troops_minimal.lua` | Mini-test 4 steps (managers + TRZ_LOADED) | ⬜ Pending |
| `recette/diag_ctld_loaded.lua` | Vérifie chargement CTLD | ✅ Fonctionne |
| `recette/diag_pcall2.lua` | Vérifie getInstance | ✅ Fonctionne |

---

## Commandes pour reprise

### Fix + Rebuild
```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Moi\Documents\GitHub\DCS-CTLD_FG\tools\merger_V2\merge_CTLD.ps1"
```

### Injecter CTLD (DCS mission doit être ouverte)
```powershell
node "C:\Users\Moi\.vscode-dcs-tools\bridge.js" "C:\Users\Moi\Documents\GitHub\DCS-CTLD_FG\CTLD_Next.lua"
```

### Test log (après injection)
```powershell
node "C:\Users\Moi\.vscode-dcs-tools\bridge.js" "C:\Users\Moi\Documents\GitHub\DCS-CTLD_FG\recette\scenarios\scenario_troops_minimal.lua"
```

### Filter CTLD.log
```powershell
findstr /C:"[scenario_troops_minimal]" "C:\Users\Moi\Documents\GitHub\DCS-CTLD_FG\recette\CTLD.log"
```

### Reset step counter
```lua
_G["_TFC_STEP"] = 1
_G["_TFC_MINI_STEP"] = 1
```

---

## Fichiers critiques pour reprise

| Fichier | Rôle |
|---------|------|
| `src/CTLD_core.lua` | **Fix ligne 395** : guard `isActive()` avant rebuild |
| `CTLD_Next.lua` | Rebuild artifact après fix |
| `src/CTLD_troop.lua` | Source de vérité lifecycle troupes |
| `recette/scenarios/scenario_troops_minimal.lua` | Premier test post-fix |
| `.kilo/witchcraft-debug.md` | Méthode debug Witchcraft |
| `MODERNIZATION-PLAN.md` | Avancement MP synchronisé |

---

## Notes Witchcraft

- `[SUCCESS] nil` = injection réussie sans erreur Lua
- Traces : `trigger.action.outText` (DCS screen) + `ctld.utils.log` (CTLD.log si `ctld.debug=true`)
- `ctld.utils.log` écrit dans `recette/CTLD.log` automatiquement si `ctld.debug = true` (fix appliqué)
- Persistance : `_G["_VAR"]` persiste entre injections Witchcraft

---

## Warning

Le bug `isActive` doit être corrigé AVANT tout rebuild — sinon CTLD ne peut pas s'injecter dans la mission.