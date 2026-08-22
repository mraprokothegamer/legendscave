# waterdispenser v2.0.4 — Verification Checklist

Run through this after install to confirm the **fixed build** is active.

---

## 1. Required files (13 total)

| File | Purpose |
|------|---------|
| `fxmanifest.lua` | Manifest — version **2.0.4** |
| `config.lua` | Config — **CupBone = 18905** (left hand) |
| `INSTALL.md` | Install guide |
| `VERIFY.md` | This checklist |
| `client/hud.lua` | 17mov_Hud thirst sync |
| `client/prop.lua` | Cup spawn + **left hand** attach |
| `client/main.lua` | Drink sequence + NUI |
| `server/framework.lua` | Qbox/ESX bridge |
| `server/main.lua` | Cooldown + thirst |
| `shared/validate.lua` | Config validation |
| `html/index.html` | NUI — **"UI v2.0.4 · Far right · Left hand"** |
| `html/style.css` | NUI — far right padding **4px** |
| `html/app.js` | Fill animation + positioning |

---

## 2. Key settings (`config.lua`)

```lua
Config.CupBone = 18905              -- LEFT hand (SKEL_L_Hand)
Config.NuiPosition = 'bottom-right'
Config.NuiPaddingRight = 4          -- Far right edge
Config.ThirstRefill = 10
Config.MaxDrinksPerHour = 2
```

---

## 3. In-game checks

| # | Check | Pass? |
|---|--------|-------|
| 1 | NUI is on the **far right** — not center | ☐ |
| 2 | Panel shows **"UI v2.0.4 · Far right · Left hand"** | ☐ |
| 3 | Cup appears in **left hand** during drink | ☐ |
| 4 | Vertical cup fill + progress bar runs ~7 seconds | ☐ |
| 5 | Thirst increases +10% after drinking | ☐ |
| 6 | 3rd drink within 1 hour is blocked (cooldown) | ☐ |

If you do **not** see the version text in step 2, you are still on an **old build**.

---

## 4. Server console (on resource start)

```
[waterdispenser] Framework: Qbox (qbx_core)
[waterdispenser] Production build loaded successfully.
```

---

## 5. server.cfg load order

```cfg
ensure ox_lib
ensure ox_target
ensure qbx_core
ensure 17mov_Hud
ensure waterdispenser
```

---

## 6. Clean install steps

1. **Delete** the old `waterdispenser` folder completely
2. Extract the new zip into `resources/[standalone]/`
3. Run in server console:
   ```
   stop waterdispenser
   refresh
   ensure waterdispenser
   ```
4. Or restart the full server

---

## 7. Debug mode

In `config.lua`:
```lua
Config.Debug = true
```

Restart resource, then F8:
```
/testwater
```

Expected F8 output:
```
[waterdispenser] Cup attached to left hand using model hash: ...
```

---

## 8. Quick file grep (optional)

On your server machine, inside the resource folder:

```bash
grep "2.0.4" fxmanifest.lua html/index.html
grep "18905" config.lua
grep "paddingRight" html/app.js client/main.lua
```

All three should return matches.
