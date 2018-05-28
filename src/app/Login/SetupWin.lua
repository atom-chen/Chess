
local WinBase = OpenFile("WinBase")
local TouchRegionLayer = OpenFile("TouchRegionLayer")
local UIImageBox = OpenFile("UIImageBox")

local SetupWin = class("SetupWin", WinBase)

function SetupWin:ctor()
    SetupWin.super.ctor(self)
    GameController.SET_UP_FUNC = clone(GameController.SET_UP_FUNC)
end

function SetupWin:onWinEnter()
    self.layer = display.newLayer()

    self.backFrame = cc.CSLoader:createNode("layer/setup.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self.layer:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    local background = self.backFrame:getChildByName("bg")
    self.shield = TouchRegionLayer.new(background,function()
        CloseWin(self)
    end,cc.c4b(10,10,10,220))
    self.shield:addChild(self.layer)

    self:addChild(self.shield)

    local close = UIImageBox.new(self.backFrame:getChildByName("close"), function (me)
        GameController.init()
        CloseWin(self)
    end, {playEffect = "ui/close.mp3"})

    self.sound = UIImageBox.new(self.backFrame:getChildByName("sound"),function(me)
        if GameController.SET_UP_FUNC.Sound == "1" then
            GameController.SET_UP_FUNC.Sound = "0"
            me:setImage("setup/set_sliper_close.png")
        else
            GameController.SET_UP_FUNC.Sound = "1"
            me:setImage("setup/set_sliper_open.png")
        end
    end)
    if GameController.SET_UP_FUNC.Sound == "1" then
        self.sound:setImage("setup/set_sliper_open.png")
    else
        self.sound:setImage("setup/set_sliper_close.png")
    end

    self.music = UIImageBox.new(self.backFrame:getChildByName("music"),function(me)
        if GameController.SET_UP_FUNC.Music == "1" then
            GameController.SET_UP_FUNC.Music = "0"
            me:setImage("setup/set_sliper_close.png")
        else
            GameController.SET_UP_FUNC.Music = "1"
            me:setImage("setup/set_sliper_open.png")
        end
    end)
    if GameController.SET_UP_FUNC.Music == "1" then
        self.music:setImage("setup/set_sliper_open.png")
    else
        self.music:setImage("setup/set_sliper_close.png")
    end


    local ok = UIImageBox.new(self.backFrame:getChildByName("ok"), function (me)
        GameController.changeSetUpFunc()
        CloseWin(self)
    end, {textParams = {text = WordDictionary[1002], size = 24}})

    local cancel = UIImageBox.new(self.backFrame:getChildByName("cancel"), function (me)
        GameController.init()
        CloseWin(self)
    end, {textParams = {text = WordDictionary[1003], size = 24}})
end


return SetupWin