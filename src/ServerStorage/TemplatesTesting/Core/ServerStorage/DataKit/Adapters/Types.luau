--!strict

--[=[
	@class Types

	Contrato de los servicios externos que consume DataKit. Producción inyecta los
	adapters reales (ver [Adapters]); los tests inyectan fakes equivalentes en memoria
	(ver [Testing]). Que todo dependa de estas interfaces —y no de los servicios de
	Roblox directamente— es lo que hace al motor testeable.

	El contrato declara **solo lo que DataKit llama de verdad**. En particular no incluye
	`SetAsync`: toda escritura pasa por `UpdateAsync` para preservar el *fence* durable (un
	fence reseteado dejaría que un dueño viejo pisara al vigente). Como el `UpdateAsync` de
	Roblox no acepta `userIds`, DataKit tampoco etiqueta datos con UserIds — es agnóstico a
	si la identidad es un jugador.
]=]

export type DataStoreLike = {
	GetAsync: (self: DataStoreLike, key: string) -> any,
	UpdateAsync: (self: DataStoreLike, key: string, transform: (any) -> any) -> any,
	RemoveAsync: (self: DataStoreLike, key: string) -> any,
}

export type DataStoreServiceLike = {
	GetDataStore: (self: DataStoreServiceLike, name: string, scope: string?) -> DataStoreLike,
}

export type MemoryHashMapLike = {
	GetAsync: (self: MemoryHashMapLike, key: string) -> any,
	SetAsync: (self: MemoryHashMapLike, key: string, value: any, ttl: number) -> any,
	UpdateAsync: (self: MemoryHashMapLike, key: string, transform: (any?) -> any, ttl: number) -> any,
	RemoveAsync: (self: MemoryHashMapLike, key: string) -> (),
}

export type MemoryStoreServiceLike = {
	GetHashMap: (self: MemoryStoreServiceLike, name: string) -> MemoryHashMapLike,
}

export type Connection = { Disconnect: (self: Connection) -> () }
export type ConnectHeartbeat = (fn: (dt: number) -> ()) -> Connection
export type Clock = () -> number
export type Wait = (seconds: number) -> ()

--[=[
	@interface Deps
	@within Types

	Bundle inyectable que recibe cada módulo de DataKit (default = servicios reales). Son
	exactamente los servicios que el núcleo consume: persistencia (`dataStore`), candado
	(`memoryStore`), tiempo (`now`, `wait`, `connectHeartbeat`) e identidad de este server
	(`serverId`). DataKit no conoce jugadores ni mensajería.
]=]
export type Deps = {
	dataStore: DataStoreServiceLike,
	memoryStore: MemoryStoreServiceLike,
	now: Clock,
	wait: Wait,
	connectHeartbeat: ConnectHeartbeat,
	serverId: string,
}

return {}
