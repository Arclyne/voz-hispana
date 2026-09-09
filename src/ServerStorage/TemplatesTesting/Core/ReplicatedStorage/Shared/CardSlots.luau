--[[
	CardSlots — contenedores para las filas de tarjetas de la tablet.

	El problema son dos, y los dos vienen del mismo sitio: las tarjetas cuelgan
	directamente de un ScrollingFrame con UIListLayout.

	  • El layout manda sobre la Position de cada tarjeta y la reescribe aunque se
	    insista en cada frame, asi que una tarjeta no puede moverse por su cuenta.
	  • El ScrollingFrame recorta, asi que tampoco puede crecer: el hover se corta
	    contra el borde de la banda.

	Entre el layout y la tarjeta se mete un slot. El slot es lo que el UIListLayout
	ordena — mismo tamano, misma proporcion, mismo LayoutOrder, misma visibilidad —
	y la tarjeta vive dentro suyo al 100%, con Position, UIScale y ZIndex libres.
	Para todo lo demas la tarjeta sigue siendo la misma instancia con el mismo
	nombre; lo unico que cambia es que ya no es hija directa del ScrollingFrame,
	por eso existe `cards()`, que devuelve las tarjetas de verdad esten envueltas o
	no.

	Ademas el ScrollingFrame se agranda por los cuatro lados y se compensa con un
	UIPadding del mismo margen: la caja de contenido queda exactamente donde
	estaba — nada se mueve ni cambia de tamano — pero la frontera de recorte pasa a
	estar fuera, y lo que se salga durante una animacion se ve. El margen vertical
	es generoso porque ahi no estorba a nadie; el horizontal es corto a proposito,
	porque es el unico que tiene precio: una tarjeta que sale de la banda por un
	lado asoma ese margen antes de que la recorten.

		CardSlots.attach(scrollingFrame)   -- las de ahora y las que vengan
		CardSlots.cards(holder)            -- las tarjetas, con slot o sin el
		CardSlots.find(holder, nombre)
		CardSlots.destroy(tarjeta)         -- se lleva el slot por delante
		CardSlots.lift(tarjeta, motivo)    -- por encima de todo
		CardSlots.drop(tarjeta, motivo)    -- y de vuelta

	El lift existe porque WorldSystemUI usa ZIndexBehavior.Global: el ZIndex es
	absoluto en todo el ScreenGui y no relativo al padre, asi que subir solo la
	tarjeta dejaria a sus hijos por debajo. Se sube el subarbol entero con el mismo
	delta, que preserva el orden relativo de dentro. Y va por motivos con
	contador: el hover y el brinco de una oferta pueden solaparse, y el primero en
	soltar no debe bajar a la tarjeta mientras el otro sigue.
]]

local CardSlots = {}

-- Todos los slots se llaman igual: quien busque una tarjeta por nombre pasa por
-- `find`, y quien recorra la fila por `cards`.
local SLOT_NAME = "CardSlot"
-- Lo pone el slot en la tarjeta. Sirve de marca para no envolver dos veces y
-- para que otros modulos sepan que la Position de esa tarjeta es suya.
local CARD_ATTRIBUTE = "InCardSlot"
-- Puesto a mano en el Studio, deja un hijo fuera del envoltorio.
local SKIP_ATTRIBUTE = "NoCardSlot"

CardSlots.SLOT_NAME = SLOT_NAME
CardSlots.CARD_ATTRIBUTE = CARD_ATTRIBUTE
CardSlots.SKIP_ATTRIBUTE = SKIP_ATTRIBUTE

-- Cuanto sube el subarbol de una tarjeta al levantarla. El numero cae a
-- proposito en medio de las capas que ya hay: las filas y sus flechas viven en
-- ZIndex 1 y 2, asi que con 20 la tarjeta pasa por encima de todo lo que la
-- rodea; y la cartera, la NavBar y las vistas previas de la tienda estan en 100,
-- 101 y 201, asi que una tarjeta levantada nunca tapa lo que debe quedar por
-- encima de ella.
local LIFT = 20

-- Margen de recorte extra, en fracciones del alto base de la banda. El alto de
-- la banda y no el ancho: el ancho son varias tarjetas y daria un margen
-- desproporcionado.
local MARGIN_Y = 0.24
local MARGIN_X = 0.05

