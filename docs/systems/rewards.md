---
sidebar_position: 15
title: Recompensas y economía secundaria
---

# Recompensas y economía secundaria

Cuatro sistemas pequeños que conceden valor y que **no aparecían en la lista de sistemas**
de este proyecto hasta ahora. Dos de ellos tocan la economía directamente.

| Sistema | Archivo | Qué concede |
|---|---|---|
| Caja de botín | `ServerScripts/LootBoxService.server.luau` | Un juguete o un baile al azar, por 500 Coins o 1 ChestKey |
| Sueldo por tiempo jugado | `ServerScripts/PlaytimeRewardSystem.server.luau` | 25 Coins cada 10 minutos |
| Favoritos | `ServerScripts/FavoriteService.server.luau` | Nada económico: guarda casas favoritas |
| Necesidades | `ServerScripts/stats/` | Vejiga, higiene y su efecto sobre la velocidad |

## La caja de botín

**HECHO.** Su catálogo se construye **una vez, al arrancar**, con dos fuentes:

```lua
for _, toy in ipairs(ToysFolder:GetChildren()) do ... end        -- Assets/Tools/Toys
for danceName, danceData in pairs(AnimationsData) do ... end     -- DancesInfo
```

**Registrado como correcto.** El precio no lo pone el cliente: solo elige **qué moneda**, y
el importe sale de una tabla del servidor.

```lua
local LOOTBOX_PRICES = { Coins = 500, ChestKey = 1 }
...
local price = LOOTBOX_PRICES[currencyType]
if not price then return false, "Invalid currency type" end
```

