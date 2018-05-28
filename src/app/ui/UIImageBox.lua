-- TOUCH_EVENT_BEGAN   
-- TOUCH_EVENT_MOVED   
-- TOUCH_EVENT_ENDED   
-- TOUCH_EVENT_CANCELED

-- UI_TEX_TYPE_LOCAL
-- UI_TEX_TYPE_PLIST
local OpenFile = OpenFile
local Shader = OpenFile("Shader")
local UILabel = OpenFile("UILabel")
local _perY = 0

local UIImageBox = class("UIImageBox", function(img,onClick,params) 
    -- if type(img) == 'table' then
    --     return UIScale9Sprite.new(img.name,nil,nil,img.size,img.destroy)
    -- end
    local params = params or {}
    if tolua.type(img) == "cc.Sprite" then
        -- local sprite = ccui.ImageView:create()
        local sprite = replaceNodeSpriteToImageView(img)
        -- sprite:loadSpriteFrame(img:getSpriteFrame())
        return sprite
    elseif tolua.type(img) == "ccui.ImageView" then
        return img
    end
    local sprite = nil
    if params.NOPLIS then
        sprite = ccui.ImageView:create(img,UI_TEX_TYPE_LOCAL)
    else
        sprite = ccui.ImageView:create(img,UI_TEX_TYPE_PLIST)
    end
	-- local sprite = UISprite.new(img, cc.Sprite);
	return sprite;
end);

function UIImageBox:ctor(img,onClick,params)

	--监听按钮
	self.onClick = onClick;
	--扩展参数
	self.params = params or {};
    self._swallowTouches = self.params._swallowTouches -- true 代表不能穿透
    if self._swallowTouches == nil then
        self._swallowTouches = true
    end

    self.dontProgram = self.params.isProgram
    self.playEffect = self.params.playEffect or "ui/Click.wav" --播放音效标志
	--默认不加入滤镜
	self.isGrayEnable = false;

	self.touchEnable = true
    self.highlighted = false
    self.pressed = false

	--设置位置
	-- display.align(self, self.params.ap or display.CENTER, self.params.x or 0, self.params.y or 0)

    local sp = self:_getSprite()

    if sp then
        self.initProgram = sp:getGLProgram()
    	self.pProgram = sp:getGLProgram()
    end

    --文字
    
    self.textParams = self.params.textParams
    if self.textParams then
        local sz = self:getContentSize()
        self.label = UILabel.new(self.textParams)
        if self.label then
            local perX,perY = self.textParams.perX or 0, self.textParams.perY or 0
            display.align(self.label,self.textParams.layou or display.CENTER,self.textParams.x or (sz.width * 0.5 + perX), (self.textParams.y or (sz.height * 0.5 + perY)) + _perY )
            self:addChild(self.label,self.textParams.zOrder or 0)
        end
    elseif self:getChildByName("label") then
        self.label = self:getChildByName("label")
    end

	if self.onClick or self.params.tipsProto then

        self:setTouchEnabled(true);
		self:onTouch()
	end

    local function onNodeEvent(eventType)
        if eventType == "enter" then
            --self:onEnter()
        elseif eventType == "enterTransitionFinish" then
            --self:onEnterTransitionFinish()
        elseif eventType == "exit" then
            --self:onExit()
        elseif eventType == "cleanup" then
            if self.params.tipsProto then 
                TipsLayer:hide(self)
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)
    -- self:ignoreContentAdaptWithSize(true)
end

function UIImageBox:setOriginGLProgram(pProgram) --设置本源颜色
    self.pProgram = pProgram or self:_getSprite():getGLProgram()
end

function UIImageBox:setTips(tipsProto, tipsParam)
    if tipsProto then 
        self.params.tipsProto = tipsProto
        self.params.tipsParam = tipsParam
    end
end

function UIImageBox:setTipsParam(tipsParam)
    self.params.tipsParam = tipsParam 
end

function UIImageBox:setImage(img,params)
    local params = params or {}
	if tolua.type(img) == "cc.SpriteFrame" then
        self:loadSpriteFrame(img)
	elseif type(img) == "string" then
        self:loadTexture(img,params.isPlist or UI_TEX_TYPE_PLIST)
	end

    if self.label then
        local sz = self:getContentSize()
        if not self.textParams then self.textParams = {} end
        local perX,perY = self.textParams.perX or params.perX or 0, self.textParams.perY or params.perY or 0
        display.align(self.label,self.textParams.layou or display.CENTER,self.textParams.x or (sz.width * 0.5 + perX), (self.textParams.y or (sz.height * 0.5 + perY)) + _perY)
        if params.color then
            self.label:setTextColor(params.color)
        end
        if params.fontSize then
            self.label:setFontSize(params.fontSize)
        end
    end
end

