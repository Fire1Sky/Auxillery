local InputModule = {}
if game:GetService("RunService"):IsServer() then
	return InputModule
end

local Player: Player = game.Players.LocalPlayer
local Mouse: Mouse = Player:GetMouse()

function InputModule.Get2DMousePosition()
	return Vector2.new(Mouse.X, Mouse.Y) / Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY)
end

return InputModule
