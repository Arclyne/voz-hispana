local MONEY = {
	type = "+100",
	color = Color3.fromRGB(200, 195, 42),
	image = "rbxassetid://107645265535864",
	imageScale = 0.7,
	reward = { Coins = 100 },
}

local MONEY_MID = {
	type = "+200",
	color = Color3.fromRGB(200, 195, 42),
	image = "rbxassetid://75331535110159",
	imageScale = 1.3,
	reward = { Coins = 200 },
}

local MONEY_BIG = {
	type = "+300",
	color = Color3.fromRGB(200, 195, 42),
	image = "rbxassetid://76321182258542",
	imageScale = 1.3,
	reward = { Coins = 300 },
}

local GEMS = {
	type = "+15",
	color = Color3.fromRGB(82, 135, 200),
	image = "rbxassetid://101938447947919",
	imageScale = 0.7,
	reward = { Gems = 15 },
}

local GEMS_MID = {
	type = "+30",
	color = Color3.fromRGB(82, 135, 200),
	image = "rbxassetid://102489051058857",
	imageScale = 1.3,
	reward = { Gems = 30 },
}

local GEMS_BIG = {
	type = "+60",
	color = Color3.fromRGB(82, 135, 200),
	image = "rbxassetid://108274115121443",
	imageScale = 1.3,
	reward = { Gems = 60 },
}

local EXTRA_SPIN = {
	type = "+2 Spins",
	color = Color3.fromRGB(223, 104, 104),
	image = "rbxassetid://137169374613239",
	imageScale = 1,
	reward = { Spins = 2 },
}

local DANCE = {
	type = "Baile",
	color = Color3.fromRGB(235, 115, 229),
	image = "rbxassetid://89596568018019",
	imageScale = 1,
	reward = { _Special = "Dance" }, -- TODO: aquí luego lo conectamos a tu sistema real
}

local FURNITURE = {
	type = "Mueble",
	color = Color3.fromRGB(203, 128, 235),
	image = "rbxassetid://107645265535864",
	imageScale = 1,
	reward = { _Special = "Furniture" }, -- TODO
}

local TOY = {
	type = "Cofre Tool",
	color = Color3.fromRGB(108, 185, 86),
	image = "rbxassetid://84734362596573",
	imageScale = 1.5,
	reward = { ChestKey = 1 },
}

export type Prize = {
	type: string,
	color: Color3,
	reward: {[string]: any}?
}

return {
	EXTRA_SPIN,
	MONEY,
	GEMS,
	MONEY_BIG,
	GEMS_MID,
	MONEY,
	DANCE,
	MONEY_MID,
	GEMS,
	MONEY,
	FURNITURE,
	MONEY_MID,
	GEMS,
	MONEY,
	TOY,
	GEMS_BIG,
} :: { Prize }
