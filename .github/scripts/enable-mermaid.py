"""Enable Mermaid rendering in moonwave.toml.

Called by .github/workflows/docs.yml between the warm-up build and the real
build, and only after @docusaurus/theme-mermaid has been installed into
Moonwave's cached Docusaurus project. It edits the working copy of
moonwave.toml in place; the change is never committed.

Kept as a file rather than an inline heredoc because the workflow's `run:`
block is indented, and an indented heredoc terminator would never close.
"""

import sys

PATH = "moonwave.toml"
ANCHOR = "[docusaurus]\n"
REPLACEMENT = (
    "[docusaurus]\n"
    'themes = ["@docusaurus/theme-mermaid"]\n'
    "markdown = { mermaid = true }\n"
)

text = open(PATH, encoding="utf-8").read()

# Match the setting, not the prose: moonwave.toml carries a comment explaining
# why the theme is not declared there, and that comment names the package.
if 'themes = ["@docusaurus/theme-mermaid"]' in text:
    print("Mermaid already enabled; nothing to do.")
    sys.exit(0)

count = text.count(ANCHOR)
if count != 1:
    sys.exit(f"Expected exactly one [docusaurus] table in {PATH}, found {count}.")

open(PATH, "w", encoding="utf-8").write(text.replace(ANCHOR, REPLACEMENT, 1))
print("Mermaid rendering enabled in moonwave.toml.")
