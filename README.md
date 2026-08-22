# legendscave

FiveM resources for the Legends Cave server.

## waterdispenser

Auto-detecting emergency water dispenser resource with:

- **ox_target** interaction on dispenser props
- **ox_lib** callbacks and notifications
- **Qbox** (qbx_core) or **ESX** thirst support — auto-detected
- **NUI** vertical cup-fill animation with progress bar
- Random player remarks after drinking
- Hourly cooldown (2 cups per hour per player)
- Cup prop in hand, pour + sip sounds, and drinking animation
- **config.lua** for framework, refill %, sounds, animations, remarks, and scan keywords

### Dependencies (required)

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

### Framework (one required)

**Qbox (recommended for your setup):**
- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [17mov_Hud](https://17movement.net/products/advanced-hud) (or HUD that listens to `hud:client:UpdateNeeds`)

**ESX (alternative):**
- [es_extended](https://github.com/esx-framework/esx_core)
- [esx_status](https://github.com/esx-framework/esx_status)

The script auto-detects `qbx_core` → `qb-core` → `es_extended`. Override with `Config.Framework = 'qbox'` or `'esx'` in `config.lua`.

### Install

1. Copy `waterdispenser` into your server's `resources` folder.
2. Ensure dependencies start first in `server.cfg`:
   ```
   ensure ox_lib
   ensure ox_target
   ensure qbx_core
   ensure waterdispenser
   ```
3. Edit `waterdispenser/config.lua` as needed.

### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `Config.Framework` | `auto` | `auto`, `qbox`, or `esx` |
| `Config.Hud` | `17mov_Hud` | `17mov_Hud`, `auto`, or `default` |
| `Config.HudResource` | `17mov_Hud` | Resource name for 17mov HUD exports |
| `Config.ThirstRefill` | `10` | Emergency thirst restored (percent) |
| `Config.MaxDrinksPerHour` | `2` | Max drinks per player per hour |
| `Config.CooldownWindow` | `3600` | Cooldown window in seconds |
| `Config.FillDuration` | `7000` | NUI vertical cup-fill animation (ms, 5–10s) |
| `Config.Remarks` | 5 lines | Random post-drink player remarks |
| `Config.ScanKeywords` | watercooler, dispenser, hydrant | Archetype name keywords for auto-scan |
| `Config.KnownModels` | prop_watercooler variants | Models registered without scanning |

Dispenser props are registered from `Config.KnownModels` immediately, then the client periodically scans loaded world objects whose archetype name matches any keyword in `Config.ScanKeywords`.
