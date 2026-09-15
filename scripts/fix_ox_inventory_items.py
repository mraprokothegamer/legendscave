#!/usr/bin/env python3
"""Repair ox_inventory data/items.lua syntax and the min-weight wrapper.

Fixes:
- curly/smart quotes that Lua cannot parse
- do return (function(t) ... end)({ ... }) wrapping
- truncated facility_card button function
- file footer so the chunk returns a table
"""

from __future__ import annotations

import argparse
import pathlib
import re
import sys

IIFE_START = re.compile(
    r"\A\s*do\s+return\s+\(function\s*\(\s*t\s*\)\s*"
    r".*?"
    r"end\s*\)\s*\(\s*\{",
    re.DOTALL,
)

FACILITY_CARD = """['facility_card'] = {
	label = 'Facility Access Card',
	weight = 10,
	stack = false,
	close = true,
	consume = 0,
	description = 'Access card for a personal storage unit. Use it to open your locker.',
	client = {
		image = 'facility_card.png',
		event = 'facility:client:useCard',
	},
},
"""

HYGIENE_PERFUME = """['hygiene_perfume'] = {
	label = 'Aproko Perfume',
	weight = 100,
	stack = true,
	close = true,
	consume = 1,
	description = 'Fresher you. Premium scent that lasts longer than deodorant.',
	client = {
		image = 'perfume.png',
		export = 'fivem-hygiene.hygiene_perfume',
	},
},
"""

FOOTER = """
for _, v in pairs(items) do
	if type(v) == 'table' and type(v.weight) == 'number' and v.weight < 500 then
		v.weight = 500
	end
end

return items
"""

NEXT_ITEM = re.compile(r"\n(?=\s*\[['\"][^'\"]+['\"]\]\s*=)")


def normalize_quotes(text: str) -> str:
    return (
        text.replace("\ufeff", "")
        .replace("\u2018", "'")
        .replace("\u2019", "'")
        .replace("\u201c", '"')
        .replace("\u201d", '"')
    )


def replace_named_item(text: str, name: str, replacement: str) -> str:
    pattern = re.compile(
        rf"\['{re.escape(name)}'\]\s*=\s*\{{.*?(?=\n\s*\[['\"][^'\"]+['\"]\]\s*=|\n\s*\}}\s*\)?\s*(?:end)?\s*\Z)",
        re.DOTALL,
    )
    if not pattern.search(text):
        return text
    return pattern.sub(lambda _: replacement.rstrip() + "\n", text, count=1)


def unwrap_iife(text: str) -> tuple[str, bool]:
    match = IIFE_START.search(text)
    if not match:
        return text, False
    body = "local items = {\n" + text[match.end() :]
    return body, True


def fix_footer(text: str, unwrapped: bool) -> str:
    stripped = text.rstrip() + "\n"
    if re.search(r"\nreturn items\s*\Z", stripped):
        return stripped

    if unwrapped or stripped.lstrip().startswith("local items"):
        stripped = re.sub(r"\nend\s*\Z", "\n", stripped)
        stripped = stripped.rstrip() + "\n"
        stripped = re.sub(r"\)\s*\Z", "", stripped)
        stripped = stripped.rstrip() + "\n"
        if not stripped.rstrip().endswith("}"):
            stripped = stripped.rstrip() + "\n}\n"
        if "return items" not in stripped:
            stripped = stripped.rstrip() + "\n" + FOOTER
        return stripped if stripped.endswith("\n") else stripped + "\n"

    # Normal ox_inventory file: return { ... }
    if not re.search(r"\nreturn\s+", stripped) and stripped.lstrip().startswith("{"):
        stripped = "return " + stripped.lstrip()
    return stripped


def apply_fixes(text: str) -> str:
    text = normalize_quotes(text)
    text, unwrapped = unwrap_iife(text)
    text = replace_named_item(text, "hygiene_perfume", HYGIENE_PERFUME)
    text = replace_named_item(text, "facility_card", FACILITY_CARD)
    return fix_footer(text, unwrapped)


def brace_balance(text: str) -> int:
    depth = 0
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        if ch == "-" and i + 1 < n and text[i + 1] == "-":
            if i + 3 < n and text[i + 2] == "[" and text[i + 3] == "[":
                end = text.find("]]", i + 4)
                i = n if end == -1 else end + 2
                continue
            end = text.find("\n", i)
            i = n if end == -1 else end + 1
            continue
        if ch in "'\"":
            quote = ch
            i += 1
            while i < n:
                if text[i] == "\\":
                    i += 2
                    continue
                if text[i] == quote:
                    i += 1
                    break
                i += 1
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        i += 1
    return depth


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "path",
        nargs="?",
        default="ox_inventory/data/items.lua",
        help="Path to items.lua",
    )
    parser.add_argument("-o", "--output", help="Write to this path instead of in-place")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    source = pathlib.Path(args.path)
    if not source.is_file():
        print(f"File not found: {source}", file=sys.stderr)
        return 1

    original = source.read_text(encoding="utf-8")
    fixed = apply_fixes(original)
    depth = brace_balance(fixed)
    if depth != 0:
        print(
            f"Warning: curly-brace balance is {depth} after the fix (0 is expected).",
            file=sys.stderr,
        )

    dest = pathlib.Path(args.output) if args.output else source
    if args.dry_run:
        print(fixed)
        return 0 if depth == 0 else 2

    dest.write_text(fixed, encoding="utf-8", newline="\n")
    print(f"Wrote {dest} ({len(fixed.splitlines())} lines)")
    return 0 if depth == 0 else 2


if __name__ == "__main__":
    sys.exit(main())
