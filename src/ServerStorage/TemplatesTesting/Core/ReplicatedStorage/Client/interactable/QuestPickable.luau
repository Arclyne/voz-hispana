local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Interactable = require(script.Parent.Interactable)

local CollectQuestPickable = ReplicatedStorage
	:WaitForChild("Events")
	:WaitForChild("Quests")
	:WaitForChild("CollectQuestPickable")

local QuestPickable = {}
QuestPickable.__index = QuestPickable

setmetatable(QuestPickable, Interactable)

local function getPromptHolder(model: Instance): BasePart?
	local promptHolder = model:FindFirstChild("PromptHolder", true)

	if promptHolder and promptHolder:IsA("BasePart") then
		return promptHolder
	end

	if model:IsA("Model") then
		if model.PrimaryPart then
			return model.PrimaryPart
		end

		return model:FindFirstChildWhichIsA("BasePart", true)
	end

	if model:IsA("BasePart") then
		return model
	end

	return nil
end

function QuestPickable.new(model: Instance)
	local self = Interactable.new()
	setmetatable(self, QuestPickable)

	self.model = model
	self.busy = false
	self.wheel = self:getDefaultWheel()

	local promptHolder = getPromptHolder(model)

	if not promptHolder then
		warn("[QuestPickable] El objeto no tiene PromptHolder ni ninguna BasePart:", model:GetFullName())
		return self
	end

	self:setAdornee(promptHolder)
	self:setClickHitbox(promptHolder)

	self.wheel:setQuickAction("Recoger", self.collect, self)
	self.wheel.page:addAction("Recoger", self.collect, self)

	return self
end

function QuestPickable:collect()
	if self.busy then
		return
	end

	self.busy = true

	local collectibleId = self.model:GetAttribute("CollectibleId")

	if not collectibleId then
		warn("[QuestPickable] El objeto no tiene CollectibleId:", self.model:GetFullName())
		self.busy = false
		return
	end

	CollectQuestPickable:FireServer(collectibleId)

	self:disable()

	if self.model and self.model.Parent then
		self.model:Destroy()
	end
end

function QuestPickable:onDestroy()
	self:disable()
end

return QuestPickable