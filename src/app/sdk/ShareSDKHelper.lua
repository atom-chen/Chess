--
-- ShareSDKHelper ShareSDK分享辅助
-- Author: mafei
-- Date: 2015-07-21 16:30:32
--
local luaj_error = {
    [-1]='不支持的参数类型或返回值类型',
    [-2]='无效的签名',
    [-3]='没有找到指定的方法',
    [-4]='Java 方法执行时抛出了异常',
    [-5]='Java 虚拟机出错',
    [-6]='Java 虚拟机出错',
}

local SDK_className = "org/cocos2dx/lua/ShareSDKHelper"
local ShareSDKHelper = class("ShareSDKHelper")

-- Gender = {}
-- Gender.UNKNOWN = 0
-- Gender.M = 1
-- Gender.F = 2

-- QuestStatus = {}
-- QuestStatus.a = 0
-- QuestStatus.c = 1
-- QuestStatus.f = 2

SSPublishContentMediaType = {}
SSPublishContentMediaType.SSPublishContentMediaTypeText = 0 -- 文本 
SSPublishContentMediaType.SSPublishContentMediaTypeImage = 1 -- 图片 
SSPublishContentMediaType.SSPublishContentMediaTypeNews = 2 -- 新闻 
SSPublishContentMediaType.SSPublishContentMediaTypeMusic = 3 -- 音乐 
SSPublishContentMediaType.SSPublishContentMediaTypeVideo = 4 -- 视频 
SSPublishContentMediaType.SSPublishContentMediaTypeApp = 5 -- 应用,仅供微信使用 
SSPublishContentMediaType.SSPublishContentMediaTypeNonGif = 6 -- 非Gif消息,仅供微信使用 
SSPublishContentMediaType.SSPublishContentMediaTypeGif = 7 -- Gif消息,仅供微信使用 


-- 使用历程
-- local data = {
--     content = "分享内容",
--     defaultContent = "测试一下",
--     image = "/sdcard/temp/test.png",
--     title = "标题",
--     url = "http://www.mob.com",
--     description = "这是一条测试信息"
--     mediaType = SSPublishContentMediaType.SSPublishContentMediaTypeNews,
-- }
-- ShareSDKHelper:shareMessage(data,function(ret) 
--     if ret.success == true then
--     else
--     end
--     end)

function ShareSDKHelper:shareMessage(params,callBack)
    local publish = cc.UserDefault:getInstance():getStringForKey("key_publish", "normal")
    if publish == "wanda" then
        local _params = params or {}

        local temp = {
            json.encode(_params),
            function (_retDat)
                if type(_retDat) == 'table' then
                    callBack(_retDat)
                else
                    callBack(loadstring('return '.._retDat)())
                end
            end
            
        }

        self:callStaticMethod("shareMessage",temp)
    end
end

function ShareSDKHelper:callStaticMethod(methodName,args,sig)
	--table.print(args)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        -- 调用方法并获得返回值
        local ok, ret = luaj.callStaticMethod(SDK_className, methodName, args, sig)

        --if not ok then
        --    print("luaj error", SDK_className,methodName,table.toString(args),"ret",ret,luaj_error[ret])
        --else
        --    print("luaj ret", SDK_className,methodName,table.toString(args),"ret",ret,luaj_error[ret])
        --end
    elseif targetPlatform == cc.PLATFORM_OS_IPAD or targetPlatform == cc.PLATFORM_OS_IPHONE then
    	--CCLuaObjcBridge调Objective-C方法传索引数组报invalid key to 'next'错调试
    	--http://blog.csdn.net/lixianlin/article/details/24310789
    	local ocParams = {}
    	for k,v in pairs(args) do
    		if type(k) == 'number' then
    			ocParams['_'..tostring(k)] = v
    		else
    			ocParams[k] = v
    		end
    	end

    	luaoc.callStaticMethod("ShareSDKHelper", methodName, ocParams)
    else
        -- scheduler.performWithDelayGlobal(function()
        --     args[2]({success = true,msg = "分享成功"})
        -- end ,0.01)
    	--print(SDK_className,"模拟调用",methodName)
    end
end

return ShareSDKHelper