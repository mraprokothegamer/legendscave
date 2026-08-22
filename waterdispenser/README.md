# ls_waterdispenser v2.0.7

Uses **existing Rockstar water cooler props** already in the map (`prop_watercooler`, etc.).
Does **not** spawn coolers — only a temporary cup in the player's right hand while drinking.

## Features
- ox_target (third eye) on Rockstar water coolers
- Price: $10 (config)
- Thirst: +30% (config)
- Cup in **right hand** (bone 57005) with safe model fallbacks
- Far-right NUI fill animation + progress bar
- Pour + sip sounds (GTA natives — no .wav files)
- Qbox / qb-core / ESX + 17mov_Hud

## Folder structure (required)

```
ls_waterdispenser/
├── fxmanifest.lua
├── config.lua
├── client/hud.lua, prop.lua, main.lua
├── server/framework.lua, main.lua
├── shared/validate.lua
└── html/index.html, style.css, app.js
```

## Install
1. Delete any old `ls_waterdispenser` folder
2. Place this folder in `resources/[standalone]/ls_waterdispenser`
3. server.cfg:
   ```
   ensure ox_lib
   ensure ox_target
   ensure qbx_core
   ensure 17mov_Hud
   ensure ls_waterdispenser
   ```
4. Restart server

## Config highlights
```lua
Config.WaterPrice = 10
Config.ThirstRefill = 30
Config.CupModel = `prop_plastic_cup_02`  -- right hand
Config.KnownModels = { `prop_watercooler`, `prop_watercooler_dark` }
```
