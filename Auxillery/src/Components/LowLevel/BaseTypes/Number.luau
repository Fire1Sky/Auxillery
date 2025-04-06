--!strict
local NumberModule = {}
local BooleanOptions = {
	["true"] = 1,
	["false"] = 0
}
--[[
	Checks if TargetNumber is withing a specified MaxDistance from the ReferenceNumber.
	Returns a boolean indicating if the TargetNumber is within the range of the ReferenceNumber and the actual Distance.
]]
function NumberModule:NumberInRange(ReferenceNumber : number, TargetNumber : number, MaxDistance : number)
	assert(typeof(ReferenceNumber) == "number", tostring(ReferenceNumber).." isn't a number.")
	assert(typeof(TargetNumber) == "number", tostring(TargetNumber).." isn't a number.")
	assert(typeof(MaxDistance) == "number", tostring(MaxDistance).." isn't a number.")

	local dist = math.abs(ReferenceNumber - TargetNumber)
	local iswithinRange = dist < MaxDistance

	return iswithinRange, dist
end

function NumberModule:BooleanToNumber(Boolean : boolean)
	return BooleanOptions[tostring(Boolean)]
end

return NumberModule