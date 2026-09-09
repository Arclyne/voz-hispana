local module = {}
module.__index = module

local RunS = game:GetService('RunService')

local IsClient = RunS:IsClient()
local Players = game:GetService("Players")
local LocalPlayer:Player = IsClient and Players.LocalPlayer or nil

local folderPlataformas = workspace:FindFirstChild("ButtonVipMoney") or IsClient and workspace:WaitForChild("ButtonVipMoney")
if not folderPlataformas then
	folderPlataformas = Instance.new("Folder")
	folderPlataformas.Name = "ButtonVipMoney"
	folderPlataformas.Parent = workspace
end

local folderBilletes = script:WaitForChild("Billetes")

module.Proccess = {}

function module.new(model : Model)
	local self = setmetatable({
		Tag = 'PlantillaExample',
		model = model,
		WhiteList = {"Buy"},
		cantidad = 12,
		billetes = {},
		
		AnimationTime = 4,
		
		plataforma = folderPlataformas:FindFirstChild(model:GetAttribute("Key") or ""),
		
		IdProduct = 3608698947,
		
	},module)
	
	self.Tubo = self.plataforma and self.plataforma:WaitForChild("TuboNightclub")
	self.OriginalPosition = self.Tubo and self.Tubo:GetPivot()
	self.PositionBillete = self.plataforma and self.plataforma:WaitForChild("InitialPositionMoney"):GetPivot()
	self.BaseSize = self.plataforma and self.plataforma:WaitForChild("BaseSize")
	
	return self
end


local function CalculateTime(position1:Vector3, position2:Vector3, velocity)
	local distance = (position1 - position2).Magnitude
	return distance / velocity
end

local function BouncePosition(startCF: CFrame, endCF: CFrame, t: number)
	local distance = (endCF.Position - startCF.Position).Magnitude
	local bounces = math.clamp(math.floor(distance / 8), 2, 6)
	local maxHeight = math.clamp(distance * 0.35, 2, 10)
	local interpolatedCF = startCF:Lerp(endCF, t)
	local bounceIndex = math.min(math.floor(t * bounces), bounces - 1)
	local localT = (t * bounces) % 1
	local floorY = endCF.Y
	local height = maxHeight * (0.55 ^ bounceIndex)
	local arcHeight = 4 * localT * (1 - localT) * height
	local baseY = bounceIndex == 0 and (1 - localT) * startCF.Y + localT * floorY or floorY
	local finalY = baseY + arcHeight
	return CFrame.new(interpolatedCF.X, finalY, interpolatedCF.Z) * (interpolatedCF - interpolatedCF.Position)
end

