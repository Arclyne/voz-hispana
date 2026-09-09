--!strict
--[[
	Guardia de unidades de tiempo.

	Kinetic usa segundos en `delay`, `duration` y `velocity`, a diferencia de
	react-spring, que usa milisegundos. La trampa es copiar `delay = 300` de un
	ejemplo de react-spring: en segundos son cinco minutos de espera, y el sintoma
	("no pasa nada") parece que la biblioteca esta rota en vez de un error de unidad.

	Convertimos ese fallo silencioso en uno ruidoso. Ver `docs/DESIGN.md` seccion 4.4.
]]

-- Por encima de esto, el valor casi con seguridad venia en milisegundos.
local SUSPICIOUS_SECONDS = 20

local warned: { [string]: true } = {}

local timeGuard = {}

function timeGuard.check(field: string, value: number)
	if value <= SUSPICIOUS_SECONDS or warned[field] then
		return
	end

	warned[field] = true
	warn(
		string.format(
			"[Kinetic] `%s = %s` parece venir en milisegundos. Kinetic usa SEGUNDOS "
				.. "(a diferencia de react-spring): %s significa %.1f minutos. "
				.. "Si es intencional, ignora este aviso; solo se muestra una vez por campo.",
			field,
			tostring(value),
			tostring(value),
			value / 60
		)
	)
end

-- Para tests: permite volver a emitir el aviso de un campo ya avisado.
function timeGuard._reset()
	table.clear(warned)
end

return timeGuard
