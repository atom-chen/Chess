--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local display = {}
local sharedDirector         = cc.Director:getInstance()
local sharedTextureCache     = cc.TextureCache:getInstance()
local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local sharedAnimationCache   = cc.AnimationCache:getInstance()

local director = cc.Director:getInstance()
local view = director:getOpenGLView()

if not view then
    local width = 960
    local height = 640
    if CC_DESIGN_RESOLUTION then
        if CC_DESIGN_RESOLUTION.width then
            width = CC_DESIGN_RESOLUTION.width
        end
        if CC_DESIGN_RESOLUTION.height then
            height = CC_DESIGN_RESOLUTION.height
        end
    end
    view = cc.GLViewImpl:createWithRect("Cocos2d-Lua", cc.rect(0, 0, width, height))
    director:setOpenGLView(view)
end

local framesize = view:getFrameSize()
local textureCache = director:getTextureCache()
local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local animationCache = cc.AnimationCache:getInstance()

-- auto scale
local function checkResolution(r)
    r.width = checknumber(r.width)
    r.height = checknumber(r.height)
    r.autoscale = string.upper(r.autoscale)
    assert(r.width > 0 and r.height > 0,
        string.format("display - invalid design resolution size %d, %d", r.width, r.height))
end

local function setDesignResolution(r, framesize)
    if r.autoscale == "FILL_ALL" then
        view:setDesignResolutionSize(framesize.width, framesize.height, cc.ResolutionPolicy.FILL_ALL)
    else
        local scaleX, scaleY = framesize.width / r.width, framesize.height / r.height
        local width, height = framesize.width, framesize.height
        if r.autoscale == "FIXED_WIDTH" then
            width = framesize.width / scaleX
            height = framesize.height / scaleX
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "FIXED_HEIGHT" then
            width = framesize.width / scaleY
            height = framesize.height / scaleY
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "EXACT_FIT" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.EXACT_FIT)
        elseif r.autoscale == "NO_BORDER" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.NO_BORDER)
        elseif r.autoscale == "SHOW_ALL" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.SHOW_ALL)
        else
            printError(string.format("display - invalid r.autoscale \"%s\"", r.autoscale))
        end
    end
end

