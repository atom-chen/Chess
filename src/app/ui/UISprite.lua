local UISprite = class("UISprite", function(name, spriteClass) 
	local image = nil;
    if tolua.type(name) == "cc.SpriteFrame" then
        image = name;
    else
        image = "#" .. name
    end
    
    local sprite = display.newSprite(image, nil, nil, {class = spriteClass});
    return sprite;
end)

function UISprite.create(path)
	return UISprite.new(path)
end

function UISprite:onEnter()
	-- printInfo("%s:onEnter()",self.class.__cname);
end

function UISprite:onEnterTransitionFinish()
	-- printInfo("%s:onEnterTransitionFinish()",self.class.__cname);
end

function UISprite:onExitTransitionStart()
	-- printInfo("%s:onExitTransitionStart()",self.class.__cname);	
end

function UISprite:onExit()
	-- printInfo("%s:onExit()",self.class.__cname);
end

function UISprite:onCleanup()
	-- printInfo("%s:onCleanup()",self.class.__cname);
end

function UISprite:setGrayEnable(enable)
    if enable then
    	--print("  我日啊日啊日  ")
        darkNode(self)
    end
end

function UISprite:setEnabled(enable)
    if enable ~= self.touchEnable then
        self.touchEnable = enable
    end

    self:setGrayEnable(not enable)
end

function createClipSprite(bgPath, maskPath, bgScale,maskScale)
    --特殊处理下英雄头像来做玩家头像的情况？
    -- if string.find(bgPath,"head_") ==true and (bgScale ~= nil and bgScale == 1.17) then
    --     bgScale = bgScale * 0.89
    -- end
    local bg = UISprite.create(bgPath)
    bg:setScale(bgScale or 1)
    -- bg:setScaleX(bg:getScaleX() * -1)
    bg:setScaleY(bg:getScaleY() * -1)
    local  mask = UISprite.create(maskPath)
    if maskScale then
        mask:setScale(maskScale)
    end
    -- mask:setScaleX(mask:getScaleX() * -1)
    mask:setScaleY(mask:getScaleY() * -1)
    
    local size = mask:getContentSize()
    mask:setPosition(cc.p(size.width/2, size.height/2))
    bg:setPosition(cc.p(size.width/2, size.height/2))

    bg:setBlendFunc(gl.DST_COLOR, gl.ONE_MINUS_DST_COLOR)
    local render = cc.RenderTexture:create(size.width, size.height)
      
    local sprite = render:getSprite()
    sprite:setOpacityModifyRGB(false)
    local texture = sprite:getTexture()
    texture:setAntiAliasTexParameters()
    
    render:beginWithClear(0, 0, 0, 0)
    mask:visit()
    bg:visit()
    render:endToLua()
    
    local newSprite = cc.Sprite:createWithTexture(sprite:getTexture())
    newSprite:setOpacityModifyRGB(false)
 
    newSprite:setBlendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA)
    return newSprite
end

return UISprite