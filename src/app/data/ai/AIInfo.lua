local AIInfo = class("AIInfo")

function AIInfo._ab_create()
    return AIInfo.new()
end

function AIInfo:ctor()

end

function AIInfo:_ab_init(reply)
    local body = reply or {}

    self.id = body.id or 0
    self.gold = body.gold or 10000
    if self.gold < 10000 then
    	self.gold = 10000
    end
end

function AIInfo:_ab_isGoldEnough(costGold)
    return self.gold >= costGold, costGold - self.gold
end

function AIInfo:_ab_getGold(gold)
    self.gold = self.gold + gold
end

return AIInfo