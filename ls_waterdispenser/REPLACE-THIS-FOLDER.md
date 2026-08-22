# CRITICAL — Install v2.3.4 (fixes `Prop` nil)

Your error:
```
attempt to index a nil value (global 'Prop')
@ls_waterdispenser/client/main.lua:49
@ls_waterdispenser/client/main.lua:82
```
means `client/prop.lua` is **missing** on the server (or not listed in `fxmanifest.lua`).

## Do this exactly

1. Stop the resource:
   ```
   stop ls_waterdispenser
   ```

2. On the server, **DELETE** the whole folder:
   ```
   resources/.../ls_waterdispenser
   ```
   Do not overwrite. Delete it.

3. Download:
   https://codeload.github.com/mraprokothegamer/legendscave/zip/refs/heads/cursor/water-dispenser-resource-b357

4. From the zip, copy folder `ls_waterdispenser` into resources.

5. Confirm **all** of these exist:
   ```
   ls_waterdispenser/fxmanifest.lua          ← must list client/prop.lua
   ls_waterdispenser/config.lua
   ls_waterdispenser/client/hud.lua
   ls_waterdispenser/client/prop.lua         ← REQUIRED (defines Prop)
   ls_waterdispenser/client/main.lua
   ls_waterdispenser/server/main.lua
   ls_waterdispenser/server/framework.lua
   ls_waterdispenser/html/index.html
   ls_waterdispenser/html/app.js
   ls_waterdispenser/html/style.css
   ```

6. Start:
   ```
   refresh
   ensure ls_waterdispenser
   ```

7. Console MUST show **both** lines:
   ```
   [ls_waterdispenser] client/prop.lua v2.3.4 loaded (Prop module OK)
   [ls_waterdispenser] client/main.lua v2.3.4 loaded (expects Prop from prop.lua)
   ```

If you only see `main.lua` and not `prop.lua`, the file was not copied or `fxmanifest.lua` is old.
If you still see `Prop` nil, a duplicate/old `ls_waterdispenser` or `waterdispenser` resource is being started instead.
