--!strict

local Animate = {}

local DefaultArgs = {
	Priority = Enum.AnimationPriority.Action,
	Speed = 1,
	TimePosition = 0,
	Looped = false,
}

local Constants = require("../Constants")

function Animate.LoadAnimation(
	Animator: Animator,
	Animation: Animation,
	GivenArgs: {
		Priority: Enum.AnimationPriority?,
		Speed: number?,
		Looped: boolean?,
		TimePosition: number?,
	}?
): AnimationTrack
	assert(typeof(Animator) == "Instance" and Animator:IsA("Animator"), Constants.INVALID_TYPE:format("Animator", (typeof(Animator) == "Instance" and Animator.ClassName) or typeof(Animator)))
	assert(
		(typeof(Animation) == "Instance" and Animation:IsA("Animation")),
		Constants.INVALID_TYPE:format("Animation", (typeof(Animation) == "Instance" and Animation.ClassName) or typeof(Animation))
	)

	local Args = GivenArgs or DefaultArgs
	for Name, Value in pairs(DefaultArgs) do
		if not Args[Name] then
			Args[Name] = Value
		end
	end

	local Track = Animator:LoadAnimation(Animation)

	Track.Priority = Args.Priority or DefaultArgs.Priority
	Track:AdjustSpeed(Args.Speed or DefaultArgs.Speed)
	Track.TimePosition = Args.TimePosition or DefaultArgs.TimePosition
	Track.Looped = Args.Looped or DefaultArgs.Looped

	return Track
end

return Animate
