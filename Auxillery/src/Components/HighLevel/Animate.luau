--!strict

local Animate = {}

local DefaultArgs = {
	Priority = Enum.AnimationPriority.Action,
	Speed = 1,
	TimePosition = 0,
	Looped = false
}

local Instance = require(script.Parent.Parent.LowLevel.BaseTypes.Instance)

function Animate:LoadAnimation(AnimationController, Animation : Animation, GivenArgs : {Priority : Enum.AnimationPriority, Speed : number, Looped : boolean, TimePosition : number}?) : AnimationTrack
	assert(typeof(AnimationController) == "Instance", tostring(AnimationController).." isn't a Instance.")
	assert(AnimationController:IsA("AnimationController") or AnimationController:IsA("Animator") or AnimationController:IsA("Humanoid"), tostring(AnimationController).." isn't a valid Animation Controller.")
	assert((typeof(Animation) == "Instance" and Animation:IsA("Animation")), tostring(Animation).." isn't a Animation.")

	local Args = GivenArgs or DefaultArgs
	if AnimationController:IsA("Humanoid") then
		local Animator = AnimationController:FindFirstChildOfClass("Animator")
		if not Animator then
			AnimationController = Instance:CreateInstance("Animator", {Parent = AnimationController})
		else
			AnimationController = Animator
		end
	end
	
	local Track = AnimationController:LoadAnimation(Animation)

	repeat task.wait() until Track.Length > 0

	Track.Priority = Args.Priority or DefaultArgs.Priority
	Track:AdjustSpeed(Args.Speed or DefaultArgs.Speed)
	Track.TimePosition = Args.TimePosition or DefaultArgs.TimePosition
	Track.Looped = Args.Looped or DefaultArgs.Looped

	return Track
end

return Animate