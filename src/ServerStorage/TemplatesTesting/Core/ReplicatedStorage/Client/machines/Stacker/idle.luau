local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Board = require(script.Parent.Board)
local Figure = require(script.Parent.Figure)
local Sift = require(ReplicatedStorage.Shared.Sift)

local function drop(figure: Figure.Figure, targetY: number)
    for y = figure.y, targetY, -1 do
        task.wait(0.02)
        figure.y = y
    end
end

return function(model: Model, trove)
    local board = Board.new(model.Screen)
    local figures = table.create(board.height * board.width)
    local threads = table.create(board.height * board.width)

    for x = 1, board.width do
        for y = 1, board.height do
            local figure = Figure.new(x, board.height + 1, { { 1 } })

            board:addFigure(figure)
            table.insert(figures, {
                figure = figure,
                targetY = y,
            })
        end
    end

    figures = Sift.Array.shuffle(figures)

    local function dropAll()
        -- start in zero index so we have no delay for the first item
        for i = 0, #figures - 1 do
            local figure = figures[i + 1]
            figure.figure.y = board.height + 1
            table.insert(threads, task.delay(i * 0.1, drop, figure.figure, figure.targetY))
        end
    end

    board:onUpdate(function()
        local ended = Sift.Array.every(threads, function(thread)
            return coroutine.status(thread) == "dead"
        end)

		if ended then
            table.clear(threads)
            table.insert(threads, task.delay(1, dropAll))
        end
    end)

    board:start()

    trove:Add(board, "destroy")
    trove:Add(function()
        for _, thread in threads do
            if coroutine.status(thread) == "suspended" then
                task.cancel(thread)
            end
        end
    end)
end
