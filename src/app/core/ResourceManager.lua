
local ResourceManager = class("ResourceManager")

ResourceManager.resSpine = {0,0,data} --一般资源的spine{最近创建次数， 现在有的资源数}

function ResourceManager.removeAll()
    for k,v in pairs(ResourceManager.resSpine) do
        if k ~= 1 and k ~= 2 then 
            local removePath = ResMgr.spinePath[k]
            DHSkeletonDataCache:getInstance():removeSkeletonData(k)

            for var = 0, ResMgr.spineResNum[k] - 1 do
                -- print(" resSpine  pngPaths[k] 1======================= ",v,ResourceManager.resSpine[removeIndex].pngPaths[k])
                local plistPath = removePath.."/skeleton"..var..".plist"
                local pngPath = removePath.."/skeleton"..var..".png"
                display.removeSpriteFramesWithFile(plistPath, pngPath)
            end
            ResourceManager.resSpine[k] = nil
        else
            ResourceManager.resSpine[k] = 0
        end
    end

    sp.SkeletonCache:getInstance():clearSkeleton()
end

function ResourceManager:ctor()
    
end

function ResourceManager:createAnimation(path, scale, unschedule)
    if not cc.FileUtils:getInstance():isFileExist(path .. "/skeleton.json") then
        return
    end

    local plistPaths , pngPaths = {},{}
    local index = 0
    local scale = scale or 1

    -- local _, _ , name = string.find(path, ".+/(.+)$")    
    -- local num = ResMgr.spineResNum[name] or 0
    -- --print("name namecreateAnimation ", name, num)
    -- if num == 0 then 
    --     return nil
    -- end

    local plistPath = path.."/skeleton.atlas"--path.."/skeleton"..var..".atlas"
    local pngPath = path.."/skeleton.png"--path.."/skeleton"..var..".png"
    local jsonPath = path.."/skeleton.json"
    sp.SkeletonCache:getInstance():loadSkeletonData(path, jsonPath, plistPath, scale)
    local spine = sp.SkeletonAnimation:createWithKey(path, scale)

    if not unschedule then
        spine:scheduleUpdate(function()end)
    end

    return spine
end

function ResourceManager:createAnimation2(path, scale, isCont, isHeroAnim)
    local plistPaths , pngPaths = {},{}
    local index = 0
    local isHeroAnim = isHeroAnim
    if string.find(path,"spine/actors") then
        isHeroAnim = true
    end


    -- local num = ResMgr.spineResNum[name] or 0
    --print("name namecreateAnimation ", name, num)
    -- if num == 0 then 
    --     return nil
    -- end

    -- for var=0, num - 1 do
    --     local plistPath = path.."/skeleton"..var..".plist"
    --     local pngPath = path.."/skeleton"..var..".png"
        

    --         cc.SpriteFrameCache:getInstance():addSpriteFrames(plistPath)

    -- end
    local plistPath = path.."/skeleton0.plist"
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plistPath)

    local jsonPath = path.."/skeleton.json"
    print("   name =============== ",name)
    print("   jsonPath =============== ",jsonPath)
    DHSkeletonDataCache:getInstance():loadSkeletonData(name,jsonPath,(scale and scale) or 1)
    local spine = DHSkeletonAnimation:createWithKey(name)
    self:popSpineCont(name,isCont, isHeroAnim)

    return spine
end

