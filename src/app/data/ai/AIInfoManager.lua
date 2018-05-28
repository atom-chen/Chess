
local OpenFile = OpenFile
local AIInfo = OpenFile("AIInfo")
local BaseInfoManager = OpenFile("BaseInfoManager")

local AIInfoManager = class("AIInfoManager", BaseInfoManager)

function AIInfoManager._ab_create(reply)
    return AIInfoManager.new(reply)
end

function AIInfoManager:_ab_init(reply)
    self.aiList = {}
    for i,v in ipairs(reply) do
        local info = AIInfo._ab_create()
        info:_ab_init(v)
        self.aiList[v.id] = info
    end
end

function AIInfoManager:_ab_finalize()
end

function AIInfoManager:_ab_getAI(id)
    if not self.aiList[id] then
        local info = AIInfo._ab_create()
        info:_ab_init({id = id})
        self.aiList[id] = info
    end

    return self.aiList[id]
end

function AIInfoManager:_ab_save()
    local data = {}
    for k,v in pairs(self.aiList) do
        table.insert(data, {
            id = v.id,
            name = v.name,
            gold = v.gold,
        })
    end

    return data
end

return AIInfoManager