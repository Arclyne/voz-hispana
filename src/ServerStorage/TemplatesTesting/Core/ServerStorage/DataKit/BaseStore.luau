--!strict
local Adapters = require(script.Parent.Adapters)
local Types = require(script.Parent.Adapters.Types)
local Signal = require(script.Parent.Signal)
local Mutex = require(script.Parent.Mutex)
local Health = require(script.Parent.Health)
local deepCopy = require(script.Parent.Util.deepCopy)
local reconcile = require(script.Parent.Util.reconcile)
local retry = require(script.Parent.Util.retry)

local DATASTORE_VERSION = 3
local FENCE_KEY = "__dkFence"
local DATA_KEY = "__dkData"
local MSGS_KEY = "__dkMsgs"

--[=[
	@interface Message
	@within BaseStore

	Una entrada de la cola de mensajes del sobre: `id` es el correlativo que asigna
	[BaseStore.Enqueue] (monotónico por key) y `body` el payload que mandó el emisor. El `id` es lo
	que se pasa como consumido a [BaseStore.CommitOwned] para drenarlo.
]=]
export type Message = { id: number, body: any }

type Queue = { seq: number, list: { Message } }

local function emptyQueue(): Queue
	return { seq = 0, list = {} }
end

local function readQueue(stored: any): Queue
	if type(stored) == "table" then
		local msgs = stored[MSGS_KEY]
		if type(msgs) == "table" and type(msgs.seq) == "number" and type(msgs.list) == "table" then
			return msgs
		end
	end
	return emptyQueue()
end

-- Un sobre escrito antes de que existieran los mensajes no trae `__dkMsgs`: se lee como cola
-- vacía, así que no hay migración de datos que hacer.
local function unwrap(stored: any): (number, any, Queue)
	if type(stored) == "table" and type(stored[FENCE_KEY]) == "number" then
		return stored[FENCE_KEY], stored[DATA_KEY], readQueue(stored)
	end
	return 0, stored, emptyQueue()
end

local function wrap(fence: number, data: any, msgs: Queue?): any
	local envelope: { [string]: any } = {}
	envelope[FENCE_KEY] = fence
	envelope[DATA_KEY] = data
	envelope[MSGS_KEY] = msgs or emptyQueue()
	return envelope
end

--[=[
	@class BaseStore

	Motor de un DataStore. Compone [Mutex], [Health], `retry`, `reconcile` y
	`deepCopy` tras una API de alto nivel. Recibe `deps` inyectables (por defecto,
	los servicios reales) para ser testeable. Reexpone las señales de salud
	`OnError(msg)` y `OnCriticalToggle(critical)`.

	:::caution Módulo interno
	`BaseStore` **no se exporta** desde la fachada [DataKit]: no es API pública y no hay
	compromiso de estabilidad sobre él. Se consume a través de [Store] / [Profile], que son los
	que garantizan un solo escritor (lease + fence). Escribir por acá salteándose esa capa es
	justo lo que rompe la garantía de "nunca duplicar".

	Por eso conserva el estilo PascalCase de la API de DataStore de Roblox (`GetAsync`,
	`UpdateAsync`, `Acquire`) y las señales como propiedades, en vez del camelCase con
	métodos-evento de [Store]: es la capa que calca al servicio, no la que exponemos.
	:::
]=]
local BaseStore = {}
BaseStore.__index = BaseStore
BaseStore.__tostring = function(self: { Name: string }): string
	return `<BaseStore:{self.Name}>`
end

type self = {
	Name: string,
	_store: Types.DataStoreLike,
	_template: any?,
	OnError: Signal.Signal,
	OnCriticalToggle: Signal.Signal,
	_deps: Types.Deps,
	_health: Health.Health,
	_mutex: Mutex.Mutex,
}
export type BaseStore = typeof(setmetatable({} :: self, BaseStore))

--[=[
	@within BaseStore
]=]
function BaseStore.new(storeName: string, template: any?, deps: Types.Deps?): BaseStore
	assert(typeof(storeName) == "string", "[BaseStore] storeName must be string")
	local resolvedDeps = deps or Adapters.defaultDeps()

	local self = setmetatable({} :: self, BaseStore)
	self.Name = storeName
	self._deps = resolvedDeps
	self._store = resolvedDeps.dataStore:GetDataStore(storeName)
	self._template = template

	self._health = Health.new(resolvedDeps.now)
	self._mutex = Mutex.new()
	self.OnError = self._health.OnError
	self.OnCriticalToggle = self._health.OnCriticalToggle

	return self