-- Debiles por clave: ni un ScrollingFrame ni una tarjeta destruidos deben seguir
-- vivos por estar apuntados aqui.
local attached = setmetatable({}, { __mode = "k" })
local lifts = setmetatable({}, { __mode = "k" })

local function isSlot(instance: Instance?): boolean
	return instance ~= nil and instance:IsA("Frame") and instance.Name == SLOT_NAME
end

CardSlots.isSlot = isSlot

--== Envoltorio =============================================================--

local function shouldWrap(child: Instance): boolean
	if not child:IsA("GuiObject") then
		return false
	end
	if isSlot(child) then
		return false
	end
	-- Ojo con la tentacion de saltarse los hijos llamados "Template": en esta
	-- interfaz ese nombre es contenido, no plantilla. Las tarjetas de Amigos y de
	-- Mas Jugados salen de `template:Clone()` sin renombrar y llegan a la fila
	-- llamandose Template, y en Mas Jugados y en Casas hay ademas varias puestas a
	-- mano en el Studio. Las plantillas de verdad cuelgan del script que las
	-- clona, nunca del ScrollingFrame, asi que este barrido no las ve.
	if child:GetAttribute(SKIP_ATTRIBUTE) then
		return false
	end
	if child:GetAttribute(CARD_ATTRIBUTE) then
		return false
	end
	return true
end

local function wrap(card: GuiObject): Frame?
	local holder = card.Parent
	if isSlot(holder) then
		return holder :: Frame
	end
	if not (holder and holder:IsA("GuiObject")) then
		return nil
	end

	local slot = Instance.new("Frame")
	slot.Name = SLOT_NAME
	slot.BackgroundTransparency = 1
	slot.BorderSizePixel = 0
	-- Lo contrario de lo que hace el ScrollingFrame: el slot es exactamente el
	-- agujero por el que la tarjeta puede salirse.
	slot.ClipsDescendants = false
	slot.Size = card.Size
	slot.Position = card.Position
	slot.AnchorPoint = card.AnchorPoint
	slot.LayoutOrder = card.LayoutOrder
	slot.Visible = card.Visible
	slot.ZIndex = card.ZIndex

	-- La proporcion la mide el layout sobre el slot, asi que tiene que estar ahi.
	-- Se copia en vez de moverse: dentro de un slot ya proporcionado, la de la
	-- tarjeta queda como identidad y no molesta.
	for _, child in card:GetChildren() do
		if child:IsA("UIAspectRatioConstraint") then
			child:Clone().Parent = slot
		end
	end

	slot.Parent = holder

	card:SetAttribute(CARD_ATTRIBUTE, true)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromScale(1, 1)

	--[[
		Si el Parent de la tarjeta esta bloqueado — porque quien llamo esta a su vez
		dentro de una asignacion de Parent, cosa que pasa con SignalBehavior.Immediate
		— el movimiento no se hace. `attach` ya aplaza el envoltorio para que no
		ocurra, pero si alguna vez ocurre, mas vale deshacer el slot que dejarlo vacio
		ocupando un hueco en la fila: el UIListLayout lo ordena igual y se ve como un
		agujero entre tarjetas.
	]]
	local moved = pcall(function()
		card.Parent = slot
	end)

	if not moved or card.Parent ~= slot then
		card:SetAttribute(CARD_ATTRIBUTE, nil)
		card.AnchorPoint = slot.AnchorPoint
		card.Position = slot.Position
		card.Size = slot.Size
		slot:Destroy()
		return nil
	end

	-- El controlador sigue escribiendo sobre la tarjeta sin saber del slot: los
	-- de la tienda ponen el LayoutOrder DESPUES de emparentarla, para que las
	-- ofertas salgan primero.
	card:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
		slot.LayoutOrder = card.LayoutOrder
	end)
	card:GetPropertyChangedSignal("Visible"):Connect(function()
		slot.Visible = card.Visible
	end)

	--[[
		La tarjeta se fue del arbol — destruida o reparentada — y el slot vacio sobra.

		Aplazado a proposito, y por AncestryChanged y no por Destroying: con
		SignalBehavior.Immediate esa senal corre DENTRO del Destroy de la tarjeta, y
		destruir el slot desde ahi vuelve a entrar en la tarjeta a medio destruir, que
		es el "The Parent property of CardSlot.X is locked" que salia en las places de
		casas. Un paso mas tarde ya no hay nada a medias.
	]]
	card.AncestryChanged:Connect(function(_, parent)
		if parent then
			return
		end

		task.defer(function()
			if not slot.Parent then
				return
			end
			for _, child in slot:GetChildren() do
				if child:IsA("GuiObject") then
					return
				end
			end
			slot:Destroy()
		end)
	end)

	-- El hover lo anima ButtonMotion con un UIScale; lo unico que falta es que la
	-- tarjeta que crece pase por encima de sus vecinas en vez de por debajo.
	if card:IsA("GuiButton") then
		card.MouseEnter:Connect(function()
			CardSlots.lift(card, "hover")
		end)
		card.MouseLeave:Connect(function()
			CardSlots.drop(card, "hover")
		end)
		card.SelectionGained:Connect(function()
			CardSlots.lift(card, "hover")
		end)
		card.SelectionLost:Connect(function()
			CardSlots.drop(card, "hover")
		end)
	end

	return slot
