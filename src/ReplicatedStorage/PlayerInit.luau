--[[ 
    PlayerInit
    ---------------
    Al no poder garantizar que PlayerService.PlayerAdded es recibido por scripts de un template
    que pueden tardar en ser importados con InsertService, se requiere este script para asegurar
    que ejecutamos PlayerService.PlayerAdded en esos scripts de forma segura.
    -------------------------------------------------
    Ejemplo de uso (en script de servidor obivamente):
    -------------------------------------------------
	local PlayerInit = require(ReplicatedStorage.PlayerInit)

	local function OnPlayerAdded(player)
		-- lo que haya que ejecutar cuando se une un jugador al juego
	end

	-- Registramos el callback
	PlayerInit.Connect(OnPlayerAdded)
    -------------------------------------------------
--]]

local Players = game:GetService("Players")

--[=[
	Deferred fan-out for `Players.PlayerAdded`.

	Template scripts are imported at runtime by `ImportTemplates.server.luau` and are
	only enabled afterwards by `InitScripts.server.luau`. A script that connects to
	`Players.PlayerAdded` directly can therefore miss players who joined while the
	import was still running. This module keeps its own connection from the moment it
	is first required, remembers which players it has already announced, and replays
	that announcement to listeners that register later.

	Callbacks are invoked through `task.defer` and wrapped in `pcall`, so one failing
	listener neither blocks nor breaks the others.

	The module is required from both sides. On the server it announces every player.
	On the client `Players.PlayerAdded` fires for *all* players, so client-context
	consumers filter for `Players.LocalPlayer` themselves — this module does not do
	that filtering for them.

	@class PlayerInit
]=]
local PlayerInit = {}
local listeners = {}           -- lista de funciones que deben ejecutarse por jugador
local initialized = {}         -- mapa player -> true si ya fue inicializado

-- Ejecuta todos los listeners de forma segura para un jugador (en diferido)
local function runListenersForPlayer(player)
	for _, entry in ipairs(listeners) do
		if entry and entry.active then
			task.defer(function()
				local ok, err = pcall(entry.callback, player)
				if not ok then
					warn(("PlayerInit: listener error for %s: %s"):format(player.Name, tostring(err)))
				end
			end)
		end
	end
end

-- Handler cuando entra un jugador
local function handlePlayerAdded(player)
	if initialized[player] then
		return
	end
	initialized[player] = true
	runListenersForPlayer(player)
end

-- Limpieza cuando se va un jugador (evita fugas de memoria)
local function handlePlayerRemoving(player)
	initialized[player] = nil
end

Players.PlayerAdded:Connect(handlePlayerAdded)
Players.PlayerRemoving:Connect(handlePlayerRemoving)

-- Inicializar jugadores ya presentes (cuando el módulo se carga)
for _, p in ipairs(Players:GetPlayers()) do
	handlePlayerAdded(p)
end

-- API: registra un listener. Cuando se registre, se ejecutará inmediatamente
-- para los jugadores que ya están inicializados.
--[=[
	Registers a per-player callback.

	The callback runs once for every player who joins from this point on, and
	immediately (deferred) for every player already present and already announced.
	It never runs twice for the same player through this module.

	@param callback (player: Player) -> () -- invoked once per player
	@return () -> () -- call to deactivate this listener
	@error "PlayerInit.Connect expects a function" -- raised when `callback` is not a function
]=]
function PlayerInit.Connect(callback)
	assert(type(callback) == "function", "PlayerInit.Connect expects a function")

	local entry = {callback = callback, active = true}
	table.insert(listeners, entry)

	for _, p in ipairs(Players:GetPlayers()) do
		if initialized[p] then
			task.defer(function()
				if not entry.active then
					return
				end

				local ok, err = pcall(callback, p)
				if not ok then
					warn(("PlayerInit: listener initial run failed for %s: %s"):format(p.Name, tostring(err)))
				end
			end)
		end
	end

	return function()
		entry.active = false
	end
end

return PlayerInit
