-- 热云游戏统计SDK
-- Author: mafei
-- Date: 2015-06-24 16:42:25
--


local luaj_error = {
    [-1]='不支持的参数类型或返回值类型',
    [-2]='无效的签名',
    [-3]='没有找到指定的方法',
    [-4]='Java 方法执行时抛出了异常',
    [-5]='Java 虚拟机出错',
    [-6]='Java 虚拟机出错',
}

local SDK_className = "org/cocos2dx/lua/GoogleAdMobSDK"
local GoogleAdMobSDK = class("GoogleAdMobSDK")

function GoogleAdMobSDK:_ab_showPage(callBack)

    --public static void onRegister(String userId)
    local temp = {
        function (_retDat)
            if type(_retDat) == 'string' then
                _retDat = loadstring("return ".._retDat)()
            end
            local ret = _retDat

            if callBack then
                callBack(ret)
            end
        end,
    }

    self:_ab_callStaticMethod("showPage",temp)
end

function GoogleAdMobSDK:_ab_showReward(callBack)

    --public static void onRegister(String userId)
    local temp = {
        function (_retDat)
            if type(_retDat) == 'string' then
                _retDat = loadstring("return ".._retDat)()
            end
            local ret = _retDat

            if callBack then
                callBack(ret)
            end
        end,
    }

    self:_ab_callStaticMethod("showReward",temp)
end


function GoogleAdMobSDK:_ab_callStaticMethod(methodName,args,sig)
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

    	luaoc.callStaticMethod("GoogleAdMobSDK", methodName, ocParams)
    else
    	--print(SDK_className,"模拟调用",methodName)
    end
end

return GoogleAdMobSDK