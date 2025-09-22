local ExtendedInstance = {}

local Instance = require("../Standalone/BaseTypes/Instance")

function ExtendedInstance:TableToInstance(Parent : Instance?, Table : {any})
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
			Instance:CreateInstance(Types[Type], {Parent = Parent, Name = Name, Value = Value})
		elseif Type == "table" then
			ExtendedInstance:TableToInstance(Instance:CreateInstance("Folder", {Parent = Parent, Name = Name}), Value)
		end
	end
end

function ExtendedInstance:InstanceToTable(Parent : Instance, Table : {})
	assert(typeof(Parent) == "Instance", tostring(Parent).." is a invalid Parent.")
	assert(typeof(Table) == "table", tostring(Table).." is a invalid table.")
	local Types = {
		StringValue = "StringValue",
		NumberValue = "NumberValue",
		BoolValue = "BoolValue",
		ObjectValue = "ObjectValue"
	}

	for _, Inst in pairs(Parent:GetChildren()) do
		local Type = Inst.ClassName
		if Types[Type] and Inst:IsA("ValueBase") then
			Table[Inst.Name] = Inst.Value
		elseif Type == "Folder" then
			local NewTab = {}
			Table[Inst.Name] = NewTab
			ExtendedInstance:InstanceToTable(Inst, NewTab)
		end
	end
end

function ExtendedInstance:ConnectInstanceToTable(Parent : Folder, Table : {[string] : any})
	assert(typeof(Parent) == "Instance", tostring(Parent).." is a invalid Parent.")
	assert(typeof(Table) == "table", tostring(Table).." is a invalid table.")

	for _, v in pairs(Parent:GetChildren()) do
		if v:IsA("Folder") then
			ExtendedInstance:ConnectInstanceToTable(v, Table[v.Name])
		elseif v:IsA("ValueBase") then
			local function OnValueChange()
				Table[v.Name] = v.Value
			end

			v:GetPropertyChangedSignal("Value"):Connect(OnValueChange)
		end
	end
end

return ExtendedInstance