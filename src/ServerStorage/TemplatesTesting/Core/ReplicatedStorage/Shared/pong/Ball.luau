local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CircularBuffer = require(script.Parent.Parent.CircularBuffer)
local Trove = require(script.Parent.Parent.Trove)
local NetworkTimer = require(script.Parent.Parent.NetworkTimer)
local Paddle = require(script.Parent.Paddle)
local makeClientPart = require(ReplicatedStorage.Shared.makeClientPart)

export type StatePayload = {
    tick: number,
    position: Vector3,
    directionX: number,
    directionY: number,
    lastHit: string?,
}

type BoundsParts = {
    top: BasePart,
    bottom: BasePart,
    left: BasePart,
    right: BasePart,
}

local BALL_SPEED = 4.4
local BALL_ERROR = 0.5
local SPAWN_OFFSET = 0.5

local remotes = ReplicatedStorage.Events

local Ball = {}
Ball.__index = Ball

export type Ball = typeof(setmetatable(
    {} :: {
        _trove: Trove.Trove,
        _model: Model,
        _bounds: BoundsParts,
        _frame: CFrame,
        _radius: number,
        _debugLastWarn: number,

        _part: BasePart,
        _directionX: number,
        _directionY: number,
        _timer: NetworkTimer.NetworkTimer,
        _spawned: boolean,
        _initialPosition: Vector3,
        _lastHit: string?,
        _paddle1: Paddle.Paddle,
        _paddle2: Paddle.Paddle,
        _owner: Player?,

        -- server
        _ticksMap: { [Player]: number },
        _lastTickByPlayer: { [Player]: number },
        _onScoreCallback: ((side: "left" | "right") -> ())?,

        -- client
        _stateBuffer: CircularBuffer.CircularBuffer<StatePayload>,
        _latestServerState: StatePayload,
        _lastProcessedState: StatePayload,
    },
    Ball
))

local function defaultStatePayload(): StatePayload
    return {
        tick = 0,
        position = Vector3.zero,
        directionX = 0,
        directionY = 0,
    }
end

local function expectBasePart(model: Model, name: string): BasePart
    local part = model:FindFirstChild(name, true)
    assert(part and part:IsA("BasePart"), (`[pong] missing BasePart "{name}" in model "{model.Name}"`))
    return part
end

local function flattenXZ(v: Vector3): Vector3
    return Vector3.new(v.X, 0, v.Z)
end

local function safeUnit(v: Vector3, fallback: Vector3): Vector3
    if v.Magnitude < 1e-6 then
        return fallback
    end
    return v.Unit
end

local function createPlayfieldFrame(model: Model, bounds: BoundsParts): CFrame
    local leftPos = bounds.left.Position
    local rightPos = bounds.right.Position
    local topPos = bounds.top.Position
    local bottomPos = bounds.bottom.Position

    local origin = (leftPos + rightPos + topPos + bottomPos) / 4

    local modelPivot = model:GetPivot()

    local xFromBounds = flattenXZ(rightPos - leftPos)
    local xAxis = safeUnit(xFromBounds, flattenXZ(modelPivot.RightVector))

    local yAxis = Vector3.yAxis

    -- Make Z axis perpendicular to X in the horizontal plane.
    local zAxis = safeUnit(flattenXZ(xAxis:Cross(yAxis)), flattenXZ(modelPivot.LookVector))

    -- Align Z axis with (top-bottom) direction if possible.
    local zFromBounds = flattenXZ(topPos - bottomPos)
    if zFromBounds.Magnitude > 1e-6 and zAxis:Dot(zFromBounds.Unit) < 0 then
        zAxis = -zAxis
    end

    -- CFrame.fromMatrix expects backVector; back = -look.
    return CFrame.fromMatrix(origin, xAxis, yAxis, -zAxis)
end

function Ball.new(model: Model, part: BasePart, paddle1: Paddle.Paddle, paddle2: Paddle.Paddle): Ball
    local self = setmetatable({
        _trove = Trove.new(),
        _model = model,
        _bounds = {
            top = expectBasePart(model, "Top"),
            bottom = expectBasePart(model, "Bottom"),
            left = expectBasePart(model, "Left"),
            right = expectBasePart(model, "Right"),
        },
        _frame = CFrame.identity,
        _radius = math.max(part.Size.X, part.Size.Z) / 2,
        _debugLastWarn = 0,

        _part = part,
        _directionX = 0,
        _directionY = 0,
        _timer = NetworkTimer.new(),
        _spawned = false,
        _initialPosition = part.Position,
        _paddle1 = paddle1,
        _paddle2 = paddle2,
        _ticksMap = {},
        _lastTickByPlayer = {},
        _stateBuffer = CircularBuffer.new(),
        _latestServerState = defaultStatePayload(),
        _lastProcessedState = defaultStatePayload(),
    }, Ball)

    self._frame = createPlayfieldFrame(model, self._bounds)

    if RunService:IsClient() then
        self._part = self._trove:Add(makeClientPart(part))
    end

    if RunService:IsClient() then
        self._trove:Add(self._timer:bind(function()
            self:_handleClientTick()
        end))
    end

    return self
