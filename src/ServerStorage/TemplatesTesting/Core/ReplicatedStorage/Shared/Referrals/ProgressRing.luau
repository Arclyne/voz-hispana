--[[
	ProgressRing

	El anillo que rodea el avatar de un amigo en progreso.

	Roblox no sabe dibujar arcos: un UIStroke es todo o nada, y no hay forma de
	pintar "media circunferencia". Las dos salidas habituales son recortar dos
	mitades de una imagen de anillo y rotarlas, o construir el anillo con muchos
	trozos pequenos.

	Aqui van los trozos, y a proposito: la otra via necesita subir una imagen a la
	cuenta, y ya sabemos como acaba eso (los assets del Creator Store cargan en
	Studio y fallan en el cliente publicado, que es justo lo que nos paso con las
	flechas del carrusel). Esto no depende de ningun asset.

	Con 48 segmentos y separacion minima se lee como un borde continuo.
]]

local ProgressRing = {}
ProgressRing.__index = ProgressRing

local SEGMENTS = 48

-- Los segmentos van TUMBADOS sobre la circunferencia, no apuntando hacia afuera:
-- puestos en radial el anillo parecia un sol con pinchos. El ancho se solapa un
-- pelin con el del vecino para que no se vean las juntas.
local SEGMENT_ARC = 0.072 -- largo sobre la circunferencia
local SEGMENT_THICKNESS = 0.07 -- grosor del borde
local RADIUS = 0.46 -- distancia del centro, en fraccion del diametro

--[[
	Rellena `container` con los segmentos. El contenedor tiene que ser cuadrado;
	el anillo se dibuja sobre su caja completa.
]]
function ProgressRing.new(container: Frame, emptyColor: Color3)
	local self = setmetatable({}, ProgressRing)

	self.container = container
	self.segments = {}
	self.emptyColor = emptyColor
	self.ratio = -1
	self.color = Color3.new(1, 1, 1)

	for index = 1, SEGMENTS do
		local angle = (index - 1) / SEGMENTS * math.pi * 2

		local segment = Instance.new("Frame")
		segment.Name = "Seg" .. index
		segment.AnchorPoint = Vector2.new(0.5, 0.5)
		segment.Size = UDim2.fromScale(SEGMENT_ARC, SEGMENT_THICKNESS)
		segment.BorderSizePixel = 0
		segment.BackgroundColor3 = emptyColor

		-- Se coloca sobre la circunferencia y se gira para que apunte al centro.
		-- El angulo arranca arriba (de ahi el -math.pi/2) y avanza en el sentido
		-- de las agujas del reloj, como cualquier barra circular.
		segment.Position = UDim2.fromScale(
			0.5 + math.sin(angle) * RADIUS,
			0.5 - math.cos(angle) * RADIUS
		)
		segment.Rotation = math.deg(angle)
		segment.ZIndex = container.ZIndex
		segment.Parent = container

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = segment

		self.segments[index] = segment
	end

	return self
end

--[[
	`ratio` de 0 a 1. `color` es el del tramo lleno.

	Solo se repintan los segmentos que cambian de estado: mover la barra un
	segundo toca uno o ninguno, no cuarenta y ocho.
]]
function ProgressRing:set(ratio: number, color: Color3)
	ratio = math.clamp(ratio or 0, 0, 1)

	local sameColor = color == nil or (color.R == self.color.R and color.G == self.color.G and color.B == self.color.B)

	if ratio == self.ratio and sameColor then
		return
	end

	local filled = math.floor(ratio * SEGMENTS + 0.0001)

	-- Un progreso que ha empezado pero no llega a un segmento entero enciende el
	-- primero igual: si no, la barra parece parada durante los primeros segundos.
	if filled == 0 and ratio > 0 then
		filled = 1
	end

	self.ratio = ratio
	self.color = color or self.color

	for index, segment in ipairs(self.segments) do
		segment.BackgroundColor3 = index <= filled and self.color or self.emptyColor
	end
end

function ProgressRing:destroy()
	for _, segment in ipairs(self.segments) do
		segment:Destroy()
	end

	self.segments = {}
end

return ProgressRing
