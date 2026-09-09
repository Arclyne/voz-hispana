--!strict
--[[
	Ciclo de vida de instancias en una lista: enter / update / leave.

	Es el punto donde una biblioteca vanilla aporta mas que su equivalente en React.
	En React el reconciliador ya sabe que elementos entraron y cuales salieron; en
	vanilla eso lo tienes que llevar tu, y sobre todo tienes que acordarte de
	**no destruir la instancia hasta que su animacion de salida termine**. Ese
	"destruir despues" es codigo repetitivo que todo el mundo escribe mal al menos
	una vez: se destruye antes de tiempo y la salida no se ve, o se olvida y fuga.

	El diff se hace por clave, no por indice, para que reordenar la lista no se
	interprete como que todo salio y todo volvio a entrar.
]]

local Controller = require(script.Parent.Parent.core.Controller)
local instanceTarget = require(script.Parent.Parent.targets.instance)
local types = require(script.Parent.Parent.types)

type SpringProps = types.SpringProps
type ValueMap = types.ValueMap

--[=[
	@interface TransitionProps
	@within Transition
	.key (item: any) -> any -- Identidad estable de cada elemento. Sin esto no se puede distinguir un reordenamiento de una entrada/salida.
	.create (item: any) -> Instance -- Crea la instancia de un elemento que entra.
	.render ((instance: Instance, values: ValueMap, item: any) -> ())? -- Escribe los valores en la instancia. Si se omite, se escriben como propiedades.
	.from ValueMap? -- Valores de partida de quien entra.
	.enter ValueMap? -- Destino al entrar.
	.leave ValueMap? -- Destino al salir. Al terminar, la instancia se destruye.
	.update ValueMap? -- Destino de los que ya estaban y siguen estando.
	.config SpringConfig? -- Fisica compartida por todos los elementos.
	.trail number? -- Segundos de desfase entre elementos consecutivos.
	.parent Instance? -- Donde parentar las instancias creadas.
]=]
export type TransitionProps = {
	key: (item: any) -> any,
	create: (item: any) -> Instance,
	render: ((instance: Instance, values: ValueMap, item: any) -> ())?,
	from: ValueMap?,
	enter: ValueMap?,
	leave: ValueMap?,
	update: ValueMap?,
	config: types.SpringConfig?,
	trail: number?,
	parent: Instance?,
}

type Entry = {
	key: any,
	item: any,
	instance: Instance,
	controller: Controller.Controller,
	leaving: boolean,
}

--[=[
	@class Transition

	Gestiona el ciclo de vida de instancias en una lista: enter / update / leave.
	Se crea con [Kinetic.transition].

	Es el punto donde una biblioteca vanilla aporta mas que su equivalente en React.
	En React el reconciliador ya sabe que entro y que salio; en vanilla eso lo llevas
	tu, y sobre todo tienes que acordarte de **no destruir la instancia hasta que su
	animacion de salida termine**. Ese "destruir despues" es codigo repetitivo que
	todo el mundo escribe mal al menos una vez: o se destruye antes de tiempo y la
	salida no se ve, o se olvida y fuga.
]=]
local Transition = {}
Transition.__index = Transition

export type Transition = typeof(setmetatable(
	{} :: {
		_props: TransitionProps,
		_entries: { Entry },
		_byKey: { [any]: Entry },
		_destroyed: boolean,
	},
	Transition
))

local function writeValues(entry: Entry, props: TransitionProps)
	local render = props.render
	if render then
		render(entry.instance, entry.controller:get(), entry.item)
		return
	end
	for key, value in entry.controller:get() do
		instanceTarget.write(entry.instance, key, value)
	end
end

function Transition.new(props: TransitionProps): Transition
	assert(type(props.key) == "function", "Kinetic.transition necesita `key`")
	assert(type(props.create) == "function", "Kinetic.transition necesita `create`")

	return setmetatable({
		_props = props,
		_entries = {},
		_byKey = {},
		_destroyed = false,
	}, Transition)
end

