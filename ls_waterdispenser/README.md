# ls_waterdispenser v2.4.3

Drink from existing Rockstar water coolers (`prop_watercooler`).
Free water, +30% thirst, cup in hand, fill NUI.

## Files

```
ls_waterdispenser/
├── fxmanifest.lua
├── config.lua
├── client/hud.lua
├── client/main.lua      ← cup + drink + NUI (no prop.lua)
├── server/framework.lua
├── server/main.lua
├── shared/validate.lua
└── html/index.html, style.css, app.js
```

## Install

1. Delete any old `ls_waterdispenser` folder
2. Put this folder in resources
3. `ensure ox_lib` / `ox_target` / `qbx_core` / `17mov_Hud` / `ls_waterdispenser`
4. Console must show: `[ls_waterdispenser] v2.4.3 loaded`

The drink cup is a **local** object (`CreateObject` `isNetwork=false`). Do not spawn it networked: that triggers FiveM's `NETWORK_GET_NETWORK_ID_FROM_ENTITY: no net object for entity` warning.

Download:
https://codeload.github.com/mraprokothegamer/legendscave/zip/refs/heads/cursor/fix-entity-net-object-8739
