---
sidebar_position: 21
title: Interactuables — catálogo de tipos
---

# Interactuables — catálogo de tipos

Los 44 módulos de cliente de `ReplicatedStorage/Client/interactable/` (5 675 líneas). Uno por
tipo de objeto con el que se puede interactuar: camas, neveras, duchas, tiendas, pianos.

La **estructura** —el registrador, la clase base, la rueda de acciones y la matriz de
validación del servidor— está en [Interactuables](./interactables.md). Esta página es el
catálogo: qué hay, qué hace cada uno y por dónde sale al servidor.

## Ninguno de estos archivos tiene autoridad

**HECHO.** Son código de cliente, sin excepción. Lo que hacen es siempre lo mismo:

1. Heredar de `Interactable`.
2. Colocar un `ProximityPrompt` y una caja de clic sobre el modelo.
3. Añadir acciones a la rueda.
4. Al pulsar una, **disparar un remote** o llamar a una fachada de `Shared/`.

Es decir: **la seguridad de un interactuable no está en su archivo de cliente**, sino en el
manejador de servidor que recibe el remote. Esa es la
[matriz de validación](./interactables.md#la-matriz-de-validación), y ahí es donde hay que
mirar cuando la pregunta es «¿puede un jugador hacer trampa con esto?».

Por eso este catálogo lista los remotes de cada tipo: no para juzgarlo aquí, sino para poder
saltar de un objeto del mundo al manejador que lo valida.

## El registrador

**HECHO.** `init.server.luau` es de 20 líneas y hace de todo el registro:

```lua
for _, child in script:GetChildren() do
	if not child:IsA("ModuleScript") then continue end
	local module = require(child)
	bindToTag(child.Name, function(instance)
		local object = module.new(instance)
		return typeof(object.onDestroy) == "function" and function()
			object:onDestroy()
		end
	end)
end
```

**El nombre del archivo *es* la etiqueta.** No hay tabla intermedia: renombrar `Fridge.luau`
rompe todas las neveras del juego, y añadir un archivo nuevo crea un tipo nuevo sin tocar
nada más.

**Registrado como correcto.** El `onDestroy` opcional se devuelve como función de limpieza a
`bindToTag`, así que un tipo que necesite deshacer algo lo declara y ya está; el que no, no
paga nada.

**HECHO.** `init.meta.json` marca este script `Disabled = true`, y vive dentro de
`ReplicatedStorage/Client`, que `InitScripts.server.luau` **excluye explícitamente** de su
pasada de activación. Quien lo enciende no está en este repositorio: es
[BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007).

## El catálogo

**HECHO.** Extraído de los propios archivos: las acciones son las cadenas que se pasan a
`addAction` y `setQuickAction`; los remotes, los que el módulo dispara.

| Tipo (= etiqueta) | Acciones de la rueda | Sale al servidor por | Servidor propio |
|---|---|---|---|
| `BarraBartender` | Pedir, Preparar, Replenish, Cancelar, Work, Renunciar | `Shared/BartenderSystem` | Sí |
| `Bath` | Bañarse | `Interactable/Bath` | Sí |
| `Bed` | Dormir, Tender | `Interactable/Bed` | Sí |
| `Bin` | Arrojar | `Interactable/Bin` | Sí |
| `ButtonVipMoney` | Soltar | `Shared/JobSystem` | No — va por [Trabajos](./jobs.md) |
| `CajasWork` | Obtener | `Shared/JobSystem` | No |
| `Chair` | Sentarse | `Interactable/Sit` | Sí (`Seat.server.luau`) |
| `ClassicDoor` | — | `Interactable/ClassicDoor` | Sí |
| `Computer` | **Proximamente** | — | No |
| `CuadrosPaint` | — | — | Sí |
| `DiscoBall` | Encender, Apagar | `Interactable/DiscoBall` | Sí |
| `Display` | Encender, Apagar, KARAOKE, YouBlox | `Interactable/Display` | Sí |
| `DoorSalaKaraoke` | Open, Knok, Rent, Vacate | `Interactable/salaKaraoke` | No — va por [Karaoke](./karaoke.md) |
| `DoubleBed` | Dormir, Tender | `Interactable/DoubleBed` | Sí |
| `Fridge` | Abrir, Cerrar | `Interactable/Fridge` | Sí |
| `IdleToggle` | Activar, Desactivar | — | No |
| `Interruptor` | Encender, Color | **`Interactable/Lamp`** | Comparte el de `Lamp` |
| `Lamp` | Encender, Color | `Interactable/Lamp` | Sí |
| `MusicPlayer` | Custom ID | `Interactable/MusicPlayer` | Sí |
| `NightClub` | Claim, Open, Unclaim | `Shared/Stores` | No |
| `NpcDialog` | — | `Interactable/FocusNpcDialog` | Sí — ver [Bar y NPC](./bar-npcs.md) |
| `Paint` | Paint, Purchase, Dar Like | `Shared/Paint` | Sí — ver [Cuadros](./paint.md) |
| `Pee` | — | `Interactable/Pee` | Sí |
| `Piano` | Custom ID | **`Interactable/MusicPlayer`** | Comparte el de `MusicPlayer` |
| `PlaceTool` | Colocar | `Interactable/PlaceTool` | `ToolPlacementServer` |
| `Player/Tijeras` | Cortar | `Interactable/StartCut`, `CancellCut`, `EndCut` | Sí |
| `Player/init` | Donar, Regalar, Ajustar Volumen | `Data/Main` | No |
| `PurchaseGamepass` | Purchase / Editar | `Shared/Stores` | No |
| `QuestPickable` | Recoger | `Shared/Quests` | No — ver [Barrido](./survey.md) |
| `Shower` | Ducharse | `Interactable/Shower` | Sí |
| `SmokeMachine` | Encender, Apagar | `Interactable/SmokeMachine` | Sí |
| `Stores` | Reclamar | `Shared/Stores` | No — ver [Tiendas](./stores.md) |
| `Toilet` | Usar | `Interactable/Toilet` | Sí |
| `ToolInteractable` | Recoger, Abrir, Coger porción, Dejar porción | `PickupTool`, `OpenFoodContainer`, `TakeFoodServing`, `ReturnFoodServing` | `ToolsServer` |
| `Treadmill` | Correr | `Interactable/Treadmill` | Sí |
| `Washbasin` | Lavar manos, Lavar dientes | `Interactable/WashHands`, `WashTeeth` | Sí |
| `Weight` | — | `Interactable/Weight` | Sí |
| `test` | Dormir | **ninguno** | No |

Y seis archivos que no son tipos: `Interactable/init`, `Interactable/ActionWheel/` (3),
`Interactable/CustomPrompt/`, `Display/VideoPlayer`, `Display/Videos` y
`DiscoBall/Laser.server` son la infraestructura compartida.

**HECHO.** 21 de los 44 tipos tienen un script de servidor propio en
`ServerScripts/interactable/`. Los otros 23 salen por sistemas mayores —`Stores`,
`JobSystem`, `Karaoke`, `Paint`, `Quests`, `ToolsServer`, `ToolPlacementServer`— o no salen.

## Dos tipos que comparten el remote de otro

**HECHO.** `Interruptor` dispara `Interactable/Lamp`, e `Interruptor` no tiene script de
servidor propio: lo atiende `Lamp.server.luau`. Igual `Piano` con
`Interactable/MusicPlayer`.

**Por qué importa.** `MusicPlayer` es el sujeto de
[BUG-CANDIDATE-024](../testing/verification-plan.md#bug-candidate-024) —reproduce el audio
que le diga el cliente, en el modelo que le diga el cliente—. Que `Piano` use el mismo
remote significa que ese candidato tiene **dos puntos de entrada en la interfaz**, no uno, y
que una prueba que solo mire los reproductores de música no lo cubre entero.

No cambia la gravedad del 024 —quien explota un remote no necesita interfaz— pero sí el plan
de verificación: hay que probar los dos.

## `PlaceTool`, el candidato 023 en tres líneas

**HECHO.** Es el ejemplo más limpio de lo que registra
[BUG-CANDIDATE-023](../testing/verification-plan.md#bug-candidate-023):

```lua
function PlaceTool:place()
	local toolName = self.instance:GetAttribute("ToolName")
	local position = self.instance.Position
	local rotY = self.instance:GetAttribute("SurfaceRotY")
	remotes.PlaceTool:FireServer(toolName, position, rotY, self.ParentObject)
	self:onDestroy()
end
```

La posición y la rotación **las calcula el cliente y las manda**. El bloque invisible del que
salen lo creó el propio cliente al pulsar sobre una superficie. Nada de eso es un ataque en
sí: es la forma normal de este juego. Lo que decide si hay problema es qué comprueba
`ToolPlacementServer` al recibirlo, y eso está en [Inventario](./inventory.md).

## Observaciones registradas

**OBSERVACIÓN — `test.luau`.** Un archivo llamado `test` es, por la regla del registrador,
una **etiqueta viva**: cualquier modelo etiquetado `test` recibe este módulo. Es una copia
recortada de `Bed.luau` —mismo esqueleto, misma acción «Dormir»— a la que le falta todo lo
que hace funcionar una cama: no busca el `Seat`, no tiene el estado global
`isSleepingOrBusy`, no tiene enfriamiento y **no dispara ningún remote**. Lo único que hace
es una barra de 7 segundos y un `print("termiando")`.

No hace daño: sin remote, no llega nada al servidor. Pero es código de pruebas publicado, y
ocupa un nombre de etiqueta que alguien podría querer usar. Se anota y **no se borra**: este
proyecto documenta.

**OBSERVACIÓN — `Computer.luau`.** Diecinueve líneas. Hereda de `Display`, añade una página
«Juegos» con una sola acción, «Proximamente», cuyo cuerpo es `print("...")`. Es un marcador
de sitio consciente, no un olvido.

**OBSERVACIÓN — `Fridge.luau`, 718 líneas.** Es, con diferencia, el tipo más grande: más que
la clase base (437) y casi tres veces el siguiente. Dispara un solo remote, una sola vez, en
la línea 372. Las otras 700 líneas son la coreografía de abrir la nevera, mostrar su
contenido y elegir. No se ha leído entero: la pregunta que este proyecto tiene abierta sobre
las neveras es qué valida `Fridge.server.luau`, y eso ya está en la matriz.

## Qué queda por leer

| Grupo | Estado |
|---|---|
| Los 44 módulos: acciones, remotes y a qué sistema salen | **Leído** — es lo que sostiene la tabla de arriba |
| `Fridge`, `DoubleBed`, `Bed`, `Shower`, `Treadmill`… por dentro | **En parte, a propósito** — son coreografía de cliente |
| `Interactable/init.luau` (437), `ActionWheel/` (489), `CustomPrompt/` (128) | **En parte** — su papel, no su implementación |
| `DiscoBall/Laser.server.luau` | **Pendiente** — corre en un `Actor`, etiquetado `IgnoreAutoEnable` |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Registro por nombre de archivo | `Client/interactable/init.server.luau`; `Shared/bindToTag.luau` |
| Clase base y rueda | `Client/interactable/Interactable/` |
| Validación (servidor) | `ServerScripts/interactable/` — ver [Interactuables](./interactables.md) |
| Activación del registrador | Fuera de este repositorio — ver [BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007) |
