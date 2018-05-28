
--按钮
local UIButton = class("UIButton", function(img)
	local sprite = UISprite.new(img, cc.Sprite)
	return sprite
end)

local PASCD = 500

function UIButton.create(img, imgDown, params)
    return UIButton.new(img,imgDown, params)
end

function UIButton:ctor(img,imgDown, params)
    local params = params or {} 
    self.params = params
    self.pasTime = self.params.pasTime or 200
    self.pasCD = PASCD
    --默认图片
    self.img = UIImage.new(img)
    if not imgDown then imgDown = img end
    --按下图片
    self.imgDown = UIImage.new(imgDown)
	--监听按钮
    self.touchEnable = true
    self.highlighted = false
    self.pressed = false
    self.clickHandler = params.onClick or nil
    self.curTime = 0
    self.schedulerID = nil
    self.playEffect = params.playEffect or "musicItem/comi.mp3"

    self.childFocusCancelOffset = 5 * ResolutionManager:getScale()
    
	
    self:setSpriteFrame(self.img)
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
	--注册触摸事件
    listener:registerScriptHandler(self:getTouchHandler("began"), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(self:getTouchHandler("moved"), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(self:getTouchHandler("ended"), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(self:getTouchHandler("cancelled"), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)


    local function onNodeEvent(eventType)
       -- print("began start start began began")
        if eventType == "enter" then
            --self:onEnter()
        elseif eventType == "enterTransitionFinish" then
           -- self:onEnterTransitionFinish()
        elseif eventType == "exit" then
            --self:onExit()
        elseif eventType == "cleanup" then
            self:onCleanup()
        end
       -- print("cleanup cleanup cleanup began began")
    end

    self:registerScriptHandler(onNodeEvent)

    self.pProgram = self:getGLProgram()
end

function UIButton:onCleanup()
	--移出触摸事件
    self:getEventDispatcher():removeEventListenersForTarget(self)
   
    if self.schedulerID then 
        scheduler.unscheduleGlobal(self.schedulerID)
        self.schedulerID = nil
    end
end

function UIButton:setImage(img)
    if tolua.type(img) == "cc.SpriteFrame" then
        self.img = img
        self:setSpriteFrame(self.img)
    elseif type(img) == "string" then
        self.img = UIImage.new(img);
        if tolua.type(self.img) == "cc.SpriteFrame" then
            self:setSpriteFrame(self.img)
        else
            --肯能是使用小图
            self:setTexture(img)
            self.img = img
        end
    end
end

function UIButton:update(dt)
    -- print("update updateupdateupdate")
    if self.touchEnable then
        self.pasCD = self.pasCD - dt * 1000
        if self.pasCD <= 0 then
    		self.curTime = self.curTime + dt * 1000;
    		if self.lastTime and (self.curTime - self.lastTime) > self.pasTime then
    			self.lastTime = self.curTime
    			if self.clickHandler then 
                    self.clickHandler("holded",self, dt) 
                end
    		end
        end
	end
end

function UIButton:registerScriptTouchHandler(handler)
    self.clickHandler = handler
end

--触摸方法
function UIButton:getTouchHandler(eventType)
    return function (touch, event) 
        if eventType == "began" then
            return self:beganEvent(touch, event)
        elseif eventType == "moved" then
            return self:movedEvent(touch, event)
        elseif eventType == "ended" then
            self:endedEvent(touch, event)
        else
            self:cancelledEvent(touch, event)
        end
    end
end

function UIButton:beganEvent(touch, event)
    local point = touch:getLocation()

    if self:contains(point) and self.params.unEnableTouch then --特殊按键事件
        self.params.unEnableTouch(self)
        -- return false
    end

    if not self:contains(point) or not self.touchEnable or not self:isVisible() or not self:hasVisibleParents()then
        return false
    end
--print("touchBegan")
    if not self:propagateTouchEvent("began", self,touch, event) then 
        --print("not self:propagateTouchEvent(began, self,touch, event)")
        return false
    end

    self:setHighlighted(true)
    -- audio.playSound(MUSIC.buttonClick,false)
    -- 播放音效
    if self.playEffect then
        playEffectFunc(self.playEffect)
    end
    
    self.pressed = true;
    self.lastTime = self.curTime;

    self.schedulerID =  scheduler.scheduleUpdateGlobal(handler(self, self.update))

    if self.clickHandler then 
        --print("touchBegan111111")
        self.clickHandler("began")
    end

    return true -- 继续接收消息
end

function UIButton:movedEvent(touch, event)
    local point = touch:getLocation()

    self:propagateTouchEvent("moved", self,touch, event)

    if self:contains(point) then 
        self:setHighlighted(true)
        self.pressed = true

        if self.clickHandler then 
            self.clickHandler("moved")
        end
    else
        self:setHighlighted(false)
        self.pressed = false

        if self.clickHandler then 
            self.clickHandler("moveout")
        end
    end

    if not self.pressed or not self.touchEnable then 
        return 
    end

    local startPoint = touch:getStartLocation()
    local touchPoint = touch:getLocation()
    local offset = cc.pGetDistance(startPoint,touchPoint)
    if self.schedulerID and self.pasCD > 0 and offset > self.childFocusCancelOffset then 
        scheduler.unscheduleGlobal(self.schedulerID)
        self.schedulerID = nil
    end
end

function UIButton:endedEvent(touch, event)
    local point = touch:getLocation()

    if self.schedulerID then 
        scheduler.unscheduleGlobal(self.schedulerID)
        self.schedulerID = nil
    end

    local highlighted = self.highlighted
    self:setHighlighted(false)
    self.pressed = false

    self:propagateTouchEvent("ended", self,touch, event)

    -- if self.lastTime < 200 and self.clickHandler and self:contains(point) then 
    if self.clickHandler and self:contains(point) then 
        if highlighted then
            self.clickHandler("ended",self) 
        else
            self.clickHandler("cancelled",self)
        end
    else
        self.clickHandler("cancelled",self)
    end
    
    self.lastTime = 0
    self.curTime = 0
    self.pasCD = PASCD
end

function UIButton:cancelledEvent(touch, event)
    if self.schedulerID then 
        scheduler.unscheduleGlobal(self.schedulerID)
        self.schedulerID = nil
    end

    self:setHighlighted(false)
    self.pressed = false
    self.lastTime = 0
    self.curTime = 0
    self.pasCD = PASCD

    self:propagateTouchEvent("cancelled", self,touch, event)

    if self.clickHandler then 
        self.clickHandler("cancelled",self)
    end
end


function UIButton:getTouchRect()
	return self:getBoundingBox()
end

function UIButton:contains(point)
    local touchLocation = self:getParent():convertToNodeSpace(point)

	return cc.rectContainsPoint(self:getTouchRect(), touchLocation)
end

function UIButton:setEnabled(enable)
	if enable ~= self.touchEnable then
		self.touchEnable = enable
	end

    self:setGrayEnable(not enable)
end

function UIButton:setOtherEnable(index)
    darkNode(self,index)
end

function UIButton:setGrayEnable(enable)
    if enable then
        darkNode(self)
    else
        self:setGLProgram(self.pProgram)
    end
end

function UIButton:setHighlighted(enable)
    self:setSpriteFrame((enable and self.imgDown) or self.img) 
    self.highlighted = enable
end

function UIButton:isHighlighted()
    return self.highlighted
end

function UIButton:isSwallowTouches()
    return true
end


function UIButton:propagateTouchEvent(type, sender, touch, event)
    return self:interceptTouchEvent(type, sender, touch, event)
end

function UIButton:interceptTouchEvent(type, sender, touch, event)
--print("UIButton:interceptTouchEvent")
    local parent = self:getParent()

    while parent ~=nil do
        if parent.interceptTouchEvent then 
            return parent:interceptTouchEvent(type, sender, touch, event)
        end

         parent = parent:getParent()
    end    

    return true    
end

function UIButton:hasVisibleParents()
    local  parent = self:getParent()

    while parent ~= nil do
        if not parent:isVisible() then 
            return false
        end

        parent = parent:getParent()
    end  

    return true
end
return UIButton