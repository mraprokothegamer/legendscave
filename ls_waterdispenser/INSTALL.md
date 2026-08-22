# waterdispenser

Production-ready emergency water dispenser resource for **Qbox** servers using **ox_lib**, **ox_target**, and **17mov_Hud**.

Players can use any Rockstar water cooler prop in the city to get free emergency hydration (+10% thirst), with a cooldown of 2 cups per hour.

---

## Features

- Auto-detects water dispenser props (known models + keyword scan)
- ox_target interaction — no manual prop setup per location
- Centered vertical NUI with cup fill animation and progress bar (~7 seconds)
- Cup prop, pour/sip sounds, and drinking animation
- Free emergency water (+10% thirst)
- Server-side cooldown and session locking (anti-spam / anti-exploit)
- Qbox + 17mov_Hud thirst sync
- ESX fallback support

---

## Requirements

| Resource | Required | Notes |
|----------|----------|-------|
| ox_lib | Yes | Callbacks and notifications |
| ox_target | Yes | Dispenser interaction |
| qbx_core | Yes (Qbox) | Player metadata / thirst |
| 17mov_Hud | Recommended | HUD thirst bar sync |

---

## Installation

### 1. Copy the resource

Place the `waterdispenser` folder in your server resources directory:

```
resources/[standalone]/waterdispenser
```

### 2. Add to server.cfg

**Load order matters.** Add this after your core and ox resources:

```cfg
# Dependencies
ensure ox_lib
ensure ox_target
ensure qbx_core
ensure 17mov_Hud

# Resource
ensure waterdispenser
```

### 3. Configure (optional)

Edit `config.lua` if you want to change:

- Thirst refill amount (`Config.ThirstRefill`)
- Cooldown limits (`Config.MaxDrinksPerHour`)
- Fill animation duration (`Config.FillDuration`)
- Player remarks (`Config.Remarks`)
- Dispenser scan keywords (`Config.ScanKeywords`)

Default setup is ready for Qbox + 17mov_Hud without changes.

### 4. Restart and verify

1. Restart the server or run `ensure waterdispenser`
2. Check console for: `[waterdispenser] Production build loaded successfully.`
3. In-game, find a water cooler and use **ox_target** (default: left Alt) → **Drink Water**

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| No target option on cooler | Wait ~5s after join (initial scan). Add model to `Config.KnownModels`. |
| Thirst bar not updating | Ensure `17mov_Hud` starts before `waterdispenser`. Check `Config.HudResource` matches folder name. |
| "Dispenser system unavailable" | Ensure `qbx_core` is running. Set `Config.Framework = 'qbox'`. |
| Cooldown not working | Cooldown is server-side per citizenid. Restart clears in-memory data. |

Enable debug logs:

```lua
Config.Debug = true
```

---

## Configuration reference

| Option | Default | Description |
|--------|---------|-------------|
| `Config.Framework` | `auto` | `auto`, `qbox`, or `esx` |
| `Config.Hud` | `17mov_Hud` | HUD integration mode |
| `Config.HudResource` | `17mov_Hud` | HUD resource folder name |
| `Config.ThirstRefill` | `10` | Thirst restored per drink (%) |
| `Config.MaxDrinksPerHour` | `2` | Max drinks per hour |
| `Config.CooldownWindow` | `3600` | Cooldown window (seconds) |
| `Config.FillDuration` | `7000` | NUI fill time (ms) |
| `Config.TargetLabel` | `Drink Water` | ox_target label |
| `Config.ScanKeywords` | watercooler, dispenser, hydrant | Prop scan keywords |

---

## Support

Built for **Legends Cave** — Qbox + ox stack + 17mov_Hud.
