local Player = game:GetService("Players").LocalPlayer
local GuiService = game:GetService("GuiService")
local Tool = script.Parent
local RemoteEvent = Tool:WaitForChild("RemoteEvent")
local Mouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()

local function CastMouseRay()
	local mousePosition = Vector2.new(Mouse.X, Mouse.Y + GuiService:GetGuiInset().Y) 
	local Viewport = workspace.CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local ray = Ray.new(Viewport.Origin, Viewport.Direction * 1000)

	local partHit, endPosition = workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character})
	return endPosition	
end

Tool.Equipped:Connect(function()
	Tool.Handle.Sound:Play()
end)

Tool.Activated:Connect(function()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	RemoteEvent:FireServer(CastMouseRay())

	task.wait(3)
	Tool.Enabled = true
end)