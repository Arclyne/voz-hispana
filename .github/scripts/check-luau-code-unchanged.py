#!/usr/bin/env python3
"""Assert that a diff changes only comments and whitespace in .luau files.

The documentation project that produced this site is allowed to add Moonwave
annotations and comments to Luau sources, but must never change a line of
executable code. This script enforces that mechanically instead of by review.

For every .luau file that differs between a base ref and the working tree, both
versions are stripped of comments and blank lines by a small Luau lexer (one that
understands short strings, long strings, line comments and long comments, so that
a `--` inside a string literal is not mistaken for a comment) and the results are
compared. Any difference is reported with the first offending line.

Usage:
    python3 .github/scripts/check-luau-code-unchanged.py [BASE_REF]

BASE_REF defaults to origin/main, falling back to main.
Exit code 0 means no executable code changed.
"""

from __future__ import annotations

import subprocess
import sys


def strip_luau(source: str) -> str:
    """Return `source` with comments removed and blank lines dropped."""
    out: list[str] = []
    i, n = 0, len(source)

    def long_bracket(start: int) -> tuple[int, int] | None:
        """If a long bracket opens at `start`, return (level, index after it)."""
        if source[start] != "[":
            return None
        j = start + 1
        level = 0
        while j < n and source[j] == "=":
            level += 1
            j += 1
        if j < n and source[j] == "[":
            return level, j + 1
        return None

    while i < n:
        ch = source[i]

        # Comment: line or long.
        if ch == "-" and source.startswith("--", i):
            bracket = long_bracket(i + 2) if i + 2 < n else None
            if bracket:
                level, body = bracket
                close = "]" + "=" * level + "]"
                end = source.find(close, body)
                i = n if end == -1 else end + len(close)
            else:
                end = source.find("\n", i)
                i = n if end == -1 else end
            continue

        # Long string: preserved verbatim, it is code.
        bracket = long_bracket(i)
        if bracket:
            level, body = bracket
            close = "]" + "=" * level + "]"
            end = source.find(close, body)
            end = n if end == -1 else end + len(close)
            out.append(source[i:end])
            i = end
            continue

        # Short string: consume whole, honouring escapes.
        if ch in "\"'":
            j = i + 1
            while j < n:
                if source[j] == "\\":
                    j += 2
                    continue
                if source[j] == ch:
                    j += 1
                    break
                j += 1
            out.append(source[i:j])
            i = j
            continue

        out.append(ch)
        i += 1

    stripped = (line.strip() for line in "".join(out).split("\n"))
    return "\n".join(line for line in stripped if line)


def git(*args: str) -> str:
    return subprocess.run(
        ["git", *args], check=True, capture_output=True, text=True
    ).stdout


def base_ref(argv: list[str]) -> str:
    if len(argv) > 1:
        return argv[1]
    for candidate in ("origin/main", "main"):
        try:
            git("rev-parse", "--verify", candidate)
            return candidate
        except subprocess.CalledProcessError:
            continue
    sys.exit("Could not resolve a base ref; pass one explicitly.")


def main() -> int:
    base = base_ref(sys.argv)
    changed = [
        path
        for path in git("diff", "--name-only", base, "--", "*.luau").splitlines()
        if path
    ]

    if not changed:
        print(f"No .luau files differ from {base}.")
        return 0

    violations: list[str] = []
    for path in changed:
        try:
            before = git("show", f"{base}:{path}")
        except subprocess.CalledProcessError:
            before = ""  # new file
        try:
            after = open(path, encoding="utf-8").read()
        except FileNotFoundError:
            after = ""  # deleted file

        stripped_before = strip_luau(before)
        stripped_after = strip_luau(after)
        if stripped_before == stripped_after:
            continue

        before_lines = stripped_before.split("\n")
        after_lines = stripped_after.split("\n")
        detail = "code differs beyond the end of the other version"
        for index in range(min(len(before_lines), len(after_lines))):
            if before_lines[index] != after_lines[index]:
                detail = (
                    f"first difference at stripped line {index + 1}\n"
                    f"        {base}: {before_lines[index]!r}\n"
                    f"        working: {after_lines[index]!r}"
                )
                break
        violations.append(f"  {path}: {detail}")

    print(f"Checked {len(changed)} changed .luau file(s) against {base}.")
    if violations:
        print("\nExecutable Luau changed — this project may only add comments:\n")
        print("\n".join(violations))
        return 1

    print("Only comments and whitespace changed. OK.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
