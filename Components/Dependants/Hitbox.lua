--!strict
local HitboxModule = {}

local Instance = require("../Standalone/BaseTypes/Instance")
local Services = require("../Standalone/Services")
local String = require("../Standalone/BaseTypes/String")

export type HitboxArguments = {
	Origin: Model?,
	
	Reference: BasePart | CFrame | {Reference: BasePart, Offset: CFrame},
	Size: Vector3?,

	OnHumanoidHit: (Humanoid: Humanoid) -> ()?,
	AdditionalCheck: ((Humanoid: Humanoid) -> boolean)?,

	OverlapParams: OverlapParams?,

	Debug: {
		ShowHitbox: boolean?,
		PrintProcessingTime: boolean?,
		PrintEstimatedProcessTime: number?,
	}?,

	Stats: {
		Linger: {
			Duration: number,
			Interval: number
		}?,
		SelfHit: boolean?,
	},
}

local function GetPartsByMode(
	Reference: BasePart | CFrame | {Reference: BasePart, Offset: CFrame},
	Params: OverlapParams?,
	Size: Vector3?
): ({ BasePart }, CFrame)
	if typeof(Reference) == "Instance" then
		return workspace:GetPartBoundsInBox(Reference.CFrame, Size, Params), Reference.CFrame
	elseif typeof(Reference) == "CFrame" then
		return workspace:GetPartBoundsInBox(Reference, Size, Params), Reference
	else
		return workspace:GetPartBoundsInBox(Reference.Reference.CFrame * Reference.Offset, Size, Params), Reference.Reference.CFrame * Reference.Offset
	end
end

local function Summon(Args: HitboxArguments): { Humanoid }
	local StartTime = os.clock()

	local Parts, CF = GetPartsByMode(Args.Reference, Args.OverlapParams, Args.Size)
	local Callback = Args.OnHumanoidHit

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
					CFrame = CF,
					Size = Args.Size,
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

function HitboxModule.Spawn(Args: HitboxArguments): { Humanoid }
	assert(typeof(Args) == "table", "No Arguments given")
	assert(typeof(Args.Reference) == "Instance" or typeof(Args.Reference) == "table" or typeof(Args.Reference) == "CFrame", "Invalid Reference")
	assert(Args.Stats, "Invalid Stats")

	if Args.Stats.Linger then
		assert(Args.Stats.Linger.Duration, `Invalid Linger Duration: {tostring(Args.Stats.Linger.Duration)}`)
		assert(Args.Stats.Linger.Interval, `Invalid Linger Interval: {tostring(Args.Stats.Linger.Interval)}`)

		local StartingTime = os.clock()

		while (os.clock() - StartingTime) < Args.Stats.Linger.Duration do
			task.wait(Args.Stats.Linger.Interval)

			local Hits = Summon(Args)

			if #Hits ~= 0 then
				return Hits
			end
		end

		return {}
	else
		return Summon(Args)
	end
end

return HitboxModule