function ResourceManager:popSpineCont(path,isCont, isHeroAnim)
    if not path or isCont then return end

    if ResourceManager.resSpine[path] then
        ResourceManager.resSpine[path][1] = ResourceManager.resSpine[path][1] + 1
        ResourceManager.resSpine[1] =  ResourceManager.resSpine[1] + 1
        ResourceManager.resSpine[path][2] = ResourceManager.resSpine[1]
        return
    end
    if ResourceManager.resHeroSpine[path] then 
        ResourceManager.resHeroSpine[path][1] = ResourceManager.resHeroSpine[path][1] + 1
        ResourceManager.resHeroSpine[1] =  ResourceManager.resHeroSpine[1] + 1
        ResourceManager.resHeroSpine[path][2] = ResourceManager.resHeroSpine[1]
        return
    end
    --print("load spine ",path)
    --if string.find(path,"spine/actors") then
    if isHeroAnim then
        ResourceManager.resHeroSpine[1] =  ResourceManager.resHeroSpine[1] + 1
        ResourceManager.resHeroSpine[2] =  ResourceManager.resHeroSpine[2] + 1
        ResourceManager.resHeroSpine[path] = {1, ResourceManager.resHeroSpine[1]}
    else
        ResourceManager.resSpine[1] =  ResourceManager.resSpine[1] + 1
        ResourceManager.resSpine[2] =  ResourceManager.resSpine[2] + 1
        ResourceManager.resSpine[path] = {1, ResourceManager.resSpine[1]}
    end
    
    local pIndex = 100 --一般的spine动画个数
    local phIndex = 100 --英雄的spine动画个数
    if ResourceManager.resSpine[2] > pIndex then
        local removeKey = nil
        local removeValue = nil
        for k, v in pairs(ResourceManager.resSpine) do
            if k ~=1 and k ~= 2 then 
                if removeKey == nil then 
                    removeKey = k
                    removeValue = v
                else
                    if removeValue[2] > v[2] then --最近未使用
                        removeKey = k
                        removeValue = v
                    elseif removeValue[1] > v[1] then --最少使用
                        removeKey = k
                        removeValue = v  
                    end
                end
            end
        end
        
        local removePath = ResMgr.spinePath[removeKey]
        DHSkeletonDataCache:getInstance():removeSkeletonData(removeKey)

        for var = 0, ResMgr.spineResNum[path] - 1 do
            -- print(" resSpine  pngPaths[k] 1======================= ",v,ResourceManager.resSpine[removeIndex].pngPaths[k])
            local plistPath = removePath.."/skeleton"..var..".plist"
            local pngPath = removePath.."/skeleton"..var..".png"
            display.removeSpriteFramesWithFile(plistPath, pngPath)
        end

        ResourceManager.resSpine[removeKey] = nil
        ResourceManager.resSpine[2] =  ResourceManager.resSpine[2] - 1
    end

    if ResourceManager.resHeroSpine[2] > phIndex then
        local removeKey = nil
        local removeValue = nil
        for k, v in pairs(ResourceManager.resHeroSpine) do
            if k ~=1 and k ~= 2 then 
                if removeKey == nil then 
                    removeKey = k
                    removeValue = v
                else
                    if removeValue[2] > v[2] then --最近未使用
                        removeKey = k
                        removeValue = v
                    elseif removeValue[1] > v[1] then --最少使用
                        removeKey = k
                        removeValue = v  
                    end
                end
            end
        end
        local removePath = ResMgr.spinePath[removeKey]
        DHSkeletonDataCache:getInstance():removeSkeletonData(removeKey)

        for var = 0, ResMgr.spineResNum[path] - 1 do
            -- print(" resHeroSpine  pngPaths[k] 1======================= ",v,ResourceManager.resHeroSpine[removeIndex].pngPaths[k])
            local plistPath = removePath.."/skeleton"..var..".plist"
            local pngPath = removePath.."/skeleton"..var..".png"
            display.removeSpriteFramesWithFile(plistPath, pngPath)
        end

        ResourceManager.resHeroSpine[removeKey] = nil
        ResourceManager.resHeroSpine[2] =  ResourceManager.resHeroSpine[2] - 1
    end

    -- print("     #ResourceManager.resSpine 1======================= ",#ResourceManager.resSpine)
    -- print("     #ResourceManager.resHeroSpine 1======================= ",#ResourceManager.resHeroSpine)
end

return ResourceManager