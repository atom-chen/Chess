--    __G__TRACKBACK__TEXT = nil;
--if DEBUG >= 1 then
--    function __G__TRACKBACK__(errorMessage)
--        print("----------------------------------------");
--        print("LUA ERROR: "..tostring(errorMessage).."\n");
--        print(debug.traceback("", 2));
--        print("----------------------------------------");
--        __G__TRACKBACK__TEXT = "LUA ERROR: "..tostring(errorMessage).."\n" .. debug.traceback("", 2);
--    end
--end

local fileList = {
--core
["CoreColor"] = "app.core.CoreColor",
["GameController"] = "app.core.GameController",
["GameEntry"] = "app.core.GameEntry",
["MusicDenshion"] = "app.core.MusicDenshion",
["SgAudioEngine"] = "app.core.SgAudioEngine",
["PathFinder"] = "app.core.PathFinder",
["ResolutionManager"] = "app.core.ResolutionManager",
["ResourceManager"] = "app.core.ResourceManager",
["SceneBase"] = "app.core.SceneBase",
["scheduler"] = "app.core.scheduler",
["ScroPath"] = "app.core.ScroPath",
["ShaderManager"] = "app.core.ShaderManager",
["NotificationManager"] = "app.core.NotificationManager",
-- ["Strings"] = "app.core.Strings",
["WinBase"] = "app.core.WinBase",
["WinManager"] = "app.core.WinManager",
["MyRandom"] = "app.core.MyRandom",
["RulesWin"] = "app.core.RulesWin",
["Helper"] = "app.core.Helper",

--config
["WordDictionary"] = "app.config.WordDictionary",
["constant"] = "app.config.constant",
["gameConfig"] = "app.config.gameConfig",
["aiConfig"] = "app.config.aiConfig",
["chinesechessConf"] = "app.config.chinesechessConf",

--data
["BaseInfoManager"] = "app.data.BaseInfoManager",
["DataManager"] = "app.data.DataManager",
["MessageHelper"] = "app.data.MessageHelper",
["PlayerInfo"] = "app.data.player.PlayerInfo",
["PlayerInfoManager"] = "app.data.player.PlayerInfoManager",
["AIInfo"] = "app.data.ai.AIInfo",
["AIInfoManager"] = "app.data.ai.AIInfoManager",
["DBManager"] = "app.data.DBManager",

["Shader"] = "app.shader.Shader",
["MoveLabel"] = "app.ui.MoveLabel",
["PageScrollView"] = "app.ui.PageScrollView",
["ShieldLayer"] = "app.ui.ShieldLayer",
["TouchRegionLayer"] = "app.ui.TouchRegionLayer",
["ui"] = "app.ui.ui",
["UIAniButton"] = "app.ui.UIAniButton",
["UIAnimation"] = "app.ui.UIAnimation",
["UIButton"] = "app.ui.UIButton",
["UIImage"] = "app.ui.UIImage",
["UIImageBox"] = "app.ui.UIImageBox",
["UILabel"] = "app.ui.UILabel",
["UIScale9Sprite"] = "app.ui.UIScale9Sprite",
["UIScrollView"] = "app.ui.UIScrollView",
["MultiScrollView"] = "app.ui.MultiScrollView",
["UISprite"] = "app.ui.UISprite",
["UIRichLabel"] = "app.ui.RichLabel",

--login
["LoginScene"] = "app.Login.LoginScene",
["SetupWin"] = "app.Login.SetupWin",

--card
["CardManager"] = "app.card.CardManager",
["Card"] = "app.card.Card",
["DdzCard"] = "app.card.DdzCard",

--baccarat
["BaccaratAI"] = "app.baccarat.BaccaratAI",
["BaccaratScene"] = "app.baccarat.BaccaratScene",
["BaccaratScene2"] = "app.baccarat.BaccaratScene2",
["BaccaratResultWin"] = "app.baccarat.BaccaratResultWin",
["Notice"] = "app.baccarat.Notice",

--斗地主
["DdzAI"] = "app.ddz.DdzAI",
["DdzPlayer"] = "app.ddz.DdzPlayer",
["DdzResultWin"] = "app.ddz.DdzResultWin",
["DdzScene"] = "app.ddz.DdzScene",

--中国象棋
["CChessAI"] = "app.chinesechess.CChessAI",
["CChess"] = "app.chinesechess.CChess",
["CChessResultWin"] = "app.chinesechess.CChessResultWin",
["CChessScene"] = "app.chinesechess.CChessScene",

--五子棋
["WzqAI"] = "app.wzq.WzqAI",
["WzqChess"] = "app.wzq.WzqChess",
["WzqResultWin"] = "app.wzq.WzqResultWin",
["WzqScene"] = "app.wzq.WzqScene",

--sdk
["GoogleAdMobSDK"] = "app.sdk.GoogleAdMobSDK",

}

