# Project State — DCS-CTLD_FG
Generated: 2026-05-03 23:51:15+02:00

## Session Summary

### Work done this session
- Created `recette/scenarios/tfc_full.lua` — FullTroop 8-step scenario (template "JTAC Group 2", 6 units, 1 group)
- Identified and fixed 3 bugs in `src/CTLD_troop.lua`:
  1. `_syncFromDCSGroup`: ne réécrit plus `_jtacUnits = {}` — préserve les entrées et met à jour la valeur avec groupName
  2. `wasJtac`: check changé de `== true` à `~= nil` pour supporter la valeur groupName
  3. `onUnitDead`: passe `groupName` (depuis `_jtacUnits[unitName]`) à `deregisterJTAC` au lieu de `unitName`
- Rebuilt `CTLD_Next.lua` (`node merger_build.js` — 28 files merged, 0 warnings)
- Discovered: `CTLDJTACManager` uses `get()` (not `getInstance()`) — the only manager with `get()` instead of `getInstance()`

### Current blocker
**`step3_incomplete`** — `spawnJTAC` call returns nil or JTAC not registered in manager.
Root cause still under investigation:
- `Group.getByName` works correctly in isolation
- `_syncFromDCSGroup` should update `_jtacUnits[unitName] = gname` for JTAC units
- Problem likely: unit names mismatch between template-generated names (`"JTAC Group 2_u5"`) and DCS-generated names (may differ if DCS auto-generates)

### Next action required
Re-run `tfc_full.lua` and capture DCS screen messages to see:
1. `[TFC] addGroup OK: gname='...'` — confirms group spawned
2. `DCS unit[1]='...'` — actual unit names from DCS
3. `_jtacUnits before sync: [...]` — what's in _jtacUnits after Step 2
4. `_sync: alive=X jtac=Y` — result after `_syncFromDCSGroup`
5. `spawnJTAC result=true/false`

### Files modified this session
- `src/CTLD_troop.lua` — 3 patches (lines ~92, ~1020, ~1025)
- `CTLD_Next.lua` — rebuilt from source
- `recette/scenarios/tfc_full.lua` — new scenario
- `recette/scenarios/tfc_jtac_test.lua` — isolated spawnJTAC test (works)
- `recette/patch_onUnitDead.lua` — not loaded (removed from tfc_full.lua)

### Important protocol note
After any modification to `src/*.lua`, MUST run `node merger_build.js` to rebuild `CTLD_Next.lua` before testing in DCS.

## TFC Scenario State

| Step | Description | Status |
|------|-------------|--------|
| 1 | Find/create template "JTAC Group 2" | PASS |
| 2 | TRZ_LOADED group | PASS |
| 3 | Spawn 1 group (6 units), spawnJTAC | FAIL — step3_incomplete |
| 4 | S_EVENT_DEAD on JTAC unit → onUnitDead | Not reached |
| 5 | embarkFromField: deregisterJTAC then destroy | Not reached |
| 6 | Disembark after field: respawn + resumeJTAC | Not reached |
| 7 | returnToTroopZone: deregisterJTAC | Not reached |
| 8 | Final report + cleanup | Not reached |

## Recipes TODO
- FullTroop scenario (tfc_full.lua) — Steps 3-8 not executed yet
- `recette/recette.md` — need to update with F-xx for FullTroop once passed
- `.github/MODERNIZATION-PLAN.md` — need to update when scenario passes