--!strict
local HitboxModule = {}

local Instance = require("../Standalone/BaseTypes/Instance")
local Services = require("../Standalone/Services")

export type HitboxArguments = {
	Origin: Model?,
	Prediction: Player?,

	Shape: string?,
	Reference: BasePart | CFrame,
	Size: any,

	OnHumanoidHit: (Humanoid: Humanoid) -> ()?,
	AdditionalCheck: ((Humanoid: Humanoid) -> boolean)?,

	OverlapParams: OverlapParams?,

	Debug: {
		ShowHitbox: boolean?,
		PrintProcessingTime: boolean?,
	}?,

	Stats: {
		Linger: {
			Duration: number,
			Interval: number,
			IgnoreParts: boolean?,
		}?,
		SelfHit: boolean?,
	},
}

export type RaycastArguments = {
	Part: BasePart,

	Size: number?,
	Duration: number,
	Offset: Vector3,
	DebugEnabled: boolean?,

	Prediction: Player?,

	RaycastParams: RaycastParams?,
}

local Shapes: { [string]: (Args: HitboxArguments) -> ({ BasePart }, CFrame) } = {
	Box = function(Args)
		local OriginCFrame = if typeof(Args.Reference) == "Instance"
			then Args.Reference.CFrame
			else Args.Reference :: CFrame

		if Args.Prediction and typeof(Args.Reference) == "Instance" then
			OriginCFrame *= CFrame.new(
				Args.Reference.AssemblyLinearVelocity * math.clamp(Args.Prediction:GetNetworkPing(), 0, 0.2)
			)
		end

		return workspace:GetPartBoundsInBox(OriginCFrame, Args.Size, Args.OverlapParams), OriginCFrame
	end,

	Sphere = function(Args)
		local OriginCFrame = if typeof(Args.Reference) == "Instance"
			then Args.Reference.CFrame
			else Args.Reference :: CFrame

		if Args.Prediction and typeof(Args.Reference) == "Instance" then
			OriginCFrame *= CFrame.new(
				Args.Reference.AssemblyLinearVelocity * math.clamp(Args.Prediction:GetNetworkPing(), 0, 0.2)
			)
		end

		return workspace:GetPartBoundsInRadius(OriginCFrame.Position, Args.Size, Args.OverlapParams), OriginCFrame
	end,
}
local ShapeToPartType = {
	Box = Enum.PartType.Block,
	Sphere = Enum.PartType.Ball,
}

function GetSpatialQueryResults(Args: HitboxArguments): ({ Humanoid }, { BasePart })
	local Callback = Args.OnHumanoidHit
	local HumanoidsHit = {}

	local StartTime = os.clock()
	local ShapeMethod = Shapes[Args.Shape or "Box"]

	local Parts, OriginCFrame = ShapeMethod(Args)

	for _, Part in pairs(Parts) do
		local ModelAnchestor = Part:FindFirstAncestorOfClass("Model")

		if not ModelAnchestor then
			continue
		end

		local TargetHitbox = ModelAnchestor:FindFirstChild("_CustomHitbox") or ModelAnchestor.PrimaryPart

		if not TargetHitbox or TargetHitbox.Name ~= Part.Name then
			continue
		end

		local Humanoid = ModelAnchestor:FindFirstChildOfClass("Humanoid")

		if Humanoid and not table.find(HumanoidsHit, Humanoid) then
			if (not Args.Stats.SelfHit) and ModelAnchestor == Args.Origin then
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
		local TranslatedSize = Args.Size

		if typeof(Args.Size) == "number" then
			TranslatedSize = Vector3.one * Args.Size
		end

		if Args.Debug.ShowHitbox then
			Services.D:AddItem(
				Instance:CreateInstance("Part", {
					Parent = workspace,
					CFrame = OriginCFrame,
					Size = TranslatedSize,
					Transparency = 0.8,
					Color = Color3.fromRGB(255, 0, 0),
					Material = Enum.Material.SmoothPlastic,
					CanCollide = false,
					Anchored = true,
					Shape = ShapeToPartType[Args.Shape or "Box"],
				}),
				0.1
			)
		end

		if Args.Debug.PrintProcessingTime then
			print(os.clock() - StartTime .. " Hitbox processing time.")
		end
	end

	return HumanoidsHit, Parts
end

