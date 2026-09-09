--!strict
--[[
	Presets de configuracion fisica.

	Los valores son identicos a los de react-spring / roact-spring a proposito:
	quien ya tiene intuicion sobre `wobbly` debe obtener el mismo movimiento aqui.
]]

local types = require(script.Parent.Parent.types)

type SpringConfig = types.SpringConfig

local configs: { [string]: SpringConfig } = {
	default = table.freeze({ tension = 170, friction = 26 }),
	gentle = table.freeze({ tension = 120, friction = 14 }),
	wobbly = table.freeze({ tension = 180, friction = 12 }),
	stiff = table.freeze({ tension = 210, friction = 20 }),
	slow = table.freeze({ tension = 280, friction = 60 }),
	molasses = table.freeze({ tension = 280, friction = 120 }),
}

return table.freeze(configs)
