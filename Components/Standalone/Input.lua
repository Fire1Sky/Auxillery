local InputModule = {}
if game:GetService("RunService"):IsServer() then
	return {} :: typeof(InputModule)
end

local UIS = game:GetService("UserInputService")
local Emitter = require("./Emitter")

local Camera = workspace.CurrentCamera

function InputModule.Get2DMousePosition()
	return UIS:GetMouseLocation() / Camera.ViewportSize
end

--[[
	Waits for the Player to press the keys given. If no keys are given, it'll wait for any key.
	Parameters:
		Timeout: Timeout for when no key is pressed to avoid infinite yield.
		OnRelease: Whether the function should yield until the key is pressed or released

	- Yields
]]
function InputModule.AwaitKey(Keys: {Enum.KeyCode}?, Timeout: number?, OnRelease: boolean?): Enum.KeyCode?
	local Connection: RBXScriptConnection
	local OnPress = Emitter.newSingle()

	local Event = if OnRelease then "InputEnded" else "InputBegan"

	Connection = UIS[Event]:Connect(function(Input, GPE)
		if GPE then return end

		if Keys then
			if table.find(Keys, Input.KeyCode) then
				Connection:Disconnect()
				OnPress:Fire(Input.KeyCode)
			end
		else
			Connection:Disconnect()
			OnPress:Fire(Input.KeyCode)
		end
	end)

	if Timeout then
		task.delay(Timeout, function()
			if Connection.Connected then
				Connection:Disconnect()
				OnPress:Fire()
			end
		end)
	end

	return OnPress:Wait()
end

return InputModule
