--!strict

local EmitterModule = {}

local EmitterClass: EmitterClass = {}
EmitterClass.__index = EmitterClass

export type Emitter = typeof(setmetatable({} :: EmitterObject, {} :: EmitterClass))
export type Connection = {
	Disconnect: (self: Connection) -> (),
}

type EmitterObject = {
	Connections: {
		[string]: EmitterConnections,
	},
}
type EmitterClass = {
	__index: EmitterClass,
	Fire: (self: Emitter, Name: string, ...any) -> (),
	Connect: (self: Emitter, Name: string, Callback: (...any) -> ()) -> Connection,
	Once: (self: Emitter, Name: string, Callback: (...any) -> ()) -> Connection,
	Wait: (self: Emitter, Name: string) -> ...any,
}

type EmitterConnections = {
	[number]: {
		Callback: () -> nil,
		Type: string,
	},
}
--Creates a Emitter
function EmitterModule.new(): Emitter
	local Emitter = {
		Connections = {},
	}
	setmetatable(Emitter, EmitterClass)
	return Emitter
end

local function GetConnection(
	Emitter: Emitter,
	CategoryName: string,
	ConnectionData: { Callback: (...any) -> (), Type: string }
): Connection
	local Connection = {}

	function Connection:Disconnect()
		local Index = table.find(Emitter.Connections[CategoryName], ConnectionData)

		if Index then
			table.remove(Emitter.Connections[CategoryName], Index)
		end
	end

	return Connection
end

--Fires a Event, if possible. Given Args will be sent to the Connection.
function EmitterClass:Fire(Name: string, ...: any)
	local Connections = self.Connections[Name]

	if not Connections then
		return
	end

	for Index, EmitterConnection in pairs(Connections) do
		if EmitterConnection.Type == "Once" then
			table.remove(Connections, Index)
		end
		task.spawn(EmitterConnection.Callback, ...)
	end
end

--Creates a Connection to a Event, and creates a Event if necessary.
function EmitterClass:Connect(Name: string, Callback: (...any) -> ()): Connection
	assert(typeof(Callback) == "function", "Invalid function parameter")
	local Connections = self.Connections[Name]

	if not Connections then
		self.Connections[Name] = {}
		Connections = self.Connections[Name]
	end
	local Data = { Callback = Callback, Type = "Connect" }

	table.insert(Connections, Data)

	return GetConnection(self, Name, Data)
end

--Equivalent to Connect, but terminates the Connection after running once.
function EmitterClass:Once(Name: string, Callback: (...any) -> ()): Connection
	assert(typeof(Callback) == "function", "Invalid function parameter")
	local Connections = self.Connections[Name]

	if not Connections then
		self.Connections[Name] = {}
		Connections = self.Connections[Name]
	end
	local Data = { Callback = Callback, Type = "Once" }

	table.insert(Connections, Data)

	return GetConnection(self, Name, Data)
end

--Waits for a Event to fire, and returns the Arguments from it.
function EmitterClass:Wait(Name: string): ...any
	local Fired, Args = false, nil

	self:Once(Name, function(...)
		Fired = true
		Args = table.pack(...)
	end)

	while not Fired do
		task.wait()
	end

	return table.unpack(Args)
end

return EmitterModule
