-- ReplicatedStorage/Dialogs/Shopkeeper.lua
local RS = game:GetService("ReplicatedStorage")
local Commands = require(RS:WaitForChild("Shared"):WaitForChild("Commands"))

local KaraokeRoomRent = {
	displayName = "Alquier de salas",
	actionName = "Hablar",
	start = 1,
	nodes = {
		[1] = {
			text = "¡Buenos días! ¿Qué necesitas?",
			responses = {
				{ text = "Quiero alquilar una sala de karaoke.", event = "OpenShop" },
				{ text = "Quiero comprar stilos de la sala de karaoke.", event = "StyleSala" },
				{ text = "¿Tienes encargos?", next = 2 },
				"¡Buenos días, hasta luego!"
			},
			-- si eliges "Solo mirando." (3ª opción), cerramos:
			next = function(respIdx)
				if respIdx == 3 then return "__CLOSE__" end
			end
		},
		[2] = {
			text = "Sí, necesito que limpies la suciedad.",
			responses = {
				{ text = "Acepto.", event = "StartQuest:Ratas" },
				{ text = "Paso.", next = "__CLOSE__" },
			}
		}
	},

	onEvent = function(ctx, eventName)
		-- ctx.model, ctx.player, ctx.remotes, ctx.payload(dialogId, responseIndex), etc.
		if eventName == "OpenShop" then
			Commands:Fire(7, ctx.model)
		elseif eventName == "StyleSala" then
			Commands:Fire(8, ctx.model)
		elseif string.match(eventName, "^StartQuest:") then
			local questId = string.sub(eventName, #"StartQuest:" + 1)
			local q = ctx.remotes:FindFirstChild("Quests") and ctx.remotes.Quests:FindFirstChild("Start")
			if q then q:FireServer(questId, ctx.model) end
		end
	end,

	-- comportamiento después de eventos:
	-- "close" (por defecto) | "stay" para permanecer con el diálogo abierto tras onEvent
	afterEvent = "close",
}

return KaraokeRoomRent

