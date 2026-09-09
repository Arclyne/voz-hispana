local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.Events
local StoreFun = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Stores'))
local SignalsGame = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SignalsGame"))

local Requests = {"Color3", "boolean"}

local Materal = Enum.Material

function design(model : Model, request)
	if model:HasTag("Interruptor") then
		if typeof(request) == "boolean" then
			model:SetAttribute("IsOn", request)
		end
	else
		local light: Light = model.LightPart:FindFirstChildWhichIsA("Light")
		local lightColor = model:FindFirstChild("LightColor")
		local lightBulb = model:FindFirstChild("Lightbulb")
		if typeof(request) == "Color3" then
			if light then
				light.Color = request
			end
			if lightColor then
				lightColor.Color = request
			end
			if lightBulb then
				lightBulb.Color = request
			end
		else
			model:SetAttribute("IsOn", request)
			if light then
				light.Enabled = request
			end
			if lightColor then
				lightColor.Material = request and Materal.Neon or Materal.SmoothPlastic
			end
			if lightBulb then
				lightBulb.Transparency = request and 0 or .65
				lightBulb.Material = request and Materal.Neon or Materal.Glass
			end
		end
	end
end

function Use(Player : Player, request, model : Model)
	if typeof(model) ~= "Instance" or not table.find(Requests, typeof(request)) then return end
	if model:HasTag("Lamp") then
		if model:GetAttribute("IsToStoreSystem") then
			if not StoreFun.IsActive then return end
			if StoreFun.Added:IsA("House") then
				local Object = StoreFun:GetDecorPlayer(nil, model)
				if not Object or not Object.Disabled then return end
				design(model, request)
				Object:UpdateData(true)
			else
				local store = StoreFun:GetStore(model)
				local Object = store and store.Owner and StoreFun:GetDecorPlayer(store.Owner, model)
				if not Object or not Object.Disabled then return end
				design(model, request)
				Object:UpdateData(true)
			end
		else
			design(model, request)
		end
	elseif model:HasTag("Interruptor") and model:GetAttribute("IsToStoreSystem") then
		if not StoreFun.IsActive then return end
		local store = StoreFun.Added:IsA("House") and StoreFun.Added or StoreFun:GetStore(model)
		if not store then return end
		local DecorChild = store.DecorChild
		if not DecorChild then return end
		
		local ObjectInterruptor = false
		local Luces = {}
		
		for NameModels,Models in DecorChild do
			local _,Data = StoreFun.AddedDecor.Added.verificarExistencia(NameModels)
			if not Data or not Data.tag or not table.find({"Lamp","Interruptor"}, Data.tag) then continue end
			for _,ModelPlace in Models do
				if not ModelPlace.Disabled then continue end
				
				if StoreFun.Added:IsA("Store") then
					if ModelPlace.Disabled == model or Data.tag=="Lamp" then
						design(ModelPlace.Disabled, request)
					else
						continue
					end
					ModelPlace:UpdateData(true)
				else
					if ModelPlace.Disabled == model then
						ObjectInterruptor = ModelPlace
					elseif Data.tag=="Lamp" then
						table.insert(Luces, ModelPlace)
					end
				end
				
			end
		end
		
		if StoreFun.Added:IsA("Store") or not ObjectInterruptor then return end
		local Room = StoreFun.Added:SearchRoom(model)
		if not Room then return end
		
		for _, luz in Luces do
			local InRoom = StoreFun.Added:SearchRoom(luz.Disabled)
			if not InRoom or InRoom.Name ~= Room.Name then continue end
			design(luz.Disabled, request)
			luz:UpdateData(true)
		end
		
		design(model, request)
		ObjectInterruptor:UpdateData(true)
	end
end

remotes.Interactable.Lamp.OnServerEvent:Connect(Use)
SignalsGame:OnEvent("ChangeLamp",design)