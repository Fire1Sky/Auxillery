--[[
	Auxillery
	Contains a bunch of functionality, allowing cleaner code.
]]

local Auxillery = {
	InstanceFunctions = {},
	TableFunctions = {}
}

local Debounces = {}

local _BridgeNet = nil --Reference to BridgeNet if used. Use require() when referencing

local Services = {
	P = game:GetService("Players"),
	RS = game:GetService("ReplicatedStorage"),
	RNS = game:GetService("RunService"),
	RF = game:GetService("ReplicatedFirst"),
	SVS = game:GetService("ServerStorage"),
	SS = game:GetService("SoundService"),
	LT = game:GetService("Lighting"),
	UIS = game:GetService("UserInputService"),
	CAS = game:GetService("ContextActionService"),
	CS = game:GetService("CollectionService"),
	TS = game:GetService("TweenService"),
	IS = game:GetService("InsertService"),
	MS = game:GetService("MarketplaceService"),
	HS = game:GetService("HttpService"),
	PS = game:GetService("PathfindingService"),
	PHYS = game:GetService("PhysicsService"),
	DE = game:GetService("Debris")
}

if _BridgeNet then
	Services.BN = _BridgeNet
end

--Gets a table with Service shortcuts.
function Auxillery:GetServices()
	return Services
end

--[[
	Awaits and returns a value from the given table.

	tab: the table to look into.

	key: the key that will be waited for.

	timeout: optional argument which stops yielding the code after runtime exceeds the timeout value.
]]
function Auxillery.TableFunctions:Await(tab : {}, key : any, timeout : number?) : any
	Auxillery:AssertWarn(typeof(tab) == "table", tostring(tab).." isn't a table.")
	Auxillery:AssertWarn(key, "key is nil.")

	if tab[key] then
		return tab[key]
	else
		local runtime = 0
		if timeout and typeof(timeout) == "number" then
			repeat
				runtime += 0.015
				if runtime >= timeout then
					break
				end
				task.wait()
			until tab[key]

			return
		else
			local printed = false
			repeat
				if Auxillery:NumberInRange(5, runtime, 0.015) and not printed then
					printed = true
					warn("Infinite yield possible with table "..tostring(tab).." and key "..tostring(key))
				end
				runtime += 0.015
				task.wait()
			until tab[key]

			return tab[key]
		end
	end
end

--[[
	Checks if TargetNumber is withing a specified MaxDistance from the ReferenceNumber.
	
	Returns a boolean indicating if the TargetNumber is within the range of the ReferenceNumber and the actual Distance.
]]
function Auxillery:NumberInRange(ReferenceNumber : number, TargetNumber : number, MaxDistance : number) : boolean & number
	Auxillery:AssertWarn(typeof(ReferenceNumber) == "number", tostring(ReferenceNumber).." isn't a number.")
	Auxillery:AssertWarn(typeof(TargetNumber) == "number", tostring(TargetNumber).." isn't a number.")
	Auxillery:AssertWarn(typeof(MaxDistance) == "number", tostring(MaxDistance).." isn't a number.")

	local dist = math.abs(ReferenceNumber - TargetNumber)
	local iswithinRange = dist < MaxDistance

	return iswithinRange, dist
end

--Returns a random ID (requires HttpService to be enabled)
function Auxillery:GenerateRandomId() : string
	Auxillery:AssertWarn(Services.HS.HttpEnabled, "Enable HttpService first before using this function.")
	return string.gsub(Services.HS:GenerateGUID(false), "-", "")
end

--[[
	Same functionality as assert(), but uses a warn instead.

	Condition: If Condition is equal to false or nil the warn will trigger.

	Msg: The warn message that should be displayed.
]]
function Auxillery:AssertWarn(Condition : any, Msg : string)
	if not Condition then
		if Msg then
			warn(Msg)
		end
		return
	end
end

--Returns the Distance between 2 BaseParts.
function Auxillery.InstanceFunctions:GetDistance(Inst1 : BasePart, Inst2 : BasePart) : number
	Auxillery:AssertWarn(typeof(Inst1) == "Instance", tostring(Inst1).." isn't a Instance.")
	Auxillery:AssertWarn(typeof(Inst2) == "Instance", tostring(Inst2).." isn't a Instance.")

	Auxillery:AssertWarn(Inst1:IsA("BasePart"), tostring(Inst1).." isn't a BasePart.")
	Auxillery:AssertWarn(Inst2:IsA("BasePart"), tostring(Inst2).." isn't a BasePart.")

	return (Inst1.Position - Inst2.Position).Magnitude
end

--Creates a Debounce (Cooldown) for the given Instance. Returns true if it's still on cooldown
function Auxillery.InstanceFunctions:Debounce(Inst : Instance, Duration : number) : boolean
	Auxillery:AssertWarn(typeof(Inst) == "Instance", tostring(Inst).." isn't a Instance.")
	Auxillery:AssertWarn(typeof(Duration) == "number", Duration.." isn't a number.")

	if Debounces[Inst] then
		return true
	end
	local function Remove()
		Debounces[Inst] = nil
	end
	Debounces[Inst] = true
	task.delay(Duration, Remove)
	return false
end

--Returns a string descriping if the given Table is a Array or a Dictionary.
function Auxillery.TableFunctions:GetTableType(Table : {any}) : string
	Auxillery:AssertWarn(typeof(Table) == "table", tostring(Table).." isn't a table.")

	local Result = ""
	local Count = 0

	for _, _ in Table do
		Count += 1
	end

	if #Table == Count then
		Result = "Array"
	else 
		Result = "Dictionary"
	end

	return Result
end

--Used to correctly clone tables.
function Auxillery.TableFunctions:DeepCopy(val : any) : any
	local copy = nil
	if typeof(val) == "table" then
		copy = {}
		for n, v in pairs(val) do
			copy[n] = Auxillery.TableFunctions:DeepCopy(v)
		end
		setmetatable(copy, Auxillery.TableFunctions:DeepCopy(getmetatable(val)))
	else
		copy = val
	end

	return copy
end

--[[
	Creates a Instance.

	Type: The ClassName of the Instance

	Properties: A Dictionary which contains every Property and Value that should be set
]]
function Auxillery.InstanceFunctions:CreateInstance(Type : string, Properties : {any}) : Instance | nil
	Auxillery:AssertWarn(typeof(Type) == "string", Type.." isn't a string.")

	if Properties then
		Auxillery:AssertWarn(typeof(Properties) == "table", tostring(Properties).." is not a table.")
		Auxillery:AssertWarn(Auxillery.TableFunctions:GetTableType(Properties) == "Dictionary", "Properties table must be a Dictionary.")
	end

	local NewInstance = nil
	local function Create()
		NewInstance = Instance.new(Type)
		if Properties then
			for Property, Value in pairs(Properties) do
				if Auxillery.InstanceFunctions:SaveCheckProperty(NewInstance, Property) then
					NewInstance[Property] = Value
				end
			end
		end
	end
	pcall(Create)

	return NewInstance
end

--Checks if a Instance has the given Property without errors.
function Auxillery.InstanceFunctions:SaveCheckProperty(Inst : Instance, Property : string) : boolean
	Auxillery:AssertWarn(typeof(Inst) == "Instance", tostring(Inst).." isn't a Instance.")
	Auxillery:AssertWarn(typeof(Property) == "string", tostring(Property).." isn't a string.")

	local function Check()
		local P = Inst[Property]
	end
	local s = pcall(Check)
	return s
end

return Auxillery
