local EmitterCreator = {}

--[[TYPECHECKING]]--

type Connection = {
    Disconnect: (self: Connection) -> ()
}

type SingleChannelMeta<T...> = {
    __index: SingleChannelMeta<T...>,
	Fire: (self: SingleChannelEmitter<T...>, T...) -> (),
	Connect: (self: SingleChannelEmitter<T...>, Callback: (T...) -> ()) -> Connection,
	Once: (self: SingleChannelEmitter<T...>, Callback: (T...) -> ()) -> Connection,
	Wait: (self: SingleChannelEmitter<T...>) -> T...
}

type MultiChannelMeta = {
    __index: MultiChannelMeta,
	Fire: (self: MultiChannelEmitter, Name: string, ...any) -> (),
	Connect: (self: MultiChannelEmitter, Name: string, Callback: (...any) -> ()) -> Connection,
	Once: (self: MultiChannelEmitter, Name: string, Callback: (...any) -> ()) -> Connection,
	Wait: (self: MultiChannelEmitter, Name: string) -> ...any
}

type SingleChannelEmitter<T...> = typeof(setmetatable({} :: {
    Connections: {
        (T...) -> ()
    }
}, {} :: SingleChannelMeta<T...>
))

type MultiChannelEmitter = typeof(setmetatable({} :: {
    Connections: {[string]: {
        [number]: (...any) -> ()
    }
}
}, {} :: MultiChannelMeta))

--[[LOCAL FUNCTIONS]]--

local function CreateConnection(Connections: {() -> ()}, Lookup: () -> ()): Connection
    local Connection = {}

    function Connection:Disconnect()
        table.remove(Connections, table.find(Connections, Lookup))
    end

    return Connection
end

--[[META]]--

local SingleChannelMeta = {} :: SingleChannelMeta<>
SingleChannelMeta.__index = SingleChannelMeta

function SingleChannelMeta:Connect(Callback: () -> ()): Connection
    table.insert(self.Connections, Callback)
    return CreateConnection(self.Connections, Callback)
end

function SingleChannelMeta:Once(Callback: () -> ()): Connection
    local Connection
    Connection = self:Connect(function(...)
        Connection:Disconnect()
        task.spawn(Callback, ...)
    end)

    return Connection
end

function SingleChannelMeta:Fire(...)
    for _, Connection in pairs(self.Connections) do
        task.spawn(Connection, ...)
    end
end

function SingleChannelMeta:Wait(): ...any
    local thread = coroutine.running()

    self:Once(function(...)
        task.spawn(coroutine.resume, thread, ...)
    end)

    return coroutine.yield()
end


local MultiChannelMeta = {} :: MultiChannelMeta
MultiChannelMeta.__index = MultiChannelMeta

--Fires a Event, if possible. Given Args will be sent to the Connection.
function MultiChannelMeta:Fire(Name: string, ...: any)
	local Connections = self.Connections[Name]

	if not Connections then
		return
	end

	for _, Callback in pairs(Connections) do
		task.spawn(Callback, ...)
	end
end

--Creates a Connection to a Event, and creates a Event if necessary.
function MultiChannelMeta:Connect(Name: string, Callback: (...any) -> ()): Connection
	assert(typeof(Callback) == "function", "Invalid function parameter")
	local Connections = self.Connections[Name]

	if not Connections then
		self.Connections[Name] = {}
		Connections = self.Connections[Name]
	end

	table.insert(Connections, Callback)
	return CreateConnection(Connections, Callback)
end

--Equivalent to Connect, but terminates the Connection after running once.
function MultiChannelMeta:Once(Name: string, Callback: (...any) -> ()): Connection
	local Connection
    Connection = self:Connect(Name, function(...)
        Connection:Disconnect()
        task.spawn(Callback, ...)
    end)

    return Connection
end

--Waits for a Event to fire, and returns the Arguments from it.
function MultiChannelMeta:Wait(Name: string): ...any
	local Thread = coroutine.running()

	self:Once(Name, function(...)
		task.spawn(coroutine.resume, Thread, ...)
	end)

	return coroutine.yield()
end

--[[CONSTRUCTORS]]--

--Creates a one-channel Emitter.
function EmitterCreator.newSingle<Format...>(...: Format...): SingleChannelEmitter<Format...>
    return setmetatable({Connections = {}}, SingleChannelMeta)
end

--Creates a multi-channel Emitter.
function EmitterCreator.newMulti(): MultiChannelEmitter
    return setmetatable({Connections = {}}, MultiChannelMeta)
end

return EmitterCreator