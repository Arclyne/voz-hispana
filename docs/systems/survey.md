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

**Leído:** su estructura, su superficie de red y a quién llama.
**Sin leer:** la lógica de interfaz de sus 8 archivos (2 749 líneas).

Es una **plantilla independiente**, con su propio asset (`94091855508048`), que
`ImportTemplates` fusiona en ejecución. Ver [Inicialización](../architecture/initialization.md).

**HECHO — es interfaz de cliente, y nada más.** Su papel queda establecido:

| Comprobación | Resultado |
|---|---|
| `RemoteEvent` / `RemoteFunction` declarados | **Ninguno.** No hay un solo `.model.json` bajo `BuildingSystem/` |
| `FireServer` / `OnServerEvent` en su código | **Ninguno** |
| Archivos `.meta.json` | **Ninguno**, así que ningún script suyo declara `RunContext` ni arranca desactivado |
| Referencias a `LocalPlayer` | Una |

Lo que hace es **conducir el sistema de [Tiendas y decoración](./stores.md)** llamando a sus
métodos:

```
Stores:UpdateDecor · Stores:BuyDecors · Stores:SellDecors
Stores:ComprarMaterial · Stores:ExitModeConstruccion · Stores:GetDecorPlayer
Stores:GetStore · Stores:GetStoreParts · Stores.DecorsPlayer · Stores.MaxBuildPlace
```

Y aquí encaja una pieza documentada en otro sitio: **por eso no necesita remotes propios**.
`Stores` usa el idioma de doble contexto —llamar a uno de sus métodos en el cliente *envía*
el remote, recibirlo en el servidor *ejecuta* la lógica— así que la interfaz de construcción
llama a métodos normales y la red ocurre sola. Ver
[Tiendas → Un módulo, dos juegos, dos contextos](./stores.md#un-módulo-dos-juegos-dos-contextos).

:::note Esto cierra definitivamente la hipótesis del perfil `World`

La documentación de Casas señalaba a `BuildingSystem` como escritor probable de la sección
`content`. No lo es, y ahora se sabe por qué **no puede serlo**: no tiene ninguna vía para
escribir en un DataStore. Lo que persiste es `Stores`, en el servidor, a partir de las
acciones que esta interfaz genera.

:::

**DESCONOCIDO.** Quién monta esta interfaz. Ningún archivo `.luau` fuera de
`BuildingSystem/` menciona `BuildInterface` ni `ConstructionModeModule`, así que su punto de
entrada está en un `.rbxm` —probablemente `StarterGui/BuildMenu.rbxm`— que no es
inspeccionable. Es el mismo hueco que **U-001**.

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
| 1 | `BusquedaMusicas` | Cierra Karaoke, y es el único consumidor de `GlobalDataStore` sin leer |
| 2 | Los 36 módulos de tipo de Interactuables | Catálogo, no explicación: solo si alguien necesita extender un tipo |
| 3 | La interfaz de `BuildingSystem` | Ya se sabe qué es y a quién llama; leer sus 2 749 líneas es documentar UI |
| 4 | Los cuatro módulos de trabajo por dentro | `Bartender`, `LimpiarPiso`, `CajasTransport`, `ButtonMoney` |

**Ya hechos** desde que se escribió esta lista: `JobSystem`, `ToolPlacementServer`,
`GlobalDataStore`, `GiftInbox`, `GiftHandler`, los televisores de karaoke, y el papel de
`BuildingSystem`.
