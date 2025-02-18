local NetworkModule = {}
local BridgeNet = require("../Dependencies/BridgeNet2")

local Services = require("Services")
local IsClient = Services.RNS:IsClient()

local TableToReplicate = {}

if IsClient then
  --Setup Client
else
  --Setup Server
  function TableToReplicate:Fire(TargetInfo)
   local SupportedTypes = {
     All = BridgeNet.AllPlayers,
     Players = BridgeNet.Players,
     PlayersExcept = BridgeNet.PlayersExcept
   }
   
   local Type = SupportedTypes[TargetInfo.Name]
   
   if not Type then
     return
   end
  
  end
end

for Name, Function in pairs(TableToReplicate) do
  NetworkModule[Name] = Function
end

return NetworkModule