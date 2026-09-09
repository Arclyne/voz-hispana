--!strict
local ServerStorage = game:GetService("ServerStorage")

local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local Profiles = require(worldSystemStorage:WaitForChild("Profiles"))
local DataKit = require(ServerStorage:WaitForChild("DataKit"))
local Signal = require(ServerStorage.DataKit.Signal)
local deepCopy = require(ServerStorage.DataKit.Util.deepCopy)
local deepEquals = require(ServerStorage.DataKit.Util.deepEquals)

type Store = DataKit.Store

local SECTION_BY_STORE = {
	WorldSettingsStore = "settings",
	WorldRolesStore = "roles",
	WorldBansStore = "bans",
	WorldContentStore = "content",
}

export type StartConfig = {
	serverKey: string,
	ownerId: number,
	displayName: string,
	accessCode: string?,
}

local WorldService = {}

WorldService.OwnerId = nil :: number?
WorldService.IsDestroyed = false
WorldService.OnStoreUpdated = Signal.new()

local currentStore: Store? = nil
local currentServerKey: string? = nil
local currentAccessCode: string? = nil
local lastSections: { [string]: any } = {}

local function fireChangedSections(data: any)
	for storeName, section in SECTION_BY_STORE do
		local value = data[section]
		if not deepEquals(lastSections[section], value) then
			lastSections[section] = deepCopy(value)
			WorldService.OnStoreUpdated:Fire(storeName, deepCopy(value))
		end
	end
end

function WorldService.start(config: StartConfig): Store
	if currentStore then
		return currentStore
	end

	local store = Profiles.World.load(config.serverKey, {
		leaseMeta = {
			placeId = game.PlaceId,
			jobId = game.JobId,
			accessCode = config.accessCode,
		},
	})

	currentStore = store
	currentServerKey = config.serverKey
	currentAccessCode = config.accessCode
	WorldService.OwnerId = config.ownerId
	WorldService.IsDestroyed = false

	store:update(function(data)
		if data.settings.OwnerId == 0 then
			data.settings.OwnerId = config.ownerId
			data.settings.Name = config.displayName
		end
		return data
	end)

	store:onChanged():Connect(fireChangedSections)

	return store
end

function WorldService.GetInstance()
	if currentStore and not WorldService.IsDestroyed and currentStore:isReady() then
		return WorldService
	end
	return nil
end

function WorldService.getStore(): Store?
	return currentStore
end

function WorldService.getServerKey(): string?
	return currentServerKey
end

function WorldService.getAccessCode(): string?
	return currentAccessCode
end

function WorldService.isReady(): boolean
	return currentStore ~= nil and currentStore:isReady()
end

function WorldService.get(): any?
	if currentStore and currentStore:isReady() then
		return deepCopy(currentStore:get())
	end
	return nil
end

function WorldService.update(fn: (any) -> any): boolean
	if not currentStore or WorldService.IsDestroyed then
		return false
	end
	currentStore:update(fn)
	return true
end

function WorldService.GetStoreData(_self: any, storeName: string): any?
	local section = SECTION_BY_STORE[storeName]
	if not section then
		warn("[WorldService] Store desconocido:", storeName)
		return nil
	end
	local data = WorldService.get()
	return data and data[section] or nil
end

function WorldService.UpdateStore(_self: any, storeName: string, editor: (any) -> any?): boolean
	local section = SECTION_BY_STORE[storeName]
	if not section then
		warn("[WorldService] Store desconocido:", storeName)
		return false
	end
	if not currentStore or WorldService.IsDestroyed then
		return false
	end

	local sectionCopy = WorldService.GetStoreData(nil, storeName)
	local ok, resultOrErr = pcall(editor, sectionCopy)
	if not ok then
		warn("[WorldService] UpdateStore fallo:", resultOrErr)
		return false
	end
	if resultOrErr == nil then
		return false
	end

	currentStore:update(function(data)
		data[section] = resultOrErr
		return data
	end)
	return true
end

function WorldService.destroy()
	if WorldService.IsDestroyed then
		return
	end
	WorldService.IsDestroyed = true
	local store = currentStore
	if store then
		store:close()
	end
end

return WorldService
