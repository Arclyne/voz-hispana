---
sidebar_position: 13
title: Trabajos
---

# Trabajos

Cuatro trabajos que un jugador puede desempeñar en el mundo para ganar moneda. Es el
sistema que quedaba sin documentar de los que tocan economía, y resulta ser **el mejor
diseñado del repositorio en cuanto a superficie remota** — con un detalle que conviene
conocer antes de tocarlo.

| Trabajo | Etiqueta | Módulo | Paga |
|---|---|---|---|
| Barra de bartender | `BarraBartender` | `Bartender.luau` | La mitad del precio del pedido (`Lerp(Price, .5)`) |
| Limpiar el suelo | `ClearFloors` | `LimpiarPiso.luau` | 20 Coins |
| Transportar cajas | `CajasWork` | `CajasTransport/init.luau` | *(en la ruta no leída)* |
| Botón VIP de dinero | `ButtonVipMoney` | `ButtonMoney/init.luau` | 10 Coins, tras una compra en Robux |

## Los remotes no están declarados: se crean en ejecución

**HECHO.** Y esto tiene una consecuencia directa sobre otra página de este sitio.
`Events/Jobs/` contiene **solo un `.gitkeep`**. Los cuatro `RemoteEvent` los fabrica el
propio sistema al arrancar:

```lua
if IsClient then
	Event = Events:WaitForChild(tag..'Event')
else
	Event = Instance.new('RemoteEvent')
	Event.Name = tag..'Event'
	Event.Parent = Events
end
```

El servidor los crea, el cliente los espera. Nacen llamándose `BarraBartenderEvent`,
`ClearFloorsEvent`, `CajasWorkEvent` y `ButtonVipMoneyEvent`.

:::caution El censo de remotes está incompleto por construcción

[Remotes](../reference/remotes.md) se genera leyendo los `.model.json` de Rojo, así que
cuenta lo **declarado**, no lo que existe en ejecución. Estos cuatro no aparecen ahí, y
cualquier otro sistema que use `Instance.new("RemoteEvent")` tampoco.

El número de esa página es un suelo, no un total.

:::

## Un solo remote por trabajo, y el cliente manda el nombre del método

**HECHO.** No hay un remote por acción. Hay uno por trabajo, y la acción viaja como cadena:

```lua
local function Interaccion(Player: Player, Object: Model, Key, ...)
	...
	local getMetatable = module.SearchModel(value.Instances, Object)
	if not getMetatable then
		return warn('model not found.')
	elseif typeof(Key) ~= "string" then
		return warn("key is not string")
	end
	...
	local funcionn = getMetatable[Key]
	if typeof(funcionn) == "function" then
```

Despachar por nombre desde el cliente es normalmente una mala idea: da acceso a cualquier
método del objeto. Aquí no, porque hay una lista blanca **por instancia**, y saltársela
cuesta la sesión:

```lua
if not table.find(getMetatable.WhiteList, Key) then
	if not IsClient then
		Player:Kick("Exploiter detected.")
	end
	return warn("no se permite esta funcion")
end
```

Las listas son cortas y explícitas:

| Trabajo | Métodos invocables |
|---|---|
| `Bartender` | `trabajar`, `renunciar`, `Preparar`, `ObtenerModelo` |
| `CajasTransport` | `trabajar`, `renunciar`, `GiveBox`, `SetFinishLocation`, `SetBox` |
| `LimpiarPiso` | `trabajar`, `renunciar` — y **lista vacía** para las instancias con `UniqueId` |
| `ButtonMoney` | `Buy` |

**Registrado como correcto, y es el mejor patrón del repositorio para esto.** El sistema
tiene un método `Fire` genérico, un despachador genérico y aun así la superficie real de
cada objeto son cuatro o cinco nombres declarados junto a él. `LimpiarPiso` incluso vacía
la lista para las instancias que no deben aceptar nada.

## El escalón que sí conviene conocer

**HECHO.** Antes de ejecutar el método, se aplican las condiciones que declare el modelo en
un atributo:

```lua
local condicionalTag = string.split(getMetatable.model:GetAttribute('conditional') or 'NoConditional', ",")
for _, condicional in condicionalTag do
	local modifi = EliminarEspacios(condicional)
	if modifi then
		if not condicionales[string.format("%s_%s", modifi, Key)](getMetatable, Player) then
			return warn(modifi)
		end
	end
end
```

Se busca `"<condición>_<método>"` en `ConditionsUses`, y se llama. Nótese que **no se
comprueba que exista** antes de invocarlo. Lo que evita el error es esta línea, que es todo
el módulo:

```lua
setmetatable(module, {__index = function() return function() return true end end})
```

