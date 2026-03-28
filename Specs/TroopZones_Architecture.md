# TroopZones Architecture Specification

**Status**: Validated
**Date**: 2026-03-28
**Version**: 1.0

## Overview

Unified TroopZone architecture replacing separate PickupZones and ExtractZones systems with a single, flexible zone type supporting both troop pickup/dropoff and mission objectives.

## Naming Convention

```
TRZ_zoneName_[R|B|N]_[maxStock]_[flag]_[target]
```

### Components

| Position | Field | Type | Required | Description |
|----------|-------|------|----------|-------------|
| 1 | `TRZ_` | Prefix | ✅ Yes | Zone type identifier |
| 2 | `zoneName` | Alphanumeric | ✅ Yes | Zone identifier (no underscores, use CamelCase or hyphens) |
| 3 | `R\|B\|N` | Coalition | ❌ Optional | **R**=RED, **B**=BLUE, **N**=NEUTRAL |
| 4 | `maxStock` | Number | ❌ Optional | Troop pickup stock (0=infinite) |
| 5 | `flag` | String | ❌ Optional | DCS flag name for mission objective |
| 6 | `target` | Number | ❌ Optional | Soldiers required for objective completion |

### Parsing Rules

- **Strict order**: Coalition → maxStock → flag → target
- **Type detection**: Number before flag = maxStock, number after flag = target
- **Coalition abbreviation**: Single letter (R/B/N) expanded to full coalition constant

## Examples

| Zone Name | Zone Type | Stock | Objective | Target | Description |
|-----------|-----------|-------|-----------|--------|-------------|
| `TRZ_Base_B_50` | Pickup | 50 | - | - | BLUE pickup zone with 50 troops |
| `TRZ_Airfield_N_0` | Pickup | ∞ | - | - | NEUTRAL infinite pickup |
| `TRZ_Exfil_B_objRescue_100` | Extract | - | objRescue | 100 | BLUE extract zone, 100 soldiers for win |
| `TRZ_FOB_B_30_objSecure_50` | Mixed | 30 | objSecure | 50 | BLUE pickup (30) + objective (50) |
| `TRZ_Combat_R` | None | - | - | - | RED zone (no functionality) |

## Use Cases

### 1. Pickup Zone (Standard Stock)
```
TRZ_MainBase_B_100
```
- Coalition: BLUE
- Stock: 100 troops
- Behavior: Load decrements stock, unload RTB restores stock + shows message

### 2. Pickup Zone (Infinite Stock)
```
TRZ_Airfield_N_0
```
- Coalition: NEUTRAL
- Stock: Infinite (0)
- Behavior: Unlimited loading

### 3. Extract Zone (Mission Objective)
```
TRZ_ExfilAlpha_B_objRescue_100
```
- Coalition: BLUE
- Objective: flag "objRescue", target 100 soldiers
- Behavior: Deploy increments flag by soldier count
- Win condition: Mission Maker sets DCS trigger "if flag >= 100 → victory"

### 4. Mixed Zone (Pickup + Objective)
```
TRZ_FOBCharlie_B_30_objSecure_50
```
- Coalition: BLUE
- Stock: 30 troops (pickup)
- Objective: flag "objSecure", target 50 soldiers
- Behavior: Supports both load (stock) and deploy (objective)

### 5. Combat Deploy (No Zone)
```
(no zone)
```
- Behavior: Deploy troops anywhere on map, no flag increment, no message

## Flag Incrementation

### Current Behavior (Verified)

**Source**: `source/CTLD_core.lua:1648-1652`

```lua
local _droppedCount = trigger.misc.getUserFlag(_extractZone.flag)
_droppedCount = (#_onboard.troops.units) + _droppedCount  -- Count SOLDIERS
trigger.action.setUserFlag(_extractZone.flag, _droppedCount)
```

**Mode**: **+N per soldiers** (not per group, not per operation)

### Implementation

```lua
function CTLDTroopZone:incrementObjective(soldierCount)
    if not self.objectiveFlag then
        return false
    end

    local currentValue = trigger.misc.getUserFlag(self.objectiveFlag)
    local newValue = currentValue + soldierCount  -- +N soldiers

    trigger.action.setUserFlag(self.objectiveFlag, newValue)

    -- Log progress if target defined
    if self.objectiveTarget then
        local progress = string.format(" (%d/%d)", newValue, self.objectiveTarget)

        if newValue >= self.objectiveTarget then
            ctld.utils.log("info", string.format(
                "OBJECTIVE COMPLETE: Flag '%s' reached target %d",
                self.objectiveFlag, self.objectiveTarget
            ))
        end
    end

    return true, currentValue, newValue
end
```

## Data Structure

### CTLDTroopZone Class

```lua
CTLDTroopZone = {
    -- Identification
    fullName = "TRZ_FOB_B_30_objSecure_50",
    zoneName = "FOB",

    -- Coalition
    coalition = coalition.side.BLUE,  -- 0=NEUTRAL, 1=RED, 2=BLUE

    -- Stock management (pickup)
    troopStockMax = 30,         -- nil = no pickup
    troopStockCurrent = 30,     -- Decrements on load, 0 = infinite

    -- Mission objective (extract)
    objectiveFlag = "objSecure",      -- nil = no objective
    objectiveTarget = 50,             -- nil = no defined target

    -- Trigger zone data
    triggerZone = DCS_TriggerZone,
    position = {x, y, z},
    radius = 500,

    -- Visuals
    smoke = true,
    smokeColor = trigger.smokeColor.Blue,

    -- State
    active = true
}
```

