
local WinBase = OpenFile("WinBase")

local DdzResultWin = class("DdzResultWin", WinBase)

function DdzResultWin:ctor(playerPoint, bankerPoint, total)
    DdzResultWin.super.ctor(self)
    self.playerPoint = playerPoint or 0
    self.bankerPoint = bankerPoint or 0
    self.total = total or 0
end

function DdzResultWin:onWinEnter()
    self.backFrame = cc.CSLoader:createNode("Baccarat/result.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    self.backFrame:getChildByName("Panel_Touch"):onTouch(function (event)
    	if event.name == "ended" then
    		CloseWin(self)
    	end
    end)

    local bg = self.backFrame:getChildByName("Panel_Bg")
    bg:getChildByName("Image_1"):loadTexture("Baccarat/clearing_" .. self.playerPoint .. ".png", UI_TEX_TYPE_PLIST)
    bg:getChildByName("Image_2"):loadTexture("Baccarat/clearing_" .. self.bankerPoint .. ".png", UI_TEX_TYPE_PLIST)

    local result = bg:getChildByName("result")
    if self.playerPoint > self.bankerPoint then
    	result:loadTexture("Baccarat/game_xian_win.png", UI_TEX_TYPE_PLIST)
    elseif self.bankerPoint > self.playerPoint then
    	result:loadTexture("Baccarat/game_zhuang_win.png", UI_TEX_TYPE_PLIST)
    end
    result:setVisible(true)
    result:setScale(5)
    result:runAction(cc.ScaleTo:create(0.2, 2))

    bg:getChildByName("coin"):setString(self.total)

    if self.total > 0 then
        playEffectFunc("pwin_money.wav")
    elseif self.total < 0 then
        playEffectFunc("plose_money.wav")
    end
end


return DdzResultWin