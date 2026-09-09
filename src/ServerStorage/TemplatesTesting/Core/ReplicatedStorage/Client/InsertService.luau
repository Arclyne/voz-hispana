if not game:GetService("RunService"):IsServer() then return function() return false end end
local InsertService = game:GetService('InsertService')
local HoldToClear = 60 * 5
local HoldToUpdate = 10

local Cache = {}
local InProcess = {}
local UpdateInProcess = {}
local SetInProcess = {}


local function GetElapsedTime(timee)
	local now = DateTime.now().UnixTimestampMillis
	timee = tonumber(timee) or now
	return (now - timee) / 1000
end
local function elimineScrips(item : Instance)
	if item then
		for _,v in item:GetDescendants() do
			if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
				v:Destroy()
			end
		end
	end
end
local function GetItem(item : Model, IsA)
	if item then
		local object = item:GetChildren()[1]
		if object then
			object = object:Clone()
			elimineScrips(object)
		end
		item:Destroy()
		return object
	end
end
local function GetIsAModel(item : Instance, IsA)
	return item and (not IsA or item:IsA(IsA)) and item:Clone()
end

local module = {}
function module.LoadAsset(AssetId, IsA)
	if typeof(AssetId) ~= "number" then return end
	local AssetLoaded = Cache[AssetId]
	if AssetLoaded then
		if AssetLoaded.Item then
			AssetLoaded.DateBusqueda = DateTime.now().UnixTimestampMillis
			return GetIsAModel(AssetLoaded.Item, IsA)
		elseif GetElapsedTime(AssetLoaded.DateBusqueda) >= HoldToUpdate then
			Cache[AssetId] = nil
			return module.LoadAsset(AssetId)
		end
	end
	local Process = InProcess[AssetId]
	if Process then
		Process:Wait()
		local Cached = Cache[AssetId]
		return GetIsAModel(Cached and Cached.Item, IsA)
	end
	local bin = Instance.new("BindableEvent")
	InProcess[AssetId] = bin.Event
	local nice, Model = pcall(InsertService.LoadAsset,InsertService,AssetId)
	local Item = nice and GetItem(Model)
	Cache[AssetId] = {
		Item = Item,
		DateBusqueda = DateTime.now().UnixTimestampMillis
	}
	bin:Fire()
	bin:Destroy()
	InProcess[AssetId] = nil
	return GetIsAModel(Item, IsA)
end
function module.UpdateAsset(key, AssetId, action, IsA)
	assert(typeof(key) == "string" and typeof(action) == "function", "Datos erroneos")
	local UpdateLast = UpdateInProcess[key]
	if UpdateLast then task.cancel(UpdateLast) end
	local NewUpdate
	NewUpdate = task.spawn(function()
		action(module.LoadAsset(AssetId, IsA))
		if UpdateInProcess[key] == NewUpdate then
			UpdateInProcess[key] = nil
		end
	end)
	UpdateInProcess[key] = NewUpdate
end
function module.SetAsset(key, AssetId, action, IsA)
	assert(typeof(key) == "string" and typeof(action) == "function", "Datos erroneos")
	local SetLast = SetInProcess[key]
	if SetLast then
		if not SetLast.IsInProcess then
			SetLast.action = action
			return
		else
			task.cancel(SetLast.IsInProcess)
		end
	end
	local SetNew = {action = action}
	SetInProcess[key] = SetNew
	local Item = module.LoadAsset(AssetId, IsA)
	if SetInProcess[key] ~= SetNew then return end
	SetNew.IsInProcess = task.spawn(function()
		SetNew.action(Item)
		if SetInProcess[key] == SetNew then
			SetInProcess[key] = nil
		end
		SetNew.IsInProcess = nil
	end)
end

task.spawn(function()
	while task.wait(HoldToUpdate / 2) do
		for AssetId, Date in Cache do
			if GetElapsedTime(Date.DateBusqueda) >= HoldToClear then
				if Date.Item then Date.Item:Destroy() end
				Cache[AssetId] = nil
			end
		end
	end
end)
return module