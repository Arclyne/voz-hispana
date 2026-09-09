--!strict
local Adapters = require(script.Parent.Adapters)
local Types = require(script.Parent.Adapters.Types)
local Signal = require(script.Parent.Signal)

local LEASE_MAP = "DataKitLeases"
local DEFAULT_TTL = 120
local DEFAULT_REFRESH = 30
local REFRESH_RETRY = 5

--[[
	¿MemoryStore nos está frenando? Es distinto de "MemoryStore falló": ante un fallo
	transitorio reintentar pronto es lo correcto; ante un throttle es justo lo que lo alarga.
]]
local function isThrottled(err: any): boolean
	local text = tostring(err)
	return string.find(text, "RequestThrottled", 1, true) ~= nil
		or string.find(text, "TotalRequestsOverLimit", 1, true) ~= nil
end

--[=[
	@class Lease

	Candado distribuido para un `id` (p.ej. un mundo), respaldado por MemoryStore con TTL.
	Un solo server posee el `id` a la vez. El TTL da la liveness: si el dueño deja de
	refrescar (crash), la key expira sola y otro server puede reclamarla —sin chequeos de
	tiempo cross-server—. `start()` mantiene la posesión con un timer propio, no acoplado a
	guardados. Dispara `OnLost()` si se pierde la posesión.

	El valor publicado es `{ owner, meta? }`: la `meta` (opcional, `setMeta`) viaja y expira
	junto con el candado, así el lease sirve también de **directorio en vivo** — quién hostea
	la identidad y cómo llegarle (`{ placeId, accessCode, players, ... }`). `Lease.peek` la
	consulta sin efectos.
]=]
local Lease = {}
Lease.__index = Lease

export type Options = {
	deps: Types.Deps?,
	ttl: number?,
	refreshInterval: number?,
	mapName: string?,
	meta: any?,
}

type Record = { owner: string, meta: any }

type self = {
	Id: string,
	ServerId: string,
	OnLost: Signal.Signal,
	_deps: Types.Deps,
	_map: Types.MemoryHashMapLike,
	_ttl: number,
	_refreshInterval: number,
	_nextRefresh: number,
	_hbConn: Types.Connection?,
	_lost: boolean,
	_throttled: boolean,
	_meta: any,
}

export type Lease = typeof(setmetatable({} :: self, Lease))

--[=[
	@within Lease

	Crea un handle de lease para `id`, con `serverId` como identidad del dueño (p.ej. `game.JobId`).
	`options.meta` es la metadata inicial que se publica con cada claim/refresh.
]=]
function Lease.new(id: string, serverId: string, options: Options?): Lease
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()

	local self = setmetatable({} :: self, Lease)
	self.Id = id
	self.ServerId = serverId
	self.OnLost = Signal.new()
	self._deps = deps
	self._map = deps.memoryStore:GetHashMap(opts.mapName or LEASE_MAP)
	self._ttl = opts.ttl or DEFAULT_TTL
	self._refreshInterval = opts.refreshInterval or DEFAULT_REFRESH
	self._nextRefresh = 0
	self._hbConn = nil
	self._lost = false
	self._throttled = false
	self._meta = opts.meta

	return self
end

--[=[
	@within Lease

	Consulta puntual y sin efectos del dueño actual de `id`: devuelve `(owner, meta)` o
	`(nil, nil)` si nadie lo posee (o MemoryStore falló). Es la cara de **directorio** del
	lease: el lobby pregunta quién hostea una identidad y cómo llegarle, sin tomar nada.
]=]
function Lease.peek(id: string, options: Options?): (string?, any?)
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()
	local map = deps.memoryStore:GetHashMap(opts.mapName or LEASE_MAP)
	local ok, value = pcall(map.GetAsync, map, id)
	if ok and type(value) == "table" and type(value.owner) == "string" then
		return value.owner, value.meta
	end
	return nil, nil
end

function Lease._currentRecord(self: Lease): Record?
	local ok, value = pcall(self._map.GetAsync, self._map, self.Id)
	if ok and type(value) == "table" and type(value.owner) == "string" then
		return value
	end
	return nil
end

