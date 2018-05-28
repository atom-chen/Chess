
local OpenFile = OpenFile
local PlayerInfo = OpenFile("PlayerInfo")
local BaseInfoManager = OpenFile("BaseInfoManager")

local PlayerInfoManager = class("PlayerInfoManager", BaseInfoManager)

function PlayerInfoManager._ab_create(reply)
    return PlayerInfoManager.new(reply)
end

function PlayerInfoManager:_ab_init(reply)
    self.playerInfo = PlayerInfo._ab_create()
    self.playerInfo:_ab_init(reply)
end

function PlayerInfoManager:_ab_finalize()
end

function PlayerInfoManager:_ab_getPalyerAccountID()
    return self.playerInfo.accountID
end

function PlayerInfoManager:_ab_isGoldEnough(costGold)
    return self.playerInfo:_ab_isGoldEnough(costGold)
end

function PlayerInfoManager:_ab_save()
    local data = {
        userID = self.playerInfo.userID,
        userHead = self.playerInfo.userHead,
        name = self.playerInfo.name,
        freeBuy = self.playerInfo.freeBuy,
        gold = self.playerInfo.gold,
    }

    return data
end

return PlayerInfoManager