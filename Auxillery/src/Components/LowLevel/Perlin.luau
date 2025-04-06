--!strict
local Perlin = {}
local PerlinBlock = workspace.Perlin

local function InverseLerp(value : number, start : number, endingValue : number) : number
	return (value - start) / (endingValue - start)
end

local function SmoothNumber(baseY : number, threshold : number) : number
	if baseY <= threshold then
		return 0
	else
		local lerped = InverseLerp(baseY, threshold, 1)
		return lerped
	end
end

function Perlin:Generate(Settings : {
		MapSize : number,
		Scale : number,
		Frequency : number,
		Seed : number,
		Amplitude : number,
		SmoothingFactor : number,
		ChunkSize : number
	})
	
	local random = Random.new(Settings.Seed)
	local xOffset = random:NextNumber(-100000, 100000)
	local zOffset = random:NextNumber(-100000, 100000)
	
	local TerrainParts = workspace.TerrainParts
	TerrainParts:ClearAllChildren()
	
	for x = 0, Settings.MapSize do
		for z = 0, Settings.MapSize do
			local SampleX = x / Settings.Scale * Settings.Frequency + xOffset
			local SampleZ = z / Settings.Scale * Settings.Frequency + zOffset
			
			local baseY = math.clamp((math.noise(SampleX, SampleZ) + 0.5), 0, 1)
			local PreservedY = baseY
			
			baseY = SmoothNumber(baseY, Settings.SmoothingFactor)
			local y = baseY * Settings.Amplitude
			
			local BlockCFrame = CFrame.new(x * Settings.ChunkSize, y * Settings.ChunkSize, z * Settings.ChunkSize)
			
			local Clone = PerlinBlock:Clone()
			Clone.CFrame = BlockCFrame
			Clone.Size = Vector3.new(Settings.ChunkSize, y * (Settings.ChunkSize * 2) + 1, Settings.ChunkSize)
			Clone.Parent = TerrainParts
		end
		task.wait()
	end
end

return Perlin