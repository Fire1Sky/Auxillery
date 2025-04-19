--!strict
local InstanceModule = {}

--[[
	Creates a Instance.
	@Type: The ClassName of the Instance
	@Properties: A Dictionary which contains every Property and Value that should be set
]]
function InstanceModule:CreateInstance<T>(Type : string, Properties : {[string] : any}?) : T
	assert(typeof(Type) == "string", Type.." isn't a string.")

	if Properties then
		assert(typeof(Properties) == "table", tostring(Properties).." is not a table.")
	end

	local NewInstance = Instance.new(Type)
	if Properties then
		for Property, Value in pairs(Properties) do
			if InstanceModule:SafeCheckProperty(NewInstance, Property) then
				NewInstance[Property] = Value
			end
		end
	end

	return NewInstance
end

--Checks if a Instance has the given Property.
function InstanceModule:SafeCheckProperty(Inst : any, Property : string) : boolean
	assert(typeof(Property) == "string", tostring(Property).." isn't a string.")

	local function Check()
		local P = Inst[Property]
	end
	local s = pcall(Check)
	return s
end

return InstanceModule