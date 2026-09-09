--!strict
--[[
	El unico bucle de la biblioteca.

	Una conexion de RunService para todo el juego, no una por animacion. Los nodos
	se dan de alta al empezar a moverse y de baja al llegar al reposo; cuando el
	conjunto queda vacio la conexion se cierra y Kinetic deja de costar nada.

	Cliente -> RenderStepped: escribimos UI y queremos el valor mas fresco posible
	antes del render. Servidor -> Heartbeat: no hay render.
]]

local RunService = game:GetService("RunService")

local constants = require(script.Parent.Parent.constants)

-- Cualquier cosa que sepa avanzar en el tiempo. `advance` devuelve `true` si
-- sigue activa; `false` la da de baja.
export type Advanceable = {
	advance: (self: any, dt: number) -> boolean,
}

local FrameLoop = {}

local active: { [Advanceable]: true } = {}
local activeCount = 0
local connection: RBXScriptConnection? = nil

--[[
	Buffer para iterar sin que un `add`/`remove` durante `advance` invalide el
	recorrido: una animacion que termina y arranca otra en su `onRest` es normal.
]]
local batch: { Advanceable } = {}

--[[
	Medicion opcional del coste propio del bucle.

	Apagada por defecto: dos `os.clock` por frame no son gratis y solo interesan
	cuando el inspector esta abierto. Mide **lo que tarda Kinetic**, no el intervalo
	entre frames, que es lo unico comparable con el presupuesto de `docs/DESIGN.md`.
]]
local measuring = false
local lastStepMs = 0

local function step(deltaTime: number)
	local startedAt = if measuring then os.clock() else 0
	local dt = math.min(deltaTime, constants.MAX_DELTA)

	local n = 0
	for node in active do
		n += 1
		batch[n] = node
	end

	for i = 1, n do
		local node = batch[i]
		batch[i] = nil :: any

		-- Pudo darse de baja durante este mismo frame.
		if active[node] == nil then
			continue
		end

		local ok, stillActive = pcall(node.advance, node, dt)
		if not ok then
			-- Un nodo roto no puede tumbar el resto de animaciones del juego.
			FrameLoop.remove(node)
			task.spawn(error, stillActive)
		elseif not stillActive then
			FrameLoop.remove(node)
		end
	end

	if measuring then
		lastStepMs = (os.clock() - startedAt) * 1000
	end
end

local function ensureConnected()
	if connection then
		return
	end
	connection = if RunService:IsClient()
		then RunService.RenderStepped:Connect(step)
		else RunService.Heartbeat:Connect(step)
end

local function disconnectIfIdle()
	if activeCount > 0 or not connection then
		return
	end
	(connection :: RBXScriptConnection):Disconnect()
	connection = nil
end

-- Da de alta un nodo. Idempotente.
function FrameLoop.add(node: Advanceable)
	if active[node] then
		return
	end
	active[node] = true
	activeCount += 1
	ensureConnected()
end

-- Da de baja un nodo. Idempotente.
function FrameLoop.remove(node: Advanceable)
	if not active[node] then
		return
	end
	active[node] = nil
	activeCount -= 1
	disconnectIfIdle()
end

-- Activa el cronometraje del propio bucle. Lo usa la telemetria de `src/debug`.
function FrameLoop.setMeasuring(on: boolean)
	measuring = on
	if not on then
		lastStepMs = 0
	end
end

-- Milisegundos que costo el ultimo frame de Kinetic. `0` si no se esta midiendo.
function FrameLoop.getLastStepMs(): number
	return lastStepMs
end

function FrameLoop.isActive(node: Advanceable): boolean
	return active[node] ~= nil
end

-- Numero de nodos avanzando ahora mismo. Para tests y benchmarks.
function FrameLoop.count(): number
	return activeCount
end

--[[
	Avanza el bucle a mano con un delta fijo. Existe para los tests: permite
	simular 500 ms deterministas sin esperar 500 ms de reloj.
]]
function FrameLoop.stepManually(dt: number)
	step(dt)
end

return FrameLoop