function OpenConfig(filename)
    local config = require (fileList[filename])
    return config
end

function OpenFile(filename)
    local file = require (fileList[filename])
    return file
end

function OpenWin(winname, ...)
    print("==== ==",winname)
    local scene = display:getRunningScene()
    if not scene.winManager then
        logd('[ERROR] this is not our scene ' .. (scene.__cname or "unknow"))
        return
    end

    local win = require (fileList[winname])
    -- if scene.winManager:isOpening(win.__cname) then
    --     return nil
    -- end
    local newWin = win.new(...)
    newWin:onWinEnter()

    scene.winManager:addWin(newWin, AddWinType.normal,win,newWin.__cname,...)

    newWin:_onEnterTransitionFinish()

    if scene.onWinOpened ~= nil then
        scene:onWinOpened(newWin)
    end
    if bit.band(newWin.showType, WinShowType.hiddenBack) <= 0 and 
     bit.band(newWin.showType, WinShowType.canNotClose) <= 0 and
     bit.band(newWin.showType, WinShowType.hasAction) <= 0 and
     newWin.layer then --只要不是全屏的
     	local px,py = newWin.layer:getPosition()
    	local offset = 100
	    newWin.layer:setPositionY(py + offset)
	    newWin.layer:setCascadeOpacityEnabled(true)
	    newWin.layer:setOpacity(0)
	    newWin.layer:runAction(
	        cc.Sequence:create(
	            cc.Spawn:create(
	                cc.EaseSineIn:create(cc.MoveBy:create(0.1, cc.p(0, -offset))),
	                cc.FadeIn:create(0.1)
	            ),
	            cc.JumpTo:create(0.2, cc.p(px, py), 5, 1)
	        )
	    )
    end

--    print("**********窗口[" .. newWin.class.__cname .. "]已打开**********")
    return newWin
end

function OpenTopWin(winname, topZOder, ...)
    print("==== ==",winname)
    local scene = display:getRunningScene()
    if not scene.winManager then
        logd('[ERROR] this is not our scene ' .. (scene.__cname or "unknow"))
        return
    end

    local win = require (fileList[winname])
    -- if scene.winManager:isOpening(win.__cname) then
    --     return nil
    -- end
    local newWin = win.new(...)
    newWin:onWinEnter()

    scene:addChild(newWin, topZOder)

    newWin:_onEnterTransitionFinish()

    return newWin
end

function CloseWin(win)
    local scene = display:getRunningScene()
    scene.winManager:removeWin(win)
end

SceneOpenType = {
    raplace = 1,
    stack = 2,
}

function OpenScene(scenename, openType, ...)
    -- print("**********场景[" .. scenename .. "]正在打开**********")
    local scene = require (fileList[scenename])
    local openType = openType or 1
    local curScene = display.getRunningScene();
    if curScene and curScene.class.__cname == scene.__cname then
        return
    end

    local newScene = scene.new(...)

    if openType == SceneOpenType.raplace then
        display.replaceScene(newScene)
    elseif openType == SceneOpenType.stack then

    end

    --print("**********场景[" .. newScene.class.__cname .. "]已打开**********")
    --    return newScene
end

function gameEntry()

    WordDictionary = OpenConfig("WordDictionary")

    print(">?????????????????????????????????????????????????????? ")
    OpenFile("SgAudioEngine")
    OpenFile("CoreColor")
    OpenFile("constant")
    OpenFile("Helper")
    OpenFile("MusicDenshion")

    --初始化所有资源
    ResourceManager = OpenFile("ResourceManager")
    scheduler = OpenFile("scheduler")
    ShaderManager = OpenFile("ShaderManager")
    GlobData = OpenFile("DataManager")
    CardManager = OpenFile("CardManager").new()
    ui = OpenFile("ui")
    MyRandom = OpenFile("MyRandom").new()
    MyRandom:newrandomseed()

    ResourceManager = ResourceManager.new()
    ShaderManager = ShaderManager.new()
    ShaderManager:load()
    -- GlobData = GlobData.new()

    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeAllTextures()
    GlobData:_ab_login()
    --进入游戏
    GameController.enterGame();

    cc.FileUtils:getInstance():purgeCachedEntries()
    -- myuse.FightServer:getInstance():initFightServer()
    --release_print("gameEntry --")
end

function startAllGame()
    ResourceManager.removeAll()

    OpenScene("CastleScene")
end
