---
sidebar_position: 12
title: Barrido de los sistemas restantes
---

# Barrido de los sistemas restantes

Esta página **no** es documentación al mismo nivel que las anteriores, y conviene decirlo
antes que nada.

Las páginas de Casas, Datos del jugador, Tiendas, Monetización, Interactuables, Inventario,
Karaoke y Cuadros salen de leer esos sistemas enteros o casi. Esta sale de **leer su
superficie de red y sus guardas**, y nada más. Sirve para que ningún sistema quede sin
mencionar y para que la siguiente pasada sepa dónde empezar, no para entender cómo
funcionan.

Cada entrada dice explícitamente qué se miró.

## Misiones

**Leído:** `QuestMain.server.luau`, `QuestService.luau` en sus rutas de reclamación.
**Sin leer:** `Pickables/`, la configuración de misiones, el cliente.

**HECHO.** Cuatro remotes: `GetQuestState`, `ClaimQuest`, `GetQuestPickables`,
`CollectQuestPickable`.

**Registrado como correcto.** `ClaimQuest` es de las validaciones más completas del
repositorio:

```lua
if groupName ~= "Daily" and groupName ~= "Weekly" then return end
if typeof(slot) ~= "number" then return end
...
if activeQuest.Claimed then return end
local questConfig = QuestConfig.GetQuestById(activeQuest.QuestId)
if not questConfig then return end
if activeQuest.Progress < questConfig.Objective.RequiredAmount then return end
```

Lista blanca de grupos, tipo del hueco, la misión existe, no está reclamada, el progreso
llega al objetivo, y la recompensa sale de la configuración del servidor.

