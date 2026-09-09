local module = {}
module.__index = module

local RS = game:GetService("ReplicatedStorage")
local ClientFolder = RS:WaitForChild("Client")

local mathh = require(ClientFolder:WaitForChild("Math"))
local animator = require(ClientFolder:WaitForChild("Animator"))
local EventCustom = require(ClientFolder:WaitForChild("Event"))

local pathFind = require(RS:WaitForChild("Client"):WaitForChild("CreatePath"))
local Customize = require(script:WaitForChild('CustomizeSettings'))

local IsA = "NPC"
module.FormatPath = require(script:WaitForChild("FormatPathNpc"))

function Desactive(list, ...)
	local all = {...}
	if #all > 0 then
		for _,v in all do
			if list[v] then
				list[v]:Disconnect()
				list[v] = nil
			end
		end
	else
		for _,v in list do
			v:Disconnect()
		end
		table.clear(list)
	end
end

function module.new(model)
	assert(typeof(model)=="Instance" and model:IsA("Model"), "No es un objeto...")
	local self = setmetatable({
		
		IsActive = false,
		model = model,
		Humanoid = model:FindFirstChild("Humanoid"),
		
	}, module)
	
	self.StateChanged = EventCustom.new()
	self.State = "idle"
	
	self:init()
	
	return self
end
---------------------
function module:GetState()
	return self.State
end
function module:SetState(name)
	assert(typeof(name)=="string", "Invalid argument.")
	if table.find(Customize.witheListStates, name) and self.State ~= name then
		self.State = name
		self.StateChanged:Fire(name)
	end
end

function module:CancelAction()
	if self.Calculando then
		task.defer(task.cancel,self.Calculando)
		self.Calculando = nil
	end
	
	if self.CallBack then
		task.defer(self.CallBack,"Cancel")
		self.CallBack = nil
	end
	
	if self.InAction then self.InAction.Canceled = true end
	
	self:SetState("idle")
end

function module:GetSizeCharacter()
	local piernaPartes = {"Head","UpperTorso","LowerTorso","LeftLowerLeg","LeftFoot","LeftUpperLeg"}
	local TamanoBody = 0
	for _,detail in piernaPartes do
		local Part:BasePart = self.model:FindFirstChild(detail)
		if Part then
			TamanoBody += Part.Size.Y
		end
	end
	return TamanoBody
end

function module:PivotTo(CFramee : CFrame)
	if not self.model then return end
	self.model:PivotTo(CFramee:ToWorldSpace(CFrame.new(0,self.SizeY/2,0)))
end

function module:GetPivot()
	return self.model:GetPivot():ToWorldSpace(CFrame.new(0,-self.SizeY/2,0))
end

function module:WalkTo(Position : CFrame | Vector3, action, run)
	Position = typeof(Position)=="Vector3" and CFrame.new(Position) or typeof(Position)=="CFrame" and Position
	action = typeof(action)=="function" and action or nil
	if not Position then return end
	self:CancelAction()
	self.CallBack = action
	self.Calculando = task.spawn(function()
		local StartPosition = self.model:GetPivot()
		local busqueda : {PathWaypoint} = pathFind(StartPosition.Position, Position.Position)
		local NameRunning = run and 'run' or 'walk'
		if busqueda and #busqueda>0 then
			local list1 = {}
			for index, path in busqueda do
				local nextt = busqueda[index+1]
				local list = {
					Position = index == 1 and self:GetPivot().Position or path.Position,
					duracion = nextt and mathh.CalculateTime(path.Position, nextt.Position, Customize.WalkSpeed[NameRunning]),
				}
				table.insert(list1, list)
			end
			self.InAction = {
				State = NameRunning,
				stateSave = {},
				StartTime = os.clock(),
				Path = list1,
				EndCFrame = Position,
				Rotation = mathh.GetTimeRotation(list1[#list1-1],list1[#list1 - 2] or StartPosition,Position),
				duracion = mathh.TableSum(list1, 'duracion'),
				action = action,
			}
			self:SetState(NameRunning)
		elseif action then
			task.defer(action,"Error")
		end
		self.CallBack = nil
		self.Calculando = nil
	end)
end
function module:RunTo(Position : CFrame | Vector3, action)
	self:WalkTo(Position, action, true)
end
function module:HoldTo(TimeHold, action)
	assert(typeof(TimeHold)=="number","Incorrect params.")
	action = typeof(action)=="function" and action or nil
	self:CancelAction()
	self.CallBack = action
	self.Calculando = task.delay(0.02, function()
		local list = {
			State = "action",
			stateSave = {},
			StartTime = os.clock(),
			duracion = TimeHold,
			action = action,
		}
		self:SetState(list.State)
		self.InAction = list
		self.CallBack = nil
		self.Calculando = nil
	end)
end
---------------------
function module:Decore(Decoration : {})
	Decoration = typeof(Decoration) == "table" and Decoration
	local Head:BasePart = self.model:FindFirstChild("Head")
	local face:Decal = not Head:FindFirstChild("FaceControls") and Head:FindFirstChild("Face")
	if face then face.Texture = string.format('rbxassetid://%d', Decoration and Decoration.face or Customize.face) end
	local BC:BodyColors = self.model:FindFirstChildOfClass('BodyColors') or Instance.new('BodyColors', self.model)
	local color = Decoration and Decoration.SkinColor or Customize.SkinColor[math.random(1,#Customize.SkinColor)]
	for _,name in Customize.PartsBody do BC[name] = color end
end

function module:IsA(n) return n == IsA end

function module:init()
	if self.IsActive then return end
	self.IsActive = {}
	self.animator = animator.new(self.model)
	self.animator:PlayAnimation("idle")
	table.insert(self.IsActive, self.model.AncestryChanged:Connect(function(_,parent)
		if parent then return end
		self:destroy()
	end))
	table.insert(self.IsActive, self.Humanoid.ApplyDescriptionFinished:Connect(function()
		self.SizeY = self:GetSizeCharacter()
	end))
	table.insert(self.IsActive, self.Humanoid.Died:Connect(function() self:destroy() end))
	self.SizeY = self:GetSizeCharacter()
end
function module:destroy()
	if not self.IsActive then return end
	task.defer(Desactive, self.IsActive)
	self.IsActive = false
	self:SetState("dead")
	self.animator:PlayAnimation()
end

return module
