--
local GameController = {}
GameController.SET_UP_FUNC = { --目前只会有音效可以设置
    Music = "1", --音乐开关 （第一个字符） --1为开启，0为关闭
    Sound = "1", --音效开关 （第二个字符） --1为开启，0为关闭
}

local self = GameController;

function GameController.changeSetUpFunc()
    for k,v in pairs(GameController.SET_UP_FUNC) do
        PlayerConfig:setSetting(k, v)
    end
end

function GameController.init()
    for k,v in pairs(GameController.SET_UP_FUNC) do
        local tp = PlayerConfig:getSetting(k)
        if tp then
            if tp == "1" then
                GameController.SET_UP_FUNC[k] = "1"
            else
                GameController.SET_UP_FUNC[k] = "0"
            end
        end
    end
end

--登出游戏
function GameController.logout()
    GameController.reEnterGame()
end

--重新进入游戏
function GameController.reEnterGame()
    GameController.reEnter = true
    -- SocketI = nil 复用一个
    pauseAllEffects()
    resumeAllEffects()
    stopBackMusic(true)
    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    GameController.enterGame()

    GameController.reEnter = false

end

--进入游戏
function GameController.enterGame()
	self.init()
    
    local LoginScene = require "app.Login.LoginScene"
	display.replaceScene(LoginScene.new())
end

return GameController