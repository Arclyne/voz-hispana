local Configuration = {
	Interface = {
		Theme = Color3.fromRGB(0, 140, 255),

		AccessKeycode = Enum.KeyCode.F2,
		TabletAccessKeycode = Enum.KeyCode.Q,
		ToolsAccessKeycode = Enum.KeyCode.F,
		DancesAccessKeycode = Enum.KeyCode.R,
		StatsAccessKeycode = Enum.KeyCode.G,
		AdminPanelAccessKeycode = Enum.KeyCode.M,
		ConstructionAccessKeycode = Enum.KeyCode.P,
		NightclubAccessKeycode = Enum.KeyCode.O,
		AudioPanelPlayers = Enum.KeyCode.C,
	},
	MaxRooms = 6,

	-- Desbloqueo de espacios de casa. La clave es el número de espacio que se
	-- desbloquea (el perfil ya trae los primeros), así que sólo hay precio para
	-- los espacios que van del inicial + 1 hasta MaxRooms.
	HouseSlots = {
		Currency = "Gems",
		Prices = {
			[3] = 150,
			[4] = 300,
			[5] = 600,
			[6] = 1200,
		},
	},

	-- Venta de una casa. Las dos deducciones se aplican sobre el precio original
	-- de la casa (HousesInfo[x].price) y se enseñan desglosadas en la proforma:
	-- con los valores de abajo, el jugador recibe el 80% de lo que costó.
	-- La cuenta vive en `Shared.SellHousePrompt.quote`.
	HouseSale = {
		CommissionRate = 0.05,
		SecondHandRate = 0.15,
	},
}

return Configuration