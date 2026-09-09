-- ReplicatedStorage/Dialogs/Shopkeeper.lua
local FrameShop = {
	displayName = "Comprar marcos",
	actionName = "Hablar",
	start = 1,
	nodes = {
		[1] = {
			text = "¡Buenos días! ¡Aquí puedes encontrar marcos expléndidos para tus cuadros!",
			responses = {
				{ text = "Quiero comprar uno. (Precio: 500 monedas)", next = 3 },
				{ text = "¿Tienes algún encargo para mí?", next = 2 },
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
		},
		[3] = {
			text = "Te entregaré uno aleatorio por 500 monedas. ¿Estás seguro?",
			responses = {
				{ text = "Acepto. Aquí tienes.", event = "OpenShop"  },
				{ text = "He cambiado de opinión.", next = "__CLOSE__" },
			}
		}
	},

	onEvent = function(ctx, eventName)
		if eventName == "OpenShop" then
			-- ctx.remotes probablemente es ReplicatedStorage.Events
			local shopsFolder = ctx.remotes:FindFirstChild("Shops")
			if not shopsFolder then
				warn("No se encontró la carpeta 'Shops' dentro de ctx.remotes")
				return
			end

			local ev = shopsFolder:FindFirstChild("FrameShop")
			if ev then
				print("evento de compra de marco lanzado")
				ev:FireServer(ctx.model)
			else
				warn("No se encontró el RemoteEvent 'FrameShop' dentro de Shops")
			end
		end
	end,

	-- comportamiento después de eventos:
	-- "close" (por defecto) | "stay" para permanecer con el diálogo abierto tras onEvent
	afterEvent = "close",
}

return FrameShop

