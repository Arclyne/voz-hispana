--!strict
local Players = game:GetService("Players")

-- ⚙️ CONFIGURA AQUÍ tu grupo:
local GROUP_ID = 16663699

-- Mapea por rango del grupo (0–255). minRank inclusivo. Mayor → menor.
local ROLE_MAP = {
	{ minRank = 254, templateName = "4Owner" },          -- Owner
	{ minRank = 200, templateName = "4Dev" },            -- Dev
	{ minRank = 150, templateName = "4Admin" },          -- Admin
	{ minRank = 100, templateName = "4Mod" },            -- Mod
	{ minRank = 50,  templateName = "4ContentCreator" }, -- Content Creator
	-- Añade más si quieres
}

local GroupRoles = {}

function GroupRoles.getTemplateNameFor(player: Player): string?
	if not GROUP_ID then return nil end
	local rank = 0
	local ok, err = pcall(function()
		rank = player:GetRankInGroup(GROUP_ID)
	end)
	if not ok then
		warn("[GroupRoles] GetRankInGroup error:", err)
		return nil
	end
	for _, rule in ipairs(ROLE_MAP) do
		if rank >= rule.minRank then
			return rule.templateName
		end
	end
	return nil
end

-- ⭐ NUEVO: helper para obtener la carpeta de plantillas
function GroupRoles.getTemplatesFolder(): Folder?
	-- La carpeta debe estar como hija del propio ModuleScript (script)
	local f = script:FindFirstChild("Templates")
	if f and f:IsA("Folder") then
		return f
	end
	return nil
end

return GroupRoles
