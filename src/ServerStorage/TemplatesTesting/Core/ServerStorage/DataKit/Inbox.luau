--!strict
local Adapters = require(script.Parent.Adapters)
local Types = require(script.Parent.Adapters.Types)

local INBOX_MAP = "DataKitInbox"
local INBOX_TTL = 900

--[=[
	@class Inbox

	El **timbre** de los mensajes: un contador por identidad en MemoryStore que el emisor incrementa
	después de encolar y que el dueño sondea para saber si hay algo nuevo sin tener que escribir al
	DataStore.

	Es **puro acelerador y descartable**. La verdad vive en la cola dentro del key del DataStore (ver
	[BaseStore.Enqueue]); si MemoryStore falla, si el TTL expira o si el timbre se pierde entero, el
	mensaje se entrega igual — solo más tarde, cuando el dueño coseche en su próximo save o cuando
	alguien haga [BaseStore.Acquire]. Nada de acá puede perder un mensaje, porque nada de acá lo
	guarda.

	Por eso es un contador y no una cola: no hace falta borrar la marca ni acertarle al consumidor.
	El dueño recuerda el último valor que vio y cosecha cuando cambió; el TTL limpia solo.

	:::caution Módulo interno
	No se exporta desde la fachada [DataKit]. Se usa a través de `Store.send` y del sondeo interno de
	[Store].
	:::
]=]
local Inbox = {}

export type Options = {
	deps: Types.Deps?,
	mapName: string?,
}

local function mapFor(options: Options?): Types.MemoryHashMapLike
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()
	return deps.memoryStore:GetHashMap(opts.mapName or INBOX_MAP)
end

--[=[
	@within Inbox

	Toca el timbre de `key`: incrementa su contador. Best-effort — devuelve `false` si MemoryStore
	falló, y el llamador lo ignora a propósito, porque el mensaje ya está durable en el DataStore.
]=]
function Inbox.ring(key: string, options: Options?): boolean
	local map = mapFor(options)
	local ok = pcall(map.UpdateAsync, map, key, function(old: any): any
		return (if type(old) == "number" then old else 0) + 1
	end, INBOX_TTL)
	return ok
end

--[=[
	@within Inbox

	Lee el contador de `key`, o `nil` si nadie tocó el timbre (o si MemoryStore falló — para el
	sondeo son el mismo caso: no hay noticia, seguimos con lo que teníamos).
]=]
function Inbox.peek(key: string, options: Options?): number?
	local map = mapFor(options)
	local ok, value = pcall(map.GetAsync, map, key)
	if ok and type(value) == "number" then
		return value
	end
	return nil
end

return Inbox
