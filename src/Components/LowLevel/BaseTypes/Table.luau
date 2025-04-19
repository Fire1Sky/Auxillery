--!strict
local TableModule = {}

local Number = require("./Number")
local Services = require("../Services")

--function TableModule:Compare(BaseTable: {any}, TableToCompare: {any}): boolean
--	assert(typeof(BaseTable) == "table", "Invalid table.")
--	assert(typeof(TableToCompare) == "table", "Invalid table.")
--	if next(BaseTable) and not next(TableToCompare) then
--		return false
--	end

--	for key, base in pairs(BaseTable) do
--		if tostring(key) == "__optional" then return true end
--		local expected = TableToCompare[key]

--		if expected ~= nil then
--			if typeof(expected) == "table" then
--				if TableModule:Compare(base, expected) then
--					continue
--				else
--					return false
--				end
--			end

--			if string.find(base, "?") then continue end
--			if string.sub(base, 1, 9) == "Instance:" then
--				if typeof(expected) ~= "Instance" or expected:IsA(string.sub(base, 10)) then
--					warn(key.." ("..tostring(expected)..") doesn't equal to expected"..base.." type.")
--				end
--			else
--				if typeof(expected) ~= base then
--					warn(key.." ("..typeof(expected)..") doesn't equal to expected "..base.." type.")
--					return false
--				end
--			end
--		else
--			if typeof(base) == "string" and string.find(base, "?") then
--				continue
--			elseif typeof(base) == "table" and base.__optional then
--				continue
--			end

--			warn(key.." isn't within "..tostring(TableToCompare))
--			return false
--		end
--	end

--	return true
--end

--Returns a string descriping if the given Table is a Array or a Dictionary.
function TableModule:GetTableType(Table : {}) : string?
	assert(typeof(Table) == "table", tostring(Table).." isn't a table.")

	local Result = ""
	local Count = 0

	for _, _ in Table do
		Count += 1
	end

	if #Table == Count then
		Result = "Array"
	else 
		Result = "Dictionary"
	end

	return Result
end

--Used to correctly clone tables.
function TableModule:DeepCopy(val : any) : any
	local copy = nil
	if typeof(val) == "table" then
		copy = {}
		for n, v in pairs(val) do
			copy[n] = TableModule:DeepCopy(v)
		end
		setmetatable(copy, TableModule:DeepCopy(getmetatable(val)))
	else
		copy = val
	end

	return copy
end

--[[
	Awaits and returns a value from the given table.
	@tab: the table to look into.
	@key: the key that will be waited for.
	@timeout: optional argument which stops yielding the code after runtime exceeds the timeout value.
]]
function TableModule:Await(tab : {}, key : any, timeout : number?) : any?
	assert(typeof(tab) == "table", tostring(tab).." isn't a table.")
	assert(key, "key is nil.")

	local runtime = 0

	if tab[key] == nil then
		local printed = false
		local ldT = 0
		local ldTConnection = nil

		local function UpdateldT(dt : number)
			ldT = dt
		end

		ldTConnection = Services.RNS.Heartbeat:Connect(UpdateldT)

		repeat
			if Number:NumberInRange(5, runtime, 0.1) and (not printed) then
				printed = true
				warn("Waiting time exceeded 5 seconds with table "..tostring(tab).." and key "..tostring(key))
			end
			runtime += ldT
			Services.RNS.Heartbeat:Wait()
		until tab[key] ~= nil or (typeof(timeout) == "number" and runtime >= timeout)

		ldTConnection:Disconnect()
	end

	return tab[key], runtime
end

function TableModule:Clear(Table : any, Settings : {ClearNested : boolean?, DisconnectConnections : boolean?, DestroyObjects : boolean?, Freeze : boolean?}?)
	assert(typeof(Table) == "table", "Invalid table to clear.")
	
	if typeof(Settings) ~= "table" then
		table.clear(Table)
		setmetatable(Table, nil)
	else
		local function Clear(Tab)
			for Index, Value in pairs(Table) do
				Table[Index] = nil

				if typeof(Value) == "RBXScriptConnection" then
					if not Settings.DisconnectConnections then continue end
					Value:Disconnect()
				elseif typeof(Value) == "Instance" then
					if not Settings.DestroyObjects then continue end
					Value:Destroy()
				elseif typeof(Value) == "table" then
					if not Settings.ClearNested then continue end
					Clear(Value)
				end
			end
		end
		
		Clear(Table)
		if Settings.Freeze then
			table.freeze(Table)
		end
		return
	end
	
	table.freeze(Table)
end

return TableModule