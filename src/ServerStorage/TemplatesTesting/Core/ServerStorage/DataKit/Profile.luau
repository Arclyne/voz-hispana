--!strict
local Store = require(script.Parent.Store)
local Lease = require(script.Parent.Lease)

--[=[
	@class Profile

	Capa declarativa sobre [Store]. Con `define` declaras el nombre, el template y las
	opciones una sola vez; `load(id)` crea el [Store] para esa identidad sin repetir la
	config. Es agnóstico a la identidad (un `userId`, un `worldId`, lo que sea): no sabe nada
	de jugadores ni de sesiones.

	```lua
	local PlayerProfile = Profile.define("Player", {
		level = 1,
		xp = 0,
		inventory = { items = {} },
	})

	local store = PlayerProfile.load(tostring(player.UserId))
	store:awaitReady()
	store:update(function(data)
		data.xp += 100
		return data
	end)
	store:close()
	```

	`Profile` es una **fábrica**, no un store vivo: no expone estado de sesión ni de salud. Eso
	vive en el [Store] que devuelve `load(id)` — [Store.canWrite], [Store.isCriticalState],
	[Store.onCriticalToggle]. Los estáticos (`read`, `readCard`, `peek`) crean un store efímero
	por llamada, así que no hay salud acumulada que consultar a nivel perfil.
]=]
local Profile = {}

--[=[
	@interface Definition
	@within Profile

	El resultado de `define`: `load(id, overrides?)` produce un [Store] con el nombre, template
	y opciones declarados (los `overrides` por-llamada ganan — p.ej. la `leaseMeta` propia de este
	server). `read(id)` hace una lectura puntual sin candado (ver [Store.read]) y devuelve
	`(data, ok)` — `ok = false` si la lectura falló, para no confundir "DataStore caído" con "sin
	datos". `peek(id)` consulta el directorio en vivo (ver [Store.peekOwner]): `(owner, meta)`
	del server que lo hostea, o `nil` si nadie. `claimStaged(id, stageMeta?)` toma la reserva de
	staging del lobby antes de `ReserveServer` (ver [Store.claimStaged]) y `peekStaged(id)` la
	consulta. Si el perfil declara `card`/`cards` (ver [Store.CardSpec]), `readCard(id, cardName?)`
	lee la tarjeta proyectada (con `cardName` selecciona una del mapa plural `cards`). `send(id,
	message)` le manda un mensaje a la identidad **esté hosteada o no** (ver [Store.send]); lo
	consume el handler `onMessage` que declaró el perfil. `Name` y `Template` quedan expuestos para
	introspección.
]=]
export type Options = Store.Options

export type Definition = {
	Name: string,
	Template: any,
	load: (id: string, overrides: Store.Options?) -> Store.Store,
	read: (id: string) -> (any, boolean),
	peek: (id: string) -> (string?, any?),
	claimStaged: (id: string, stageMeta: any?) -> (Lease.Lease?, Store.CurrentHost?),
	peekStaged: (id: string) -> (string?, any?),
	readCard: (id: string, cardName: string?) -> (any, boolean),
	send: (id: string, message: any) -> boolean,
}

local function mergeOptions(base: Store.Options?, overrides: Store.Options?): Store.Options?
	if base == nil then
		return overrides
	end
	if overrides == nil then
		return base
	end
	local merged: { [string]: any } = table.clone(overrides :: any)
	for key, value in base :: any do
		if merged[key] == nil then
			merged[key] = value
		end
	end
	return merged :: any
end

--[=[
	@within Profile

	Declara un perfil reutilizable: `define(name, template, options?)`. `name` es el prefijo del
	DataStore/lease; `template` es la forma por default (se reconcilia sobre lo cargado). Las
	`options` declaradas se aplican a cada `load`, y los `overrides` de un `load` puntual las pisan.

	Todas las `options` (todas opcionales):

	- `store: string?` — nombre del DataStore. Default: `name`. Úsalo para renombrar en código sin
	  mover datos, o para apuntar a un DataStore existente.
	- `singleWriter: boolean?` — toma el [Lease] antes de cargar (un solo escritor). Default `true`.
	  `false` = carga de solo-lectura sin candado.
	- `serverId: string?` — id de este server para el lease. Default: `deps.serverId` (`game.JobId`).
	- `onConflict: "steal" | "deny"` — qué hacer si otro server ya posee la identidad. Default
	  `"steal"` (espera a que el dueño muera/suelte). `"deny"` cede de inmediato (evento onDenied).
	- `stealTimeout: number?` — segundos que `"steal"` espera a un dueño vivo antes de rendirse.
	  Default `150`.
	- `autosaveInterval: number?` — segundos entre autosaves de lo dirty. Default `300`.
	- `leaseMeta: any?` — metadata publicada con el lease (`{ placeId, accessCode, ... }`); la ven
	  `peek` y el evento onDenied. Actualizable en caliente con `store:setLeaseMeta(meta)`.
	- `card: CardSpec?` — proyección declarativa hacia una tarjeta chica que el lobby lee sin cargar
	  la identidad (ver [Store.CardSpec]). `{ project, store?, onChange? }`.
	- `cards: { [string]: CardSpec }?` — varias tarjetas por identidad (p.ej. pública + `admin`),
	  cada una a su propio DataStore; se leen con `readCard(id, name)`.
	- `onMessage: (data, message) -> data?` — consumidor de los mensajes que llegan por `send` (ver
	  [Store.send]). Devolver la data **consume** el mensaje (se borra de la cola en la misma
	  escritura que persiste la mutación); devolver `nil` lo deja para el próximo ciclo. Ojo: si vas
	  a devolver `nil`, **no mutes `data`** — la mutación quedaría aplicada sin que el mensaje se
	  consuma, y se volvería a aplicar al reintentar. Sin este handler la identidad no consume nada
	  (los mensajes se acumulan en su key hasta que alguien los atienda).
	- `messagePoll: number?` — segundos entre sondeos del timbre, o sea la latencia típica de un
	  mensaje cuando la identidad está cargada. Default `10`. Cuesta una lectura de MemoryStore por
	  identidad viva por intervalo: súbelo si tenés muchas identidades con `onMessage` por server.
	- `maxMessages: number?` — tope de mensajes sin consumir por identidad; al pasarlo se descartan
	  los más viejos. Default `1000`.
	- `deps: Deps?` — inyección de dependencias (servicios). Default: los servicios reales. Para tests.
]=]
function Profile.define(name: string, template: any, options: Store.Options?): Definition
	return {
		Name = name,
		Template = template,
		load = function(id: string, overrides: Store.Options?): Store.Store
			return Store.new(name, template, id, mergeOptions(options, overrides))
		end,
		read = function(id: string): (any, boolean)
			return Store.read(name, template, id, options)
		end,
		peek = function(id: string): (string?, any?)
			return Store.peekOwner(name, id, options)
		end,
		claimStaged = function(id: string, stageMeta: any?): (Lease.Lease?, Store.CurrentHost?)
			return Store.claimStaged(name, id, options, stageMeta)
		end,
		peekStaged = function(id: string): (string?, any?)
			return Store.peekStaged(name, id, options)
		end,
		readCard = function(id: string, cardName: string?): (any, boolean)
			return Store.readCard(name, id, options, cardName)
		end,
		send = function(id: string, message: any): boolean
			return Store.send(name, id, message, options)
		end,
	}
end

return Profile
