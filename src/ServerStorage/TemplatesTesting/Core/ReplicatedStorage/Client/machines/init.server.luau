local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Spring = require(shared:WaitForChild("Spring"))
local bindToTag = require(shared:WaitForChild("bindToTag"))
local SoundManager = require(shared:WaitForChild("SoundManager"))
local MachineFactory = require(script.MachineFactory)

local remotes = ReplicatedStorage:WaitForChild("Events")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ui = playerGui:WaitForChild("PlayPrompt")
local RouletteUI = require(ReplicatedStorage.Client.RouletteUIStarter:WaitForChild("RouletteUIController"))

local machines = {}

local function askToPlay(model: Model, callback: () -> ())
	local price = model:GetAttribute("Price") or 0
	local spring = Spring.new(-1, 0, { K = 0.125, mass = 1, damping = 0.3 })

	local frame = ui:WaitForChild("Screen")
	local message = frame:WaitForChild("Frame"):WaitForChild("Text")
	local confirm = frame.Frame:WaitForChild("Confirm")
	local cancel = frame.Frame:WaitForChild("Cancel")
	local connections = {}

	local function close()
		spring.target = -1
		task.delay(0.2, function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end)
	end

	table.insert(connections, RunService.Heartbeat:Connect(function()
		spring:update()
		frame.Position = UDim2.fromScale(0, spring.value)
	end))

	table.insert(connections, confirm.Activated:Connect(function()
		close()
		if remotes.Machines.Request:InvokeServer(model) then
			callback()
		end
	end))

	table.insert(connections, cancel.Activated:Connect(function()
		close()
	end))

	message.Text = `¿Estás seguro que quieres jugar a esto por <font color="#55ff7f">{price} créditos</font>?`
	spring.target = 0
end

bindToTag("Machine", function(model: Model)
	local machine = MachineFactory.create(model.Name, model)

	machine.prompt.triggered:Connect(function()
		if model.Name == "Roulette" then
			RouletteUI.Open(model)
			return
		end

		askToPlay(model, function()
			remotes.Machines.Start:FireServer(model)
			machine.prompt:disable()
		end)
	end)

	machines[model] = machine
end)

remotes.Machines.Start.OnClientEvent:Connect(function(model, localPlayer, ...)
	local machine = machines[model]
	if not machine then return end

	machine:stop()

	-- ✅ Roulette: NO deshabilites el prompt (para poder abrir UI siempre)
	if model and model.Name == "Roulette" then
		if localPlayer then
			machine:start(...)
		else
			machine:replicate(...)
		end
		return
	end

	-- resto igual
	machine.prompt:disable()

	if localPlayer then
		machine:start(...)
	else
		machine:replicate(...)
	end
end)

remotes.Machines.Stop.OnClientEvent:Connect(function(model)
	local machine = machines[model]
	if not machine then return end

	machine:stop()

	-- ✅ Roulette: dejamos prompt enable siempre (no hace daño)
	machine.prompt:enable()

	if game:GetAttribute("Idling") then
		machine:idle()
	end
end)

local function onIdleChanged()
	print("Idling changed")
	local idling = game:GetAttribute("Idling")
	for model, machine in machines do
		local started = model:GetAttribute("Started")
		if idling and not started then
			machine:idle()
		elseif not started then
			machine:stop()
		end
	end
end

-- Si no existe el atributo, lo creamos como TRUE por defecto
if game:GetAttribute("Idling") == nil then
	game:SetAttribute("Idling", true)
end

game:GetAttributeChangedSignal("Idling"):Connect(onIdleChanged)
onIdleChanged()
