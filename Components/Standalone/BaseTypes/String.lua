--!strict
local StringModule = {}

function StringModule.GenerateRandomId(length : number?) : string
	local UsableSymbols = {
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"0","1","2","3","4","5","6","7","8","9"
	}

	local ID = ""
	for _ = 1, length or 10 do
		local isupper = math.random(1,2) == 1

		if isupper then
			ID = ID..string.upper(UsableSymbols[math.random(1, #UsableSymbols)])
		else
			ID = ID..UsableSymbols[math.random(1, #UsableSymbols)]
		end
	end

	return ID
end

function StringModule.NormalizeString(String: string, StartAtOccurenceOf: string): string
	local Start = string.find(String, StartAtOccurenceOf)
	local Normalized = string.sub(String, Start or 0)
	
	return Normalized
end

function StringModule.FormatTime(TimeInSeconds : number) : string
	TimeInSeconds = math.round(TimeInSeconds)
	local min, h = 0, 0
	
	while TimeInSeconds >= 60 do
		min += 1
		TimeInSeconds -= 60
	end
	
	while min >= 60 do
		h += 1
		min -= 60
	end
	
	local FormattedString = TimeInSeconds.." seconds"
	
	if min > 0 then
		FormattedString = FormattedString..", "..min.." minutes"
	end
	
	if h > 0 then
		FormattedString = FormattedString..", "..h.." hours"
	end
	
	return FormattedString
end

return StringModule