function module:createBillete()
	if IsClient or not self.Occupant then return end
	
	local clone : Model = folderBilletes:GetChildren()[math.random(1, #folderBilletes:GetChildren())]:Clone()
	clone:PivotTo(self.PositionBillete)
	
	local Size = self.BaseSize.Size / 2
	local PositionEnd = self.BaseSize.CFrame:ToWorldSpace(CFrame.new(
		math.random(-Size.X, Size.X),
		Size.Y,
		math.random(-Size.Z, Size.Z)
		))
	
	PositionEnd = CFrame.new(self.BaseSize:GetClosestPointOnSurface(PositionEnd.Position)) *
		CFrame.new(0,clone:GetExtentsSize().Y/2,0) *
		CFrame.Angles(0,math.rad(math.random(0,360)),0)
	
	local list = {

		model = clone,
		status = tick(),
		len = CalculateTime(self.PositionBillete.Position, PositionEnd.Position, 30),
		PositionEnd = PositionEnd,

	}
	
	table.insert(self.Occupant.droped, list)

	clone.Parent = workspace
	
	clone:GetPropertyChangedSignal("Parent"):Connect(function()
		if not clone.Parent and list.IsDone then
			
			local Owner = clone:GetAttribute("PlayerCleaning")
			if not Owner then return end
			
			local Player : Player = Players:GetPlayerByUserId(Owner)
			if not Player then return end
			
			self.cobros.Give(Player, {Coins = 10}, true)
		end
	end)

end


function module:DropMoneys()
	if IsClient or not self.Occupant then return end
	local now = tick()

	local lights = self.Tubo:FindFirstChild("Lights"):GetChildren()
	table.sort(lights, function(a,b) return tonumber(a.Name) < tonumber(b.Name) end)
	
	if self.Occupant.Timeline==self.AnimationTime then
		if not self.Occupant.droped then self.Occupant.droped = now end
		if #self.Occupant.droped < self.Occupant.amount then
			local ElapsedTime = math.min(1, (now - self.Occupant.timeCold) / self.Occupant.NextBillete)
			local total = math.ceil((#lights + 1) * ElapsedTime)
			for index, light : BasePart in lights do
				light.Material = Enum.Material[index < total and "Neon" or "Plastic"]
			end
			if ElapsedTime >= 1 then
				self.Occupant.NextBillete = math.random(4, 10) / 10
				self.Occupant.timeCold = tick()
				task.defer(self.createBillete, self)
			end
		end
	else
		local par = DateTime.now().UnixTimestampMillis % 2
		for index, light : BasePart in lights do
			light.Material = Enum.Material[index%2 == par and "Neon" or "Plastic"]
		end
	end
	
	local Acabado = true
	
	for _, billete in self.Occupant.droped do
		local ElapsedTime = math.min((now - billete.status) / billete.len, 1)
		
		billete.model:PivotTo(
			BouncePosition(
				self.PositionBillete,
				billete.PositionEnd,
				ElapsedTime
			)
		)
		
		if ElapsedTime >= 1 then
			if not billete.IsDone then
				billete.IsDone = true
				billete.model:AddTag("Pee")
			end
		else
			Acabado = false
		end
	end
	
	return Acabado
end

function module:running(delta)
	if not self.Occupant then return end
	self.Occupant.Timeline = math.clamp(self.Occupant.Timeline + (delta * (#self.Occupant.droped < self.Occupant.amount and 1 or -1)),0,self.AnimationTime)
	self.Tubo:PivotTo(self.OriginalPosition:Lerp(self.OriginalPosition - Vector3.new(0,self.Tubo:GetExtentsSize().Y,0), self.Occupant.Timeline / self.AnimationTime))
	return self:DropMoneys() and self.Occupant.Timeline <= 0
end

function module:stop()
	if IsClient or not self.Occupant then return end
	self.disconnect.Only(self.actives,"running")
	self.Tubo:PivotTo(self.OriginalPosition)
	self.Occupant = nil
	for index, light : BasePart in self.Tubo:FindFirstChild("Lights"):GetChildren() do
		light.Material = Enum.Material.Plastic
	end
end

function module:AddEvent(Player:Player)
	if not IsClient and Player then
		if self.Occupant then
			self.Occupant.amount += self.cantidad
		else
			local list = {}
			list.droped = {}
			list.amount = self.cantidad
			list.Timeline = 0
			
			list.timeCold = tick()
			list.NextBillete = math.random(6, 14) / 10
			
			self.actives.running = RunS.Heartbeat:Connect(function(...)
				if self:running(...) then
					self:stop()
				end
			end)
			
			self.Occupant = list
		end
	end
end

function module:Buy(Player:Player)
	if IsClient then
		self:Fire(self.model,"Buy")
	elseif Player and not self.Proccess[Player] then
		local mark = self.Monetization:MarkPrompt(Player,self.IdProduct,Enum.InfoType.Product)
		if not mark then return warn("ya hay una compra en proceso") end
		
		mark:BindToClose(function(_,_,state)
			self.Proccess[Player] = nil
			if state == "Success" then
				self:AddEvent(Player)
			end
		end)
		
		self.Proccess[Player] = true
		self.Monetization.MPS:PromptProductPurchase(Player, self.IdProduct)
	else
		warn("ya estas procesando la compra")
	end
end

function module:enabled()
	if self.actives then return end
	self.actives = {}
	
	if not IsClient then
		for index, light : BasePart in self.Tubo:FindFirstChild("Lights"):GetChildren() do
			light.Material = Enum.Material.Plastic
		end
	end
	
end

function module:disabled()
	if not self.actives then return end
	self.actives = self.disconnect.All(self.actives)
end

return module
