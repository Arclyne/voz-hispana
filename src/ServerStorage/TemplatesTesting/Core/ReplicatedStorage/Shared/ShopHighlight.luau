local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Kinetic = require(ReplicatedStorage:WaitForChild("Kinetic"))
local CardSlots = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CardSlots"))

local CARD_WAIT_SECONDS = 5
local LAYOUT_WAIT_SECONDS = 3
-- Tope corto: es una red de seguridad para el layout, no una espera de carga.
-- Si algo del contenido cambiara de alto cada frame, el desplazamiento no puede
-- quedarse plantado tres segundos esperando a que pare.
local CANVAS_SETTLE_SECONDS = 0.5
local DEFAULT_HIGHLIGHT_SECONDS = 2.2
-- Dorado, no amarillo limon: con el contorno como unica senal, el tono importa.
local HIGHLIGHT_COLOR = Color3.fromRGB(255, 190, 60)
local HIGHLIGHT_THICKNESS = 5
-- Altura de cada brinco, en alturas de tarjeta. Decrecientes, como el rebote
-- del dock: el primero se ve, los siguientes solo lo rematan.
local HOP_HEIGHTS = { 0.17, 0.09, 0.045 }
local HOP_RISE_SECONDS = 0.17
local HOP_FALL_SECONDS = 0.21
local SCROLL_SPRING = { tension = 170, friction = 26 }
local STROKE_IN_SPRING = { tension = 420, friction = 18 }
local STROKE_OUT_SPRING = { tension = 180, friction = 30 }

local ShopHighlight = {}

local scrollControllers = setmetatable({}, { __mode = "k" })
local strokeControllers = setmetatable({}, { __mode = "k" })
local hopControllers = setmetatable({}, { __mode = "k" })
-- La posicion de reposo dentro del slot, guardada la primera vez: leerla al
-- empezar un brinco la tomaria a media caida si el anterior sigue en vuelo.
local restPositions = setmetatable({}, { __mode = "k" })
-- Cada resaltado se lleva su ficha; la limpieza diferida solo actua si sigue
-- siendo la suya, para que un resaltado nuevo no lo apague el anterior.
local tokens = setmetatable({}, { __mode = "k" })

--[[
	Espera a que existan las tarjetas de todos los ids. Devuelve las que haya
	encontrado al agotarse el plazo, no una lista vacia: si una oferta no tiene
	tarjeta (filtrada, ya comprada, ...) el resto se resalta igual.
]]
local function waitForCards(scrollingFrame, itemIds)
	local deadline = os.clock() + CARD_WAIT_SECONDS
	local found = {}

	repeat
		table.clear(found)
		local missing = false

		for _, itemId in itemIds do
			-- Por nombre y no como hija directa: las tarjetas viven dentro de un
			-- slot desde que el layout ordena contenedores.
			local card = CardSlots.find(scrollingFrame, itemId)
			if card and card:IsA("GuiObject") and card.Visible then
				table.insert(found, card)
			else
				missing = true
			end
		end

		if not missing then
			return found
		end
		task.wait(0.1)
	until os.clock() > deadline

	return found
end

local function waitForLayout(scrollingFrame)
	local deadline = os.clock() + LAYOUT_WAIT_SECONDS

	while scrollingFrame.AbsoluteSize.X <= 0 do
		if os.clock() > deadline then
			return false
		end
		task.wait()
	end

	return true
end

--[[
	Espera a que el canvas deje de crecer: dos frames seguidos con la misma altura.
	Con la tienda recien mostrada las tarjetas todavia estan llegando y
	AbsoluteCanvasSize sigue subiendo; medir ahi da un maxScroll corto y el
	desplazamiento se queda a medias.
]]
local function waitForCanvas(scrollingFrame)
	local deadline = os.clock() + CANVAS_SETTLE_SECONDS
	local previous = -1

	repeat
		local height = scrollingFrame.AbsoluteCanvasSize.Y
		if height > 0 and height == previous then
			return
		end
		previous = height
		task.wait()
	until os.clock() > deadline
end

--[[
	Lleva el canvas a `target`, arrancando SIEMPRE desde la posicion real del frame.

	El controller guarda su propia idea de CanvasPosition y no vuelve a leer la
	propiedad despues de crearse. En cuanto algo la mueve por fuera -- la rueda del
	raton, un arrastre, las flechas del carrusel (que animan el mismo frame con su
	propio resorte) o el tween del modo regalo -- el resorte se queda creyendo que
	sigue en el destino anterior. Pedirle ese mismo destino otra vez no movia nada:
	por eso el desplazamiento automatico solo funcionaba la primera vez.

	El `from` solo se pasa cuando hay desfase, para no matar la velocidad de una
	animacion en vuelo (dos clicks seguidos siguen encadenando sin salto).
]]
local function animateCanvas(scrollingFrame, target)
	local controller = scrollControllers[scrollingFrame]
	if not controller then
		controller = Kinetic.animate(scrollingFrame, { CanvasPosition = scrollingFrame.CanvasPosition })
		scrollControllers[scrollingFrame] = controller
	end

	local actual = scrollingFrame.CanvasPosition
	local known = controller:get().CanvasPosition

	controller:start({
		from = if known ~= actual then { CanvasPosition = actual } else nil,
		CanvasPosition = target,
		config = SCROLL_SPRING,
	})
