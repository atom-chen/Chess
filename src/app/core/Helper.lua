
SCROLLBARWIDTH = 8
SceneNodeTag_Lock = 1700
SceneNodeTag_MoveLabel = 2000

function lockScreen(params)
    local scene = display:getRunningScene()
    
    if scene.lockLayer then
        scene.lockLayer:removeFromParent()
        scene.lockLayer = nil
    end
    local color4 = params.color4 or cc.c4b(0,0,0,0)
    local time = params.time
    local onClick = params.onClick
    scene.lockLayer = cc.LayerColor:create(color4)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        if onClick then
            onClick()
        end
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = scene.lockLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,scene.lockLayer)

    scene:addChild(scene.lockLayer, SceneNodeTag_Lock)

    if time then
        local action = transition.sequence({cc.DelayTime:create(time),
            cc.CallFunc:create(function()
                if scene.lockLayer then
                    scene.lockLayer:removeFromParent()
                    scene.lockLayer = nil
                end        
            end)})
        scene:runAction(action)
    end
end

function unLockScreen()
    local scene = display:getRunningScene()
    if scene.lockLayer then
        scene.lockLayer:removeFromParent()
        scene.lockLayer = nil
    end
end
