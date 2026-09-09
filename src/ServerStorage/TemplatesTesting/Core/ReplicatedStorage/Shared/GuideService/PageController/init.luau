local module = {}
module.__index = module

local Disconnects = require(script.Parent:WaitForChild('Disconnects'))
local InterfaceController = require(script:WaitForChild('InterfaceController'))
local debris = game:GetService('Debris')
local verificacionPages = require(script:WaitForChild('VerificacionPages'))
local Player = game:GetService('Players').LocalPlayer

function module.new(uniqueKey)
	local self = setmetatable({
		uniqueKey = uniqueKey,
		Pages = {
			
			{
				{
					["type"] = "Text",
					["Options"] = {
						Text = string.format("Welcome %s!", Player.DisplayName),
						Size = Vector2.new(.5,0),
						Font = Enum.Font.SourceSansBold,
					},
				},
			},
			
		},
	}, module)
	
	self.PageSelect = 1
	
	return self
end

function module:init()
	local bindable = Instance.new('BindableEvent', script)
	self.EventInstance = bindable
	self.Ended = bindable.Event
end
function module:destroy()
	self:End(true)
	debris:AddItem(self.EventInstance,0)
	table.clear(self)
end

function module:OrderPage()
	local orderedKeys = {}
	for k in pairs(self.Pages) do
		table.insert(orderedKeys, k)
	end
	table.sort(orderedKeys)
	local sorted = {}
	for i, key in ipairs(orderedKeys) do
		sorted[i] = self.Pages[key]
	end
	return sorted
end

function module:Start()
	if self.actives then return end
	self.actives = {}
	self.PagesOrder = self:OrderPage()
	InterfaceController.Start(self)
	warn(`Iniciando "{self.uniqueKey}".`)
end
function module:AddPage(page, context)
	if self.actives then return end
	if typeof(page)=='number' and page>0 then
		page = math.round(page)
		self.Pages[page] = verificacionPages.verifiSection(context)
	end
end
function module:AdvancePage(number)
	if not self.PagesOrder then return end
	number = math.sign(tonumber(number) or 1)
	local next = self.PageSelect + number
	if next ~= self.PageSelect then
		self.PageSelect = next
		InterfaceController.SetPage(self)
	end
end
function module:PreviousPage()
	self:AdvancePage(-1)
end
function module:End(cancel)
	if not self.actives then return end
	self.EventInstance:Fire(not cancel)
	self.PageSelect = 1
	self.actives = Disconnects.All(self.actives)
	InterfaceController.Exit(self)
end

return module