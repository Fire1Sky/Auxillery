--!strict
--[[
	Auxiliary
	Contains a bunch of functionality, allowing cleaner code.
	Dependencies: BridgeNet2 (https://github.com/ffrostfall/BridgeNet2)
]]

local Auxiliary = {
	InstanceFunctions = {},
	TableFunctions = {}
}

local Debounces = {}

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

--Gets a table with Service shortcuts.
function Auxiliary:GetServices()
	return Services
end

--[[
	Awaits and returns a value from the given table.

	tab: the table to look into.

	key: the key that will be waited for.

	timeout: optional argument which stops yielding the code after runtime exceeds the timeout value.
]]
function Auxiliary.TableFunctions:Await(tab : {}, key : any, timeout : number?) : any?
	assert(typeof(tab) == "table", tostring(tab).." isn't a table.")
	assert(key, "key is nil.")

	local runtime = 0

	if not tab[key] then
		local printed = false
		local ldT = 0
		local ldTConnection = nil

		local function UpdateldT(dt : number)
			ldT = dt
		end

		ldTConnection = Services.RNS.Heartbeat:Connect(UpdateldT)

		repeat
			if Auxiliary:NumberInRange(5, runtime, 0.1) and (not printed) then
				printed = true
				warn("Waiting time exceeded 5 seconds with table "..tostring(tab).." and key "..tostring(key))
			end
			runtime += ldT
			Services.RNS.Heartbeat:Wait()
		until tab[key] or (typeof(timeout) == "number" and runtime >= timeout)

		ldTConnection:Disconnect()
	end

	return tab[key], runtime
end

function Auxiliary:AssertWarn(Condition : boolean, Msg : string) : boolean
	if not Condition then
		if Msg then
			warn(Msg)
		end
		return true
	end
	return false
end

function Auxiliary.TableFunctions:TableToInstance(Parent : Instance, Table : {any})
	assert(typeof(Parent) == "Instance", tostring(Parent).." is a invalid Parent.")
	assert(typeof(Table) == "table", tostring(Table).." is a invalid table.")
	local Types = {
		string = "StringValue",
		number = "NumberValue",
		boolean = "BoolValue",
		Instance = "ObjectValue"
	}

	for Name, Value in pairs(Table) do
		local Type = typeof(Value)
		if Types[Type] then
			Auxiliary.InstanceFunctions:CreateInstance(Types[Type], {Parent = Parent, Name = Name, Value = Value})
		elseif Type == "table" then
			Auxiliary.TableFunctions:TableToInstance(Auxiliary.InstanceFunctions:CreateInstance("Folder", {Parent = Parent, Name = Name}), Value)
		end
	end
end

function Auxiliary.TableFunctions:ConnectInstanceToTable(Parent : Instance, Table : {any})
	assert(typeof(Parent) == "Instance", tostring(Parent).." is a invalid Parent.")
	assert(typeof(Table) == "table", tostring(Table).." is a invalid table.")

	for _, v in pairs(Parent:GetChildren()) do
		if v:IsA("Folder") then
			Auxiliary.TableFunctions:ConnectInstanceToTable(v, Table[v.Name])
		else
			local function OnValueChange()
				Table[v.Name] = v.Value
			end

			v:GetPropertyChangedSignal("Value", OnValueChange)
		end
	end
end

function Auxiliary.TableFunctions:Compare(BaseTable: {any}, TableToCompare: {any}): boolean
	assert(typeof(BaseTable) == "table", "Invalid table.")
	assert(typeof(TableToCompare) == "table", "Invalid table.")
	if next(BaseTable) and not next(TableToCompare) then
		return false
	end

	for key, base in pairs(BaseTable) do
		if tostring(key) == "__optional" then return true end
		local expected = TableToCompare[key]

		if expected then
			if typeof(expected) == "table" then
				if Auxiliary.TableFunctions:Compare(base, expected) then
					continue
				else
					return false
				end
			end
			if typeof(expected) ~= string.gsub(base, "?","") then
				warn(key.." ("..typeof(expected)..") doesn't equal to expected "..base.." type.")
				return false
			end
		elseif expected == nil then
			if typeof(base) == "string" and string.find(base, "?") then
				continue
			elseif typeof(base) == "table" and base.__optional then
				continue
			end

			warn(key.." isn't within "..tostring(TableToCompare))
			return false
		end
	end

	return true
end

--[[
	Checks if TargetNumber is withing a specified MaxDistance from the ReferenceNumber.
	
	Returns a boolean indicating if the TargetNumber is within the range of the ReferenceNumber and the actual Distance.
]]
function Auxiliary:NumberInRange(ReferenceNumber : number, TargetNumber : number, MaxDistance : number)
	assert(typeof(ReferenceNumber) == "number", tostring(ReferenceNumber).." isn't a number.")
	assert(typeof(TargetNumber) == "number", tostring(TargetNumber).." isn't a number.")
	assert(typeof(MaxDistance) == "number", tostring(MaxDistance).." isn't a number.")

	local dist = math.abs(ReferenceNumber - TargetNumber)
	local iswithinRange = dist < MaxDistance

	return iswithinRange, dist
end

--Returns a random ID.
function Auxiliary:GenerateRandomId(length : number?) : string
	local UsableSymbols = {
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"0","1","2","3","4","5","6","7","8","9"
	}
	
	local ID = ""
	for i = 1, length or 10 do
		local isupper = math.random(1,2) == 1

		if isupper then
			ID = ID..string.upper(UsableSymbols[math.random(1, #UsableSymbols)])
		else
			ID = ID..UsableSymbols[math.random(1, #UsableSymbols)]
		end
	end

	return ID
end

--Returns the Distance between 2 BaseParts.
function Auxiliary.InstanceFunctions:GetDistance(Inst1 : BasePart, Inst2 : BasePart) : number?
	assert(typeof(Inst1) == "Instance", tostring(Inst1).." isn't a Instance.")
	assert(typeof(Inst2) == "Instance", tostring(Inst2).." isn't a Instance.")

	assert(Inst1:IsA("BasePart"), tostring(Inst1).." isn't a BasePart.")
	assert(Inst2:IsA("BasePart"), tostring(Inst2).." isn't a BasePart.")

	return (Inst1.Position - Inst2.Position).Magnitude
end

--Creates a Debounce (Cooldown) for the given Instance. Returns true if it's still on cooldown
function Auxiliary.InstanceFunctions:Debounce(Inst : Instance, Duration : number) : boolean?
	assert(typeof(Inst) == "Instance", tostring(Inst).." isn't a Instance.")
	assert(typeof(Duration) == "number", Duration.." isn't a number.")

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
function Auxiliary.TableFunctions:GetTableType(Table : {}) : string?
	assert(typeof(Table) == "table", tostring(Table).." isn't a table.")

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
function Auxiliary.TableFunctions:DeepCopy(val : any) : any
	local copy = nil
	if typeof(val) == "table" then
		copy = {}
		for n, v in pairs(val) do
			copy[n] = Auxiliary.TableFunctions:DeepCopy(v)
		end
		setmetatable(copy, Auxiliary.TableFunctions:DeepCopy(getmetatable(val)))
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
function Auxiliary.InstanceFunctions:CreateInstance(Type : string, Properties : {[string] : any}?)
	assert(typeof(Type) == "string", Type.." isn't a string.")

	if Properties then
		assert(typeof(Properties) == "table", tostring(Properties).." is not a table.")
		assert(Auxiliary.TableFunctions:GetTableType(Properties) == "Dictionary", "Properties table must be a Dictionary.")
	end

	local NewInstance = nil
	local function Create()
		NewInstance = Instance.new(Type)
		if Properties then
			for Property, Value in pairs(Properties) do
				if Auxiliary.InstanceFunctions:SaveCheckProperty(NewInstance, Property) then
					NewInstance[Property] = Value
				end
			end
		end
	end
	pcall(Create)

	return NewInstance
end

--Checks if a Instance has the given Property without errors.
function Auxiliary.InstanceFunctions:SaveCheckProperty(Inst : Instance, Property : string) : boolean
	assert(typeof(Inst) == "Instance", tostring(Inst).." isn't a Instance.")
	assert(typeof(Property) == "string", tostring(Property).." isn't a string.")

	local function Check()
		local P = Inst[Property]
	end
	local s = pcall(Check)
	return s
end

return Auxiliary