end

--[=[
	Envuelve una tarjeta suelta. Idempotente: si ya tiene slot devuelve el suyo.
]=]
function CardSlots.ensure(card: GuiObject): Frame?
	return wrap(card)
end

--[=[
	El slot de una tarjeta, o nil si no esta envuelta.
]=]
function CardSlots.slotOf(card: GuiObject): Frame?
	local parent = card.Parent
	return if isSlot(parent) then parent :: Frame else nil
end

--== Recorrido ==============================================================--

--[=[
	Las tarjetas de una fila, envueltas o no, en el orden en que estan los hijos.
	Sustituye a `holder:GetChildren()` en cualquier bucle que espere encontrar las
	tarjetas colgando directamente.
]=]
function CardSlots.cards(holder: Instance): { GuiObject }
	local result = {}

	for _, child in holder:GetChildren() do
		if isSlot(child) then
			for _, inner in child:GetChildren() do
				if inner:IsA("GuiObject") then
					table.insert(result, inner)
					break
				end
			end
		elseif child:IsA("GuiObject") then
			table.insert(result, child)
		end
	end

	return result
end

--[=[
	Busca una tarjeta por nombre. Mira primero como hija directa, que es donde
	estaba antes de los slots y donde siguen las filas que no se han enganchado.
]=]
function CardSlots.find(holder: Instance, name: string): GuiObject?
	local direct = holder:FindFirstChild(name)
	if direct and direct:IsA("GuiObject") and not isSlot(direct) then
		return direct
	end

	for _, card in CardSlots.cards(holder) do
		if card.Name == name then
			return card
		end
	end

	return nil
end

--[=[
	Destruye una tarjeta y su slot.
]=]
function CardSlots.destroy(card: GuiObject)
	local slot = card.Parent

	if isSlot(slot) then
		-- Se destruye el slot, que se lleva la tarjeta dentro. Al reves — primero la
		-- tarjeta y luego el slot — el Destroy del slot vuelve a entrar en la tarjeta
		-- que ya se estaba destruyendo, y con SignalBehavior.Immediate eso es un
		-- error en consola por cada tarjeta que se limpia.
		(slot :: Frame):Destroy()
	else
		card:Destroy()
	end
end

--== Capa ===================================================================--

local function shift(card: GuiObject, delta: number)
	local slot = card.Parent
	if isSlot(slot) then
		(slot :: Frame).ZIndex += delta
	end

	card.ZIndex += delta
	for _, descendant in card:GetDescendants() do
		if descendant:IsA("GuiObject") then
			descendant.ZIndex += delta
		end
	end
end

--[=[
	Sube la tarjeta y todo lo que dibuja por encima del resto de la tablet.
	`reason` distingue a quien la levanta: el hover y el brinco de una oferta se
	solapan, y baja de verdad cuando la sueltan todos.
]=]
function CardSlots.lift(card: GuiObject, reason: string?)
	local key = reason or "default"
	local reasons = lifts[card]

	if not reasons then
		reasons = {}
		lifts[card] = reasons
	end
	if reasons[key] then
		return
	end

	local wasDown = next(reasons) == nil
	reasons[key] = true

	if wasDown then
		shift(card, LIFT)
	end
end

--[=[
	Deshace un `lift` del mismo motivo.
]=]
function CardSlots.drop(card: GuiObject, reason: string?)
	local key = reason or "default"
	local reasons = lifts[card]

	if not reasons or not reasons[key] then
		return
	end

	reasons[key] = nil
	if next(reasons) == nil then
		shift(card, -LIFT)
	end
