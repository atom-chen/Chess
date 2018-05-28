
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("res/Baccarat/")
cc.FileUtils:getInstance():addSearchPath("res/Majon/")

--字体
NORMALFONT = "fnt/heijian.ttf" --默认字体
SPECIALFONT = "fnt/SimHei.ttf" --描述字体
NUMBERFONT = "fnt/BRLNSDB.ttf" --数字特殊字体

require "config"
require "cocos.init"
require "app.core.Utils"
require "app.core.GameEntry"

luaj = nil
luaoc = nil

local function main()
	local PLATFORM_OS_WINDOWS = 0
	local PLATFORM_OS_LINUX   = 1
	local PLATFORM_OS_MAC     = 2
	local PLATFORM_OS_ANDROID = 3
	local PLATFORM_OS_IPHONE  = 4
	local PLATFORM_OS_IPAD    = 5
	local PLATFORM_OS_BLACKBERRY = 6
	local PLATFORM_OS_NACL    = 7
	local PLATFORM_OS_EMSCRIPTEN = 8
	local PLATFORM_OS_TIZEN   = 9
	local PLATFORM_OS_WINRT   = 10
	local PLATFORM_OS_WP8     = 11

	local platform = cc.Application:getInstance():getTargetPlatform()
	local director = cc.Director:getInstance()
	if platform == PLATFORM_OS_ANDROID then
	    luaj = require "cocos.cocos2d.luaj"
	elseif platform == PLATFORM_OS_IPHONE or platform == PLATFORM_OS_IPAD then
	    luaoc = require "cocos.cocos2d.luaoc"
	end

    math.randomseed(os.time())

    PlayerConfig = require "app.core.PlayerConfig"
    ResolutionManager = require "app.core.ResolutionManager"
    GameController = require "app.core.GameController"
    WinManager = require "app.core.WinManager"

    PlayerConfig = PlayerConfig.new()
    ResolutionManager = ResolutionManager.new()

    OverallScale = 1 / ResolutionManager:getMinScale()

    gameEntry()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    release_print(msg)
end
