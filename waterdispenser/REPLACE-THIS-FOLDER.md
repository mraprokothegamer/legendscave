# CRITICAL — How to install v2.3.2 (fixes Prop nil)

Your console error:
```
attempt to index a nil value (global 'Prop')
```
means the server is STILL running an OLD `client/main.lua`.

## Do this exactly

1. Stop the resource:
   ```
   stop ls_waterdispenser
   ```

2. On the server machine, **DELETE** the whole folder:
   ```
   resources/.../ls_waterdispenser
   ```
   Do not overwrite. Delete it.

3. Download fresh zip:
   https://codeload.github.com/mraprokothegamer/legendscave/zip/refs/heads/cursor/water-dispenser-resource-b357

4. From the zip, copy folder `ls_waterdispenser` into resources.

5. Confirm these files exist:
   ```
   ls_waterdispenser/fxmanifest.lua
   ls_waterdispenser/config.lua
   ls_waterdispenser/client/main.lua      ← MUST be ~11KB, no Prop. calls
   ls_waterdispenser/client/hud.lua
   ls_waterdispenser/server/main.lua
   ls_waterdispenser/server/framework.lua
   ls_waterdispenser/html/index.html
   ```
   There should be **NO** `client/prop.lua`.

6. Start:
   ```
   refresh
   ensure ls_waterdispenser
   ```

7. Console MUST show:
   ```
   [ls_waterdispenser] client/main.lua v2.3.2 loaded (self-contained, no Prop module)
   ```

If you still see `Prop` errors, the wrong folder is being started (check `ensure` path / duplicate resources).
