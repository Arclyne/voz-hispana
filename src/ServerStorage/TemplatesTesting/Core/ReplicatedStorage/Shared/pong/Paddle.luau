local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local CircularBuffer = require(script.Parent.Parent.CircularBuffer)
local Input = require(script.Parent.Input)
local Trove = require(ReplicatedStorage.Shared.Trove)
local NetworkTimer = require(ReplicatedStorage.Shared.NetworkTimer)
local Sift = require(ReplicatedStorage.Shared.Sift)
local makeClientPart = require(ReplicatedStorage.Shared.makeClientPart)

export type InputPayload = {
    tick: number,
    direction: number,
}

export type StatePayload = {
    tick: number,
    position: Vector3,
}

local OWNER_COLOR = Color3.fromRGB(13, 105, 172)
local PADDLE_SPEED = 8.5
local PADDLE_ERROR = 0.12

local remotes = ReplicatedStorage.Events

local Paddle = {}
Paddle.__index = Paddle

local function defaultStatePayload(): StatePayload
    return {
        tick = 0,
        position = Vector3.zero,
    }
end

export type Paddle = typeof(setmetatable(
    {} :: {
        _trove: Trove.Trove,
        _model: Model,
        _part: BasePart,
        _player: Player,
        _timer: NetworkTimer.NetworkTimer,
        _initialPosition: Vector3,

        -- server
        _inputQueue: { InputPayload },
        _lastReceivedTick: number,

        -- client
        _inputBuffer: CircularBuffer.CircularBuffer<InputPayload>,
        _stateBuffer: CircularBuffer.CircularBuffer<StatePayload>,
        _latestServerState: StatePayload,
        _lastProcessedState: StatePayload,
        _debugLastWarn: number,
    },
    Paddle
))

function Paddle.new(model: Model, part: BasePart, player: Player): Paddle
    local self = setmetatable({
        _trove = Trove.new(),
        _model = model,
        _part = part,
        _player = player,
        _timer = NetworkTimer.new(),
        _initialPosition = part.Position,
        _inputQueue = {},
        _lastReceivedTick = 0,
        _inputBuffer = CircularBuffer.new(),
        _stateBuffer = CircularBuffer.new(),
        _latestServerState = defaultStatePayload(),
        _lastProcessedState = defaultStatePayload(),
        _debugLastWarn = 0,
    }, Paddle)

    if RunService:IsClient() then
        self._part = self._trove:Add(makeClientPart(part))
        if player == Players.LocalPlayer then
            self._part.Color = OWNER_COLOR
        end
    end

    if RunService:IsClient() then
        self._trove:Add(self._timer:bind(function()
            self:_handleClientTick()
        end))
    end

    return self
end

function Paddle.pushInput(self: Paddle, input: InputPayload)
    if not RunService:IsServer() then
        return
    end

    if input.tick <= self._lastReceivedTick then
        return
    end

    self._lastReceivedTick = input.tick
    table.insert(self._inputQueue, input)
end

function Paddle._handleServerTick(self: Paddle)
    if not RunService:IsServer() then
        return
    end

    local clientTick = 0
    while #self._inputQueue > 0 do
		local input = table.remove(self._inputQueue, 1) :: InputPayload
		local state = self:_processMovement(input)
        self._stateBuffer:set(input.tick, state)
        clientTick = input.tick
    end

	if clientTick > 0 then
		remotes.Machines.PongPaddleUpdate:FireAllClients(self._model, {
			player = self._player,
			state = self._stateBuffer:get(clientTick),
		})
    end
end

function Paddle._handleClientTick(self: Paddle)
    if not RunService:IsClient() then
        return
    end

    if Players.LocalPlayer == self._player then
        local input: InputPayload = {
            tick = self._timer.currentTick,
            direction = Input.getDirection(),
        }
        self._inputBuffer:set(self._timer.currentTick, input)
		remotes.Machines.PongInput:FireServer(self._model, input)

        local state = self:_processMovement(input)
        self._stateBuffer:set(self._timer.currentTick, state)

        self:_handleReconciliation()
    else
        self:_handleInterpolation()
    end
end

function Paddle._shouldReconcile(self: Paddle)
    local isNewServerState = self._latestServerState.tick ~= 0
    local isLastStateUndefinedOrDifferent = self._lastProcessedState.tick == 0
        or self._lastProcessedState.tick ~= self._latestServerState.tick

    return isNewServerState and isLastStateUndefinedOrDifferent
end

function Paddle._handleReconciliation(self: Paddle)
    if not self:_shouldReconcile() then
        return
    end

    self._lastProcessedState = self._latestServerState

    local rewindState = self._stateBuffer:get(self._latestServerState.tick)
    local positionError = (rewindState.position - self._latestServerState.position).Magnitude

    if positionError > PADDLE_ERROR then
        if RunService:IsStudio() and Players.LocalPlayer == self._player then
            local now = os.clock()
            if now - self._debugLastWarn > 1 then
                self._debugLastWarn = now
                warn(`[pong] paddle reconcile model={self._model.Name} tick={self._latestServerState.tick} error={positionError}`)
            end
        end

        self._stateBuffer:set(self._latestServerState.tick, self._latestServerState)
        self._part.Position = self._latestServerState.position

        for tickToProcess = self._latestServerState.tick + 1, self._timer.currentTick do
            local input = self._inputBuffer:get(tickToProcess)
            local state = self:_processMovement(input)
            self._stateBuffer:set(tickToProcess, state)
        end
    end
end

function Paddle._handleInterpolation(self: Paddle)
    self._part.Position = self._part.Position:Lerp(self._latestServerState.position, 0.7)
end

function Paddle._processMovement(self: Paddle, input: InputPayload): StatePayload
    local direction = math.sign(input.direction)
    local hasHit = Sift.Array.findWhere(self._part:GetTouchingParts(), function(part)
        return if direction == 1
            then part.Name == "Top"
            elseif direction == -1 then part.Name == "Bottom"
            else false
    end) ~= nil

    if not hasHit then
        self._part:PivotTo(
            self._part
                :GetPivot()
                :ToWorldSpace(
                    CFrame.new(0, 0, direction * PADDLE_SPEED * self._timer.timeBetweenTicks)
                )
        )
    end

    return {
        tick = input.tick,
        position = self._part.Position,
    }
end

function Paddle.destroy(self: Paddle)
    self._part.Position = self._initialPosition
    self._trove:Destroy()
end

return Paddle