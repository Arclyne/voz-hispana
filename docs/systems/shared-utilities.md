---
sidebar_position: 20
title: Utilidades compartidas
---

# Utilidades compartidas

Los 44 archivos sueltos de `ReplicatedStorage/Shared/` (6 200 líneas). No son un sistema:
son la caja de herramientas de la que tiran los demás. Esta página los clasifica, dice quién
usa cada uno, y separa lo que sujeta comportamiento de lo que solo pinta.

Las **carpetas** de `Shared/` —`Karaoke`, `Stores`, `Paint`, `JobSystem`, `Monetization`,
`BartenderSystem`…— tienen su propia página cada una. Aquí solo están los archivos sueltos.

## Cómo se leyó esto

**HECHO.** El recuento de consumidores de cada archivo sale de buscar su nombre en los 552
`.luau` del repositorio. **Ese recuento es un suelo, no un total**: hay 320 archivos `.rbxm`
—modelos binarios de Roblox— que pueden contener `LocalScript` con `require`, y su código
fuente va comprimido dentro, así que una búsqueda de texto no lo ve. Un acierto prueba que
se usa; un fallo **no prueba** que no.

Es el mismo aviso que lleva el [censo de remotes](../reference/remotes.md).

## De terceros, no del proyecto

**HECHO.** Cuatro de estos archivos son librerías conocidas, con su licencia dentro:

| Archivo | Líneas | Qué es | Consumidores |
|---|---|---|---|
| `Trove.luau` | 612 | Contenedor de limpieza de Sleitnick — `Add`, `Clean`, `Extend` | 16 |
| `Signal.luau` | 432 | La señal *batched yield-safe* de stravant, MIT | 14 |
| `Spring.luau` | 31 | Muelle crítico, `K` / masa / amortiguación | 2 |
| `lerp.luau` | 5 | Interpolación lineal con `math.clamp` | 3 |

No se documentan por dentro, por la misma razón que
[DataKit](../architecture/datakit.md): tienen su documentación aguas arriba. Las carpetas
`Promise`, `Sift`, `Icon`, `Kinetic`, `FastCastRedux`, `Observers` y `PartCache` reciben el
mismo trato, y su mapa de dependencias está en
[Librerías de terceros](../architecture/third-party.md).

## Las que sujetan comportamiento

Estas cinco no son adorno: si fallan, algo del juego deja de funcionar.

### `Running.luau` — el bucle compartido

**HECHO.** Una única lista de funciones por fotograma, con enfriamiento por entrada.
`Heartbeat` en el servidor, `RenderStepped` en el cliente. Se conecta al añadir la primera
función y **se desconecta sola** cuando la lista queda vacía.

**Registrado como correcto.** Ese desconectar-al-vaciarse es lo que evita que un bucle por
fotograma quede corriendo en vacío toda la sesión. Lo usan `ComprasTablero`, `AreaSystem` y
tres más.

