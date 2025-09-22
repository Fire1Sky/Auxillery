--!strict
local SoundModule = {}
local SoundClass : SoundClass = {}
SoundClass.__index = SoundClass

local Emitter = require("../Standalone/Emitter")

local GlobalEmitter = Emitter.new()
SoundModule.GlobalEmitter = GlobalEmitter

export type SoundObject = typeof(
	setmetatable({} :: SoundProperties,
	{} :: SoundClass
))
export type SoundClass = {
	__index : SoundClass,
	
	GetFatigueVolume : (self : SoundObject) -> number,
	Play : (self : SoundObject) -> ()
}
export type SoundProperties = {
	SoundInstance : AudioPlayer,
	Volume : number,
	BasePart : BasePart
}

function SoundModule.new(Sound : SoundProperties) : SoundObject
	local self = setmetatable(Sound, SoundClass)
	self.SoundInstance.AutoLoad = true
	return self
end

function SoundClass:Play()
	GlobalEmitter:Fire("SoundPlayed", self)
	self.SoundInstance:Play()
end

function SoundClass:GetFatigueVolume()
	return math.random(self.SoundInstance.PlaybackSpeed * 0.95, self.SoundInstance.PlaybackSpeed * 1.05)
end

return SoundModule