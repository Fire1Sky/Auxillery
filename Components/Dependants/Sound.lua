local AudioControl = {}
local Instance = require("../Standalone/BaseTypes/Instance")

local Output: AudioDeviceOutput
AudioControl.Output = nil :: any & AudioDeviceOutput

local Random = Random.new()

function AudioControl.Init(): AudioDeviceOutput
	if Output and Output.Parent ~= nil then
		return Output
	end
	
	local Listener = Instance:CreateInstance("AudioListener", {Parent = workspace.CurrentCamera})
	local CreatedOutput: AudioDeviceOutput = Instance:CreateInstance("AudioDeviceOutput", {Parent = workspace.CurrentCamera})
	Output = CreatedOutput
	
	Instance:CreateInstance("Wire", {
		Parent = Output,
		SourceInstance = Listener,
		TargetInstance = Output
	})
	
	AudioControl.Output = Output
	
	return CreatedOutput
end

function AudioControl.Play(
		Source: AudioPlayer,
		Target: AudioEmitter | AudioDeviceOutput?,
		Settings: {
			Effects: {Instance}?,
			Clone: boolean?,
			Fatigue: boolean?
		}?
	)
	local GivenSettings = Settings or {}

	Source.PlaybackSpeed = 1

	if not Target then
		Target = Output or AudioControl.Init() :: AudioDeviceOutput
	end
	
	if GivenSettings.Clone then
		local RSource = Source
		Source = Source:Clone()
		Source.Parent = RSource
		Source.Name = Source.Name.."_Clone"
		
		Source.Ended:Once(function()
			Source:Destroy()
		end)
	end
	
	for _, v in pairs(Source:GetChildren()) do
		if v:IsA("Wire") then
			v:Destroy()
		end
	end
	
	local LastSource = Source
	
	if GivenSettings.Effects then
		for _, v in ipairs(GivenSettings.Effects) do
			AudioControl.Connect(LastSource, v, Source)
			LastSource = v
		end
	end
	
	AudioControl.Connect(LastSource, Target, Source)

	if GivenSettings.Fatigue then
		Source.PlaybackSpeed *= Random:NextNumber(0.95, 1.05)
		
		Source.Ended:Once(function()
			Source.PlaybackSpeed = 1
		end)
	end

	Source.TimePosition = 0
	Source:Play()
end

function AudioControl.Connect(Source: Instance, Target: AudioEmitter | AudioDeviceOutput?, Parent: Instance?)
	Instance:CreateInstance("Wire", {
		Parent = Parent or Source,
		SourceInstance = Source,
		TargetInstance = Target
	})
end

function AudioControl.GetAudioEmitter(Model: Model): AudioEmitter
	return Model:FindFirstChildOfClass("AudioEmitter") or Instance:CreateInstance("AudioEmitter", {Parent = Model})
end

return AudioControl