---
sidebar_position: 24
title: Servidor — piezas sueltas
---

# Servidor — piezas sueltas

Lo que queda de `ServerScriptService/ServerScripts/` cuando se sacan los sistemas que ya
tienen página: el walkie-talkie, los grupos de colisión, el ragdoll, el generador de modelos
de herramienta, las estadísticas y las animaciones. Más `Shared/Nametag/` y los diez scripts
que viven dentro de los propios objetos de `Assets/`.

## El walkie-talkie

**HECHO.** `WalkieServer.server.luau` (147) monta una cadena de audio de Roblox por jugador
—`AudioDeviceInput` → `AudioFader` → `AudioEmitter` en el personaje— y sobre eso construye
canales de tres cifras. Es la misma familia de API que usa el
[modulador de voz](./shared-utilities.md#las-de-mundo-y-física).

Un canal tiene **un transmisor y N receptores**:

```lua
if not channels[channel] then
	channels[channel] = {transmitter = player, receivers = {}}
end
```

**El primero que entra se queda de transmisor.** Los demás pasan a receptores y se les cablea
el emisor del transmisor. Al irse el transmisor, el primer receptor que devuelva `next()`
hereda el puesto.

**HECHO.** El manejador del remote es este, entero:

```lua
RemoteEvent.OnServerEvent:Connect(function(player, channel, tool)
	if #channel == 3 then
		leaveChannel(player)
		joinChannel(player, channel, tool)
	end
end)
```

Una comprobación: que `channel` tenga longitud 3. Queda registrado como
[BUG-CANDIDATE-046](../testing/verification-plan.md#bug-candidate-046).

**Registrado como correcto.** `PlayerRemoving` llama a `leaveChannel` y a `cleanWires`, así
que los `Wire` de un jugador que se va se destruyen y el canal se reasigna o se borra. La
limpieza está hecha, que es más de lo que se puede decir de varios sitios recogidos en el
[plan de verificación](../testing/verification-plan.md).

## El generador de modelos de herramienta

**HECHO.** `ToolModelGenerator/init.server.luau` (169) recorre `Assets/Tools`, y por cada
`Tool` con el atributo `Colocable = true` fabrica un `Model` equivalente en
`Assets/ToolsModels`: copia los atributos, clona la jerarquía, ancla y descolisiona las
partes, y asegura un `PromptHolder`.

**Registrado como correcto.** `removeScripts` borra `Script`, `LocalScript` y `ModuleScript`
del clon. Es el mismo control que
[`InsertService.elimineScrips`](./client-ui.md#insertserviceluau-corre-en-el-servidor): lo
que va a acabar colocado en el mundo no lleva código.

**Pero al final de la fabricación:**

```lua
script:FindFirstChild("Settings"):Clone().Parent = model
```

Se clona **el mismo** `Settings` en todos los modelos. Y ese `Settings` es una copia sin
tocar de `src/ServerStorage/Templates/SettingsTemplate.luau`, cuya `Gui.Description` es un
texto de relleno. Queda registrado como
[BUG-CANDIDATE-047](../testing/verification-plan.md#bug-candidate-047).

## Grupos de colisión

**HECHO.** `collisions.server.luau` (36) registra tres grupos y su matriz:

| Grupo | Con `Players` | Consigo mismo | Con `Default` |
|---|---|---|---|
| `Players` | — | (por defecto) | (por defecto) |
| `Uncollideable-Players` | **no** | **no** | (por defecto) |
| `Collideable-Players` | **sí** | (por defecto) | **no** |

Cada personaje que aparece recibe `Players` en todas sus partes. Los otros dos grupos los
asigna quien los necesite.

**OBSERVACIÓN.** `PlayerRemoving` hace `events[player]:Disconnect()` sin comprobar que exista.
`events[player]` se rellena en `PlayerInit.Connect`, así que un jugador que se fuera antes de
que ese callback corriera daría `attempt to index nil`. Cae en el mismo hueco que
[BUG-CANDIDATE-018](../testing/verification-plan.md#bug-candidate-018) —salir durante la
carga—, aunque aquí la consecuencia se queda en un error en el registro.

## Ragdoll

**HECHO.** Dos `Script` de servidor, 110 líneas entre los dos, los dos con
`Disabled = true` en su `.meta.json` —los enciende `InitScripts`, ver
[Arranque](../architecture/initialization.md):

| Script | Qué hace |
|---|---|
| `DisableJointsWhenFalling` | Suelta las articulaciones al caer |
| `PhysicallySimulatedUpperBody` | Simula físicamente el tronco |

No declaran remotes: actúan sobre el personaje en el servidor y la física se replica sola.
`Client/Ragdoll/` (134) es su otra mitad.

## Estadísticas y animaciones

**HECHO.** `stats/` (210 en tres archivos) lleva las barras de necesidades: `Stats.luau`
declara cuáles hay y sus constantes, `Timer.luau` marca el paso del tiempo y
`init.server.luau` las aplica. La presentación está en
[`Client/stats.server.luau`](./client-ui.md), y los avisos en
`Client/notificationsManager/statsNotifications`.

**HECHO.** `AnimationSystem/` (176) es el que ya describe el
[barrido](./survey.md): `AnimationManager` guarda qué animaciones tiene cada jugador
—`HasAnimation`, `AddAnimation`—, y es de quien tira la
[ruleta](./machines.md#la-ruleta) para conceder un baile.

**HECHO.** `fireExcept.luau` (11) difunde a todos menos a uno. Lo usan las cuatro máquinas
que replican movimiento. Es el gemelo del `fireAllExcept` local de `Machine.luau` — dos
copias de la misma función de once líneas, una privada y otra compartida.

## Nametags

**HECHO.** `Shared/Nametag/` (451) es la mitad de datos de
[Nametags y micrófono](./nametags.md):

| Archivo | Líneas | Qué es |
|---|---|---|
| `Countries.luau` | 208 | Tabla de países y sus banderas |
| `LevelStyler.luau` | 164 | El estilo de la etiqueta según el nivel |
| `MicStatus.luau` | 79 | Los estados del icono de micrófono |

Los tres son tablas y presentación. No tocan red ni datos.

## Los scripts dentro de los objetos

**HECHO.** `Assets/` tiene diez `.luau` (1 243 líneas) que viajan **dentro** de las
herramientas: el `LocalScript` del walkie, el de la cámara, el del cañón. Son el otro extremo
de los remotes de `Events/Tools/`.

Ejemplo, y el que importa aquí, el del walkie:

```lua
if button.Name == "Ok" then
	if #CurrentChannel == 3 then
		RemoteEvent:FireServer(CurrentChannel, Tool)
	end
end
```

El cliente manda el canal **y el `Tool` en el que vive**. Que el servidor se fíe de ese
segundo argumento es la mitad del [BUG-CANDIDATE-046](../testing/verification-plan.md#bug-candidate-046).

**Nota sobre el generador de modelos:** estos scripts son justo los que `removeScripts`
elimina al fabricar la versión colocable de una herramienta. Un walkie en la mano tiene su
`LocalScript`; un walkie colocado en el suelo, no. Es lo correcto, y explica por qué el
generador existe.

## Las tres plantillas para copiar

**HECHO.** `src/ServerStorage/Templates/` (169 líneas) no es código de juego: son tres
esqueletos para empezar algo nuevo.

| Plantilla | Líneas | Para qué |
|---|---|---|
| `SettingsTemplate.luau` | 28 | Los ajustes de un objeto colocable: nombre, descripción, precio, etiqueta |
| `TemplateJob.luau` | 97 | Un trabajo nuevo para [`JobSystem`](./jobs.md): `Tag`, `WhiteList`, `finished`, `MarkUse` |
| `TemplateUIS.luau` | 44 | Un panel de interfaz: `Start`, `OpenFrame`, `Exit`, con su animación y su limpieza |

**Registrado como correcto — la idea.** Que exista una plantilla de trabajo con su
`WhiteList` ya puesta es lo que hace probable que un trabajo nuevo la traiga. La lista blanca
de [Trabajos](./jobs.md#un-solo-remote-por-trabajo-y-el-cliente-manda-el-nombre-del-método) no
es opcional en la práctica porque el punto de partida ya la incluye.

**Y por eso mismo, lo que traen mal se propaga.** Dos cosas:

**OBSERVACIÓN — `SettingsTemplate.luau` es el origen del texto de relleno.** Es de aquí de
donde salen las 46 descripciones idénticas que registra
[BUG-CANDIDATE-047](../testing/verification-plan.md#bug-candidate-047). Cada mueble nuevo
nace con ella.

**OBSERVACIÓN — la rama de servidor de `TemplateJob` no puede ejecutarse.** El archivo define:

```lua
local Player: Player = IsClient and game:GetService('Players').LocalPlayer or nil
...
elseif self.Occupant[Player] then
```

En el servidor `Player` es `nil`, así que `self.Occupant[nil]` siempre devuelve `nil` —leer
una tabla con clave nula no lanza en Lua, simplemente no encuentra nada— y la rama nunca se
toma. En la plantilla no importa, porque no se ejecuta. Importa **si alguien la copia sin
mirar esa línea**, que es exactamente para lo que sirve una plantilla.

Se anota y no se corrige: este proyecto documenta.

## Qué queda por leer

| Archivo | Estado |
|---|---|
| `WalkieServer`, `collisions`, `fireExcept`, `ToolModelGenerator` | **Leídos** |
| `Ragdoll/` (2), `stats/` (3), `AnimationSystem/` (2) | **En parte** — su papel y sus fuentes |
| `Shared/Nametag/` (3) | **En parte** — qué son; las tablas no se transcriben |
| `Assets/**/*.luau` (10) | **En parte** — el del walkie entero, los otros en superficie |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Canales de walkie | `ServerScripts/WalkieServer.server.luau`; `Assets/Tools/Toys/Walkie/LocalScript.client.luau` |
| Grupos de colisión | `ServerScripts/collisions.server.luau` |
| Modelos colocables | `ServerScripts/ToolModelGenerator/` |
| Plantilla de ajustes | `src/ServerStorage/Templates/SettingsTemplate.luau` |
| Difusión excepto uno | `ServerScripts/fireExcept.luau`; `machines/Machine.luau`, `fireAllExcept` |
| Datos de etiqueta | `Shared/Nametag/` |
