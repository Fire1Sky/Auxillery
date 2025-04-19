--!strict
local HitboxModule = {}
local DefaultAccuracyMode : ("Inner" | "Outer") = "Inner"

local Instance = require("../LowLevel/BaseTypes/Instance")
local Services = require("../LowLevel/Services")
local String = require("../LowLevel/BaseTypes/String")

export type HitboxArguments = {
	Origin : Model?,
	Reference : BasePart | {CFrame : CFrame, Size : Vector3},
	ForceMode : ("Inner" | "Outer")?,
	OnHumanoidHit : (Humanoid : Humanoid) -> ()?,
	
	Debug : {
		ShowHitbox : boolean?,
		PrintProcessingTime : boolean?,
		PrintEstimatedProcessTime : number?
	}?,
	
	Stats : {
		Linger : {
			Duration : number,
			Interval : number
		}?,
		Damage : number,
		SelfHit : boolean?
	}
}

local function UpdateDefaultAccuracyMode()
	local FPS = workspace:GetRealPhysicsFPS()
	
	if FPS >= 40 then
		DefaultAccuracyMode = "Inner"
	else
		DefaultAccuracyMode = "Outer"
	end
end

local function GetPartsByMode(Reference : BasePart | {CFrame : CFrame, Size : Vector3}, Params : OverlapParams, ForceMode : ("Outer" | "Inner")?) : {BasePart}
	if typeof(Reference) == "table" then
		return workspace:GetPartBoundsInBox(Reference.CFrame, Reference.Size, Params)
	end
	
	if ForceMode == "Inner" then
		return workspace:GetPartsInPart(Reference, Params)
	else
		return workspace:GetPartBoundsInBox(Reference.CFrame, Reference.Size, Params)
	end
end

local function Summon(Args : HitboxArguments)
	local StartTime = os.clock()
	UpdateDefaultAccuracyMode()
	
	local OverlapParams = OverlapParams.new()
	if not Args.Stats.SelfHit and Args.Origin then
		OverlapParams.FilterDescendantsInstances = {Args.Origin}
	end
		
	local Parts = GetPartsByMode(Args.Reference, OverlapParams, Args.ForceMode or DefaultAccuracyMode)
	local Callback = Args.OnHumanoidHit
	
	if typeof(Callback) ~= "function" then
		Callback = function(Humanoid : Humanoid)
			Humanoid:TakeDamage(Args.Stats.Damage)
		end
	end
	assert(Callback) --mute typecheck engine
	local HumanoidsDamaged = {}
	
	for _, Part in pairs(Parts) do
		if not Part.Parent then continue end
		local Humanoid = Part.Parent:FindFirstChildOfClass("Humanoid")
		
		if Humanoid and not table.find(HumanoidsDamaged, Humanoid) then
			table.insert(HumanoidsDamaged, Humanoid)
			Callback(Humanoid)
		end
	end
	
	if Args.Debug then
		if Args.Debug.ShowHitbox then
			Services.D:AddItem(
				Instance:CreateInstance("Part", {
					Parent = workspace,
					CFrame = Args.Reference.CFrame,
					Size = Args.Reference.Size,
					Transparency = 0.5,
					Color = Color3.fromRGB(255,0,0),
					CanCollide = false
				}),
				0.1
			)	
		end
		if Args.Debug.PrintProcessingTime then
			print(os.clock() - StartTime.." Hitbox processing time.")
		end
		
		if Args.Debug.PrintEstimatedProcessTime then
			print(String:FormatTime((os.clock() - StartTime) * Args.Debug.PrintEstimatedProcessTime).." for "..Args.Debug.PrintEstimatedProcessTime.." Hitboxes")
		end
	end
end

function HitboxModule:Spawn(Args : HitboxArguments)
	assert(typeof(Args.Reference) == "Instance" or typeof(Args.Reference) == "table")
	assert(Args.Stats)
	assert(Args.Stats.Damage)
	Summon(Args)
	
	if Args.Stats.Linger then
		assert(Args.Stats.Linger.Duration)
		assert(Args.Stats.Linger.Interval)
		
		local StartingTime = os.clock()
		
		while (os.clock() - StartingTime) < Args.Stats.Linger.Duration do
			task.wait(Args.Stats.Linger.Interval)
			Summon(Args)
		end
	end
end

return HitboxModule