--[[
	PlayerDataReplicator

	Puente bidireccional entre el perfil de DataKit (via PlayerDataService) y el
	arbol de ValueBase que cuelga del Player. Sustituye al viejo modulo `Data` y a
	`PlayerProfileBridge`.

	Todo el mapeo vive en SPEC: una fila por carpeta o valor. Para replicar un dato
	nuevo se anade una fila y su default en PlayerSchema, no una funcion.

	Anatomia de una fila:

		key / path   Donde vive en el perfil. `path` para claves anidadas.
		instance     Nombre del Folder o ValueBase que cuelga del Player.
		kind         "folder" | "record" | "scalar"
		merge        "byName" reconcilia la lista contra el default por Name.
		coerce       Normaliza el Value antes de crear la Instance.
		load         Reemplaza por completo la materializacion generica.
		afterLoad    Corre despues de crear la Instance; lo que devuelva va al estado.
		beforeSave   Transforma lo serializado antes de escribirlo al perfil.
		stateKey     Clave bajo la que se guarda el resultado en DataComplete.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local PlayerSchema = require(script.Parent:WaitForChild("PlayerSchema"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AddItem = require(Shared:WaitForChild("AddValues"))
local BreakDown = require(Shared:WaitForChild("BreakDown"))

local FLUSH_INTERVAL = 60
local LOAD_ERROR = "No se pudieron cargar tus datos. Reintenta en un momento."

local PlayerDataReplicator = {}

-- Registro de estado por jugador. Conserva el nombre `DataComplete` porque
-- RevisarCanciones y ComprasTablero lo leen por inyeccion (.DataBase.DataComplete).
PlayerDataReplicator.DataComplete = {}

-- Karaoke.CrearCancion, inyectado desde Data.Main.
PlayerDataReplicator.KaraokeFactory = nil

local tracked: { [Player]: boolean } = {}
local exitSequence: ((Player) -> ())? = nil

-- // SERIALIZACION //

local serializeChildren

local function serializeValue(value: Instance?)
	if not (value and value:IsA("ValueBase")) then
		return nil
	end

	local record = {
		Name = value.Name,
		Value = (value :: any).Value,
	}

	for index, attribute in value:GetAttributes() do
		record[index] = BreakDown.Set(attribute)
	end

	record.Childs = serializeChildren(value)

	return record
end

function serializeChildren(container: Instance?)
	if not container then
		return nil
	end

	local list = {}
	for _, child in container:GetChildren() do
		if child:IsA("ValueBase") then
			local record = serializeValue(child)
			if record then
				table.insert(list, record)
			end
		end
	end

	return list
end

-- // MATERIALIZACION //

local function buildFolder(player: Player, name: string, records, coerce)
	local folder = Instance.new("Folder")
	folder.Name = name

	for _, record in records do
		if typeof(record) == "table" and typeof(record.Name) == "string" then
			local value = record.Value
			if coerce then
				value = coerce(value)
			end

			local instance = AddItem(record.Name, value, record)
			if instance then
				instance.Parent = folder
			end
		end
	end

	folder.Parent = player
	return folder
end

-- Reconcilia una lista guardada contra el default usando Name como identidad.
-- Necesario porque DataKit solo reconcilia claves string: una stat nueva jamas
-- entraria en el perfil de alguien que ya jugo.
local function mergeByName(saved, default)
	local byName = {}
	if typeof(saved) == "table" then
		for _, record in saved do
			if typeof(record) == "table" and typeof(record.Name) == "string" then
				byName[record.Name] = record
			end
		end
	end

	local records = {}
	for _, entry in default do
		table.insert(records, byName[entry.Name] or entry)
	end

	return records
end

local animationManager
local function getAnimationManager()
	if not animationManager then
		local system = ServerScriptService
			:WaitForChild("ServerScripts")
			:WaitForChild("AnimationSystem")
		animationManager = require(system:WaitForChild("AnimationManager"))
	end
	return animationManager
end

-- Las animaciones no se materializan genericamente: AnimationManager es quien
-- crea la carpeta y quien deriva los atributos desde DancesInfo.
local function loadAnimations(player: Player, records)
	local Manager = getAnimationManager()

	local folder = player:FindFirstChild("Animations")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Animations"
		folder.Parent = player
	end

	for _, record in records do
		if typeof(record) == "table" and typeof(record.Name) == "string" and record.Value == true then
			Manager.AddAnimation(player, record.Name)
		end
	end

	return nil
end

-- Los atributos de cada baile (Category, AssetId, ...) salen de DancesInfo en
-- cada carga, asi que guardarlos seria duplicar la config en el perfil.
local function stripAnimationAttributes(records)
	if typeof(records) ~= "table" then
		return records
	end

	local clean = {}
	for _, record in records do
		if typeof(record) == "table" and typeof(record.Name) == "string" then
			table.insert(clean, { Name = record.Name, Value = record.Value })
		end
	end

	return clean
end

-- La Biblioteca guarda en Value la lista de ids ya publicados y en Childs las
-- canciones en curso. Las que ya se publicaron no hace falta arrastrarlas.
local function trimKaraoke(record)
	
	if typeof(record) ~= "table" or typeof(record.Childs) ~= "table" then
		return record
	end

	local list = typeof(record.Value) == "string" and record.Value or ""
	if list == "" then
		return record
	end

	local ids = string.split(list, ",")
	local kept = {}

	for _, song in record.Childs do
		if typeof(song) == "table" and not table.find(ids, song.Name) then
			table.insert(kept, song)
		end
	end

	record.Childs = kept
	
	return record
end

-- // SPEC //

local SPEC = {
	{
		key = "cooldowns",
		instance = "Cooldowns",
		kind = "folder",
		-- CooldownManager asume IntValue; un Value corrupto crearia un StringValue.
		coerce = function(value)
			return math.floor(tonumber(value) or 0)
		end,
	},
	{
		key = "questData",
		instance = "QuestData",
		kind = "record",
	},
	{
		key = "animations",
		instance = "Animations",
		kind = "folder",
		load = loadAnimations,
		beforeSave = stripAnimationAttributes,
	},
	{
		key = "stats",
		instance = "leaderstats",
		kind = "folder",
		merge = "byName",
	},
	{
		key = "storesData",
		instance = "StoresData",
		kind = "folder",
	},
	{
		key = "inventoryBuild",
		instance = "InventoryBuild",
		kind = "folder",
	},
	{
		key = "inventoryProducts",
		instance = "InventoryItemsProucts",
		kind = "folder",
	},
	{
		key = "stylesSalas",
		instance = "stylesSalas",
		kind = "folder",
	},
	{
		key = "guide",
		instance = "GuideService",
		kind = "record",
	},
	{
		-- Los marcos viven con el resto del sistema de pinturas, no sueltos.
		path = { "paints", "marcos" },
		instance = "MarcosPaint",
		kind = "folder",
	},
	{
		key = "lastPaint",
		instance = "LastPaint",
		kind = "record",
	},
	{
		key = "materials",
		instance = "Materials",
		kind = "scalar",
	},
	{
		key = "favoriteNightclub",
		instance = "FavoriteNightclub",
		kind = "scalar",
	},
	{
		key = "karaoke",
		instance = "Biblioteca",
		kind = "record",
		stateKey = "karaoke",
		coerce = function(value)
			return typeof(value) == "string" and value or ""
		end,
		afterLoad = function(instance)
			local factory = PlayerDataReplicator.KaraokeFactory
			if not factory then
				warn("[PlayerDataReplicator] KaraokeFactory sin inyectar; Biblioteca sin objeto")
				return nil
			end
			return factory.new(instance)
		end,
		beforeSave = trimKaraoke,
	},
}

-- Normaliza `key` a `path` una sola vez y resuelve el default del esquema.
for _, entry in SPEC do
	entry.path = entry.path or { entry.key }
end

local function getPath(data, path)
	local node = data
	for _, field in path do
		if typeof(node) ~= "table" then
			return nil
		end
		node = node[field]
	end
	return node
end

local function setPath(data, path, value)
	local node = data
	for index = 1, #path - 1 do
		local field = path[index]
		if typeof(node[field]) ~= "table" then
			node[field] = {}
		end
		node = node[field]
	end
	node[path[#path]] = value
end

local function defaultFor(entry)
	return getPath(PlayerSchema.Template, entry.path)
end

-- // CARGA //

local function applyEntry(player: Player, entry, saved)
	if entry.kind == "folder" then
		local records
		if entry.merge == "byName" then
			records = mergeByName(saved, defaultFor(entry) or {})
		elseif typeof(saved) == "table" then
			records = saved
		else
			records = defaultFor(entry) or {}
		end

		if entry.load then
			return entry.load(player, records)
		end

		buildFolder(player, entry.instance, records, entry.coerce)
		return nil
	end

	if entry.kind == "record" then
		local record = typeof(saved) == "table" and saved or defaultFor(entry) or {}

		local value = record.Value
		if entry.coerce then
			value = entry.coerce(value)
		end

		local instance = AddItem(entry.instance, value, record)
		if not instance then
			return nil
		end
		instance.Parent = player

		if entry.afterLoad then
			return entry.afterLoad(instance)
		end
		return nil
	end

	if entry.kind == "scalar" then
		local value = saved
		if value == nil then
			value = defaultFor(entry)
		end

		local instance = AddItem(entry.instance, value)
		if instance then
			instance.Parent = player
		end
		return nil
	end

	warn(("[PlayerDataReplicator] kind desconocido '%s' en %s"):format(tostring(entry.kind), tostring(entry.instance)))
	return nil
end

--[[
	Carga el perfil y monta el arbol de Instances del jugador.
	Devuelve la tabla de estado (la que va a DataComplete) o nil + mensaje.
]]
function PlayerDataReplicator.hydrate(player: Player)
	local store = PlayerDataService.load(player)

	if not store:awaitReady() then
		return nil, LOAD_ERROR
	end

	if not player:IsDescendantOf(game) then
		return nil, "El jugador salio durante la carga"
	end

	local data = store:get()
	local state = {}

	local ok, err = pcall(function()
		for _, entry in SPEC do
			local result = applyEntry(player, entry, getPath(data, entry.path))
			if entry.stateKey and result ~= nil then
				state[entry.stateKey] = result
			end
		end
	end)

	if not ok then
		return nil, ("Error replicando datos de %s: %s"):format(player.Name, tostring(err))
	end

	tracked[player] = false

	-- Se pone al final a proposito: cuando alguien ve DataLoaded, el arbol
	-- completo ya existe. QuestMain depende de esto.
	player:SetAttribute("DataLoaded", true)

	return state
end

-- Habilita el guardado. Hasta que no se llama, un flush no escribe nada: evita
-- persistir un arbol a medio montar si algo falla despues de hydrate.
function PlayerDataReplicator.markReady(player: Player)
	if tracked[player] ~= nil then
		tracked[player] = true
	end
end

function PlayerDataReplicator.setExitSequence(fn: (Player) -> ())
	exitSequence = fn
end

-- // GUARDADO //

local function snapshotInto(player: Player, data)
	for _, entry in SPEC do
		local instance = player:FindFirstChild(entry.instance)
		local serialized

		if entry.kind == "folder" then
			serialized = serializeChildren(instance)
		elseif entry.kind == "record" then
			serialized = serializeValue(instance)
		elseif entry.kind == "scalar" then
			-- Sin el chequeo explicito, un escalar en false se perderia.
			if instance and instance:IsA("ValueBase") then
				serialized = (instance :: any).Value
			end
		end

		-- Una Instance ausente no borra lo guardado: puede que otro sistema la
		-- haya quitado o que nunca se llegara a crear.
		if serialized ~= nil then
			if entry.beforeSave then
				serialized = entry.beforeSave(serialized)
			end
			setPath(data, entry.path, serialized)
		end
	end

	return data
end

function PlayerDataReplicator.flush(player: Player): boolean
	if not tracked[player] then
		return false
	end

	local store = PlayerDataService.get(player)
	
	if not store or not store:canWrite() then
		return false
	end

	store:update(function(data)
		return snapshotInto(player, data)
	end)

	return true
end

-- Guardado final: corre la secuencia de salida, vuelca y suelta al jugador.
function PlayerDataReplicator.finalize(player: Player)
	local track = tracked[player]
	
	if track == nil then
		return
	end
	
	if typeof(track) == "RBXScriptSignal" then
		return track:Wait() --// Espera que termina la primera equiencia de guardado, sin eso el "Store" queda nil y la linea 485 queda en nil (No guarda los datos)
	end

	if not track then
		tracked[player] = nil
		return
	end
	
	local bin = Instance.new("BindableEvent")
	tracked[player] = bin.Event --// Agregado para evitar que se vuelva a sobreescribir un nuevo dato mientras se realiza el "ExitSequence"

	if exitSequence then
		local ok, err = pcall(exitSequence, player)
		if not ok then
			warn(("[PlayerDataReplicator] Error en la secuencia de salida de %s: %s"):format(player.Name, tostring(err)))
		end
	end
	
	PlayerDataReplicator.flush(player)
	
	bin:Fire()
	bin:Destroy()
	
	tracked[player] = nil
end

PlayerDataService.onBeforeClose(function(player)
	PlayerDataReplicator.finalize(player)
end)

task.spawn(function()
	while task.wait(FLUSH_INTERVAL) do
		local pending = {}
		for player in tracked do
			table.insert(pending, player)
		end

		for _, player in pending do
			if player.Parent ~= nil then
				local ok, err = pcall(PlayerDataReplicator.flush, player)
				if not ok then
					warn(("[PlayerDataReplicator] Error en el volcado periodico de %s: %s"):format(player.Name, tostring(err)))
				end
			end
		end
	end
end)

return PlayerDataReplicator
