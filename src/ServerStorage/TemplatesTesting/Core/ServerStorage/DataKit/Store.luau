--!strict
local Adapters = require(script.Parent.Adapters)
local Types = require(script.Parent.Adapters.Types)
local Signal = require(script.Parent.Signal)
local BaseStore = require(script.Parent.BaseStore)
local Lease = require(script.Parent.Lease)
local Inbox = require(script.Parent.Inbox)
local capitalize = require(script.Parent.Util.capitalize)
local deepCopy = require(script.Parent.Util.deepCopy)
local deepEquals = require(script.Parent.Util.deepEquals)
local reconcile = require(script.Parent.Util.reconcile)

local DEFAULT_AUTOSAVE = 300
local AUTOSAVE_RETRY = 30
local RETRY_BASE = 2
local RETRY_CAP = 60
local DEFAULT_STEAL_TIMEOUT = 150
local OWNERSHIP_RETRY = 3
local STAGING_TTL = 30
local DEFAULT_MESSAGE_POLL = 10
local DEFAULT_MAX_MESSAGES = 1000

--[=[
	@class Store

	Envuelve un [BaseStore] keyeado por una `id` arbitraria (p.ej. `worldId`), no por un
	jugador. Carga en el heartbeat, avisa cuando está listo, reintenta las caídas para
	siempre (backoff topado) y guarda solo lo modificado. Un `update` sobre un store aún no
	cargado se encola y se aplica sobre los datos reales al cargar.

	Por default (`singleWriter`) reclama un [Lease] sobre `Name/id` antes de cargar (namespaceado por
	nombre: dos perfiles distintos con la misma `id` no comparten candado): todo lo que persiste
	necesita un solo escritor. `singleWriter = false` es el escape hatch para lecturas que no toman el
	candado; para una lectura puntual sin ciclo de vida usa [Store.read]. `onConflict` decide qué
	pasa si otro server ya lo posee:

	- `"steal"` (default): espera a que el dueño suelte o a que su TTL expire (crash) y entonces
	  reclama. Es la política para **identidades que se mueven** (un jugador que hoppea de server):
	  la sesión vieja está muerta, robar es seguro. Si el dueño sigue vivo pasado `stealTimeout`,
	  se rinde (dispara el evento de denegación).
	- `"deny"`: cede de inmediato (evento de denegación con el dueño) y no carga. Es la política para
	  **lugares vivos compartidos** (un mundo hosteado con jugadores dentro): no se roba, se converge
	  —el cliente teletransporta al server dueño.

	## Métodos vs eventos

	Los **métodos** hacen algo y devuelven un valor: [Store.get], [Store.update], [Store.save],
	[Store.close], [Store.isReady], [Store.awaitReady], [Store.setLeaseMeta].

	Los **eventos** son métodos sin argumentos que devuelven un [Signal] al que te conectás con
	`:Connect(fn)`: [Store.onReady], [Store.onError], [Store.onSaved], [Store.onEnd],
	[Store.onDenied], [Store.onChanged], [Store.onDelivered]. Se llaman una vez y se guarda la señal,
	o se encadenan inline: `store:onChanged():Connect(fn)`.

	```lua
	local store = Store.new("Player", { level = 1, xp = 0 }, tostring(player.UserId))

	store:onChanged():Connect(function(data)
		replicate:FireClient(player, data)
	end)

	store:awaitReady()
	store:update(function(data)
		data.xp += 100
		return data
	end)
	store:close()
	```

	Para mover valor **entre dos stores** (p.ej. un mueble que sale de la casa al inventario
	del jugador) usá [Store.transfer]: registra el movimiento en cache y garantiza que el
	origen persista **antes** que el destino en cada `save`/`close` — la única forma de que un
	crash a medio guardado pierda el valor (recuperable) y nunca lo duplique.

	Para escribirle a una identidad **que este server no posee** —incluso una que no tiene dueño en
	ningún lado, o cuyo jugador nunca entró— usá [Store.send] del lado emisor y la opción
	`onMessage` del lado consumidor.
]=]
local Store = {}
Store.__index = Store

--[=[
	@method onReady
	@within Store
	@return Signal

	Evento `()`: dispara una vez cuando el store cargó. Ver [Store.awaitReady].
]=]

--[=[
	@method onError
	@within Store
	@return Signal

	Evento `(source, err)`: dispara cuando el store falla al cargar o al guardar (la librería sigue
	reintentando por su cuenta) o cuando una proyección `card` no pudo escribirse. `source` es
	`"store"`, `"card"`/`"card:<key>"` o `"transfer:<Name>"` según el origen del fallo.
]=]

--[=[
	@method onSaved
	@within Store
	@return Signal

	Evento `(reason)`: dispara tras cada save que **confirmó escrituras** (`"Auto"` / `"Manual"` /
	`"Close"` / `"Transfer"`) — la señal de que el estado **persistió** al DataStore. No trae la
	data; combinalo con [Store.get] para leer qué quedó (útil para espejos durables).
]=]

--[=[
	@method onChanged
	@within Store
	@return Signal

	Evento `(data)`: dispara cuando el estado poseído cambia en cache (tras cada [Store.update],
	y al aplicar las mutaciones encoladas al cargar), en su propio thread. `data` es la cache viva
	(no la mutes). Es el gancho on-update para efectos aguas abajo (replicar al cliente, publicar a
	un OrderedDataStore, espejar a MemoryStore) sin que DataKit conozca ninguno.
]=]

--[=[
	@method onEnd
	@within Store
	@return Signal

	Evento `()`: dispara cuando el store se cierra (`close`): tras guardar lo pendiente y soltar el
	candado.
]=]

