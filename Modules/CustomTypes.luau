--!strict
--[[
    CustomTypes
    Allows the creation of custom types.
    Dependencies: Auxillery
]]

local CustomTypes = {
	Types = {}
}

local Mods = game.ReplicatedStorage:WaitForChild("Modules")
local Aux = require(Mods.Auxillery)

local TypeClass = {}
TypeClass.__index = TypeClass

export type Type = {
	Compare : (self : {any}, TableToCompare : {any}) -> boolean
}

--Checks if the given table is this specific type.
function TypeClass:Compare(TableToCompare : {}, Orig : {}?) : boolean
	Aux:AssertWarn(typeof(TableToCompare) == "table", tostring(TableToCompare).." isn't a table.")
	local success = true

	for n, v in pairs(TableToCompare) do
		if Orig then
			local CorrelatingTypeValue = Orig[n]
			
			if not ((typeof(v) == CorrelatingTypeValue) or (string.find(CorrelatingTypeValue, "?"))) then
				if typeof(CorrelatingTypeValue) == "table" and CorrelatingTypeValue.__optional then
					continue
				end
				success = false
				break
			end
			if typeof(v) == "table" then
				success = self:Compare(v, CorrelatingTypeValue)
			end
		else
			local CorrelatingTypeValue = self[n]

			--in case the value is entirely optional (indicated with the "?"), we should keep success at true
			if not ((typeof(v) == CorrelatingTypeValue) or (string.find(CorrelatingTypeValue, "?"))) then
				if typeof(CorrelatingTypeValue) == "table" and CorrelatingTypeValue.__optional then
					continue
				end
				success = false
				break
			end

			--if we have a nested type then we also have to compare descendants of the table
			if typeof(v) == "table" then
				success = self:Compare(v, CorrelatingTypeValue)
			end
		end
	end

	return success
end

local function new(Name, originaltable : {any}) : Type
	Aux:AssertWarn(Aux.TableFunctions:GetTableType(originaltable) == "Dictionary", tostring(originaltable).." must be a dictionary.")

	local self = Aux.TableFunctions:DeepCopy(originaltable)
	setmetatable(self, TypeClass)
	CustomTypes.Types[Name] = self
	table.freeze(self)
	return self
end

function CustomTypes:GetCustomType(TypeName) : Type | nil
	Aux:AssertWarn(typeof(TypeName) == "string", tostring(TypeName).." isn't a string.")

	if CustomTypes[TypeName] then
		return CustomTypes[TypeName]
	end
	
	return
end

function CustomTypes:CreateType(TypeName : string, TypeData : {any}) : Type
	Aux:AssertWarn(typeof(TypeName) == "string", tostring(TypeName).." isn't a string.")
	Aux:AssertWarn(typeof(TypeData) == "table", tostring(TypeData).." isn't a table.")
	Aux:AssertWarn(Aux.TableFunctions:GetTableType(TypeData) == "Dictionary", tostring(TypeData).." must be a Dictionary.")
	
	return new(TypeName, TypeData)
end

return CustomTypes