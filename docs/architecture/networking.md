---
sidebar_position: 7
title: Red
---

# Red

## Forma de la superficie de remotes

**HECHO.** Los remotes no se crean en código. Se **declaran como archivos `.model.json`
de Rojo** y se distribuyen como instancias, así que la superficie completa se puede
conocer estáticamente leyendo el árbol de archivos. Hay:

| Clase | Cantidad |
|---|---|
| `RemoteEvent` | 174 |
| `RemoteFunction` | 40 |
| `BindableEvent` | 11 |
| `BindableFunction` | 1 |

169 de los `RemoteEvent` y los 40 `RemoteFunction` viven bajo `ReplicatedStorage.Events`,
organizados por tema. Los 5 restantes son locales a una función concreta (por ejemplo
`Assets/Tools/Toys/SlimeBomb/RemoteEvent`).

## Mapa por temas

**HECHO.** `ReplicatedStorage.Events` agrupa los remotes en una carpeta por subsistema. La
cantidad por carpeta es una primera estimación razonable de dónde está de verdad el
tráfico cliente↔servidor:

| Carpeta | `RemoteEvent` | `RemoteFunction` | `BindableEvent` |
|---|---|---|---|
| `Interactable` | 44 | — | — |
| `Karaoke` | 25 | — | — |
| `WorldSystem` (Core) | 12 | 21 | — |
| `Machines` | 18 | 1 | — |
| `Stores` | 10 | — | — |
| `Tools` | 9 | — | — |
| `IconsUI` | — | — | 8 |
| `Monetization` | 6 | — | — |
| `Paint` | 6 | — | — |
| `Decors` | 5 | — | — |
| `Player` | 5 | — | 2 |
| `(raíz)` | 5 | 1 | — |
| `CustomClickDetector` | 4 | — | — |
| `Inventory` | 4 | 1 | — |
| `Quests` | 4 | 2 | — |
| `Collections` | 3 | 1 | — |
| `Referrals` | 3 | 1 | — |
| `Animator` | 2 | 1 | — |
| `Other` | 2 | — | — |
| `GameLoad` | 1 | — | — |
| `LootBox` / `Roulette` | — | 1 cada uno | — |
| `ShopUI` | — | — | 1 |
| `WorldSystem` (PlayerHouses) | 1 | 9 | — |

**INFERENCIA.** Destacan dos cosas. `WorldSystem` es la única área que se apoya en
`RemoteFunction` (30 de los 40, sumando ambas plantillas), porque las operaciones de
mundos y casas son petición→respuesta por naturaleza: *¿puedo entrar, qué casas tengo,
cuánto cuesta esto*. Todo lo demás es abrumadoramente `RemoteEvent` de disparar y olvidar.

## Dos carpetas `WorldSystem` de eventos

**HECHO.** Hay dos carpetas `Events/WorldSystem` distintas, en plantillas distintas, y la
[importación de plantillas](./initialization.md) las fusiona en la misma carpeta de
ejecución:

| Plantilla | Remotes | Presente en |
|---|---|---|
| `Core` | `JoinServer`, `JoinWorld`, `GetHouses`, `GetPlayerHouses`, `GetPlayerHouseServers`, `GetSlots`, `BuySlot`, `BuyItem`, `GetShopData`, `GetFriendServers`, `GetMostPlayedServers`, `GetFavoriteWorlds`, `houseControl`, `currencyControl`, … | Todos los places |
| `PlayerHouses` | `GetWorldSettings`, `GetRoles`, `GetUserRol`, `SetUserRole`, `GetBans`, `SetBan`, `SetWorldName`, `togglePrivacity`, `GetSlots`, `WorldDataUpdated` | Places de casa |

**INFERENCIA.** La separación es por *dónde se puede responder la operación*. Los remotes
de `Core` responden a qué mundos existen y cómo llegar a ellos, y los sirve un lobby. Los
de `PlayerHouses` administran **este** mundo —su nombre, roles, baneos, privacidad— y solo
los puede servir el servidor que tiene cargados los datos del mundo.

**OBSERVACIÓN.** `GetSlots` está declarado en **ambas** carpetas, en las dos como
`RemoteFunction`. Solo existe un enlazador en todo el repositorio —
`Core/…/ServerScripts/PlayerDataReplicator.server.luau` hace
`GetSlots.OnServerInvoke = getPlayerSlots` — y un solo consumidor,
`Core/…/Client/WorldSystem/Modules/InventoryController.luau`. Nada de la plantilla
`PlayerHouses` lo referencia.

Si alguna vez ambas plantillas se fusionan en el mismo place, las reglas de fusión
conservan la instancia importada primero y destruyen la segunda; como las clases son
idénticas, el resultado es un solo `RemoteFunction` con un solo enlace, que es lo que el
código ya espera. Queda registrado como observación, **no** como defecto. Si las dos
plantillas *se fusionan* en el mismo place es **DESCONOCIDO**: `PlayerHouses` no aparece
en `TEMPLATES_IDS`.

