# CTLD — Manual Test Sequences

Centralized catalogue of manual DCS in-game test sequences.
Each sequence targets a specific feature perimeter and should be replayed whenever a change
touches that perimeter.

---

## How to use

1. Identify the modified perimeter (column **Perimeter / files**).
2. Run the listed sequence in a live DCS mission with CTLD + Witchcraft active.
3. Tick each step. Any ❌ = regression to fix before merge.

---

## MT-01 — Multi-group troop transport + disembark menu

**Perimeter / files:** `src/CTLD_troop.lua` — `refreshMenuSection`, `disembark`, `disembarkAll`,
`disembarkIndex`, `embarkFromTroopZone`, `embarkFromFieldByGroup`, `_findAllNearbyDropped`,
`_menuCheckCargo`, `_canEmbark`, `_currentTroopCount`

**Pre-requisites:**
- Mission with ≥ 2 TRZ pickup zones populated with troops (e.g. 2 x JTAC-type loadable groups)
- Player in UH-1H (or any transport with `troops: true`)
- `multiGroupTransport = true` in config (or set via Witchcraft `cfg.settings["multiGroupTransport"] = true`)

### Sequence

| # | Action | Verify |
|---|--------|--------|
| 1 | Land in TRZ. Open Troop Commands → Embark → Load [JTAC group 1]. | ✓ Screen message confirms load. ✓ Check Cargo shows exactly 1 group with name, troop count, weight. ✓ Disembark menu is a **direct command** (no submenu, since only 1 group). |
| 2 | Still in same TRZ. Open Troop Commands → Embark → Load [JTAC group 2]. | ✓ Screen message confirms load. ✓ Check Cargo shows 2 lines [1] and [2] + TOTAL line with summed count and weight. ✓ Disembark menu is now a **submenu** containing exactly 3 entries: "Disembark All", "[1] \<group1 name\>", "[2] \<group2 name\>". |
| 3 | Take off. Open Troop Commands in flight. | ✓ "Disembark Troops" submenu is gone (ground-only). ✓ "Parachute Troops" submenu appears with: "Parachute All" + "[1] \<name\>" + "[2] \<name\>" — exactly 3 entries. |
| 4 | Land. Open Troop Commands → Disembark Troops → choose [1]. | ✓ Group 1 spawns on the ground, not colliding with helicopter. ✓ Screen message names the deployed group. ✓ Check Cargo shows only 1 remaining group (the one NOT chosen). |
| 5 | Still 1 group onboard. A previously deployed JTAC group is within ~125 m. Open Troop Commands → Embark / Extract Troops. | ✓ Section is **visible and enabled** despite troops still onboard. ✓ "Extract from field" shows the nearby group name (direct command if 1 group, submenu if multiple). |
| 6 | Choose remaining group → Disembark. | ✓ Group spawns at different position from step 4 spawn — **not on top of previous group**. ✓ Minimum ~10 m from helicopter. ✓ Check Cargo shows "No troops onboard." |
| 7 | Both groups now dropped nearby. Open Troop Commands → Embark / Extract Troops. | ✓ "Extract from field" is a **submenu** with exactly 2 entries. ✓ Each entry shows group name AND distance in metres (e.g. "Dropped Alpha (45m)"). |
| 8 | Extract one group from the submenu. | ✓ That group embarks. ✓ Check Cargo shows 1 group. ✓ Remaining dropped group still visible on map. |
| 9 | Embark a second group (from TRZ or remaining dropped). Use Disembark All. | ✓ Both groups spawn at **separate positions** — visually distinct, no unit stacking. ✓ Both positions at least ~10 m from helicopter. |
| 10 | Embark 2 groups again. Disembark [2] then [1] separately (back-to-back). | ✓ [2] spawns first, [1] spawns after in a different position — **no overlap between the two spawns**. ✓ Correct group names in confirmation messages match the chosen index. |

### Pass criteria
- Step 4: exactly 3 entries in disembark submenu (All + [1] + [2])
- Step 6: extract menu visible even with 1 group already onboard (capacity > current count)
- Steps 9/10: groups not stacked on the same coordinates

---

## MT-02 — (placeholder for next manual sequence)

*To be filled in when a new manual test sequence is validated.*

---

## Changelog

| Date | Sequence | Notes |
|------|----------|-------|
| 2026-05-12 | MT-01 | First validation — all 10 steps PASS after fixes: extract guard, spawn offset |
