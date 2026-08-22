# legendscave

FiveM resources for the Legends Cave server.

## waterdispenser

Auto-detecting emergency water dispenser resource with:

- **ox_target** interaction on dispenser props
- **NUI** cup-fill animation while water pours
- **ESX** free thirst relief via **esx_status** (+10% by default)
- Random player remarks after drinking
- Hourly cooldown (2 cups per hour per player)
- Cup prop in hand, pour + sip sounds, and drinking animation
- **config.lua** for refill %, sounds, animations, remarks, and scan keywords

### Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [es_extended](https://github.com/esx-framework/esx_core)
- [esx_status](https://github.com/esx-framework/esx_status)

### Install

1. Copy `waterdispenser` into your server's `resources` folder.
2. Add `ensure waterdispenser` to `server.cfg` (after dependencies).
3. Edit `waterdispenser/config.lua` to tweak price, thirst refill, sounds, or scan keywords.

### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `Config.ThirstRefill` | `10` | Emergency thirst restored (percent) |
| `Config.MaxDrinksPerHour` | `2` | Max drinks per player per hour |
| `Config.CooldownWindow` | `3600` | Cooldown window in seconds |
| `Config.FillDuration` | `7000` | NUI vertical cup-fill animation (ms, 5–10s) |
| `Config.Remarks` | 5 lines | Random post-drink player remarks |
| `Config.ScanKeywords` | watercooler, dispenser, hydrant | Archetype name keywords for auto-scan |
| `Config.KnownModels` | prop_watercooler variants | Models registered without scanning |

Dispenser props are registered from `Config.KnownModels` immediately, then the client periodically scans loaded world objects whose archetype name matches any keyword in `Config.ScanKeywords`.
