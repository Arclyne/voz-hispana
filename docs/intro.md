---
sidebar_position: 1
title: Introducción
---

# Voz Hispana — Documentación de ingeniería

Este sitio documenta el proyecto Voz Hispana **tal y como está escrito**, no como podría
estar diseñado idealmente. Cada afirmación se deriva del código de este repositorio.
Donde el código no basta para resolver una duda, la página lo dice explícitamente en vez
de rellenar el hueco.

## Cómo leer este sitio

La documentación está por capas. Cada una acota el alcance de la anterior:

```
PROYECTO  →  ARQUITECTURA  →  CICLOS DE VIDA  →  SISTEMAS  →  FLUJOS  →  SCRIPTS  →  MÓDULOS  →  FUNCIONES
```

| Capa | Sección |
|---|---|
| Arquitectura y ciclos de vida | **Arquitectura** |
| Sistemas y sus flujos | **Sistemas** |
| Referencia por script y por asset | **Referencia** |
| APIs públicas de los módulos | **Referencia de API** (Moonwave, extraída de los comentarios del código) |
| Defectos sospechados y cómo probarlos | **Verificación** |

Usa la barra lateral para navegar; las secciones aparecen ahí a medida que se escriben.

:::note Qué cubre la Referencia de API

Moonwave la extrae de los comentarios `--[=[ ]=]` del código Luau, pero **no de todos**.
Está acotada a `ReplicatedStorage` y a
`ServerStorage/TemplatesTesting/Core/ServerStorage` — las rutas que hoy tienen clases
anotadas: `PlayerInit`, `ServerPresence` y el paquete `DataKit`.

Buena parte de `Core/ReplicatedStorage` es anterior a este proyecto y usa líneas `---`
como separadores visuales, que el extractor de Moonwave lee como comentarios de
documentación mal formados y se niega a compilar. Meter esos archivos supondría editar
comentarios en unos quince ficheros —varios de ellos librerías de terceros—, un cambio
mayor que la documentación que desbloquearía. El alcance se amplía a medida que se
documentan más sistemas.

Todo lo que queda fuera sigue cubierto por la documentación conceptual; simplemente no
tiene página de API generada.

:::

## Qué es este proyecto, estructuralmente

Voz Hispana **no** es un único place de Roblox con un único árbol de scripts. Hay tres
hechos que condicionan todo lo demás:

1. **El código versionado es en su mayoría un conjunto de *plantillas*, no el juego en
   marcha.** `src/ServerScriptService/ImportTemplates.server.luau` descarga en tiempo de
   ejecución tres assets publicados de Roblox con `InsertService:LoadAsset` y los fusiona
   dentro de los servicios vivos. Lo que hay bajo `src/ServerStorage/TemplatesTesting/`
   son *overrides locales* de esos assets, que se usan en lugar de las versiones
   publicadas cuando existen. Ver **Arquitectura → Inicialización**.

2. **La mayoría de los scripts se distribuyen desactivados y se encienden después de la
   importación.** 104 de los 170 archivos `.meta.json` ponen `Disabled: true`.
   `src/ServerScriptService/InitScripts.server.luau` recorre el DataModel cuando las
   plantillas ya han llegado y los reactiva.

3. **El juego abarca varios places.** La casa de un jugador corre en un *servidor
   reservado* de otro `PlaceId` (declarado en `ReplicatedStorage/HousesInfo`), al que se
   llega con `TeleportService`. El lobby, el karaoke, el arcade y el place de donaciones
   son `PlaceId` distintos también. Ver [Casas](./systems/housing/overview.md).

Por (1), quien solo haga grep en `src/` se equivocará sobre qué corre dónde. Por (2), el
sufijo del archivo no dice si un script está activado — ni siquiera si corre en el
cliente. **Arquitectura → Inicialización** explica las reglas que aplican de verdad.

## Convenciones usadas en todo el sitio

Las afirmaciones van etiquetadas para que se sepa siempre cuánto peso tienen:

| Etiqueta | Significado |
|---|---|
| **HECHO** | Visible directamente en el código de este repositorio. |
| **INFERENCIA** | Conclusión razonable a partir de varias partes del código. |
| **TEORÍA** | Hipótesis sobre el comportamiento en ejecución que la lectura estática no puede resolver. |
| **DESCONOCIDO** | No se puede determinar en absoluto con el código disponible. |

Los defectos sospechados nunca se llaman bugs. Se registran como entradas
`BUG-CANDIDATE-XXX` con su clasificación, la evidencia que las sostiene, lo que sigue sin
saberse, y un plan reproducible para confirmarlas o descartarlas. Ver **Verificación**.

## Lo que no es inspeccionable desde este repositorio

320 archivos `.rbxm` son binarios y su contenido no se puede leer. Varios importan mucho
—en particular `src/StarterPlayer/StarterPlayerScripts.rbxm` y
`src/StarterPlayer/StarterCharacterScripts.rbxm`, que podrían contener los puntos de
entrada reales del cliente. Las páginas que dependen de ellos declaran el hueco en vez de
rellenarlo. La lista completa está en [Assets binarios](./reference/binary-assets.md).
