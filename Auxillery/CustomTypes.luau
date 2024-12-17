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

function TypeClass:Compare(Other : {}) : boolean
	assert(typeof(Other) == "table" and Aux.TableFunctions:GetTableType(Other) == "Dictionary", "Invalid table.")
	return Aux.TableFunctions:Compare(self, Other, true)
end


local function new(Name, originaltable : {any})
	assert(Aux.TableFunctions:GetTableType(originaltable) == "Dictionary", tostring(originaltable).." must be a dictionary.")

	local self = Aux.TableFunctions:DeepCopy(originaltable)
	setmetatable(self, TypeClass)
	CustomTypes.Types[Name] = self
	table.freeze(self)
	return self
end

function CustomTypes:GetCustomType(TypeName)
	assert(typeof(TypeName) == "string", tostring(TypeName).." isn't a string.")

	if CustomTypes[TypeName] then
		return CustomTypes[TypeName]
	end

	return
end

function CustomTypes:CreateType(TypeName : string, TypeData : {any})
	assert(typeof(TypeName) == "string", tostring(TypeName).." isn't a string.")
	assert(typeof(TypeData) == "table", tostring(TypeData).." isn't a table.")
	assert(Aux.TableFunctions:GetTableType(TypeData) == "Dictionary", tostring(TypeData).." must be a Dictionary.")

	return new(TypeName, TypeData)
end

return CustomTypes