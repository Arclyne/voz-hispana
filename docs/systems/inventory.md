---
sidebar_position: 9
title: Inventario y herramientas
---

# Inventario y herramientas

Dos capas que conviene no confundir:

| Capa | Dónde | Qué hace |
|---|---|---|
| **Inventario** | `ServerScripts/inventory/InventoryManager` | Qué herramientas posee un jugador, cuántas, y qué hay en cada uno de los 8 huecos de la rueda. Se persiste. |
| **Herramientas** | `ServerScripts/ToolsServer.server.luau` | Qué hace cada herramienta cuando se usa. No persiste nada. |

La primera es, con diferencia, **el código mejor validado del repositorio**. La segunda es
lo contrario. Las dos están a un directorio de distancia.

## El inventario

```mermaid
flowchart TB
    subgraph PERFIL["Perfil WorldsPlayer"]
        IT[("inventory.items<br/>nombre → cantidad")]
        WH[("inventory.wheel<br/>slot → nombre")]
        FL[("inventory.defaultsInitialised")]
    end
    subgraph SRV["InventoryManager"]
        AD["addItem / setItemCount"]
        WS["setWheelSlot / removeWheelSlot"]
        SY["syncPhysicalTool<br/>Backpack ↔ items"]
    end
    RE["Events/Inventory<br/>Equip · Unequip · WheelAdd<br/>WheelRemove · GetWheel"]

    RE --> AD
    RE --> WS
    AD --> IT
    WS --> WH
    IT --> SY
    FL -.->|una sola vez| IT
```

**HECHO.** El inventario vive en el perfil, bajo `inventory`, con tres claves: `items`
(nombre → cantidad), `wheel` (slot → nombre) y `defaultsInitialised`.

### El equipamiento por defecto solo ocurre una vez

**HECHO.** Y el código explica por qué, en un comentario propio:

```lua
local function ensureDefaultInventory(inventory)
	-- Solo se ejecuta una vez en toda la vida de los datos del jugador.
	-- Es importante NO comprobar simplemente si el inventario está vacío,
	-- porque un jugador podría gastar/quitar todos sus objetos legítimamente.
	if inventory.defaultsInitialised then
		return
	end
```

