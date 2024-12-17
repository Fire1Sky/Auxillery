local Aux = script.Parent.Parent
_G._Aux = {}

for _, v in pairs(Aux:GetChildren()) do
	if v:IsA("ModuleScript") then
		_G._Aux[v.Name] = require(v)
	end
end