local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local StoreFun = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Stores'))

local remotes = ReplicatedStorage.Events
local cleanup: (() -> ())?

local store = {}
store.__index = store
setmetatable(store, Interactable)

function store.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, store)

	self.model = model
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Reclamar", self.claim, self)
	self.wheel.page:addAction("Reclamar", self.claim, self)
	
	self:setAdornee(model:WaitForChild("Prompt"))
	self:setClickHitbox(model)

	model.AttributeChanged:Connect(function(Attribute)
		if Attribute == 'claimed' then
			if model:GetAttribute('claimed') then
				self:off() else self:on()
			end
		end
	end)
	
	if model:GetAttribute("claimed") then self:off() end
	
	return self
end

function store:claim()
	local store2 = StoreFun:GetStore(self.model)
	if store2 then
		local data = Players.LocalPlayer:FindFirstChild('StoresData')
		data =	data and #data:GetChildren() < 2 and data:FindFirstChild('Simple')
		store2:Update(data)
	end
end

function store:on()
	self:enable()
end

function store:off()
	self:disable()
end

return store
