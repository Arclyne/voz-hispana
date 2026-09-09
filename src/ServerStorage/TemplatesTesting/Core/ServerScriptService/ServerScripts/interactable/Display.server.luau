local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bindToTag = require(ReplicatedStorage.Shared.bindToTag)
local Karaoke = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Karaoke'))

local DEFAULT_VIDEO = "YouBlox"

local remotes = ReplicatedStorage.Events

bindToTag("Display", function(model)
	model:SetAttribute("Video", DEFAULT_VIDEO)
end)

remotes.Interactable.Display.OnServerEvent:Connect(function(player, model: Model, video: string | boolean)
	if typeof(video) == "string" then
		if video == 'KARAOKE' then
			local InfoModel = Karaoke.TvKaraoke:FindTV(model,true)
			if not InfoModel then InfoModel = Karaoke.TvKaraoke:Added(model) end
			if InfoModel then
				InfoModel:UpdateOwner()
				Karaoke.Commands:Fire(player,4,InfoModel.Model)
			end
		elseif video == 'AgregarAKaraoke' then
			Karaoke.TvKaraoke:Added(model)
		else
			model:SetAttribute("Video", video)
			model:SetAttribute("On", true)
		end
	elseif typeof(video) == "boolean" then
		model:SetAttribute("On", video)
	end
end)
