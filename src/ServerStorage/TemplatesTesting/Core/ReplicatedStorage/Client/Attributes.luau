local module = {}
module.__index = module
local debris = game:GetService('Debris')
local FolderClients = game:GetService("ReplicatedStorage"):WaitForChild("Client")
local disconnect = require(FolderClients:WaitForChild('Disconnects'))
local EventCustom = require(FolderClients:WaitForChild("Event"))

function module.new(Metatable)
	local self = setmetatable({
		self = typeof(Metatable)=='table' and Metatable or {},
		--InstanceChanged = Instance.new('BindableEvent'),
		Attributes = {},
		actives = {},
	}, module)
	
	self.self.AttributeChanged = EventCustom.new()
	self:init()
	
	return self
end

function module:init()
	
	function self.self.GetAttributeChangedSignal(_,NameAttribute)
		if self.IsDestroyed then return warn("Disabled") end
		if typeof(NameAttribute)~="string" or #NameAttribute <= 0 then
			warn('Añade un nombre en formato string.')
		else
			if self.self[NameAttribute]~=nil and not self.Attributes[NameAttribute] then
				return warn('No puedes obetener el cambio de una propiedad ya existente.')
			end
			if not self.Attributes[NameAttribute] then
				self.Attributes[NameAttribute] = EventCustom.new()
			end
			return self.Attributes[NameAttribute]
		end
	end
	function self.self.SetAttribute(_,NameAttribute,Valor)
		if self.IsDestroyed then return warn("Disabled") end
		if typeof(NameAttribute)~="string" then
			warn('Añade un nombre en formato string.')
		elseif self.self[NameAttribute]~=nil and not self.Attributes[NameAttribute] then
			warn('No puedes reemplazar un valor ya existente')
		else
			if not self.Attributes[NameAttribute] then
				self.Attributes[NameAttribute] = EventCustom.new()
			end
			if self.self[NameAttribute]~=Valor then
				self.self[NameAttribute] = Valor
				self.self.AttributeChanged:Fire(NameAttribute)
				self.Attributes[NameAttribute]:Fire()
			end
		end
	end
	function self.self.GetAttribute(_,NameAttribute)
		if self.IsDestroyed then return warn("Disabled") end
		if self.Attributes[NameAttribute] then
			return self.self[NameAttribute]
		end
	end
	function self.self.RemoveAttribute(_,...)
		if self.IsDestroyed then return warn("Disabled") end
		for _,NameAttribute in {...} do
			if typeof(NameAttribute)~="string" then
				warn('Añade un nombre en formato string.')
			elseif self.Attributes[NameAttribute] then
				self.Attributes[NameAttribute]:Destroy()
				self.Attributes[NameAttribute] = nil
				self.self[NameAttribute] = nil
			else
				warn("no existe este attributo")
			end
		end
	end
	
	table.insert(self.actives, self.self:GetAttributeChangedSignal("Deleted"):Connect(function() self:Destroy() end))
	
end

function module:Destroy()
	if self.IsDestroyed then return end
	self.actives = disconnect.All(self.actives)
	for _,event in self.Attributes do event:Destroy() end
	self.self.AttributeChanged:Destroy()
	table.clear(self)
	self.IsDestroyed = true
end

return module