--[=[
	@method onDenied
	@within Store
	@return Signal

	Evento `(owner, ownerMeta)`: dispara cuando no somos (o dejamos de ser) el escritor: otro server
	posee la identidad, o perdimos el candado a mitad de sesión. `ownerMeta` es la `leaseMeta` del
	dueño vigente, suficiente para converger hacia él (p.ej. teleport con `{ placeId, accessCode }`).
]=]

--[=[
	@method onDelivered
	@within Store
	@return Signal

	Evento `(message)`: dispara cuando un mensaje consumido por el handler `onMessage` **ya
	persistió** — o sea, cuando la escritura que lo sacó de la cola confirmó. Es el lugar para los
	efectos que no se pueden repetir (avisarle al jugador "te regalaron un sofá", auditoría): el
	handler `onMessage` puede correr más de una vez sobre el mismo mensaje si un save falla, pero
	este evento dispara una sola vez, cuando ya no hay vuelta atrás.
]=]

type Mutation = (any) -> any

--[=[
	@type MessageHandler (data: any, message: any) -> any?
	@within Store

	El consumidor declarativo de [Store.send]. Recibe la data en cache y el mensaje; devolver la data
	consume el mensaje, devolver `nil` lo deja para el próximo ciclo.
]=]
export type MessageHandler = (data: any, message: any) -> any?

type StoreState = {
	store: BaseStore.BaseStore,
	template: any?,
	data: any?,
	loaded: boolean,
	loading: boolean,
	dirty: boolean,
	pending: { Mutation },
	attempt: number,
	retryAt: number,
	fence: number,
}

export type ConflictPolicy = "deny" | "steal"

--[=[
	@interface CardSpec
	@within Store

	Proyección declarativa del estado poseído hacia una **tarjeta** chica que el lobby lee
	sin cargar el store: `project(data)` deriva la tarjeta desde la cache del store, y la
	librería la escribe en `store` (default `NameCard`) tras cada save que confirmó
	escrituras, solo si cambió. Ver [Store.readCard].

	`onChange(id, card)` se dispara tras cada escritura confirmada de la tarjeta (solo cuando
	la proyección cambió) — el gancho para efectos secundarios sobre el valor recién escrito,
	p.ej. espejarlo a MemoryStore para una lista de mundos en vivo. Corre en su propio thread,
	así que un efecto que cede no bloquea el save.

	Para varias tarjetas de la misma identidad (p.ej. una pública y una `admin`) usa el mapa
	`Options.cards` en vez de `Options.card`: cada una escribe a su propia store (default
	`NameKeyCard`) y se lee con `readCard(..., cardName)`.
]=]
export type CardSpec = {
	project: (data: any) -> any,
	store: string?,
	onChange: ((id: string, card: any) -> ())?,
}

export type Options = {
	deps: Types.Deps?,
	store: string?,
	autosaveInterval: number?,
	singleWriter: boolean?,
	serverId: string?,
	onConflict: ConflictPolicy?,
	stealTimeout: number?,
	leaseMeta: any?,
	card: CardSpec?,
	cards: { [string]: CardSpec }?,
	onMessage: MessageHandler?,
	messagePoll: number?,
	maxMessages: number?,
}

type self = {
	Name: string,
	Id: string,
	_onReady: Signal.Signal,
	_onError: Signal.Signal,
	_onSaved: Signal.Signal,
	_onEnd: Signal.Signal,
	_onDenied: Signal.Signal,
	_onChanged: Signal.Signal,
	_onDelivered: Signal.Signal,
	_deps: Types.Deps,
	_ready: boolean,
	_closed: boolean,
	_autosave: number,
	_lastSave: number,
	_hbConn: Types.Connection?,
	_lease: Lease.Lease?,
	_singleWriter: boolean,
	_denied: boolean,
	_ownershipResolved: boolean,
	_onConflict: ConflictPolicy,
	_claimDeadline: number,
	_resolvingOwnership: boolean,
	_ownershipRetryAt: number,
	_saving: boolean,
	_saveWaiters: { thread },
	_transferSources: { [any]: number },
	_state: StoreState,
	_card: CardState?,
	_cards: { [string]: CardState },
	_msgHandler: MessageHandler?,
	_msgKey: string,
	_msgPoll: number,
	_maxMessages: number,
	-- Cola cosechada del sobre. Se reemplaza entera en cada cosecha: un mensaje que el handler no
	-- consumió vuelve en la próxima, sin que haga falta llevar un set de "ya visto".
	_msgPending: { BaseStore.Message },
	-- `true` cuando `_msgPending` trae algo sin evaluar. Sin esto el heartbeat correría el handler
	-- ~60 veces por segundo sobre los mensajes que devuelven nil.
	_msgFresh: boolean,
	-- id -> body de lo aplicado en cache y pendiente de drenar. El body se guarda para poder
	-- anunciarlo por `onDelivered` recién cuando el drenado confirme.
	_msgConsumed: { [number]: any },
	_lastRing: number?,
	_msgPollAt: number,
}

type CardState = {
	spec: CardSpec,
	store: BaseStore.BaseStore,
	last: any,
	written: boolean,
}

export type Store = typeof(setmetatable({} :: self, Store))

--[=[
	@interface TransferEndpoint
	@within Store

	Un lado de un [Store.transfer]: el store y la mutación
	(`update(data) -> data`) que ese lado aplica en cache.
]=]
export type TransferEndpoint = {
	store: Store,
	update: Mutation,
}

