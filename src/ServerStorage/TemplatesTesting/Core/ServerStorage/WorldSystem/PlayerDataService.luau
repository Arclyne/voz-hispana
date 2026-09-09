--!strict
local Profiles = require(script.Parent.Profiles)
local DataKit = require(script.Parent.Parent.DataKit)

type Store = DataKit.Store

local stores: { [Player]: Store } = {}
local beforeClose: { (Player, Store) -> () } = {}
local closing: { [Player]: boolean } = {}

--[=[
	Registro de un [`Store`](/api/Store) por jugador: cargar, acceder y cerrar.

	Es la capa fina entre el resto del juego y DataKit. Nadie más debería llamar a
	`Profiles.WorldsPlayer.load` directamente: quien necesite los datos de un jugador pide
	aquí.

	Tres detalles que importan más de lo que parece:

	* **`load` es idempotente.** Devuelve el store existente si ya lo hay, así que varios
	  sistemas pueden llamarlo al entrar un jugador sin coordinarse. Y se auto-limpia: el
	  `onEnd` del store borra la entrada, pero solo si sigue siendo la misma —comprueba
	  `stores[player] == store` antes de tocar nada, para no borrar un store nuevo.
	* **`close` corre los callbacks antes de soltar el store.** El orden es deliberado:
	  `runBeforeClose` primero, `stores[player] = nil` después, de modo que un callback
	  todavía puede llamar a `get` y encontrarlo.
	* **`close` está protegido contra reentrada** con el mapa `closing`, y cada callback va
	  dentro de un `pcall`: uno que falle no impide que corran los demás ni que el perfil se
	  cierre.

	`closeAll` copia la lista de jugadores antes de recorrerla, para no mutar la tabla
	mientras itera.

	@class PlayerDataService
	@server
]=]
local PlayerDataService = {}

function PlayerDataService.onBeforeClose(fn: (Player, Store) -> ())
	table.insert(beforeClose, fn)
end

local function runBeforeClose(player: Player, store: Store)
	for _, fn in beforeClose do
		local ok, err = pcall(fn, player, store)
		if not ok then
			warn(("[PlayerDataService] beforeClose falló para %s: %s"):format(player.Name, tostring(err)))
		end
	end
end

function PlayerDataService.load(player: Player): Store
	local existing = stores[player]
	if existing then
		return existing
	end

	local store = Profiles.WorldsPlayer.load(tostring(player.UserId))
	stores[player] = store

	store:onEnd():Connect(function()
		if stores[player] == store then
			stores[player] = nil
		end
	end)

	return store
end

function PlayerDataService.get(player: Player): Store?
	return stores[player]
end

function PlayerDataService.getData(player: Player): any?
	local store = stores[player]
	if store and store:isReady() then
		return store:get()
	end
	return nil
end

function PlayerDataService.update(player: Player, fn: (any) -> any): boolean
	local store = stores[player]
	if not store then
		return false
	end
	store:update(fn)
	return true
end

function PlayerDataService.close(player: Player)
	local store = stores[player]
	if not store or closing[player] then
		return
	end

	closing[player] = true
	runBeforeClose(player, store)
	stores[player] = nil
	closing[player] = nil

	store:close()
end

function PlayerDataService.closeAll()
	local pending = {}
	for player in pairs(stores) do
		table.insert(pending, player)
	end

	for _, player in pending do
		PlayerDataService.close(player)
	end
end

return PlayerDataService
