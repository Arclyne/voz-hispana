local module = {}

module.event = Instance.new("BindableEvent")
module.eventExit = Instance.new("BindableEvent")

module.MouseEnter = module.event.Event
module.MouseLeave = module.eventExit.Event

return module