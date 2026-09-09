#!/usr/bin/env python3
"""Comprueba que lo que la documentación afirma sobre el repositorio siga siendo cierto.

Este proyecto documenta un juego contando cosas: cuántos archivos hay, cuántos
remotes, cuántos candidatos a bug, cuántas clases anotadas. Esos números envejecen
en silencio, y un número equivocado en la documentación es peor que no tenerlo:
alguien lo usará para decidir.

Este script los vuelve a contar contra el árbol real y falla si no cuadran. Está
cableado en CI, así que la desviación se detecta al introducirla.

Comprueba además la estructura de cada entrada BUG-CANDIDATE: el encargo fijó un
formato, y una entrada sin plan de verificación o sin condición de fallo no sirve
para lo que se escribió.

    python3 .github/scripts/check-docs-facts.py
"""

import json
import os
import re
import sys

ROOT = "src"
PLAN = "docs/testing/verification-plan.md"
PROGRESS = "DOCS_PROGRESS.md"
CODE_DIRS = [
    "src/ReplicatedStorage",
    "src/ServerStorage/TemplatesTesting/Core/ServerStorage",
]

problems = []


def fail(msg):
    problems.append(msg)


def read(path):
    with open(path, encoding="utf-8") as handle:
        return handle.read()


def walk(suffix):
    out = []
    for dirpath, _, names in os.walk(ROOT):
        for name in names:
            if name.endswith(suffix):
                out.append(os.path.join(dirpath, name))
    return out


# ---------------------------------------------------------------- inventario

luau = walk(".luau")
rbxm = walk(".rbxm")

# Los remotes se declaran como .model.json de Rojo. Se cuentan las declaraciones,
# no los archivos: un archivo puede declarar varias instancias anidadas.
class_counts = {}


def count_classes(node):
    if isinstance(node, dict):
        name = node.get("ClassName")
        if isinstance(name, str):
            class_counts[name] = class_counts.get(name, 0) + 1
        for value in node.values():
            count_classes(value)
    elif isinstance(node, list):
        for value in node:
            count_classes(value)


for path in walk(".model.json"):
    try:
        count_classes(json.loads(read(path)))
    except (json.JSONDecodeError, OSError):
        fail(f"{path}: no se pudo leer como JSON")

disabled = 0
run_context = {}
for path in walk(".meta.json"):
    try:
        props = json.loads(read(path)).get("properties", {})
    except (json.JSONDecodeError, OSError):
        continue
    if props.get("Disabled"):
        disabled += 1
    ctx = props.get("RunContext")
    if ctx:
        run_context[ctx] = run_context.get(ctx, 0) + 1


# ------------------------------------------------------------------- clases

annotated = []
for directory in CODE_DIRS:
    for dirpath, _, names in os.walk(directory):
        for name in names:
            if name.endswith(".luau"):
                for match in re.finditer(r"@class\s+(\S+)", read(os.path.join(dirpath, name))):
                    annotated.append(match.group(1))

duplicates = {name for name in annotated if annotated.count(name) > 1}
if duplicates:
    fail(
        "Nombres de @class duplicados dentro del alcance de Moonwave: "
        + ", ".join(sorted(duplicates))
        + ". El extractor aborta el build entero por esto."
    )

# classOrder de moonwave.toml tiene que nombrar clases que existen, y no dejarse
# ninguna: las dos direcciones rompen o degradan el sitio.
ordered = re.findall(r'^\s*"([^"]+)",?\s*$', read("moonwave.toml"), re.M)
ordered += re.findall(r'classes\s*=\s*\[([^\]]*)\]', read("moonwave.toml"))
ordered = set(re.findall(r'"([^"]+)"', " ".join(ordered)))

missing = ordered - set(annotated)
if missing:
    fail(
        "moonwave.toml nombra en classOrder clases que no existen: "
        + ", ".join(sorted(missing))
        + ". Esto rompe el build para todo el mundo."
    )

unlisted = set(annotated) - ordered
if unlisted:
    fail(
        "Hay clases anotadas que classOrder no menciona: "
        + ", ".join(sorted(unlisted))
        + ". Añádelas a moonwave.toml o no aparecerán agrupadas."
    )


# -------------------------------------------------------- candidatos a bug

plan = read(PLAN)
ids = re.findall(r"^## BUG-CANDIDATE-(\d+)", plan, re.M)

expected = [f"{n:03d}" for n in range(1, len(ids) + 1)]
if ids != expected:
    fail(f"Los BUG-CANDIDATE no son consecutivos desde 001: {ids}")

index_rows = re.findall(r"^\| \[(\d+)\]\(#bug-candidate-\d+\)", plan, re.M)
index_main = []
for row in index_rows:
    if row in index_main:
        continue
    index_main.append(row)
if sorted(set(index_main)) != sorted(set(ids)):
    fail(
        "El índice de candidatos no coincide con las entradas: "
        f"índice {sorted(set(index_main))} vs entradas {sorted(set(ids))}"
    )

