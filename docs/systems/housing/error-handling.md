---
sidebar_position: 7
title: Manejo de errores
---

# Manejo de errores en Casas

Todos los modos de fallo encontrados en la ruta de casas, qué hace el código con cada uno,
y qué queda abierto. Las filas marcadas **DESCONOCIDO** no son huecos de esta página: son
huecos de lo que la lectura estática puede establecer.

## Matriz de fallos

| Fallo | Dónde se detecta | Manejo | Qué ve el jugador | Pregunta abierta |
|---|---|---|---|---|
| El cliente envía una `serverKey` que no es cadena | `JoinServerFunc` | Rechazado antes que nada | `(false, "Invalid Server Key")` | — |
| La clave no casa con `^(%d+)_(.+)$` | `parseRoomKey` | Cae al directorio de presencia | `(false, "Server not found")` si no está | — |
| Room no está en `HousesInfo` | `JoinServerFunc` / `PlayerWorld_Init` | Lobby: se trata como clave que no es de casa. Servidor de casa: `onFailedServer` → `KickAll` | `"[Error] Unknown room X."` | — |
| Falla `ReserveServer` | `reserveAccessCode` | `warn`, devuelve `nil`; `hostWorld` limpia su stage local y llama a `claim:release()` para liberar el turno de inmediato | `(false, "The server could not be reserved")` | Sin reintento — ¿basta un intento? |
| Falla `TeleportAsync` | `safeTeleport` | 3 intentos, 0,5 s entre ellos, cada uno con `pcall` | `(false, "TeleportFailed: …")` | — |
| Metadata del anfitrión mal formada | `teleportToHost` | Comprueba tipos de `placeId` y `accessCode` antes de usarlos | `(false, "Malformed host metadata")` | — |
| Entrada del directorio mal formada | `JoinServerFunc` | Comprueba tipos de `placeId` y `jobId` | `(false, "Malformed directory entry")` | — |
| Falla la lectura de MemoryStore | `ServerPresence.SafeGet` | Reintenta con backoff; abandona si hay throttle; devuelve un flag de error distinto de «no encontrado» | `(false, "Error trying to get the server")` | — |
| MemoryStore hace throttling | `isThrottled` en `ServerPresence`, `Lease`, `ServerDirectory` | Deja de reintentar, pausa 60 s, conserva la caché existente | Datos algo desfasados, sin error | — |
| Otro lobby está haciendo staging | `claimStaged` devuelve `kind = "staged"` | Sondea `peekStaged` 10 × 1 s, y luego entra a la misma instancia | `(false, "Server is pending")` si el sondeo agota el plazo | ¿Bastan 10 s para un `ReserveServer` lento? |
| El lobby que hacía staging desapareció | `waitForStagedHost` | `if not stager then return nil` — se rinde al momento en vez de sondear un claim muerto | `(false, "The server could not be reserved")` | — |
| `TeleportData` ausente o mal formado | `extractPayload` | Devuelve `(nil, nil)`; `onPlayerAdded` no hace nada, así que el servidor queda sin inicializar | Nada — el jugador está en un servidor inerte | **DESCONOCIDO**: sin expulsión ni mensaje. Ver abajo. |
| Falla la lectura de `WorldsPlayer` | `hasRoom` | Distingue «falló la lectura» de «no la posee» | `"[Error] Failed getting the [id] rooms."` | — |
| El dueño no posee la room | `hasRoom` | `onFailedServer` → `KickAll` | `"[Error] The user N does not have the X."` | — |
| El lease ya está tomado | `Store._resolveOwnership` → `onDenied` | `convergeToOwner`, 3 intentos | Teletransportado al anfitrión real, o expulsado | [BUG-CANDIDATE-004](../../testing/verification-plan.md#bug-candidate-004) |
| El store nunca queda listo | `store:awaitReady()` devuelve false | `onFailedServer` salvo que ya esté denegado | `"[Error] The data server could not be obtained."` | — |
| El jugador no puede hostear | `canHostWorld` | `WorldService.destroy()` y luego `KickAll` | El motivo concreto del rechazo | — |
| Falla `GetNameFromUserIdAsync` en el primer arranque | `getRoomDisplayName` | Cae a `"default Name"` | Una casa llamada así para siempre | [BUG-CANDIDATE-009](../../testing/verification-plan.md#bug-candidate-009) |
| Falla `IsFriendsWith` | `canHostWorld`, `canPlayerEnter` | Se trata como «no es amigo» — **falla cerrado** | Rechazado de una casa privada | — |
| Falla `FilterStringAsync` | `SetWorldName` | Conserva el nombre saneado pero sin filtrar — **falla abierto** | El nombre se aplica | Anotado en [Permisos](./permissions.md) |
| Falla `store:update` | `WorldService.update` devuelve false | `warn`, el remote devuelve `nil` / `false` | No pasa nada | Sin error visible para el usuario |
| Falla la expulsión | `ModeratorManager.kickPlayer` | Con `pcall`, avisa | Se queda en la casa | — |
| Falla `ListItemsAsync` | `ServerDirectory.fullSync` | 3 intentos; **conserva la caché existente** en vez de sustituirla por una parcial | Lista de servidores algo desfasada | — |
| Proxy HTTP inalcanzable | `WorldsBrowser.searchPlayer` | `pcall`, avisa, devuelve `{}` | Un resultado de búsqueda vacío | Indistinguible de «sin coincidencias» |

## Dos modos de fallo que merecen más detalle

### Un servidor de casa sin `TeleportData` utilizable

**HECHO.** `extractPayload` devuelve `(nil, nil)` cuando falta `GetJoinData().TeleportData`
o cuando su `key` no es una cadena. `onPlayerAdded` entonces no hace absolutamente nada:

```lua
local key, accessCode = extractPayload(player)
if key then
    booting = true
    init(key, player, accessCode)
    booting = false
end
```

**INFERENCIA.** No hay `else`. El jugador se queda en un servidor reservado que nunca se
inicializa: sin datos de mundo, sin presencia, sin `isStarted` y —como `PlayerAdded` se
conectó con `:Once`— **sin una segunda oportunidad desde una llegada posterior**, porque
la conexión `Once` la ha consumido este jugador.

Cualquier otro fallo de `init` desemboca en `onFailedServer`, que avisa y expulsa con una
explicación. Solo esta ruta es silenciosa.

**DESCONOCIDO.** Si un jugador puede llegar a un place de `PlayerHouses` sin un
`TeleportData` válido. `WorldManager` siempre lo pone, así que las rutas posibles serían
una entrada directa al place, una reentrada iniciada por Roblox, o un teleport desde
código que no está en este repositorio. Registrado como
[BUG-CANDIDATE-013](../../testing/verification-plan.md#bug-candidate-013).

### Un fallo de `ReserveServer` libera el turno pero no reintenta

**HECHO.** `reserveAccessCode` hace exactamente un intento:

```lua
local ok, code = pcall(TeleportService.ReserveServer, TeleportService, placeId)
if ok then return code end
warn("[WorldManager] ReserveServer failed:", code)
return nil
```

y `hostWorld` deshace limpiamente:

```lua
if not code then
    localStages[serverKey] = nil
    claim:release()
    return false, "The server could not be reserved"
end
```

**INFERENCIA — esto es comportamiento correcto, no una omisión.** Liberar de inmediato la
reclamación de staging es lo que permite que la *siguiente* petición reintente desde un
estado limpio, en vez de esperar los 30 segundos del TTL de staging. Compárese con
`safeTeleport`, que sí reintenta: un teleport es idempotente desde el punto de vista del
llamante, mientras que una reserva mantiene una reclamación distribuida que bloquea a
otros. Reintentar bajo la reclamación alargaría la espera de todos los demás.

La observación se sostiene solo como pregunta sobre el resultado *visible para el usuario*:
el jugador ve un único mensaje de fallo y tiene que actuar de nuevo por su cuenta.

## Convenciones de reporte de errores

**HECHO.** Coexisten dos convenciones distintas, separadas por la frontera de confianza:

| Capa | Convención |
|---|---|
| Remotes que alcanza el cliente (`JoinServer`, `JoinWorld`) | Devuelven `(false, "motivo")` — siempre una respuesta definida, nunca un error, nunca `nil` |
| Interior del servidor de casa | `onFailedServer(msg)` → `warn` + `ServerPresence.KickAll(msg)` — el mensaje es a la vez la línea de log y el motivo de expulsión |
| Remotes administrativos | Devuelven `nil` o `(false, "Code")` y avisan en el servidor |
| Todo lo que toca una API web de Roblox | Envuelto en `pcall`, sin excepción, en todas las rutas revisadas |

**INFERENCIA.** La convención del servidor de casa implica que los mensajes de error
internos se muestran literalmente a los jugadores — incluidas cadenas como
`"[Error] Failed getting the [12345] rooms."`, que filtra un id de usuario y un formato de
corchetes interno a un diálogo de expulsión. Gravedad baja, y se menciona solo porque la
*misma* cadena sirve a dos públicos.

## Lo que no tiene manejo alguno

**HECHO**, dicho para que la ausencia no se confunda con una omisión de esta página:

| Sin manejo para | Consecuencia |
|---|---|
| La salida del último jugador | No corre nada específico de casas; ver [Ciclo de vida del servidor](./server-lifecycle.md) |
| Que un servidor de casa vacío caduque | Lo decide Roblox; no es expresable en este código |
| Un perfil `World` que falle al guardar en el apagado | `Store` reintenta internamente; un fallo total pierde como mucho un intervalo de autoguardado |
| Una casa cuyo dueño ya no posee la room | Inalcanzable — nada quita entradas de `rooms` |
| Borrar o resetear una casa | No es expresable; ver [Persistencia](./persistence.md) |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Fallos de cara al cliente | `WorldManager.server.luau`, `JoinServerFunc`, `JoinWorldFunc` |
| Reintento de teleport | `WorldManager.server.luau`, `safeTeleport` |
| Deshacer la reserva | `WorldManager.server.luau`, `hostWorld` |
| Fallos del servidor de casa | `PlayerWorld_Init.lua.server.luau`, `onFailedServer` |
| Resiliencia de MemoryStore | [`ServerPresence`](/api/ServerPresence); `ServerDirectory.server.luau`, `fullSync` |
| Resiliencia del Store | [`Store`](/api/Store), [`Health`](/api/Health) |
