--!strict

local Animate = {}

local DefaultArgs = {
	Priority = Enum.AnimationPriority.Action,
	Speed = 1,
	TimePosition = 0,
	Looped = false
}

function Animate:LoadAnimation(Animator : Animator, Animation : Animation, GivenArgs : {Priority : Enum.AnimationPriority, Speed : number, Looped : boolean, TimePosition : number}?) : AnimationTrack
	assert(typeof(Animator) == "Instance" and Animator:IsA("Animator"), tostring(Animator).." isn't a Instance.")
	assert((typeof(Animation) == "Instance" and Animation:IsA("Animation")), tostring(Animation).." isn't a Animation.")

	local Args = GivenArgs or DefaultArgs
	
	local Track = Animator:LoadAnimation(Animation)

	while Track.Length == 0 do
		task.wait()
	end

	Track.Priority = Args.Priority or DefaultArgs.Priority
	Track:AdjustSpeed(Args.Speed or DefaultArgs.Speed)
	Track.TimePosition = Args.TimePosition or DefaultArgs.TimePosition
	Track.Looped = Args.Looped or DefaultArgs.Looped

	return Track
end

return Animate