end

--== Margen de recorte ======================================================--

--[[
	Agranda el ScrollingFrame y le devuelve el hueco con un UIPadding igual. La
	caja de contenido — la que ven el UIListLayout y los tamanos en escala de las
	tarjetas — queda identica a la de antes, asi que ni el tamano ni la posicion
	de nada cambian; lo unico que se mueve es la frontera de recorte, que sale
	fuera de la banda visible.

	El margen se recalcula al cambiar el tamano del contenedor porque va en
	pixeles: en escala habria que resolver una ecuacion (el margen entra en el
	tamano sobre el que se mide la escala) y en offset no.
]]
local function expandClip(scroll: ScrollingFrame, marginX: number, marginY: number)
	local parent = scroll.Parent
	if not (parent and parent:IsA("GuiObject")) then
		return
	end

	local baseSize = scroll.Size
	local basePosition = scroll.Position

	local padding = scroll:FindFirstChild("SlotMargin")
	if not padding then
		padding = Instance.new("UIPadding")
		padding.Name = "SlotMargin"
		padding.Parent = scroll
	end

	local function apply()
		local baseHeight = parent.AbsoluteSize.Y * baseSize.Y.Scale + baseSize.Y.Offset
		if baseHeight <= 0 then
			return
		end

		local mx = math.round(baseHeight * marginX)
		local my = math.round(baseHeight * marginY)

		padding.PaddingLeft = UDim.new(0, mx)
		padding.PaddingRight = UDim.new(0, mx)
		padding.PaddingTop = UDim.new(0, my)
		padding.PaddingBottom = UDim.new(0, my)

		scroll.Size = UDim2.new(
			baseSize.X.Scale, baseSize.X.Offset + mx * 2,
			baseSize.Y.Scale, baseSize.Y.Offset + my * 2
		)

		-- Crecer por los cuatro lados sin mover el centro: con el AnchorPoint en
		-- medio la Position no cambia, y con el en una esquina hay que retirarla
		-- el margen entero. Sale lo mismo de la formula.
		local anchor = scroll.AnchorPoint
		scroll.Position = UDim2.new(
			basePosition.X.Scale, basePosition.X.Offset + mx * (2 * anchor.X - 1),
			basePosition.Y.Scale, basePosition.Y.Offset + my * (2 * anchor.Y - 1)
		)
	end

	apply()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(apply)
end

--== Enganche ===============================================================--

export type Options = {
	marginX: number?,
	marginY: number?,
	clip: boolean?,
}

--[=[
	Engancha una fila: envuelve lo que ya haya y lo que aparezca despues, y saca
	la frontera de recorte fuera de la banda. Idempotente.
]=]
function CardSlots.attach(scroll: ScrollingFrame, options: Options?)
	if attached[scroll] then
		return
	end
	attached[scroll] = true

	local opts: Options = options or {}

	for _, child in scroll:GetChildren() do
		if shouldWrap(child) then
			wrap(child :: GuiObject)
		end
	end

	--[[
		Al reparentar la tarjeta dentro del slot vuelve a saltar ChildAdded para el
		propio slot; `shouldWrap` lo descarta y no hay recursion.

		El envoltorio se aplaza a proposito. Con SignalBehavior.Immediate este
		callback corre DENTRO de la asignacion de Parent que lo disparo, y mover la
		tarjeta ahi mismo es reentrante: el motor avisa ("something unexpectedly tried
		to set the parent of X while trying to set the parent of X") y el movimiento
		no se hace, dejando la tarjeta suelta y un slot vacio ocupando su hueco. Con
		Deferred daba igual, pero las places de casas van en Immediate.
	]]
	scroll.ChildAdded:Connect(function(child)
		if not shouldWrap(child) then
			return
		end

		task.defer(function()
			-- Un paso mas tarde la tarjeta puede haberse destruido o movido: los
			-- controladores limpian y repueblan la fila en la misma pasada.
			if child.Parent == scroll and shouldWrap(child) then
				wrap(child :: GuiObject)
			end
		end)
	end)

	if opts.clip ~= false then
		expandClip(scroll, opts.marginX or MARGIN_X, opts.marginY or MARGIN_Y)
	end
end

return CardSlots
