local CS = script.Components
local LV = CS.LowLevel
local HL = CS.HighLevel

local Auxillery = {
	AI = require(HL.AI),
	Animate = require(HL.Animate),
	Loot = require(HL.Loot),
	Network = require(HL.Network),
	Services = require(HL.Services),
	Sound = require(HL.Sound),
	Tests = require(LV.Tests),
	CustomSignals = require(HL.CustomSignals),
	CustomTypes = require(HL.CustomTypes),
	Instance = require(LV.BaseTypes.Instance),
	Table = require(LV.BaseTypes.Table),
	Number = require(LV.BaseTypes.Number),
	String = require(LV.BaseTypes.String),
	Emitter = require(LV.Emitter)
}

local IsClient = game:GetService("RunService"):IsClient()

for _, v in pairs(CS:GetDescendants()) do
	if v:IsA("ModuleScript") then
		local Visibility = v:GetAttribute("AuxVisibility")
		
		if IsClient then
			if Visibility == "Server" then 
				v:Destroy()
			end
		else
			if Visibility == "Client" then 
				v:Destroy()
			end
		end
	end
end

return Auxillery