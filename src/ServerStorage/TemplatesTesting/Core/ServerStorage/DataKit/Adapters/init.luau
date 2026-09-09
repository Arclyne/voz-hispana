--!strict
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local Types = require(script.Types)

--[=[
	@class Adapters

	Implementaciones reales de las interfaces de [Types] sobre los servicios de Roblox.
	`defaultDeps()` arma el bundle que usan los módulos cuando no se inyecta nada.
]=]
local Adapters = {}

local RealDataStore: Types.DataStoreServiceLike = {
	GetDataStore = function(_, name, scope)
		return (DataStoreService:GetDataStore(name, scope) :: any) :: Types.DataStoreLike
	end,
}

local RealMemoryStore: Types.MemoryStoreServiceLike = {
	GetHashMap = function(_, name)
		return (MemoryStoreService:GetHashMap(name) :: any) :: Types.MemoryHashMapLike
	end,
}

--[=[
	@within Adapters

	Bundle de [Types.Deps] con los servicios reales de Roblox.
]=]
function Adapters.defaultDeps(): Types.Deps
	return {
		dataStore = RealDataStore,
		memoryStore = RealMemoryStore,
		now = os.time,
		wait = task.wait,
		connectHeartbeat = function(fn)
			return (RunService.Heartbeat:Connect(fn) :: any) :: Types.Connection
		end,
		serverId = game.JobId,
	}
end

return Adapters
