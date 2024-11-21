--[[
	Custom Signals
	Allows you to create custom signal behaviour.
]]

local Mods = game:GetService("ReplicatedStorage").Modules

local Aux = require(Mods.Auxillery)
local Services = Aux:GetServices()

local CustomSignals = {} --Get Function is stored here
local Saved = {} --Signals are stored here
local Class = {} --Class Functions are stored here
Class.__index = Class

export type Custom_Signal = {
	Bind : BindableEvent,
	Dependencies : number,
	Property : string,
	Instance : Instance,
	Previous : any,
	Heartbeat : RBXScriptConnection,
	AlterHeartbeat : (self : {}, NewFunction : () -> nil) -> nil,
	RemoveDependency : (self : {}) -> nil
}

local function CheckProperty(Inst : Instance, Property : string)
	local Property = Inst[Property]
end

local function GetNewSignal(Inst : Instance, Property : string) --: Custom_Signal
	local s = pcall(CheckProperty)
	if not s then
		warn("Property is invalid.")
		return
	end
	local SavedInstance = Saved[Inst]
	
	local CustomSignal = {}
	local Bind = Instance.new("BindableEvent")
	
	CustomSignal.Bind = Bind
	CustomSignal.Dependencies = 1
	CustomSignal.Property = Property
	CustomSignal.Instance = Inst
	CustomSignal.Previous = Inst[Property]
	setmetatable(CustomSignal, Class)
	
	local function Default()
		if CustomSignal.Previous ~= Inst[Property] then
			Bind:Fire(Inst[Property])
		end
		CustomSignal.Previous = Inst[Property]
	end
	CustomSignal.Heartbeat = Services.RNS.Heartbeat:Connect(Default)

	if not SavedInstance then
		Saved[Inst] = {}
		SavedInstance = Saved[Inst]
	end
	
	SavedInstance[Property] = CustomSignal
	
	return CustomSignal
end

--Allows editing the <code>CustomSignal's</code> behaviour by setting a new function to the heartbeat.
function Class:AlterHeartbeat(NewFunction : () -> nil)
	assert(typeof(NewFunction) == "function", "Given Function is invalid.")
	if self.Heartbeat then
		self.Heartbeat:Disconnect()
	end
	
	local NewHeartbeat = Services.RNS.Heartbeat:Connect(NewFunction)
	self.Heartbeat = NewHeartbeat
end

--Removes a <code>Dependency</code> from the Signal. If 0 scripts depend on the signal, it gets destroyed.
function Class:RemoveDependency()
	self.Dependencies -= 1
	
	if self.Dependencies == 0 then
		setmetatable(self, nil)
		self.Heartbeat:Disconnect()
		self.Heartbeat = nil
		self.Dependencies = nil
		self.Bind:Destroy()
		self.Bind = nil
        table.freeze(self)
		Saved[self.Instance][self.Property] = nil
	end
end

--Returns the <code>CustomSignal</code> of the Instance's Property. If nonexistent, it'll create a new one.
function CustomSignals:Get(Inst : Instance, Property : string) : Custom_Signal
	local SavedInstance = Saved[Inst]
	
	if SavedInstance then
		local SavedPropertySignal = SavedInstance[Property]
		
		if SavedPropertySignal then
			SavedPropertySignal.Dependencies += 1
			return SavedPropertySignal
		else
			return GetNewSignal(Inst, Property)
		end
	else
		return GetNewSignal(Inst, Property)
	end
end

return CustomSignals