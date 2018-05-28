local SceneBase = class("SceneBase", function(name)
    return display.newScene(name)
end)

local OpenFile = OpenFile
local WinManager = OpenFile("WinManager")
local UIImageBox = OpenFile("UIImageBox")

function SceneBase:ctor(name)
    --  self:addComponent("components.behavior.EventProtocol"):exportMethods();
    --print("  ctor() ===== ",self.class.__cname)
    if not self.winManager then
        self.winManager = WinManager.new()
    end
    local function onNodeEvent(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif eventType == "exit" then
            self:onExit()
        elseif eventType == "cleanup" then
            self:onCleanup()
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    self.resItems = {};


    --self.openWinList = {};

    --  if device.platform == "android" then
    --      --开启按键响应
    --      self:enableKeypad(true);
    --      self:onKeypad(function(event)
    --          if event.key == "back" then
    --              GameSDK:endGame();
    --          end
    --      end)
    --  end

    --默认返回键监听
    self:enableBackPress(true)

    -- self:addTestButton()
end

function SceneBase:addTestButton()
    local printLua = UIImageBox.new("main_image_012.png",function()
       print(string.format("---------LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
    end,{textParams = {text = "打印LUA", size = 30, color = CoreColor.GENERAL_WORDS, font = HYH3GJ}, NOPLIS = true })

    local printOjbs = UIImageBox.new("main_image_012.png",function()
       Zip:printObjects()
    end,{textParams = {text = "打印Objs", size = 30, color = CoreColor.GENERAL_WORDS, font = HYH3GJ}, NOPLIS = true })

    local printTexture = UIImageBox.new("main_image_012.png",function()
       print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    end,{textParams = {text = "打印纹理", size = 30, color = CoreColor.GENERAL_WORDS, font = HYH3GJ}, NOPLIS = true })

    local remove = UIImageBox.new("main_image_012.png",function()
       cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end,{textParams = {text = "REMOVE纹理", size = 30, color = CoreColor.GENERAL_WORDS, font = HYH3GJ}, NOPLIS = true })

    local addCount = 0
    local removeCount = 0
    local addSpine = UIImageBox.new("main_image_012.png",function()
       
        -- if yunAnimat == nil then
        --     yunAnimat = ResourceManager:createAnimation("spine/ui/ui_pit_lightpoint")
        --     yunAnimat:playAnimation("idle", -1);
        --     yunAnimat:scheduleUpdateLua()
        --     yunAnimat:setPosition(cc.p(200,200))
        --     self:addChild(yunAnimat,100)
        -- elseif ui_reel == nil then
        --     ui_reel = ResourceManager:createAnimation("spine/ui/ui_reel")
        --     ui_reel:playAnimation("idle", -1);
        --     ui_reel:scheduleUpdateLua()
        --     ui_reel:setPosition(cc.p(200,200))
        --     self:addChild(ui_reel,100)
        -- end

        -- for i=1,5 do
        --     scheduler.performWithDelayGlobal(function() 
        --         local yunAnimat = ResourceManager:createAnimation("spine/actors/sakura")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)

        --         local yunAnimat = ResourceManager:createAnimation("spine/actors/boneskin")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))    
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)

        --         local yunAnimat = ResourceManager:createAnimation("spine/actors/bleachedbones")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))    
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)

        --         local yunAnimat = ResourceManager:createAnimation("spine/actors/ares")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))    
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)
        --     end,i*5)
        -- end
        local path
        local jsonPath
        --print("addCount",addCount)
        if addCount == 0 then
            path = "spine/actors/bleachedbones"
            jsonPath = "spine/actors/bleachedbones/skeleton.json"
            scale = 1

        elseif addCount == 1 then
            path = "spine/actors/boneskin"
            jsonPath = "spine/actors/boneskin/skeleton.json"
            scale = 1

        elseif addCount == 2 then
            path = "spine/actors/ares"
            jsonPath = "spine/actors/ares/skeleton.json"
            scale = 1

        elseif addCount == 3 then
            path = "spine/actors/sakura"
            jsonPath = "spine/actors/sakura/skeleton.json"
            scale = 1
            

            addCount = -1
        end 
        addCount = addCount + 1
        cc.SpriteFrameCache:getInstance():addSpriteFrames(path.."/skeleton0.plist")
        -- DHSkeletonDataCache:getInstance():loadSkeletonData(path,jsonPath,(scale and scale) or 1)

        -- local function getText(index)
        --     --local n = math.round(10)
        --     local text = ""
        --     for i=1,5 do
        --         text = text .. 1
        --     end
        --     return text
        -- end

        -- for i=1,100 do
        --     local text2 = UILabel.new({
        --         text = getText(i),
        --         size = 26,
        --         color = CoreColor.WHITE,
        --         back = CoreColor.BLACK
        --     })
        --     display.align(text2, display.BOTTOM_LEFT, math.random()*500, math.random()*500)
        --     self:addChild(text2)

        --     text2:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        -- end

        -- local text2 = UILabel.new({
        --         text = "aaaaa",
        --         size = 26,
        --         --font = "res/fonts/SimHei.ttf",
        --         color = CoreColor.WHITE,
        --         --back = CoreColor.BLACK
        --     })
        --     display.align(text2, display.BOTTOM_LEFT, math.random()*500, math.random()*500)
        --     self:addChild(text2)

        --     text2:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))

    end,{textParams = {text = "Add Spine", size = 30, color = CoreColor.GENERAL_WORDS, font = HYH3GJ}, NOPLIS = true })

    local removeSpine = UIImageBox.new("main_image_012.png",function()    
        local path
        local jsonPath  
        --print("removeCount",removeCount)  
        if removeCount == 0 then
            path = "spine/actors/bleachedbones"
            jsonPath = "spine/actors/bleachedbones/skeleton.json"
            scale = 1

        elseif removeCount == 1 then
            path = "spine/actors/boneskin"
            jsonPath = "spine/actors/boneskin/skeleton.json"
            scale = 1

        elseif removeCount == 2 then
            path = "spine/actors/ares"
            jsonPath = "spine/actors/ares/skeleton.json"
            scale = 1

        elseif removeCount == 3 then
            path = "spine/actors/sakura"
            jsonPath = "spine/actors/sakura/skeleton.json"
            scale = 1

            removeCount = -1
        end 

        --DHSkeletonDataCache:getInstance():removeSkeletonData(path)
        display.removeSpriteFramesWithFile(path.."/skeleton0.plist",path.."/skeleton0.png")
        
        removeCount = removeCount + 1


        --ResourceManager:getInstance():exitBattle()
        --require "pay.payWin"
        --require "include"
        --OpenWin(payWin)

        --检测是否显示游戏公告
        --checkGameNotice()
        -- local function getText(index)
        --     --local n = math.round(10)
        --     local text = ""
        --     for i=1,1 do
        --         text = text .. "aaaaa"
        --     end
        --     return text
        -- end

        -- for i=1,100 do
        --     local text2 = UILabel.new({
        --         text = getText(i),
        --         size = 26,
        --         --font = "res/fonts/SimHei.ttf",
        --         color = CoreColor.WHITE,
        --         --back = CoreColor.BLACK
        --     })
        --     display.align(text2, display.BOTTOM_LEFT, math.random()*500, math.random()*500)
        --     self:addChild(text2)

        --     text2:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        -- end

        --gTest = clone(chapterConf)

        -- local function myCreateAnimation(path)
        --     local jsonPath = path .."/skeleton.json"
        --     local scale = 1
        --     cc.SpriteFrameCache:getInstance():addSpriteFrames(path.."/skeleton0.plist")
        --     DHSkeletonDataCache:getInstance():loadSkeletonData(path,jsonPath,(scale and scale) or 1)



        --     scheduler.performWithDelayGlobal(function() 
        --             DHSkeletonDataCache:getInstance():removeSkeletonData(path)
        --             display.removeSpriteFramesWithFile(path.."/skeleton0.plist",path.."/skeleton0.png")
        --         end,3.5)

        --     return DHSkeletonAnimation:createWithKey(path)

        -- end

        -- for i=1,5 do
        --     scheduler.performWithDelayGlobal(function() 
        --         local yunAnimat = myCreateAnimation("spine/actors/sakura")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)

        --         local yunAnimat = myCreateAnimation("spine/actors/boneskin")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))    
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)

        --         local yunAnimat = myCreateAnimation("spine/actors/bleachedbones")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))    
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)

        --         local yunAnimat = myCreateAnimation("spine/actors/ares")
        --         yunAnimat:playAnimation("idle", -1);
        --         yunAnimat:scheduleUpdateLua()
        --         yunAnimat:setPosition(cc.p(200,200))    
        --         yunAnimat:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()))
        --         self:addChild(yunAnimat)
        --     end,i*5)
        -- end

        -- local path
        -- local jsonPath
        -- if addCount == 0 then
        --     path = "spine/actors/bleachedbones"
        --     jsonPath = "spine/actors/bleachedbones/skeleton.json"
        --     scale = 1

        -- elseif addCount == 1 then
        --     path = "spine/actors/boneskin"
        --     jsonPath = "spine/actors/boneskin/skeleton.json"
        --     scale = 1

        -- elseif addCount == 2 then
        --     path = "spine/actors/ares"
        --     jsonPath = "spine/actors/ares/skeleton.json"
        --     scale = 1

        -- elseif addCount == 3 then
        --     path = "spine/actors/sakura"
        --     jsonPath = "spine/actors/sakura/skeleton.json"
        --     scale = 1
            

        --     addCount = -1
        -- end 
        -- addCount = addCount + 1
        -- cc.SpriteFrameCache:getInstance():addSpriteFrames(path.."/skeleton0.plist")
        -- DHSkeletonDataCache:getInstance():loadSkeletonData(path,jsonPath,(scale and scale) or 1)

    end,{textParams = {text = "Remove Spine", size = 30, color = CoreColor.GENERAL_WORDS, font = HYH3GJ}, NOPLIS = true })

    display.align(printLua,display.BOTTOM_LEFT,0,0)
    self:addChild(printLua,100000)
    display.align(printOjbs,display.BOTTOM_LEFT,150,0)
    self:addChild(printOjbs,100000)
    display.align(printTexture,display.BOTTOM_LEFT,300,0)
    self:addChild(printTexture,100000)
    -- display.align(remove,display.BOTTOM_LEFT,450,0)
    -- self:addChild(remove,100000)
    -- display.align(addSpine,display.BOTTOM_LEFT,600,0)
    -- self:addChild(addSpine,100000)
    -- display.align(removeSpine,display.BOTTOM_LEFT,750,0)
    -- self:addChild(removeSpine,100000)
