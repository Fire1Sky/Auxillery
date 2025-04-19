local CS = script.Components
local LV = CS.LowLevel
local HL = CS.HighLevel

local l = require

local Auxillery = {
	Animate = l(HL.Animate),
	Loot = l(LV.Loot),
	Services = l(LV.Services),
	Sound = l(HL.Sound),
	CustomSignals = l(HL.HeartbeatSignals),
	Instance = l(LV.BaseTypes.Instance),
	Table = l(LV.BaseTypes.Table),
	Number = l(LV.BaseTypes.Number),
	String = l(LV.BaseTypes.String),
	Emitter = l(LV.Emitter),
	Network = l(HL.Network),
	ExtendedInstance = l(HL.ExtendedInstance),
	Hitbox = l(HL.Hitbox)
}

local IsClient = game:GetService("RunService"):IsClient()

for _, v in pairs(CS:GetDescendants()) do
	if v:IsA("ModuleScript") then
		local Visibility = v:GetAttribute("AuxVisibility")
		
		if IsClient and Visibility == "Server" then
			v:Destroy()
		end
		
		if (not IsClient) and Visibility == "Client" then 
			v:Destroy()
		end
	end
end

return Auxillery
