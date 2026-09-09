local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Figure = require(script.Parent.Figure)
local ObjectCache = require(ReplicatedStorage.Shared.ObjectCache)

local BOARD_COLUMNS = 8
local MARGIN = 0.1
local POINT_TEMPLATE = Instance.new("Part")
POINT_TEMPLATE.Size = Vector3.new(1 - MARGIN, 1 - MARGIN, 1)
POINT_TEMPLATE.Color = Color3.fromRGB(13, 105, 172)
POINT_TEMPLATE.Material = Enum.Material.Neon
POINT_TEMPLATE.Anchored = true

local Board = {}
Board.__index = Board

export type Board = typeof(setmetatable(
    {} :: {
        width: number,
        height: number,
        cache: typeof(ObjectCache.new(...)),
        screen: Part,
        blockSize: number,
        connection: RBXScriptConnection?,
		figures: { Figure.Figure },
		rendered: { [number]: { [number]: BasePart } },

        _onUpdateCallback: ((dt: number) -> ())?,
        _onDrawCallback: (() -> ())?,
    },
    Board
))

function Board.new(screen: Part): Board
    local blockSize = screen.Size.X / BOARD_COLUMNS

    local template = POINT_TEMPLATE:Clone()
    template.Size *= Vector3.new(blockSize, blockSize, screen.Size.Z + 1e-3)

    local self = setmetatable({}, Board)
    self.width = BOARD_COLUMNS
    self.height = math.floor(screen.Size.Y / blockSize)
    self.cache = ObjectCache.new(template, math.floor(self.width * self.height), screen)
    self.screen = screen
    self.blockSize = blockSize
	self.figures = {}

	self.rendered = table.create(self.width)
	for i = 1, self.width do
		self.rendered[i] = table.create(self.height)
	end

    return self
end

function Board.isFree(self: Board, x: number, y: number): boolean
    if self:outBounds(x, y) then
        return false
    end

    local point = {
        x = x,
        y = y,
    }

    for _, figure in self.figures do
        if figure:hasPoint(point) then
            return false
        end
    end

    return true
end

function Board.isColliding(self: Board, figure: Figure.Figure): boolean
    local points = figure:getPoints()

    for _, point in points do
        if self:outBounds(point.x, point.y) then
            return true
        end
    end

    for _, fig: Figure.Figure in self.figures do
        if fig ~= figure then
            for _, point in points do
                if fig:hasPoint(point) then
                    return true
                end
            end
        end
    end

    return false
end

function Board.addFigure(self: Board, figure: Figure.Figure)
    table.insert(self.figures, figure)
end

function Board.removeFigure(self: Board, figure: Figure.Figure)
    local index = table.find(self.figures, figure)
    if index then
        table.remove(self.figures, index)
    end
end

function Board.draw(self: Board)
	local renderPending = table.create(self.width)
	for i = 1, self.width do
		renderPending[i] = table.create(self.height, false)
	end
	
    for _, figure in self.figures do
        if figure.visible then
            for _, point in figure:getPoints() do
				if not self:outBounds(point.x, point.y) then
					renderPending[point.x][point.y] = true
                end
            end
		end
	end
	
	for x = 1, self.width do
		for y = 1, self.height do
			if renderPending[x][y] and not self.rendered[x][y] then
				self.rendered[x][y] = self.cache:GetPart(self:_computeCFrame(x, y))
			elseif not renderPending[x][y] and self.rendered[x][y] then
				self.cache:ReturnPart(self.rendered[x][y])
				self.rendered[x][y] = nil
			end
		end
	end
end

function Board.onUpdate(self: Board, callback: (number) -> ())
    self._onUpdateCallback = callback
end

function Board.onDraw(self: Board, callback: () -> ())
    self._onDrawCallback = callback
end

function Board.start(self: Board)
    self.connection = RunService.Heartbeat:Connect(function(dt)
        if self._onUpdateCallback then
            self._onUpdateCallback(dt)
        end

        self:draw()

        if self._onDrawCallback then
            self._onDrawCallback()
        end
    end)
end

function Board.stop(self: Board)
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

function Board.destroy(self: Board)
    self:stop()
    self.cache:Destroy()
end

function Board.outBounds(self: Board, x: number, y: number): boolean
    if x > self.width or y > self.height then
        return true
    end

    if x <= 0 or y <= 0 then
        return true
    end

    return false
end

function Board._computeCFrame(self: Board, x: number, y: number): CFrame
    local topLeft = self.screen.CFrame:ToWorldSpace(
        CFrame.new(
            self.screen.Size.X / 2 + self.blockSize / 2,
            self.screen.Size.Y / 2 + self.blockSize / 2,
            0
        )
    )

    return topLeft:ToWorldSpace(
        CFrame.new(-self.blockSize * x, -self.blockSize * (self.height - y + 1), 0)
    )
end

return Board
