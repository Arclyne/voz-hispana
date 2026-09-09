--[[
	Carousel — las flechas de una fila de tarjetas.

		Carousel.attach(scrollingFrame)

	Busca `Left` y `Right` como hermanos del ScrollingFrame y se encarga de todo:
	el desplazamiento, la animacion y el estado apagado cuando la fila no da mas de
	si. Antes esto era el script `Move`, repetido cinco veces con la aritmetica del
	layout copiada a mano.

	El aspecto NO se toca aqui: color, tamano, posicion y el chevron estan puestos
	en el Studio, para que la fila se vea en el editor igual que en el juego y se
	pueda retocar sin abrir un script. Este modulo lee ese estado de reposo al
	enlazar y anima a partir de el.

	La animacion tiene tres piezas y cada una dice algo distinto:

	  • El hover llena el circulo del azul de la tablet y pone el chevron en
	    blanco: el boton se enciende.
	  • El hover ademas lo desplaza un par de pixeles HACIA DONDE apunta, no hacia
	    arriba ni hacia fuera de si mismo. Es la pista de que va a mover la fila
	    en esa direccion.
	  • Al pulsar, la flecha sale disparada en su direccion y vuelve con un
	    resorte, a la vez que el carrusel arranca. La flecha va delante y las
	    tarjetas la siguen.

	Y cuando por ese lado ya no queda fila, la flecha se apaga en vez de
	desaparecer: sigue diciendo donde termina el carrusel.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kinetic = require(ReplicatedStorage:WaitForChild("Kinetic"))
local ButtonMotion = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ButtonMotion"))

local Carousel = {}

-- El azul del boton "+" de Tus Casas: la flecha encendida es el mismo acento que
-- el resto de acciones de la tablet.
local FACE_HOVER = Color3.fromRGB(31, 162, 245)
local GLYPH_HOVER = Color3.fromRGB(255, 255, 255)

local HOVER_SCALE = 1.10
local PRESS_SCALE = 0.90
-- Pixeles que se corre la flecha al pasar por encima, en su propia direccion.
local HOVER_NUDGE = 3
-- Y los que sale disparada al pulsarla.
local KICK = 12

-- Lo que se apaga una flecha que ya no tiene fila por delante.
local OFF_TRANSPARENCY = 0.55

local SCROLL_SPRING = { tension = 190, friction = 26 }
local KICK_OUT = { tension = 900, friction = 22 }
local KICK_BACK = { tension = 260, friction = 18 }

-- Holgura para no encender una flecha por medio pixel de canvas sobrante.
local EDGE_SLACK = 2

local attached = setmetatable({}, { __mode = "k" })

--== Medidas ================================================================--

--[[
	El paso de un click es la distancia entre dos tarjetas consecutivas, medida
	sobre el layout ya resuelto. Reproducir la aritmetica del UIListLayout — que es
	lo que hacia `Move` — da de mas desde que el ScrollingFrame lleva su margen de
	recorte: el AbsoluteSize incluye ese margen y la caja de contenido no.
]]
local function stepOf(scroll: ScrollingFrame): number
	local items = {}
	for _, child in scroll:GetChildren() do
		if child:IsA("GuiObject") then
			table.insert(items, child)
		end
	end

	if #items == 0 then
		return 0
	end

	if #items >= 2 then
		table.sort(items, function(a, b)
			return a.AbsolutePosition.X < b.AbsolutePosition.X
		end)

		local gap = items[2].AbsolutePosition.X - items[1].AbsolutePosition.X
		if gap > 0 then
			return gap
		end
	end

	-- Con una sola tarjeta no hay distancia que medir: su ancho mas el padding
	-- declarado, que es lo que habria si hubiera una segunda.
	local layout = scroll:FindFirstChildOfClass("UIListLayout")
	local padding = if layout
		then scroll.AbsoluteSize.X * layout.Padding.Scale + layout.Padding.Offset
		else 0

	return items[1].AbsoluteSize.X + padding
end

local function maxScrollOf(scroll: ScrollingFrame): number
	local window = scroll.AbsoluteWindowSize.X
	if window <= 0 then
		window = scroll.AbsoluteSize.X
	end
	return math.max(0, scroll.AbsoluteCanvasSize.X - window)
end

--== Una flecha =============================================================--

local function glyphOf(button: GuiButton): ImageLabel?
	local glyph = button:FindFirstChild("Glyph")
	return if glyph and glyph:IsA("ImageLabel") then glyph else nil
end

local function ensureScale(target: GuiObject): UIScale
	return target:FindFirstChildOfClass("UIScale") or (function()
		local scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = target
		return scale
	end)()
end

local function bindArrow(button: GuiButton, direction: number, scrollTo)
	-- Esta flecha tiene animacion propia, asi que el barrido generico de la
	-- tablet se aparta. El unbind cubre el caso de que se haya adelantado.
	button:SetAttribute(ButtonMotion.SKIP_ATTRIBUTE, true)
	ButtonMotion.unbind(button)
	button.AutoButtonColor = false

	-- El estado de reposo se lee del Studio, no se impone desde aqui.
	local restPosition = button.Position
	local restFace = button.BackgroundColor3
	local restFaceTransparency = button.BackgroundTransparency

	local glyph = glyphOf(button)
	local restGlyph = if glyph then glyph.ImageColor3 else Color3.new(0, 0, 0)

	local stroke = button:FindFirstChildOfClass("UIStroke")
	local restStrokeTransparency = if stroke then stroke.Transparency else 0

	local scale = ensureScale(button)

	local body = Kinetic.animate(scale, {
		from = { Scale = 1 },
		config = Kinetic.config.wobbly,
	})
	local face = Kinetic.animate(button, {
		from = { BackgroundColor3 = restFace },
		config = Kinetic.config.stiff,
	})

	-- La flecha es una imagen tenida, no un color de fondo, asi que va por un
	-- controller propio en vez de por Kinetic.animate sobre una propiedad.
	local ink = Kinetic.controller({ from = { tint = 0 } })
	ink:onChange(function(values)
		if glyph then
			glyph.ImageColor3 = restGlyph:Lerp(GLYPH_HOVER, values.tint)
		end
	end)

	-- El empuje va aparte del resto: el resorte del click no debe cortarse
	-- porque el raton entre o salga a mitad de camino.
	local push = Kinetic.controller({ from = { offset = 0 } })
	push:onChange(function(values)
		button.Position = UDim2.new(
			restPosition.X.Scale, restPosition.X.Offset + values.offset * direction,
			restPosition.Y.Scale, restPosition.Y.Offset
		)
	end)

	-- La opacidad de apagado se escribe a pelo y no por resorte: cambia una vez
	-- por final de carrera, no en cada frame.
	local function paintEnabled(enabled: boolean)
		local fade = if enabled then 0 else OFF_TRANSPARENCY
		button.BackgroundTransparency = restFaceTransparency + (1 - restFaceTransparency) * fade
		if glyph then
			glyph.ImageTransparency = fade
		end
		if stroke then
			stroke.Transparency = restStrokeTransparency + (1 - restStrokeTransparency) * fade
		end
	end

	local enabled = true
	local hovered = false
	local pressed = false

	local function apply()
		local lit = enabled and hovered

		body:start({
			Scale = if enabled and pressed then PRESS_SCALE elseif lit then HOVER_SCALE else 1,
		})
		face:start({ BackgroundColor3 = if lit then FACE_HOVER else restFace })
		ink:start({ tint = if lit then 1 else 0 })
		push:start({ offset = if lit then HOVER_NUDGE else 0 })
	end

	button.MouseEnter:Connect(function()
		hovered = true
		apply()
	end)
	button.MouseLeave:Connect(function()
		hovered = false
		pressed = false
		apply()
	end)
	button.MouseButton1Down:Connect(function()
		pressed = true
		apply()
	end)
	button.MouseButton1Up:Connect(function()
		pressed = false
		apply()
	end)
	-- Mando: sin raton no hay MouseEnter, pero si foco de seleccion.
	button.SelectionGained:Connect(function()
		hovered = true
		apply()
	end)
	button.SelectionLost:Connect(function()
		hovered = false
		pressed = false
		apply()
	end)

	button.Activated:Connect(function()
		if not enabled then
			-- Un empujoncito contra el tope y nada mas: la flecha apagada responde,
			-- pero dejando claro que por ahi no se sigue.
			push:start({
				to = function(nextStep)
					nextStep({ offset = -3, config = KICK_OUT })
					nextStep({ offset = 0, config = KICK_BACK })
				end,
			})
			return
		end

		push:start({
			to = function(nextStep)
				nextStep({ offset = KICK, config = KICK_OUT })
				nextStep({ offset = if hovered then HOVER_NUDGE else 0, config = KICK_BACK })
			end,
		})

		scrollTo(direction)
	end)

	return {
		setEnabled = function(value: boolean)
			if enabled == value then
				return
			end
			enabled = value
			paintEnabled(value)
			apply()
		end,
	}
end

--== Enganche ===============================================================--

--[=[
	Engancha las flechas `Left` y `Right` que acompanan a una fila. Idempotente.
]=]
function Carousel.attach(scroll: ScrollingFrame)
	if attached[scroll] then
		return
	end
	attached[scroll] = true

	local section = scroll.Parent
	local left = section and section:FindFirstChild("Left")
	local right = section and section:FindFirstChild("Right")
	if not (left and right and left:IsA("GuiButton") and right:IsA("GuiButton")) then
		return
	end

	local canvas = Kinetic.animate(scroll, {
		from = { CanvasPosition = scroll.CanvasPosition },
		config = SCROLL_SPRING,
	})

	-- El destino se lleva aparte del CanvasPosition real: dos clicks seguidos
	-- tienen que sumar dos pasos, y leer la posicion a media animacion daria uno
	-- y pico.
	local target = scroll.CanvasPosition.X

	local function scrollTo(direction: number)
		local step = stepOf(scroll)
		if step <= 0 then
			return
		end

		target = math.clamp(target + step * direction, 0, maxScrollOf(scroll))

		--[[
			El resorte guarda su propia idea de CanvasPosition y no relee la propiedad.
			Si la fila se movio por fuera — la rueda del raton, un arrastre, el
			desplazamiento automatico de ShopHighlight — arrancar sin `from` daria un
			salto de vuelta a la posicion vieja antes de moverse. Solo se pasa cuando
			hay desfase, para que dos clicks seguidos sigan encadenando sin cortar la
			velocidad.
		]]
		local actual = scroll.CanvasPosition
		local known = canvas:get().CanvasPosition

		canvas:start({
			from = if known ~= actual then { CanvasPosition = actual } else nil,
			CanvasPosition = Vector2.new(target, 0),
			config = SCROLL_SPRING,
		})
	end

	local leftArrow = bindArrow(left, -1, scrollTo)
	local rightArrow = bindArrow(right, 1, scrollTo)

	local function refresh()
		local limit = maxScrollOf(scroll)
		local at

		if canvas:isIdle() then
			-- Nadie esta animando: la posicion real manda, que puede venir de una
			-- rueda de raton o de un arrastre y no de las flechas.
			target = scroll.CanvasPosition.X
			at = target
		else
			-- En vuelo manda el destino: mirar la posicion real apagaria la flecha a
			-- mitad del ultimo desplazamiento para volver a encenderla enseguida.
			at = target
		end

		leftArrow.setEnabled(at > EDGE_SLACK)
		rightArrow.setEnabled(at < limit - EDGE_SLACK)
	end

	scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(refresh)
	scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(refresh)
	scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	-- Las tarjetas llegan del servidor un rato despues que el script.
	scroll.ChildAdded:Connect(refresh)
	scroll.ChildRemoved:Connect(refresh)

	-- El primer refresh espera a que el layout tenga medidas: recien clonada la
	-- interfaz, el canvas mide cero y las dos flechas saldrian apagadas.
	task.defer(refresh)
end

return Carousel
