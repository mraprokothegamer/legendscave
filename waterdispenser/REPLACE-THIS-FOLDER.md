# Install v2.3.5

`main.lua` now includes a **built-in Prop fallback**, so the old
`FATAL: client/prop.lua is missing` error cannot block drinking.

## Quick update (minimum)

Replace at least this one file on the server:

```
ls_waterdispenser/client/main.lua
```

Then:

```
ensure ls_waterdispenser
```

Console must show:

```
[ls_waterdispenser] client/main.lua v2.3.5 loaded
```

You may also see (harmless):

```
[ls_waterdispenser] prop.lua not loaded — using built-in Prop fallback
```

## Full clean install (recommended)

1. `stop ls_waterdispenser`
2. Delete the whole `ls_waterdispenser` folder
3. Download:
   https://codeload.github.com/mraprokothegamer/legendscave/zip/refs/heads/cursor/water-dispenser-resource-b357
4. Copy `ls_waterdispenser` into resources
5. `refresh` → `ensure ls_waterdispenser`
