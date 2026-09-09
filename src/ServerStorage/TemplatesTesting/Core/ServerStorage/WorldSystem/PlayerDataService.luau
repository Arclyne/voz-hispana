--!strict
local Profiles = require(script.Parent.Profiles)
local DataKit = require(script.Parent.Parent.DataKit)

type Store = DataKit.Store

local stores: { [Player]: Store } = {}
local beforeClose: { (Player, Store) -> () } = {}
local closing: { [Player]: boolean } = {}

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