## El patrón petición→respuesta

**HECHO.** Los `RemoteFunction` del sistema de mundos devuelven de forma consistente
`(ok: boolean, err: string?)`. `WorldManager` es el ejemplo más claro:

```lua
JoinServerFunc.OnServerInvoke = function(player: Player, serverKey: string)
    if typeof(serverKey) ~= "string" then
        return false, "Invalid Server Key"
    end
    …
    return false, "Server not found"
end
```

Cada ruta de fallo devuelve una *cadena con el motivo*, nunca `nil` y nunca un error. Así
el cliente siempre recibe una respuesta definida, y no hace falta envolver el invoke en un
`pcall` para distinguir «denegado» de «se rompió».

## Validación de entrada

**HECHO.** Los manejadores del servidor en la ruta revisada validan la entrada del cliente
por *tipo* antes de usarla, y resuelven los identificadores con tablas del lado servidor
en vez de confiar en ellos:

| Manejador | Validación |
|---|---|
| `JoinServer` | `typeof(serverKey) ~= "string"` → rechazo; luego `parseRoomKey` debe casar con `^(%d+)_(.+)$`; luego `HousesInfo[roomName]` debe existir |
| `JoinWorld` | `typeof(placeKey) ~= "string"` → rechazo; `PlaceKeyToPlaceId[placeKey]` debe existir, si no `"Invalid place key"` |
| `LoadCharacterRequest` | validez del jugador, cooldown de 2 segundos, `InitScriptsReadyFlag`, y un flag de un-personaje-por-sesión |
| `teleportToHost` | `meta.placeId` debe ser `number` y `meta.accessCode` `string`, si no `"Malformed host metadata"` |
| `JoinServer` (hosting `default`) | `placeId` debe ser `number` y `jobId` `string`, si no `"Malformed directory entry"` |

**INFERENCIA — la propiedad de seguridad que importa.** Un cliente puede nombrar *qué*
quiere alcanzar, nunca *cómo*. Los `PlaceId` salen de `HousesInfo` o de
`PlaceKeyToPlaceId`; los `accessCode` salen de MemoryStore. El código enuncia la regla
directamente para los eventos:

```lua
-- El code sale del registro de MemoryStore, nunca del cliente.
```

**Nota de alcance.** Esta valoración cubre las rutas de arranque, jugador y sistema de
mundos que se han leído de punta a punta. Los otros ~200 remotes —`Interactable`,
`Karaoke`, `Machines`, `Stores`, `Tools`— **no** se han revisado, y nada de lo dicho aquí
debe leerse como una afirmación sobre ellos. Están en cola para las fases 3 y 4.

## Comunicación servidor → servidor

**HECHO.** `MessagingService` lo usan 9 archivos. Los temas establecidos en la ruta
revisada:

| Tema | Publicador | Contenido |
|---|---|---|
| `UserServerRegistryUpdate` | `ServerPresence.RefreshNow` | `{ key = serverKey, info = payload }` |
| `UserServerRegistryClosed` | `ServerPresence.Cleanup` | `serverKey` |

**INFERENCIA.** Existen para que un servidor que consulta el directorio se entere de los
cambios sin sondear MemoryStore. La entrada de MemoryStore sigue siendo la fuente de
verdad: el mensaje es solo un aviso de que cambió. Cada publicación va dentro de un
`pcall` y un fallo solo avisa, así que un mensaje perdido degrada la frescura, no la
corrección.

Los demás usuarios de `MessagingService` —`DataKit.Store`/`BaseStore`, `ServerDirectory`,
`ShopServerSystem`, `Karaoke/RevisarCanciones`, `Paint/ServerClient`, `ComprasTablero`,
`Referrals/ReferralMain`— se documentan con sus sistemas.

## Bindables

**HECHO.** 11 `BindableEvent` y 1 `BindableFunction`. 8 de los `BindableEvent` están en
`Events/IconsUI`, 2 en `Events/Player`, 1 en `Events/ShopUI`.

**INFERENCIA.** Aquí los bindables sirven para desacoplar dentro del mismo lado (sobre
todo UI de cliente), no como transporte cliente↔servidor. Su escaso número frente a 214
remotes sugiere que casi todo el acoplamiento dentro de un lado se hace por `require`
directo.

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Remotes de mundos y casas | `Core/…/ServerScripts/WorldManager.server.luau` |
| Remotes de administración de mundo | `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau` |
| Consultas al directorio | `Core/…/ServerScripts/ServerDirectory.server.luau`, `WorldsBrowser.server.luau` |
| Mensajería entre servidores | [`ServerPresence`](/api/ServerPresence); `DataKit/Store.luau`, `DataKit/BaseStore.luau` |
| Solicitud de personaje | `Core/…/ServerScripts/playerManager.server.luau` |
