local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Machine = require(script.Parent.Machine)
local InventoryManager = require(script.Parent.Parent.inventory.InventoryManager)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local Trove = require(ReplicatedStorage.Shared.Trove)

local TOYS = {
	ReplicatedStorage.Assets.Tools.Toy1,
	ReplicatedStorage.Assets.Tools.Toy2,
	ReplicatedStorage.Assets.Tools.Toy3,
	ReplicatedStorage.Assets.Tools.Toy4,
	ReplicatedStorage.Assets.Tools.Toy5,
}

local remotes = ReplicatedStorage.Events
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)

local ToyMachine = {}
ToyMachine.__index = ToyMachine

function ToyMachine.new(model: Model)
	local self = setmetatable({
		model = model,
		_machine = Machine.new(model, 1),
		_trove = Trove.new(),
	}, ToyMachine)

	self._machine:bind(remotes.Machines.ToyPress, function(player, inGreenZone, hookPos)
		self.model.Hook:PivotTo(CFrame.new(hookPos))
		if inGreenZone then
			self._trove:Add(task.spawn(function()
				self:_handleGreenZone(player)
			end))
		else
			self:stop()
		end
	end)
	
	return self
end

function ToyMachine:join(player: Player)
	return self._machine:join(player)
end

function ToyMachine:start()
	self._machine:start()
end

function ToyMachine:stop()
	self._trove:Clean()
	self._machine:stop()
end

function ToyMachine:onStop(callback: (Player) -> ())
	self._machine.stopped:Connect(callback)
end

function ToyMachine:_handle(player: Player, toyName: string)
	InventoryManager.addItem(player, toyName)
	SoundManager:Play(nil, 13697778590, { Volume = 1 }, self.model)
end

function ToyMachine:_getRandomToy()
	return TOYS[math.random(1, #TOYS)]
end

function ToyMachine:_handleGreenZone()
	local toy = self:_getRandomToy()	
	local hook = self.model.Hook

	local toyHandle: Part?

	local getToyModel = hook.Get
	local getModelCFrame = getToyModel:GetPivot()
	local getModelX, getModelZ = getModelCFrame.X, getModelCFrame.Z

	local numberValue = getToyModel.YPosition
	numberValue.Value = getModelCFrame.Y

	local currentEvent = numberValue.Changed:Connect(function()
		getToyModel:PivotTo(CFrame.new(getModelX, numberValue.Value, getModelZ))
	end)
	SoundManager:Play(nil, 13697775987, { Volume = 1 }, self.model)
	local tween0 = TweenService:Create(numberValue, tweenInfo, { Value = numberValue.Value - 1.25 })
	tween0:Play()
	tween0.Completed:Wait()
	tween0:Destroy()

	if toy then
		local parent = hook.Get.Toy

		local handle = toy.Handle:Clone()
		handle.Anchored = true
		handle.CanCollide = false
		handle.Massless = false
		handle.Position = parent.Position
		handle.Size *= 0.5
		handle.Parent = parent

		toyHandle = handle

		local weld = Instance.new('WeldConstraint')
		weld.Part0 = toyHandle
		weld.Part1 = hook.Get.Toy
		weld.Parent = toyHandle
	end

	task.wait(0.5)
	SoundManager:Play(nil, 13697775987, { Volume = 1 }, self.model)
	local tween1 = TweenService:Create(numberValue, tweenInfo, { Value = numberValue.Value + 1.25 })
	tween1:Play()
	tween1.Completed:Wait()
	tween1:Destroy()
	
	currentEvent:Disconnect()

	task.wait(0.2)

	local dropToyPosition = self.model.DropToyPosition.Position

	local hookPositionValue = hook.HookPosition
	hookPositionValue.Value = hook:GetPivot().Position

	local currentEvent = hookPositionValue.Changed:Connect(function()
		hook:PivotTo(CFrame.new(hookPositionValue.Value))
	end)

	local tween = TweenService:Create(hookPositionValue, TweenInfo.new((dropToyPosition - hookPositionValue.Value).Magnitude * 3), {Value = dropToyPosition})
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()

	if toyHandle then
		toyHandle.Anchored = false

		local weld = toyHandle:FindFirstChildWhichIsA('WeldConstraint') do
			if weld then
				weld:Destroy()
			end
		end

		task.delay(3, function()
			toyHandle:Destroy()
		end)
	end

	currentEvent:Disconnect()

	if toy then
		self:_handle(self._machine:getPlayer(), toy.Name)
	end
	
	self:stop()
end

return ToyMachine
