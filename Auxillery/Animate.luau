--!strict
--[[
    Animate
   	Cleanly load animations.
   	Dependencies: Auxiliary
]]

local Animate = {}

local DefaultArgs = {
	Priority = Enum.AnimationPriority.Action,
	Speed = 1,
	TimePosition = 0,
	Looped = false
}

local Aux = require(script.Parent.Auxiliary)

function Animate:LoadAnimation(AnimationController : AnimationController | Animator | Humanoid, Animation : Animation, GivenArgs : {Priority : Enum.AnimationPriority, Speed : number, Looped : boolean, TimePosition : number}?) : AnimationTrack
	assert(typeof(AnimationController) == "Instance", tostring(AnimationController).." isn't a Instance.")
	assert(AnimationController:IsA("AnimationController") or AnimationController:IsA("Animator") or AnimationController:IsA("Humanoid"), tostring(AnimationController).." isn't a valid Animation Controller.")
	assert((typeof(Animation) == "Instance" and Animation:IsA("Animation")), tostring(Animation).." isn't a Animation.")

	local Args = GivenArgs or DefaultArgs
	local Track = nil
	
	if AnimationController:IsA("Humanoid") or AnimationController:IsA("AnimationController") then
		local Animator = AnimationController:FindFirstChildOfClass("Animator") :: Animator
		if not Animator then
			Animator = Aux.InstanceFunctions:CreateInstance("Animator", {Parent = AnimationController})
		end
		
		Track = Animator:LoadAnimation(Animation)
	else
		Track = AnimationController:LoadAnimation(Animation)
	end

	repeat task.wait() until Track.Length > 0

	Track.Priority = Args.Priority or DefaultArgs.Priority
	Track:AdjustSpeed(Args.Speed or DefaultArgs.Speed)
	Track.TimePosition = Args.TimePosition or DefaultArgs.TimePosition
	Track.Looped = Args.Looped or DefaultArgs.Looped

	return Track
end

return Animate