end

function Ball._handleServerTick(self: Ball)
    if not RunService:IsServer() then
        return
    end

    local state = self:_processMovement()

    for player, tick in self._ticksMap do
        remotes.Machines.PongBallUpdate:FireClient(player, self._model, {
            tick = tick,
            position = state.position,
            directionX = state.directionX,
            directionY = state.directionY,
            lastHit = state.lastHit,
        })
    end

    table.clear(self._ticksMap)
end

function Ball._handleClientTick(self: Ball)
    if not RunService:IsClient() then
        return
    end

    local state = self:_processMovement()
    self._stateBuffer:set(self._timer.currentTick, state)

    remotes.Machines.PongTick:FireServer(self._model, self._timer.currentTick)

    self:_handleReconciliation()
end

function Ball._shouldReconcile(self: Ball)
    local isNewServerState = self._latestServerState.tick ~= 0
    local isLastStateUndefinedOrDifferent = self._lastProcessedState.tick == 0
        or self._lastProcessedState.tick ~= self._latestServerState.tick

    return isNewServerState and isLastStateUndefinedOrDifferent
end

function Ball._handleReconciliation(self: Ball)
    if not self:_shouldReconcile() then
        return
    end

    self._lastProcessedState = self._latestServerState

    local serverState = self._latestServerState
    local rewindState = self._stateBuffer:get(serverState.tick)

    local shouldCorrect = false
    local positionError = math.huge
    local directionXError = math.huge
    local directionYError = math.huge
    local hitMismatch = true

    if rewindState ~= nil then
        positionError = (rewindState.position - serverState.position).Magnitude
        directionXError = math.abs((rewindState.directionX or 0) - serverState.directionX)
        directionYError = math.abs((rewindState.directionY or 0) - serverState.directionY)
        hitMismatch = (rewindState.lastHit ~= serverState.lastHit)

        -- IMPORTANT: direction mismatches cause huge divergence after a bounce,
        -- even when positional error is still small. Correct early.
        shouldCorrect = positionError > BALL_ERROR
            or directionXError > 0.01
            or directionYError > 0.15
            or hitMismatch
    else
        -- If we don't have a predicted state for that tick,
        -- we can't reconcile safely without snapping.
        shouldCorrect = true
    end

    if shouldCorrect then
        if RunService:IsStudio() then
            local now = os.clock()
            if now - self._debugLastWarn > 1 then
                self._debugLastWarn = now
                warn(
                    `[pong] ball reconcile model={self._model.Name} tick={serverState.tick} posErr={positionError} dirXErr={directionXError} dirYErr={directionYError} hitMismatch={hitMismatch}`
                )
            end
        end

        self._spawned = true
        self._part.Position = serverState.position
        self._directionX = serverState.directionX
        self._directionY = serverState.directionY
        self._lastHit = serverState.lastHit
        self._stateBuffer:set(serverState.tick, serverState)

        for tickToProcess = serverState.tick + 1, self._timer.currentTick do
            local resimState = self:_processMovement()
            self._stateBuffer:set(tickToProcess, resimState)
        end
    end
end

function Ball.spawn(self: Ball, owner: Player)
    self._owner = owner
    self._spawned = true
    self._directionX = 0
    self._directionY = 0
    self._lastHit = nil

    local paddle = owner == self._paddle1._player and self._paddle1 or self._paddle2
    self._part.Position = self:_getPositionFromPaddle(paddle)
end

function Ball.shoot(self: Ball)
    if not self._owner then
        return
    end

    local ownerPaddle = if self._owner == self._paddle1._player then self._paddle1 else self._paddle2
    local otherPaddle = if ownerPaddle == self._paddle1 then self._paddle2 else self._paddle1

    local frame = self._frame
    local ownerLocal = frame:PointToObjectSpace(ownerPaddle._part.Position)
    local otherLocal = frame:PointToObjectSpace(otherPaddle._part.Position)

    -- directionX convention in this module:
    --   dx = directionX * -BALL_SPEED * dt
    -- So directionX == 1 moves toward -X (left), and -1 moves toward +X (right).
    self._directionX = if otherLocal.X > ownerLocal.X then -1 else 1
    self._directionY = self:getBouncingDirectionY(ownerPaddle)

    self._owner = nil
end

function Ball._processMovement(self: Ball): StatePayload
    if self._spawned then
        self:_followOwner()
        self:_moveAndHit()
    end

    return {
        tick = self._timer.currentTick,
        position = self._part.Position,
        directionX = self._directionX,
        directionY = self._directionY,
        lastHit = self._lastHit,
    }
