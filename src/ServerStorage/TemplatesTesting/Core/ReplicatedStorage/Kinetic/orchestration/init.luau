--!strict
--[[
	Coordinacion entre varios controllers.

	Nota de diseno: solo `trail` entra aqui. Un desfase con retraso fijo (todos al
	mismo destino, solo se retrasa el arranque) no necesita ser una funcion de la
	biblioteca: con `Controller.start` soportando `delay`, se resuelve en tres lineas
	del lado del usuario. Se documenta como receta en `docs/DESIGN.md` seccion 4.8 en
	vez de anadirse aqui como superficie publica a mantener.

	`trail` si es una primitiva real: cada controller lee en vivo la posicion del
	anterior, frame a frame, asi que el desfase emerge de la fisica (inercia real en
	la cadena) y no es trivial de escribir a mano.
]]

local Completion = require(script.Parent.util.Completion)
local Controller = require(script.Parent.core.Controller)
local Transition = require(script.Transition)
local types = require(script.Parent.types)

type SpringProps = types.SpringProps
type ValueMap = types.ValueMap

local orchestration = {}

--[[
	`count` controllers encadenados por fisica: el primero va al destino y cada uno
	de los siguientes persigue la posicion *actual* del anterior.

	Devuelve el arreglo de controllers. Arrancar la cadena es arrancar el primero;
	los demas se mueven solos al seguirlo.
]]
function orchestration.trail(count: number, props: SpringProps): { Controller.Controller }
	assert(type(count) == "number" and count >= 1, "Kinetic.trail necesita un `count` de al menos 1")

	local targets, options = Controller.splitProps(props)
	local controllers: { Controller.Controller } = table.create(count)

	for i = 1, count do
		--[[
			Solo el primero recibe los destinos; el resto nace quieto en `from` y
			se pone en marcha cuando su predecesor empieza a moverse.
		]]
		local ownProps: SpringProps = {}
		for key, value in options :: any do
			(ownProps :: any)[key] = value
		end
		if i == 1 then
			for key, value in targets do
				(ownProps :: any)[key] = value
			end
		end
		controllers[i] = Controller.new(ownProps)
	end

	for i = 2, count do
		local follower = controllers[i]
		controllers[i - 1]:onChange(function(values)
			for key, value in values do
				local spring = follower._springs[key]
				if spring then
					spring:retarget(value)
				end
			end
		end)
	end

	return controllers
end

-- Ejecuta las animaciones una tras otra. Cada paso es una funcion que devuelve
-- una Completion; se llama cuando le toca, no antes.
function orchestration.sequence(steps: { () -> Completion.Completion }): Completion.Completion
	local completion = Completion.new()

	task.spawn(function()
		local last
		for _, step in steps do
			local result = step()
			-- Aceptamos tanto una Completion ya creada como una funcion que la crea.
			last = if type(result) == "table" and (result :: any).await then (result :: any):await() else result
		end
		completion:_settle(last or { value = 0, finished = true, cancelled = false })
	end)

	return completion
end

-- Espera a que todas terminen.
function orchestration.parallel(completions: { Completion.Completion }): Completion.Completion
	local completion = Completion.new()
	local pending = #completions

	if pending == 0 then
		completion:_settle({ value = 0, finished = true, cancelled = false })
		return completion
	end

	local anyCancelled = false
	local lastResult

	for _, item in completions do
		item:andThen(function(result)
			lastResult = result
			if result.cancelled then
				anyCancelled = true
			end
			pending -= 1
			if pending == 0 then
				completion:_settle({
					value = lastResult.value,
					finished = not anyCancelled,
					cancelled = anyCancelled,
				})
			end
		end)
	end

	return completion
end

--[[
	Ciclo de vida de instancias en una lista: enter / update / leave.
	La implementacion vive en `Transition.luau`.
]]
function orchestration.transition(props: Transition.TransitionProps): Transition.Transition
	return Transition.new(props)
end

return orchestration
