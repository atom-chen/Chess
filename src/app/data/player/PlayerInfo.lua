local PlayerInfo = class("PlayerInfo")

function PlayerInfo._ab_create()
    return PlayerInfo.new()
end

function PlayerInfo:ctor()

end

function PlayerInfo:_ab_init(reply)
    local body = reply or {}

    self.userID = body.userID or 0
    self.userHead = body.userHead or ""
    self.name = body.name or ""
    self.freeBuy = body.freeBuy or 20
    self.gold = body.gold or 10000
    if self.gold < 0 then
    	self.gold = 0
    end
end

function PlayerInfo:_ab_isGoldEnough(costGold)
    return self.gold >= costGold, costGold - self.gold
end

function PlayerInfo:_ab_getGold(gold)
    self.gold = self.gold + gold
end

function PlayerInfo:_ab_useFreeBuy()
    self.freeBuy = self.freeBuy - 1
end

return PlayerInfo