local MessageHelper = class("MessageHelper")

HANDLER_TYPE = {
    RECORD = 1,
    DATA = 2,
    VIEW = 3
}

function MessageHelper.create()
    return MessageHelper.new()
end

function MessageHelper:ctor()
    self.handleList = {}
    for key, value in pairs(HANDLER_TYPE) do
        self.handleList[value] = {}
    end
    self.scheduleId = {}
end

function MessageHelper:destroy()
    for id,value in pairs(self.scheduleId ) do
        scheduler.unscheduleGlobal(id)
    end
    self.scheduleId = {}
end

function MessageHelper:postDelay(callBack,delay,params)
    local id
    id = scheduler.performWithDelayGlobal(function() 
        self.scheduleId[id] = nil
        callBack(params)
        end,delay)
    self.scheduleId[id] = true
end

function MessageHelper:addHandler(priority, handle, _idList, obj)
    local idList = _idList
    if _G.type(_idList) ~= 'table' then
        if not _idList then
            error(" message msgID list is null ")
        end
        idList = {_idList}
    end
    if not self.handleList[priority] then
        self.handleList[priority] = {}
    end

    local handleList = self.handleList[priority]
    for _,id in pairs(idList) do
        if handleList[id] then
            if not handleList[id][handle] then 
                if obj then
                    handleList[id][handle] = obj 
                else
                    handleList[id][handle] = true
                end

                handleList[id]["count"] = handleList[id]["count"] + 1
            end
        else
            handleList[id] = {}

            if obj then
                handleList[id][handle] = obj 
            else
                handleList[id][handle] = true
            end
            
            handleList[id]["count"] = 1
        end
    end
end


function MessageHelper:removeHandler(priority, handle, _idList)
    local idList = _idList
    if _G.type(_idList) ~= 'table' then
        idList = {_idList}
    end
    
    local handleList = self.handleList[priority]
    for _,id in pairs(idList) do
        if not handleList or not handleList[id] then
            
        else
            if handleList[id][handle] then 
                handleList[id][handle] = nil
                handleList[id]["count"] = handleList[id]["count"] - 1

                if handleList[id]["count"] == 0 then
                    handleList[id] = nil
                end
            end
        end
    end
end

function MessageHelper:dispatchMsg(msgID,data)

    if not msgID then
        error(" message msgID list is null ")
    end

    for priority,handleList in ipairs(self.handleList) do
        local list = handleList[msgID] or {}
        for handle, obj in pairs(list) do
            if type(handle) == "function" then
                if type(obj) ~= "boolean" then
                    handle(obj, msgID,data)
                else
                    handle(msgID,data)
                end
            end
        end
    end
end

local helper = nil

function getMessageHelper()
    if helper == nil then
        helper = MessageHelper.create()
    end
    return helper
end

function releaseMessageHelper()
    if helper ~= nil then
        helper:destroy()
    end
    helper = nil
end