--触摸方法
function UIImageBox:onTouch()
    local function callback(event)
        if event.name == "began" then
            self.canEnded = true
            self.pressed = true
            self.beganPos = cc.p(event.prevX,event.prevY)
            if not self.touchEnable then
                return false
            end
            if not self.dontProgram then
                self:setOtherEnable(3) --高亮
            end
            if self.playEffect then-- 播放音效
                playEffectFunc(self.playEffect)
            end

            if self.params.tipsProto then 
                local sz = self:getContentSize()
                sz.width = sz.width + (self.params.tipsOffX or 0)
                local bPos = self:convertToWorldSpace(cc.p(0,0))
                TipsLayer:createTips(self.params.tipsProto, self.params.tipsParam, bPos, sz, self)
            end

            if self.params.action then
                self:runAction(cc.MoveBy:create(0.1,cc.p(0,-5)))
            end
        elseif event.name == "moved" then
            if not self.touchEnable then
                return false
            end
            local dis = nil
            dis = cc.pGetDistance(self.beganPos,cc.p(event.prevX,event.prevY))
            if dis and dis >= 10 then
                self.canEnded = false
                self.pressed = false
            end
        elseif event.name == "ended" then
            self.pressed = false
            if not self.touchEnable then
                return false
            end
            if not self.dontProgram then
                self:resetShader() --还原Shader
            end
            if self.canEnded and self.onClick then
                self:onClick(event)
            end
            if self.params.tipsProto then 
                TipsLayer:hide(self)
            end

            if self.params.action then
                self:runAction(cc.MoveBy:create(0.1,cc.p(0,5)))
            end
        elseif event.name == "cancelled" then
            self.pressed = false
            if not self.touchEnable then
                return false
            end
            if not self.dontProgram then
                self:resetShader() --还原Shader
            end
            if self.params.tipsProto then 
                TipsLayer:hide(self)
            end

            if self.params.action then
                self:runAction(cc.MoveBy:create(0.1,cc.p(0,5)))
            end
        end
    end
    local prevX, prevY = 0, 0;
    self:setSwallowTouches(self._swallowTouches or false)
    self:addTouchEventListener(function(sender, state)
        local event;
        if state == 0 then
            event = sender:getTouchBeganPosition();
            prevX = event.x;
            prevY = event.y;
            event.prevX = prevX;
            event.prevY = prevY;
            event.name = "began"
        elseif state == 1 then
            event = sender:getTouchMovePosition();
            event.prevX = prevX;
            event.prevY = prevY;
            prevX = event.x;
            prevY = event.y;
            event.name = "moved"
        elseif state == 2 then
            event = sender:getTouchEndPosition();
            event.prevX = prevX;
            event.prevY = prevY;
            prevX = event.x;
            prevY = event.y;
            event.name = "ended"
        else
            event = sender:getTouchEndPosition();
            event.prevX = prevX;
            event.prevY = prevY;
            prevX = event.x;
            prevY = event.y;
            event.name = "cancelled"
        end
        event.target = sender
        callback(event)
    end)
end

function UIImageBox:getTouchHandler(eventType)
	 
end

function UIImageBox:_getSprite()
    return self:getVirtualRenderer():getSprite()
end

--功能：先加入灰度滤镜设置
--参数：enable 是否设置度图片
function UIImageBox:setGrayEnable(enable,index)
    if enable then
        --暂时这样写   后面找到方法再改
        scheduler.performWithDelayGlobal(function()
            if self._getSprite then
                self:setOpacity(255)

                --todo
                if not tolua.isnull(self:_getSprite()) then
                    darkNode(self:_getSprite(),index)
                end
            end
        end,0.001)
    end
end

function UIImageBox:setEnabled(enable,index)
    if enable ~= self.touchEnable then
        self.touchEnable = enable
    end
    if enable == true then
        self:resetShader()
    end
    --
    self:setGrayEnable(not enable,index)
    
end

function UIImageBox:setOtherEnable(index,isOrigin)
    local sp = self:_getSprite()
    self:setGrayEnable(true,index)
    if isOrigin then
        self:setOriginGLProgram(sp:getGLProgram())
    end
    -- self:getVirtualRenderer():getSprite():getGLProgram():updateUniforms()
end

function UIImageBox:setOriginGLProgramByinit(typeIndex)
    local pProgram
    if typeIndex then
        pProgram = ShaderManager:getShader(typeIndex)
    end
    self:setOriginGLProgram(pProgram or self.initProgram)
  
    scheduler.performWithDelayGlobal(function()
        if self._getSprite then
            self:setOpacity(255)

            --todo
            if not tolua.isnull(self:_getSprite()) then
                self:_getSprite():setGLProgram(self.pProgram)
            end
        end
    end,0.001)
end

function UIImageBox:resetShader()
    if self.pProgram == nil then
        return 
    end
    local sp = self:_getSprite()
	sp:setGLProgram(self.pProgram)
end

function UIImageBox:getTouchRect()
	return self:getBoundingBox()
end


function UIImageBox:isSwallowTouches()
    return true
end

function UIImageBox:setHighlighted(enable)
    self.highlighted = enable
end

function UIImageBox:setImgAnchorPoint(anch)
    self:_getSprite():setAnchorPoint(anch)
end

function UIImageBox:setText(text)
    self.label:setText(text)
end

return UIImageBox