local function backoff(attempt: number): number
	return math.min(RETRY_BASE * 2 ^ (attempt - 1), RETRY_CAP)
end

--[=[
	@within Store

	Crea el store y arranca la carga en el siguiente heartbeat. `template` es la forma por
	default (se reconcilia sobre lo cargado); el DataStore es `options.store` o `Name`.
]=]
function Store.new(name: string, template: any?, id: string, options: Options?): Store
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()

	local self = setmetatable({} :: self, Store)
	self.Name = name
	self.Id = id
	self._onReady = Signal.new()
	self._onError = Signal.new()
	self._onSaved = Signal.new()
	self._onEnd = Signal.new()
	self._onDenied = Signal.new()
	self._onChanged = Signal.new()
	self._onDelivered = Signal.new()
	self._deps = deps
	self._ready = false
	self._closed = false
	self._autosave = opts.autosaveInterval or DEFAULT_AUTOSAVE
	self._lastSave = deps.now()

	-- Single-writer es el default: todo lo que persiste necesita un solo escritor. `false` es
	-- el escape hatch para cargas de solo-lectura que no deben tomar el candado.
	self._singleWriter = opts.singleWriter ~= false
	self._denied = false
	self._ownershipResolved = not self._singleWriter
	self._onConflict = opts.onConflict or "steal"
	self._claimDeadline = deps.now() + (opts.stealTimeout or DEFAULT_STEAL_TIMEOUT)
	self._resolvingOwnership = false
	self._ownershipRetryAt = 0
	self._saving = false
	self._saveWaiters = {}
	self._transferSources = {}
	self._msgHandler = opts.onMessage
	self._msgKey = name .. "/" .. id
	self._msgPoll = opts.messagePoll or DEFAULT_MESSAGE_POLL
	self._maxMessages = opts.maxMessages or DEFAULT_MAX_MESSAGES
	self._msgPending = {}
	self._msgFresh = false
	self._msgConsumed = {}
	self._lastRing = nil
	self._msgPollAt = deps.now() + self._msgPoll
	self._card = if opts.card
		then {
			spec = opts.card,
			store = BaseStore.new(opts.card.store or (name .. "Card"), nil, deps),
			last = nil,
			written = false,
		}
		else nil
	self._cards = {}
	if opts.cards then
		for key, spec in opts.cards do
			self._cards[key] = {
				spec = spec,
				store = BaseStore.new(spec.store or (name .. capitalize(key) .. "Card"), nil, deps),
				last = nil,
				written = false,
			}
		end
	end
	self._lease = nil
	if self._singleWriter then
		local serverId = opts.serverId or deps.serverId
		assert(serverId ~= nil, "[Store] singleWriter requiere serverId (en options o deps)")
		local lease = Lease.new(name .. "/" .. id, serverId, { deps = deps, meta = opts.leaseMeta })
		self._lease = lease
		-- Si perdemos la posesión a mitad de sesión, dejamos de ser el escritor.
		lease.OnLost:Connect(function()
			self._denied = true
			self._onDenied:Fire(nil)
		end)
	end

	self._state = {
		store = BaseStore.new(opts.store or name, template, deps),
		template = template,
		data = nil,
		loaded = false,
		loading = false,
		dirty = false,
		pending = {},
		attempt = 0,
		retryAt = 0,
		fence = 0,
	}

	self._hbConn = deps.connectHeartbeat(function()
		self:_heartbeat()
	end)

	return self
end

-- Eventos: cada uno devuelve el [Signal] al que te conectás con `:Connect(fn)`.
-- Ver la sección "Métodos vs eventos" en la doc de la clase.
function Store.onReady(self: Store): Signal.Signal
	return self._onReady
end

function Store.onError(self: Store): Signal.Signal
	return self._onError
end

function Store.onSaved(self: Store): Signal.Signal
	return self._onSaved
end

function Store.onEnd(self: Store): Signal.Signal
	return self._onEnd
end

function Store.onDenied(self: Store): Signal.Signal
	return self._onDenied
end

function Store.onChanged(self: Store): Signal.Signal
	return self._onChanged
end

function Store.onDelivered(self: Store): Signal.Signal
	return self._onDelivered
end

--[=[
	@within Store

	Evento `(isCritical: boolean)`: reexpone el toggle de estado crítico del [BaseStore] de
	esta identidad, para no tener que alcanzarlo por dentro. Ver [Store.isCriticalState].
]=]
function Store.onCriticalToggle(self: Store): Signal.Signal
	return self._state.store.OnCriticalToggle
end

--[=[
	@within Store

	Lectura puntual y **sin candado** de una `id`: lee el store una vez y devuelve la data
	(reconciliada en memoria con su template, sin escribir de vuelta). No toma el [Lease], no
	arranca heartbeat, autosave ni ciclo de vida — no hay que cerrar nada.

	Para el lobby que solo quiere *mirar* los datos de un mundo (o listarlos) sin hostearlo: nunca
	se bloquea por la propiedad y nunca escribe. Devuelve `(data, ok)`: `data` es `nil` si no hay
	datos guardados, y `ok = false` distingue "la lectura falló" de "no hay datos" (sin eso el
	lobby mostraría un mundo vacío cuando DataStore está caído).
]=]
function Store.read(name: string, template: any?, id: string, options: Options?): (any, boolean)
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()

	local store = BaseStore.new(opts.store or name, template, deps)
	local ok, data = store:GetAsync(id)
	if ok and data ~= nil and template ~= nil then
		reconcile(data, template)
	end
	return if ok then data else nil, ok
end

