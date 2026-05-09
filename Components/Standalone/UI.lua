local RNS = game:GetService("RunService")
local UI = {}

local PulseThreads = {}

function UI.MultiplyUDim2(UDim: UDim2, Multiplier: number): UDim2
    return UDim2.fromScale(
        UDim.X.Scale * Multiplier, 
        UDim.Y.Scale * Multiplier
    )
end

function UI.V2ToU2(V2: Vector2, Mode: ("Offset" | "Scale")?): UDim2
	return UDim2["from"..(Mode or "Scale")](V2.X, V2.Y)
end

function UI.U2ToV2(U2: UDim2, Mode: ("Offset" | "Scale")?): Vector2
	local X = U2.X[Mode or "Scale"]
	local Y = U2.Y[Mode or "Scale"]

	return Vector2.new(
		X,
		Y
	)
end

function UI.Pulse(
		Frame: GuiObject,
		Multiplier: number,
		Time: number,
		Peak: number
	)
	
	local HalfTime = Peak * Time
	local LastFrame = os.clock()
	local TimePassed = 0
	
	local PreviousThread = PulseThreads[Frame.Name]

	if PreviousThread then
		task.cancel(PreviousThread.Thread)
		Frame.Size = PreviousThread.Size
		TimePassed = HalfTime
	end

	local OriginalSize = Frame.Size
	local PeakSize = UI.MultiplyUDim2(OriginalSize, Multiplier)
	
	local function InitiatePulse()
		while task.wait() do
			if TimePassed > Time then
				break
			end

			TimePassed += os.clock() - LastFrame
			local T = TimePassed / Time
			local Lerp

			if TimePassed > HalfTime then
				Lerp = UDim2.fromScale(
					math.lerp(PeakSize.X.Scale, OriginalSize.X.Scale, (T - 0.5) * 2),
					math.lerp(PeakSize.Y.Scale, OriginalSize.Y.Scale, (T - 0.5) * 2)
				)
			else
				Lerp = UDim2.fromScale(
					math.lerp(OriginalSize.X.Scale, PeakSize.X.Scale, T * 2),
					math.lerp(OriginalSize.Y.Scale, PeakSize.Y.Scale, T * 2)
				)
			end

			LastFrame = os.clock()
			Frame.Size = Lerp
		end
		
		PulseThreads[Frame.Name] = nil
	end
	
	local Thread = coroutine.create(InitiatePulse)
	PulseThreads[Frame.Name] = {Thread = Thread, Size = OriginalSize}
	coroutine.resume(Thread)
end

function UI.GradientFade(Gradient: UIGradient, Duration: number, Rotation: number?, FadeOut: boolean?)
	if Rotation then
		Gradient.Rotation = Rotation
	end

	local Connection
	local T = os.clock()
	Connection = RNS.Heartbeat:Connect(function()
		local Elapsed = os.clock() - T

		if Elapsed > Duration then
			Connection:Disconnect()
			return
		end

		local Transformed = math.min(Elapsed / Duration, 1)
		local End = math.min(Transformed + 0.025, 1)
		local EndKeypoint = nil

		if Transformed < 0.025 then
			End = Transformed
		end

		if End < 0.95 then 
			EndKeypoint = NumberSequenceKeypoint.new(End, if FadeOut then 0 else 1)
		end

		if FadeOut then
			local Sequence = {
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(Transformed, 1),
				NumberSequenceKeypoint.new(1, 0)
			}

			if EndKeypoint then
				table.insert(Sequence, 3, EndKeypoint)
			end

			Gradient.Transparency = NumberSequence.new(Sequence)

			return
		end

		local Sequence = {
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(Transformed, 0),
			NumberSequenceKeypoint.new(1, 1)
		}

		if EndKeypoint then
			table.insert(Sequence, 3, EndKeypoint)
		end

		Gradient.Transparency = NumberSequence.new(Sequence)
	end)
end

return UI