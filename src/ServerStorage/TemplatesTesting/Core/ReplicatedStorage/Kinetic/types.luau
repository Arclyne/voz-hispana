--!strict
--[[
	Tipos compartidos por toda la biblioteca.

	Vive en la raiz para que cualquier modulo pueda requerirlo sin crear ciclos:
	este archivo no requiere nada.
]]

--[=[
	@type EasingFunction (t: number) -> number
	@within Kinetic

	Curva de animacion. Recibe y devuelve un valor normalizado 0..1. Solo se usa
	cuando la config define `duration`.
]=]
export type EasingFunction = (t: number) -> number

--[=[
	@type Extrapolate "clamp" | "extend" | "identity"
	@within Kinetic

	Que hacer cuando la entrada de una interpolacion cae fuera de su rango.
	`clamp` la sujeta al extremo, `extend` sigue la recta, `identity` devuelve la
	entrada sin tocar.
]=]
export type Extrapolate = "clamp" | "extend" | "identity"

--[=[
	@interface SpringConfig
	@within Kinetic
	.mass number? -- Mas masa, mas friccion hace falta para frenar. Default `1`.
	.tension number? -- Rigidez del resorte. Con `0` no hay movimiento. Default `170`.
	.friction number? -- Amortiguacion: mas friccion, frena antes. Default `26`.
	.clamp boolean? -- Terminar en seco al llegar, sin sobrepasar. Default `false`.
	.precision number? -- Distancia minima para darse por llegado. Por defecto se deriva del recorrido.
	.velocity (number | { number })? -- Velocidad inicial en unidades por segundo. Un arreglo asigna una por escalar.
	.restVelocity number? -- Velocidad minima para considerarse quieto. Default `precision / 10`.
	.bounce number? -- Rebota en vez de sobrepasar: la velocidad se multiplica por `-1 + bounce` al cruzar el destino.
	.duration number? -- Duracion en **segundos**. Si esta, se ignora el resorte y manda `easing`.
	.easing EasingFunction? -- Curva, solo con `duration`. Default `easings.linear`.
	.progress number? -- Punto de arranque dentro del easing, 0..1. Default `0`.
	.damping number? -- Razon de amortiguacion, solo con `frequency`. `0` nunca frena, `1` frena sin rebotar.
	.frequency number? -- Frecuencia natural en segundos. Si esta, `tension` y `friction` se derivan de ella.
	.round number? -- Redondear la salida a este multiplo. Util para pixeles enteros.

	Configuracion fisica de un resorte. Todos los campos son opcionales.

	:::caution Segundos, no milisegundos
	`duration` va en **segundos**, a diferencia de react-spring. Ver [Kinetic] para el
	resto de props de tiempo.
	:::
]=]
export type SpringConfig = {
	mass: number?,
	tension: number?,
	friction: number?,
	clamp: boolean?,
	precision: number?,
	velocity: (number | { number })?,
	restVelocity: number?,
	bounce: number?,
	duration: number?,
	easing: EasingFunction?,
	progress: number?,
	damping: number?,
	frequency: number?,
	round: number?,
}

--[=[
	@type Animatable number | boolean | UDim | UDim2 | Vector2 | Vector3 | Color3 | Rect | NumberRange
	@within Kinetic

	Cualquier valor que Kinetic sabe descomponer en escalares.

	Deliberadamente sin `CFrame`: Kinetic esta enfocada en GUI. Animar partes en el
	mundo 3D ya lo cubre `TweenService`, y ese caso suele querer curvas predecibles
	en vez de fisica de resorte.

	`boolean` no se interpola: se trata siempre como `immediate`, util para `Visible`.
]=]
export type Animatable = number | boolean | UDim | UDim2 | Vector2 | Vector3 | Color3 | Rect | NumberRange

--[=[
	@type ValueMap { [string]: Animatable }
	@within Kinetic

	Mapa de clave a valor animable.
]=]
export type ValueMap = { [string]: Animatable }

--[=[
	@interface AnimationResult
	@within Kinetic
	.value Animatable -- Valor en el momento del evento.
	.finished boolean -- `true` si la animacion llego a su objetivo por si sola.
	.cancelled boolean -- `true` si la interrumpio un `stop` o una animacion nueva.

	Resultado que reciben `onStart`, `onRest` y las [Completion].
]=]
export type AnimationResult = {
	value: Animatable,
	finished: boolean,
	cancelled: boolean,
}