--[=[
	@within Store

	Manda un mensaje a una identidad **esté hosteada o no**: lo encola dentro de su propio key y
	devuelve `true` si quedó guardado. No toma el candado, no toca la data y no le importa quién sea
	el dueño — por eso funciona igual si el jugador está en otro server, si no está en ninguno, o si
	nunca entró al juego.

	Del otro lado, quien declaró `onMessage` en sus opciones lo consume: si la identidad está
	cargada ahora, en segundos; si no, en el momento en que alguien la cargue, aunque sea en un mes.
	Es **el mismo camino** en los dos casos, y por eso no hay nada que decidir en el emisor:

	```lua
	-- Regalarle un mueble a alguien, esté online o no:
	Store.send("Player", tostring(friendUserId), { kind = "gift", itemId = "sofa" })
	```

	La entrega es durable de punta a punta: el mensaje vive en el DataStore hasta que el consumidor
	lo aplica, y sale de la cola en **la misma escritura** que persiste la mutación que causó. Un
	crash a mitad de camino lo re-entrega en vez de dejarlo aplicado a medias. Eso es justo lo que
	MessagingService no puede dar (se pierde si el server se satura o reinicia, y no sirve si nadie
	hostea); acá MessagingService no participa — el timbre que baja la latencia va por MemoryStore y
	es descartable.

	Devuelve `false` solo si el DataStore falló: en ese caso el mensaje **no** se guardó y hay que
	reintentar. Que el timbre falle no cuenta como fallo — el mensaje ya está durable y se cosecha
	igual, solo más tarde.

	`options` debe traer las mismas `store`/`maxMessages`/`deps` con que se declaró la identidad
	(desde un [Profile] usá `def.send(id, message)`, que ya las pasa).
]=]
function Store.send(name: string, id: string, message: any, options: Options?): boolean
	assert(message ~= nil, "[Store] send requiere un mensaje")
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()

	local store = BaseStore.new(opts.store or name, nil, deps)
	local ok = store:Enqueue(id, message, opts.maxMessages or DEFAULT_MAX_MESSAGES)
	if ok then
		-- Timbre best-effort: acelera la cosecha del dueño. Si falla, no cambia el resultado.
		Inbox.ring(name .. "/" .. id, { deps = deps })
	end
	return ok
end

--[=[
	@within Store

	Consulta puntual del **directorio en vivo**: devuelve `(owner, meta)` del server que posee
	`Name/id` ahora mismo, o `(nil, nil)` si nadie lo hostea. No toma el candado ni toca
	DataStore — es la pregunta del lobby "¿está hosteado y cómo le llego?" antes de decidir
	entre teleportar o hostear.
]=]
function Store.peekOwner(name: string, id: string, options: Options?): (string?, any?)
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()
	return Lease.peek(name .. "/" .. id, { deps = deps })
end

--[=[
	@interface CurrentHost
	@within Store

	Quién tiene la identidad cuando `claimStaged` no la consigue: `kind = "hosted"` (un server
	la hostea de verdad — teleporta hacia él con su `meta`) o `kind = "staged"` (otro lobby ya
	está abriéndola — espera su `meta.accessCode` vía `peekStaged` y únete a esa instancia).
]=]
export type CurrentHost = {
	kind: "hosted" | "staged",
	owner: string,
	meta: any?,
}

--[=[
	@within Store

	Reserva de **staging** del lobby: cierra la ventana entre "decidí abrir este mundo" y "la
	instancia reservada tomó el lease real". Sin ella, dos lobbies que ven el mundo libre a la
	vez reservan **dos instancias** de la misma casa y parten a los jugadores en dos copias.

	Devuelve `(claim, current)`:
	- `claim` (un [Lease] de TTL corto, 30s) → **ganaste**: llama `TeleportService:ReserveServer`
	  AHORA (fuera de todo transform — reservar dentro de un `UpdateAsync` era el bug del sistema
	  viejo), publica el código con `claim:setMeta({ accessCode = ... })` seguido de
	  `claim:tryClaim()` (republica la meta y renueva el TTL: reservar pudo tardar) y teleporta.
	  No hace falta soltarlo: expira solo cuando el host toma el lease real. Si `ReserveServer`
	  falla, `claim:release()` libera el turno de inmediato.
	- `(nil, current)` → la identidad ya está `hosted` (teleporta al dueño con `current.meta`) o
	  `staged` por otro lobby (haz poll de [Store.peekStaged] hasta ver su `accessCode` y
	  únete a la misma instancia).
	- `(nil, nil)` → MemoryStore falló; reintenta.

	El staging vive en una key aparte (`staged/Name/id`): **no bloquea** el `tryClaim` real del
	host. La ventana entre el chequeo de "hosted" y el claim de staging no es atómica; si un host
	gana justo en medio, la instancia reservada se auto-deniega al cargar (`onConflict deny`) y
	converge por teleport — el mecanismo existente absorbe la carrera.
]=]
function Store.claimStaged(name: string, id: string, options: Options?, stageMeta: any?): (Lease.Lease?, CurrentHost?)
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()
	local key = name .. "/" .. id

	local hostOwner, hostMeta = Lease.peek(key, { deps = deps })
	if hostOwner then
		return nil, { kind = "hosted" :: "hosted", owner = hostOwner, meta = hostMeta }
	end

	local serverId = opts.serverId or deps.serverId
	assert(serverId ~= nil, "[Store] claimStaged requiere serverId (en options o deps)")
	local staging = Lease.new("staged/" .. key, serverId, { deps = deps, ttl = STAGING_TTL, meta = stageMeta })
	local claimed, owner, ownerMeta = staging:tryClaim()
	if claimed then
		return staging, nil
	end
	if owner then
		return nil, { kind = "staged" :: "staged", owner = owner, meta = ownerMeta }
	end
	return nil, nil