Una moneda que no esté en la tabla se rechaza, así que es una lista blanca por
construcción. Y cobra **antes** de conceder, que es el orden correcto —al revés que
[BUG-CANDIDATE-008](../testing/verification-plan.md#bug-candidate-008).

**Registrado como correcto.** Nunca da repetidos: `getUnownedLoot` filtra el catálogo
contra lo que el jugador ya tiene, y si no queda nada rechaza **antes** de cobrar.

### Dos cosas que conviene mirar

**HECHO.** Los 14 bailes de `DancesInfo` cuestan **1 000 Coins** cada uno y todos tienen
`IsForSale = true`. La caja cuesta **500** y nunca repite. Ver
[BUG-CANDIDATE-037](../testing/verification-plan.md#bug-candidate-037).

**HECHO.** `DancesInfo` declara `rarityWeight` en cada baile, y la caja **no lo consulta**:

```lua
local function getRandomReward(lootList)
	if #lootList == 0 then return nil end
	local randomIndex = math.random(1, #lootList)
	return lootList[randomIndex]
end
```

Reparto uniforme. No es un campo muerto —`ShopServerSystem` sí lo usa para ponderar su
rotación— sino un campo que un consumidor honra y el otro ignora. Hoy da igual, porque los
14 bailes tienen el mismo peso; dejaría de dar igual en cuanto alguien quiera un baile raro.

**OBSERVACIÓN.** Hay un interruptor de pruebas al principio del archivo:

```lua
local TEST_MODE = false
...
if TEST_MODE then
	print("MODO PRUEBA ACTIVO: Ignorando economía e inventario para " .. player.Name)
	local reward = getRandomReward(AVAILABLE_LOOT)
	return true, reward
end
```

Con `TEST_MODE = true` se salta el cobro **y** la comprobación de lo que ya se tiene. Está
en `false` y no hay ninguna vía para cambiarlo desde fuera. Es la misma forma que
[BUG-CANDIDATE-015](../testing/verification-plan.md#bug-candidate-015), y se registra por lo
mismo: un despliegue con esa constante mal puesta abriría la economía entera.

## El sueldo por tiempo jugado

**HECHO.** 25 Coins cada 600 segundos, con el temporizador guardado en la carpeta
`Cooldowns` — que `SPEC` **persiste** en el perfil del jugador.

**Registrado como correcto, y bien pensado.** Al entrar distingue de dónde viene el jugador:

```lua
local joinData = player:GetJoinData()
local vieneDeMiJuego = joinData.SourceGameId == game.GameId
```

| Origen | Qué hace | Por qué |
|---|---|---|
| Teleport dentro del universo | Respeta el temporizador guardado, y si venció durante el viaje paga el atrasado | Viajar entre places —lobby, casa, karaoke— no debe costar progreso |
| Inicio de sesión nuevo, o procedencia externa | **Reinicia** el temporizador a 10 minutos | Evita que entrar y salir cobre antes de tiempo |

El comentario del código llama a lo segundo *«nuevo/fresco o externo»*, y comparar
`SourceGameId` contra `game.GameId` es la forma correcta de distinguirlos: un teleport
desde otro juego no cuenta como interno.

**OBSERVACIÓN.** El precio de esa decisión es que quien lleve nueve minutos y se
desconecte pierde esos nueve. Es coherente con evitar el abuso, y conviene saberlo.

**Contexto económico**, que sitúa lo demás: 150 Coins por hora. Una caja de botín son 3 h
20 min de juego; un baile en la tienda, 6 h 40 min.

## Favoritos

**HECHO.** Dos `RemoteFunction` —`GiveFavorite` y `RemoveFavorite`— que añaden y quitan
cadenas de `data.favorites`, en el perfil del jugador.

**Registrado como correcto** en lo que comprueba: tipo del argumento, store cargado, y que
no esté ya —dos veces, fuera y dentro del `update`, que es la forma segura.

Lo que **no** comprueba es cuánto: [BUG-CANDIDATE-036](../testing/verification-plan.md#bug-candidate-036).

## Necesidades

**HECHO.** `ServerScripts/stats/` mantiene medidores por jugador —vejiga, higiene— que
otros sistemas incrementan: la ducha y el lavabo suben `hygiene`, la cinta de correr y las
pesas dan progreso. Cuando la vejiga se desborda hay una espera de
`BLADDER_OVERFLOW_WAIT = 5` segundos y un efecto visible, y el estado afecta a la velocidad
del personaje entre `MIN_WALKSPEED = 8` y `MAX_WALKSPEED = 16`.

Es el sistema al que se refieren varios manejadores de
[Interactuables](./interactables.md) cuando llaman a `stats:addIncrementor(...)` o
`stats:increment(...)`.

**Leído por encima:** su papel y sus constantes. **Sin leer:** `Stats.luau` y `Timer.luau`.

## Puntos de verificación

| Aspecto | Entrada |
|---|---|
| `favorites` crece sin tope, con cadenas del cliente | [BUG-CANDIDATE-036](../testing/verification-plan.md#bug-candidate-036) |
| La caja de botín domina estrictamente a la tienda de bailes | [BUG-CANDIDATE-037](../testing/verification-plan.md#bug-candidate-037) |

## Controles que sí sujetan

| Control | Cómo |
|---|---|
| **El precio de la caja no lo pone el cliente** | Solo elige moneda, y `LOOTBOX_PRICES` actúa como lista blanca |
| **La caja cobra antes de conceder** | `Collections.charge` y solo entonces `addItem` / `AddAnimation` |
| **La caja nunca da repetidos** | `getUnownedLoot` filtra, y rechaza antes de cobrar si no queda nada |
| **Reconectar no cobra el sueldo antes de tiempo** | `SourceGameId == game.GameId` distingue el teleport interno del inicio de sesión |
| **El temporizador del sueldo sobrevive a la sesión** | Va en `Cooldowns`, que `SPEC` persiste |
| **Un favorito no se duplica** | Se comprueba fuera y dentro del `update` |

## Qué queda por leer

| Archivo | Líneas | Estado |
|---|---|---|
| `LootBoxService.server.luau` | 104 | Leído |
| `PlaytimeRewardSystem.server.luau` | 107 | Leído |
| `FavoriteService.server.luau` | 55 | Leído |
| `stats/init.server.luau` | 211 | **En parte** — su papel y sus constantes |
| `stats/Stats.luau`, `stats/Timer.luau` | — | **Pendiente** |
| `DancesInfo.luau` | 192 | Leído — 14 bailes, todos a 1 000 Coins |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Caja de botín | `ServerScripts/LootBoxService.server.luau` |
| Catálogo de bailes | `ReplicatedStorage/DancesInfo.luau` |
| Sueldo | `ServerScripts/PlaytimeRewardSystem.server.luau`; `Shared/Cooldown/CooldownManager` |
| Favoritos | `ServerScripts/FavoriteService.server.luau` |
| Necesidades | `ServerScripts/stats/` |