Cualquier clave desconocida devuelve una función que devuelve `true`.

**OBSERVACIÓN — el valor por defecto es permitir.** Es lo que hace que el caso normal
—`NoConditional`, cuando el modelo no declara nada— funcione sin necesidad de escribir una
entrada por método. Pero significa también que **una condición mal escrita desaparece en
silencio**: `NoSignalCliente_SetFinishLocation` en lugar de `NoSignalClient_…` no da error,
no avisa, y permite la acción.

Hoy solo hay una condición real declarada, `NoSignalClient_SetFinishLocation`, y la usa
`CajasTransport`. El riesgo no está en lo que hay, está en lo que se añada: es la misma
forma de fallo abierto que [Dependencias](../architecture/dependencies.md) registra para
`VoiceChatService` y `TextService`.

## Un trabajo a la vez

**HECHO.** El servidor lleva `module.UsosPlayer[Player]`, y empezar uno nuevo renuncia
automáticamente al anterior:

```lua
module.UsosPlayer[Player] = getMetatable
if LastTrabajo then LastTrabajo:renunciar(Player) end
```

La liberación va atada a una señal que devuelve el propio método:

```lua
EventActive = DoneEvent:Connect(function()
	EventActive = disconnect.Disconnect(EventActive)
	if module.UsosPlayer[Player] == getMetatable then
		module.UsosPlayer[Player] = nil
	end
end)
```

**Registrado como correcto.** La comprobación `== getMetatable` antes de limpiar evita que
la señal tardía de un trabajo viejo borre el registro de uno nuevo — la misma clase de
guarda que `PlayerDataService.load` usa con `stores[player] == store`.

## Cómo entra y sale del juego

**HECHO.** El cableado y el ciclo de vida los lleva [`Data.Main`](./session-orchestrator.md):

```lua
local Jobs = require(modules:WaitForChild("JobSystem"))
Jobs.Monetization = Monetizacion
...
Jobs.init(true)          -- dentro de Init()
...
game:BindToClose(function()
	Jobs.disabled()      -- lo primero del apagado
```

`init` registra las etiquetas con `CollectionService`, crea los remotes e inyecta las
dependencias en los cuatro módulos. `enabled` / `disabled` son un interruptor global que
recorre todas las instancias, y `Jobs.disabled()` es **la primera línea** del `BindToClose`:
se detiene el trabajo antes de empezar a guardar.

## Controles que sí sujetan

| Control | Cómo |
|---|---|
| **Despacho por nombre acotado** | Lista blanca por instancia, y quien la burla recibe `Player:Kick("Exploiter detected.")` |
| **El modelo tiene que existir y estar registrado** | `SearchModel` lo busca entre las instancias etiquetadas; uno cualquiera devuelve `model not found` |
| **La clave tiene que ser una cadena** | Comprobado antes de indexar nada |
| **Un jugador no acumula trabajos** | `UsosPlayer` es uno por jugador, y el anterior renuncia solo |
| **Una señal tardía no pisa el trabajo nuevo** | La comparación `== getMetatable` antes de limpiar |
| **La compra del botón VIP no se solapa** | `Proccess[Player]` más `Monetization:MarkPrompt`, que ya trae su propio candado |
| **El pago del botón VIP ocurre solo si la compra tuvo éxito** | `mark:BindToClose`, comprobando `state == "Success"` |

## Puntos de verificación

| Aspecto | Entrada |
|---|---|
| Una condición mal escrita permite la acción en silencio | [BUG-CANDIDATE-032](../testing/verification-plan.md#bug-candidate-032) |

## Qué queda por leer

| Archivo | Líneas | Estado |
|---|---|---|
| `JobSystem/init.luau` | 304 | Leído |
| `JobSystem/ConditionsUses.luau` | 12 | Leído |
| `JobSystem/ButtonMoney/init.luau` | 245 | **En parte** — `Buy` y el ciclo de vida |
| `Bartender.luau` | 447 | **Pendiente** — solo se leyó dónde paga |
| `LimpiarPiso.luau` | 246 | **Pendiente** — ídem |
| `CajasTransport/init.luau` | 261 | **Pendiente** |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Registro y despacho | `Shared/JobSystem/init.luau`, `init`, `Interaccion` |
| Lista blanca | El campo `WhiteList` de cada módulo de trabajo |
| Condiciones | `Shared/JobSystem/ConditionsUses.luau` |
| Un trabajo por jugador | `init.luau`, `module.UsosPlayer` |
| Arranque y apagado | `Data/Main/init.server.luau`, `Jobs.init(true)` y `Jobs.disabled()` |
