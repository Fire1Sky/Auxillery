local LootModule = {}
local LootPoolClass = {}
LootPoolClass.__index = LootPoolClass

export type Loot = {{Name : string, Rarity : number}}

function LootModule.new(Loot : Loot)
	local LootPool = {LootPool = Loot}
	setmetatable(LootPool, LootPoolClass)
	return LootPool
end

function LootPoolClass:GetRandomItem()
	local weightedsum = 0
	for _, v in pairs(self.LootPool) do
		weightedsum += v.Rarity
	end
	
	local random = Random.new()
	local rnd = random:NextNumber(0, weightedsum)
	for _, v in pairs(self.LootPool) do
		if rnd < v.Rarity then
			return v.Name
		end
		rnd -= v.Rarity
	end
end

return LootModule