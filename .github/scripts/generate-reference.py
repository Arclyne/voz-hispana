"""Regenera los inventarios de assets binarios y de remotes en docs/reference/.

Estas paginas son generadas, no escritas a mano: son un censo mecanico del
repositorio, y mantenerlas a mano garantizaria que se desincronicen. Vuelve a
ejecutar este script tras anadir, borrar o renombrar archivos, y commitea el
resultado.

Ejecutar desde la raiz del repositorio:
    python3 .github/scripts/generate-reference.py
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
title: Assets binarios
---

# Assets binarios

**No inspeccionables.** Estos archivos son modelos binarios de Roblox. Su contenido no se
puede leer desde este repositorio, y **nada en este sitio describe lo que hay dentro**. Se
listan para que quien lea sepa qué existe, dónde acaba en tiempo de ejecución, y qué huecos
de la documentación explican.

Si una página dice que no se ha encontrado un productor o un consumidor, uno de estos
archivos es el sitio más probable donde está.
""", f"\n**{total} archivos.**\n"]

out.append("""
## Los que más importan

| Archivo | Por qué importa |
|---|---|
| `src/StarterPlayer/StarterPlayerScripts.rbxm` | El sitio más probable del cargador de scripts del cliente y del emisor de `LoadCharacterRequest`. Explica [BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007). |
| `src/StarterPlayer/StarterCharacterScripts.rbxm` | Lo que se añade a cada personaje. Hace que [Ciclo de vida del Character](../architecture/character-lifecycle.md) esté incompleto por construcción. |
| `src/ReplicatedFirst/LoadingScreenUI.rbxm` | Lo primero que ve un cliente. |
| `src/StarterGui/ScreenGui.rbxm`, `src/StarterGui/BuildMenu.rbxm` | UI raíz, fuera de las plantillas. |
| `…/PlayerHouses/StarterGui/PermsGui.rbxm` | La UI de permisos de casa — la mitad cliente de [Casas → Permisos](../systems/housing/permissions.md). |
""")

for tmpl in sorted(bins):
    files = bins[tmpl]
    label = "Fuera de las plantillas" if tmpl == "(root)" else f"Plantilla `{tmpl}`"
    out.append(f"\n## {label}\n\n**{len(files)} archivos.**\n")
    groups = collections.defaultdict(list)
    for p, rt, size in files:
        groups[os.path.dirname(p)].append((os.path.basename(p), rt, size))
    for d in sorted(groups):
        out.append(f"\n<details>\n<summary><code>{d}/</code> — {len(groups[d])} archivo(s)</summary>\n\n")
        out.append("| Archivo | Ruta en ejecución | Tamaño |\n|---|---|---|\n")
        for name, rt, size in groups[d]:
            out.append(f"| `{name}` | `{rt}` | {size // 1024 or 1} KB |\n")
        out.append("\n</details>\n")

open("docs/reference/binary-assets.md", "w", encoding="utf-8").write("".join(out))
print("binary-assets.md:", total, "archivos")

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
title: Remotes y bindables
---

# Remotes y bindables

:::caution Este censo es un suelo, no un total

Cuenta lo **declarado** como `.model.json` de Rojo. Un sistema que cree sus remotes en
ejecución con `Instance.new` no aparece aquí. Se conoce al menos un caso:
[Trabajos](../systems/jobs.md#los-remotes-no-están-declarados-se-crean-en-ejecución) fabrica
cuatro `RemoteEvent` al arrancar el servidor, y su carpeta `Events/Jobs/` solo contiene un
`.gitkeep`.

:::

Todos los `RemoteEvent`, `RemoteFunction`, `BindableEvent` y `BindableFunction` declarados


en este repositorio, con la ruta del DataModel que ocupan en tiempo de ejecución.

Se **declaran como archivos `.model.json` de Rojo**, no se crean en código, así que esta
lista es completa para el código inspeccionable. Las instancias que crea un script en
ejecución —por ejemplo `TemplatesReady`, que `ImportTemplates` crea con `Instance.new`— se
anotan aparte al final.

Para qué se usan, ver [Arquitectura → Red](../architecture/networking.md).
"""]
out.append("\n| Clase | Cantidad |\n|---|---|\n")
for cn, n in by_cls.most_common():
    out.append(f"| `{cn}` | {n} |\n")

for cn, _ in by_cls.most_common():
    subset = sorted(r for r in rows if r[0] == cn)
    out.append(f"\n## {cn} ({len(subset)})\n\n| Ruta en ejecución | Plantilla |\n|---|---|\n")
    for _, tmpl, rt, _name in subset:
        out.append(f"| `{rt}` | {tmpl} |\n")

out.append("""
## Creados en ejecución, no declarados

| Nombre | Clase | Lo crea |
|---|---|---|
| `ReplicatedStorage.TemplatesReady` | `RemoteEvent` | `ImportTemplates.server.luau` |
| `ReplicatedStorage.TemplatesReadyFlag` | `BoolValue` | `ImportTemplates.server.luau` |
| `ReplicatedStorage.InitScriptsReadyFlag` | `BoolValue` | `InitScripts.server.luau` |
| `ReplicatedStorage.IsInEvent` | `Configuration` | `Core/StarterGui/LocalScript.client.luau`, si no existe |
""")
open("docs/reference/remotes.md", "w", encoding="utf-8").write("".join(out))
print("remotes.md:", len(rows), "declarados")