# Cada entrada tiene que traer lo que el encargo pidió.
sections = re.split(r"^## BUG-CANDIDATE-", plan, flags=re.M)[1:]
REQUIRED = [
    ("**Sistema:**", "sistema"),
    ("**Clasificación:**", "clasificación"),
    ("**Estado:**", "estado de verificación"),
    ("#### Plan de verificación", "plan de verificación"),
    ("**Pasa:**", "condición de paso"),
    ("**Falla:**", "condición de fallo"),
]
for section in sections:
    ident = section.split("\n", 1)[0].strip()
    for needle, label in REQUIRED:
        if needle not in section:
            fail(f"BUG-CANDIDATE-{ident} no tiene {label} ({needle})")


# -------------------------------------------- números afirmados en las páginas

progress = read(PROGRESS)
diagrams = sum(
    read(os.path.join(dirpath, name)).count("```mermaid")
    for dirpath, _, names in os.walk("docs")
    for name in names
    if name.endswith(".md")
)

CLAIMS = [
    (progress, rf"\*\*{len(luau)} archivos `\.luau`", f"{len(luau)} archivos .luau"),
    (progress, rf"\| `\.luau` \| {len(luau)} \|", f"tabla de inventario: {len(luau)} .luau"),
    (progress, rf"\| `\.rbxm`[^|]*\| {len(rbxm)} \|", f"tabla de inventario: {len(rbxm)} .rbxm"),
    (progress, rf"\*\*{disabled} de ellos ponen `Disabled: true`", f"{disabled} scripts desactivados"),
    (progress, rf"\*\*Diagramas:\*\* {diagrams} diagramas", f"{diagrams} diagramas"),
    (progress, rf"\*\*Candidatos a bug:\*\* {len(ids)} ", f"{len(ids)} candidatos"),
    (progress, rf"\*\*creado\*\*, {len(ids)} entradas", f"{len(ids)} entradas del plan citadas en DOCS_PROGRESS"),
]
for haystack, pattern, label in CLAIMS:
    if not re.search(pattern, haystack):
        fail(f"Un número afirmado ya no cuadra con el repositorio: {label}")

# La tabla de estado de DOCS_PROGRESS se lleva a mano y se ha desviado ya dos
# veces respecto al inventario generado. Se contrasta contra el inventario, que
# es la fuente de verdad porque lo produce un script.
inventory = read("docs/reference/script-inventory.md")
STATUS_ROWS = [
    ("**Documentado**", r"\| \*\*Documentado\*\* \| [^|]+ \| (\d+) \|"),
    ("Analizado", r"\| Analizado \| [^|]+ \| (\d+) \|"),
    ("Analizado (en parte)", r"\| Analizado \(en parte\) \| [^|]+ \| (\d+) \|"),
    ("Pendiente", r"\| Pendiente \| [^|]+ \| (\d+) \|"),
]
PROGRESS_ROWS = [
    ("**Documentado**", r"\| \*\*Documentado\*\*[^|]*\| (\d+) \|"),
    ("Analizado", r"\| Analizado \(leído entero[^|]*\| (\d+) \|"),
    ("Analizado (en parte)", r"\| Analizado \(en parte\) \| (\d+) \|"),
    ("Pendiente", r"\| Pendiente \| (\d+) \|"),
]
for (label, inv_pat), (_, prog_pat) in zip(STATUS_ROWS, PROGRESS_ROWS):
    inv_m = re.search(inv_pat, inventory)
    prog_m = re.search(prog_pat, progress)
    if not inv_m:
        fail(f"No se pudo leer «{label}» del inventario generado")
    elif not prog_m:
        fail(f"No se pudo leer «{label}» de DOCS_PROGRESS")
    elif inv_m.group(1) != prog_m.group(1):
        fail(
            f"DOCS_PROGRESS dice {prog_m.group(1)} para «{label}» y el inventario "
            f"generado dice {inv_m.group(1)}. Regenera el inventario y copia sus cifras."
        )

for cls, count in sorted(class_counts.items()):
    if cls in ("RemoteEvent", "RemoteFunction", "BindableEvent", "BindableFunction"):
        if not re.search(rf"\| `{cls}` \| {count} \|", progress):
            fail(f"DOCS_PROGRESS no dice {count} para {cls}")


# ------------------------------------------------------------------ informe

print(
    f"Contados: {len(luau)} .luau, {len(rbxm)} .rbxm, {disabled} desactivados, "
    f"{len(annotated)} clases anotadas, {len(ids)} candidatos, {diagrams} diagramas."
)
print("RunContext: " + ", ".join(f"{k}={v}" for k, v in sorted(run_context.items())))

if problems:
    print("\nIncoherencias:\n")
    for problem in problems:
        print(f"  {problem}")
    sys.exit(1)

print("Todo lo que la documentación afirma sigue cuadrando. OK.")
