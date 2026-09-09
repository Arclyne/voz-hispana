local Players = game:GetService("Players")
local Replicated = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local PAndSUi = PlayerGui:WaitForChild("PAndSUi",30)
local Modules = Replicated:WaitForChild("Shared"):WaitForChild("Paint")
local PaintUi = PAndSUi:WaitForChild("Paint")

local Interactable = Replicated:WaitForChild('Client'):WaitForChild('interactable')
local PromptModule = require(Interactable:WaitForChild('Paint'))

local Func = {}

Func.Paint = function()
	local Buttons = PaintUi:WaitForChild("Buttons")
	local Frames = PaintUi:WaitForChild("Frames")
	local Create = Frames:WaitForChild("Create")
	local Load = Frames:WaitForChild("Load")
	local CreateModule = require(Modules.Create)
	local LoadModule = require(Modules.Load)

	for _, B in ipairs(Buttons:GetChildren()) do
		if B:IsA("TextButton") then
			B.MouseButton1Click:Connect(function()
				for _, Frame in ipairs(PaintUi.Frames:GetChildren()) do
					Frame.Visible = (Frame.Name == B.Name)
				end
			end)
		end
	end

	-- Create
	CreateModule.Init(Player,PaintUi,Create)

	-- Load
	task.delay(nil, function()
		LoadModule.Init(Player,Load)
	end)
	
	PaintUi:GetPropertyChangedSignal("Visible"):Connect(function()
		Replicated:FindFirstChild("IsInEvent"):SetAttribute("OpenGuiPaint", PaintUi.Visible or nil)
		if PaintUi.Visible then
			local modelActual:Model = PromptModule:GetModelActual()
			if modelActual then
				local IsOwnerPaint = tonumber(modelActual:GetAttribute("Owner"))
				
				local FrameOpen = false
				
				for _, B in ipairs(Buttons:GetChildren()) do
					if B:IsA("TextButton") then
						
						local IsVisible
						if IsOwnerPaint~=Player.UserId then
							IsVisible = B.Name~="Load"
						else
							IsVisible = B.Name~="Create"
						end
						
						B.Visible = IsVisible
						local Frame = PaintUi:FindFirstChild("Frames"):FindFirstChild(B.Name)
						if Frame then
							Frame.Visible = IsVisible and not FrameOpen
							if IsVisible then
								FrameOpen = true
							end
						end
						
					end
				end
				
			else
				PaintUi.Visible = false
			end
		else
			for _, B in ipairs(Buttons:GetChildren()) do
				if B:IsA("TextButton") then
					local Frame = PaintUi:FindFirstChild("Frames"):FindFirstChild(B.Name)
					if Frame then
						Frame.Visible = false
					end
				end
			end
		end
	end)
	
end

Func.Sculture = function()

end

Func.Paint()
Func.Sculture()