# legendscave

FiveM resources for the Legends Cave server.

## waterdispenser

Auto-detecting water dispenser resource with:

- **ox_target** interaction on dispenser props
- **ESX** payment and **esx_status** thirst refill
- Cup prop in hand, pour + sip sounds, and drinking animation
- **config.lua** for price, refill %, sounds, animations, and scan keywords

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
| `Config.WaterPrice` | `10` | Cost per drink |
| `Config.ThirstRefill` | `30` | Thirst restored (percent) |
| `Config.ScanKeywords` | watercooler, dispenser, hydrant | Archetype name keywords for auto-scan |
| `Config.KnownModels` | prop_watercooler variants | Models registered without scanning |

Dispenser props are registered from `Config.KnownModels` immediately, then the client periodically scans loaded world objects whose archetype name matches any keyword in `Config.ScanKeywords`.
