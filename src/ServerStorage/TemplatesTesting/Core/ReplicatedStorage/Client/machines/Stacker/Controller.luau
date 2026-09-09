local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Board = require(script.Parent.Board)
local Clock = require(ReplicatedStorage.Shared.Clock)
local Figure = require(script.Parent.Figure)
local Promise = require(ReplicatedStorage.Shared.Promise)
local Sift = require(ReplicatedStorage.Shared.Sift)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local BOARD_COLUMNS = 7
local INITIAL_COLUMNS = 3
local BLINK_STEPS = 5
local BLINK_STEP_DURATION = 0.2
local BOUNCE_THROTTLE = 0.175
local BOUNCE_DECREMENT_RATE = 0.0125

local Controller = {}
Controller.__index = Controller

export type Controller = typeof(setmetatable(
    {} :: {
        board: Board.Board,
        figure: Figure.Figure,
        clock: Clock.Clock?,
        stackLevel: number,
        bouncing: boolean,

        _onWinCallback: (() -> ())?,
        _onLoseCallback: (() -> ())?,
        _promise: any,
    },
    Controller
))

function Controller.new(board: Board.Board): Controller
    return setmetatable({
        board = board,
        figure = Figure.new(1, 1, {}),
        stackLevel = 0,
        bouncing = true,
    }, Controller)
end

function Controller.start(self: Controller)
    self:spawn(INITIAL_COLUMNS)

    local movingRight = true

    local function moveFigure()
        if movingRight then
            self.figure:moveRight()
        else
            self.figure:moveLeft()
        end
    end

    local function handleCollision()
        movingRight = not movingRight
        moveFigure()
        moveFigure()
		moveFigure()
		SoundManager:Play(nil, 15154119183, { Volume = 1 }, self.board.screen)
    end

    local function checkCollision()
        local points = self.figure:getPoints()
        local left = points[1]
        local right = points[#points]

        if movingRight and self.board:outBounds(left.x, left.y) then
            handleCollision()
        elseif not movingRight and self.board:outBounds(right.x, right.y) then
            handleCollision()
        end
    end

    self.clock = Clock.new(BOUNCE_THROTTLE, function()
        moveFigure()
        checkCollision()
    end)

    assert(self.clock)

    self.board:onUpdate(function(dt)
        if self.bouncing then
            self.clock:update(dt)
        end
    end)

    self.board:start()
end

function Controller.onWin(self: Controller, callback: () -> ())
    self._onWinCallback = callback
end

function Controller.onLose(self: Controller, callback: () -> ())
    self._onLoseCallback = callback
end

function Controller.stack(self: Controller)
    if not self.bouncing or not self.clock then
        return
    end

    self.bouncing = false

    local function isValidPoint(point: { x: number, y: number }): boolean
        if self.board:outBounds(point.x, 1) then
            return false
        end

        if point.y == 1 then
            return true
        end

        return not self.board:isFree(point.x, point.y - 1)
    end

    local function createSingleBlock(point): Figure.Figure
        return Figure.new(point.x, point.y, { { 1 } })
    end

    local function moveFigureDown(figure: Figure.Figure)
        return Promise.new(function(resolve, _, onCancel)
            onCancel(function()
                self.board:removeFigure(figure)
            end)

            self.board:addFigure(figure)
            task.wait(BLINK_STEP_DURATION)

            while not self.board:isColliding(figure) do
				if self.board:outBounds(figure.x, figure.y - 1) then
					SoundManager:Play(nil, 15154117376, { Volume = 1 }, self.board.screen)
					
                    for i = 1, BLINK_STEPS do
                        figure.visible = i % 2 == 0
                        task.wait(BLINK_STEP_DURATION)
                    end

                    break
                else
                    figure:moveDown()
                    task.wait(BLINK_STEP_DURATION)
                end
            end

            self.board:removeFigure(figure)
            resolve()
        end)
    end

    local points = self.figure:getPoints()

    local movingPoints = Sift.Array.filter(points, function(point)
        return not isValidPoint(point)
    end)

    local staticPoints = Sift.Array.filter(points, function(point)
        return isValidPoint(point)
    end)

    local function moveFiguresDown()
        local movingFigures = Sift.Array.map(movingPoints, createSingleBlock)
        local promises = Sift.Array.map(movingFigures, moveFigureDown)

        self._promise = Promise.all(promises)
        return self._promise:await()
    end

    if not Sift.isEmpty(movingPoints) then
        local staticFigures = Sift.List.map(staticPoints, createSingleBlock)

        for _, figure in staticFigures do
            self.board:addFigure(figure)
        end

		self.board:removeFigure(self.figure)
		SoundManager:Play(nil, 15154118313, { Volume = 1 }, self.board.screen)

        if not moveFiguresDown() then
            return
        end
	else
		SoundManager:Play(nil, 15154115062, { Volume = 1 }, self.board.screen)
    end

    if self.stackLevel == self.board.height then
        if self._onWinCallback then
            self._onWinCallback()
        end
        return
    elseif #staticPoints == 0 then
        if self._onLoseCallback then
            self._onLoseCallback()
        end
        return
    end

    self:spawn(#staticPoints)
    self.clock.interval -= BOUNCE_DECREMENT_RATE
end

function Controller.spawn(self: Controller, columns: number)
    local random = Random.new()
    local positionX = random:NextInteger(1, BOARD_COLUMNS - columns)

    self.bouncing = true
    self.stackLevel = math.min(self.stackLevel + 1, self.board.height)
    self.figure = Figure.new(positionX, self.stackLevel, {
        table.create(columns, 1),
    })

    self.board:addFigure(self.figure :: Figure.Figure)
end

function Controller.destroy(self: Controller)
    if self._promise and self._promise:getStatus() == Promise.Status.Started then
        self._promise:cancel()
    end

    self.board:destroy()
end

return Controller