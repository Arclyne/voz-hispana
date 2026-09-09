"""Regenerate the binary-asset and remote inventories under docs/reference/.

These pages are generated, not hand-written: they are a mechanical census of the
repository, and hand-maintaining them would guarantee they drift. Re-run this
script after adding, removing or renaming files, and commit the result.

Run from the repository root:  python3 .github/scripts/generate-reference.py
"""

import os, json, collections, re

ROOT = "src"

def runtime_path(p):
    """Where a repository path ends up in the DataModel at runtime."""
    rel = p[len(ROOT) + 1:]
    parts = rel.split("/")
    if parts[:2] == ["ServerStorage", "TemplatesTesting"] and len(parts) > 3:
        return f"{parts[3]}." + ".".join(parts[4:]), parts[2]
    return ".".join(parts), "(root)"

# ---------- binary assets ----------
bins = collections.defaultdict(list)
for dp, _, fn in os.walk(ROOT):
    for f in sorted(fn):
        if f.endswith(".rbxm") or f.endswith(".rbxl"):
            p = os.path.join(dp, f)
            rt, tmpl = runtime_path(p)
            bins[tmpl].append((p, rt, os.path.getsize(p)))

total = sum(len(v) for v in bins.values())
out = ["""---
sidebar_position: 2
title: Binary assets
---

# Binary assets

**Not inspectable.** These files are Roblox binary models. Their contents cannot be read
from this repository, and **nothing on this site describes what is inside them**. They are
listed so that a reader knows what exists, where it lands at runtime, and which gaps in the
documentation they account for.

If a page says a producer or consumer could not be found, one of these files is the most
likely home for it.
""", f"\n**{total} files.**\n"]

out.append("""
## The ones that matter most

| File | Why it matters |
|---|---|
| `src/StarterPlayer/StarterPlayerScripts.rbxm` | The most likely home of the client script loader and of the `LoadCharacterRequest` sender. Accounts for [BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007). |
| `src/StarterPlayer/StarterCharacterScripts.rbxm` | Whatever is added to every character. Makes [Character lifecycle](../architecture/character-lifecycle.md) incomplete by construction. |
| `src/ReplicatedFirst/LoadingScreenUI.rbxm` | The first thing a client sees. |
| `src/StarterGui/ScreenGui.rbxm`, `src/StarterGui/BuildMenu.rbxm` | Root UI, outside the templates. |
| `…/PlayerHouses/StarterGui/PermsGui.rbxm` | The house permissions UI — the client half of [Housing → Permissions](../systems/housing/permissions.md). |
""")

for tmpl in sorted(bins):
    files = bins[tmpl]
    label = "Outside the templates" if tmpl == "(root)" else f"`{tmpl}` template"
    out.append(f"\n## {label}\n\n**{len(files)} files.**\n")
    groups = collections.defaultdict(list)
    for p, rt, size in files:
        groups[os.path.dirname(p)].append((os.path.basename(p), rt, size))
    for d in sorted(groups):
        out.append(f"\n<details>\n<summary><code>{d}/</code> — {len(groups[d])} file(s)</summary>\n\n")
        out.append("| File | Runtime path | Size |\n|---|---|---|\n")
        for name, rt, size in groups[d]:
            out.append(f"| `{name}` | `{rt}` | {size // 1024 or 1} KB |\n")
        out.append("\n</details>\n")

open("docs/reference/binary-assets.md", "w", encoding="utf-8").write("".join(out))
print("binary-assets.md:", total, "files")

# ---------- remotes ----------
rows = []
for dp, _, fn in os.walk(ROOT):
    for f in sorted(fn):
        if not f.endswith((".model.json", ".meta.json")):
            continue
        p = os.path.join(dp, f)
        try:
            d = json.load(open(p, encoding="utf-8"))
        except Exception:
            continue
        cn = d.get("className") or d.get("ClassName")
        if cn not in ("RemoteEvent", "RemoteFunction", "BindableEvent",
                      "BindableFunction", "UnreliableRemoteEvent"):
            continue
        name = f.split(".")[0]
        holder = dp
        if name == "init":
            name = os.path.basename(dp)
            holder = os.path.dirname(dp)
        rt, tmpl = runtime_path(os.path.join(holder, name))
        rows.append((cn, tmpl, rt, name))

by_cls = collections.Counter(r[0] for r in rows)
out = ["""---
sidebar_position: 3
title: Remotes and bindables
---

# Remotes and bindables

Every `RemoteEvent`, `RemoteFunction`, `BindableEvent` and `BindableFunction` declared in
this repository, with the DataModel path it occupies at runtime.

They are **declared as Rojo `.model.json` files**, not created in code, so this list is
complete for the inspectable source. Instances created at runtime by a script — for example
`TemplatesReady`, which `ImportTemplates` creates with `Instance.new` — are noted separately
at the end.

For what they are used for, see [Architecture → Networking](../architecture/networking.md).
"""]
out.append("\n| Class | Count |\n|---|---|\n")
for cn, n in by_cls.most_common():
    out.append(f"| `{cn}` | {n} |\n")

for cn, _ in by_cls.most_common():
    subset = sorted(r for r in rows if r[0] == cn)
    out.append(f"\n## {cn} ({len(subset)})\n\n| Runtime path | Template |\n|---|---|\n")
    for _, tmpl, rt, _name in subset:
        out.append(f"| `{rt}` | {tmpl} |\n")

out.append("""
## Created at runtime, not declared

| Name | Class | Created by |
|---|---|---|
| `ReplicatedStorage.TemplatesReady` | `RemoteEvent` | `ImportTemplates.server.luau` |
| `ReplicatedStorage.TemplatesReadyFlag` | `BoolValue` | `ImportTemplates.server.luau` |
| `ReplicatedStorage.InitScriptsReadyFlag` | `BoolValue` | `InitScripts.server.luau` |
| `ReplicatedStorage.IsInEvent` | `Configuration` | `Core/StarterGui/LocalScript.client.luau`, if absent |
""")
open("docs/reference/remotes.md", "w", encoding="utf-8").write("".join(out))
print("remotes.md:", len(rows), "declared")
