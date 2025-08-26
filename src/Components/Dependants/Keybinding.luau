local Keybinding = {}
local Instance = require("../Standalone/BaseTypes/Instance")

export type Action = InputAction & { GamepadBinding: InputBinding, KeyboardBinding: InputBinding }

local function GetContext(ContextName: string): InputContext
	local Context: InputContext = script.Contexts:FindFirstChild(ContextName)

	if not Context then
		Context = Instance:CreateInstance("InputContext", {
			Parent = script.Contexts,
			Name = ContextName,
			Enabled = false,
		})
	end

	return Context
end

local function GetAction(Context: InputContext, ActionName: string): Action
	local Action = Context:FindFirstChild(ActionName) :: Action

	if not Action then
		Action = script.ActionTemplate:Clone()
		Action.Name = ActionName
		Action.Parent = Context
	end

	return Action
end

function Keybinding.GetAction(Context: string, Action: string): Action
	local ContextObject = GetContext(Context)
	local ActionObject: Action = GetAction(ContextObject, Action)

	return ActionObject
end

function Keybinding.ToggleContext(Context: string, State: boolean)
	local ContextObject = GetContext(Context)
	ContextObject.Enabled = State
end

function Keybinding.AddKeybind(Context: string, Action: string, Name: string, Binding: Enum.KeyCode)
	local ContextObject = GetContext(Context)
	local ActionObject: Action = GetAction(ContextObject, Action)

	Instance:CreateInstance("InputBinding", {
		Name = Name,
		KeyCode = Binding,
		Parent = ActionObject,
	})
end

return Keybinding