end

-- Centra el grupo entero, no la primera tarjeta: con una sola el resultado es
-- exactamente el de antes, y con varias quedan encuadradas juntas.
-- Desplaza el scroll vertical principal de la tienda hasta el encabezado de
-- una categoría. La posición absoluta ya incluye el CanvasPosition actual; se
-- lo sumamos de vuelta para obtener el offset estable dentro del contenido.
function ShopHighlight.scrollToSection(scrollingFrame, anchor)
	if not (scrollingFrame and scrollingFrame:IsA("ScrollingFrame")) then
		return
	end
	if not (anchor and anchor:IsA("GuiObject")) then
		return
	end

	task.spawn(function()
		local deadline = os.clock() + LAYOUT_WAIT_SECONDS
		while (scrollingFrame.AbsoluteSize.Y <= 0 or anchor.AbsoluteSize.Y <= 0) and os.clock() < deadline do
			task.wait()
		end
		if scrollingFrame.AbsoluteSize.Y <= 0 or anchor.AbsoluteSize.Y <= 0 then
			return
		end

		-- Tras el cambio Home -> Shop el layout sigue asentandose: esperamos a que
		-- UIListLayout y AbsoluteCanvasSize reflejen la seccion ya visible y con todo
		-- su contenido, no solo un frame.
		waitForCanvas(scrollingFrame)

		local targetY = scrollingFrame.CanvasPosition.Y
			+ (anchor.AbsolutePosition.Y - scrollingFrame.AbsolutePosition.Y)
		local windowHeight = scrollingFrame.AbsoluteWindowSize.Y
		if windowHeight <= 0 then
			windowHeight = scrollingFrame.AbsoluteSize.Y
		end
		local maxScroll = math.max(0, scrollingFrame.AbsoluteCanvasSize.Y - windowHeight)
		targetY = math.clamp(targetY, 0, maxScroll)

		animateCanvas(scrollingFrame, Vector2.new(scrollingFrame.CanvasPosition.X, targetY))
	end)
end

local function scrollIntoView(scrollingFrame, cards)
	local canvasOrigin = scrollingFrame.CanvasPosition.X - scrollingFrame.AbsolutePosition.X
	local left, right

	for _, card in cards do
		local cardLeft = card.AbsolutePosition.X + canvasOrigin
		local cardRight = cardLeft + card.AbsoluteSize.X
		left = if left then math.min(left, cardLeft) else cardLeft
		right = if right then math.max(right, cardRight) else cardRight
	end

	if not left or not right then
		return
	end

	local centered = (left + right) / 2 - scrollingFrame.AbsoluteSize.X / 2
	local maxScroll = math.max(0, scrollingFrame.AbsoluteCanvasSize.X - scrollingFrame.AbsoluteSize.X)

	animateCanvas(scrollingFrame, Vector2.new(math.clamp(centered, 0, maxScroll), 0))
end

--== Brinco estilo dock =====================================================--
--[[
	La tarjeta vive dentro de un slot (ver Shared.CardSlots): el UIListLayout
	ordena el slot y la Position de la tarjeta es libre dentro suyo. El brinco es
	por tanto lo que aparenta ser — subir la tarjeta y dejarla caer — y no el apano
	de UIPadding en negativo con el fondo duplicado que hacia falta cuando la
	tarjeta colgaba directamente del layout y no habia forma de moverla.

	El contorno dorado va en un aro aparte y no en la propia tarjeta porque muchas
	ya tienen su UIStroke — el del hover, que ButtonMotion engorda — y una GuiObject
	solo admite uno.
]]

local function ensureRing(card)
	local ring = card:FindFirstChild("FocusRing")
	if ring then
		return ring
	end

	ring = Instance.new("Frame")
	ring.Name = "FocusRing"
	ring.Size = UDim2.fromScale(1, 1)
	ring.Position = UDim2.fromScale(0, 0)
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	-- Sin capturar el raton: el hover de la tarjeta tiene que seguir llegando con
	-- el aro puesto.
	ring.Active = false

	-- El aro sigue la silueta de la tarjeta, redondeo incluido.
	local corner = card:FindFirstChildOfClass("UICorner")
	if corner then
		corner:Clone().Parent = ring
	end

	-- Por encima de todo lo que dibuja la tarjeta: con ZIndexBehavior.Global el
	-- ZIndex es lo unico que decide quien tapa a quien.
	local top = card.ZIndex
	for _, child in card:GetDescendants() do
		if child:IsA("GuiObject") then
			top = math.max(top, child.ZIndex)
		end
	end
	ring.ZIndex = top + 1

	local stroke = Instance.new("UIStroke")
	stroke.Name = "FocusStroke"
	stroke.Color = HIGHLIGHT_COLOR
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = 0
	stroke.Parent = ring

	ring.Parent = card
	return ring