end

function BaseStore._withVersion(_self: BaseStore, key: string): string
	return key .. "__v" .. tostring(DATASTORE_VERSION)
end

--[=[
	@within BaseStore
]=]
function BaseStore.IsCriticalState(self: BaseStore): boolean
	return self._health:isCritical()
end

function BaseStore._run(self: BaseStore, fn: (...any) -> any, ...: any): (boolean, any)
	local ok, res = retry({ wait = self._deps.wait, label = "BaseStore" }, fn, ...)
	if not ok then
		self._health:recordFailure(tostring(res))
	end
	return ok, res
end

--[=[
	@within BaseStore
]=]
function BaseStore.GetAsync(self: BaseStore, key: string): (boolean, any)
	local ok, raw = self:_run(self._store.GetAsync, self._store, self:_withVersion(key))
	if not ok then
		return false, raw
	end
	local _, data = unwrap(raw)
	return true, data
end

--[=[
	@within BaseStore

	Lectura barata de la **cola de mensajes** de `key` (un `GetAsync`, sin escribir ni tomar
	propiedad). Es el camino del sondeo: cuando el timbre avisa que llegó algo, esto lo confirma
	sin gastar presupuesto de escritura. Devuelve `(ok, list)`.
]=]
function BaseStore.PeekMessages(self: BaseStore, key: string): (boolean, { Message })
	local ok, raw = self:_run(self._store.GetAsync, self._store, self:_withVersion(key))
	if not ok then
		return false, {}
	end
	local _, _, msgs = unwrap(raw)
	return true, msgs.list
end

--[=[
	@within BaseStore

	Encola un mensaje para `key` **sin ser su dueño**: un `UpdateAsync` que solo appendea a la cola
	del sobre y reescribe el mismo fence y la misma data. Por eso funciona igual si otro server tiene
	la identidad cargada, si no la tiene nadie, o si el key todavía no existe.

	El mensaje espera en el sobre hasta que un dueño lo coseche ([BaseStore.Acquire] al cargar, o
	[BaseStore.CommitOwned] en cada save) — esa es la durabilidad que MessagingService no da.
	`maxMessages` recorta la cola por la cabeza (se descartan los más viejos) para que un consumidor
	que nunca vuelve no haga crecer el key sin límite.
]=]
function BaseStore.Enqueue(self: BaseStore, key: string, message: any, maxMessages: number): (boolean, any)
	local k = self:_withVersion(key)
	local token = self.Name .. k
	self._mutex:lock(token)
	local ok, res = self:_run(self._store.UpdateAsync, self._store, k, function(stored: any): any
		local fence, data, msgs = unwrap(stored)
		msgs.seq += 1
		table.insert(msgs.list, { id = msgs.seq, body = message })
		while #msgs.list > maxMessages do
			table.remove(msgs.list, 1)
		end
		return wrap(fence, data, msgs)
	end)
	self._mutex:unlock(token)
	if not ok then
		return false, res
	end
	return true, nil
end

--[=[
	@within BaseStore

	Escribe `value` preservando el resto del sobre (el fence durable y la cola de mensajes): pasa por
	`UpdateAsync` para no resetearlos (un fence reseteado dejaría que un dueño viejo volviera a
	commitear sobre el dueño vigente; una cola reseteada perdería mensajes sin entregar). No valida
	propiedad; para el camino del escritor usa [BaseStore.CommitOwned].
]=]
function BaseStore.SetAsync(self: BaseStore, key: string, value: any): (boolean, any)
	local k = self:_withVersion(key)
	local token = self.Name .. k
	self._mutex:lock(token)
	local ok, res = self:_run(self._store.UpdateAsync, self._store, k, function(stored: any): any
		local fence, _, msgs = unwrap(stored)
		return wrap(fence, value, msgs)
	end)
	self._mutex:unlock(token)
	if not ok then
		return false, res
	end
	return true, nil
end

