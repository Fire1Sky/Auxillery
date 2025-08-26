local CS = script.Components
local Standalone = CS.Standalone
local Dependants = CS.Dependants


local Auxillery = {
	Animate = require(Standalone.Animate),
	Loot = require(Standalone.Loot),
	Services = require(Standalone.Services),
	Instance = require(Standalone.BaseTypes.Instance),
	Table = require(Standalone.BaseTypes.Table),
	Number = require(Standalone.BaseTypes.Number),
	String = require(Standalone.BaseTypes.String),
	Emitter = require(Standalone.Emitter),
	Math = require(Standalone.Math),
	Input = require(Standalone.Input),

	Sound = require(Dependants.Sound),
	CustomSignals = require(Dependants.HeartbeatSignals),
	ExtendedInstance = require(Dependants.ExtendedInstance),
	Hitbox = require(Dependants.Hitbox),
	Keybinding = require(Dependants.Keybinding)
}

return Auxillery