local function setConstants()
    local sizeInPixels = view:getFrameSize()
    display.sizeInPixels = {width = sizeInPixels.width, height = sizeInPixels.height}

    local viewsize = director:getWinSize()
    display.contentScaleFactor = director:getContentScaleFactor()
    display.size               = {width = viewsize.width, height = viewsize.height}
    display.width              = display.size.width
    display.height             = display.size.height
    display.cx                 = display.width / 2
    display.cy                 = display.height / 2
    display.c_left             = -display.width / 2
    display.c_right            = display.width / 2
    display.c_top              = display.height / 2
    display.c_bottom           = -display.height / 2
    display.left               = 0
    display.right              = display.width
    display.top                = display.height
    display.bottom             = 0
    display.center             = cc.p(display.cx, display.cy)
    display.left_top           = cc.p(display.left, display.top)
    display.left_bottom        = cc.p(display.left, display.bottom)
    display.left_center        = cc.p(display.left, display.cy)
    display.right_top          = cc.p(display.right, display.top)
    display.right_bottom       = cc.p(display.right, display.bottom)
    display.right_center       = cc.p(display.right, display.cy)
    display.top_center         = cc.p(display.cx, display.top)
    display.top_bottom         = cc.p(display.cx, display.bottom)

    printInfo(string.format("# display.sizeInPixels         = {width = %0.2f, height = %0.2f}", display.sizeInPixels.width, display.sizeInPixels.height))
    printInfo(string.format("# display.size                 = {width = %0.2f, height = %0.2f}", display.size.width, display.size.height))
    printInfo(string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
    printInfo(string.format("# display.width                = %0.2f", display.width))
    printInfo(string.format("# display.height               = %0.2f", display.height))
    printInfo(string.format("# display.cx                   = %0.2f", display.cx))
    printInfo(string.format("# display.cy                   = %0.2f", display.cy))
    printInfo(string.format("# display.left                 = %0.2f", display.left))
    printInfo(string.format("# display.right                = %0.2f", display.right))
    printInfo(string.format("# display.top                  = %0.2f", display.top))
    printInfo(string.format("# display.bottom               = %0.2f", display.bottom))
    printInfo(string.format("# display.c_left               = %0.2f", display.c_left))
    printInfo(string.format("# display.c_right              = %0.2f", display.c_right))
    printInfo(string.format("# display.c_top                = %0.2f", display.c_top))
    printInfo(string.format("# display.c_bottom             = %0.2f", display.c_bottom))
    printInfo(string.format("# display.center               = {x = %0.2f, y = %0.2f}", display.center.x, display.center.y))
    printInfo(string.format("# display.left_top             = {x = %0.2f, y = %0.2f}", display.left_top.x, display.left_top.y))
    printInfo(string.format("# display.left_bottom          = {x = %0.2f, y = %0.2f}", display.left_bottom.x, display.left_bottom.y))
    printInfo(string.format("# display.left_center          = {x = %0.2f, y = %0.2f}", display.left_center.x, display.left_center.y))
    printInfo(string.format("# display.right_top            = {x = %0.2f, y = %0.2f}", display.right_top.x, display.right_top.y))
    printInfo(string.format("# display.right_bottom         = {x = %0.2f, y = %0.2f}", display.right_bottom.x, display.right_bottom.y))
    printInfo(string.format("# display.right_center         = {x = %0.2f, y = %0.2f}", display.right_center.x, display.right_center.y))
    printInfo(string.format("# display.top_center           = {x = %0.2f, y = %0.2f}", display.top_center.x, display.top_center.y))
    printInfo(string.format("# display.top_bottom           = {x = %0.2f, y = %0.2f}", display.top_bottom.x, display.top_bottom.y))
    printInfo("#")
end

function display.setAutoScale(configs)
    if type(configs) ~= "table" then return end

    checkResolution(configs)
    if type(configs.callback) == "function" then
        local c = configs.callback(framesize)
        for k, v in pairs(c or {}) do
            configs[k] = v
        end
        checkResolution(configs)
    end

    setDesignResolution(configs, framesize)

    printInfo(string.format("# design resolution size       = {width = %0.2f, height = %0.2f}", configs.width, configs.height))
    printInfo(string.format("# design resolution autoscale  = %s", configs.autoscale))
    setConstants()
end

if type(CC_DESIGN_RESOLUTION) == "table" then
    display.setAutoScale(CC_DESIGN_RESOLUTION)
end

display.COLOR_WHITE = cc.c3b(255, 255, 255)
display.COLOR_BLACK = cc.c3b(0, 0, 0)
display.COLOR_RED   = cc.c3b(255, 0, 0)
display.COLOR_GREEN = cc.c3b(0, 255, 0)
display.COLOR_BLUE  = cc.c3b(0, 0, 255)

display.AUTO_SIZE      = 0
display.FIXED_SIZE     = 1
display.LEFT_TO_RIGHT  = 0
display.RIGHT_TO_LEFT  = 1
display.TOP_TO_BOTTOM  = 2
display.BOTTOM_TO_TOP  = 3

display.CENTER        = cc.p(0.5, 0.5)
display.LEFT_TOP      = cc.p(0, 1)
display.TOP_LEFT      = cc.p(0, 1)
display.LEFT_BOTTOM   = cc.p(0, 0)
display.BOTTOM_LEFT   = cc.p(0, 0)
display.LEFT_CENTER   = cc.p(0, 0.5)
display.CENTER_LEFT   = cc.p(0, 0.5)
display.RIGHT_TOP     = cc.p(1, 1)
display.TOP_RIGHT     = cc.p(1, 1)
display.RIGHT_BOTTOM  = cc.p(1, 0)
display.BOTTOM_RIGHT  = cc.p(1, 0)
display.RIGHT_CENTER  = cc.p(1, 0.5)
display.CENTER_RIGHT  = cc.p(1, 0.5)
display.CENTER_TOP    = cc.p(0.5, 1)
display.TOP_CENTER    = cc.p(0.5, 1)
display.CENTER_BOTTOM = cc.p(0.5, 0)
display.BOTTOM_CENTER = cc.p(0.5, 0)

display.SCENE_TRANSITIONS = {
    CROSSFADE       = cc.TransitionCrossFade,
    FADE            = {cc.TransitionFade, cc.c3b(0, 0, 0)},
    FADEBL          = cc.TransitionFadeBL,
    FADEDOWN        = cc.TransitionFadeDown,
    FADETR          = cc.TransitionFadeTR,
    FADEUP          = cc.TransitionFadeUp,
    FLIPANGULAR     = {cc.TransitionFlipAngular, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPX           = {cc.TransitionFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPY           = {cc.TransitionFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
    JUMPZOOM        = cc.TransitionJumpZoom,
    MOVEINB         = cc.TransitionMoveInB,
    MOVEINL         = cc.TransitionMoveInL,
    MOVEINR         = cc.TransitionMoveInR,
    MOVEINT         = cc.TransitionMoveInT,
    PAGETURN        = {cc.TransitionPageTurn, false},
    ROTOZOOM        = cc.TransitionRotoZoom,
    SHRINKGROW      = cc.TransitionShrinkGrow,
    SLIDEINB        = cc.TransitionSlideInB,
    SLIDEINL        = cc.TransitionSlideInL,
    SLIDEINR        = cc.TransitionSlideInR,
    SLIDEINT        = cc.TransitionSlideInT,
    SPLITCOLS       = cc.TransitionSplitCols,
    SPLITROWS       = cc.TransitionSplitRows,
    TURNOFFTILES    = cc.TransitionTurnOffTiles,
    ZOOMFLIPANGULAR = cc.TransitionZoomFlipAngular,
    ZOOMFLIPX       = {cc.TransitionZoomFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    ZOOMFLIPY       = {cc.TransitionZoomFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
}

display.TEXTURES_PIXEL_FORMAT = {}

display.DEFAULT_TTF_FONT        = "Arial"
display.DEFAULT_TTF_FONT_SIZE   = 32


local PARAMS_EMPTY = {}
local RECT_ZERO = cc.rect(0, 0, 0, 0)

local sceneIndex = 0
function display.newScene(name, params)
    params = params or PARAMS_EMPTY
    sceneIndex = sceneIndex + 1
    local scene
    if not params.physics then
        scene = cc.Scene:create()
    else
        scene = cc.Scene:createWithPhysics()
    end
    scene.name_ = string.format("%s:%d", name or "<unknown-scene>", sceneIndex)

    if params.transition then
        scene = display.wrapSceneWithTransition(scene, params.transition, params.time, params.more)
    end

    return scene
end

function display.wrapScene(scene, transition, time, more)
    local key = string.upper(tostring(transition))

    if key == "RANDOM" then
        local keys = table.keys(display.SCENE_TRANSITIONS)
        key = keys[math.random(1, #keys)]
    end

    if display.SCENE_TRANSITIONS[key] then
        local t = display.SCENE_TRANSITIONS[key]
        time = time or 0.2
        more = more or t[2]
        if type(t) == "table" then
            scene = t[1]:create(time, scene, more)
        else
            scene = t:create(time, scene)
        end
    else
        error(string.format("display.wrapScene() - invalid transition %s", tostring(transition)))
    end
    return scene
end

function display.runScene(newScene, transition, time, more)
    if director:getRunningScene() then
        if transition then
            newScene = display.wrapScene(newScene, transition, time, more)
        end
        director:replaceScene(newScene)
    else
        director:runWithScene(newScene)
    end
end

function display.replaceScene(newScene, transition, time, more)
    if director:getRunningScene() then
        if transition then
            newScene = display.wrapScene(newScene, transition, time, more)
        end
        director:replaceScene(newScene)
    else
        director:runWithScene(newScene)
    end
end

function display.getRunningScene()
    return director:getRunningScene()
end

function display.newNode()
    return cc.Node:create()
end

function display.newLayer(...)
    local params = {...}
    local c = #params
    local layer
    if c == 0 then
        -- /** creates a fullscreen black layer */
        -- static Layer *create();
        layer = cc.Layer:create()
    elseif c == 1 then
        -- /** creates a Layer with color. Width and height are the window size. */
        -- static LayerColor * create(const Color4B& color);
        layer = cc.LayerColor:create(cc.convertColor(params[1], "4b"))
    elseif c == 2 then
        -- /** creates a Layer with color, width and height in Points */
        -- static LayerColor * create(const Color4B& color, const Size& size);
        --
        -- /** Creates a full-screen Layer with a gradient between start and end. */
        -- static LayerGradient* create(const Color4B& start, const Color4B& end);
        local color1 = cc.convertColor(params[1], "4b")
        local p2 = params[2]
        assert(type(p2) == "table" and (p2.width or p2.r), "display.newLayer() - invalid paramerter 2")
        if p2.r then
            layer = cc.LayerGradient:create(color1, cc.convertColor(p2, "4b"))
        else
            layer = cc.LayerColor:create(color1, p2.width, p2.height)
        end
    elseif c == 3 then
        -- /** creates a Layer with color, width and height in Points */
        -- static LayerColor * create(const Color4B& color, GLfloat width, GLfloat height);
        --
        -- /** Creates a full-screen Layer with a gradient between start and end in the direction of v. */
        -- static LayerGradient* create(const Color4B& start, const Color4B& end, const Vec2& v);
        local color1 = cc.convertColor(params[1], "4b")
        local p2 = params[2]
        local p2type = type(p2)
        if p2type == "table" then
            layer = cc.LayerGradient:create(color1, cc.convertColor(p2, "4b"), params[3])
        else
            layer = cc.LayerColor:create(color1, p2, params[3])
        end
    end
    return layer
end


--[[--

创建并返回一个 CCSprite 显示对象。

display.newSprite() 有三种方式创建显示对象：

-   从图片文件创建
-   从缓存的图像帧创建
-   从 CCSpriteFrame 对象创建

~~~ lua

-- 从图片文件创建显示对象
local sprite1 = display.newSprite("hello1.png")

-- 从缓存的图像帧创建显示对象
-- 图像帧的名字就是图片文件名，但为了和图片文件名区分，所以此处需要在文件名前添加 “#” 字符
-- 添加 “#” 的规则适用于所有需要区分图像和图像帧的地方
local sprite2 = display.newSprite("#frame0001.png")

-- 从 CCSpriteFrame 对象创建
local frame = display.newFrame("frame0002.png")
local sprite3 = display.newSprite(frame)

~~~

如果指定了 x,y 参数，那么创建显示对象后会调用对象的 setPosition() 方法设置对象位置。

@param mixed 图像名或CCSpriteFrame对象
@param number x
@param number y
@param table params

@return CCSprite

@see CCSprite

]]
function display.newSprite(filename, x, y, params)
   local spriteClass = nil
   local size = nil

   if params then
       spriteClass = params.class
       size = params.size
   end
   if not spriteClass then spriteClass = cc.Sprite end

   local t = type(filename)
   if t == "userdata" then t = tolua.type(filename) end
   local sprite

   if not filename then
       sprite = spriteClass:create()
   elseif t == "string" then
       if string.byte(filename) == 35 then -- first char is #
        -- print(" filename ========!!!!!!!!!!============== ",filename)
        -- print(" filename ========@@@@@@@@@@============== ",string.sub(filename, 2))
           local frame = display.newSpriteFrame(string.sub(filename, 2))
           if frame then
               sprite = spriteClass:createWithSpriteFrame(frame)
            else
                sprite = cc.Sprite:create(string.sub(filename, 2))--用的全路径原图
                if not sprite then
                    sprite = spriteClass:create("unKnown.png")
                end
                -- sprite.isUnKnown = true
           end
       else
           if display.TEXTURES_PIXEL_FORMAT[filename] then
               cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[filename])
               sprite = spriteClass:create(filename)
               cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
           else
               sprite = spriteClass:create(filename)
           end
       end
  elseif t == "cc.SpriteFrame" then
       sprite = spriteClass:createWithSpriteFrame(filename)
    elseif t == "cc.Texture2D" then
        sprite = spriteClass:createWithTexture(filename)
   else
       print("display.newSprite() - invalid filename value type")
       sprite = spriteClass:create()
   end

   if sprite then
       if x and y then sprite:setPosition(x, y) end
       if size then sprite:setContentSize(size) end
   else
       print("display.newSprite() - create sprite failure, filename %s", tostring(filename))
       sprite = spriteClass:create()
   end

   return sprite
end

-- function display.newSprite(source, x, y, params)
--     local spriteClass = cc.Sprite
--     local scale9 = false

--     if type(x) == "table" and not x.x then
--         -- x is params
--         params = x
--         x = nil
--         y = nil
--     end

--     local params = params or PARAMS_EMPTY
--     if params.scale9 or params.capInsets then
--         spriteClass = ccui.Scale9Sprite
--         scale9 = true
--         params.capInsets = params.capInsets or RECT_ZERO
--         params.rect = params.rect or RECT_ZERO
--     end

--     local sprite
--     while true do
--         -- create sprite
--         if not source then
--             sprite = spriteClass:create()
--             break
--         end

--         local sourceType = type(source)
--         if sourceType == "string" then
--             if string.byte(source) == 35 then -- first char is #
--                 -- create sprite from spriteFrame
--                 if not scale9 then
--                     sprite = spriteClass:createWithSpriteFrameName(string.sub(source, 2))
--                 else
--                     sprite = spriteClass:createWithSpriteFrameName(string.sub(source, 2), params.capInsets)
--                 end
--                 break
--             end

--             -- create sprite from image file
--             if display.TEXTURES_PIXEL_FORMAT[source] then
--                 cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[source])
--             end
--             if not scale9 then
--                 sprite = spriteClass:create(source)
--             else
--                 sprite = spriteClass:create(source, params.rect, params.capInsets)
--             end
--             if display.TEXTURES_PIXEL_FORMAT[source] then
--                 cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
--             end
--             break
--         elseif sourceType ~= "userdata" then
--             error(string.format("display.newSprite() - invalid source type \"%s\"", sourceType), 0)
--         else
--             sourceType = tolua.type(source)
--             if sourceType == "cc.SpriteFrame" then
--                 if not scale9 then
--                     sprite = spriteClass:createWithSpriteFrame(source)
--                 else
--                     sprite = spriteClass:createWithSpriteFrame(source, params.capInsets)
--                 end
--             elseif sourceType == "cc.Texture2D" then
--                 sprite = spriteClass:createWithTexture(source)
--             else
--                 error(string.format("display.newSprite() - invalid source type \"%s\"", sourceType), 0)
--             end
--         end
--         break
--     end

--     if sprite then
--         if x and y then sprite:setPosition(x, y) end
--         if params.size then sprite:setContentSize(params.size) end
--     else
--         error(string.format("display.newSprite() - create sprite failure, source \"%s\"", tostring(source)), 0)
--     end

--     return sprite
-- end

function display.newSpriteFrame(source, ...)
    local frame
    if type(source) == "string" then
        if string.byte(source) == 35 then -- first char is #
            source = string.sub(source, 2)
        end
        frame = spriteFrameCache:getSpriteFrame(source)
        if not frame then
            return nil
            -- error(string.format("display.newSpriteFrame() - invalid frame name \"%s\"", tostring(source)), 0)
        end
    elseif tolua.type(source) == "cc.Texture2D" then
        frame = cc.SpriteFrame:createWithTexture(source, ...)
    else
        error("display.newSpriteFrame() - invalid parameters", 0)
    end
    return frame
end

function display.newFrames(pattern, begin, length, isReversed)
    local frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end

    for index = begin, last, step do
        local frameName = string.format(pattern, index)
        local frame = spriteFrameCache:getSpriteFrame(frameName)
        if not frame then
            error(string.format("display.newFrames() - invalid frame name %s", tostring(frameName)), 0)
        end
        frames[#frames + 1] = frame
    end
    return frames
end

local function newAnimation(frames, time)
    local count = #frames
    assert(count > 0, "display.newAnimation() - invalid frames")
    time = time or 1.0 / count
    return cc.Animation:createWithSpriteFrames(frames, time),
           cc.Sprite:createWithSpriteFrame(frames[1])
end

function display.newAnimation(...)
    local params = {...}
    local c = #params
    if c == 2 then
        -- frames, time
        return newAnimation(params[1], params[2])
    elseif c == 4 then
        -- pattern, begin, length, time
        local frames = display.newFrames(params[1], params[2], params[3])
        return newAnimation(frames, params[4])
    elseif c == 5 then
        -- pattern, begin, length, isReversed, time
        local frames = display.newFrames(params[1], params[2], params[3], params[4])
        return newAnimation(frames, params[5])
    else
        error("display.newAnimation() - invalid parameters")
    end
end

function display.loadImage(imageFilename, callback)
    if not callback then
        return textureCache:addImage(imageFilename)
    else
        textureCache:addImageAsync(imageFilename, callback)
    end
end

local fileUtils = cc.FileUtils:getInstance()
function display.getImage(imageFilename)
    local fullpath = fileUtils:fullPathForFilename(imageFilename)
    return textureCache:getTextureForKey(fullpath)
end

function display.removeImage(imageFilename)
    textureCache:removeTextureForKey(imageFilename)
end

function display.loadSpriteFrames(dataFilename, imageFilename, callback)
    if display.TEXTURES_PIXEL_FORMAT[imageFilename] then
        cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[imageFilename])
    end
    if not callback then
        spriteFrameCache:addSpriteFrames(dataFilename, imageFilename)
    else
        spriteFrameCache:addSpriteFramesAsync(dataFilename, imageFilename, callback)
    end
    if display.TEXTURES_PIXEL_FORMAT[imageFilename] then
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
    end
end

function display.removeSpriteFrames(dataFilename, imageFilename)
    spriteFrameCache:removeSpriteFramesFromFile(dataFilename)
    if imageFilename then
        display.removeImage(imageFilename)
    end
end

function display.removeSpriteFrame(imageFilename)
    spriteFrameCache:removeSpriteFrameByName(imageFilename)
end

function display.setTexturePixelFormat(imageFilename, format)
    display.TEXTURES_PIXEL_FORMAT[imageFilename] = format
end

function display.setAnimationCache(name, animation)
    animationCache:addAnimation(animation, name)
end

function display.getAnimationCache(name)
    return animationCache:getAnimation(name)
end

function display.removeAnimationCache(name)
    animationCache:removeAnimation(name)
end

function display.removeUnusedSpriteFrames()
    spriteFrameCache:removeUnusedSpriteFrames()
    textureCache:removeUnusedTextures()
end


--[[--

创建并返回一个 CCSprite9Scale 显示对象。

格式：

sprite = display.newScale9Sprite(图像名, [x, y], [CCSize 对象])

CCSprite9Scale 就是通常所說的“九宫格”图像。一个矩形图像会被分为 9 部分，然后根据要求拉伸图像，同时保证拉伸后的图像四边不变形。

~~~ lua

-- 创建一个 Scale9 图像，并拉伸到 400, 300 点大小
local sprite = display.newScale9Sprite("Box.png", 0, 0, CCSize(400, 300))

~~~

@param string filename 图像名
@param integer x
@param integer y
@param CCSize size

@return CCSprite9Scale CCSprite9Scale显示对象

]]
function display.newScale9Sprite(filename, x, y, size)
    return display.newSprite(filename, x, y, {class = cc.Scale9Sprite, size = size})
end

--[[--

将指定的显示对象按照特定锚点对齐。

格式：

display.align(显示对象, 锚点位置, [x, y])

显示对象锚点位置：

-   display.CENTER 图像中央
-   display.LEFT_TOP,
-   display.TOP_LEFT 图像左上角
-   display.CENTER_TOP,
-   display.TOP_CENTER 图像顶部的中间
-   display.RIGHT_TOP,
-   display.TOP_RIGHT 图像顶部的中间
-   display.CENTER_LEFT,
-   display.LEFT_CENTER 图像左边的中间
-   display.CENTER_RIGHT,
-   display.RIGHT_CENTER 图像右边的中间
-   display.BOTTOM_LEFT,
-   display.LEFT_BOTTOM 图像左边的底部
-   display.BOTTOM_RIGHT,
-   display.RIGHT_BOTTOM 图像右边的底部
-   display.BOTTOM_CENTER,
-   display.CENTER_BOTTOM 图像中间的底部

~~~ lua

-- 将图像按左上角对齐，并放置在屏幕左上角
display.align(sprite, display.LEFT_TOP, 0, 0)

~~~

@param CCSprite target 显示对象
@param integer anchorPoint 锚点位置
@param integer x
@param integer y

]]
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
function display.align(target, anchorPoint, x, y)
    assert(target, "display.align() target is nil")
    target:setAnchorPoint(anchorPoint)

    if target.__cname == "UILabel" then
        -- if targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_ANDROID then
            -- if target.font == NORMALFONT then
                -- y = y - 3
            -- end
        -- end
        if targetPlatform == cc.PLATFORM_OS_ANDROID then
            -- if target.font == NORMALFONT then
                -- y = y - 3
            -- end
        end
    end
    if x and y then target:setPosition(x, y) end
end



--
-- Function: addSpriteFrame
-- Description: 把单张图片加到缓存中，并以图片名字命名
-- Param: 
--     string imageName 图片名字
-- Return: 
--     CCSpriteFrame 返回一个iamgeName创建的CCSpriteFrame
--
function display.addSpriteFrame(iamgeName, imageFormat)
    local pTexture = nil;
    if imageFormat then
        pTexture = sharedTextureCache:addImage(iamgeName, imageFormat);
    else
        pTexture = sharedTextureCache:addImage(iamgeName);
    end
     
    local spriteFrame = nil;
    if pTexture then
        print("  in pTexture ~~~~~~~~~~~~~~~~~~~~ ")
        local rect = cc.rect(0, 0, 0, 0);
        rect.size = pTexture:getContentSize();
        print("   rect.size ========== ",rect.size.width,rect.size.height)
        spriteFrame = cc.SpriteFrame:createWithTexture(pTexture, rect);
    end
    print("   spriteFrame ==================",spriteFrame)
    sharedSpriteFrameCache:addSpriteFrame(spriteFrame, iamgeName);
    return spriteFrame;
end

--[[Sprite Sheets 通俗一点解释就是包含多张图片的集合。Sprite Sheets 材质文件由多张图片组成，而数据文件则记录了图片在材质文件中的位置等信息。

@param string plistFilename 数据文件名
@param string image 材质文件名
@param string imageFormat 图片格式 .png .pvr.ccz
@see Sprite Sheets

]]
function display.addSpriteFramesWithFile(plistFilename, image, imageFormat, handler)
    local async = type(handler) == "function"
    local asyncHandler = nil
    if async then
        asyncHandler = function()
            -- printf("%s, %s async done.", plistFilename, image)
            local texture = sharedTextureCache:getTextureForKey(image)
            assert(texture, string.format("The texture %s, %s, %s is unavailable.", plistFilename, image, imageFormat))
            sharedSpriteFrameCache:addSpriteFrames(plistFilename)
            handler(plistFilename, image, imageFormat)
        end
    end

    if display.TEXTURES_PIXEL_FORMAT[image] then
        cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[image])
        if async then
            sharedTextureCache:addImageAsync(image, asyncHandler)
        else
            sharedSpriteFrameCache:addSpriteFrames(plistFilename)
        end
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
    else
        if async then
            sharedTextureCache:addImageAsync(image, asyncHandler)
        else
            sharedSpriteFrameCache:addSpriteFrames(plistFilename)
        end
    end
end


return display
