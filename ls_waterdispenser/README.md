# ls_waterdispenser

Emergency water for **Qbox** using the **ox** stack. Target any water cooler /
dispenser prop in the world and drink to restore thirst, with a held cup,
drinking animation, sound, and a custom "water pouring into a cup" NUI.

## Features

- `ox_target` interaction on every configured water cooler / dispenser prop.
- Restores **+45 thirst** (additive, capped at 100).
- **3 uses per player per hour**, rolling 60‑minute window, enforced **server‑side**.
- Two‑phase interaction with the cup held in the **left hand** throughout:
  1. **Fill** (`Config.FillDuration`, default 5s): middle‑right NUI shows the cup filling with a progress bar + pour sound.
  2. **Drink** (`Config.DrinkDuration`, default 10s): NUI hides and the drinking animation plays.
- The NUI sits middle‑right so it doesn't block the prop or the player.

## Dependencies

- [`qbx_core`](https://github.com/Qbox-project/qbx_core)
- [`ox_lib`](https://github.com/overextended/ox_lib)
- [`ox_target`](https://github.com/overextended/ox_target)

## Install

1. Copy the `ls_waterdispenser` folder into your server's `resources/`.
2. Ensure it starts **after** its dependencies in `server.cfg`:

   ```cfg
   ensure ox_lib
   ensure ox_target
   ensure qbx_core
   ensure ls_waterdispenser
   ```

3. Restart the server (or `ensure ls_waterdispenser`).

## Configuration

All settings live in `config.lua`:

| Key | Default | Description |
| --- | --- | --- |
| `Config.UsesPerHour` | `3` | Uses allowed per player within the window. |
| `Config.WindowMinutes` | `60` | Rolling window length in minutes. |
| `Config.ThirstRestore` | `45` | Thirst added per use (capped at 100). |
| `Config.FillDuration` | `5000` | Cup‑fill phase in ms (NUI + progress bar), shown before drinking. |
| `Config.DrinkDuration` | `10000` | Drinking animation length in ms, after the cup fills. |
| `Config.Anim` | `mp_player_intdrink / loop_bottle` | Ped drinking animation. |
| `Config.Cup` | `ng_proc_watercup_01`, bone `18905` | Held cup prop + left‑hand bone/offset. Set `model = false` to disable. |
| `Config.Sound` | `pour.wav`, vol `0.5` | Pour sound played through the NUI. |
| `Config.Props` | coolers + vendor | Prop models the interaction attaches to. Add your own. |

### Thirst / HUD note

Thirst is applied server‑side via the Qbox player object
(`SetMetaData('thirst', ...)`) and the HUD is refreshed with
`hud:client:UpdateNeeds`. If your HUD reads needs differently, adjust that one
line in `server/main.lua`.

## Assets

- `html/sounds/pour.wav` is a synthesized placeholder produced by
  `tools/generate_pour_sound.py` (stdlib only). Drop in your own file and point
  `Config.Sound.file` at it to change the sound.

## Previewing the NUI without a server

Open `html/index.html?demo=1` in a browser to loop the pour + progress‑bar
animation. The `?demo=1` guard never runs inside the game client.
