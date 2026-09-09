local module = {}
module.__index = module

local RS = game:GetService("ReplicatedStorage")

local RunService = require(RS:WaitForChild("Shared"):WaitForChild("Running"))
local EventCustom = require(RS:WaitForChild("Client"):WaitForChild("Event"))

local function GetColorRGB(Color : Color3)
	return string.format("%d, %d, %d", Color.R * 255, Color.G * 255, Color.B * 255)
end

function module.new(TextLabel : TextLabel, StartCount)
	assert(typeof(TextLabel) == "Instance" and
		(TextLabel:IsA("TextLabel") or TextLabel:IsA("TextButton" or TextLabel:IsA("TextBox"))
		), "Only Label")
	
	local self = setmetatable({
		
		Label = TextLabel,
		formatText = "%d",
		ActualCount = tonumber(StartCount) or 0,
		
		FadeAnimation = .1,
		TimeOut = .1,
		TimeAnimation = 1,
		
		Changed = EventCustom.new(),
		
	}, module)
	
	self:init()
	
	return self
end

function module:SetTimeAnimation(NewTime, NewFade, NewOut)
	if self.IsDestroyed then return end
	self.TimeAnimation = tonumber(NewTime) or self.TimeAnimation
	self.FadeAnimation = tonumber(NewFade) or self.FadeAnimation
	self.TimeOut = tonumber(NewOut) or self.TimeOut
end
function module:SetFormat(format)
	if self.IsDestroyed then return end
	format = typeof(format)=="string" and string.match(format, "%%d") and format
	self.formatText = format or self.formatText
	self.Label.Text = string.format(self.formatText, self.ActualCount)
end
function module:SetAmount(total, NoAnimation)
	total = tonumber(total) or 0
	if self.IsDestroyed or self.ActualCount == total then return end
	if not NoAnimation and
		self.TimeAnimation + self.TimeOut + self.FadeAnimation > 0 then
		self.NewCount = {
			Call = tick(),
			Ascending = total > self.ActualCount,
			Diference = total - self.ActualCount,
			Total = total,
			Actual = self.ActualCount,
		}
		self:Update()
	else
		self.ActualCount = total
		self.Label.Text = string.format(self.formatText, total)
		self.Changed:Fire(Enum.UserInputState.None)
	end
end

function module:Update()
	if self.IsDestroyed or not self.NewCount then return end
	self.Changed:Fire(Enum.UserInputState.Begin)
	self.RunActive = self.RunActive or RunService:AddFunct(function()
		local IsActive = self:Running()
		if IsActive then return end
		self.RunActive = RunService:ElimineFunct(self.RunActive)
		self.ActualCount = self.NewCount and self.NewCount.Total or self.ActualCount
		self.Label.Text = string.format(self.formatText, self.ActualCount)
		self.NewCount = nil
		self.Changed:Fire(Enum.UserInputState.End)
	end)
end

function module:Running()
	if self.IsDestroyed or not self.NewCount then return end
	local TotalAnimation = self.TimeAnimation + self.FadeAnimation + self.TimeOut
	local ElapsedTime = math.min(tick() - self.NewCount.Call, TotalAnimation)
	if ElapsedTime >= self.FadeAnimation then
		if self.TimeAnimation > 0 then
			local anim = self.TimeOut>0 and math.min(ElapsedTime - self.FadeAnimation, self.TimeAnimation) or ElapsedTime - self.FadeAnimation
			local alpha = anim / self.TimeAnimation
			local Count = self.NewCount.Actual + math.round(self.NewCount.Diference * alpha)
			self.ActualCount = Count
			local Color = self.NewCount.Ascending and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
			local FormatModi = anim<1 and string.gsub(self.formatText,"%%d",`<font color="rgb({GetColorRGB(Color)})">%%d</font>`) or self.formatText
			self.Label.Text = string.format(FormatModi, Count)
		elseif self.ActualCount ~= self.NewCount.Total then
			self.ActualCount = self.NewCount.Total
			local Color = self.NewCount.Ascending and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
			local FormatModi = string.gsub(self.formatText,"%%d",`<font color="rgb({GetColorRGB(Color)})">%%d</font>`)
			self.Label.Text = string.format(FormatModi, self.ActualCount)
		end
	end
	if ElapsedTime >= TotalAnimation then return end
	self.Changed:Fire(Enum.UserInputState.Change, ElapsedTime / TotalAnimation)
	return true
end

function module:Cancel()
	if self.IsDestroyed or not self.NewCount then return end
	self.Changed:Fire(Enum.UserInputState.Cancel)
	self.RunActive = RunService:ElimineFunct(self.RunActive)
	self.ActualCount = self.NewCount.Total
	self.Label.Text = string.format(self.formatText, self.ActualCount)
	self.NewCount = nil
end

function module:init()
	if self.IsDestroyed or self.IsActive then return end
	self.IsActive = true
	self.Label.Text = string.format(self.formatText, self.ActualCount)
	self.Label.RichText = true
	self.Label.AncestryChanged:Connect(function(_, Parent)
		if Parent then return end
		self:Destroy()
	end)
end

function module:Destroy()
	if self.IsDestroyed then return end
	self:Cancel()
	self.Changed:Destroy()
	table.clear(self)
	self.IsDestroyed = true
end

return module