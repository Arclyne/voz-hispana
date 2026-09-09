local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local CookingInteractable = require(script.Parent.CookingInteractable)
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local player = Players.LocalPlayer

local CUT_ANIM_ID = "rbxassetid://105712921488150"
local CUT_SOUND_ID = "rbxassetid://121865121722310"
local CHOP_COOLDOWN = 0.25

local function getAnimator(character: Model): Animator?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end
	return humanoid:FindFirstChildOfClass("Animator")
end

local function loadAnimation(animator: Animator, id: string, looped: boolean): AnimationTrack
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	local track = animator:LoadAnimation(anim)
	anim:Destroy()
	track.Looped = looped
	return track
end

local CuttingBoard = {}
CuttingBoard.__index = CuttingBoard
setmetatable(CuttingBoard, CookingInteractable)

function CuttingBoard.new(model: Model)
	local self = CookingInteractable.new(model, "CuttingBoard")
	setmetatable(self, CuttingBoard)

	local wheel = self:addWheel("cut", function(tool)
		return tool:GetAttribute("Cuttable")
	end)
	wheel:setQuickAction("Cortar", self.request, self)
	wheel.page:addAction("Cortar", self.request, self)

	self._cutTrack = nil
	self._occupied = false
	self._inputConn = nil
	self._chopBar = nil
	self._chopBarFrame = nil

	local occupant = model:FindFirstChild("Occupant")
	occupant.Changed:Connect(function()
		if occupant.Value == player then
			self:onOccupy()
		elseif self._occupied then
			self:onRelease()
		end
	end)

	model:GetAttributeChangedSignal("ChopProgress"):Connect(function()
		local progress = model:GetAttribute("ChopProgress")
		if progress then
			self:updateProgressBar(progress)
		else
			self:destroyProgressBar()
		end
	end)

	return self
end

function CuttingBoard:onOccupy()
	self._occupied = true
	self:disable()

	local character = player.Character
	if not character then
		return
	end

	local playerPart = self.model:FindFirstChild("Player")
	if playerPart then
		character:PivotTo(playerPart:GetPivot())
	end

	Controls:Disable()

	local animator = getAnimator(character)
	if not animator then
		return
	end

	self:enableChopInput(animator, character)
end

function CuttingBoard:enableChopInput(animator, character)
	local cutTrack = loadAnimation(animator, CUT_ANIM_ID, false)
	self._cutTrack = cutTrack
	self._lastChopTime = 0

	self._inputConn = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if not self._occupied then
			return
		end
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local now = os.clock()
		if now - self._lastChopTime < CHOP_COOLDOWN then
			return
		end
		self._lastChopTime = now

		self:request()

		cutTrack:Play()
		cutTrack.TimePosition = 0

		local sound = Instance.new("Sound")
		sound.SoundId = CUT_SOUND_ID
		sound.Parent = character:FindFirstChild("HumanoidRootPart")
		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
		end)
	end)
end

function CuttingBoard:updateProgressBar(progress)
	if not self._chopBar then
		local barTemplate = ReplicatedStorage.Assets.Interactable.Billboard:WaitForChild("Bar")
		local bar = barTemplate:Clone()
		bar.Name = "Bar_Chop"

		local adornee = self.model:FindFirstChild("Primary")
		if not adornee then
			return
		end

		if bar:IsA("BillboardGui") then
			bar.Adornee = adornee
		end
		bar.Parent = adornee

		local barFrame = bar:FindFirstChild("ToolActivatedBar", true)
		local progressFrame = barFrame and barFrame:FindFirstChild("Bar", true)
		if not barFrame or not progressFrame then
			bar:Destroy()
			return
		end

		progressFrame.Size = UDim2.new(0, 0, 1, 0)
		barFrame.Visible = true
		self._chopBar = bar
		self._chopBarFrame = progressFrame
	end

	TweenService:Create(self._chopBarFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
		Size = UDim2.new(progress, 0, 1, 0),
	}):Play()
end

function CuttingBoard:destroyProgressBar()
	if self._chopBar then
		self._chopBar:Destroy()
		self._chopBar = nil
		self._chopBarFrame = nil
	end
end

function CuttingBoard:onRelease()
	self._occupied = false
	self:enable()
	Controls:Enable()

	if self._inputConn then
		self._inputConn:Disconnect()
		self._inputConn = nil
	end
	if self._cutTrack then
		self._cutTrack:Stop()
		self._cutTrack:Destroy()
		self._cutTrack = nil
	end
end

return CuttingBoard
