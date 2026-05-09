--!strict
local NumberModule = {}
local BooleanOptions = {
	["true"] = 1,
	["false"] = 0
}

local Constants = require("../../Constants")
--[[
	Checks if TargetNumber is withing a specified MaxDistance from the ReferenceNumber.
	Returns a boolean indicating if the TargetNumber is within the range of the ReferenceNumber and the actual Distance.
]]
function NumberModule.NumberInRange(ReferenceNumber: number, TargetNumber: number, MaxDistance: number)
	assert(typeof(ReferenceNumber) == "number", Constants.INVALID_TYPE:format("number", typeof(ReferenceNumber)))
	assert(typeof(TargetNumber) == "number", Constants.INVALID_TYPE:format("number", typeof(TargetNumber)))
	assert(typeof(MaxDistance) == "number", Constants.INVALID_TYPE:format("number", typeof(MaxDistance)))

	local dist = math.abs(ReferenceNumber - TargetNumber)
	local iswithinRange = dist < MaxDistance

	return iswithinRange, dist
end

function NumberModule.BooleanToNumber(Boolean : boolean)
	return BooleanOptions[tostring(Boolean)]
end

function NumberModule.DecimalLock(Number : number, Decimals : number)
	local Mult = 10 ^ Decimals
	return math.floor(Number * Mult) / Mult
end

return NumberModule