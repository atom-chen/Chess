
--窗口基类
local WinBase = class("WinBase", function()
    local node = display.newNode();
    return node;
end)

function WinBase:onWinEnter()  print("WinBase:onWinEnter=====================") end


function WinBase:ctor(winName)
    --增加监听功能
    --	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.winState = "close"
    --self.winType = "fixed"
    self.showType = WinShowType.normal
    self.topOffset = 0
    self:regMsgHandler()

    --print("self +__cname", self.__cname)

    local function onNodeEvent(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif eventType == "exit" then
            self:onExit()
        elseif eventType == "cleanup" then
            self:unregMsgHandler()
            if self.onCleanup then
                self:onCleanup()
            end
            self:_onCleanup()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    self.resItems = {};
end

function WinBase:regMsgHandler()
    --print("regMsgHandler")
end

function WinBase:unregMsgHandler()
    --print("unregMsgHandler")
end

function WinBase:getActionNode()
    return nil
end

function WinBase:onEnter()
    --print("WinBase:onEnter");
    self.winState = "opening"
end

function WinBase:onExit()
    --print("WinBase:onExit   ",self.__cname);
    self.winState = "close"
    -- for k,v in pairs(self.resItems) do
    --     self:unloadRes(k);
    -- end
    --移除lua监听事件
    --	self:removeAllEventListeners();
    --移除监听扩展
    --	self:removeComponent("components.behavior.EventProtocol")
end

function WinBase:onEnterTransitionFinish()
    --print("WinBase:onEnterTransitionFinish");
    self.winState = "open"
end

function WinBase:_onEnterTransitionFinish()

end

function WinBase:onExitTransitionStart()
    --print("WinBase:onExitTransitionStart");
    self.winState = "closing"
    return nil
end

function WinBase:getActionOut()
    --关闭窗口前的动画
    return nil
end
function WinBase:getActionIn()
    --关闭窗口前的动画
    return nil
end

function WinBase:_onCleanup()
    --print("WinBase:onCleanup",self.__cname);
    for k,v in pairs(self.resItems) do
        self:unloadRes(k);
    end
end

--把资源加入内存

function WinBase:isResLoaded(resName)
    if self.resItems[resName] == nil then
        return false
    else
    	if self.resItems[resName] >= 1 then
        	return true
        else
        	return false
        end
    end
end

function WinBase:loadRes(resName)
    if self.resItems[resName] == nil then
        self.resItems[resName] = 1;
        ResMgr.loadRes(resName);
    else
        self.resItems[resName] = self.resItems[resName] + 1;
    end
end

function WinBase:unloadRes(resName)
    if resName == nil or self.resItems == nil or self.resItems[resName] == nil then
        return;
    end

    self.resItems[resName] = self.resItems[resName] - 1;
    -- print("    self.resItems[resName]  ===== ", self.resItems[resName],resName)
    if self.resItems[resName] <= 0 then
        self.resItems[resName] = nil;
        ResMgr.unloadRes(resName);
    end
end

function WinBase:loadResGroup(resGroup)
    if type(resGroup) == "table" then
        for k,v in pairs(resGroup) do
            self:loadRes(v);
        end
    end
end

function WinBase:unloadResGroup(resGroup)
    if type(resGroup) == "table" then
        for k,v in pairs(resGroup) do
            self:unloadRes(v);
        end
    end
end

function WinBase:showWin()
    --[[local name = self.class.__cname;]]
    if (self.winState ~= "close") then
        return
    end

    local scene = display:getRunningScene();
    --[[if not scene.openWinList or type(scene.openWinList) ~= "table" then
    scene.openWinList = {}
    end

    for k,v in pairs(scene.openWinList) do
    if (v.class.__cname == name and v.winType ~= "fixed") or (self.winType == "float" and v.winType == "float") then
    v:close();
    end
    end]]
    scene:addChild(self)
    --[[table.insert(scene.openWinList, self)]]

    local inAction = self:getActionIn()
    local _layer = self:getActionNode()
    if inAction and _layer then
        _layer:runAction(inAction)
    end

end

function WinBase:distory()

    local win = self
    win:unregMsgHandler()

    if (win.winState == "close" or win.winState == "closing") then
        --print("****************************窗口关闭错误[%s]****************************", self.__cname)
        return
    end
    --print("****************************正在关闭窗口[%s]****************************", self.__cname)
    local exitAction = win:getActionOut()

    local _layer = self:getActionNode()
    if exitAction and _layer then
        local actSq = cc.Sequence:create(exitAction, cc.CallFunc:create(function ()
            if win.onCloseWin ~= nil then
                win:onCloseWin()
            end
            win:removeFromParent()
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end))
        _layer:runAction(actSq)
    else
        if win.onCloseWin ~= nil then
            win:onCloseWin()
        end
        win:removeFromParent()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end
end


return WinBase