end

--[=[
	@within Store

	Consulta puntual del staging: `(stager, meta)` del lobby que está abriendo `Name/id`, o
	`(nil, nil)` si nadie. Es el poll del lobby perdedor esperando el `accessCode` del ganador.
	Consulta antes [Store.peekOwner]: si ya está `hosted`, el staging es irrelevante.
]=]
function Store.peekStaged(name: string, id: string, options: Options?): (string?, any?)
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()
	return Lease.peek("staged/" .. name .. "/" .. id, { deps = deps })
end

--[=[
	@within Store

	Lee la **tarjeta** de una identidad (la proyección declarada con `Options.card`) sin
	candado ni ciclo de vida: es la lectura barata del lobby para pintar la lista de mundos
	sin bajar el estado completo. Devuelve `(card, ok)` — `card` puede ser nil legítimamente
	(nunca se ha escrito); `ok = false` significa que la lectura falló (no asumas vacío).

	`cardName` selecciona una tarjeta declarada en `Options.cards` (plural); sin él lee la
	tarjeta singular `Options.card`. El DataStore default de una tarjeta keyeada es
	`NameKeyCard` (p.ej. `WorldAdminCard`); pasa las mismas `options` con que la declaraste
	para respetar un `store` custom.
]=]
function Store.readCard(name: string, id: string, options: Options?, cardName: string?): (any, boolean)
	local opts: Options = options or {}
	local deps = opts.deps or Adapters.defaultDeps()
	local storeName
	if cardName ~= nil then
		local spec = opts.cards and opts.cards[cardName]
		storeName = (spec and spec.store) or (name .. capitalize(cardName) .. "Card")
	else
		storeName = (opts.card and opts.card.store) or (name .. "Card")
	end
	local store = BaseStore.new(storeName, nil, deps)
	local ok, data = store:GetAsync(id)
	return if ok then data else nil, ok
end

local function dependsOn(store: Store, target: Store, visited: { [any]: boolean }): boolean
	if store == target then
		return true
	end
	if visited[store] then
		return false
	end
	visited[store] = true
	for source in store._transferSources do
		if dependsOn(source, target, visited) then
			return true
		end
	end
	return false
end

--[=[
	@within Store

	Mueve valor entre **dos stores** (dos identidades) aplicando ambas mutaciones en cache y
	garantizando el orden de persistencia que impide duplicarlo: el store destino queda ligado
	al origen, y cada `save` (autosave, manual o `close`) del destino **persiste el origen
	primero y espera su confirmación** antes de escribir lo suyo. Un crash a medio guardado
	pierde el valor en tránsito (recuperable con logs) — nunca lo deja en ambos lados.

	Los transfers del mismo sentido se acumulan en cache (el autosave los persiste en lote);
	uno del sentido **contrario** drena primero el lote pendiente (un save ordenado) para que
	nunca convivan dos sentidos sin orden seguro. Si el origen no puede guardar (backend caído
	o denegado), el destino no persiste y su `save` devuelve `false` con `onError()`.

	No guarda inmediatamente: registra el movimiento y deja el guardado al ciclo normal. Dentro
	de una misma identidad no hay nada que ordenar (un key es atómico): usa `update`.

	Las dos mutaciones se aplican **todo-o-nada en cache**: si cualquiera lanza, ambos
	stores se restauran a su estado previo y el error se propaga — un transfer a medias
	(el valor salió del origen pero nunca entró al destino) se persistiría como pérdida.

	```lua
	Store.transfer({
		store = house,
		update = function(build)
			build.items[itemId] = nil
			return build
		end,
	}, {
		store = player,
		update = function(data)
			data.items[itemId] = true
			return data
		end,
	})
	```

	Devuelve `false` (con la razón) si algún store está cerrado, denegado o aún no cargó, o si el
	lote pendiente en sentido contrario no pudo drenarse; en esos casos no aplica ninguna de las
	dos mutaciones.
]=]
function Store.transfer(from: TransferEndpoint, to: TransferEndpoint): (boolean, string?)
	assert(
		from.store ~= to.store,
		"[Store] transfer requiere dos stores distintos: dentro de una misma identidad usa update"
	)
	local fromState = from.store._state
	local toState = to.store._state

	if from.store._closed or to.store._closed then
		return false, "store cerrado"
	end
	if from.store._denied or to.store._denied then
		return false, "store denegado"
	end
	if not fromState.loaded or not toState.loaded then
		return false, "store sin cargar"
	end

	if dependsOn(from.store, to.store, {}) then
		from.store:save("Transfer")
		if dependsOn(from.store, to.store, {}) then
			return false, "el lote pendiente en sentido contrario no pudo drenarse"
		end
		if from.store._denied or to.store._denied then
			return false, "store denegado"
		end
	end

	local fromSnapshot = deepCopy(fromState.data)
	local fromDirty = fromState.dirty
	local toSnapshot = deepCopy(toState.data)
	local toDirty = toState.dirty
	local applied, applyErr = pcall(function()
		from.store:update(from.update)
		to.store:update(to.update)
	end)
	if not applied then
		fromState.data = fromSnapshot
		fromState.dirty = fromDirty
		toState.data = toSnapshot
		toState.dirty = toDirty
		error(`[Store] transfer abortado (cache restaurada): {applyErr}`, 2)
	end

	to.store._transferSources[from.store] = (to.store._transferSources[from.store] or 0) + 1
	return true
end

