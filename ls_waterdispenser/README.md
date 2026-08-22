# ls_waterdispenser

## Correct folder structure (required)

```
resources/[standalone]/ls_waterdispenser/
├── fxmanifest.lua
├── config.lua
├── client/
│   ├── hud.lua
│   ├── prop.lua
│   └── main.lua
├── server/
│   ├── framework.lua
│   └── main.lua
├── shared/
│   └── validate.lua
└── html/
    ├── index.html
    ├── style.css
    └── app.js
```

## Install

1. Delete any old/broken `ls_waterdispenser` folder on your server
2. Copy this **entire** folder into `resources/[standalone]/`
3. In server.cfg:
   ```
   ensure ox_lib
   ensure ox_target
   ensure qbx_core
   ensure 17mov_Hud
   ensure ls_waterdispenser
   ```
4. Restart server (or `refresh` then `ensure ls_waterdispenser`)

## Important

- Do **not** nest folders like `ls_waterdispenser/waterdispenser/...`
- `fxmanifest.lua` must sit next to `client/`, `server/`, `html/`, and `config.lua`
- No `html/sounds/pour.wav` is required — sounds use GTA natives

## Config defaults

- Price: $10
- Thirst: +30%
- Cup: right hand (bone 57005)
- NUI: far right fill panel