**Pero el manejo de errores no hace lo que parece.** Queda registrado como
[BUG-CANDIDATE-041](../testing/verification-plan.md#bug-candidate-041).

### `SignalsGame.luau` — el bus por nombre

**HECHO.** Un diccionario de señales creadas bajo demanda:

```lua
function module.Set(_, key)
	OnlyString(key)
	local event = module:Get(key)
	if not event then
		event = EventCustom.new()
		DatasSignals[key] = event
	end
	return event
end
```

**Registrado como correcto.** `OnlyString` es un `assert`, y `OnEvent` exige que la acción
sea función. Es un bus **interno**: `EventCustom` no es un `RemoteEvent`, así que nada de
esto cruza la red y una clave no puede venir de un cliente.

**OBSERVACIÓN.** Las señales se crean y **no se destruyen nunca**. `DatasSignals` solo
crece. Con claves fijas escritas en el código eso es un número acotado; con claves generadas
—por jugador, por objeto— sería una fuga. No se ha encontrado ningún uso del segundo tipo,
pero la forma lo permite.

### `SoundManager.luau` — el reproductor común

**HECHO.** El archivo con más consumidores de todo `Shared` (24). Reproduce por
`PlayLocalSound` para un jugador o para todos, o parenta un `Sound` a una pieza del mundo,
con caché y precarga por `ContentProvider`. Su propio encabezado documenta las tres formas.

**OBSERVACIÓN.** Su documentación interna dice
`require(RS:WaitForChild("SoundManager"))` —directamente bajo `ReplicatedStorage`— y el
archivo vive en `ReplicatedStorage/Shared/`. El ejemplo del comentario está desfasado
respecto a dónde está el archivo. Es documentación, no código: no rompe nada, pero manda a
quien lo lea a la ruta equivocada.

### `Commands.luau` — los comandos de chat

**HECHO.** Traduce `/crearcancion`, `/canciones`, `/revisarcanciones`, `/reportes`,
`/musicasbaneadas`… a un número, y ese número viaja al cliente para que abra el panel
correspondiente. Tres de los comandos están marcados `IsWihAdmin`, y uno además
`SuperAdmin`.

```lua
if not Commands.IsWihAdmin or self.AdminPanel:IsAdmin(player, Commands.SuperAdmin) then
	return Commands.typee
end
```

**Registrado como correcto** en la ruta de chat: un comando de administración escrito por un
jugador normal no devuelve nada.

**Pero hay una segunda ruta.** El manejador del remote es este, entero:

```lua
self.Event.OnServerEvent:Connect(function(Player:Player, number, option)
	if typeof(number)=="number" then
		self:Fire(Player, number, option)
	end
end)
```

Comprueba que sea un número y lo devuelve al mismo jugador. **No vuelve a pasar por
`IsAdmin`.** Queda registrado como
[BUG-CANDIDATE-042](../testing/verification-plan.md#bug-candidate-042).

**HECHO.** Los números 6 a 9 están **reservados por comentario** y no implementados:

```lua
--//el 6 ya está reservado para seleccionar los diseños de las tiendas
--//el 7 ya está reservado para el alquiler de las salas del karaoke
--//el 8 ya está reservado para la compra de los diseños de las salas del karaoke
--//el 9 ya está reservado para el uso de el bar
```

### `AreaSystem.luau` — quién está dentro de qué

**HECHO.** Registra piezas y avisa cuando un jugador entra o sale. Se apoya en `Running`
para el sondeo. Su único consumidor encontrado es el televisor de karaoke
(`KaraokeTV/TV/init.luau`), para saber quién está en la sala. Ver
[Karaoke](./karaoke.md).

## Las de interfaz

**HECHO.** No tocan datos ni red. Se listan para que consten, no para desmenuzarlas: su
comportamiento se ve mirando la pantalla, y leerlas línea a línea no responde ninguna
pregunta que este proyecto tenga abierta.

| Archivo | Líneas | Qué hace |
|---|---|---|
| `CardSlots.luau` | 477 | Envuelve cada tarjeta de la tablet en un *slot* para que el `UIListLayout` ordene el slot y la tarjeta pueda moverse y crecer. **Lleva 40 líneas de documentación propia** explicando el porqué |
| `ButtonMotion.luau` | 420 | Animación de pulsación de botones |
| `ShopHighlight.luau` | 377 | Resalta una tarjeta de la tienda: desplaza hasta ella, contorno dorado y tres brincos decrecientes. Usa `CardSlots.lift` |
| `Carousel.luau` | 354 | Carrusel horizontal |
| `AnimationButtons.luau` | 299 | Catálogo de animaciones para `ButtonMotion` |
| `SellHousePrompt.luau` | 289 | El diálogo de vender la casa — ver [Casas](./housing/overview.md) |
| `SmoothShiftLock.luau` | 231 | Bloqueo de hombro suavizado |
| `MovedScrollButton.luau` | 222 | Arrastre dentro de un `ScrollingFrame` |
| `SizeManager.luau` | 164 | Escalado de interfaz |
| `UpdatingCountText.luau` | 135 | Contador que sube o baja animado |
| `RutaCreate.luau` | 135 | Trazado de rutas en pantalla |
| `AdjustBoxFrame.luau` | 130 | Ajuste de marcos |
| `GuiScaleManager.luau` | 105 | `UIScale` según resolución |
| `InputPlayer.luau` | 85 | Entrada de texto; lo usa `PrompBuy` |
| `promptText.luau` | 53 | Un `Prompt` de `PlayerGui` con aceptar y cancelar |
| `textScaler.luau` | 34 | Tamaño de texto según caja |
| `showExitButton.luau` | 33 | Botón de salida |
| `PrettyPrint.luau` | 34 | Volcado legible de tablas, para depurar |

## Las de mundo y física

| Archivo | Líneas | Qué hace | Nota |
|---|---|---|---|
| `ObjectCache.luau` | 174 | Reserva de piezas reutilizables | Lo usa el minijuego `Stacker` |
| `MovingPlayers.luau` | 97 | Mover al personaje sin control del jugador | Doble contexto |
| `basketUtil.luau` | 67 | La pelota de baloncesto: clon, `attach`, sonido | Ver [Barrido](./survey.md) |
| `CollisionModule.luau` | 62 | Caja envolvente en 2D (planta) de una pieza | Sin consumidor encontrado |
| `VoiceModulator.luau` | 70 | Cambia el tono de la voz insertando un `AudioPitchShifter` entre el `AudioFader` y el `AudioEmitter` | Ver [Nametags y micrófono](./nametags.md) |
| `makeClientPart.luau` | 37 | Clona una pieza del servidor para que solo el cliente la vea | `assert(RunService:IsClient())` |
| `attach.luau` | 6 | Un `WeldConstraint` | |
| `NetworkTimer.luau` | 41 | Reloj de 60 tics fijos sobre `Heartbeat` | |
| `Clock.luau` | 29 | Temporizador por intervalo | |
| `CircularBuffer.luau` | 26 | Búfer circular de 1 024 | |
| `bindToTag.luau` | 24 | Etiqueta de `CollectionService` → módulo. Ver [Interactuables](./interactables.md) | 8 consumidores |
| `KeyGenerator.luau` | 28 | Seis dígitos al azar, sin repetir dentro del proceso | Sin consumidor encontrado |
| `InfoCoins.luau` | 9 | Icono y color de `Coins` y `Gems` | |
| `AssetsToPreload.luau` | 13 | Lista de imágenes a precargar | Sin consumidor encontrado |

## Tres carpetas pequeñas que sí son de este proyecto

Además de los archivos sueltos, `Shared/` tiene tres carpetas que no dan para página propia
pero tampoco son de terceros.

### `Cooldown/` — enfriamientos persistentes

**HECHO.** Dos archivos, 131 líneas. `CooldownManager` es de servidor y su encabezado lo
dice en mayúsculas: «ESTE SCRIPT SOLO SE USA DESDE UN SERVIDOR PARA EVITAR EXPLOITS». Guarda
cada enfriamiento como un `IntValue` en una carpeta `Cooldowns` colgada del jugador.
`CooldownShared` calcula y formatea lo que queda, y se puede usar desde los dos lados.

**Registrado como correcto**, en tres puntos:

| Control | Cómo |
|---|---|
| El reloj es el del servidor | `workspace:GetServerTimeNow()`, no `os.time()` ni `tick()`: cambiar la hora del cliente no adelanta nada |
| Los enfriamientos **sobreviven a la reconexión** | `PlayerDataReplicator` los persiste (`key = "cooldowns"`, `kind = "folder"`) |
| Un valor corrupto no rompe el manejador | El `coerce` del SPEC es `math.floor(tonumber(value) or 0)`, con este comentario en el archivo: «CooldownManager asume IntValue; un Value corrupto crearia un StringValue» |

Ese tercer punto merece leerse dos veces: alguien se dio cuenta de que el cargador genérico
habría creado el tipo equivocado, y lo arregló **en el sitio correcto** —la especificación de
carga— en vez de parchear el consumidor. Quien use `CooldownManager` no tiene que saber nada
de esto.

Lo usa hoy la tirada gratis de la ruleta, con `FREE_SPIN_COOLDOWN = 24 * 60 * 60`. Ver
[Máquinas](./machines.md#dos-formas-de-entrar-escritas-con-doce-meses-de-diferencia).

### `Dialogs/` — dos guiones de NPC

**HECHO.** 111 líneas de datos: `FrameShop` (el vendedor de marcos) y `KaraokeRoomRent` (el
alquiler de salas). Un grafo de nodos con `text`, `responses` y un `next` que puede ser un
número o una función:

```lua
next = function(respIdx)
	if respIdx == 3 then return "__CLOSE__" end
end
```

Los consume `DialogModule` — ver [Bar, NPC y diálogos](./bar-npcs.md#los-diálogos). Los dos
archivos empiezan con el mismo comentario copiado, `-- ReplicatedStorage/Dialogs/Shopkeeper.lua`,
que no corresponde ni a su ruta ni a su nombre.

### `PrompBuy/` — el diálogo de confirmar compra

**HECHO.** 109 líneas de cliente. Monta una GUI a partir de `FrameBuy.rbxm`, muestra precio
y nombre de artículo, y devuelve la respuesta. `self.YaHayFuncion` impide abrir dos a la vez.
Usa `InputPlayer` del catálogo de arriba.

Es interfaz: quien decide si la compra procede es el servidor. Ver
[Tiendas](./stores.md#controles-económicos-que-sí-sujetan).

## Las que quizá no use nadie

**INFERENCIA — no HECHO.** Ocho archivos no aparecen en ningún `.luau` del repositorio, y
una búsqueda de texto sobre los `.rbxm` tampoco los encuentra:

`UpdatingCountText`, `MovedScrollButton`, `KeyGenerator`, `CollisionModule`,
`AssetsToPreload`, `AdjustBoxFrame`, y —solo en `.luau`— `RutaCreate` y `Carousel`, que sí
aparecen en `ScreenGui.rbxm` y `WorldSystemUI.rbxm` respectivamente.

Se marca como **inferencia y no como hecho** por la razón de arriba: el código de un
`LocalScript` dentro de un `.rbxm` va comprimido, y `grep` no lo lee. Confirmarlo exige
abrir el place en Studio y buscar ahí.

**No se borra nada.** Este proyecto documenta; retirar código muerto es una tarea aparte, y
además necesita la comprobación en Studio que aquí no se puede hacer.

## Qué queda por leer

| Archivo | Estado |
|---|---|
| `Trove`, `Signal` | **De terceros** — se documenta la frontera, no el interior |
| `CardSlots`, `ButtonMotion`, `ShopHighlight`, `Carousel`, `AnimationButtons` | **Superficie** — qué son y quién los usa |
| `Running`, `SignalsGame`, `Commands`, `AreaSystem`, `SoundManager` | Leídos |
| Las 18 de interfaz | **Superficie** — a propósito |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Bucle por fotograma | `Shared/Running.luau` |
| Bus interno por nombre | `Shared/SignalsGame.luau` |
| Comandos de chat | `Shared/Commands.luau`; `Events/Other/Commands` |
| Sonido | `Shared/SoundManager.luau` |
| Áreas | `Shared/AreaSystem.luau` |
| Etiqueta → módulo | `Shared/bindToTag.luau` |
