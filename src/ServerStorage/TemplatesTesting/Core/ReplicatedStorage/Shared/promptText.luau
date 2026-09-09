local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("Prompt")
local label = gui.background.label
local input = gui.background.input
local accept = gui.background.accept
local cancel = gui.background.cancel

local cleanupData

local function cleanup(cancelled)
	gui.Enabled = false
	cleanupData.acceptConnection:Disconnect()
	cleanupData.cancelConnection:Disconnect()
	
	if cancelled then
		cleanupData.cancelCallback()
	end
end

local function promptText(
	text: string,
	placeholder: string,
	onSubmit: (string) -> (), onCancel: () -> ()?
)
	if cleanupData then
		cleanup(true)
		cleanupData = nil
	end

	gui.Enabled = true
	label.Text = text
	input.Text = ""
	input.PlaceholderText = placeholder
	
	cleanupData = {
		acceptConnection = accept.Activated:Once(function()
			onSubmit(input.Text)
			cleanup(false)
			cleanupData = nil
		end),
		
		cancelConnection = cancel.Activated:Once(function()
			cleanup(true)
			cleanupData = nil
		end),
		
		cancelCallback = cancel,
	}
end

return promptText
