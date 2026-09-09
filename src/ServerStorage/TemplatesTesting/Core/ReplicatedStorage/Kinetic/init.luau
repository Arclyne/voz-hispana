--!strict

local Animatable = require(script.animatable)
local Completion = require(script.util.Completion)
local Controller = require(script.core.Controller)
local FrameLoop = require(script.core.FrameLoop)
local Interpolation = require(script.core.Interpolation)
local SpringValue = require(script.core.SpringValue)
local Transition = require(script.orchestration.Transition)
local constants = require(script.constants)
local debugState = require(script.debug)
local instanceTarget = require(script.targets.instance)
local orchestration = require(script.orchestration)
local types = require(script.types)

export type SpringConfig = types.SpringConfig
export type SpringProps = types.SpringProps
export type AnimationResult = types.AnimationResult
export type Animatable = types.Animatable
export type ValueMap = types.ValueMap
export type Extrapolate = types.Extrapolate
export type AnimatableAdapter = types.AnimatableAdapter
export type Controller = Controller.Controller
export type SpringValue = SpringValue.SpringValue
export type Interpolation = Interpolation.Interpolation
export type Completion = Completion.Completion
export type ColorSpace = Animatable.ColorSpace
export type Transition = Transition.Transition
export type TransitionProps = Transition.TransitionProps