### Methods

```lua
-- Check if zone allows troop loading
function CTLDTroopZone:canLoadTroops()
    return self.troopStockMax == 0 or
           (self.troopStockCurrent and self.troopStockCurrent > 0)
end

-- Check if zone has mission objective
function CTLDTroopZone:hasObjective()
    return self.objectiveFlag ~= nil
end

-- Check if zone is RTB destination
function CTLDTroopZone:isRTBDestination()
    return self.troopStockMax ~= nil
end

-- Decrement stock on load
function CTLDTroopZone:decrementStock(count)
    if self.troopStockMax == 0 then return end  -- Infinite
    if not self.troopStockCurrent then return end

    self.troopStockCurrent = math.max(0, self.troopStockCurrent - count)
end

-- Increment objective flag
function CTLDTroopZone:incrementObjective(soldierCount)
    -- See implementation above
end
```

## Mission Initialization

### Automatic Zone Detection

```lua
function CTLDZoneManager:scanMissionTroopZones()
    local detectedZones = {}

    for _, triggerZone in pairs(env.mission.triggers.zones) do
        local zoneName = triggerZone.name

        if string.sub(zoneName, 1, 4) == "TRZ_" then
            local parsed, error = self:parseTroopZoneName(zoneName)

            if parsed then
                local troopZone = CTLDTroopZone:new({
                    fullName = parsed.fullName,
                    zoneName = parsed.zoneName,
                    coalition = parsed.coalition,

                    troopStockMax = parsed.maxStock,
                    troopStockCurrent = parsed.maxStock,

                    objectiveFlag = parsed.objectiveFlag,
                    objectiveTarget = parsed.objectiveTarget,

                    triggerZone = triggerZone,
                    position = {x = triggerZone.x, y = triggerZone.y, z = triggerZone.z},
                    radius = triggerZone.radius,

                    smoke = true,
                    smokeColor = trigger.smokeColor.Green,
                    active = true
                })

                -- Initialize DCS flag if objective
                if troopZone.objectiveFlag then
                    trigger.action.setUserFlag(troopZone.objectiveFlag, 0)
                end

                table.insert(detectedZones, troopZone)
            end
        end
    end

    return detectedZones
end
```

## Events

### OnTroopsDeployed

```lua
EventDispatcher:publish("OnTroopsDeployed", {
    troops = {
        groupTemplate = "Standard Group",
        soldierCount = 12,
        units = {...},
        spawnedGroup = Group#001
    },
    transport = Unit#123,
    player = "PlayerName",
    method = "menu_ctld" | "parachute" | "fast_rope",

    destination = {
        type = "troop_zone_rtb"        -- Unload in stock zone (RTB)
             | "troop_zone_objective"   -- Deploy in objective zone
             | "combat",                -- Deploy outside zone

        troopZone = CTLDTroopZone#001 or nil,

        -- Objective info (if type = troop_zone_objective)
        objectiveFlagIncremented = true,
        objectiveFlagName = "objRescue",
        objectiveFlagValueBefore = 38,
        objectiveFlagValueAfter = 50,      -- 38 + 12 soldiers
        objectiveTarget = 100,             -- Target for win
        objectiveProgress = "50/100"       -- Human-readable progress
    },

    position = {x, y, z},
    timestamp = timer.getTime()
})
```

## Mission Maker Workflow

### Creating Extract Zone with Objective

1. **Create DCS trigger zone**: `TRZ_ExfilBravo_B_objRescue_50`

2. **Flag auto-initialization**: CTLD initializes flag `objRescue` to 0 at mission start

3. **Automatic incrementation**: Each soldier extracted → flag +1

4. **Victory trigger** (DCS Mission Editor):
   ```
   CONDITION: Flag "objRescue" >= 50
   ACTION: End Mission BLUE Victory
   MESSAGE: "50 soldiers rescued successfully!"
   ```

### Responsibility Separation

- **CTLD**: Increments flag based on soldiers extracted
- **Mission Maker**: Defines victory condition via DCS triggers

## Migration from Legacy System

### Legacy Conventions

- `PKZ_Name_Max` → Pickup zones
- `createExtractZone("name", flagNumber, smoke)` → Extract zones

### New Convention

- `TRZ_Name_R_Max` → Pickup zone RED
- `TRZ_Name_B_flagName_Target` → Extract zone BLUE

**No automatic conversion**: Mission Maker must manually rename zones.

## Validation

- ✅ Convention `TRZ_zoneName_[R|B|N]_[maxStock]_[flag]_[target]`
- ✅ Coalition abbreviation (R/B/N)
- ✅ Strict order: number before flag = stock, number after = target
- ✅ Flag incrementation: +N soldiers (verified in existing code)
- ✅ Target in zone name (auto-documentation, DCS triggers for win)
- ✅ Unified structure replaces PickupZone + ExtractZone
- ✅ Automatic parsing of trigger zones at startup
- ✅ Event OnTroopsDeployed with unified destination

## References

- Memory: `project_troops_zones_architecture.md`
- Analysis: `project_troops_system_analysis.md`
- Events: `CTLD_Events.md`
