#!/usr/bin/env python3
"""Check that every internal link in docs/ resolves.

moonwave.toml sets `onBrokenLinks = "throw"`, so a bad link fails the site build
on CI. This script catches the same class of problem locally and in a fraction of
the time, which matters because the Moonwave binary cannot be downloaded in every
environment.

It checks two kinds of link:

  * relative Markdown links between pages under docs/, including anchors, which
    are matched against the target page's headings using Docusaurus' slug rules;
  * absolute /api/<Class> links, which are matched against the `@class <Class>`
    annotations actually present in the Luau sources.

External links (http/https) and mailto: are not checked.

Usage: python3 .github/scripts/check-docs-links.py [DOCS_DIR] [CODE_DIR]
"""

from __future__ import annotations

import os
import re
import sys

LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*$", re.MULTILINE)
FENCE = re.compile(r"^```.*?^```", re.MULTILINE | re.DOTALL)


def slug(text: str) -> str:
    """Approximate Docusaurus' heading-to-anchor conversion."""
    text = re.sub(r"`([^`]*)`", r"\1", text)          # strip inline code marks
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)  # strip links
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text)
    return re.sub(r"[\s_]+", "-", text.strip())


def headings(path: str) -> set[str]:
    body = FENCE.sub("", open(path, encoding="utf-8").read())
    return {slug(m.group(2)) for m in HEADING.finditer(body)}


def main() -> int:
    docs = sys.argv[1] if len(sys.argv) > 1 else "docs"
    code = sys.argv[2] if len(sys.argv) > 2 else "src"

    classes: set[str] = set()
    for root, _, files in os.walk(code):
        for name in files:
            if not name.endswith(".luau"):
                continue
            source = open(os.path.join(root, name), encoding="utf-8", errors="replace").read()
            classes.update(re.findall(r"@class\s+(\S+)", source))

    pages = [
        os.path.join(root, name)
        for root, _, files in os.walk(docs)
        for name in files
        if name.endswith((".md", ".mdx"))
    ]
    anchors = {page: headings(page) for page in pages}

    problems: list[str] = []
    checked = 0

    for page in sorted(pages):
        body = FENCE.sub("", open(page, encoding="utf-8").read())
        for match in LINK.finditer(body):
            target = match.group(1)
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            checked += 1

            path_part, _, anchor = target.partition("#")

            if path_part.startswith("/api/"):
                cls = path_part[len("/api/"):].strip("/")
                if cls and cls not in classes:
                    problems.append(
                        f"{page}: /api/{cls} — no `@class {cls}` found under {code}/"
                    )
                continue

            if path_part.startswith("/"):
                problems.append(f"{page}: {target} — unchecked absolute link")
                continue

            resolved = os.path.normpath(os.path.join(os.path.dirname(page), path_part))
            if not os.path.isfile(resolved):
                problems.append(f"{page}: {target} — no such file ({resolved})")
                continue

            if anchor and anchor not in anchors.get(resolved, set()):
                problems.append(f"{page}: {target} — no heading anchor #{anchor} in {resolved}")

    print(f"Checked {checked} internal link(s) across {len(pages)} page(s).")
    if problems:
        print("\nBroken links:\n")
        print("\n".join("  " + p for p in problems))
        return 1
    print("All internal links resolve. OK.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
