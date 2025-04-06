local TesterModule = {}
local TesterClass = {Tests = {}}

function TesterModule.new()
    local Tester = {}
    setmetatable(Tester, TesterClass)
    return Tester
end

function TesterClass:AddTest(Test : any) : nil
    table.insert(self.Tests, Test)
end

function TesterClass:Destroy()
    table.clear(self)
    table.freeze(self)
end

function TesterClass:Test() : boolean
    for _, v in pairs(self.Tests) do
        if not v then
            self:Destroy()
            return false
        end
    end

    self:Destroy()
    return true
end

return TesterModule