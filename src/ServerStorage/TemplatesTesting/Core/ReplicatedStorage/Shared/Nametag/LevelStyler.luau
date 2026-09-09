--!strict
local TweenService = game:GetService("TweenService")

-- Paleta dorada (>= 50)
local GOLD = {
	base   = Color3.fromRGB(255,197, 77),
	dark   = Color3.fromRGB(138,107,  0),
	gradHi = Color3.fromRGB(255, 217, 2),
	gradLo = Color3.fromRGB(255,181, 61),
}

-- Familias 0–49
local FAMILIES = {
	[0] = { base=Color3.fromRGB(255,255,255), dark=Color3.fromRGB(124,124,124), gradHi=Color3.fromRGB(255,255,255), gradLo=Color3.fromRGB(202,202,202) },
	[1] = { base=Color3.fromRGB(85,204,85),   dark=Color3.fromRGB(30,120,30),   gradHi=Color3.fromRGB(150,235,150), gradLo=Color3.fromRGB(85,204,85) },
	[2] = { base=Color3.fromRGB(85,170,255),  dark=Color3.fromRGB(54,107,161),  gradHi=Color3.fromRGB(149,206,255), gradLo=Color3.fromRGB(85,170,255) },
	[3] = { base=Color3.fromRGB(179,102,255), dark=Color3.fromRGB(108,43,181),  gradHi=Color3.fromRGB(220,170,255), gradLo=Color3.fromRGB(179,102,255) },
	[4] = { base=Color3.fromRGB(255,154,85),  dark=Color3.fromRGB(161,95,54),   gradHi=Color3.fromRGB(255,208,149), gradLo=Color3.fromRGB(255,154,85) },
}

local function paletteForLevel(level: number)
	if level >= 50 then
		return GOLD
	end
	local idx = math.clamp(math.floor(level / 10), 0, 4)
	return FAMILIES[idx]
end

local function ensureGradient(label: TextLabel): UIGradient
	local g = label:FindFirstChildOfClass("UIGradient")
	if not g then
		g = Instance.new("UIGradient")
		g.Parent = label
	end
	g.Enabled = true
	return g
end

local function removeGradient(label: TextLabel)
	local g = label:FindFirstChildOfClass("UIGradient")
	if g then g:Destroy() end
end

local function setGradientColors(g: UIGradient, hi: Color3, lo: Color3)
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, hi),
		ColorSequenceKeypoint.new(1, lo),
	})
end

local function startLoopMarker(parent: Instance, name: string): BoolValue
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local marker = Instance.new("BoolValue")
	marker.Name = name
	marker.Parent = parent
	return marker
end

local function stopLoopMarker(parent: Instance, name: string)
	local e = parent:FindFirstChild(name)
	if e then e:Destroy() end
end

local LevelStyler = {}

function LevelStyler.apply(levelLabel: TextLabel, level: number)
	if not levelLabel or not levelLabel:IsA("TextLabel") then return end

	local title: TextLabel? = levelLabel:FindFirstChild("Title") :: TextLabel?
	local textObj: TextLabel = title or levelLabel
	textObj.Text = tostring(math.max(0, level))

	local pal = paletteForLevel(level)
	if not pal then return end

	textObj.TextColor3 = pal.dark

	local g3 = ensureGradient(levelLabel)
	setGradientColors(g3, pal.gradHi, pal.gradLo)

	-- Limpiar posibles animaciones viejas
	for _, tag in ipairs({"__ROTATE","__BREATH","__TITLE_SWEEP","__TITLE_WAG"}) do
		stopLoopMarker(levelLabel, tag)
		if title then stopLoopMarker(title, tag) end
	end

	if level >= 50 then
		-- === Animaciones doradas suaves ===

		-- 1️⃣ Rotación orbital ligera (2.2s por vuelta)
		do
			local m = startLoopMarker(levelLabel, "__ROTATE")
			g3.Rotation = 0
			task.defer(function()
				while m.Parent do
					local t = TweenService:Create(g3, TweenInfo.new(2.2, Enum.EasingStyle.Linear), { Rotation = 360 })
					t:Play()
					t.Completed:Wait()
					if not m.Parent then break end
					g3.Rotation = 0
				end
			end)
		end

		-- 2️⃣ "Respiro": offset ping-pong suave
		do
			local m = startLoopMarker(levelLabel, "__BREATH")
			g3.Offset = Vector2.new(-0.1, 0)
			task.defer(function()
				while m.Parent do
					local t1 = TweenService:Create(g3, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(0.1, 0) })
					t1:Play(); t1.Completed:Wait()
					if not m.Parent then break end
					local t2 = TweenService:Create(g3, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(-0.1, 0) })
					t2:Play(); t2.Completed:Wait()
				end
			end)
		end

		-- 3️⃣ Title sweep + wag
		if title then
			local gt = ensureGradient(title)
			setGradientColors(gt, GOLD.gradHi, GOLD.gradLo)
			gt.Offset = Vector2.new(-1, 0)
			gt.Rotation = 0

			-- Sweep lateral continuo
			do
				local m = startLoopMarker(title, "__TITLE_SWEEP")
				task.defer(function()
					while m.Parent do
						local t1 = TweenService:Create(gt, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(1, 0) })
						t1:Play(); t1.Completed:Wait()
						if not m.Parent then break end
						local t2 = TweenService:Create(gt, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(-1, 0) })
						t2:Play(); t2.Completed:Wait()
					end
				end)
			end

			-- Wag (balanceo) sutil
			do
				local m = startLoopMarker(title, "__TITLE_WAG")
				task.defer(function()
					while m.Parent do
						local t1 = TweenService:Create(gt, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = 10 })
						t1:Play(); t1.Completed:Wait()
						if not m.Parent then break end
						local t2 = TweenService:Create(gt, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = -10 })
						t2:Play(); t2.Completed:Wait()
					end
				end)
			end
		end
	else
		-- < 50 → estático
		g3.Rotation = 0
		g3.Offset = Vector2.new(0,0)
		if title then removeGradient(title) end
	end
end

return LevelStyler
