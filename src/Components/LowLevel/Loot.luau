--!strict
local LootModule = {}
local LootPoolClass : LootPoolClass = {}
LootPoolClass.__index = LootPoolClass

export type LootPool = typeof(setmetatable({} :: LootPoolObject, {} :: LootPoolClass))
type LootPoolClass = {
	__index : LootPoolClass,
	GetRandomItem : (self : LootPool) -> ()
}
type LootPoolObject = {
	LootPool : {
		[number] : {
			Name : string,
			Rarity : number
		}
	}
}

function LootModule.new(LootPool : {[number] : {Name : string, Rarity : number}})
	local LootPoolObject = {LootPool = LootPool}
	setmetatable(LootPoolObject, LootPoolClass)
	return LootPoolObject
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