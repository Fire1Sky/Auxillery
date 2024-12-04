--[[
    Animate
    Recyles Animations to prevent reloading animations.
    Dependencies: Auxillery
]]

local Animate = {}
local AnimationRunners = {}

local Mods = script.Parent
local Aux = require(Mods.Auxillery)

local DefaultArgs = {
	Priority = Enum.AnimationPriority.Action,
	Speed = 1,
	TimePosition = 0,
	Looped = false
}

local function CreateAnimationRunner(AnimationController : Humanoid | AnimationController | Animator)
	AnimationRunners[AnimationController] = {}
	local AnimationRunner = AnimationRunners[AnimationController]

	return AnimationRunner
end

local function FindAnimationTrack(AnimationRunner : {any}, Animation : Animation | number)
	if typeof(Animation) == "number" then
		for i, v in pairs(AnimationRunner) do
			if v.AnimationId == "rbxassetid://"..Animation then
				return v, i
			end
		end
	else
		for i, v in pairs(AnimationRunner) do
			if v.Animation.AnimationId == Animation.AnimationId then
				return v, i
			end
		end
	end
end

function Animate:LoadAnimation(AnimationController : Humanoid | AnimationController | Animator, Animation : Animation | number, GivenArgs : {})
	Aux:AssertWarn(typeof(AnimationController) == "Instance", tostring(AnimationController).." isn't a Instance.")
	Aux:AssertWarn(AnimationController:IsA("Humanoid") or AnimationController:IsA("AnimationController") or AnimationController:IsA("Animator"), tostring(AnimationController).." isn't a valid Animation Controller.")

	Aux:AssertWarn((typeof(Animation) == "Instance" and Animation:IsA("Animation")) or typeof(Animation) == "number", tostring(Animation).." isn't a Animation or a number.")

	local AnimationRunner = AnimationRunners[AnimationController]

	if not AnimationRunner then
		AnimationRunner = CreateAnimationRunner(AnimationController)
	end

	local Args = GivenArgs or DefaultArgs

	local Track = FindAnimationTrack(AnimationRunner, Animation)
	if Track then
		Track.TimePosition = Args.TimePosition or DefaultArgs.TimePosition
		Track.Priority = Args.Priority or DefaultArgs.Priority
		Track.Looped = Args.Looped or DefaultArgs.Looped
		Track:AdjustSpeed(Args.Speed or DefaultArgs.Speed)
	else
		if typeof(Animation) == "number" then
			local AnimInstance = Aux:CreateInstance("Animation", {AnimationId = "rbxassetid://"..Animation})
			Track = AnimationController:LoadAnimation(AnimInstance)
			AnimInstance:Destroy()
		else
			Track = AnimationController:LoadAnimation(Animation)
		end

		Track.TimePosition = Args.TimePosition or DefaultArgs.TimePosition
		Track.Priority = Args.Priority or DefaultArgs.Priority
		Track.Looped = Args.Looped or DefaultArgs.Looped
		Track:AdjustSpeed(Args.Speed or DefaultArgs.Speed)
		table.insert(AnimationRunner, Track)
	end

	return Track
end

function Animate:UnloadAnimation(AnimationController : Humanoid | AnimationController | Animator, Animation : Animation | number)
	Aux:AssertWarn(typeof(AnimationController) == "Instance", tostring(AnimationController).." isn't a Instance.")
	Aux:AssertWarn(AnimationController:IsA("Humanoid") or AnimationController:IsA("AnimationController") or AnimationController:IsA("Animator"), tostring(AnimationController).." isn't a valid Animation Controller.")

	Aux:AssertWarn((typeof(Animation) == "Instance" and Animation:IsA("Animation")) or typeof(Animation) == "number", tostring(Animation).." isn't a Animation or a number.")

	local AnimationRunner = AnimationRunners[AnimationController]
	Aux:AssertWarn(AnimationRunner, "AnimationController has not been used.")

	local Track, Index = FindAnimationTrack(AnimationRunner, Animation)
	Aux:AssertWarn(Track, "Animation doesn't exist.")
	table.remove(AnimationRunner, Index)
	Track:Destroy()
end

return Animate