Es una decisión correcta y bien razonada. También significa que **`DefaultTools` no es una
lista viva**: cambiarla no afecta a nadie que ya haya entrado alguna vez. Eso importa por
[BUG-CANDIDATE-026](../testing/verification-plan.md#bug-candidate-026).

### La validación de entrada, que aquí sí está

**Registrado como correcto, y como referencia para el resto del proyecto.** Los cinco
remotes de inventario validan antes de tocar nada:

```lua
inventoryRemotes.WheelAdd.OnServerEvent:Connect(function(player, index, id)
	if typeof(index) ~= "number" or index % 1 ~= 0 then return end
	if index <= 0 or index > WHEEL_SLOTS then return end
	if typeof(id) ~= "string" then return end
	InventoryManager.setWheelSlot(player, index, id)
end)
```

Tipo, entereza, rango y tipo del identificador. Y `setWheelSlot` **vuelve a validarlo todo**
por su cuenta, más la propiedad:

```lua
if not InventoryManager.hasTool(player, id) then return false end
```

| Comprobación | Dónde |
|---|---|
| El nombre corresponde a una `Tool` real de `Assets/Tools` | `getToolAsset`, invocado por `addItem` y `setItemCount` |
| La cantidad es un entero no negativo | `setItemCount` |
| El jugador posee lo que quiere poner en la rueda | `setWheelSlot`, vía `hasTool` |
| Un objeto que llega a cero desaparece también de la rueda | `setItemCount`, bucle sobre `inventory.wheel` |
| Lo que se devuelve al cliente se vuelve a filtrar | `getWheelData` reconfirma rango y propiedad de cada slot |
| El guardado de la rueda no satura el DataStore | `queueWheelSave`, debounce de 30 s con limpieza en `PlayerRemoving` |
| Morir desequipa | `humanoid.Died` → `unequipTool` |

**Es el único sistema leído hasta ahora que valida en las dos capas**: en el manejador del
remote y otra vez dentro del gestor. Compárese con la
[matriz de Interactuables](./interactables.md#la-matriz-de-validación).

## Las herramientas

**HECHO.** `ToolsServer.server.luau` son 988 líneas y ocho manejadores de remote. El rigor
varía enormemente **dentro del mismo archivo**:

| Remote | ¿Comprueba que la `Tool` sea del jugador? | Notas |
|---|---|---|
| `Cannon` | **Sí** — `IsA("Tool")` y `tool.Parent ~= character` | Además tiene cooldown de 5 s vía `CooldownManager` |
| `GloveGun` | **Sí** — las dos mismas comprobaciones | |
| `Minimizate` / `Maximizate` | Actúa sobre el propio personaje | No comprueba que el jugador tenga la poción |
| `Ballon` | Comprueba la forma del objeto, no su propiedad | `tool:FindFirstChild("Handle")` y `Handle.BallonMesh` |
| `EquipTool` | — | Reproduce el `EquipSound` de lo que le manden |
| `Fly` | — | Activa partículas y reproduce sonidos que le manden |
| `EquipToolAccesory` | — | **Reparenta la `Instance` que le manden** |

Ver [BUG-CANDIDATE-027](../testing/verification-plan.md#bug-candidate-027).

**OBSERVACIÓN.** `Minimizate` y `Maximizate` no comprueban que el jugador tenga
`MiniPotion` o `BigPotion`. Hoy da igual, porque las dos están en `DefaultTools` y las tiene
todo el mundo; pasaría a importar en cuanto se vendieran. Lo que sí comprueban es el estado
actual (`SizeState`), así que no se pueden encadenar más allá de `Small` / `Normal` / `Big`.

**OBSERVACIÓN.** Quedan dos `print` de depuración —«Transformando al jugador de … a estado:
…»— en las rutas de encoger y crecer.

## Colocar herramientas en el mundo

`ToolPlacementServer.server.luau` (880 líneas) es la ruta por la que una herramienta pasa
del inventario al suelo y vuelve. Sirve además la mecánica de raciones de comida.

**Y es, con diferencia, el archivo que mejor valida entradas de todo el repositorio.**

### La función que el resto de sistemas no tiene

**HECHO.** `canUsePlacedModel` es la comprobación compartida que
[BUG-CANDIDATE-025](../testing/verification-plan.md#bug-candidate-025) señala como
inexistente en los interactuables. Existe — aquí, privada a este archivo:

```lua
local function canUsePlacedModel(player: Player, model: Instance): boolean
	if typeof(model) ~= "Instance" or not model:IsA("Model") then return false end
	if model.Parent ~= workspaceTools then return false end
	if not CollectionService:HasTag(model, PLACE_TAG) then return false end

	local owner = model:GetAttribute("owner")
	if owner and type(owner) == "string" and owner ~= "" and owner ~= player.Name then
		return false
	end

	local character = player.Character
	if not character or not character.PrimaryPart then return false end

	local distance = (character.PrimaryPart.Position - getModelPosition(model)).Magnitude
	if distance > MAX_PICKUP_DISTANCE then return false end

	return true
end
```

Tipo, contenedor esperado, etiqueta, propiedad, personaje vivo **y distancia**. Los cuatro
remotes de este archivo empiezan llamándola.

**Es exactamente la forma de la solución** que aquella entrada propone. Existe en el
repositorio y no está compartida.

### Cerrojo por modelo, liberado en todas las salidas

**HECHO.** `modelLocks[model]` impide que dos llamadas simultáneas operen sobre el mismo
objeto, y se libera en **cada** camino de salida — no solo en el feliz:

```lua
if modelLocks[model] then return end
modelLocks[model] = true

local character = player.Character
if not character then
	modelLocks[model] = nil
	return
end
```

Es la protección contra doble consumo que a la reclamación de misiones le falta —donde
funciona solo porque nada cede el hilo— y que a las compras de
[BUG-CANDIDATE-008](../testing/verification-plan.md#bug-candidate-008) también.

### Lo que sí queda abierto

**HECHO.** `PlaceTool` valida los cuatro argumentos por tipo, que el jugador **lleve
puesta** la herramienta, que sea `Colocable`, y que exista una plantilla con ese nombre.
No comprueba **dónde** se coloca:

```lua
local finalPosition = position + Vector3.new(0, size.Y / 2, 0)
local finalCFrame = CFrame.new(finalPosition) * CFrame.Angles(0, math.rad(rotY + 180), 0)
...
newModel:PivotTo(finalCFrame)
```

La asimetría está dentro del mismo archivo: **recoger comprueba distancia, colocar no.** Ver
[BUG-CANDIDATE-023](../testing/verification-plan.md#bug-candidate-023).

**OBSERVACIÓN.** La propiedad se lleva por **nombre de jugador**, no por `UserId`:
`owner ~= player.Name` al comprobar, y `Players:FindFirstChild(owner)` al buscar. Roblox
permite cambiar de nombre de usuario. Quien lo cambie pierde el acceso a sus objetos
colocados, y quien adopte ese nombre lo gana. Es poco probable y fácil de evitar guardando
el `UserId`; se registra por completitud.

## Controles que sí sujetan

| Control | Cómo |
|---|---|
| **Un objeto que no existe no se puede conceder** | `getToolAsset` busca la `Tool` en `Assets/Tools` antes de `addItem` y `setItemCount`; un nombre inventado devuelve `false` |
| **La rueda no puede apuntar a lo que no tienes** | `setWheelSlot` exige `hasTool`, y `getWheelData` lo vuelve a filtrar al leer |
| **Un objeto no puede estar en dos slots** | `setWheelSlot` limpia tanto el slot destino como cualquier otro slot que ya tuviera ese objeto |
| **`Cannon` no se puede disparar con la herramienta de otro** | `tool.Parent ~= character` corta antes de nada, y hay cooldown de 5 s |
| **Los objetos por defecto no se re-conceden** | La bandera `defaultsInitialised` impide devolver a un jugador lo que ha gastado |
| **El guardado de la rueda está amortiguado** | 30 s de debounce, y se cancela si el jugador se va |
| **Recoger un objeto colocado exige estar cerca y ser su dueño** | `canUsePlacedModel`: contenedor, etiqueta, propiedad, personaje vivo y 30 studs de distancia |
| **Dos llamadas no operan sobre el mismo objeto colocado** | `modelLocks`, liberado en cada camino de salida, no solo en el feliz |
| **Solo se coloca lo que se lleva en la mano** | `character:FindFirstChild(toolName)` más el atributo `Colocable` |

## Puntos de verificación

| Aspecto | Entrada |
|---|---|
| El globo nunca se concede a nadie | [BUG-CANDIDATE-026](../testing/verification-plan.md#bug-candidate-026) |
| `ToolsServer` reparenta y manipula `Instance` arbitrarias del cliente | [BUG-CANDIDATE-027](../testing/verification-plan.md#bug-candidate-027) |
| Colocar una herramienta no comprueba dónde, aunque recogerla sí compruebe distancia | [BUG-CANDIDATE-023](../testing/verification-plan.md#bug-candidate-023) |

## Qué queda por leer

| Archivo | Líneas | Estado |
|---|---|---|
| `inventory/init.server.luau`, `InventoryManager/init.luau`, `DefaultTools.luau` | 706 | Leídos |
| `ToolsServer.server.luau` | 988 | **En parte** — los ocho manejadores y su validación; no la mecánica del cañón ni del guante |
| `ToolPlacementServer.server.luau` | 880 | **En parte** — los cuatro remotes, la validación y los cerrojos; no la mecánica de animaciones de apertura |
| `Client/inventory/` (4 archivos) | 908 | **Pendiente** — la rueda y la lista son interfaz |
| `Shared/ToolUseManagge.luau` | 108 | **Pendiente** — lo instancia `Data.Main` por jugador (`list.Agarre`) |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Remotes de inventario | `ServerScripts/inventory/init.server.luau` |
| Estado y persistencia | `inventory/InventoryManager/init.luau` |
| Objetos iniciales | `inventory/InventoryManager/DefaultTools.luau` |
| Sincronía con la mochila | `InventoryManager`, `syncPhysicalTool`, `normalizePhysicalTool`, `clearManagedPhysicalTools` |
| Comportamiento de cada herramienta | `ServerScripts/ToolsServer.server.luau` |
| Colocar y recoger en el mundo | `ServerScripts/ToolPlacementServer.server.luau`, `canUsePlacedModel`, `modelLocks` |
| Cooldowns | `Shared/Cooldown/CooldownManager` |
