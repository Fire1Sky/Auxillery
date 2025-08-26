--!strict
local HitboxModule = {}
local DefaultAccuracyMode: "Inner" | "Outer" = "Inner"

local Instance = require("../Standalone/BaseTypes/Instance")
local Services = require("../Standalone/Services")
local String = require("../Standalone/BaseTypes/String")

local IsDynamicModeEnabled = false
local DynamicModeFPSTarget = 40

export type HitboxArguments = {
	Origin: Model?,
	Reference: BasePart | { CFrame: CFrame, Size: Vector3 },
	ForceMode: ("Inner" | "Outer")?,
	OnHumanoidHit: (Humanoid: Humanoid) -> ()?,
	AdditionalCheck: ((Humanoid: Humanoid) -> boolean)?,

	Debug: {
		ShowHitbox: boolean?,
		PrintProcessingTime: boolean?,
		PrintEstimatedProcessTime: number?,
	}?,

	Stats: {
		Linger: {
			Duration: number,
			Interval: number,
		}?,
		Damage: number?,
		SelfHit: boolean?,
		DealDamage: boolean?,
	},
}

local function UpdateDefaultAccuracyMode()
	local FPS = workspace:GetRealPhysicsFPS()

	if FPS >= DynamicModeFPSTarget then
		DefaultAccuracyMode = "Inner"
	else
		DefaultAccuracyMode = "Outer"
	end
end

local function GetPartsByMode(
	Reference: BasePart | { CFrame: CFrame, Size: Vector3 },
	Params: OverlapParams?,
	ForceMode: ("Outer" | "Inner")?
): { BasePart }
	if
		not IsDynamicModeEnabled
		or typeof(Reference) == "table"
		or ForceMode == "Outer"
		or DefaultAccuracyMode == "Outer"
	then
		return workspace:GetPartBoundsInBox(Reference.CFrame, Reference.Size, Params)
	end

	return workspace:GetPartsInPart(Reference, Params)
end

local function Summon(Args: HitboxArguments): { Humanoid }
	local StartTime = os.clock()

	if IsDynamicModeEnabled then
		UpdateDefaultAccuracyMode()
	end

	local Parts = GetPartsByMode(Args.Reference, nil, Args.ForceMode or DefaultAccuracyMode)
	local Callback = Args.OnHumanoidHit

	if typeof(Callback) ~= "function" and Args.Stats.DealDamage and Args.Stats.Damage then
		Callback = function(Humanoid: Humanoid)
			Humanoid:TakeDamage(Args.Stats.Damage)
		end
	end
	local HumanoidsHit = {}

	for _, Part in pairs(Parts) do
		if not Part.Parent then
			continue
		end

		if Part.Parent:FindFirstChild("_CustomHitbox") then
			if Part.Name ~= "_CustomHitbox" then
				continue
			end
		else
			if Part.Name ~= "HumanoidRootPart" then
				continue
			end
		end

		if not Part.Parent or Part.Name ~= "HumanoidRootPart" then
			continue
		end
		local Humanoid = Part.Parent:FindFirstChildOfClass("Humanoid")

		if Humanoid and not table.find(HumanoidsHit, Humanoid) then
			if (not Args.Stats.SelfHit) and Humanoid.Parent == Args.Origin then
				continue
			end

			if not Args.AdditionalCheck then
				table.insert(HumanoidsHit, Humanoid)
			end

			if Args.AdditionalCheck and Args.AdditionalCheck(Humanoid) then
				table.insert(HumanoidsHit, Humanoid)
			else
				continue
			end

			if Callback then
				Callback(Humanoid)
			end
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
					Color = Color3.fromRGB(255, 0, 0),
					Material = Enum.Material.SmoothPlastic,
					CanCollide = false,
					Anchored = true,
				}),
				0.1
			)
		end

		if Args.Debug.PrintProcessingTime then
			print(os.clock() - StartTime .. " Hitbox processing time.")
		end

		if Args.Debug.PrintEstimatedProcessTime then
			print(
				String:FormatTime((os.clock() - StartTime) * Args.Debug.PrintEstimatedProcessTime)
					.. " for "
					.. Args.Debug.PrintEstimatedProcessTime
					.. " Hitboxes"
			)
		end
	end

	return HumanoidsHit
end

function HitboxModule.ToggleDynamicMode(Enabled: boolean, FPSTarget: number?)
	IsDynamicModeEnabled = Enabled

	if FPSTarget then
		DynamicModeFPSTarget = FPSTarget
	end
end

function HitboxModule.Spawn(Args: HitboxArguments): { Humanoid }?
	assert(typeof(Args.Reference) == "Instance" or typeof(Args.Reference) == "table", "Invalid Reference")
	assert(Args.Stats, "Invalid Stats")

	if Args.Stats.Linger then
		assert(Args.Stats.Linger.Duration, "Invalid Linger Duration")
		assert(Args.Stats.Linger.Interval, "Invalid Linger Interval")

		local StartingTime = os.clock()

		while (os.clock() - StartingTime) < Args.Stats.Linger.Duration do
			task.wait(Args.Stats.Linger.Interval)
			Summon(Args)
		end
	else
		return Summon(Args)
	end

	return nil
end

return HitboxModule
