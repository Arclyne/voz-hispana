--!strict
--[[
	Adaptador de Instance: la capa que sustituye a React.

	Aporta tres cosas que el Controller a secas no puede dar:

	1. `from` implicito. El valor de partida es el que la propiedad ya tiene. Esto
	   es lo que hace ergonomica la API vanilla: no declaras el estado inicial,
	   ya esta en el objeto.

	2. Setters memoizados. Se resuelve una vez por clave que se escribe, para no
	   pagar el analisis del nombre en cada frame.

	3. Ciclo de vida. Se conecta a `Destroying` y se auto-destruye. Ver
	   `docs/DESIGN.md` seccion 3.5: la fuga silenciosa es el fallo caracteristico
	   de las bibliotecas de animacion vanilla en Roblox.

	Las claves con prefijo `@` escriben atributos en vez de propiedades:

		Kinetic.animate(part, { ["@Glow"] = 1 })

	El adaptador de cada clave se fija en la primera escritura y no se revalida.
	Ver la limitacion documentada en `docs/DESIGN.md` seccion 3.4.
]]

local Animatable = require(script.Parent.Parent.animatable)
local Controller = require(script.Parent.Parent.core.Controller)
local types = require(script.Parent.Parent.types)

type SpringProps = types.SpringProps
type ValueMap = types.ValueMap

local instanceTarget = {}

-- Prefijo que marca una clave como atributo en lugar de propiedad.
local ATTRIBUTE_PREFIX = "@"

instanceTarget.ATTRIBUTE_PREFIX = ATTRIBUTE_PREFIX

local function isAttribute(key: string): boolean
	return string.sub(key, 1, 1) == ATTRIBUTE_PREFIX
end

-- Lee el valor actual de una propiedad o atributo, para usarlo como `from`.
function instanceTarget.read(instance: Instance, key: string): any
	if isAttribute(key) then
		return instance:GetAttribute(string.sub(key, 2))
	end

	local ok, value = pcall(function()
		return (instance :: any)[key]
	end)
	return if ok then value else nil
end

-- Escribe un valor. No valida el tipo: eso se hizo al construir el controller.
function instanceTarget.write(instance: Instance, key: string, value: any)
	if isAttribute(key) then
		instance:SetAttribute(string.sub(key, 2), value)
	else
		(instance :: any)[key] = value
	end
end

-- Crea un Controller enlazado a las propiedades de una instancia.
function instanceTarget.animate(instance: Instance, props: SpringProps): Controller.Controller
	assert(typeof(instance) == "Instance", "Kinetic.animate espera una Instance como primer argumento")

	local targets, options = Controller.splitProps(props)

	--[[
		`from` implicito: lo que la propiedad ya vale. Solo se rellenan las claves
		que el usuario no declaro explicitamente.
	]]
	local from: ValueMap = {}
	if options.from then
		for key, value in options.from :: ValueMap do
			from[key] = value
		end
	end

	local function seed(key: string)
		if from[key] ~= nil then
			return
		end
		local current = instanceTarget.read(instance, key)
		if current == nil then
			error(
				string.format(
					"Kinetic.animate: '%s' no existe en %s (o su atributo no esta definido). "
						.. "Para un atributo nuevo, declara su valor inicial en `from`.",
					key,
					instance.ClassName
				),
				3
			)
		end
		if not Animatable.isAnimatable(current) then
			error(
				string.format(
					"Kinetic.animate: '%s' es de tipo %s, que Kinetic no sabe animar. "
						.. "Registra un adaptador con Kinetic.registerType si lo necesitas.",
					key,
					typeof(current)
				),
				3
			)
		end
		from[key] = current
	end

	for key in targets do
		seed(key)
	end
	-- Una cadena asincrona declara sus claves en los pasos, no en el nivel superior.
	local to = options.to
	if typeof(to) == "table" and (to :: any)[1] ~= nil then
		for _, step in to :: { ValueMap } do
			for key in step do
				seed(key)
			end
		end
	end

	--[[
		Se construye solo con `from` y las opciones, sin destinos, para que el
		Controller no arranque antes de que el sink este conectado.
	]]
	local initial: SpringProps = {}
	for key, value in options :: any do
		if key ~= "to" then
			(initial :: any)[key] = value
		end
	end
	initial.from = from

	local controller = Controller.new(initial)

	local writers: { [string]: (value: any) -> () } = {}

	local function writerFor(key: string): (value: any) -> ()
		local writer = writers[key]
		if writer then
			return writer
		end
		if isAttribute(key) then
			local name = string.sub(key, 2)
			writer = function(value)
				instance:SetAttribute(name, value)
			end
		else
			writer = function(value)
				(instance :: any)[key] = value
			end
		end
		writers[key] = writer
		return writer
	end

	controller:onChange(function(values)
		for key, value in values do
			writerFor(key)(value)
		end
	end)

	--[[
		Sin esto, destruir la instancia deja el resorte corriendo y escribiendo en
		un objeto huerfano: la fuga caracteristica de este tipo de biblioteca.
	]]
	local destroying
	destroying = instance.Destroying:Connect(function()
		destroying:Disconnect()
		controller:destroy()
	end)

	if next(targets) ~= nil or typeof(to) == "table" then
		controller:start(props)
	end

	return controller
end

return instanceTarget
