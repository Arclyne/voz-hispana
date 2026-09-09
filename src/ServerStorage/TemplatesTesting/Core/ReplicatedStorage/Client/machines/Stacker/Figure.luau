type Point = {
    x: number,
    y: number,
}

local Figure = {}
Figure.__index = Figure

export type Figure = typeof(setmetatable(
    {} :: {
        x: number,
        y: number,
        shape: { { number } },
        visible: boolean,
    },
    Figure
))

function Figure.new(x: number, y: number, shape: { { number } }): Figure
    return setmetatable({
        x = x,
        y = y,
        shape = shape,
        visible = true,
    }, Figure)
end

function Figure.moveUp(self: Figure)
    self.y += 1
end

function Figure.moveDown(self: Figure)
    self.y -= 1
end

function Figure.moveLeft(self: Figure)
    self.x -= 1
end

function Figure.moveRight(self: Figure)
    self.x += 1
end

function Figure.getPoints(self: Figure): { Point }
    local points = {}

    for i = 1, #self.shape do
        for j = 1, #self.shape[i] do
            if self.shape[i][j] > 0 then
                table.insert(points, {
                    x = self.x + j - 1,
                    y = self.y + i - 1,
                })
            end
        end
    end

    return points
end

function Figure.hasPoint(self: Figure, point: Point): boolean
    local points = self:getPoints()
    for _, figurePoint in points do
        if figurePoint.x == point.x and figurePoint.y == point.y then
            return true
        end
    end
    return false
end

return Figure