end

-- function SceneBase:onSceneEnter()
-- end

function SceneBase:onEnter()
    -- printInfo("%s:onEnter()",self.class.__cname);
    --print("  onEnter() ===== ",self.class.__cname)
end

function SceneBase:onEnterTransitionFinish()
--  printInfo("%s:onEnterTransitionFinish()",self.class.__cname);
end

function SceneBase:onExit()
   -- print("SceneBase:onExit()   ",  self.__cname)
    -- if self.__cname ~= "MainScene" then
    --     self.winManager:closeAllWin()
    --     self.winManager = nil

    --     for k,v in pairs(self.resItems) do
    --         self:unloadRes(k);
    --     end
    -- end
end

function SceneBase:onCleanup()
   -- print("SceneBase:onCleanup()   ",  self.__cname)
    -- if self.__cname ~= "MainScene" then
        self.winManager:closeAllWin()
        self.winManager = nil

        -- for k,v in pairs(self.resItems) do
        --     self:unloadRes(k);
        -- end
    -- end
    for k,v in pairs(self.resItems) do
        self:unloadRes(k);
    end

    if self._onCleanup then
        self:_onCleanup()
    end

end

function SceneBase:isResLoaded(resName)
    if self.resItems[resName] == nil then
        return false
    else
        if self.resItems[resName] > 0 then
            return true
        else
            return false
        end
    end