--[=[
	@within BaseStore

	Borra el sobre completo, fence incluido: la siguiente adquisición arranca desde 1, así
	que un dueño viejo con fence mayor podría volver a commitear. No lo llames sobre una
	identidad con un escritor vivo.
]=]
function BaseStore.RemoveAsync(self: BaseStore, key: string): (boolean, any)
	return self:_run(self._store.RemoveAsync, self._store, self:_withVersion(key))
end

--[=[
	@within BaseStore

	Toma la propiedad de `key` para escribir: sube atómicamente el *fence* durable (guardado en
	el propio DataStore), siembra/reconcilia el template y devuelve `(ok, fence, data, msgs)`. El
	`fence` obtenido debe pasarse a [BaseStore.CommitOwned] en cada escritura. Es el camino del
	escritor; como el fence vive en el DataStore (durable), sobrevive a la pérdida del candado en
	MemoryStore.

	`msgs` es la cola de [BaseStore.Message] que estaba esperando en el sobre: todo lo que se encoló
	mientras la identidad no tenía dueño se cosecha acá, en la misma lectura que ya hacíamos.
]=]
function BaseStore.Acquire(self: BaseStore, key: string, template: any?): (boolean, number, any, { Message })
	local k = self:_withVersion(key)
	local token = self.Name .. k
	local newFence = 0
	local newData: any = nil
	local newMsgs: { Message } = {}

	self._mutex:lock(token)
	local ok = self:_run(self._store.UpdateAsync, self._store, k, function(stored: any): any
		local prevFence, data, msgs = unwrap(stored)
		local tmpl = template or self._template
		if data == nil then
			if tmpl ~= nil then
				data = deepCopy(tmpl)
			end
		elseif tmpl ~= nil then
			reconcile(data, tmpl)
		end
		newFence = prevFence + 1
		newData = data
		newMsgs = msgs.list
		return wrap(newFence, data, msgs)
	end)
	self._mutex:unlock(token)

	if not ok then
		return false, 0, nil, {}
	end
	return true, newFence, deepCopy(newData), deepCopy(newMsgs)
end

--[=[
	@within BaseStore

	Escribe `value` en `key` **solo si seguimos siendo el dueño**: la escritura va dentro de un
	`UpdateAsync` que rechaza el guardado si el fence almacenado supera al `fence` que sostenemos
	(otro server tomó la propiedad después). Devuelve `(committed, stale, msgs)`: `stale = true`
	significa que perdimos la propiedad y la escritura se descartó (nunca pisa al dueño nuevo).
	`committed` y `stale` en `false` a la vez = fallo transitorio del DataStore (reintentar).

	`consumed` son los ids de [BaseStore.Message] que el dueño ya aplicó a su data: se borran de la
	cola **dentro de este mismo `UpdateAsync`**, o sea que el mensaje deja de existir exactamente
	cuando persiste la mutación que causó. Si la escritura falla o queda `stale`, el mensaje sigue
	en la cola y se re-entrega — nunca queda "consumido pero sin efecto".

	`msgs` es la cola que quedó tras el drenado: la cosecha de lo que llegó desde la última vez, sin
	costar una request extra (la escritura iba a pasar igual).
]=]
function BaseStore.CommitOwned(
	self: BaseStore,
	key: string,
	fence: number,
	value: any,
	consumed: { [number]: boolean }?
): (boolean, boolean, { Message })
	local k = self:_withVersion(key)
	local token = self.Name .. k
	local aborted = false
	local newMsgs: { Message } = {}

	self._mutex:lock(token)
	local ok = self:_run(self._store.UpdateAsync, self._store, k, function(stored: any): any
		local prevFence, _, msgs = unwrap(stored)
		if prevFence > fence then
			aborted = true
			return nil
		end
		if consumed then
			for i = #msgs.list, 1, -1 do
				if consumed[msgs.list[i].id] then
					table.remove(msgs.list, i)
				end
			end
		end
		newMsgs = msgs.list
		return wrap(fence, value, msgs)
	end)
	self._mutex:unlock(token)

	if not ok then
		return false, false, {}
	end
	if aborted then
		return false, true, {}
	end
	return true, false, deepCopy(newMsgs)
end

return BaseStore
