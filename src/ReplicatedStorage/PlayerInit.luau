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
	Reparto diferido de `Players.PlayerAdded`.

	Los scripts de plantilla los importa en ejecución `ImportTemplates.server.luau` y
	solo después los activa `InitScripts.server.luau`. Por eso, un script que se conecte
	directamente a `Players.PlayerAdded` puede perderse a los jugadores que entraron
	mientras la importación seguía en curso. Este módulo mantiene su propia conexión
	desde el momento en que se le hace `require` por primera vez, recuerda a qué
	jugadores ya ha anunciado, y reproduce ese anuncio para los listeners que se
	registren más tarde.

	Los callbacks se invocan con `task.defer` y envueltos en `pcall`, así que un listener
	que falle ni bloquea ni rompe a los demás.

	El módulo se usa desde ambos lados. En el servidor anuncia a todos los jugadores. En
	el cliente `Players.PlayerAdded` dispara para *todos* los jugadores, así que los
	consumidores de contexto cliente filtran por `Players.LocalPlayer` ellos mismos:
	este módulo no hace ese filtrado por ellos.

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
	Registra un callback por jugador.

	El callback se ejecuta una vez por cada jugador que entre a partir de este momento, y
	de inmediato (de forma diferida) por cada jugador ya presente y ya anunciado. A través
	de este módulo nunca se ejecuta dos veces para el mismo jugador.

	@param callback (player: Player) -> () -- se invoca una vez por jugador
	@return () -> () -- llámalo para desactivar este listener
	@error "PlayerInit.Connect expects a function" -- se lanza cuando `callback` no es una función
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