--[=[
	@interface SpringProps
	@within Kinetic
	.to (ValueMap | { ValueMap } | (next: (SpringProps) -> AnimationResult, cancel: () -> ()) -> ())? -- Destino. Un arreglo es una cadena de pasos; una funcion, un script asincrono.
	.from ValueMap? -- Origen. Por defecto, el valor actual.
	.delay (number | (key: string) -> number)? -- Segundos antes de arrancar.
	.loop (boolean | number | SpringProps | () -> boolean)? -- Repetir. Una tabla son props del reinicio.
	.reset boolean? -- Volver a `from` antes de animar.
	.reverse boolean? -- Intercambia `from` y `to`.
	.immediate (boolean | (key: string) -> boolean)? -- Saltar la animacion y escribir directo.
	.cancel (boolean | string | { string })? -- Cancelar claves en vuelo.
	.pause boolean? -- Congelar sin perder velocidad.
	.config (SpringConfig | (key: string) -> SpringConfig)? -- Fisica. Persiste entre llamadas a `start`.
	.onStart ((result: AnimationResult, key: string) -> ())? -- Al arrancar cada clave.
	.onChange ((values: ValueMap) -> ())? -- Una vez por frame, con todos los valores.
	.onRest ((result: AnimationResult, key: string) -> ())? -- Al llegar al reposo cada clave.
	.onPause ((result: AnimationResult, key: string) -> ())? -- Al pausar.
	.onResume ((result: AnimationResult, key: string) -> ())? -- Al reanudar.

	Props aceptadas por [Controller:start] y por los constructores.

	Las claves que no sean props reservadas se interpretan como destinos, es decir
	`{ x = 1 }` equivale a `{ to = { x = 1 } }`.

	:::caution Segundos, no milisegundos
	`delay` va en **segundos**, a diferencia de react-spring, donde son milisegundos.
	Kinetic avisa por consola si detecta un valor sospechosamente alto.
	:::
]=]
export type SpringProps = {
	to: (ValueMap | { ValueMap } | (next: (SpringProps) -> AnimationResult, cancel: () -> ()) -> ())?,
	from: ValueMap?,
	delay: (number | (key: string) -> number)?,
	loop: (boolean | number | SpringProps | () -> boolean)?,
	reset: boolean?,
	reverse: boolean?,
	immediate: (boolean | (key: string) -> boolean)?,
	cancel: (boolean | string | { string })?,
	pause: boolean?,
	config: (SpringConfig | (key: string) -> SpringConfig)?,

	onStart: ((result: AnimationResult, key: string) -> ())?,
	onChange: ((values: ValueMap) -> ())?,
	onRest: ((result: AnimationResult, key: string) -> ())?,
	onPause: ((result: AnimationResult, key: string) -> ())?,
	onResume: ((result: AnimationResult, key: string) -> ())?,

	[string]: any,
}

--[=[
	@interface AnimatableAdapter
	@within Kinetic
	.name string -- Nombre del tipo, tal como lo devuelve `typeof`.
	.arity number -- Cuantos escalares ocupa.
	.decompose (value: any, out: { number }, offset: number?) -> { number } -- Aplana el valor escribiendo en `out` desde `offset`.
	.compose (scalars: { number }, offset: number) -> any -- Reconstruye el valor a partir de los escalares.
	.discrete boolean? -- `true` si el tipo no se interpola y debe tratarse como `immediate`.

	Traduce un tipo de Roblox a escalares y de vuelta. Registrar uno con
	[Kinetic.registerType] permite animar tipos propios sin tocar el motor.

	`decompose` escribe sobre `out` en lugar de asignar una tabla nueva porque se
	llama en el camino caliente del frame loop.
]=]
export type AnimatableAdapter = {
	name: string,
	arity: number,
	decompose: (value: any, out: { number }, offset: number?) -> { number },
	compose: (scalars: { number }, offset: number) -> any,
	discrete: boolean?,
}

-- Modulo puramente de tipos: no expone valores en tiempo de ejecucion.
return {}
