local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local StoreFun = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Stores'))

local remotes = ReplicatedStorage.Events
local cleanup: (() -> ())?

local product = {}
product.__index = product
setmetatable(product, Interactable)

function product.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, product)

	self.model = model
	self.wheel = self:getDefaultWheel()
	
	self:setAdornee(model:WaitForChild("Prompt"))
	self:setClickHitbox(model)

	model.AttributeChanged:Connect(function(Attribute)
		if Attribute == 'Owner' then
			self:OwnerActions()
		end
	end)
	
	if model:GetAttribute("Owner") then
		self:OwnerActions()
	else
		self:off()
	end
	
	return self
end

function product:OwnerActions()
	if self.model:GetAttribute("Owner") then
		local IsOwner = Players.LocalPlayer.UserId == self.model:GetAttribute("Owner")
		self.wheel:setQuickAction(IsOwner and 'Editar' or 'Purchase',self.ActionPurchase, self)
		self.wheel.page:removeAction(IsOwner and 'Purchase' or 'Editar')
		self.wheel.page:addAction(IsOwner and 'Editar' or 'Purchase',self.ActionPurchase, self)
	else
		self:off()
	end
end

function product:ActionPurchase() StoreFun:AccionarCompras(self.model) end

function product:on()
	self:enable()
end

function product:off()
	self:disable()
end

return product