end

local function controllerFor(registry, instance, props)
	local controller = registry[instance]
	if not controller then
		controller = Kinetic.animate(instance, props)
		registry[instance] = controller
	end
	return controller
end

local function hopControllerFor(card)
	local controller = hopControllers[card]
	if controller then
		return controller
	end

	local rest = restPositions[card]
	if not rest then
		rest = card.Position
		restPositions[card] = rest
	end

	controller = Kinetic.controller({ from = { jump = 0 } })
	controller:onChange(function(values)
		-- `jump` va en alturas de tarjeta, que dentro del slot es exactamente la
		-- escala vertical: el slot mide lo que media la tarjeta.
		card.Position = UDim2.new(
			rest.X.Scale, rest.X.Offset,
			rest.Y.Scale - values.jump, rest.Y.Offset
		)
	end)
	hopControllers[card] = controller
	return controller
end

local function bounce(card)
	local controller = hopControllerFor(card)

	--[[
		La forma de funcion y no una lista de pasos porque cada tramo necesita su
		propia curva: subida frenando y caida acelerando, que es lo que lo hace
		leerse como gravedad y no como un vaiven. Dentro de una lista, `config`
		seria un destino mas y Kinetic intentaria animarlo.
	]]
	controller:start({
		to = function(nextStep)
			for _, height in HOP_HEIGHTS do
				nextStep({
					jump = height,
					config = { duration = HOP_RISE_SECONDS, easing = Kinetic.easings.easeOutQuad },
				})
				nextStep({
					jump = 0,
					config = { duration = HOP_FALL_SECONDS, easing = Kinetic.easings.easeInQuad },
				})
			end
		end,
	})
end

local function pulse(card, seconds)
	-- Si la fila no estaba enganchada, se envuelve aqui: sin slot la Position de
	-- la tarjeta es del layout y el brinco no llegaria a verse.
	CardSlots.ensure(card)

	-- El aro antes del lift: `lift` sube todo el subarbol de golpe y lo que nazca
	-- despues se quedaria una capa por debajo.
	local ring = ensureRing(card)
	local stroke = ring:FindFirstChild("FocusStroke")

	-- Una tarjeta que brinca por encima de sus vecinas y de las flechas del
	-- carrusel, que es lo unico que la tapaba mientras subia.
	CardSlots.lift(card, "highlight")

	local strokeController = controllerFor(strokeControllers, stroke, { Thickness = 0 })

	bounce(card)
	strokeController:start({ Thickness = HIGHLIGHT_THICKNESS, config = STROKE_IN_SPRING })

	local token = (tokens[card] or 0) + 1
	tokens[card] = token

	task.delay(seconds, function()
		if tokens[card] ~= token or not stroke.Parent then
			return
		end

		strokeController:start({ Thickness = 0, config = STROKE_OUT_SPRING }):andThen(function(result)
			-- La tarjeta vuelve a su capa cuando el contorno ya no se ve; bajarla
			-- antes la meteria por detras de sus vecinas de golpe. Si otro resaltado
			-- tomo el relevo mientras se apagaba, la capa es suya y no se toca.
			if not result.finished or tokens[card] ~= token then
				return
			end
			CardSlots.drop(card, "highlight")
		end)
	end)
end

--[[
	Resalta uno o varios articulos. `itemIds` acepta un id suelto o una lista de
	ids: el banner de ofertas manda todas las suyas de golpe cuando se pulsa el
	fondo o "Ver tienda", y una sola cuando se pulsa una tarjeta concreta.
]]
function ShopHighlight.focus(scrollingFrame, itemIds, seconds)
	local ids = if type(itemIds) == "table" then itemIds else { itemIds }
	if #ids == 0 then
		return
	end

	task.spawn(function()
		local cards = waitForCards(scrollingFrame, ids)
		if #cards == 0 or not waitForLayout(scrollingFrame) then
			return
		end

		-- Las posiciones absolutas quedan del frame anterior hasta que el layout se
		-- recalcula, y con la seccion recien mostrada eso da un scroll a destiempo.
		task.wait()

		scrollIntoView(scrollingFrame, cards)
		for _, card in cards do
			pulse(card, seconds or DEFAULT_HIGHLIGHT_SECONDS)
		end
	end)
end

return ShopHighlight
