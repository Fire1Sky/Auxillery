local Math = {}

function Math.GetOrientationOfCFrame(CF: CFrame): Vector3
	local _sx, _sy, _sz, m00, m01, m02, _m10, _m11, m12, _m20, _m21, m22 = CF:GetComponents()

	local X = math.deg(math.atan2(-m12, m22))
	local Y = math.deg(math.asin(m02))
	local Z = math.deg(math.atan2(-m01, m00))

	return Vector3.new(X, Y, Z)
end

function Math.SineLerp(a: number, b: number, t: number)
	local ft = math.sin(t * math.pi * 0.5)
	return a + (b - a) * ft
end

return Math