end

function Ball._getPositionFromPaddle(self: Ball, paddle: Paddle.Paddle)
    local frame = self._frame
    local paddleLocal = frame:PointToObjectSpace(paddle._part.Position)

    -- Spawn slightly toward the center of the field.
    local offset = if paddleLocal.X < 0 then SPAWN_OFFSET else -SPAWN_OFFSET

    return frame:PointToWorldSpace(paddleLocal + Vector3.new(offset, 0, 0))
end

function Ball._followOwner(self: Ball)
    if not self._owner then
        return
    end

    local paddle = self._owner == self._paddle1._player and self._paddle1 or self._paddle2
    self._part.Position = self._part.Position:Lerp(self:_getPositionFromPaddle(paddle), 0.4)
end

local function getHalfExtent(part: BasePart, frame: CFrame, axis: "x" | "z"): number
    local right = frame:VectorToObjectSpace(part.CFrame.RightVector)
    local up = frame:VectorToObjectSpace(part.CFrame.UpVector)
    local look = frame:VectorToObjectSpace(part.CFrame.LookVector)

    local halfX = part.Size.X / 2
    local halfY = part.Size.Y / 2
    local halfZ = part.Size.Z / 2

    local component = if axis == "x" then "X" else "Z"

    return math.abs((right :: any)[component]) * halfX
        + math.abs((up :: any)[component]) * halfY
        + math.abs((look :: any)[component]) * halfZ
end

function Ball.getBouncingDirectionY(self: Ball, paddle: Paddle.Paddle)
    local frame = self._frame

    local paddleLocal = frame:PointToObjectSpace(paddle._part.Position)
    local ballLocal = frame:PointToObjectSpace(self._part.Position)

    local half = getHalfExtent(paddle._part, frame, "z")
    if half <= 1e-6 then
        return 0
    end

    local raw = -(ballLocal.Z - paddleLocal.Z) / half

    -- Keep bounce angles reasonable so the ball is mostly horizontal.
    return math.clamp(raw, -1, 1) * 0.75
end

local function isWithinZExtent(ballZ: number, paddleZ: number, paddleSizeZ: number, radius: number): boolean
    local half = paddleSizeZ / 2
    return math.abs(ballZ - paddleZ) <= (half + radius)
end

local function computeBounceDirectionY(ballZ: number, paddleZ: number, halfZ: number): number
    if halfZ <= 1e-6 then
        return 0
    end

    local raw = -(ballZ - paddleZ) / halfZ
    return math.clamp(raw, -1, 1) * 0.75
end

local MAX_PADDLE_REWIND_TICKS = 6

local function getPaddleWorldPositionForCollision(self: Ball, paddle: Paddle.Paddle): Vector3
    if not RunService:IsServer() then
        return paddle._part.Position
    end

    local tick = self._ticksMap[paddle._player]
    if type(tick) ~= "number" then
        tick = self._lastTickByPlayer[paddle._player]
    end

    if type(tick) ~= "number" then
        return paddle._part.Position
    end

    for t = tick, tick - MAX_PADDLE_REWIND_TICKS, -1 do
        local state = paddle._stateBuffer:get(t)
        if state ~= nil and state.position ~= nil then
            return state.position
        end
    end

    return paddle._part.Position
end

