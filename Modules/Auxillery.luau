--!strict
local Auxillery = {}

local Services = {
	PLRS = game:GetService("Players"),
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
	BN = require(script:WaitForChild("BridgeNet2", 1)),
    HS = game:GetService("HttpService")
}

--Gets a table with <code>Service</code> shortcuts.
function Auxillery:GetServices()
	return Services
end

--[[
	Same functionality as <code>assert()</code>, but uses a warn instead in case you don't want the script to error.

	Arguments:

		Condition : If Condition is equal to false or nil the warn will trigger.

		Msg : The warn message that should be displayed.
]]
function Auxillery:AssertWarn(Condition : any, Msg : string)
	if not Condition then
		if Msg then
			warn(Msg)
		end
		return
	end
end

--[[
	Returns the Distance between 2 BaseParts.
]]
function Auxillery:GetDistance(Inst1 : BasePart, Inst2 : BasePart)
	Auxillery:AssertWarn(typeof(Inst1) == "Instance", "First given Argument isn't a Instance.")
	Auxillery:AssertWarn(typeof(Inst2) == "Instance", "Second given Argument isn't a Instance.")

	Auxillery:AssertWarn(Inst1:IsA("BasePart"), "First given Instance isn't a BasePart.")
	Auxillery:AssertWarn(Inst2:IsA("BasePart"), "Second given Instance isn't a BasePart.")
	
	return (Inst1.Position - Inst2.Position).Magnitude
end

--[[
	Returns a string descriping if the given Table is a Array or a Dictionary.
]]
function Auxillery:GetTableType(Table : {})
	Auxillery:AssertWarn(typeof(Table) == "table", "Given `table` isn't a table.")

	local Result = ""
	local Count = 0

	for _ in Table do
		Count += 1
	end

	if #Table == Count then
		Result = "Array"
	else 
		Result = "Dictionary"
	end

	return Result
end

--[[
	Creates a Instance.

	Arguments:

		Type : The ClassName of the Instance

		Properties : A Dictionary which contains every Property and Value that should be set
]]
function Auxillery:CreateInstance(Type : string, Properties : {any})
	Auxillery:AssertWarn(typeof(Type) == "string", "Type isn't a string.")

	if Properties then
		Auxillery:AssertWarn(typeof(Properties) == "table", "Properties table is not a table.")
		Auxillery:AssertWarn(Auxillery:GetTableType(Properties) == "Dictionary", "Properties table must be a Dictionary.")
	end

	local NewInstance = nil
	local function Create()
		NewInstance = Instance.new(Type)
		if Properties then
			for Property, Value in pairs(Properties) do
				if Auxillery:SaveCheckProperty(NewInstance, Property) then
					NewInstance[Property] = Value
				end
			end
		end
	end
	pcall(Create)

	return NewInstance
end

--[[
	Checks if a Instance has the given Property without errors.
	Returns a boolean
]]
function Auxillery:SaveCheckProperty(Inst : Instance, Property : string)
	Auxillery:AssertWarn(typeof(Inst) == "Instance", "First given Argument isn't a Instance.")
	Auxillery:AssertWarn(typeof(Property) == "string", "Second given Argument isn't a string.")

	local function Check()
		local P = Inst[Property]
	end
	local s = pcall(Check)
	return s
end

return Auxillery
