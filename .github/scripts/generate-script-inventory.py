"""Regenerate the script inventory under docs/reference/.

These pages are generated, not hand-written: they are a mechanical census of the
repository, and hand-maintaining them would guarantee they drift. Re-run this
script after adding, removing or renaming files, and commit the result.

Run from the repository root:  python3 .github/scripts/generate-script-inventory.py

The status sets near the top are the one hand-maintained part: they record how
far the documentation project has read each file. Update them as files are read.
"""

import os, json, collections

ROOT = "src"
ANALYSED = {
    "src/ServerScriptService/ImportTemplates.server.luau",
    "src/ServerScriptService/InitScripts.server.luau",
    "src/ReplicatedStorage/InitAfterTemplates.luau",
    "src/ReplicatedStorage/PlayerInit.luau",
    "src/ReplicatedStorage/Client/visualsManager.server.luau",
}
def t(*parts):
    return "src/ServerStorage/TemplatesTesting/" + "/".join(parts)
ANALYSED |= {
    t("Core/ServerScriptService/ServerScripts/WorldManager.server.luau"),
    t("Core/ServerScriptService/ServerScripts/playerManager.server.luau"),
    t("Core/ServerScriptService/ServerScripts/PlayerDataReplicator.server.luau"),
    t("Core/ServerScriptService/ServerScripts/ServerDirectory.server.luau"),
    t("Core/ServerScriptService/ServerScripts/WorldsBrowser.server.luau"),
    t("Core/ServerStorage/WorldSystem/ServerPresence.luau"),
    t("Core/ServerStorage/WorldSystem/Profiles.luau"),
    t("Core/ServerStorage/WorldSystem/PlayerSchema.luau"),
    t("Core/ReplicatedStorage/HousesInfo.luau"),
    t("Core/ReplicatedStorage/GeneralConfiguration.luau"),
    t("Core/ReplicatedStorage/Client/PlayerManager.server.luau"),
    t("Core/ReplicatedStorage/Client/MainPS.server.luau"),
    t("Core/StarterGui/LocalScript.client.luau"),
    t("Core/ServerStorage/DataKit/init.luau"),
    t("Core/ServerStorage/DataKit/Profile.luau"),
    t("Core/ServerStorage/DataKit/Lease.luau"),
    t("Core/ServerStorage/DataKit/Mutex.luau"),
    t("Core/ServerStorage/DataKit/Health.luau"),
    t("GameWorlds/ServerScriptService/ServerScripts/PublicServerInit.lua.server.luau"),
    t("PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau"),
    t("PlayerHouses/ServerScriptService/WorldService.luau"),
    t("PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau"),
    t("PlayerHouses/ServerScriptService/ModeratorManager.server.luau"),
    t("PlayerHouses/ReplicatedStorage/RolesInfo.luau"),
}
PARTIAL = {
    t("Core/ServerStorage/DataKit/Store.luau"),
    t("Core/ServerStorage/DataKit/BaseStore.luau"),
    t("Core/ServerScriptService/ServerScripts/ShopServerSystem.server.luau"),
}
DOCUMENTED = {
    "src/ReplicatedStorage/PlayerInit.luau",
    t("Core/ServerStorage/WorldSystem/ServerPresence.luau"),
}

def meta_for(p):
    stem = p[:-len(".luau")]
    for suf in (".server", ".client"):
        if stem.endswith(suf):
            stem = stem[:-len(suf)]
            break
    return stem + ".meta.json"

def runtime_path(p):
    rel = p[len(ROOT) + 1:]
    parts = rel.split("/")
    if parts[:2] == ["ServerStorage", "TemplatesTesting"] and len(parts) > 3:
        return f"{parts[3]}." + ".".join(parts[4:]).replace(".luau", ""), parts[2]
    return ".".join(parts).replace(".luau", ""), "(root)"

