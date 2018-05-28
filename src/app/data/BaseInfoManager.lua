local BaseInfoManager = class("BaseInfoManager")

function BaseInfoManager._ab_create(...)
    return BaseInfoManager.new(...)
end

function BaseInfoManager:ctor(...)
    print("base manager")
    self:_ab_init(...)
    self:_ab_regMsgHandler()
end

function BaseInfoManager:init(...)
    print("baseinit")
end

function BaseInfoManager:_ab_regMsgHandler()
    print("regMsgHandler")
end

function BaseInfoManager:_ab_unregMsgHandler()
    print("unregMsgHandler")
end

function BaseInfoManager:_ab_finalize()
end

function BaseInfoManager:_ab_dtor()
    self:_ab_unregMsgHandler()
    self:_ab_finalize()
end

return BaseInfoManager