function Store._checkReady(self: Store)
	if self._ready then
		return
	end
	if not self._state.loaded then
		return
	end
	self._ready = true
	self._onReady:Fire()
end

function Store._load(self: Store, state: StoreState)
	state.loading = true
	task.spawn(function()
		local ok, fence, data, msgs = state.store:Acquire(self.Id, state.template)
		state.loading = false
		if self._closed then
			return
		end
		if ok then
			state.fence = fence
			state.data = data
			state.loaded = true
			state.attempt = 0
			-- Todo lo que se encoló mientras la identidad no tenía dueño llega acá, en la misma
			-- lectura con la que la tomamos: es el caso "le regalaron algo estando offline".
			self:_harvest(msgs)
			if #state.pending > 0 then
				for _, fn in ipairs(state.pending) do
					state.data = fn(state.data)
				end
				table.clear(state.pending)
				state.dirty = true
				self._onChanged:Fire(state.data)
			end
			self:_checkReady()
		else
			state.attempt += 1
			state.retryAt = self._deps.now() + backoff(state.attempt)
			self._onError:Fire("store", "acquire failed")
		end
	end)
end

-- Reemplaza la cola pendiente por la recién leída del sobre. Los ya consumidos siguen viniendo en
-- la lista hasta que el drenado confirme; `_applyMessages` los saltea por id.
function Store._harvest(self: Store, msgs: { BaseStore.Message })
	if self._msgHandler == nil then
		return
	end
	self._msgPending = msgs
	self._msgFresh = true
end

-- Corre el handler sobre lo pendiente sin evaluar. Devuelve `true` si consumió algo, para que el
-- heartbeat guarde en el acto: ese save persiste la mutación y drena el mensaje en una sola
-- escritura, que es lo que hace la entrega exactly-once.
function Store._applyMessages(self: Store): boolean
	local handler = self._msgHandler
	local state = self._state
	if handler == nil or not self._msgFresh or not state.loaded or self._closed or self._denied then
		return false
	end
	self._msgFresh = false

	local consumedAny = false
	for _, msg in self._msgPending do
		if self._msgConsumed[msg.id] == nil then
			-- El handler es código del consumidor: si lanza, no puede tumbar el heartbeat del
			-- store. El mensaje queda sin consumir y se reintenta en la próxima cosecha.
			local ok, out = pcall(handler, state.data, deepCopy(msg.body))
			if not ok then
				self._onError:Fire("message", tostring(out))
			elseif out ~= nil then
				state.data = out
				state.dirty = true
				self._msgConsumed[msg.id] = msg.body
				consumedAny = true
				self._onChanged:Fire(state.data)
			end
		end
	end
	return consumedAny
end

-- Sondeo del timbre: una lectura de MemoryStore (barata) que decide si vale la pena leer el
-- DataStore. Si el timbre está caído o expiró no pasa nada: la cosecha del próximo save entrega
-- igual, solo más tarde.
function Store._pollMessages(self: Store, now: number)
	if now < self._msgPollAt then
		return
	end
	self._msgPollAt = now + self._msgPoll

	-- Lo que sigue en la cola sin consumir se vuelve a ofrecer en cada sondeo: es el reloj de
	-- reintento del handler que difirió (devolvió nil). Sin esto un mensaje diferido quedaría
	-- esperando a que algo más provoque una cosecha, y sobre un store quieto eso no pasa nunca.
	-- No cuesta ninguna request: reofrece lo que ya tenemos en memoria.
	if #self._msgPending > 0 then
		self._msgFresh = true
	end

	local ring = Inbox.peek(self._msgKey, { deps = self._deps })
	if ring == nil or ring == self._lastRing then
		return
	end
	self._lastRing = ring

	local ok, list = self._state.store:PeekMessages(self.Id)
	if ok then
		self:_harvest(list)
	end
end

function Store._resolveOwnership(self: Store)
	local lease = self._lease
	-- Un solo intento a la vez (tryClaim cede en MemoryStore) y con throttle entre reintentos:
	-- sin esto el heartbeat lanzaría una resolución por frame (~60/s) y martillearía el lease.
	if not lease or self._resolvingOwnership or self._deps.now() < self._ownershipRetryAt then
		return
	end
	self._resolvingOwnership = true
	self._ownershipRetryAt = self._deps.now() + OWNERSHIP_RETRY
	local claimed, owner, ownerMeta = lease:tryClaim()
	self._resolvingOwnership = false
	if claimed then
		self._ownershipResolved = true
		lease:start()
		return
	end
	if owner == nil then
		-- Fallo transitorio de MemoryStore: se reintenta tras OWNERSHIP_RETRY.
		return
	end
	-- Conflicto: otro server vivo posee el lease.
	if self._onConflict == "deny" or self._deps.now() >= self._claimDeadline then
		-- deny: cedemos al dueño (el cliente teletransporta allá con su ownerMeta).
		-- steal agotado: el dueño sigue vivo pasado el plazo, nos rendimos.
		self._ownershipResolved = true
		self._denied = true
		self._onDenied:Fire(owner, ownerMeta)
	end
	-- steal dentro del plazo: no hacemos nada; el próximo heartbeat reintenta
	-- tryClaim y ganará en cuanto el dueño suelte o su TTL expire (crash).
end

