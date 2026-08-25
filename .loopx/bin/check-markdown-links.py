#!/usr/bin/env python3
"""Check local Markdown links while ignoring code examples and external URLs."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
INLINE_CODE = re.compile(r"`[^`]*`")


def iter_markdown(root: Path):
    for path in sorted(root.rglob("*.md")):
        if any(part in {".git", "target", ".omc"} for part in path.parts):
            continue
        yield path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()

    root = Path(__file__).resolve().parents[2]
    broken: list[tuple[Path, int, str]] = []
    for path in iter_markdown(root):
        fenced = False
        for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if raw_line.lstrip().startswith("```"):
                fenced = not fenced
                continue
            if fenced:
                continue
            line = INLINE_CODE.sub("", raw_line)
            for target in LINK.findall(line):
                target = target.strip().split()[0].strip("<>")
                if not target or target.startswith(("#", "/", "http://", "https://", "mailto:")):
                    continue
                relative = target.split("#", 1)[0]
                if relative and not (path.parent / relative).exists():
                    broken.append((path.relative_to(root), line_number, target))

    if broken:
        print("BROKEN MARKDOWN LINKS:")
        for path, line, target in broken:
            print(f"  {path}:{line}: {target}")
        print(f"FAIL: {len(broken)} broken local Markdown links")
        return 1
    print("PASS: All local Markdown links resolve")
    return 0


if __name__ == "__main__":
    sys.exit(main())
