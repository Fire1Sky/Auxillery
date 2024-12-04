--!strict
--[[
    CustomTypes
    Allows the creation of custom types (just like type Name = {any})
    Dependencies: Auxillery
]]

local CustomTypes = {
    Types = {}
}

local Mods = game.ReplicatedStorage:WaitForChild("Modules")
local Aux = require(Mods.Auxillery)

local TypeClass = {}
TypeClass.__index = TypeClass

--Checks if the given table is this specific type.
function TypeClass:Compare(TableToCompare : {}, Orig : {}?) : boolean
    Aux:AssertWarn(typeof(TableToCompare) == "table", tostring(TableToCompare).." isn't a table.")
    local success = true

    for n, v in pairs(TableToCompare) do
        if Orig then
            local orval = Orig[n]
            if not orval then
                success = false
                break
            end
            if not ((typeof(v) == orval) or (string.find(orval, "?"))) then
                success = false
                break
            end
            if typeof(v) == "table" then
                success = self:Compare(v, orval)
            end
        else
            local orval = self[n]

            --this would set success to false if the given table having values inside which dont belong to the type. useful for similar types
            if not orval then
                success = false
                break
            end

            --in case the value is entirely optional (indicated with the "?"), we should keep success at true
            if not ((typeof(v) == orval) or (string.find(orval, "?"))) then
                success = false
                break
            end

            --if we have a nested type then we also have to compare descendants of the table
            if typeof(v) == "table" then
                success = self:Compare(v, orval)
            end
        end
    end

    return success
end

local function new(Name, originaltable : {any})
    Aux:AssertWarn(Aux.TableFunctions:GetTableType(originaltable) == "Dictionary", tostring(originaltable).." must be a dictionary.")

    local self = Aux:DeepCopy(originaltable)
    setmetatable(self, TypeClass)
    CustomTypes.Types[Name] = self
    table.freeze(self)
    return self
end

function CustomTypes:GetCustomType(TypeName, TypeData : {any}) : {}
    Aux:AssertWarn(typeof(TypeName) == "string", tostring(TypeName).." isn't a string.")

    if CustomTypes[TypeName] then
        return CustomTypes[TypeName]
    else
        Aux:AssertWarn(typeof(TypeData) == "table", tostring(TypeData).." isn't a table.")

        return new(TypeName, TypeData)
    end
end

return CustomTypes