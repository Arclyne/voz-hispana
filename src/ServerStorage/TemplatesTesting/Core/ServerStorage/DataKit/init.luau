--!strict
local Store = require(script.Store)
local Profile = require(script.Profile)
local Lease = require(script.Lease)
local Signal = require(script.Signal)
local Types = require(script.Adapters.Types)

--[=[
	@class DataKit

	Fachada del paquete y **única** superficie pública. Instalado por wally, `Packages.DataKit`
	es un link ModuleScript: sus hijos no son accesibles, así que lo que no esté acá no existe
	para el consumidor.

	- [Profile] — la capa recomendada: declarás nombre, template y opciones una vez y `load(id)`
	  te da un [Store] por identidad.
	- [Store] — el primitivo por debajo, si necesitás construirlo a mano.
	- `transfer` ([Store.transfer]) — mueve valor entre dos stores sin poder duplicarlo.

	El resto (`BaseStore`, `Health`, `Mutex`, `Signal`, `Lease`, `Adapters`, `Util`) es **interno**:
	no se exporta y no hay que depender de ello. Los tipos que sí necesitás para tipar lo que la
	API te devuelve (`Lease` de `claimStaged`, `Signal`/`Connection` de los eventos, `Deps` para
	inyección) están exportados abajo.

	```lua
	local DataKit = require(game:GetService("ServerStorage").Packages.DataKit)

	local PlayerProfile = DataKit.Profile.define("Player", { coins = 0 })
	local store = PlayerProfile.load(tostring(player.UserId))
	```
]=]
local DataKit = {
	Store = Store,
	Profile = Profile,
	transfer = Store.transfer,
}

export type Store = Store.Store
export type StoreOptions = Store.Options
export type ConflictPolicy = Store.ConflictPolicy
export type TransferEndpoint = Store.TransferEndpoint
export type CurrentHost = Store.CurrentHost
export type CardSpec = Store.CardSpec
export type MessageHandler = Store.MessageHandler
export type ProfileDefinition = Profile.Definition

-- Tipos de cosas que la API pública devuelve: `claimStaged` da un Lease, los eventos de Store
-- (`onReady`, `onChanged`, ...) dan un Signal y `:Connect` una Connection.
export type Lease = Lease.Lease
export type Signal = Signal.Signal
export type Connection = Signal.Connection

-- Contrato de inyección: `StoreOptions.deps` espera esto (los tests y los fakes lo usan).
export type Deps = Types.Deps

return DataKit
