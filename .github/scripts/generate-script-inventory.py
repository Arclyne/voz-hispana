"""Regenera el inventario de scripts en docs/reference/.

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
    t("Core/ServerStorage/WorldSystem/PlayerDataService.luau"),
    t("Core/ServerStorage/WorldSystem/PlayerDataReplicator.luau"),
    t("Core/ServerScriptService/ServerScripts/PlayerDataInit.server.luau"),
    t("Core/ReplicatedStorage/Client/EconomySystem/Collections.luau"),
    t("Core/ServerStorage/WorldSystem/EventService.luau"),
    t("Core/ServerScriptService/ServerScripts/EventBootstrap.server.luau"),
    t("Core/ServerStorage/WorldSystem/ReferralService.luau"),
    t("Core/ServerScriptService/Data/Main/init.server.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/HouseAdded.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/ColorTexture.luau"),
    t("Core/ReplicatedStorage/Shared/BreakDown.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/init.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/MainModule.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/MarkAdded.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/Beneficios.luau"),
    t("Core/ServerStorage/WorldSystem/GamePassService/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorsPlayer.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorFuncs/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorFuncs/AddedDecor/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorFuncs/AddedDecor/Collitions.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/Added.luau"),
    t("Core/ReplicatedStorage/Client/interactable/init.server.luau"),
    t("Core/ReplicatedStorage/Shared/bindToTag.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/MusicPlayer.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Bin.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/CuadrosPaint.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Display.server.luau"),
}
PARTIAL = {
    t("Core/ServerStorage/DataKit/Store.luau"),
    t("Core/ServerStorage/DataKit/BaseStore.luau"),
    t("Core/ServerScriptService/ServerScripts/ShopServerSystem.server.luau"),
    t("Core/ServerStorage/RoleService/init.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/Machine.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/PopTheLock.luau"),
    t("Core/ServerScriptService/ServerScripts/EventCommands.server.luau"),
    t("Core/ReplicatedStorage/Shared/AddValues.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/Compras.luau"),
    t("Core/ServerStorage/WorldSystem/GamePassService/GamePassRewards.luau"),
    t("Core/ServerScriptService/Data/Main/PlayerGamesFetcher.luau"),
    t("Core/ServerStorage/SoundInfo.luau"),
    t("Core/ReplicatedStorage/Client/Posicionamientos.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interactable/init.luau"),
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
            status = "**Documentado**"
        elif p in ANALYSED:
            status = "Analizado"
        elif p in PARTIAL:
            status = "Analizado (en parte)"
        else:
            status = "Pendiente"
        rows.append(dict(path=p, kind=kind, ctx=ctx, disabled=disabled,
                         lines=lines, rt=rt, tmpl=tmpl, status=status))

counts = collections.Counter(r["status"] for r in rows)
out = ["""---
sidebar_position: 1
title: Inventario de scripts
---

# Inventario de scripts

Todos los archivos `.luau` inspeccionables del repositorio, con la ruta del DataModel que
ocupan en ejecución y hasta dónde ha llegado este proyecto de documentación con cada uno.

Hay dos columnas porque el nombre del archivo miente sobre ambas cosas:

* **Ruta en ejecución** — la importación de plantillas saca todo de
  `ServerStorage/TemplatesTesting/<Plantilla>/<Servicio>/` hacia `<Servicio>`. Ver
  [Inicialización](../architecture/initialization.md).
* **Contexto** — el `RunContext` del `.meta.json` hermano manda sobre el sufijo
  `.server.luau` / `.client.luau`. Una celda vacía significa que no hay `RunContext`, así
  que decide el sufijo.

**Desactivado** marca un script que se distribuye apagado y se activa después: por
`InitScripts` en el servidor, o por algo ajeno a este repositorio en el cliente
([BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007)).

## Estado

| Estado | Significado | Cantidad |
|---|---|---|
"""]
for label, meaning in [
    ("**Documentado**", "Leído entero y anotado con Moonwave por este proyecto"),
    ("Analizado", "Leído entero; su comportamiento se describe en alguna página del sitio"),
    ("Analizado (en parte)", "Leído solo en las partes relevantes para una pregunta concreta"),
    ("Pendiente", "Aún sin leer"),
]:
    out.append(f"| {label} | {meaning} | {counts.get(label, 0)} |\n")
out.append(f"\n**Total: {len(rows)} archivos, {sum(r['lines'] for r in rows):,} líneas.**\n")

order = ["(root)", "Core", "GameWorlds", "PlayerHouses", "BuildingSystem"]
by_tmpl = collections.defaultdict(list)
for r in rows:
    by_tmpl[r["tmpl"]].append(r)

for tmpl in order + sorted(k for k in by_tmpl if k not in order):
    if tmpl not in by_tmpl:
        continue
    group = by_tmpl[tmpl]
    label = "Fuera de las plantillas" if tmpl == "(root)" else f"Plantilla `{tmpl}`"
    done = sum(1 for r in group if r["status"] != "Pendiente")
    out.append(f"\n## {label}\n\n{len(group)} archivos, "
               f"{sum(r['lines'] for r in group):,} líneas, {done} leídos.\n")
    by_dir = collections.defaultdict(list)
    for r in group:
        by_dir[os.path.dirname(r["path"])].append(r)
    for d in sorted(by_dir):
        entries = by_dir[d]
        read = sum(1 for r in entries if r["status"] != "Pendiente")
        badge = f" — {read}/{len(entries)} leídos" if read else ""
        out.append(f"\n<details>\n<summary><code>{d}/</code> — {len(entries)} archivo(s)"
                   f"{badge}</summary>\n\n")
        out.append("| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |\n"
                   "|---|---|---|---|---|---|---|\n")
        for r in sorted(entries, key=lambda x: x["path"]):
            out.append(f"| `{os.path.basename(r['path'])}` | {r['kind']} | {r['ctx'] or '—'} "
                       f"| {r['disabled'] or '—'} | {r['lines']} | `{r['rt']}` | {r['status']} |\n")
        out.append("\n</details>\n")

open("docs/reference/script-inventory.md", "w", encoding="utf-8").write("".join(out))
print("script-inventory.md:", len(rows), "files;", dict(counts))
