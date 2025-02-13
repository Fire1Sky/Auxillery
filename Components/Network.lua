local NetworkModule = {}

local Services = require("Services")
local IsClient = Services.RNS:IsClient()

local ClientFunctions = {}
local ServerFunctions = {}
local TableToReplicate = nil

if IsClient then
  TableToReplicate = ClientFunctions
  --Setup Client
else
  TableToReplicate = ServerFunctions
  --Setup Server
end

for Name, Function in pairs(TableToReplicate) do
  NetworkModule[Name] = Function
end

return NetworkModule