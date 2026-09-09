---
sidebar_position: 27
title: Misiones
---

# Misiones

Misiones diarias y semanales con objetivos, progreso y recompensa. 586 líneas de servidor
—`QuestMain`, `QuestService`, `QuestPickableService`— más `Shared/Quests` (270) y el cliente
(300).

El [barrido](./survey.md) había leído la ruta de reclamación. Esta página lee el resto, y lo
que encuentra es lo contrario de lo que este proyecto ha ido encontrando en otros sitios:
**aquí la validación está hecha, y bien**.

## Los cuatro remotes

| Remote | Tipo | Qué hace |
|---|---|---|
| `GetQuestState` | `RemoteFunction` | Devuelve el estado de las misiones del jugador |
| `ClaimQuest` | `RemoteEvent` | Reclamar la recompensa de una misión terminada |
| `GetQuestPickables` | `RemoteFunction` | Devuelve los objetos recogibles **de ese jugador** |
| `CollectQuestPickable` | `RemoteEvent` | Recoger uno |

**HECHO.** `QuestMain.server.luau` no hace más que atarlos y llamar al servicio. La lógica
—y las comprobaciones— viven en los dos servicios.

## Reclamar una misión

**HECHO.** `QuestService:ClaimQuest` comprueba **siete** cosas antes de dar nada:

```lua
if groupName ~= "Daily" and groupName ~= "Weekly" then return end
if typeof(slot) ~= "number" then return end
local group = data[groupName]
if typeof(group) ~= "table" then return end
local activeQuest = group[slot]
if not activeQuest then return end
if activeQuest.Claimed then return end
local questConfig = QuestConfig.GetQuestById(activeQuest.QuestId)
if not questConfig then return end
if activeQuest.Progress < questConfig.Objective.RequiredAmount then return end
```

Y solo entonces:

```lua
local reward = questConfig.Reward
if reward.Xp and reward.Xp > 0 then
	Collections.Give(player, { Xp = reward.Xp }, true)
end
if reward.Currency and reward.Amount and reward.Amount > 0 then
	Collections.Give(player, { [reward.Currency] = reward.Amount }, true)
end
activeQuest.Claimed = true
```

**Registrado como correcto**, punto por punto:

| Control | Cómo |
|---|---|
| El grupo es una lista blanca | `"Daily"` o `"Weekly"`, nada más |
| El `slot` se comprueba de tipo | Antes de indexar |
| La misión tiene que existir **en los datos del jugador** | `group[slot]`, no una tabla global |
| **No se puede reclamar dos veces** | `activeQuest.Claimed` |
| La configuración tiene que existir | `GetQuestById` |
| **El progreso tiene que bastar** | `Progress < RequiredAmount` corta |
| **La recompensa no la elige el cliente** | Sale de `questConfig.Reward` |

Es el orden correcto de las siete, y no falta ninguna.

## Recoger un objeto — la comprobación de distancia que falta en todas partes

**HECHO.** `QuestPickableService:Collect` es, de los manejadores leídos en este repositorio,
**el más completo**:

```lua
if typeof(collectibleId) ~= "string" then return end

local store = getPlayerStore(player)
local info = store[collectibleId]
if not info then return end

local character = player.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root then return end

if (root.Position - info.Position).Magnitude > 30 then return end

local objectives = getActiveCollectObjectives(player)
local objective = objectives[info.QuestKey]
if not objective then ... return end

if objective.ObjectName ~= info.ObjectName or objective.QuestId ~= info.QuestId then ... return end
```

| Control | Qué cubre |
|---|---|
| Tipo del identificador | Nada raro llega a indexar |
| **El recogible es de este jugador** | `getPlayerStore(player)`: los recogibles son por jugador, así que no se puede coger el de otro |
| El personaje existe y tiene raíz | |
| **La distancia se comprueba en el servidor** | `Magnitude > 30` — la comprobación que
[BUG-CANDIDATE-025](../testing/verification-plan.md#bug-candidate-025) echa en falta en 21 de 25 interactuables |
| El objetivo está activo | Un recogible huérfano se limpia y se avisa al cliente |
| El objetivo **corresponde** al recogible | `ObjectName` y `QuestId` tienen que coincidir |

**Esto es el contraejemplo que hace falta para leer bien la 025.** Su diagnóstico es que la
validación no está en el framework, y que cada autor la resuelve o no la resuelve. Aquí un
autor la resolvió, y la resolvió mejor que en ningún otro sitio del repositorio — sin que
nada se lo pidiera, y sin que nadie más pueda reutilizarlo.

## El bucle de progreso

**HECHO.** Cada jugador tiene su propia corrutina, que espera a que carguen los datos antes
de tocar nada:

```lua
local function waitForData(player: Player)
	if player:GetAttribute("DataLoaded") then return true end
	while player.Parent and not player:GetAttribute("DataLoaded") do
		player:GetAttributeChangedSignal("DataLoaded"):Wait()
	end
	return player.Parent ~= nil
end
```

**Registrado como correcto.** La espera comprueba `player.Parent` en cada vuelta y devuelve
si el jugador se fue, así que un jugador que sale durante la carga no deja el bucle colgado.
Es exactamente la clase de cuidado que le falta al caso de
[BUG-CANDIDATE-018](../testing/verification-plan.md#bug-candidate-018).

**HECHO.** Después, una vuelta por segundo mientras el jugador esté: comprueba reinicios de
diaria/semanal y suma `TimeInPlace`. El coste es un `task.wait(1)` por jugador.

## La `Xp` que no lleva a ninguna parte

**HECHO.** `ClaimQuest` concede `Xp` de verdad, por una ruta validada, y `PlayerSchema` lo
persiste. Pero **nada convierte `Xp` en `Level`**: fuera de aquí, el único sitio de todo el
repositorio que menciona `Xp` es `QuestClient`, y solo para pintar «120XP» en la ficha de la
misión.

La otra mitad de esa cadena rota —el `Level` que nunca sube y el candado que nunca se abre—
está en [Interfaz de construcción](./building-ui.md#el-precio-y-el-nivel) y en
[BUG-CANDIDATE-051](../testing/verification-plan.md#bug-candidate-051). Esta página aporta la
mitad que faltaba: **el productor de experiencia existe y funciona**. Lo que falta es el
eslabón del medio.

## Qué queda por leer

| Archivo | Líneas | Estado |
|---|---|---|
| `QuestMain.server.luau` | 74 | **Leído** |
| `Pickables/QuestPickableService.luau` | 316 | **Leído** |
| `QuestService.luau` | ~200 | En parte — `ClaimQuest`, `AddProgress` y el estado |
| `Shared/Quests/QuestConfig.luau` | 221 | **Superficie** — es la tabla de misiones |
| `Shared/Quests/QuestShared.luau` | 49 | **Superficie** |
| `Client/QuestClient/` | 300 | **Superficie** — interfaz, sin autoridad |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Los cuatro remotes | `ServerScripts/Quests/QuestMain.server.luau` |
| Reclamación y recompensa | `ServerScripts/Quests/QuestService.luau`, `ClaimQuest` |
| Recogibles | `ServerScripts/Quests/Pickables/QuestPickableService.luau`, `Collect` |
| Catálogo de misiones | `Shared/Quests/QuestConfig.luau` |
| Concesión de moneda | `Client/EconomySystem/Collections.luau` — ver [Datos del jugador](./player-data.md) |
