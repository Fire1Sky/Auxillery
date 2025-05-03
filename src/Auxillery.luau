local CS = script.Components
local LV = CS.LowLevel
local HL = CS.HighLevel


local Auxillery = {
	Animate = require(HL.Animate),
	Loot = require(LV.Loot),
	Services = require(LV.Services),
	Sound = require(HL.Sound),
	CustomSignals = require(HL.HeartbeatSignals),
	Instance = require(LV.BaseTypes.Instance),
	Table = require(LV.BaseTypes.Table),
	Number = require(LV.BaseTypes.Number),
	String = require(LV.BaseTypes.String),
	Emitter = require(LV.Emitter),
	ExtendedInstance = require(HL.ExtendedInstance),
	Hitbox = require(HL.Hitbox)
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
