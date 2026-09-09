--!strict
--[[
	Telemetria opcional para el inspector.

	Un plugin de Studio y el juego corriendo son dos contextos de script distintos:
	el plugin no puede leer las tablas internas de Kinetic ni compartir su cache de
	`require`. Lo que si comparten es el DataModel, asi que la telemetria se publica
	como atributos de una carpeta y el plugin los lee desde alli.

	Esta apagado por defecto y no cuesta nada mientras lo este: sin llamar a
	`setEnabled(true)` no se crea la carpeta ni se conecta ningun bucle.
]]

local RunService = game:GetService("RunService")

local FrameLoop = require(script.Parent.core.FrameLoop)

local FOLDER_NAME = "KineticDebug"
local SAMPLE_INTERVAL = 0.25

local debugState = {}

local enabled = false
local folder: Folder? = nil
local connection: RBXScriptConnection? = nil

-- Ventana movil de tiempos de frame, para no publicar un numero que salte cada frame.
local samples: { number } = {}
local sampleIndex = 0
local SAMPLE_WINDOW = 60

local accumulator = 0

local function publish()
	local target = folder
	if not target then
		return
	end

	local count = #samples
	local total, worst = 0, 0
	for _, sample in samples do
		total += sample
		worst = math.max(worst, sample)
	end

	target:SetAttribute("ActiveNodes", FrameLoop.count())
	target:SetAttribute("FrameMs", if count > 0 then total / count else 0)
	target:SetAttribute("PeakMs", worst)
	target:SetAttribute("UpdatedAt", os.clock())
end

local function onHeartbeat(deltaTime: number)
	--[[
		Tomamos lo que el propio frame loop cronometro, no el intervalo entre frames.
		Medir el hueco entre heartbeats daria ~16.6 ms a 60 FPS: el coste de todo el
		juego, no el de Kinetic, y no seria comparable con el presupuesto de
		`docs/DESIGN.md` seccion 3.7.
	]]
	sampleIndex = sampleIndex % SAMPLE_WINDOW + 1
	samples[sampleIndex] = FrameLoop.getLastStepMs()

	accumulator += deltaTime
	if accumulator >= SAMPLE_INTERVAL then
		accumulator = 0
		publish()
	end
end

--[=[
	@function setDebugEnabled
	@within Kinetic
	@param on boolean

	Publica telemetria del frame loop para el inspector de Studio.

	Crea una carpeta `KineticDebug` en `ReplicatedStorage` con atributos
	`ActiveNodes`, `FrameMs`, `PeakMs` y `UpdatedAt`, refrescados cuatro veces por
	segundo. `FrameMs` es el coste **del propio Kinetic**, no el intervalo entre
	frames. Apagado por defecto; mientras lo este no cuesta nada.

	El plugin y el juego son contextos de script distintos y no comparten memoria,
	pero si el DataModel: por eso la telemetria viaja como atributos.
]=]
function debugState.setEnabled(on: boolean)
	if on == enabled then
		return
	end
	enabled = on

	if not on then
		if connection then
			(connection :: RBXScriptConnection):Disconnect()
			connection = nil
		end
		if folder then
			(folder :: Folder):Destroy()
			folder = nil
		end
		FrameLoop.setMeasuring(false)
		table.clear(samples)
		sampleIndex = 0
		return
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if existing then
		existing:Destroy()
	end

	local created = Instance.new("Folder")
	created.Name = FOLDER_NAME
	created:SetAttribute("ActiveNodes", 0)
	created:SetAttribute("FrameMs", 0)
	created:SetAttribute("PeakMs", 0)
	created:SetAttribute("UpdatedAt", 0)
	created.Parent = ReplicatedStorage
	folder = created

	FrameLoop.setMeasuring(true)
	connection = RunService.Heartbeat:Connect(onHeartbeat)
end

--[=[
	@function isDebugEnabled
	@within Kinetic
	@return boolean
]=]
function debugState.isEnabled(): boolean
	return enabled
end

--[=[
	@function getStats
	@within Kinetic
	@return { activeNodes: number, frameMs: number, peakMs: number }

	Instantanea de la telemetria, sin necesidad de leer los atributos. `activeNodes`
	siempre es valido; los tiempos solo se recogen mientras la telemetria este
	encendida, porque cronometrar el bucle cuesta dos `os.clock` por frame.
]=]
function debugState.getStats(): { activeNodes: number, frameMs: number, peakMs: number }
	local count = #samples
	local total, worst = 0, 0
	for _, sample in samples do
		total += sample
		worst = math.max(worst, sample)
	end

	return {
		activeNodes = FrameLoop.count(),
		frameMs = if count > 0 then total / count else 0,
		peakMs = worst,
	}
end

debugState.FOLDER_NAME = FOLDER_NAME

return debugState
