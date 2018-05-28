
local UIAniButton = class("UIAniButton", function()
	return cc.Node:create()
end)

function UIAniButton.create(ani, callback, params)
	return UIAniButton.new(ani, callback, params)
 end 


function UIAniButton:ctor(ani, callback, params)
	-- print("UIAniButtonUIAniButtonUIAniButtonUIAniButtonUIAniButtonUIAniButton",self.onTouchBegan)

	self.params = params or {}
    self.moveOutCb = self.params.moveOut
	self.ani = ani
	self:addChild(ani)
	self.pressed = false
	self.highlighted = false
    self.pressed = false
    self.clickHandler = callback or nil
    self.enabled = true
    -- self.playEffect = self.params.playEffect or "musicItem/comi.mp3" --播放音效标志

    if self.clickHandler or self.params.tipsProto then
    	local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
    	--注册触摸事件
        listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(handler(self, self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    end
    if self.ani then
        self.pProgram = self.ani:getGLProgram()
    end
    -- print( "    self.pProgram ======== ",self.pProgram)
 end

function UIAniButton:setEnabled(flag)
    self.enabled = flag
end

function UIAniButton:setOpacity(val)
    self.ani:setOpacity(val)
end

function UIAniButton:onTouchBegan(touch, event)
	local point = touch:getLocation()

	--print("UIAniButton:onTouchBegan", not self:contains(point) , not self:isVisible() , not self:hasVisibleParents())

    if not self.enabled then
        return false
    end

    if not self:contains(point) or not self:isVisible() or not self:hasVisibleParents() then
        return false
    end

	--print("UIAniButton:onTouchBegan(touch, event)")
	if not self:propagateTouchEvent("began", self,touch, event) then 
        --print("not self:propagateTouchEvent(began, self,touch, event)")
        return false
    end

    self.canEnded = true
    self.beganPos = point

    self:setHighlighted(true)
    self.pressed = true
    -- if self.ani then
    --     self:setOtherEnable(3)
    -- end
    if self.playEffect then-- 播放音效
        playEffectFunc(self.playEffect)
    end
    
    if self.clickHandler then 
        --print("touchBegan111111")
        self.clickHandler("began",self,point)
    end

    if self.ani then
        self.ani:setGLProgram(ShaderManager:getShader(ShaderType.HIGHTLIGHT))
    end

    if self.params.tipsProto then 
        local rect = self:getTouchRect()
        local sz = cc.size(rect.width, rect.height)
        local bPos = self:convertToWorldSpace(cc.p(0,0))
        TipsLayer:createTips(self.params.tipsProto, self.params.tipsParam, bPos, sz, self)
    end

	return true

end

function UIAniButton:onTouchMoved(touch, event)
	local point = touch:getLocation()
	self:propagateTouchEvent("moved", self,touch, event)

	 if not self.pressed then 
        return 
    end

    if self:contains(point) then 
        self.pressed = true

        if self.clickHandler then 
            self.clickHandler("moved",self,point)
        end
    else
        if self.moveOutCb then
            self:moveOutCb()
        end
        self:setHighlighted(false)
        self.pressed = false
        self:resetShader()
    end

    local dis = nil
    dis = cc.pGetDistance(self.beganPos, point)
    if dis and dis >= 10 then
        self.canEnded = false
    end
end

function UIAniButton:onTouchEnded(touch, event)
	local point = touch:getLocation()

	local highlighted = self.highlighted
    self:setHighlighted(false)
     self.pressed = false

    self:propagateTouchEvent("ended", self,touch, event)

    if self.clickHandler and self:contains(point) then 
        if self.canEnded and highlighted then
            self.clickHandler("ended",self,point)
        else
            self.clickHandler("cancelled",self,point)
        end
    end
    self:resetShader()

    if self.params.tipsProto then 
        TipsLayer:hide(self)
    end
end

function UIAniButton:onTouchCancelled(touch, event)
	self:setHighlighted(false)
	self.pressed = false

    self:propagateTouchEvent("cancelled", self,touch, event)
    
	if self.clickHandler then 
        self.clickHandler("cancelled",self,point)
    end

    self:resetShader()

    if self.params.tipsProto then 
        TipsLayer:hide(self)
    end
end

function UIAniButton:setOtherEnable(type)
    if self.ani then
        self.initProgramType = type
        self.ani:setGLProgram(ShaderManager:getShader(self.initProgramType)) 
    end
end

function UIAniButton:setOriginGLProgramByinit()
    if self.ani then
        self.initProgramType = nil
        self.ani:setGLProgram(self.pProgram) 
    end
end

function UIAniButton:resetShader()
    if self.ani and not self.initProgramType then
        self.ani:setGLProgram(self.pProgram)
    elseif self.ani then 
        self.ani:setGLProgram(ShaderManager:getShader(self.initProgramType))        
    end
end


function UIAniButton:propagateTouchEvent(type, sender, touch, event)
    return self:interceptTouchEvent(type, sender, touch, event)
end

function UIAniButton:interceptTouchEvent(type, sender, touch, event)
--print("UIAniButton:interceptTouchEvent")
    -- local parent = self:getParent()

    -- while parent ~=nil do
    --     if parent.interceptTouchEvent then 
    --         return parent:interceptTouchEvent(type, sender, touch, event)
    --     end

    --      parent = parent:getParent()
    -- end    

    return true    
end

function UIAniButton:setHighlighted(enable)
    self.highlighted = enable
end

function UIAniButton:isHighlighted()
    return self.highlighted
end

function UIAniButton:isSwallowTouches()
    return true
end

function UIAniButton:hasVisibleParents()
    local  parent = self:getParent()

    while parent ~= nil do
        if not parent:isVisible() then 
            return false
        end

        parent = parent:getParent()
    end  

    return true
end

function UIAniButton:getTouchRect()
	-- local box = self.ani:getAabbContentSize()
    local box = self.ani:getBoundingBox()
	-- print("UIAniButton getBoundingBox",-box.width/2, 0, box.width, box.height )
    -- return {x = -box.width/2, y = 0, width = box.width, height = box.height} --box
	return box --box
end

function UIAniButton:contains(point)
    local touchLocation = self.ani:getParent():convertToNodeSpace(point)
   --print("    touchLocation ====== ",touchLocation.x,"    ",touchLocation.y)
	return cc.rectContainsPoint(self:getTouchRect(), touchLocation)
end

return UIAniButton