**OBSERVACIÓN, y merece atención.** `activeQuest.Claimed = true` se escribe **después** de
conceder las recompensas, la misma forma que
[BUG-CANDIDATE-008](../testing/verification-plan.md#bug-candidate-008). Aquí **no** abre
ventana de doble reclamación, y el motivo es concreto: en todo el recorrido no hay ni un
punto de suspensión. `getQuestDataValue` usa `FindFirstChild` e `Instance.new`,
`JSONDecode` no cede, `Collections.Give` escribe `.Value` sin ceder, y `saveData` codifica y
asigna. Sin ceder el hilo, dos llamadas seguidas no se entrelazan.

Es correcto **hoy**, y lo es por una propiedad frágil: **añadir un solo `task.wait`, un
`pcall` sobre algo asíncrono o una escritura a DataStore en `Collections.Give` o en
`saveData` abriría la ventana**. Se registra aquí para que quien toque esas funciones lo
sepa.

## Máquinas de arcade

**Leído:** `machines/init.server.luau` en `requestSpinRF`, `Machine.luau` en `bind` y la
ruta de premio, `PopTheLock.luau` en su remote.
**Sin leer:** el resto de los minijuegos.

**HECHO.** Cuatro puntos de entrada: `Machines.Request`, `Machines.Start`, el remote por
máquina que ata `Machine:bind`, y `requestSpinRF`.

**Registrado como correcto.** `requestSpinRF` valida en cadena y devuelve un motivo por cada
rechazo —`BAD_MODEL`, `NOT_ROULETTE`, `IN_MACHINE`, `NO_CHAR`, `DEAD`, `NO_MACHINE`,
`BUSY`, `NO_SPINS_STAT`, `NO_SPINS`—, comprueba el recurso **antes** de cobrarlo, y usa
`CooldownManager` para el giro gratuito. Un comentario del propio código señala el orden:
*«BUSY CHECK antes de tocar spins/cooldown (para que no pierdan nada)»*.

**Pendiente de verificar:** [BUG-CANDIDATE-016](../testing/verification-plan.md#bug-candidate-016),
sobre el valor de recompensa que llega del cliente.

## Animación y bailes

**Leído:** `AnimationSystem/init.server.luau` entero.
**Sin leer:** `AnimationManager`, `Client/Animator`, `Client/animation`.

**HECHO.** Cuatro remotes: `Animate`, `Animator.GetAnimations`, `WorldSystem.GetDances`,
`Animator.PlayAnimation`.

**Registrado como correcto.** La posesión se comprueba, y el rechazo se registra:

```lua
local animFolder = player:FindFirstChild("Animations")
local animValue = animFolder and animFolder:FindFirstChild(name)
if not animValue then
	warn(player.Name .. " intentó bailar " .. name .. " sin tenerlo.")
	return
end
```

Y hay una decisión de seguridad escrita en el código:

```lua
-- Eliminamos AddAnimation remote por seguridad.
```

Quitar un remote **es** una medida de seguridad, y dejarla anotada es exactamente lo que
hay que hacer.

**Pero** el destino de la animación viene del cliente:
[BUG-CANDIDATE-031](../testing/verification-plan.md#bug-candidate-031).

## Cocina

**Leído:** `cooking/CookingStation.luau` en su `bind`, `CuttingBoard.server.luau`.
**Sin leer:** las recetas, `Shared/cooking`, `Client/cooking`, los interactuables de horno,
microondas y batidora.

**HECHO.** Los remotes de cocina (`Oven`, `Stove`, `Microwave`, `Blender`, `CuttingBoard`,
`FoodPlate`, `TakeFoodServing`, `ReturnFoodServing`, `OpenFoodContainer`, `GiveCoffee`,
`GiveWater`) viven bajo `Events/Interactable`, no en una carpeta propia. Por eso hay 43
remotes ahí y solo 25 scripts en `ServerScripts/interactable`.

**HECHO.** `CookingStation:bind` comprueba que el jugador tenga `Humanoid` con vida, y
después opera sobre el `model` que recibe. Es el mismo patrón que la
[matriz de Interactuables](./interactables.md#la-matriz-de-validación): sin comprobación de
etiqueta ni de distancia. Entra dentro de
[BUG-CANDIDATE-025](../testing/verification-plan.md#bug-candidate-025).

**Registrado como correcto.** El consumo de ingredientes pasa por
`InventoryManager.removeItem`, que es la ruta validada del inventario, no una manipulación
directa.

## Trabajos

**Leído:** solo su cableado desde `Data.Main` (`Jobs.Monetization = Monetizacion`,
`Jobs.init(true)`, `Jobs.disabled()` en el apagado).
**Sin leer:** `Shared/JobSystem` (1 515 líneas) y `Events/Jobs`.

**DESCONOCIDO** cómo se asignan los trabajos y cómo se pagan. Es de los mayores huecos que
quedan, y toca economía.

## Ragdoll

**Leído:** el listado. **Sin leer:** los dos archivos.

**HECHO.** `ServerScripts/Ragdoll` no tiene ningún `OnServerEvent` ni `OnServerInvoke`
propio. Se dispara desde otros sistemas: `ToolsServer` referencia
`Events.Player.RagdollTarget`.

## Nametags y micrófono

**Leído:** el listado y la relación con `PlayerInit`.
**Sin leer:** `NametagServer`, `Shared/Nametag`, `MicManagerServer`, `NametagMicClient`.

**HECHO.** No declaran remotes propios: un `grep` de `OnServerEvent` sobre esos archivos no
devuelve nada. Es coherente con que el estado de micrófono llegue por atributos y por
`VoiceChatService`, que es lo que documenta
[Arranque](../architecture/initialization.md) al hablar del control de chat de voz
([BUG-CANDIDATE-001](../testing/verification-plan.md#bug-candidate-001)).

## Sistema de construcción

**Leído:** nada. **Sin leer:** los 8 archivos de `BuildingSystem/ReplicatedStorage`
(2 749 líneas).

Es una **plantilla independiente**, con su propio asset (`94091855508048`), que
`ImportTemplates` fusiona en ejecución. Ver [Inicialización](../architecture/initialization.md).

Ya no es candidato a escribir la sección `content` del perfil `World` —eso lo resolvió
[Tiendas y decoración](./stores.md)—, así que su papel exacto sigue sin establecerse.

## Colocación de herramientas

**Leído:** nada. **Sin leer:** `ToolPlacementServer.server.luau` (880 líneas).

Es el segundo archivo de servidor más grande sin leer, después de `JobSystem`. Por el
nombre y por los remotes `PlaceTool` y `PickupTool`, es la ruta por la que una herramienta
pasa del inventario al mundo, lo que la conecta con
[Inventario](./inventory.md) y con
[BUG-CANDIDATE-023](../testing/verification-plan.md#bug-candidate-023), que trata el mismo
problema para el mobiliario.

## Televisores de karaoke

**Leído:** nada. **Sin leer:** `Karaoke/KaraokeTV/` (950 líneas).

Los alcanza el remote `Display` de interactuables, que ya está documentado como sin
comprobación de etiqueta ni distancia.

## Prioridad sugerida para la siguiente pasada

| # | Qué | Por qué |
|---|---|---|
| 1 | `Shared/JobSystem` | 1 515 líneas, toca economía, y no se sabe nada de él |
| 2 | `ToolPlacementServer` | 880 líneas, y es el análogo de un problema ya registrado |
| 3 | `GlobalDataStore` y `GiftInbox` | Cierran **U-008**, y de ellos depende cuánto pesa BUG-CANDIDATE-029 |
| 4 | `BuildingSystem` | Una plantilla entera sin tocar |
| 5 | `KaraokeTV` y `BusquedaMusicas` | Cierran Karaoke |
