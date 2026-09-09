local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage.Events

local sala = {}
sala.__index = sala

setmetatable(sala, Interactable)

function sala.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, sala)
	
	self.model = model
	self.wheel = self:getDefaultWheel()

	self:setAdornee(model.Prompt)
	self:setClickHitbox(model)
	
	self:changeAttribute()
	model.AttributeChanged:Connect(function() self:changeAttribute() end)

	return self
end

function sala:Open()
	remotes.Interactable.salaKaraoke:FireServer(self.model,"Open")
end
function sala:Rent()
	remotes.Interactable.salaKaraoke:FireServer(self.model,"Rent")
end
function sala:Vacate()
	remotes.Interactable.salaKaraoke:FireServer(self.model,"Vacate")
end
function sala:Knok()
	remotes.Interactable.salaKaraoke:FireServer(self.model,"Knok")
end
function sala:LockUnlock()
	remotes.Interactable.salaKaraoke:FireServer(self.model,"LockUnlock")
end
function sala:ChangeStyle(nameStyle)
	remotes.Interactable.salaKaraoke:FireServer(self.model,"ChangeStyle",nameStyle)
end

function sala:StylesPage()
	self.wheel:removePage("Style")
	if self.model:GetAttribute("Owner")==player.UserId then
		if not self.activeChange then
			local folderData = player:FindFirstChild("stylesSalas")
			if folderData then
				self.activeChange = {}
				if #folderData:GetChildren()>1  then
					local stylesPage = self.wheel:addPage("Style")
					for _,v in folderData:GetChildren() do
						stylesPage:addAction(v.Name, self.ChangeStyle, self, v.Name)
					end
				end
				table.insert(self.activeChange, folderData.ChildAdded:Connect(function() self:StylesPage() end))
				table.insert(self.activeChange, folderData.ChildRemoved:Connect(function() self:StylesPage() end))
			end
		else
			local folderData = player:FindFirstChild("stylesSalas")
			if folderData and #folderData:GetChildren()>1  then
				local stylesPage = self.wheel:addPage("Style")
				for _,v in folderData:GetChildren() do
					stylesPage:addAction(v.Name, self.ChangeStyle, self, v.Name)
				end
			end
		end
	elseif self.activeChange then
		for _,v in self.activeChange do v:Disconnect() end
		self.activeChange = nil
	end
end

function sala:changeAttribute()
	self.wheel.page:removeAction('Open')
	self.wheel.page:removeAction('Rent')
	self.wheel.page:removeAction('Knok')
	self.wheel.page:removeAction('Vacate')
	self.wheel.page:removeAction('Lock')
	self.wheel.page:removeAction('Unlock')
	
	self:StylesPage()
	self:RemoveHighlight()
	
	local IsOwner = self.model:GetAttribute("Owner")
	if IsOwner then
		if not self.model:GetAttribute("Block") or IsOwner==player.UserId then
			self.wheel:setQuickAction("Open", self.Open, self)
			self.wheel.page:addAction("Open", self.Open, self)
			if IsOwner==player.UserId then
				self.wheel.page:addAction("Vacate", self.Vacate, self)
				self.wheel.page:addAction(self.model:GetAttribute("Block") and "Unlock" or "Lock", self.LockUnlock, self)
				if not self.model:GetAttribute("IsOpened") then
					self:AddHighlight()
				end
			end
		else
			self.wheel:setQuickAction("Knok", self.Knok, self)
			self.wheel.page:addAction("Knok", self.Knok, self)
		end
	else
		self.wheel:setQuickAction("Rent", self.Rent, self)
		self.wheel.page:addAction("Rent", self.Rent, self)
	end
	
end

return sala
