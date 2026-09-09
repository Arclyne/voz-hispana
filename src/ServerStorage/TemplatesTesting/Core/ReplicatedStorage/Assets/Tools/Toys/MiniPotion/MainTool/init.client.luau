local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local tool = script.Parent

-- Cambia "Minimizate" por "Maximizate" en la poción grande
local potionRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools"):WaitForChild("Minimizate")

local drinkTrack = nil
local isDrinking = false

-- Cargar la animación al equipar
tool.Equipped:Connect(function()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	if not drinkTrack then
		-- Asegúrate de que el nombre coincida con la animación dentro de tu Tool
		drinkTrack = animator:LoadAnimation(script:WaitForChild("Drink"))
	end
end)

-- Parar animación al desequipar
tool.Unequipped:Connect(function()
	if drinkTrack and drinkTrack.IsPlaying then
		drinkTrack:Stop()
	end
	isDrinking = false
end)

-- Detectar clic
tool.Activated:Connect(function()
	local character = player.Character
	if not character then return end

	-- Comprobación local para no gastar la poción si ya estás en el tamaño límite
	local currentState = character:GetAttribute("SizeState") or "Normal"

	-- OJO: Cambia "Small" por "Big" en la poción de agrandar
	if currentState == "Small" then return end 

	if isDrinking then return end 
	isDrinking = true

	if drinkTrack then
		drinkTrack:Play()
	end

	-- Avisamos al servidor para el sonido de tragar
	potionRemote:FireServer("Drink")

	task.wait(1)

	if tool.Parent == player.Character then
		-- Avisamos para el cambio de tamaño (Cambia "Shrink" por "Grow" en la poción grande)
		potionRemote:FireServer("Shrink")
	end

	isDrinking = false
end)