function Transition._createEntry(self: Transition, item: any, key: any, index: number): Entry
	local props = self._props
	local instance = props.create(item)

	local initial: SpringProps = { config = props.config }
	if props.from then
		initial.from = table.clone(props.from)
	end

	local controller = Controller.new(initial)
	local entry: Entry = {
		key = key,
		item = item,
		instance = instance,
		controller = controller,
		leaving = false,
	}

	controller:onChange(function()
		if entry.instance.Parent ~= nil or props.parent == nil then
			writeValues(entry, props)
		end
	end)

	-- Primera escritura antes de parentar: evita un frame con el valor sin animar.
	writeValues(entry, props)
	if props.parent then
		instance.Parent = props.parent
	end

	if props.enter then
		local enterProps: SpringProps = table.clone(props.enter) :: any
		if props.trail then
			enterProps.delay = (index - 1) * props.trail
		end
		controller:start(enterProps)
	end

	return entry
end

function Transition._removeEntry(self: Transition, entry: Entry)
	local index = table.find(self._entries, entry)
	if index then
		table.remove(self._entries, index)
	end
	if self._byKey[entry.key] == entry then
		self._byKey[entry.key] = nil
	end
	entry.controller:destroy()
	entry.instance:Destroy()
end

function Transition._startLeave(self: Transition, entry: Entry, index: number)
	local props = self._props
	entry.leaving = true

	if not props.leave then
		self:_removeEntry(entry)
		return
	end

	local leaveProps: SpringProps = table.clone(props.leave) :: any
	if props.trail then
		leaveProps.delay = (index - 1) * props.trail
	end

	entry.controller:start(leaveProps):andThen(function(result)
		--[[
			El elemento pudo volver a entrar mientras salia: en ese caso `leaving`
			ya es false y destruir la instancia seria borrar algo que esta en uso.
			Tampoco destruimos si la salida fue cancelada por otra animacion.
		]]
		if self._destroyed or not entry.leaving or result.cancelled then
			return
		end
		self:_removeEntry(entry)
	end)
end

--[=[
	@method update
	@within Transition
	@param items { any }

	Reconcilia la lista: crea los que entran, actualiza los que siguen y saca los que
	ya no estan.

	El diff se hace por `key`, no por indice, para que reordenar la lista no cuente
	como que todo salio y volvio a entrar. Si un elemento vuelve mientras salia, se
	cancela su salida y regresa desde donde este, sin saltar.
]=]
function Transition.update(self: Transition, items: { any })
	if self._destroyed then
		return
	end

	local props = self._props
	local seen: { [any]: true } = {}

	for index, item in items do
		local key = props.key(item)
		seen[key] = true

		local entry = self._byKey[key]

		if entry == nil then
			entry = self:_createEntry(item, key, index)
			self._byKey[key] = entry
			table.insert(self._entries, entry)
			continue
		end

		entry.item = item

		if entry.leaving then
			--[[
				Volvio antes de terminar de salir. Cancelamos la salida y lo mandamos
				de vuelta a `enter` desde donde este, sin saltar: es justo el caso que
				la fisica de resortes resuelve mejor que un tween.
			]]
			entry.leaving = false
			if props.enter then
				entry.controller:start(table.clone(props.enter) :: any)
			end
		elseif props.update then
			entry.controller:start(table.clone(props.update) :: any)
		end
	end

	-- Recorremos al reves: `_startLeave` puede sacar la entrada de la lista en el acto.
	for index = #self._entries, 1, -1 do
		local entry = self._entries[index]
		if not seen[entry.key] and not entry.leaving then
			self:_startLeave(entry, index)
		end
	end
end

--[=[
	@method getInstances
	@within Transition
	@return { Instance }

	Instancias vivas, en el orden en que entraron. Incluye las que estan saliendo.
]=]
function Transition.getInstances(self: Transition): { Instance }
	local out = table.create(#self._entries)
	for _, entry in self._entries do
		table.insert(out, entry.instance)
	end
	return out
end

--[=[
	@method getController
	@within Transition
	@param key any
	@return Controller?

	Controller de un elemento por su clave, o `nil` si no esta vivo.
]=]
function Transition.getController(self: Transition, key: any): Controller.Controller?
	local entry = self._byKey[key]
	return if entry then entry.controller else nil
end

--[=[
	@method count
	@within Transition
	@return number

	Cuantos elementos hay vivos, contando los que estan saliendo.
]=]
function Transition.count(self: Transition): number
	return #self._entries
end

--[=[
	@method destroy
	@within Transition

	Destruye todas las instancias de golpe, sin animar la salida.
]=]
function Transition.destroy(self: Transition)
	if self._destroyed then
		return
	end
	self._destroyed = true

	for _, entry in self._entries do
		entry.controller:destroy()
		entry.instance:Destroy()
	end
	table.clear(self._entries)
	table.clear(self._byKey)
end

return Transition