function Store._heartbeat(self: Store)
	if self._closed then
		return
	end

	if self._singleWriter and not self._ownershipResolved then
		self:_resolveOwnership()
	end
	-- No cargar hasta ser dueño; si nos denegaron, nunca.
	if self._denied or not self._ownershipResolved then
		return
	end

	local now = self._deps.now()

	local state = self._state
	if not state.loaded and not state.loading and now >= state.retryAt then
		self:_load(state)
	end

	if self._msgHandler ~= nil and state.loaded then
		self:_pollMessages(now)
		if self:_applyMessages() then
			-- No esperamos al autosave: el mensaje ya es durable del lado del emisor, dejarlo
			-- aplicado solo en cache alargaría la única ventana en que un crash lo re-entregaría.
			self:save("Message")
		end
	end

	if now - self._lastSave >= self._autosave then
		self._lastSave = now
		if not self:save("Auto") then
			-- Reintento corto tras un autosave fallido: esperar el intervalo completo
			-- alargaría la ventana de pérdida sin necesidad.
			self._lastSave = self._deps.now() - self._autosave + math.min(AUTOSAVE_RETRY, self._autosave)
		end
	end
end

--[=[
	@within Store

	`true` cuando el store **cargó**. Nada más: no dice que siga vivo ni que seas el escritor.
	Sigue siendo `true` después de [Store.close] y mientras estés denegado.

	Para la pregunta "¿escribo y va a persistir?" usá [Store.canWrite].
]=]
function Store.isReady(self: Store): boolean
	return self._ready
end

--[=[
	@within Store

	`true` una vez que se llamó a [Store.close]. Se marca de forma **síncrona** al entrar en
	`close`, antes de guardar y liberar, así que es autoritativo durante todo el teardown.

	Importa porque [Store.update] hace `assert` sobre un store cerrado (aceptar la mutación
	sería pérdida de datos silenciosa) y [Store.isReady] sigue devolviendo `true` después de
	cerrar — `_ready` describe "cargó", no "sigue vivo".

	Para decidir si escribir, preferí [Store.canWrite] (cubre cerrado **y** denegado); usá este
	accesor cuando necesites distinguir el motivo.
]=]
function Store.isClosed(self: Store): boolean
	return self._closed
end

--[=[
	@within Store

	`true` cuando **no somos el escritor**: otro server posee la identidad (`onConflict = "deny"`),
	o perdimos el candado a mitad de sesión. Es el estado que anuncia el evento [Store.onDenied].

	A diferencia de un store cerrado, uno denegado **no lanza** en [Store.update]: la mutación
	entra a la cache y `save` devuelve `false` sin escribir nada. Desde afuera se ve como un
	no-op silencioso, y por eso existe este accesor.
]=]
function Store.isDenied(self: Store): boolean
	return self._denied
end

--[=[
	@within Store

	`true` cuando escribir tiene sentido: el store **cargó**, no está cerrado y seguimos siendo
	el escritor. Es la pregunta compuesta que [Store.isReady] por sí sola no responde.

	```lua
	if store:canWrite() then
		store:update(function(data)
			data.coins += 1
			return data
		end)
	end
	```

	Si necesitás distinguir el motivo (p.ej. para el mensaje de error), usá [Store.isClosed] y
	[Store.isDenied] por separado.
]=]
function Store.canWrite(self: Store): boolean
	return self._ready and not self._closed and not self._denied
end

--[=[
	@within Store

	`true` cuando el [BaseStore] de esta identidad está en estado crítico: demasiados fallos
	seguidos del DataStore en una ventana corta (ver `Health`). Útil para degradar la
	experiencia (avisar al jugador, frenar compras) en vez de acumular escrituras que no
	van a persistir.
]=]
function Store.isCriticalState(self: Store): boolean
	return self._state.store:IsCriticalState()
end

--[=[
	@within Store

	Cede el hilo hasta que el store esté listo, hasta que otro server lo posea (con
	`singleWriter`) o hasta que el store se cierre. Devuelve `true` si somos el dueño y
	cargó; `false` si nos denegaron o si el store se cerró antes de terminar de cargar
	(p.ej. el jugador se fue mientras su perfil cargaba).
]=]
function Store.awaitReady(self: Store): boolean
	if self._ready then
		return true
	end
	if self._denied or self._closed then
		return false
	end

	local co = coroutine.running()
	local onReady: Signal.Connection
	local onDenied: Signal.Connection
	local onEnd: Signal.Connection
	local function resolve()
		onReady:Disconnect()
		onDenied:Disconnect()
		onEnd:Disconnect()
		task.spawn(co)
	end
	onReady = self._onReady:Connect(resolve)
	onDenied = self._onDenied:Connect(resolve)
	onEnd = self._onEnd:Connect(resolve)
	coroutine.yield()

	return self._ready and not self._denied
end

--[=[
	@within Store

	Actualiza la metadata publicada con el candado (p.ej. `{ placeId, accessCode, players }`);
	el keepalive la publica en su siguiente heartbeat. Es lo que ven `peekOwner` y el
	`onDenied()` de los demás servers. No-op si el store no toma candado.
]=]
function Store.setLeaseMeta(self: Store, meta: any)
	if self._lease then
		self._lease:setMeta(meta)
	end
end

--[=[
	@within Store

	Datos cacheados del store, o `nil` si aún no cargó.
]=]
function Store.get(self: Store): any
	return self._state.data
end

--[=[
	@within Store

	Aplica `fn(data) -> data` al store y lo marca dirty. Si el store todavía no cargó, la
	mutación se encola y se aplica sobre los datos reales al cargar. Lanza sobre un store
	cerrado: después de `close` nada vuelve a guardarse, así que aceptar la mutación sería
	pérdida de datos silenciosa. Dispara el evento `onChanged` cuando la mutación se aplica a la
	cache (inmediato si ya cargó; al cargar si estaba encolada).
]=]
function Store.update(self: Store, fn: Mutation)
	assert(not self._closed, `[Store] update sobre un store cerrado: {self.Name}/{self.Id}`)
	local state = self._state
	if state.loaded then
		state.data = fn(state.data)
		state.dirty = true
		self._onChanged:Fire(state.data)
	else
		table.insert(state.pending, fn)
	end
