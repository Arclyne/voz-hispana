local module = {}
module.__index = module
function desactive(active, ...)
	local total = {...}
	if #total > 0 then
		for _, value in total do
			if active[value] then
				active[value]:Disconnect()
				active[value] = nil
			end
		end
	else
		for _,v:RBXScriptConnection in active do
			v:Disconnect()
		end
		table.clear(active)
	end
end
local function IsGuiBase(Object)
	return typeof(Object)=="Instance" and Object:IsA("GuiBase")
end
local function ConvertToVector(udim:UDim2,SizeBase:Vector2)
	return Vector2.new(
		(SizeBase.X * udim.X.Scale) + udim.X.Offset,
		(SizeBase.Y * udim.Y.Scale) + udim.Y.Offset
	)
end
local function GetChilds(AbsoluteSize,Objects,Data)
	Data = typeof(Data)=="table" and Data or {}
	for _,Child:Frame in Objects:GetChildren() do
		if IsGuiBase(Child) and not Child:IsA("ScreenGui") then
			local list = {
				Size = ConvertToVector(Child.Size, AbsoluteSize) / AbsoluteSize,
				Base = Child,
			}
			list.Position = (ConvertToVector(Child.Position, AbsoluteSize) / AbsoluteSize) -- (list.Size * Child.AnchorPoint)
			Child.Position = UDim2.fromScale(list.Position.X, list.Position.Y)
			table.insert(Data,list)
		elseif Child:IsA("Folder") then
			GetChilds(AbsoluteSize,Child,Data)
		end
	end
	return Data
end
function module.new(Main, Base)
	assert(IsGuiBase(Base) and IsGuiBase(Main) and Base.Parent==Main, "Datos erroneos")
	local self = setmetatable({
		actives = {},
		Base = Base,
		Main = Main,
	}, module)
	self:init()
	return self
end
function module:Adjust()
	if not self.IsLoaded or not self.AdjustData or self.IsDestroyed then return end
	local LastAbsoluteSize = (self.AbsoluteSize * self.ObjectSize):Floor()
	local NewAbsoluteSize = self.Main.AbsoluteSize:Floor()
	local AbsoluteSize = (LastAbsoluteSize / NewAbsoluteSize)
	local DirefenceX = (NewAbsoluteSize.X - LastAbsoluteSize.X) / NewAbsoluteSize.X
	local DirefenceY = (NewAbsoluteSize.Y - LastAbsoluteSize.Y) / NewAbsoluteSize.Y
	for _, Gui:{Base : Frame} in self.Childs do
		local AdjustSize = Gui.Size * AbsoluteSize
		local IsBase = Gui.Base == self.Base
		local AumentarX = IsBase and DirefenceX or 0
		local AumentarY = IsBase and DirefenceY or 0
		Gui.Base.Size = UDim2.fromScale(
			AdjustSize.X + AumentarX,
			AdjustSize.Y + AumentarY
		)
		local PosiX = Gui.Position.X
		local PosiY = Gui.Position.Y
		local AdjustX = PosiX > .5
			and (1 - ((1 - PosiX) * AbsoluteSize.X))
			or (PosiX * AbsoluteSize.X) + (DirefenceX * Gui.Base.AnchorPoint.X)
		local AdjustY = PosiY > .5
			and (1 - ((1 - PosiY) * AbsoluteSize.Y))
			or (PosiY * AbsoluteSize.Y) + (DirefenceY * Gui.Base.AnchorPoint.Y)
		Gui.Base.Position = UDim2.fromScale(
			AdjustX ,
			AdjustY
		)
	end
end
function module:GetAdjust()
	if not self.IsLoaded or self.AdjustData or self.IsDestroyed then return end
	if self.Main.Parent then
		self.WorldObject = IsGuiBase(self.Main.Parent) and self.Main.Parent or workspace.CurrentCamera
		self.WorldSize = self.WorldObject:IsA("Camera") and self.WorldObject.ViewportSize or self.WorldObject.AbsoluteSize
		self.ObjectSize = Vector2.new(1,1)
		self.AbsoluteSize = self.Main.AbsoluteSize
		self.Childs = GetChilds(self.AbsoluteSize,self.Main)
		self.AdjustData = true
		self:Adjust()
	end
end
function module:enabled()
	if not self.IsLoaded or self.IsDestroyed or self.actives["ChangeAbsoluteSize"] then return end
	self.actives["ChangeAbsoluteSize"] = self.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if not self.AdjustData then return end
		self.ObjectSize = (self.WorldObject:IsA("Camera") and self.WorldObject.ViewportSize or self.WorldObject.AbsoluteSize) / self.WorldSize
		self:Adjust()
	end)
end
function module:disabled()
	if self.IsDestroyed or not self.actives["ChangeAbsoluteSize"] then return end
	desactive(self.actives,"ChangeAbsoluteSize")
	if not self.Main:IsA("ScreenGui") then
		local AbsoluteSize = (self.AbsoluteSize/self.WorldSize)*self.ObjectSize
		self.Main.Size = UDim2.fromScale(AbsoluteSize.X, AbsoluteSize.Y)
	end
end
function module:init()
	if self.IsLoaded or self.IsDestroyed then return end
	self.IsLoaded = true
	self:GetAdjust()
	table.insert(self.actives, self.Main.AncestryChanged:Connect(function(_, Parent)
		if not Parent then
			self:Destroy()
		elseif not self.AdjustData then
			self:GetAdjust()
		end
	end))
end
function module:Destroy()
	if self.IsDestroyed then return end
	desactive(self.actives)
	table.clear(self)
	self.IsDestroyed = true
end
return module