--!strict
--[[
    CustomTypes
    Allows the creation of custom types.
    Dependencies: Auxillery
]]

local CustomTypes = {
	Types = {}
}

local Mods = script.Parent
local Aux = require(Mods.Auxiliary)

local TypeClass = {}
TypeClass.__index = TypeClass

export type Type = {
	Compare : (self : {any}, BaseTable : {any}, TableToCompare : {any}) -> boolean
}

function TypeClass:Compare(BaseTable: {any}, TableToCompare: {any}): boolean
	if next(BaseTable) and not next(TableToCompare) then
		return false
	end

	for key, base in pairs(BaseTable) do
		local expected = TableToCompare[key]

		if expected then
			if typeof(expected) == "table" then
				if TypeClass:Compare(base, expected) then
					continue
				else
					return false
				end
			end
		elseif expected == nil then
			print(key.." isn't within the table")
			if typeof(base) == "string" and string.find(base, "?") then
				continue
			elseif typeof(base) == "table" and base.__optional then
				continue
			end
			return false
		end
	end

	return true
end



local function new(Name, originaltable : {any}) : Type?
	Aux:AssertWarn(Aux.TableFunctions:GetTableType(originaltable) == "Dictionary", tostring(originaltable).." must be a dictionary.")

	local self = Aux.TableFunctions:DeepCopy(originaltable)
	setmetatable(self, TypeClass)
	CustomTypes.Types[Name] = self
	table.freeze(self)
	return self
end

function CustomTypes:GetCustomType(TypeName) : Type?
	Aux:AssertWarn(typeof(TypeName) == "string", tostring(TypeName).." isn't a string.")

	if CustomTypes[TypeName] then
		return CustomTypes[TypeName]
	end
	
	return
end

function CustomTypes:CreateType(TypeName : string, TypeData : {any}) : Type?
	Aux:AssertWarn(typeof(TypeName) == "string", tostring(TypeName).." isn't a string.")
	Aux:AssertWarn(typeof(TypeData) == "table", tostring(TypeData).." isn't a table.")
	Aux:AssertWarn(Aux.TableFunctions:GetTableType(TypeData) == "Dictionary", tostring(TypeData).." must be a Dictionary.")

	return new(TypeName, TypeData)
end

return CustomTypes