--[=[
	@class Kinetic

	Animacion basada en fisica de resortes para objetos **vanilla** de Roblox.

	Inspirada en [react-spring](https://www.react-spring.dev) y
	[roact-spring](https://www.chrisc.dev/roact-spring/docs/intro/), sin ninguna
	dependencia de React o Roact: Kinetic escribe directamente sobre instancias,
	atributos o callbacks.

	```lua
	local Kinetic = require(ReplicatedStorage.Packages.Kinetic)

	local api = Kinetic.animate(button, {
		Size = UDim2.fromOffset(200, 50),
		config = Kinetic.config.wobbly,
	})

	button.MouseEnter:Connect(function()
		api:start({ Size = UDim2.fromOffset(220, 60) })
	end)
	```

	La API tiene tres niveles, de mas azucarado a mas crudo:

	| Nivel | Constructor | Cuando |
	| --- | --- | --- |
	| 1 | [Kinetic.animate] | Propiedades de una instancia. El 90% de los casos. |
	| 2 | [Kinetic.controller] | Valores nombrados; tu decides donde escribirlos. |
	| 3 | [Kinetic.value] | Un solo valor. |

	:::caution Segundos, no milisegundos
	`delay` y `duration` van en **segundos**, a diferencia de react-spring. El resto
	del ecosistema de Roblox (`task.wait`, `TweenInfo`) usa segundos y mezclar
	unidades es una fuente seria de bugs. Kinetic avisa por consola si detecta un
	valor sospechosamente alto, por si vino copiado de un ejemplo de react-spring.
	:::
]=]
local Kinetic = {}

--[=[
	@prop VERSION string
	@within Kinetic
	@readonly
]=]
Kinetic.VERSION = "0.1.0"

--[=[
	@function animate
	@within Kinetic
	@param instance Instance
	@param props SpringProps
	@return Controller

	Anima propiedades de una instancia. El `from` de cada clave se toma del valor
	que la propiedad ya tiene, que es lo que hace ergonomica la API vanilla: no
	declaras el estado inicial, ya esta en el objeto.

	Las claves con prefijo `@` escriben atributos en vez de propiedades:

	```lua
	Kinetic.animate(part, { ["@Glow"] = 1 })
	```

	El controller se conecta a `Instance.Destroying` y se auto-destruye, para que
	destruir la instancia no deje un resorte corriendo sobre un objeto huerfano.

	:::info
	El adaptador de cada clave se resuelve una sola vez, al llamar a esta funcion, y
	no se revalida. Para propiedades nativas da igual (`Frame.Size` siempre es
	`UDim2`), pero un atributo no tiene tipo fijo: cambiarle el tipo mientras hay
	una animacion activa da resultados indefinidos.
	:::
]=]
function Kinetic.animate(instance: Instance, props: SpringProps): Controller.Controller
	return instanceTarget.animate(instance, props)
end

--[=[
	@function controller
	@within Kinetic
	@param props SpringProps?
	@return Controller

	Grupo de valores nombrados, con el sink a tu cargo via [Controller:onChange].

	```lua
	local ctrl = Kinetic.controller({
		from = { progress = 0, tint = Color3.new(1, 0, 0) },
		config = { tension = 210, friction = 20 },
	})

	ctrl:onChange(function(v)
		bar.Size = UDim2.fromScale(v.progress, 1)
		bar.BackgroundColor3 = v.tint
	end)

	ctrl:start({ progress = 1, tint = Color3.new(0, 1, 0) })
	```
]=]
function Kinetic.controller(props: SpringProps?): Controller.Controller
	return Controller.new(props)
end

--[=[
	@function value
	@within Kinetic
	@param initial Animatable
	@param config SpringConfig?
	@return SpringValue

	Un unico valor animable.

	```lua
	local x = Kinetic.value(0, Kinetic.config.stiff)
	x:onChange(function(v)
		frame.Position = UDim2.fromOffset(v, 0)
	end)
	x:start(200)
	```
]=]
function Kinetic.value(initial: types.Animatable, config: SpringConfig?): SpringValue.SpringValue
	return SpringValue.new(initial, config)
end

--[=[
	@function interpolate
	@within Kinetic
	@param source Interpolation
	@param mapper any
	@param output { Animatable }?
	@param extrapolate Extrapolate?
	@return Interpolation

	Valor derivado de otro, sin fisica propia. Normalmente se usa como
	`fuente:map(...)`; esta forma existe para fuentes personalizadas.
]=]
function Kinetic.interpolate(
	source: Interpolation.Source,
	mapper: any,
	output: any,
	extrapolate: types.Extrapolate?
): Interpolation.Interpolation
	return Interpolation.new(source, mapper, output, extrapolate)
end

--[=[
	@function trail
	@within Kinetic
	@param count number
	@param props SpringProps
	@return { Controller }

	`count` controllers encadenados por **fisica**: el primero va al destino y cada
	uno de los siguientes persigue la posicion actual del anterior, asi que el
	conjunto se mueve como una cadena con inercia real.

	```lua
	local apis = Kinetic.trail(#botones, {
		from = { y = 40 },
		y = 0,
	})
	apis[1]:start({ y = 0 })
	```

	:::tip Esto no es un stagger
	Para un desfase con retraso fijo (todos al mismo destino, solo escalonando el
	arranque) no hace falta nada de la biblioteca: basta `delay` en un bucle.

	```lua
	for i, boton in botones do
		Kinetic.animate(boton, { alpha = 0, delay = (i - 1) * 0.05 })
	end
	```
	:::
]=]
Kinetic.trail = orchestration.trail

--[=[
	@function sequence
	@within Kinetic
	@param steps { () -> Completion }
	@return Completion

	Ejecuta las animaciones una tras otra. Cada paso es una funcion que devuelve una
	[Completion]; se llama cuando le toca, no antes.
]=]
Kinetic.sequence = orchestration.sequence

--[=[
	@function parallel
	@within Kinetic
	@param completions { Completion }
	@return Completion

	Espera a que todas terminen. La [Completion] resultante se marca como cancelada
	si cualquiera de las de entrada lo fue.
]=]
Kinetic.parallel = orchestration.parallel

--[=[
	@function transition
	@within Kinetic
	@param props TransitionProps
	@return Transition

	Gestiona el ciclo de vida de instancias en una lista: enter / update / leave,
	destruyendo cada instancia **solo cuando su animacion de salida termina**.

	```lua
	local lista = Kinetic.transition({
		key = function(item) return item.id end,
		create = function() return plantilla:Clone() end,
		parent = scrollingFrame,
		from  = { BackgroundTransparency = 1, Position = UDim2.fromScale(0, -0.2) },
		enter = { BackgroundTransparency = 0, Position = UDim2.fromScale(0, 0) },
		leave = { BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0) },
		trail = 0.04,
	})

	lista:update(items)
	```

	El diff se hace por `key`, no por indice, para que reordenar la lista no cuente
	como que todo salio y volvio a entrar. Si un elemento vuelve mientras salia, se
	cancela su salida y regresa desde donde este, sin saltar.
]=]
Kinetic.transition = orchestration.transition

--[=[
	@prop config { [string]: SpringConfig }
	@within Kinetic
	@readonly

	Presets de configuracion fisica. Los valores son identicos a los de react-spring
	a proposito, para que la intuicion se transfiera entre bibliotecas.

	| Preset | tension | friction |
	| --- | --- | --- |
	| `default` | 170 | 26 |
	| `gentle` | 120 | 14 |
	| `wobbly` | 180 | 12 |
	| `stiff` | 210 | 20 |
	| `slow` | 280 | 60 |
	| `molasses` | 280 | 120 |
]=]
Kinetic.config = constants.config

--[=[
	@prop easings { [string]: EasingFunction }
	@within Kinetic
	@readonly

	Curvas estandar de [easings.net](https://easings.net): `linear`, y las familias
	`easeIn` / `easeOut` / `easeInOut` de `Quad`, `Cubic`, `Quart`, `Quint`, `Sine`,
	`Expo`, `Circ`, `Back`, `Elastic` y `Bounce`.

	Solo se usan cuando la config define `duration`; el camino por defecto es el
	resorte.
]=]
Kinetic.easings = constants.easings

--[=[
	@function registerType
	@within Kinetic
	@param adapter AnimatableAdapter

	Registra un adaptador para animar un tipo propio. Sobrescribe el existente si
	comparte nombre.
]=]
Kinetic.registerType = Animatable.register

--[=[
	@function setColorSpace
	@within Kinetic
	@param space "srgb" | "linear" | "oklab"

	Espacio en el que se interpolan los `Color3`. Default `linear`.

	Interpolar en `srgb` (el espacio en el que Roblox guarda `Color3`) oscurece el
	punto medio entre dos colores saturados. `linear` lo corrige sin coste
	apreciable. `oklab` es perceptualmente uniforme y da los degradados mas limpios,
	pero cuesta seis raices cubicas por frame y color.
]=]
Kinetic.setColorSpace = Animatable.setColorSpace

Kinetic.setDebugEnabled = debugState.setEnabled
Kinetic.isDebugEnabled = debugState.isEnabled
Kinetic.getStats = debugState.getStats

--[=[
	@prop internal table
	@within Kinetic
	@private

	Piezas internas expuestas para tests y herramientas. No forman parte de la API
	estable y pueden cambiar sin aviso.
]=]
Kinetic.internal = table.freeze({
	FrameLoop = FrameLoop,
	color = require(script.animatable.color),
	Interpolation = Interpolation,
	Animatable = Animatable,
	Controller = Controller,
	SpringValue = SpringValue,
})

return table.freeze(Kinetic)
