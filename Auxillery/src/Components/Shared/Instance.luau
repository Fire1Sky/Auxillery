--!strict
local InstanceModule = {
	Debounces = {}
}

local Table = require(script.Parent.Table)

--Creates a Debounce (Cooldown) for the given Instance. Returns true if it's still on cooldown
function InstanceModule:Debounce(Inst : Instance, Duration : number) : boolean?
	assert(typeof(Inst) == "Instance", tostring(Inst).." isn't a Instance.")
	assert(typeof(Duration) == "number", Duration.." isn't a number.")

	if InstanceModule.Debounces[Inst] then
		return true
	end

	local function Remove()
		InstanceModule.Debounces[Inst] = nil
	end

	InstanceModule.Debounces[Inst] = true
	task.delay(Duration, Remove)

	return false
end

--[[
	Creates a Instance.
	@Type: The ClassName of the Instance
	@Properties: A Dictionary which contains every Property and Value that should be set
]]
function InstanceModule:CreateInstance<T>(Type : string, Properties : {[string] : any}?) : T
	assert(typeof(Type) == "string", Type.." isn't a string.")

	if Properties then
		assert(typeof(Properties) == "table", tostring(Properties).." is not a table.")
		assert(Table:GetTableType(Properties) == "Dictionary", "Properties table must be a Dictionary.")
	end

	local NewInstance = Instance.new(Type)
	if Properties then
		for Property, Value in pairs(Properties) do
			if InstanceModule:SaveCheckProperty(NewInstance, Property) then
				NewInstance[Property] = Value
			end
		end
	end

	return NewInstance
end

--Checks if a Instance has the given Property.
function InstanceModule:SaveCheckProperty(Inst : any, Property : string) : boolean
	assert(typeof(Property) == "string", tostring(Property).." isn't a string.")

	local function Check()
		local P = Inst[Property]
	end
	local s = pcall(Check)
	return s
end

return InstanceModule