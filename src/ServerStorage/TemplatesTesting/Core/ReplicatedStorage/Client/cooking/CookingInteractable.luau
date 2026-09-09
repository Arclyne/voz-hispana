local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Interactable = require(script.Parent.Parent.interactable.Interactable)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage.Events

local CookingInteractable = {}
CookingInteractable.__index = CookingInteractable
setmetatable(CookingInteractable, Interactable)

function CookingInteractable.new(model: Model, remoteName: string)
	local self = Interactable.new()
	setmetatable(self, CookingInteractable)

	self.model = model
	self.remoteName = remoteName

	local pickupWheel = self:addWheel("pickup")
	pickupWheel:setQuickAction("Recoger", self.request, self)
	pickupWheel.page:addAction("Recoger", self.request, self)

	self:removeWheel("default")

	-- Los CookingInteractable ya usan "Prompt" como holder.
	-- NO es necesario crear un ProximityPrompt manual:
	-- Interactable.new() ya crea uno y setAdornee() lo parenta aquí.
	local promptHolder = model:FindFirstChild("Prompt")
		or model:FindFirstChild("Primary")
		or model.PrimaryPart

	if not promptHolder then
		warn("[CookingInteractable] " .. model.Name .. " necesita Prompt, PromptHolder, Primary o PrimaryPart")
	else
		self:setAdornee(promptHolder)
	end

	self:setClickHitbox(model)

	-- =======================
	-- Tool equipada
	-- =======================

	local function refreshWheel()
		task.defer(function()
			if self.wheelLocked then
				return
			end

			self:selectWheel()
		end)
	end

	local function watchCharacter(character)
		character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				refreshWheel()
			end
		end)

		character.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then
				refreshWheel()
			end
		end)

		refreshWheel()
	end

	if player.Character then
		watchCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		watchCharacter(character)
	end)

	-- =======================
	-- Resultado terminado
	-- =======================

	model:GetAttributeChangedSignal("ResultReady"):Connect(function()
		if model:GetAttribute("ResultReady") then
			self:enable()
			self:lockWheel("pickup")
		else
			self:unlock()
		end
	end)

	model:GetAttributeChangedSignal("ExpirationDuration"):Connect(function()
		local duration = model:GetAttribute("ExpirationDuration")

		if duration then
			self:showExpirationBar(duration)
		else
			self:destroyExpirationBar()
		end
	end)

	if model:GetAttribute("ResultReady") then
		self:enable()
		self:lockWheel("pickup")
	end

	local expirationDuration = model:GetAttribute("ExpirationDuration")

	if expirationDuration then
		self:showExpirationBar(expirationDuration)
	end

	return self
end

function CookingInteractable:request()
	remotes.Interactable[self.remoteName]:FireServer(self.model)
end

function CookingInteractable:showExpirationBar(duration)
	self:destroyExpirationBar()

	local barTemplate = ReplicatedStorage.Assets.Interactable.Billboard:WaitForChild("Bar")
	local bar = barTemplate:Clone()
	bar.Name = "Bar_Expiration"

	local adornee = self.adornee

	if not adornee then
		bar:Destroy()
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

	progressFrame.Size = UDim2.new(1, 0, 1, 0)
	progressFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	barFrame.Visible = true

	local tween = TweenService:Create(
		progressFrame,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{
			Size = UDim2.new(0, 0, 1, 0),
		}
	)

	self._expirationBar = bar
	self._expirationTween = tween

	tween:Play()
end

function CookingInteractable:destroyExpirationBar()
	if self._expirationTween then
		self._expirationTween:Cancel()
		self._expirationTween = nil
	end

	if self._expirationBar then
		self._expirationBar:Destroy()
		self._expirationBar = nil
	end
end

return CookingInteractable