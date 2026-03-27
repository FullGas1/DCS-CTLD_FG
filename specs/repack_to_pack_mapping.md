# pack → pack mapping

All occurrences of `pack` (any case) found in `source/` and `old/`.
This table is the reference to apply when writing `source_futur/` files.
**Never modify `source/` or `old/`.**

---

## 1. Config parameters (`CTLD_config.lua`)

| Old name (source/) | New name (source_futur/) | Class | Notes |
|---|---|---|---|
| `enablePackingVehicles` | `enablePackingVehicles` | CTLDConfig | Boolean setting |
| `maximumDistancePackableUnitsSearch` | `maximumDistancePackableUnitsSearch` | CTLDConfig | Distance in meters |

---

## 2. Global state (`ctld.*`)

| Old name (source/) | New name (source_futur/) | Class | Notes |
|---|---|---|---|
| `ctld.packRequestsStack` | `CTLDVehicleManager._packRequestsStack` | CTLDVehicleManager | Moved to manager as private attribute |

---

## 3. Functions

| Old name (source/ or old/) | New name (source_futur/) | Class | Notes |
|---|---|---|---|
| `ctld.isPackableUnit()` | `CTLDVehicleManager:isPackableUnit()` | CTLDVehicleManager | Returns packable unit descriptor or nil |
| `ctld.getUnitsInPackRadius()` | `CTLDVehicleManager:getUnitsInPackRadius()` | CTLDVehicleManager | Scans nearby units |
| `ctld.packVehicleRequest()` | `CTLDVehicleManager:packVehicleRequest()` | CTLDVehicleManager | Pushes to _packRequestsStack |
| `ctld.packVehicle()` | `CTLDVehicleManager:packVehicle()` | CTLDVehicleManager | Processes _packRequestsStack |
| `ctld.updatePackMenu()` | `CTLDVehicleManager:buildPackMenu()` | CTLDVehicleManager | Follows buildMenu(player, parentMenu) pattern |
| `ctld.updatePackMenuOnlanding()` | `CTLDVehicleManager:updatePackMenuOnLanding()` | CTLDVehicleManager | Called by DCS land event handler in CTLDCore |
| `ctld.autoUpdatePackMenu()` | `CTLDVehicleManager:autoUpdatePackMenu()` | CTLDVehicleManager | Scheduled via timer, scans all transport units |

---

## 4. Local variables / intermediate names

| Old name (source/ or old/) | New name (source_futur/) | Context |
|---|---|---|
| `packableUnits` | `packableUnits` | Result table of getUnitsInPackRadius() |
| `packableUnit` | `packableUnit` | Single unit descriptor |
| `packableUnitName` | `packableUnitName` | Unit name string |
| `packableUnit["packableUnitGroupID"]` | `packableUnit.groupId` | Field in CtldVehicle or descriptor table |
| `packableUnit["packableUnitName"]` | `packableUnit.unitName` | Field in CtldVehicle or descriptor table |
| `PackPreviousMenu` | `packPreviousMenu` | Menu builder local |
| `PackCommandsPath` | `packCommandsPath` | Menu builder local |
| `PackMenuPath` | `packMenuPath` | Menu builder local |
| `packSubMenuText` | `packSubMenuText` | Menu builder local |
| `packableVehicles` | `packableVehicles` | Menu builder local |

---

## 5. i18n keys (`CTLD_i18n.lua`)

| Old key (source/) | New key (source_futur/) | Notes |
|---|---|---|
| `"Pack Vehicles"` | `"Pack Vehicles"` | Submenu title — all languages |
| `"pack "` | `"pack "` | Prefix for per-vehicle menu entries (e.g. "pack Humvee") |

### Translations to update

| Language | Old value | New value |
|---|---|---|
| `en` | `""` (empty — uses key) | `""` (unchanged) |
| `fr` | `"Ré-emballer véhicules"` | `"Emballer véhicules"` |
| `es` | `"Reenvolver vehículos"` | `"Envolver vehículos"` |

> **Version bump required:** when writing `source_futur/CTLD_i18n.lua`:
> - The key `"Pack Vehicles"` is a new entry → bump `en.translation_version` (currently `"1.6"` → `"1.7"`).
> - `i18n_check()` enforces that ALL languages match `en.translation_version` → bump `fr`, `es`, and `ko` to `"1.7"` as well.
> - `ko` does not have a translation for `"Pack Vehicles"` yet → add an empty string `""` as placeholder (same convention as `en` for missing entries).

---

## 6. Section comments (informational — no impact on code)

| Location | Old comment | New comment |
|---|---|---|
| `CTLD_core.lua:760` | `-- Pack vehicules crates functions` | `-- Pack vehicles crates functions` |

---

## Usage rules

- Apply this mapping mechanically when writing each `source_futur/` file.
- Never use any `pack*` symbol in `source_futur/` — grep before committing.
- For FR/ES i18n translations marked **à définir**, ask the user before writing.
