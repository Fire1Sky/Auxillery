--!strict
--[[
	CustomSignals
	Allows the creation of signals
]]
local CustomSignals = {}
local Class = {}
Class.__index = Class

local Aux = require(script.Parent.Auxiliary)
local Services = Aux:GetServices()

function CustomSignals.new()
	local Event = Instance.new("BindableEvent")
	
	local self = {
		OnEvent = Event.Event,
		Bindable = Event
	}
	setmetatable(self, Class)
	return self
end

function Class:Set(Usage : string, Value : any)
	if Usage == "PropertyCheck" then
		assert(typeof(Value) == "table" and Aux.TableFunctions:Compare({["Instance"] = "Instance", Property = "string"}, Value, true), tostring(Value).." isn't a valid table.")
		assert(Aux.InstanceFunctions:SaveCheckProperty(Value.Instance, Value.Property), tostring(Value.Property).." isn't a valid Property of "..tostring(Value.Instance))
		
		self.PreviousProperty = Value.Instance[Value.Property]
		local function OnHeartbeat()
			if not Value.Instance then
				self:Destroy()
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

function Class:Destroy()
	if self.OnHeartbeat then
		self.OnHeatbeat:Disconnect()
	end
	self.Bindable:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return CustomSignals