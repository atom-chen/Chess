
local OpenFile = OpenFile
local PlayerInfoManager = OpenFile("PlayerInfoManager")
local AIInfoManager = OpenFile("AIInfoManager")
local BaseInfoManager = OpenFile("BaseInfoManager")
local cjson = require("quickjson")


local DataManager = class("DataManager", BaseInfoManager)

function DataManager:_ab_init()
end

function DataManager:_ab_login()
    self:_ab_setServerTime(os.time())
    self:_ab_load()
end

function DataManager:_ab_load()
    local data = PlayerConfig:getSetting("key_data", "{}")
    print("data: ", data)
    data = cjson.decode(data)
    print("data: ", data)
    self.playerMgr = PlayerInfoManager._ab_create(data.playerData)
    self.aiMgr = AIInfoManager._ab_create(data.aiData or {})
end

function DataManager:_ab_save()
    local data = {
        playerData = self.playerMgr:_ab_save(),
        aiData = self.aiMgr:_ab_save(),
    }
    
    PlayerConfig:setSetting("key_data", cjson.encode(data))
end

function DataManager:_ab_setServerTime(serverTime)
    local lastResponseTime = self.lastResponseTime
    --print("   serverTime ================ ",serverTime, os.time())
    self.lastResponseTime = serverTime
    local st = os.date("%c", tonumber(self.lastResponseTime))
    --print("请求服务器系统时间: ", st)
    local cur = os.time()
    local current = os.date("%c", cur)
    --print("当前机器的系统时间: ", current)
    self.time_diff = self.lastResponseTime - cur
    --print("时间差值:    " .. self.time_diff .. " 秒")

    --[[if self.shopMgr then
        self.shopMgr:refreshNoticeShop()
    end

    if self.lotteryMgr then
        self.lotteryMgr:refreshNoticeLottery()
    end]]
end

function DataManager:_ab_getFixedTime()
    --print("  self.time_diff =============== ",self.time_diff,os.time())
	local st = self.time_diff + os.time()
	return st
end

function DataManager:_ab_finalize()
end

function DataManager:_ab_getUserID()
    return self.playerMgr and self.playerMgr.playerInfo.userID or ""
end

function DataManager:_ab_getPlayerInfo()
    return self.playerMgr and self.playerMgr.playerInfo
end

function DataManager:_ab_getGold(gold)
    self:_ab_getPlayerInfo():_ab_getGold(gold)
end

return DataManager