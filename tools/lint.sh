#!/usr/bin/env bash
# Lint the FiveM/Qbox Lua in this repo with luacheck, tolerating CitizenFX Lua
# (CfxLua) extensions that the stock Lua 5.4 parser cannot read.
#
# The main incompatibility is the backtick hash literal: in CfxLua, `foo` is a
# compile-time joaat() hash and is used for model/prop names. Stock luacheck
# reports it as a syntax error. Backtick and single-quote are both single
# characters, so swapping `foo` -> 'foo' on a throwaway copy lets luacheck parse
# the file while keeping every line/column number identical to the source.
#
# Usage:
#   tools/lint.sh            # lint the whole repo
#   tools/lint.sh path ...   # lint specific paths (relative to repo root)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cp "$ROOT/.luacheckrc" "$TMP/.luacheckrc"

while IFS= read -r -d '' f; do
    rel="${f#"$ROOT"/}"
    mkdir -p "$TMP/$(dirname "$rel")"
    sed "s/\`/'/g" "$f" > "$TMP/$rel"
done < <(find "$ROOT" -name '*.lua' -not -path '*/.git/*' -print0)

cd "$TMP"
if [ "$#" -gt 0 ]; then
    exec luacheck "$@"
else
    exec luacheck .
fi