function Ball._moveAndHit(self: Ball)
    if self._owner then
        return
    end

    local dt = self._timer.timeBetweenTicks
    local radius = self._radius
    local frame = self._frame

    local current = frame:PointToObjectSpace(self._part.Position)

    local dx = self._directionX * -BALL_SPEED * dt
    local dz = self._directionY * -BALL_SPEED * dt

    local nextPos = current + Vector3.new(dx, 0, dz)

    local paddle1World = getPaddleWorldPositionForCollision(self, self._paddle1)
    local paddle2World = getPaddleWorldPositionForCollision(self, self._paddle2)

    local paddle1Local = frame:PointToObjectSpace(paddle1World)
    local paddle2Local = frame:PointToObjectSpace(paddle2World)

    local leftPaddle, rightPaddle
    local leftPaddleLocal, rightPaddleLocal
    if paddle1Local.X <= paddle2Local.X then
        leftPaddle, rightPaddle = self._paddle1, self._paddle2
        leftPaddleLocal, rightPaddleLocal = paddle1Local, paddle2Local
    else
        leftPaddle, rightPaddle = self._paddle2, self._paddle1
        leftPaddleLocal, rightPaddleLocal = paddle2Local, paddle1Local
    end

    local hit: string? = nil
    local hitPaddle: Paddle.Paddle? = nil
    local hitPaddleLocalZ = 0
    local hitPaddleHalfZ = 0

    -- Paddle collisions (deterministic, based on crossing the paddle face)
    -- directionX == 1 moves toward -X (left)
    if self._directionX == 1 then
        local paddlePart = leftPaddle._part
        local halfX = getHalfExtent(paddlePart, frame, "x")
        local halfZ = getHalfExtent(paddlePart, frame, "z")

        local plane = leftPaddleLocal.X + halfX
        local contactX = plane + radius

        if current.X > contactX and nextPos.X <= contactX
            and isWithinZExtent(nextPos.Z, leftPaddleLocal.Z, halfZ * 2, radius)
        then
            hit = "PaddleLeft"
            hitPaddle = leftPaddle
            hitPaddleLocalZ = leftPaddleLocal.Z
            hitPaddleHalfZ = halfZ
            nextPos = Vector3.new(contactX, nextPos.Y, nextPos.Z)
        end
    -- directionX == -1 moves toward +X (right)
    elseif self._directionX == -1 then
        local paddlePart = rightPaddle._part
        local halfX = getHalfExtent(paddlePart, frame, "x")
        local halfZ = getHalfExtent(paddlePart, frame, "z")

        local plane = rightPaddleLocal.X - halfX
        local contactX = plane - radius

        if current.X < contactX and nextPos.X >= contactX
            and isWithinZExtent(nextPos.Z, rightPaddleLocal.Z, halfZ * 2, radius)
        then
            hit = "PaddleRight"
            hitPaddle = rightPaddle
            hitPaddleLocalZ = rightPaddleLocal.Z
            hitPaddleHalfZ = halfZ
            nextPos = Vector3.new(contactX, nextPos.Y, nextPos.Z)
        end
    end

    -- Top / Bottom walls (use whichever has higher/lower Z)
    local topLocal = frame:PointToObjectSpace(self._bounds.top.Position)
    local bottomLocal = frame:PointToObjectSpace(self._bounds.bottom.Position)
    local topPart = self._bounds.top
    local bottomPart = self._bounds.bottom
    if topLocal.Z < bottomLocal.Z then
        topLocal, bottomLocal = bottomLocal, topLocal
        topPart, bottomPart = bottomPart, topPart
    end

    local topFace = topLocal.Z - getHalfExtent(topPart, frame, "z")
    local bottomFace = bottomLocal.Z + getHalfExtent(bottomPart, frame, "z")

    if not hit then
        if nextPos.Z + radius >= topFace then
            hit = "Top"
            nextPos = Vector3.new(nextPos.X, nextPos.Y, topFace - radius)
        elseif nextPos.Z - radius <= bottomFace then
            hit = "Bottom"
            nextPos = Vector3.new(nextPos.X, nextPos.Y, bottomFace + radius)
        end
    end

    -- Left / Right goals (use whichever has lower/higher X)
    local leftBoundLocal = frame:PointToObjectSpace(self._bounds.left.Position)
    local rightBoundLocal = frame:PointToObjectSpace(self._bounds.right.Position)
    local leftBoundPart = self._bounds.left
    local rightBoundPart = self._bounds.right
    if leftBoundLocal.X > rightBoundLocal.X then
        leftBoundLocal, rightBoundLocal = rightBoundLocal, leftBoundLocal
        leftBoundPart, rightBoundPart = rightBoundPart, leftBoundPart
    end

    local leftFace = leftBoundLocal.X + getHalfExtent(leftBoundPart, frame, "x")
    local rightFace = rightBoundLocal.X - getHalfExtent(rightBoundPart, frame, "x")

    if not hit then
        if nextPos.X - radius <= leftFace then
            hit = "Left"
        elseif nextPos.X + radius >= rightFace then
            hit = "Right"
        end
    end

    -- Apply movement (after correction)
    self._part.Position = frame:PointToWorldSpace(nextPos)

    if hit and hit ~= self._lastHit then
        self._lastHit = hit

        if hit == "Top" or hit == "Bottom" then
            self._directionY *= -1
        elseif hit == "Left" or hit == "Right" then
            self._spawned = false
            if self._onScoreCallback then
                self._onScoreCallback(if hit == "Left" then "left" else "right")
            end
        elseif hitPaddle then
            if hit == "PaddleLeft" and self._directionX == 1 then
                self._directionX = -1
            elseif hit == "PaddleRight" and self._directionX == -1 then
                self._directionX = 1
            end

            self._directionY = computeBounceDirectionY(nextPos.Z, hitPaddleLocalZ, hitPaddleHalfZ)
        end
    elseif not hit then
        self._lastHit = nil
    end
end

function Ball.onScore(self: Ball, callback: ("left" | "right") -> ())
    self._onScoreCallback = callback
end

function Ball.destroy(self: Ball)
    self._part.Position = self._initialPosition
    self._trove:Destroy()
end

return Ball
