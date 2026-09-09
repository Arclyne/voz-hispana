---
sidebar_position: 26
title: Interfaz de construcción
---

# Interfaz de construcción

`BuildingSystem/ReplicatedStorage/BuildInterface/` (2 749 líneas en 8 archivos) es el modo
construcción: el catálogo de muebles, el selector de color, el inventario de piezas y el
arrastrar-y-soltar.

**Es el módulo de interfaz más grande del repositorio** —más que `Icon`, más que
`ConstructionModeModule/MoveAndPlaceent` solo ya suma 1 065 líneas— y a la vez el que menos
autoridad tiene.

## No tiene ni un remote

**HECHO.** Se buscó en los ocho archivos: no hay un `FireServer`, ni un `InvokeServer`, ni un
`OnClientEvent`. Todo lo que sale al servidor sale **a través de `Shared/Stores`**:

```lua
local Store = self.serv.Stores:GetStore(self.serv.Player)
...
self.serv.Stores.AddedDecor.Added.verificarExistencia(self.DataS.Data.Name)
...
self.serv.Stores.DecorsPlayer:GetCountBuilds()
```

Eso ya lo establecía el [barrido](./survey.md); esta página lo confirma leyendo los archivos y
dice qué hace con esa conexión.

**Consecuencia práctica:** las preguntas de seguridad del modo construcción **no se responden
aquí**. Se responden en [Tiendas](./stores.md), que es donde se cobra, se valida y se
persiste. Esta interfaz solo decide qué se enseña.

## Las piezas

| Archivo | Líneas | Qué hace |
|---|---|---|
| `MoveAndPlaceent/init.luau` | 1 065 | Arrastrar, rotar, encajar y fusionar el mueble en el mundo |
| `Main/DesingFrame/init.luau` | 494 | Diseños de sala y sus previsualizaciones |
| `Main/FurnitureFrame/init.luau` | 325 | El catálogo: ficha, precios, bloqueo por nivel |
| `Color/init.luau` | 291 | La rueda de color |
| `Main/init.luau` | 201 | El contenedor de las secciones |
| `Main/Inventory/init.luau` | 180 | Lo que el jugador ya tiene colocado |
| `init.luau` | 151 | Entrada, apertura, cierre y el contador de construcciones |
| `ColorFormat.luau` | 42 | HSV ↔ hex ↔ coordenadas de la rueda |

**Registrado como correcto — el tope de construcciones.** `UpdateCountBuilds` recuenta lo
colocado y lo compara contra `MaxBuildPlace`, pero **la interfaz solo lo muestra**: quien
impide pasarse es `Shared/Stores`. Ver
[Tiendas → Controles económicos](./stores.md#controles-económicos-que-sí-sujetan).

**Registrado como correcto — la salida.** El modo se cierra solo en dos casos que importan:
si cambia el dueño de la tienda (`OwnerChanged`) y si el botón que lo abrió se deshabilita.
Un jugador no se queda construyendo en un sitio que ha dejado de ser suyo.

## El precio y el nivel

**HECHO.** El catálogo lee `setting.Price`, que es la tabla del `Settings` de cada mueble
—la misma de la que habla
[BUG-CANDIDATE-047](../testing/verification-plan.md#bug-candidate-047)—, y pinta un icono por
moneda:

```lua
for nameCoin, Price in setting.Price do
	cloneCoin.Price.Text = tostring(Price)
```

**Registrado como correcto.** Ese precio es solo lo que se muestra. Quien cobra es
`self.Cobros.charge(Player, Data.Price, true)` en el servidor, con el precio que el servidor
lee del mismo `Settings`. Que el cliente pinte otro número no cambia nada.

**Pero el nivel es otra cosa:**

```lua
data.GUI.Button.Lock.Visible = data.setting.Price.Level
	and data.setting.Price.Level>tonumber(self.LevelPlayer.Value)
```

`Price.Level` aparece **solo aquí**, en toda la base de código. Queda registrado como
[BUG-CANDIDATE-051](../testing/verification-plan.md#bug-candidate-051).

## Observaciones registradas

**OBSERVACIÓN — la cadena de `self`.** El idioma de este módulo es que cada submódulo guarda
una referencia a su padre en `self.self`, y el catálogo llega a escribir
`self.self.self.serv.InfoCoins`. Funciona y es consistente, pero significa que para saber qué
es `serv` hay que subir tres niveles a mano. No es un defecto; es lo que hace que estas 2 749
líneas cuesten más de leer de lo que deberían.

**OBSERVACIÓN — `ColorFormat.HexToColor3` no valida el rango.** Limpia la cadena, exige seis
caracteres y devuelve blanco si no cuadran. Correcto. Es el único archivo del módulo con
entrada de texto, y la trata bien.

## Qué queda por leer

| Archivo | Estado |
|---|---|
| `init.luau`, `ColorFormat.luau` | **Leídos** |
| `Main/FurnitureFrame/init.luau` | **En parte** — la ficha, el precio y el bloqueo por nivel |
| `MoveAndPlaceent`, `DesingFrame`, `Color`, `Main`, `Inventory` | **Superficie** — su papel y que no tienen remotes |

La decisión de no leer los otros cinco por dentro es deliberada y del mismo tipo que con
[las utilidades de interfaz](./shared-utilities.md#las-de-interfaz): son 2 200 líneas de
arrastrar y pintar cuyo comportamiento se ve mirando la pantalla, y ninguna pregunta abierta
de este proyecto vive ahí.

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Entrada al modo | `ConstructionModeModule/init.luau`, `Start`, `OpenFrame` |
| Catálogo y precios | `ConstructionModeModule/Main/FurnitureFrame/init.luau` |
| Colocación | `ConstructionModeModule/MoveAndPlaceent/init.luau` |
| Lo que sí valida | `Shared/Stores/` — ver [Tiendas](./stores.md) |
| Ajustes por mueble | El `Settings` de cada modelo — ver [BUG-CANDIDATE-047](../testing/verification-plan.md#bug-candidate-047) |
