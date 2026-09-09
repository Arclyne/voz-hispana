local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

---------------------------------------------------------------------------------
-- VERIFICACIÓN DE VOICE CHAT
---------------------------------------------------------------------------------
local VoiceChatService = game:GetService("VoiceChatService")
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))

local function onPlayerAdded(player)
	-- pcall por si falla la red de roblox
	local success, isVoiceEnabled = pcall(function()
		return VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
	end)

	if success then
		-- Si la verificación fue exitosa pero el jugador no tiene el chat de voz
		if not isVoiceEnabled then
			player:Kick("Este juego es exclusivo para usuarios con Chat de Voz. Por favor, actívalo en tu configuración para jugar.")
		end
	else
		-- Si Roblox falla la red al verificar, quizas conviene que le hagamos kick tambien
		warn("No se pudo verificar el estado del chat de voz de " .. player.Name)
	end
end

PlayerInit.Connect(onPlayerAdded)

---------------------------------------------------------------------------------
--TEMPLATES
---------------------------------------------------------------------------------

local TEMPLATES_IDS = {
	137484964666215, -- CORE (siempre el primero)
	92258948630058, -- GameWorlds
	94091855508048 -- BuildingSystem
}

-- Remote para avisar cuando los templates estén listos
local TemplatesReady = ReplicatedStorage:FindFirstChild("TemplatesReady") 
	or Instance.new("RemoteEvent", ReplicatedStorage)
TemplatesReady.Name = "TemplatesReady"

local TemplatesReadyFlag = ReplicatedStorage:FindFirstChild("TemplatesReadyFlag") 
	or Instance.new("BoolValue", ReplicatedStorage)
TemplatesReadyFlag.Name = "TemplatesReadyFlag"
TemplatesReadyFlag.Value = false

-- Servicios destino permitidos
local validServices = {
	"ReplicatedFirst", "StarterGui","ServerScriptService","ReplicatedStorage","ServerStorage",
	"StarterPack","StarterPlayer","SoundService","Lighting","MaterialService"
}

-- Une carpetas, modelos, guis etc, evitando duplicar instancias, se queda con la original
local function mergeInstances(source: Instance, target: Instance)
	for _, item in ipairs(source:GetChildren()) do
		local existing = target:FindFirstChild(item.Name)

		if existing then
			if existing.ClassName == item.ClassName then
				-- MISMO TIPO: en vez de tirar el duplicado, metemos sus hijos dentro del existente
				mergeInstances(item, existing)
				item:Destroy()
			else
				-- CONFLICTO DE TIPO: ignoramos el nuevo
				item:Destroy()
			end
		else
			-- NO EXISTE: lo añadimos tal cual
			item.Parent = target
		end
	end
end
-- Coloca el contenido importado en su servicio correspondiente
local function processImportedModel(model)
	for _, folder in ipairs(model:GetChildren()) do
		if folder:IsA("Folder") and table.find(validServices, folder.Name) then
			local service = game:GetService(folder.Name)
			for _, sub in ipairs(folder:GetChildren()) do
				local existing = service:FindFirstChild(sub.Name)

				if existing then
					if existing.ClassName == sub.ClassName then
						-- mergea contenido (hijos) dentro del existente
						mergeInstances(sub, existing)
						sub:Destroy()
					else
						sub:Destroy()
					end
				else
					sub.Parent = service
				end
			end
		end
	end
	model:Destroy()
end

-- Overrides locales desde ServerStorage/TemplatesTesting
local testOverrides = {}
local TemplatesTesting = ServerStorage:FindFirstChild("TemplatesTesting")
if TemplatesTesting then
	for _, child in ipairs(TemplatesTesting:GetChildren()) do
		if child:IsA("Folder") or child:IsA("Model") then
			testOverrides[child.Name] = child
		end
	end
end

-- Importar assets
for _, assetId in ipairs(TEMPLATES_IDS) do
	local success, model = pcall(function() return InsertService:LoadAsset(assetId) end)
	if success and model then
		local imported = model:GetChildren()[1]
		if imported then
			local override = testOverrides[imported.Name]
			if override then
				processImportedModel(override:Clone())
				imported:Destroy()
			else
				processImportedModel(imported)
			end
		else
			warn("Asset vacío:", assetId)
		end
	else
		warn("Error al cargar asset:", assetId)
	end
end

-- Avisar que ya se terminó

local folderTest = ServerStorage:FindFirstChild("TemplatesTesting")
if folderTest then
	folderTest:Destroy()
	Debris:AddItem(folderTest)
end

TemplatesReadyFlag.Value = true
TemplatesReady:FireAllClients()
print("✅ Templates importados — TemplatesReady disparado.")