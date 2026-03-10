--!strict
--[[
	CustomSignals
	Allows the creation of signals
]]
local CustomSignals = {}

local Services = require("../Standalone/Services")
local InstanceModule = require("../Standalone/BaseTypes/Instance")

local CustomSignalClass = {}
CustomSignalClass.__index = CustomSignalClass

export type CustomSignalClass = {
	Set: (self : Signal, Usage : string, Value : any) -> (),
	Destroy: () -> ()
}

export type Signal = typeof(setmetatable({} :: SignalObject, CustomSignalClass))

export type SignalObject = {
	OnEvent: RBXScriptSignal | any,
	Bindable: BindableEvent,
	PreviousProperty: any,
	OnHeartbeat: RBXScriptConnection?,
}

function CustomSignals.new() : Signal
	local Event = Instance.new("BindableEvent")
	
	local self = {
		OnEvent = Event.Event,
		Bindable = Event
	}
	setmetatable(self, CustomSignalClass)
	
	return self
end

function CustomSignalClass:Set(Usage : string, Value : any)
	if Usage == "PropertyCheck" then
		assert(InstanceModule:SafeCheckProperty(Value.Instance, Value.Property), tostring(Value.Property).." isn't a valid Property of "..tostring(Value.Instance))
		
		self.PreviousProperty = Value.Instance[Value.Property]
		local function OnHeartbeat()
			if not Value.Instance then
				CustomSignalClass:Destroy()
				return
			end
			if Value.Instance[Value.Property] ~= self.PreviousProperty then
				self.Bindable:Fire(Value.Instance[Value.Property])
			end
			
			self.PreviousProperty = Value.Instance[Value.Property]
		end
		
		self.OnHeartbeat = Services.RNS.Heartbeat:Connect(OnHeartbeat)
	elseif Usage == "FunctionCall" then
		assert(typeof(Value) == "function", tostring(Value).." isn't a function.")
		
		local function OnHeartbeat()
			if Value() then
				self.Bindable:Fire()
			end
		end
		
		self.OnHeartbeat = Services.RNS.Heartbeat:Connect(OnHeartbeat)
	else
		warn("Invalid Usage.")
	end
end

function CustomSignalClass:Destroy()
	if self.OnHeartbeat then
		self.OnHeartbeat:Disconnect()
	end
	self.Bindable:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	table.freeze(self)
end

return CustomSignals