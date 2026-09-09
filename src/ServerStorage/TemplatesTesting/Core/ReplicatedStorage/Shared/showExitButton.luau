local Players = game:GetService("Players")
local player = Players.LocalPlayer

if not player.Character or not player.Character.Parent then
	player.CharacterAdded:Wait()
end

local gui = Players.LocalPlayer.PlayerGui:WaitForChild("ExitUI")
local button = gui:WaitForChild("Button")
local connection: RBXScriptConnection?

local function cleanup()
	if connection then
		connection:Disconnect()
		connection = nil
	end
	
	gui.Enabled = false
end

local function showExitButton(callback: () -> ())
	cleanup()

	gui.Enabled = true
	connection = button.Activated:Connect(function()
		cleanup()
		callback()
	end)
	
	return cleanup
end

return showExitButton
