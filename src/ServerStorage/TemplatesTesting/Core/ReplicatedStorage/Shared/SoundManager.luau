--[[
     SoundManager sirve para reproducir sonidos de manera sencilla tanto
     en script local como de servidor.
     ---------------
     Ejemplo de uso:
     local RS = game:GetService("ReplicatedStorage")
	local SoundManager = require(RS:WaitForChild("SoundManager"))
	
	-- Sonar para un jugador concreto (sólo él lo oirá, vía PlayLocalSound)
	SoundManager:Play(somePlayer, 12345678, { Volume = 0.8 })
	
	-- Sonar para todos los clientes (sin parent: todos usan PlayLocalSound)
	SoundManager:Play(nil, 87654321)
	
	-- Forzar sonido “global” en un Part del mundo 
	SoundManager:Play(nil, 87654321, { Volume = 1 }, workspace.SomePart)

--]]

-- SoundManager (smooth: cache/pool + preload)
local RunService      = game:GetService("RunService")
local SoundService    = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local RS              = game:GetService("ReplicatedStorage")

local PlaySoundRE = RS:WaitForChild("Events")
	:WaitForChild("Player")
	:WaitForChild("PlaySound")

local SoundManager = {}
SoundManager.__index = SoundManager

-- Cache débil por parent (para que al destruir el parent se libere solo)
-- cache[parent][soundKey] = { sounds = {Sound,Sound,...}, index = 1 }
SoundManager._cache = setmetatable({}, { __mode = "k" })

local function makeSoundId(soundId: any): string
	local id = tostring(soundId)
	if id:find("^rbxassetid://") then
		return id
	end
	return "rbxassetid://" .. id
end

local function applyParams(sound: Sound, params: table?, targetParent: Instance?)
	-- Valores por defecto para sonidos espaciales (3D en el mundo)
	if targetParent and targetParent ~= SoundService then
		sound.RollOffMinDistance = 10
		sound.RollOffMaxDistance = 60
		sound.RollOffMode = Enum.RollOffMode.InverseTapered
	end

	if not params then return end
	for key, value in pairs(params) do
		-- claves internas nuestras
		if key == "Name" or key == "Pool" or key == "NoCache" then
			continue
		end
		if sound[key] ~= nil then
			sound[key] = value
		end
	end
end

local function getBucket(cache, parent)
	local bucket = cache[parent]
	if not bucket then
		bucket = {}
		cache[parent] = bucket
	end
	return bucket
end

local function getOrCreatePool(parent: Instance, soundKey: string, params: table?)
	local bucket = getBucket(SoundManager._cache, parent)
	local pool = bucket[soundKey]

	local poolSize = 1
	if params and typeof(params.Pool) == "number" then
		poolSize = math.clamp(math.floor(params.Pool), 1, 8)
	end

	if not pool then
		pool = { sounds = {}, index = 1 }
		bucket[soundKey] = pool
	end

	-- Asegura tamaño de pool
	while #pool.sounds < poolSize do
		local s = Instance.new("Sound")
		s.SoundId = soundKey
		s.Name = (params and params.Name) or soundKey
		applyParams(s, params, parent)
		s.Parent = parent
		table.insert(pool.sounds, s)

		-- Intento de preload "no bloqueante" si aún no está cargado
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync({ s })
			end)
		end)
	end

	-- Si bajaron el poolSize, no borro (no hace daño), así evitas churn
	return pool
end

-- Helper interno del cliente: reproduce usando pool/cache
function SoundManager:_playClient(soundId, params, parent)
	local soundKey = makeSoundId(soundId)

	-- Decide dónde reproducir
	local targetParent: Instance = SoundService
	local spatial = false
	if parent and parent:IsA("Instance") then
		targetParent = parent
		spatial = true
	end

	-- Si el usuario quiere desactivar cache para un caso concreto
	if params and params.NoCache == true then
		local s = Instance.new("Sound")
		s.SoundId = soundKey
		s.Name = (params and params.Name) or soundKey
		applyParams(s, params, targetParent)

		if spatial then
			s.Parent = targetParent
			s:Play()
		else
			s.Parent = SoundService
			SoundService:PlayLocalSound(s)
		end

		if not s.Looped then
			s.Ended:Connect(function()
				s:Destroy()
			end)
		end
		return s
	end

	-- Cache/pool
	local pool = getOrCreatePool(targetParent, soundKey, params)
	local sounds = pool.sounds

	-- round-robin
	local idx = pool.index
	local s = sounds[idx]
	pool.index = (idx % #sounds) + 1

	-- Por si el parent se destruyó entre medias
	if not s or not s.Parent then
		-- recrea el pool y vuelve a intentar una vez
		pool = getOrCreatePool(targetParent, soundKey, params)
		sounds = pool.sounds
		s = sounds[1]
	end

	-- Aplica params (por si cambian volumen, etc.)
	if params and params.Name then
		s.Name = params.Name
	end
	applyParams(s, params, targetParent)

	-- Reinicia y reproduce
	s:Stop()
	s.TimePosition = 0

	if spatial then
		s:Play()
	else
		-- PlayLocalSound para local-only (más inmediato y sin “mundo”)
		SoundService:PlayLocalSound(s)
	end

	return s
end

-- Preload de uno o varios sonidos (llámalo antes de spamear ticks)
-- soundIds: {number|string|...}
function SoundManager:Preload(soundIds: {any}, parent: Instance?, params: table?)
	if not RunService:IsClient() then
		-- opcional: si lo llamas en server, se lo pides al cliente (no lo hago aquí)
		return
	end

	local list = {}
	for _, id in ipairs(soundIds) do
		local s = Instance.new("Sound")
		s.SoundId = makeSoundId(id)
		s.Name = (params and params.Name) or tostring(id)
		applyParams(s, params, parent or SoundService)
		s.Parent = parent or SoundService
		table.insert(list, s)
	end

	-- Preload bloquea un poco, pero es mejor hacerlo al abrir UI / al acercarte
	pcall(function()
		ContentProvider:PreloadAsync(list)
	end)

	for _, s in ipairs(list) do
		s:Destroy()
	end
end

function SoundManager:Play(target, soundId, params, parent)
	if RunService:IsServer() then
		-- SERVER: pide al cliente que reproduzca
		local sid = tostring(soundId)
		if typeof(target) == "Instance" and target:IsA("Player") then
			PlaySoundRE:FireClient(target, sid, params, parent)
		else
			PlaySoundRE:FireAllClients(sid, params, parent)
		end
	else
		-- CLIENT
		self:_playClient(soundId, params, parent)
	end
end

if RunService:IsClient() then
	PlaySoundRE.OnClientEvent:Connect(function(soundId, params, parent)
		SoundManager:_playClient(soundId, params, parent)
	end)
end

return SoundManager