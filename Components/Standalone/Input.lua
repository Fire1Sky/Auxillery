local InputModule = {}
if game:GetService("RunService"):IsServer() then
	return {} :: typeof(InputModule)
end

local UIS = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Emitter = require("./Emitter")

function InputModule.Get2DMousePosition()
	return Vector2.new(Mouse.X / Mouse.ViewSizeX, Mouse.Y / Mouse.ViewSizeY)
end

--[[
	Waits for the Player to press the keys given. If no keys are given, it'll wait for any key.

	- Yields
]]
function InputModule.AwaitKey(Keys: {Enum.KeyCode}?, Timeout: number?): Enum.KeyCode?
	local Connection: RBXScriptConnection
	local OnPress = Emitter.newSingle()

	Connection = UIS.InputBegan:Connect(function(Input, GPE)
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