--[=[
	@within Lease

	Reclama el lease (o renueva su TTL si ya somos el dueño), publicando la `meta` vigente.
	Es atómico: no toca un lease ajeno vivo. Devuelve `(tomado, dueñoActual, metaDelDueño)`.
]=]
function Lease.tryClaim(self: Lease): (boolean, string?, any?)
	local ok, result = pcall(self._map.UpdateAsync, self._map, self.Id, function(old: Record?): Record?
		if old == nil or old.owner == self.ServerId then
			return { owner = self.ServerId, meta = self._meta }
		end
		return nil
	end, self._ttl)

	if ok and type(result) == "table" and result.owner == self.ServerId then
		self._lost = false
		self._throttled = false
		return true, self.ServerId, self._meta
	end

	-- Un throttle no dice nada sobre quién es el dueño, y gastar otra petición en
	-- averiguarlo es tirar cuota justo cuando no queda. Devolvemos "no lo sé" (dueño nil),
	-- que el llamador ya trata como fallo transitorio y nunca como conflicto.
	if not ok and isThrottled(result) then
		self._throttled = true
		return false, nil, nil
	end
	self._throttled = false

	local record = self:_currentRecord()
	if record then
		return false, record.owner, record.meta
	end
	return false, nil, nil
end

--[=[
	@within Lease

	Actualiza la metadata que viaja con el lease (p.ej. `{ placeId, accessCode, status }`).
	Si el keepalive está corriendo, fuerza su publicación en el siguiente heartbeat; si no,
	se publica con el próximo `tryClaim`.
]=]
function Lease.setMeta(self: Lease, meta: any)
	self._meta = meta
	if self._hbConn then
		self._nextRefresh = 0
	end
end

--[=[
	@within Lease

	`true` si este server posee el lease ahora mismo (lee MemoryStore).
]=]
function Lease.isOwner(self: Lease): boolean
	local record = self:_currentRecord()
	return record ~= nil and record.owner == self.ServerId
end

function Lease._stopTimer(self: Lease)
	if self._hbConn then
		self._hbConn:Disconnect()
		self._hbConn = nil
	end
end

function Lease._onLost(self: Lease)
	if self._lost then
		return
	end
	self._lost = true
	self:_stopTimer()
	self.OnLost:Fire()
end

--[=[
	@within Lease

	Arranca el keepalive: renueva el lease por su propio timer (cada `refreshInterval`,
	holgado bajo el TTL). Dispara `OnLost` **solo** cuando observa a otro dueño; un fallo
	transitorio de MemoryStore no cede la posesión — reintenta en corto (`REFRESH_RETRY`)
	y, si la key llegó a expirar durante una caída sin que nadie la tomara, la re-reclama
	sin interrumpir la sesión (las escrituras quedan protegidas por el fence durable).
]=]
function Lease.start(self: Lease)
	if self._hbConn then
		return
	end

	self._nextRefresh = self._deps.now() + self._refreshInterval

	local function onHeartbeat()
		if self._deps.now() < self._nextRefresh then
			return
		end
		self._nextRefresh = self._deps.now() + self._refreshInterval
		local claimed, owner = self:tryClaim()
		if claimed then
			return
		end
		if owner ~= nil and owner ~= self.ServerId then
			self:_onLost()
		-- Si nos frenaron, mantenemos el intervalo normal que ya se fijó arriba: bajar a
		-- REFRESH_RETRY multiplica por seis las peticiones justo cuando no queda cuota, y el
		-- TTL es cuatro veces el intervalo, así que el lease aguanta de sobra.
		elseif not self._throttled then
			self._nextRefresh = self._deps.now() + math.min(REFRESH_RETRY, self._refreshInterval)
		end
	end

	self._hbConn = self._deps.connectHeartbeat(onHeartbeat)
end

--[=[
	@within Lease

	Libera el lease si lo poseemos (otro server podrá reclamarlo de inmediato).
]=]
function Lease.release(self: Lease)
	local record = self:_currentRecord()
	if record ~= nil and record.owner == self.ServerId then
		pcall(self._map.RemoveAsync, self._map, self.Id)
	end
end

--[=[
	@within Lease

	Detiene el keepalive y libera el lease.
]=]
function Lease.stop(self: Lease)
	self:_stopTimer()
	self:release()
end

return Lease
