#!/usr/bin/env bash
# Idempotent dev-environment bootstrap for the legendscave FiveM/Qbox resources.
#
# The resources are CitizenFX (Lua 5.4) scripts with NUI web frontends. This
# installs the tooling used to develop them locally:
#   - lua5.4 + luac5.4  : run/byte-compile (syntax-check) resource Lua
#   - luacheck          : static analysis / linting (see .luacheckrc)
#   - python3           : serves the NUI for browser preview (tools/serve_nui.py)
#
# python3 and node are already present in the base image, so this only adds the
# Lua toolchain. Safe to run repeatedly.
set -euo pipefail

need_apt=0
command -v lua5.4  >/dev/null 2>&1 || need_apt=1
command -v luac5.4 >/dev/null 2>&1 || need_apt=1
command -v luarocks >/dev/null 2>&1 || need_apt=1

if [ "$need_apt" -eq 1 ]; then
    echo "[install] Installing Lua toolchain via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq lua5.4 liblua5.4-dev luarocks
else
    echo "[install] Lua toolchain already present; skipping apt."
fi

if command -v luacheck >/dev/null 2>&1; then
    echo "[install] luacheck already present; skipping."
else
    echo "[install] Installing luacheck via luarocks..."
    sudo luarocks install luacheck
fi

echo "[install] Versions:"
lua5.4 -v
luac5.4 -v 2>/dev/null || true
luacheck --version | head -1
python3 --version

echo "[install] Done."