end


--把资源加入内存
function SceneBase:loadRes(resName)
    if self.resItems[resName] == nil then
        self.resItems[resName] = 1;
        -- ResMgr.loadRes(resName);
    else
        self.resItems[resName] = self.resItems[resName] + 1;
    end
end

--卸载资源
function SceneBase:unloadRes(resName)
    if resName == nil or self.resItems == nil or self.resItems[resName] == nil then
       -- print("   找不到资源？？？？？？？@@@？？？？？？？？？   ",resName)
        return;
    end

    self.resItems[resName] = self.resItems[resName] - 1;

    if self.resItems[resName] <= 0 then
        self.resItems[resName] = nil;
        -- ResMgr.unloadRes(resName);
    end
end

function SceneBase:regMsgHandler(msg,callBack)
    getMessageHelper():addHandler(HANDLER_TYPE.VIEW, callBack, msg)
    self:onNodeEvent("cleanup",function() 
        getMessageHelper():removeHandler(HANDLER_TYPE.VIEW, callBack, msg)
    end)
end

--加载资源组
function SceneBase:loadResGroup(resGroup)
    if type(resGroup) == "table" then
        for k,v in pairs(resGroup) do
            self:loadRes(v);
        end
    end
end

--卸载资源组
function SceneBase:unloadResGroup(resGroup)
    if type(resGroup) == "table" then
        for k,v in pairs(resGroup) do
            self:unloadRes(v);
        end
    end
end

--发送监听事件
--function SceneBase:dispatchAllEvent(event)
--  self:dispatchEvent(event);
--  for k,v in pairs(self.openWinList) do
--      v:dispatchEvent(event);
--  end
--end


--接受返回键
function SceneBase:enableBackPress(value)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        --开启按键响应

        local function  register()
            local listener = cc.EventListenerKeyboard:create()
            --listener:setSwallowTouches(true)
            listener:registerScriptHandler(function (keyCode,event)
                if keyCode == cc.KeyCode.KEY_BACK then
                    if GameSDK ~= nil then
                        GameSDK:exitGame({},function(data)
                            local ret = data
                            if ret.code == CODE_SUCCESS then
                                GameSDK:endGame()
                            end

                        end)
                        
                        --不在向下面传递这个消息了
                        event:stopPropagation()
                    end
                end
                --print(keyCode,cc.KeyCode.KEY_BACK)
            end,cc.Handler.EVENT_KEYBOARD_PRESSED)
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
            return listener
        end

        if value == true then
            if self.listener == nil then

                self.listener = register()
            end
        else
            if self.listener ~= nil then
                self:getEventDispatcher():removeEventListener(self.listener)
                self.listener = nil
            end
        end

    end
end

return SceneBase