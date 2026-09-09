--!strict
--[[
	Normalizacion de la configuracion fisica.

	Rellena defaults y deriva `tension`/`friction` cuando el usuario pide una
	`frequency`, que suele ser mas intuitiva: "quiero que rebote dos veces por segundo"
	es mas facil de razonar que "quiero tension 210".
]]

local constants = require(script.Parent.Parent.constants)
local types = require(script.Parent.Parent.types)

type SpringConfig = types.SpringConfig

-- Config completamente resuelta: sin campos opcionales que el motor tenga que comprobar.
export type ResolvedConfig = {
	mass: number,
	tension: number,
	friction: number,
	clamp: boolean,
	damping: number,
	velocity: number | { number },
	easing: types.EasingFunction,
	progress: number,
	precision: number?,
	restVelocity: number?,
	bounce: number?,
	duration: number?,
	frequency: number?,
	round: number?,
}

local DEFAULTS: ResolvedConfig = table.freeze({
	mass = 1,
	tension = constants.config.default.tension :: number,
	friction = constants.config.default.friction :: number,
	clamp = false,
	damping = 1,
	velocity = 0,
	easing = constants.easings.linear,
	progress = 0,
})

local AnimationConfig = {}

-- Fusiona `base` con `override` y rellena los defaults que falten.
--
-- Devuelve siempre una tabla nueva: el llamador puede quedarsela sin miedo a
-- que una animacion posterior la mute.
function AnimationConfig.resolve(base: SpringConfig?, override: SpringConfig?): ResolvedConfig
	local config = {}

	if base then
		for key, value in base :: any do
			config[key] = value
		end
	end

	if override then
		for key, value in override :: any do
			config[key] = value
		end
	end

	for key, value in DEFAULTS :: any do
		if config[key] == nil then
			config[key] = value
		end
	end

	--[[
		Con `frequency`, tension y friction dejan de ser entradas y pasan a ser
		derivadas: la frecuencia natural de un oscilador es sqrt(k/m), asi que
		k = (2*pi/f)^2 * m, y la friccion critica es 2*sqrt(k*m) escalada por damping.
	]]
	if config.frequency ~= nil then
		local frequency = math.max(config.frequency, 0.01)
		local damping = math.max(config.damping, 0)

		config.frequency = frequency
		config.damping = damping
		config.tension = ((2 * math.pi / frequency) ^ 2) * config.mass
		config.friction = (4 * math.pi * damping * config.mass) / frequency
	end

	return config
end

-- Config por defecto, congelada. No la mutes.
AnimationConfig.DEFAULTS = DEFAULTS

return AnimationConfig
