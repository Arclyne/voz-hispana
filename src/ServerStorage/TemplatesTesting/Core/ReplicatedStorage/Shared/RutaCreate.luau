local module = {}
module.__index = module

local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local Running = require(RS:WaitForChild("Shared"):WaitForChild("Running"))
local Disconnect = require(RS:WaitForChild("Client"):WaitForChild("Disconnects"))
local EventCustom = require(RS:FindFirstChild("Client"):WaitForChild("Event"))
local PathFind = require(RS:FindFirstChild("Client"):WaitForChild("CreatePath"))

function module.new(Point : Vector3)
	
	assert(typeof(Point) == "Vector3", "Ony vector 3")
	
	local self = setmetatable({}, module)
	
	self.Destino = Point
	self.Enabled = false
	
	self.Actived = EventCustom.new()
	self.Arrived = EventCustom.new()
	
	self.Paths = {}
	self.MinDistance = 10
	
	return self
end

function module:enable()
	if self.Enabled or self:DistanceToObject() <= self.MinDistance then return end
	self.Enabled = {}
	self.Actived:Fire(not not self.Enabled)
	self.RunActive = Running:AddFunct(function(...) self:Running(...) end)
end

function module:DistanceToObject()
	return Player.Character and (Player.Character:GetPivot().Position - self.Destino).Magnitude or math.huge
end

function module:decore()
	if not self.Enabled or not Player.Character then
		self.CreatedPath = nil
		return
	end
	
	local path = PathFind(Player.Character:GetPivot().Position, self.Destino)
	
	if not path then
		self.CreatedPath = nil
		return
	end
	
	local countPath = #path
	local TotalPathLast = #self.Paths
	
	for index = math.max(TotalPathLast, countPath), 1, -1 do
		if index > countPath then
			local part = self.Paths[index]
			if not part then continue end
			part:Destroy()
			table.remove(self.Paths, table.find(self.Paths, part))
		elseif index > TotalPathLast then
			local created = Instance.new("Part")
			created.CanCollide = false
			created.Transparency = 1
			created.Anchored = true
			created.Size = Vector3.new(.5,.5,.5)
			local position = path[#self.Paths + 1].Position
			local attatchemnt = Instance.new("Attachment", created)
			attatchemnt.CFrame = CFrame.new(0,.02,0) * CFrame.Angles(0,0,math.rad(90))
			local last = self.Paths[#self.Paths]
			local look
			if last then
				local Beam = Instance.new("Beam", created)
				Beam.Texture = "rbxassetid://11552476728"
				Beam.TextureLength = .7
				Beam.LightEmission = 1
				Beam.Attachment0 = last:FindFirstChild("Attachment")
				Beam.Attachment1 = attatchemnt
				look = (position - last.Position).Unit
			else
				look = (path[#self.Paths + 2].Position - position).Unit
			end
			created.CFrame = CFrame.lookAt(position, position + look)
			created.Parent = workspace
			table.insert(self.Paths, created)
		else
			local part = self.Paths[index]
			if not part then continue end
			part.Position = path[index].Position
		end
	end

	self.TickElapsed = tick()
	self.CreatedPath = nil
end
function module:clearDecore()
	
	if self.CreatedPath then
		task.cancel(self.CreatedPath)
		self.CreatedPath = nil
	end
	
	for _,v in self.Paths do
		v:Destroy()
	end
	
	table.clear(self.Paths)
end

function module:Running()
	if not self.Enabled then return end
	
	if self:DistanceToObject() <= self.MinDistance then
		self.Arrived:Fire()
		return self:disable()
	end
	
	local now = tick()
	if (not self.TickElapsed or now - self.TickElapsed >= .7) and not self.CreatedPath then
		self.CreatedPath = task.spawn(self.decore, self)
	end
end

function module:disable()
	if not self.Enabled then return end
	self.RunActive = Running:ElimineFunct(self.RunActive)
	self.Enabled = Disconnect.All(self.Enabled)
	self.TickElapsed = nil
	self:clearDecore()
	self.Actived:Fire(not not self.Enabled)
end


return module