function HitboxModule.Spawn(Args: HitboxArguments): ({ Humanoid }, { BasePart })
	assert(typeof(Args) == "table", "No Arguments given")
	assert(
		typeof(Args.Reference) == "Instance" or typeof(Args.Reference) == "table" or typeof(Args.Reference) == "CFrame",
		"Invalid Reference"
	)
	assert(Args.Stats, "Invalid Stats")

	if Args.Stats.Linger then
		assert(Args.Stats.Linger.Duration, `Invalid Linger Duration: {tostring(Args.Stats.Linger.Duration)}`)
		assert(Args.Stats.Linger.Interval, `Invalid Linger Interval: {tostring(Args.Stats.Linger.Interval)}`)

		local StartingTime = os.clock()

		while (os.clock() - StartingTime) < Args.Stats.Linger.Duration do
			task.wait(Args.Stats.Linger.Interval)

			local Hits, BaseParts = GetSpatialQueryResults(Args)
			local Count = #Hits

			if not Args.Stats.Linger.IgnoreParts then
				Count += #BaseParts
			end

			if Count ~= 0 then
				return Hits, BaseParts
			end
		end

		return {}, {}
	else
		return GetSpatialQueryResults(Args)
	end
end

function HitboxModule.LingerSpherecast(Params: RaycastArguments)
	local CurrentThread = coroutine.running()
	local Size = Params.Size

	assert(typeof(Size) == "number", "Size must be a number")

	local Bind
	local DebugPart

	if Params.DebugEnabled then
		DebugPart = Instance:CreateInstance("Part", {
			Parent = workspace,
			Shape = Enum.PartType.Ball,
			CanCollide = false,
			Transparency = 0.8,
			Anchored = true,
			Size = Vector3.one * Size
		})
	end

	local LastCF = Params.Part.CFrame

	Bind = Services.RNS:BindToSimulation(function(DeltaTime)
		local Part = Params.Part
		local CF = Part.CFrame

		local Velocity = Part.AssemblyLinearVelocity
		local AngularVelocity = Part.AssemblyAngularVelocity

		local Ping = 0

		if Params.Prediction then
			Ping = math.clamp(
				Params.Prediction:GetNetworkPing() * 0.5,
				0,
				0.15
			)
		end

		local PredictedCF =
			CF
			+ (Velocity * Ping)

		if AngularVelocity.Magnitude > 0.001 then
			local Axis = AngularVelocity.Unit
			local Angle = AngularVelocity.Magnitude * Ping

			PredictedCF *= CFrame.fromAxisAngle(Axis, Angle)
		end

		local Origin = PredictedCF.Position
		local Target = (PredictedCF * CFrame.new(Params.Offset)).Position

		local MovementDelta = CF.Position - LastCF.Position
		LastCF = CF

		local RayVector =
			(Target - Origin)
			+ MovementDelta

		local Result = workspace:Spherecast(
			Origin,
			Size,
			RayVector,
			Params.RaycastParams
		)

		if DebugPart then
			DebugPart.Position = Target
		end

		local Humanoid =
			if Result
			then Instance.FindHumanoidFromPart(Result.Instance)
			else nil

		if Result and Humanoid then
			Bind:Disconnect()
			coroutine.resume(CurrentThread, Humanoid, Result)
		end
	end, Enum.StepFrequency.Hz60)

	task.delay(Params.Duration, function()
		if Bind then
			Bind:Disconnect()
		end

		if DebugPart then
			DebugPart:Destroy()
		end
	end)

	return coroutine.yield()
end

function HitboxModule.LingerRaycast(Params: RaycastArguments)
	local CurrentThread = coroutine.running()

	local Bind
	local DebugPart

	if Params.DebugEnabled then
		DebugPart = Instance:CreateInstance("Part", {
			Parent = workspace,
			Size = Vector3.new(0.2, 0.2, 0.2),
			Anchored = false,
			CanCollide = false,
			Transparency = 0.8
		})
	end

	Bind = Services.RNS:BindToSimulation(function()
		local Origin = Params.Part.Position

		if Params.Prediction then
			Origin += Params.Part.AssemblyLinearVelocity * math.clamp(Params.Prediction:GetNetworkPing() * 1.05, 0, 0.2)
		end

		local Target = (Params.Part.CFrame * CFrame.new(Params.Offset)).Position
		local RayVector = (Target - Origin).Unit * (Params.Size or (Target - Origin).Magnitude)
		local Result: RaycastResult = workspace:Raycast(Origin, RayVector, Params.RaycastParams)

		if DebugPart then
			DebugPart.Position = Target
		end

		local Humanoid = if Result then Instance.FindHumanoidFromPart(Result.Instance) else nil
		if Result and Humanoid then
			Bind:Disconnect()
			coroutine.resume(CurrentThread, Humanoid, Result)
		end
	end, Enum.StepFrequency.Hz60)

	task.delay(Params.Duration, function()
		Bind:Disconnect()
	end)

	return coroutine.yield()
end

return HitboxModule
