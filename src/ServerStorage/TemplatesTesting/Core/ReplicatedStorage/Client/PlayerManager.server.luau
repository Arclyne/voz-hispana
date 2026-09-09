local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))
local LocalPlayer = Players.LocalPlayer

local services = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GuideService"))
local ParametrosTutorialBienvenida =  require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Tutorials"):WaitForChild("ParametrosTutorialBienvenida"))

-- Lógica para limpiar el player cuando spawnea
local function limpiarPersonaje(character)
	-- Damos un margen por si el root tarda en cargar
	local rootPart = character:WaitForChild("HumanoidRootPart", 10)

	if rootPart then
		-- Borrar el prompt
		-- Usamos WaitForChild con timeout pq a veces el server tarda un poco en crearlo
		local prompt = rootPart:WaitForChild("ProximityPrompt", 3)
		if prompt then
			prompt:Destroy()
		end

		-- Quitar el tag
		-- Pequeño delay para asegurarnos de que el tag ya se replicó antes de borrarlo
		task.wait(0.1)
		if CollectionService:HasTag(rootPart, "Player") then
			CollectionService:RemoveTag(rootPart, "Player")
		end
	end
end

-- Callback para el PlayerInit
local function OnPlayerAdded(player)
	-- Solo nos interesa nuestro propio player, ignoramos al resto
	if player ~= LocalPlayer then return end

	-- Conectamos para cuando muera y reviva
	player.CharacterAdded:Connect(limpiarPersonaje)

	-- Si el char ya existe (ej. entramos tarde al server), limpiamos directo
	if player.Character then
		task.spawn(function()
			limpiarPersonaje(player.Character)
		end)
	end
	
	-- Inicializamos tutorial bienvenida
	-- Vinculamos y agregamos las páginas al servicio
	services.GuideService:Bind(ParametrosTutorialBienvenida.Name)
	for page, paso in ParametrosTutorialBienvenida.Pasos do
		services.GuideService:AddPage(ParametrosTutorialBienvenida.Name, page, paso)
	end
	-- Iniciamos el tutorial
	services.GuideService:Start(ParametrosTutorialBienvenida.Name)
end

PlayerInit.Connect(OnPlayerAdded)