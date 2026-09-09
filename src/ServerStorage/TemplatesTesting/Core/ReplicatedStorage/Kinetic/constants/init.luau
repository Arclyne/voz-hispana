--!strict

return table.freeze({
	config = require(script.configs),
	easings = require(script.easings),

	-- Sub-paso fijo del integrador, en milisegundos. Ver `docs/DESIGN.md` seccion 3.3.
	STEP_MS = 2,
	-- Tope de delta por frame, en segundos. Evita que un hitch dispare la simulacion.
	MAX_DELTA = 0.064,
	-- Precision minima; por debajo, un resorte nunca alcanzaria el reposo.
	MIN_PRECISION = 0.0001,
})