end

--[=[
	@within Store

	Guarda el store si está cargado y dirty. Toma un snapshot y limpia el dirty antes del
	async: si llega un `update` durante el guardado, no se pierde.

	Los saves de un store se serializan: una llamada concurrente espera a que los commits en
	vuelo confirmen antes de evaluar qué guardar. Si el store es destino de un
	[Store.transfer], primero persiste (y espera) a cada store origen — el orden que
	impide duplicar el valor en tránsito.

	Devuelve `true` si todo lo dirty confirmó (o no había nada), `false` si el store no es el
	escritor o algún commit (propio o de un origen) falló — lo fallido queda dirty y lo
	reintenta el siguiente save, salvo lo descartado por `stale`.
]=]
function Store.save(self: Store, reason: string?): boolean
	if self._denied then
		return false
	end
	while self._saving do
		table.insert(self._saveWaiters, coroutine.running())
		coroutine.yield()
	end
	if self._denied then
		return false
	end
	self._saving = true
	local ok, anySaved = self:_saveLocked(reason)
	if ok and anySaved then
		self:_syncProjections()
	end
	self._saving = false
	if #self._saveWaiters > 0 then
		local waiters = self._saveWaiters
		self._saveWaiters = {}
		for _, waiter in waiters do
			task.spawn(waiter)
		end
	end
	return ok
end

function Store._saveLocked(self: Store, reason: string?): (boolean, boolean)
	local state = self._state

	-- Un mensaje consumido necesita su escritura aunque no haya cambiado la data (p.ej. un mensaje
	-- que solo se descarta): sin eso no saldría nunca de la cola y se re-entregaría para siempre.
	local consumedIds: { number } = {}
	if state.loaded then
		for id in self._msgConsumed do
			table.insert(consumedIds, id)
		end
	end
	local consumed: { [number]: boolean }? = nil
	if #consumedIds > 0 then
		local set: { [number]: boolean } = {}
		for _, id in consumedIds do
			set[id] = true
		end
		consumed = set
	end

	local dirty = state.loaded and (state.dirty or consumed ~= nil)
	local snapshot = if dirty then deepCopy(state.data) else nil
	if dirty then
		state.dirty = false
	end

	local sources: { [any]: number } = {}
	local hasSources = false
	for source, epoch in self._transferSources do
		sources[source] = epoch
		hasSources = true
	end
	if hasSources then
		local function abort(source: Store?)
			if dirty then
				state.dirty = true
			end
			if source then
				self._onError:Fire("transfer:" .. source.Name, "el origen del transfer no pudo guardar")
			end
		end
		for source, epoch in sources do
			local sourceGroup = source :: Store
			if not sourceGroup:save(reason) then
				abort(sourceGroup)
				return false, false
			end
			if self._transferSources[source] == epoch then
				self._transferSources[source] = nil
			end
		end
		if self._denied then
			abort(nil)
			return false, false
		end
	end

	if not dirty then
		return true, false
	end

	local committed, stale, msgs = state.store:CommitOwned(self.Id, state.fence, snapshot, consumed)
	if committed then
		self._lastSave = self._deps.now()
		-- El drenado confirmó junto con la data: recién ahora el consumo es irreversible, así que
		-- recién ahora se anuncian los efectos que no se pueden repetir.
		for _, id in consumedIds do
			local body = self._msgConsumed[id]
			self._msgConsumed[id] = nil
			self._onDelivered:Fire(body)
		end
		self:_harvest(msgs)
		self._onSaved:Fire(reason or "Manual")
		return true, true
	elseif stale then
		-- Otro server tomó la propiedad (fence mayor): la escritura se descartó. Dejamos
		-- de ser el escritor y NO re-marcamos dirty (no reintentar datos obsoletos).
		if not self._denied then
			self._denied = true
			self._onDenied:Fire(nil)
		end
		return false, false
	else
		state.dirty = true
		self._onError:Fire("store", "commit failed")
		return false, false
	end
end

function Store._syncCard(self: Store, label: string, card: CardState)
	local okProject, projected = pcall(card.spec.project, self._state.data)
	if not okProject then
		self._onError:Fire(label, tostring(projected))
	elseif not card.written or not deepEquals(projected, card.last) then
		local okWrite = card.store:SetAsync(self.Id, projected)
		if okWrite then
			card.last = deepCopy(projected)
			card.written = true
			if card.spec.onChange then
				task.spawn(card.spec.onChange, self.Id, deepCopy(projected))
			end
		else
			self._onError:Fire(label, "no se pudo escribir la card")
		end
	end
end

function Store._syncProjections(self: Store)
	if self._card then
		self:_syncCard("card", self._card)
	end
	for key, card in self._cards do
		self:_syncCard("card:" .. key, card)
	end
end

--[=[
	@within Store

	Detiene la carga/retry/autosave, guarda lo pendiente y dispara `onEnd`. Idempotente.
]=]
function Store.close(self: Store)
	if self._closed then
		return
	end
	self._closed = true
	if self._hbConn then
		self._hbConn:Disconnect()
		self._hbConn = nil
	end
	self:save("Close")
	if self._lease then
		self._lease:stop() -- para el keepalive y libera el candado si lo poseemos
	end
	self._onEnd:Fire()
end

return Store
