---
sidebar_position: 16
title: Nametags y micrófono
---

# Nametags y micrófono

Dos sistemas que van juntos porque comparten la etiqueta que flota sobre cada personaje:
uno la pinta, el otro decide quién puede hablar con quién.

| Sistema | Archivo | Líneas |
|---|---|---|
| Nametag | `ServerScripts/NametagServer.server.luau` | 512 |
| Estilo y datos | `Shared/Nametag/` — `LevelStyler`, `Countries`, `MicStatus` | 451 |
| Permisos de micrófono | `ServerScripts/MicManagerServer.server.luau` | 196 |
| Interfaz | `Client/NametagMicClient/` | 259 |

## El nametag

**HECHO.** El servidor monta sobre cada personaje una etiqueta con etiquetas numeradas para
fijar su orden: `1Country`, `3Level`, y las demás. El nombre numérico **es** la ordenación,
no hay un campo aparte.

| Dato | De dónde sale |
|---|---|
| Bandera del país | `LocalizationService:GetCountryRegionForPlayerAsync(player)`, traducido por `Countries.luau` |
| Nivel | `leaderstats.Level`, con el estilo que decida `LevelStyler.apply` |
| Estado del micrófono | `MicStatus.luau`, alimentado por el sistema de abajo |

**HECHO — no declara ningún remote.** `NametagServer` no tiene `OnServerEvent` ni
`OnServerInvoke`: todo lo que hace es reaccionar a atributos y a `leaderstats`, que ya son
replicados. No hay superficie de red que atacar.

**OBSERVACIÓN.** El nivel se lee **por nombre de `Instance`** (`leaderstats.Level`), que es
uno de los acoplamientos frágiles que registra
[Dependencias](../architecture/dependencies.md): renombrar esa stat rompería el nametag sin
que nada lo mencione.

## Los permisos de micrófono

**HECHO.** `MicManagerServer` pregunta a Roblox con qué grupos de chat de voz está cada
jugador, y **calcula la matriz de quién oye a quién**:

```lua
for _, otherPlayer in ipairs(allPlayers) do
	if otherPlayer ~= targetPlayer and otherPlayer.Parent == Players then
		local canChat = shareAnyGroup(targetGroups, otherGroups)
		compatibilityList[tostring(otherPlayer.UserId)] = canChat
	end
end
UpdateMicEvent:FireClient(targetPlayer, compatibilityList)
```

Dos jugadores pueden hablar si **comparten al menos un grupo**. Cada cliente recibe solo su
propia fila de la matriz.

**HECHO.** El remote lo crea el propio script, en la raíz de `ReplicatedStorage`:

```lua
local existingEvent = ReplicatedStorage:FindFirstChild("UpdateMicEvent")
...
UpdateMicEvent = Instance.new("RemoteEvent")
UpdateMicEvent.Name = "UpdateMicEvent"
UpdateMicEvent.Parent = ReplicatedStorage
```

Es otro remote que no aparece en [Remotes](../reference/remotes.md), por el mismo motivo que
los de [Trabajos](./jobs.md): ese censo cuenta lo declarado, no lo que existe en ejecución.
Este además **no está bajo `Events`**, sino suelto en la raíz.

**Registrado como correcto — no tiene superficie de entrada.** Es servidor → cliente y nada
más: no hay `OnServerEvent`, así que un cliente no puede pedir ni alterar la matriz.

### Tres pasadas escalonadas, y el porqué

**HECHO.** Cada vez que alguien entra se programan **tres** actualizaciones:

```lua
task.delay(0.5, ...)   -- Primera pasada rápida
task.delay(3, ...)     -- Segunda pasada cuando Roblox ya debería haber estabilizado VoiceChat
task.delay(8, ...)     -- Tercera pasada de seguridad para casos lentos de carga
```

Los comentarios lo explican: el estado de chat de voz de un jugador no está listo en el
instante en que entra, y Roblox no avisa de cuándo lo está. Tres intentos escalonados es la
forma pragmática de cubrirlo sin sondear.

**Registrado como correcto.** Y está bien protegido contra que esas tres pasadas se pisen:

| Control | Cómo |
|---|---|
| Un resultado viejo no pisa a uno nuevo | Cada petición incrementa `requestVersion`; al volver, si la versión cambió, el resultado se descarta |
| No corren dos trabajadores a la vez | La bandera `workerRunning` |
| Una petición llegada durante la espera no se pierde | El bucle repite una vez más si `myVersion ~= requestVersion` |
| No se envía a quien ya se fue | `targetPlayer.Parent == Players` antes de cada `FireClient` |

Es un patrón de coalescencia bien hecho, del que hay poco en el repositorio.

### Lo que sí falla

Ver [BUG-CANDIDATE-038](../testing/verification-plan.md#bug-candidate-038): el filtro que
decide qué errores se registran está al revés, y el resultado es que **el único fallo que
se avisa es el esperado**.

**OBSERVACIÓN — registro muy hablador en un camino caliente.** Cada actualización imprime:

- una línea por la petición,
- **una línea por jugador**, con `HttpService:JSONEncode(rawGroups)`,
- **otra línea por jugador**, con `JSONEncode` de su lista de compatibilidad.

Con 30 jugadores son 61 líneas y 60 codificaciones JSON por pasada, y hay **tres pasadas por
cada entrada** y dos por cada salida. En un servidor lleno con rotación normal, eso es
registro constante y trabajo de serialización que solo sirve para depurar.

## Puntos de verificación

| Aspecto | Entrada |
|---|---|
| El filtro de errores de `GetChatGroupsAsync` está invertido | [BUG-CANDIDATE-038](../testing/verification-plan.md#bug-candidate-038) |
| El control de chat de voz del arranque falla abierto | [BUG-CANDIDATE-001](../testing/verification-plan.md#bug-candidate-001) |

## Controles que sí sujetan

| Control | Cómo |
|---|---|
| **La matriz de micrófono no la puede pedir el cliente** | El remote es solo servidor → cliente |
| **Cada jugador recibe solo su fila** | `compatibilityList` se construye por destinatario |
| **Un resultado tardío no pisa uno reciente** | El contador `requestVersion` |
| **No se solapan trabajadores** | La bandera `workerRunning`, con repetición si llegó otra petición |
| **El nametag no tiene superficie de red** | Ni un solo remote; se alimenta de atributos y `leaderstats` |

## Qué queda por leer

| Archivo | Líneas | Estado |
|---|---|---|
| `MicManagerServer.server.luau` | 196 | Leído |
| `NametagServer.server.luau` | 512 | **En parte** — su superficie, sus fuentes de datos y el orden de las etiquetas; no la mecánica de montaje |
| `Shared/Nametag/` (4 archivos) | 451 | **Pendiente** |
| `Client/NametagMicClient/` | 259 | **Pendiente** — es interfaz |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Etiqueta sobre el personaje | `ServerScripts/NametagServer.server.luau` |
| Estilo por nivel | `Shared/Nametag/LevelStyler.luau` |
| Banderas | `Shared/Nametag/Countries.luau` |
| Matriz de micrófono | `ServerScripts/MicManagerServer.server.luau`, `sendMicPermissions` |
| Coalescencia de peticiones | `MicManagerServer`, `requestMicUpdate`, `requestVersion`, `workerRunning` |
