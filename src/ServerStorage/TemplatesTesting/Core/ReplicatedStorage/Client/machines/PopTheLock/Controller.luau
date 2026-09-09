local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local INITIAL_SPEED = 45
local SPEED_INCREMENT = 3
local DOT_ANGLE_OFFSET = -90
local DOT_POSITION_OFFSET = -22
local DOT_OVERLAPPING_MARGIN = 10
local DOTS_TO_WIN = 50

local Controller = {}
Controller.__index = Controller

export type Controller = typeof(setmetatable(
    {} :: {
        model: Model,
        remainingDots: number,
        angle: number,
        dotAngle: number,
        speed: number,
        flipped: boolean,
        connection: RBXScriptConnection?,
        tickets: number,
        wheel: GuiObject,
        dot: GuiObject,
        label: TextLabel,
        _onDotMissedCallback: (() -> ())?,
    },
    Controller
))

function Controller.new(model: Model): Controller
    return setmetatable({
        model = model,
        remainingDots = DOTS_TO_WIN,
        angle = 0,
        dotAngle = 0,
        speed = INITIAL_SPEED,
        flipped = false,
        tickets = 0,
        wheel = model.Screen.SurfaceGui.Wheel,
        dot = model.Screen.SurfaceGui.Dot,
        label = model.Screen.SurfaceGui.Label,
    }, Controller)
end

function Controller.placeDot(self: Controller, angle: number)
    local d = math.rad(angle + DOT_ANGLE_OFFSET)
    local wR = self.wheel.AbsoluteSize.X / 2
    local dR = self.dot.AbsoluteSize.X / 2
    local x = math.cos(d) * (wR + DOT_POSITION_OFFSET) + wR - dR
    local y = math.sin(d) * (wR + DOT_POSITION_OFFSET) + wR - dR

    self.dotAngle = angle
    self.dot.Position = UDim2.fromOffset(x, y)
end

function Controller.animateDot(self: Controller)
    local fakeDot = self.dot:Clone()
    fakeDot.Transparency = 1
    fakeDot.Parent = self.dot.Parent

    local innerDot = self.dot:Clone()
    innerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    innerDot.Position = UDim2.fromScale(0.5, 0.5)
    innerDot.Size = UDim2.fromScale(0.5, 0.5)
    innerDot.Parent = fakeDot

    local tweenInfo = TweenInfo.new(0.5)
    local tween = TweenService:Create(innerDot, tweenInfo, {
        Size = UDim2.fromScale(1.2, 1.2),
        Transparency = 1,
    })

    tween.Completed:Connect(function()
        tween:Destroy()
        fakeDot:Destroy()
    end)

    tween:Play()
end

function Controller.isOverlapping(self: Controller)
    return self.angle >= (self.dotAngle - DOT_OVERLAPPING_MARGIN)
        and self.angle <= (self.dotAngle + DOT_OVERLAPPING_MARGIN)
end

function Controller.onDotMissed(self: Controller, callback: () -> ())
    self._onDotMissedCallback = callback
end

function Controller.start(self: Controller)
    self:setRemainingDotsText()
    self:placeDot(90)
    self.dot.Visible = true

    self.connection = RunService.Heartbeat:Connect(function(dt)
        local prevIsOverlapping = self:isOverlapping()
        local direction = if self.flipped then -1 else 1

        self.angle = (self.angle + self.speed * direction * dt) % 360
        self.wheel.Rotation = self.angle

        if prevIsOverlapping and not self:isOverlapping() then
            if self._onDotMissedCallback then
				self._onDotMissedCallback()
				SoundManager:Play(nil, 16425043606, { Volume = 1 }, self.model)
            end
        end
    end)
end

function Controller.stop(self: Controller)
    self.dot.Visible = false

	if self.remainingDots <= 0 then
		SoundManager:Play(nil, 16425050720, { Volume = 1 }, self.model)
    end

    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

function Controller.flip(self: Controller)
    self.flipped = not self.flipped
	self.speed += SPEED_INCREMENT
	SoundManager:Play(nil, 16425042290, { Volume = 1 }, self.model)
end

function Controller.reset(self: Controller)
    self.wheel.Rotation = 0
    self.remainingDots = DOTS_TO_WIN
    self.angle = 0
    self.dotAngle = 0
    self.speed = INITIAL_SPEED
    self.flipped = false
    self.tickets = 0
    self:stop()
    self:setInitialText()
end

function Controller.setRemainingDotsText(self: Controller)
    self.label.TextYAlignment = Enum.TextYAlignment.Top
    self.label.Text =
        `<font size="100">{self.remainingDots}</font>\n<font size="16">PARA GANAR!</font>`
end

function Controller.setInitialText(self: Controller)
    self.label.TextYAlignment = Enum.TextYAlignment.Top
    self.label.Text =
        `PARA LA <font color="rgb(255,0,0)">BARRA ROJA</font> EN LOS <font color="rgb(255,255,0)">PUNTOS AMARILLOS</font> PARA GANAR`
end

function Controller.setFinishText(self: Controller)
    self.label.TextYAlignment = Enum.TextYAlignment.Center

    if self.tickets > 0 then
        self.label.Text =
            `<font size="40">Ganaste</font>\n<font size="25">{self.tickets}</font>\n<font size="40">Ticket{self.tickets > 1 and "s" or ""}!</font>`
    else
        self.label.Text =
            `<font size="40">Perdiste</font>\n<font size="30">Inténtalo de nuevo!</font>`
    end
end

function Controller.claimTicket(self: Controller)
    self.tickets += 1
    self.remainingDots -= 1
    self:setRemainingDotsText()
    self:animateDot()
end

return Controller
