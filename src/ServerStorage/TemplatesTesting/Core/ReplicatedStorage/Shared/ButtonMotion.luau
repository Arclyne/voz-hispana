--!strict
--[[
	ButtonMotion — feedback animado (hover / click / entrada) para los botones de
	la tablet, montado sobre Kinetic (resortes) en lugar de TweenService.

	Todo lo que se mueve vive en un UIScale creado al vuelo, nunca en el `Size` del
	botón: media tablet cuelga de UIListLayout y UIAspectRatioConstraint, y tocar
	el Size obligaría a recalcular el layout en cada frame de cada hover.

		ButtonMotion.bind(boton)             -- hover y click, y ya está
		ButtonMotion.bind(tarjeta).enter(3)  -- además, entrada escalonada
		ButtonMotion.bindAll(menu, { skip = ... })
		ButtonMotion.unbind(boton)           -- lo devuelve a su estado original

	Los controllers de Kinetic se crean en el primer hover, no al enlazar: la
	tablet ronda los 150 botones y la mayoría no se toca en toda una sesión.

	`bind` es idempotente: llamarlo dos veces sobre el mismo botón devuelve el
	mismo Motion en vez de duplicar conexiones. Eso es lo que permite que el
	barrido global y un controlador concreto se enlacen al mismo botón sin saber
	el uno del otro.

	Para dejar un botón fuera basta el atributo `CustomButtonAnimation` — lo pone
	solo AnimationButtons — o pasar `skip` a `bindAll`.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kinetic = require(ReplicatedStorage:WaitForChild("Kinetic"))

export type Motion = {
	enter: (order: number) -> (),
	shake: () -> (),
	release: () -> (),
	destroy: () -> (),
}

export type Options = {
	hoverScale: number?,
	pressScale: number?,
	enterScale: number?,
	stagger: number?,
	tint: boolean?,
	skip: ((button: GuiButton) -> boolean)?,
}

local ButtonMotion = {}

-- Un botón con su propia animación se marca con esto y el genérico lo respeta.
local SKIP_ATTRIBUTE = "CustomButtonAnimation"

ButtonMotion.SKIP_ATTRIBUTE = SKIP_ATTRIBUTE

local HOVER_SCALE = 1.06
local PRESS_SCALE = 0.93
local ENTER_SCALE = 0.72
local ICON_HOVER_SCALE = 1.14
local ICON_PRESS_SCALE = 0.96
local STROKE_HOVER_BOOST = 1.8
-- Desfase entre tarjeta y tarjeta al entrar, en segundos.
local STAGGER = 0.035
-- Un icono que casi llena el botón es un fondo, no un icono: no se escala.
local ICON_MAX_COVERAGE = 0.9
local ICON_NAMES = { Icon = true, image = true, Image = true, Imagen = true }

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

-- Débil por clave: un botón destruido no debe quedar vivo por estar aquí.
local bound: any = setmetatable({}, { __mode = "k" })

local NOOP: Motion = {
	enter = function() end,
	shake = function() end,
	release = function() end,
	destroy = function() end,
}

local function ensureScale(target: GuiObject): UIScale
	local existing = target:FindFirstChildOfClass("UIScale")
	if existing then
		return existing
	end

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = target
	return scale
end

local function findIcon(button: GuiButton): GuiObject?
	for _, child in button:GetChildren() do
		if child:IsA("ImageLabel") and ICON_NAMES[child.Name] then
			local size = child.Size
			if size.X.Scale < ICON_MAX_COVERAGE or size.Y.Scale < ICON_MAX_COVERAGE then
				return child
			end
		end
	end
	return nil
end

--[=[
	Engancha los resortes a un botón. Devuelve los disparadores manuales; el hover
	y el click se conectan solos.
]=]
function ButtonMotion.bind(button: GuiButton, options: Options?): Motion
	local existing = bound[button]
	if existing then
		return existing
	end

	if button:GetAttribute(SKIP_ATTRIBUTE) then
		return NOOP
	end

	local opts: Options = options or {}
	local hoverScale = opts.hoverScale or HOVER_SCALE
	local pressScale = opts.pressScale or PRESS_SCALE
	local enterScale = opts.enterScale or ENTER_SCALE
	local stagger = opts.stagger or STAGGER
	local tint = opts.tint ~= false

	-- El tinte automático de Roblox es un salto instantáneo que pelearía con el
	-- resorte de color: lo apagamos y lo animamos nosotros.
	local hadAutoButtonColor = button.AutoButtonColor
	button.AutoButtonColor = false

	local baseColor = button.BackgroundColor3

	-- Los controllers se crean en el primer uso. Con ~150 botones en la tablet,
	-- construirlos por adelantado sería pagar por casi nada.
	local scale: UIScale? = nil
	local body: any = nil
	local surface: any = nil
	local tilt: any = nil
	local strokeApi: any = nil
	local iconApi: any = nil
	local strokeResolved = false
	local iconResolved = false
	local baseThickness = 0
	local baseTransparency = 0

	local function bodyApi(): any
		if not body then
			scale = ensureScale(button)
			body = Kinetic.animate(scale :: UIScale, {
				from = { Scale = 1 },
				config = Kinetic.config.wobbly,
			})
		end
		return body
	end

	local function surfaceApi(): any
		if not surface then
			surface = Kinetic.animate(button, {
				from = { BackgroundColor3 = baseColor },
				config = Kinetic.config.stiff,
			})
		end
		return surface
	end

	-- Controller aparte del color: comparte instancia pero no clave, así un hover
	-- a media negación no aborta la cadena de rotación.
	local function tiltApi(): any
		if not tilt then
			tilt = Kinetic.animate(button, {
				from = { Rotation = 0 },
				config = Kinetic.config.stiff,
			})
		end
		return tilt
	end

	local function strokeMotion(): any
		if not strokeResolved then
			strokeResolved = true
			local stroke = button:FindFirstChildOfClass("UIStroke")
			if stroke then
				baseThickness = stroke.Thickness
				baseTransparency = stroke.Transparency
				strokeApi = Kinetic.animate(stroke, {
					from = { Thickness = baseThickness, Transparency = baseTransparency },
					config = Kinetic.config.stiff,
				})
			end
		end
		return strokeApi
	end

	local function iconMotion(): any
		if not iconResolved then
			iconResolved = true
			local icon = findIcon(button)
			if icon then
				iconApi = Kinetic.animate(ensureScale(icon), {
					from = { Scale = 1 },
					config = Kinetic.config.wobbly,
				})
			end
		end
		return iconApi
	end

	local hovered = false
	local pressed = false

	-- Un único punto que traduce (hovered, pressed) a destinos. Los eventos sólo
	-- tocan las banderas, así soltar el click fuera del botón no deja el estado
	-- pulsado colgado.
	local function apply()
		bodyApi():start({
			Scale = if pressed then pressScale elseif hovered then hoverScale else 1,
		})

		if tint then
			surfaceApi():start({
				BackgroundColor3 = if pressed
					then baseColor:Lerp(BLACK, 0.12)
					elseif hovered then baseColor:Lerp(WHITE, 0.16)
					else baseColor,
			})
		end

		local stroke = strokeMotion()
		if stroke then
			stroke:start({
				Thickness = if hovered then baseThickness * STROKE_HOVER_BOOST else baseThickness,
				Transparency = if hovered then 0 else baseTransparency,
			})
		end

		local icon = iconMotion()
		if icon then
			icon:start({
				Scale = if pressed then ICON_PRESS_SCALE elseif hovered then ICON_HOVER_SCALE else 1,
			})
		end
	end

	--[[
		El color base se relee al empezar cada hover, no se fija al enlazar: hay
		botones cuyo color lo cambia otro script para marcar estado (los Si/No de
		Ajustes, un botón deshabilitado, ...) y con un base fijo el hover se lo
		restauraría al salir. Sólo se relee si el resorte de color está quieto, para
		no tomar por base un tinte a medio camino.
	]]
	local function refreshBase()
		if not surface or surface:isIdle() then
			baseColor = button.BackgroundColor3
		end
	end

	local connections: { RBXScriptConnection } = {}

	local function connect(signal: RBXScriptSignal, handler: () -> ())
		table.insert(connections, (signal :: any):Connect(handler))
	end

	connect(button.MouseEnter, function()
		if not hovered then
			refreshBase()
		end
		hovered = true
		apply()
	end)

	connect(button.MouseLeave, function()
		hovered = false
		pressed = false
		apply()
	end)

	connect(button.MouseButton1Down, function()
		pressed = true
		apply()
	end)

	connect(button.MouseButton1Up, function()
		pressed = false
		apply()
	end)

	-- Mando: sin ratón no hay MouseEnter, pero sí foco de selección.
	connect(button.SelectionGained, function()
		if not hovered then
			refreshBase()
		end
		hovered = true
		apply()
	end)

	connect(button.SelectionLost, function()
		hovered = false
		pressed = false
		apply()
	end)

	local destroyed = false

	local motion: Motion = {
		-- Entrada escalonada. `order` es la posición en la fila, no un tiempo.
		enter = function(order: number)
			if destroyed then return end
			local api = bodyApi()
			-- `set` y no una escritura a pelo sobre el UIScale: con `delay` el
			-- resorte no escribe nada hasta arrancar, y cualquier animación que
			-- siguiera en vuelo pisaría el valor inicial. `set` corta y fija.
			api:set({ Scale = enterScale })
			api:start({
				Scale = 1,
				from = { Scale = enterScale },
				delay = math.max(0, order) * stagger,
				config = Kinetic.config.wobbly,
			})
		end,

		-- Negación: meneo corto y vuelta a cero.
		shake = function()
			if destroyed then return end
			tiltApi():start({
				to = {
					{ Rotation = -6 },
					{ Rotation = 6 },
					{ Rotation = -3 },
					{ Rotation = 0 },
				},
				config = Kinetic.config.stiff,
			})
		end,

		-- Para cuando algo externo roba el foco (un prompt encima, por ejemplo) y
		-- el MouseLeave nunca llega.
		release = function()
			if destroyed then return end
			hovered = false
			pressed = false
			apply()
		end,

		destroy = function()
			if destroyed then return end
			destroyed = true
			bound[button] = nil

			for _, connection in connections do
				connection:Disconnect()
			end
			table.clear(connections)

			-- Se deja el botón como estaba, no a medio hover. Uno a uno y no en una
			-- tabla: los controllers que nunca se crearon son nil y un constructor
			-- con huecos no se puede recorrer.
			if body then body:destroy() end
			if surface then surface:destroy() end
			if tilt then tilt:destroy() end
			if strokeApi then strokeApi:destroy() end
			if iconApi then iconApi:destroy() end
			if scale then
				(scale :: UIScale).Scale = 1
			end
			button.Rotation = 0
			if tint then
				button.BackgroundColor3 = baseColor
			end
			button.AutoButtonColor = hadAutoButtonColor
		end,
	}

	bound[button] = motion
	return motion
end

--[=[
	Desenlaza un botón y lo deja como estaba. Sirve para que un botón con
	animación propia se quite de encima la genérica aunque el barrido global se le
	haya adelantado.
]=]
function ButtonMotion.unbind(button: GuiButton)
	local motion = bound[button]
	if motion then
		motion.destroy()
	end
end

--[=[
	Enlaza todos los GuiButton que cuelguen de `root`, y los que aparezcan
	después: media tablet son plantillas que se clonan en runtime. Devuelve una
	función que corta el seguimiento.
]=]
function ButtonMotion.bindAll(root: Instance, options: Options?): () -> ()
	local opts: Options = options or {}
	local skip = opts.skip

	local function consider(instance: Instance)
		if not instance:IsA("GuiButton") then
			return
		end
		if skip and skip(instance) then
			return
		end
		ButtonMotion.bind(instance, opts)
	end

	for _, descendant in root:GetDescendants() do
		consider(descendant)
	end

	-- Al reparentar un subárbol entero, DescendantAdded se dispara para cada
	-- pieza, así que una tarjeta clonada queda cubierta con sus botones dentro.
	local connection = root.DescendantAdded:Connect(consider)

	return function()
		connection:Disconnect()
	end
end

return ButtonMotion