rows = []
for dp, _, fn in os.walk(ROOT):
    for f in sorted(fn):
        if not f.endswith(".luau"):
            continue
        p = os.path.join(dp, f)
        kind = "Script" if ".server." in f else ("LocalScript" if ".client." in f else "ModuleScript")
        ctx, disabled = "", ""
        m = meta_for(p)
        if os.path.exists(m):
            try:
                pr = json.load(open(m, encoding="utf-8")).get("properties", {})
                ctx = pr.get("RunContext", "")
                disabled = "yes" if pr.get("Disabled") else ""
            except Exception:
                pass
        lines = sum(1 for _ in open(p, encoding="utf-8", errors="replace"))
        rt, tmpl = runtime_path(p)
        if p in DOCUMENTED:
            status = "**Documented**"
        elif p in ANALYSED:
            status = "Analyzed"
        elif p in PARTIAL:
            status = "Analyzed (partly)"
        else:
            status = "Pending"
        rows.append(dict(path=p, kind=kind, ctx=ctx, disabled=disabled,
                         lines=lines, rt=rt, tmpl=tmpl, status=status))

counts = collections.Counter(r["status"] for r in rows)
out = ["""---
sidebar_position: 1
title: Script inventory
---

# Script inventory

Every inspectable `.luau` file in the repository, with the DataModel path it occupies at
runtime and how far this documentation project has got with it.

Two columns exist because the filename lies about both:

* **Runtime path** — the template import moves everything out of
  `ServerStorage/TemplatesTesting/<Template>/<Service>/` into `<Service>`. See
  [Initialization](../architecture/initialization.md).
* **Context** — `RunContext` from the sibling `.meta.json` overrides the `.server.luau` /
  `.client.luau` suffix. A blank cell means no `RunContext` is set, so the suffix decides.

**Disabled** marks a script that ships switched off and is enabled later — by
`InitScripts` on the server, or by something outside this repository on the client
([BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007)).

## Status

| Status | Meaning | Count |
|---|---|---|
"""]
for label, meaning in [
    ("**Documented**", "Read in full and annotated with Moonwave by this project"),
    ("Analyzed", "Read in full; its behaviour is described somewhere on this site"),
    ("Analyzed (partly)", "Read in the parts that mattered for a specific question"),
    ("Pending", "Not yet read"),
]:
    out.append(f"| {label} | {meaning} | {counts.get(label, 0)} |\n")
out.append(f"\n**Total: {len(rows)} files, {sum(r['lines'] for r in rows):,} lines.**\n")

order = ["(root)", "Core", "GameWorlds", "PlayerHouses", "BuildingSystem"]
by_tmpl = collections.defaultdict(list)
for r in rows:
    by_tmpl[r["tmpl"]].append(r)

for tmpl in order + sorted(k for k in by_tmpl if k not in order):
    if tmpl not in by_tmpl:
        continue
    group = by_tmpl[tmpl]
    label = "Outside the templates" if tmpl == "(root)" else f"`{tmpl}` template"
    done = sum(1 for r in group if r["status"] != "Pending")
    out.append(f"\n## {label}\n\n{len(group)} files, "
               f"{sum(r['lines'] for r in group):,} lines, {done} read.\n")
    by_dir = collections.defaultdict(list)
    for r in group:
        by_dir[os.path.dirname(r["path"])].append(r)
    for d in sorted(by_dir):
        entries = by_dir[d]
        read = sum(1 for r in entries if r["status"] != "Pending")
        badge = f" — {read}/{len(entries)} read" if read else ""
        out.append(f"\n<details>\n<summary><code>{d}/</code> — {len(entries)} file(s)"
                   f"{badge}</summary>\n\n")
        out.append("| File | Kind | Context | Disabled | Lines | Runtime path | Status |\n"
                   "|---|---|---|---|---|---|---|\n")
        for r in sorted(entries, key=lambda x: x["path"]):
            out.append(f"| `{os.path.basename(r['path'])}` | {r['kind']} | {r['ctx'] or '—'} "
                       f"| {r['disabled'] or '—'} | {r['lines']} | `{r['rt']}` | {r['status']} |\n")
        out.append("\n</details>\n")

open("docs/reference/script-inventory.md", "w", encoding="utf-8").write("".join(out))
print("script-inventory.md:", len(rows), "files;", dict(counts))
