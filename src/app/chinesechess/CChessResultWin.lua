
local WinBase = OpenFile("WinBase")

local CChessResultWin = class("CChessResultWin", WinBase)

function CChessResultWin:ctor(aiName, result, total)
    CChessResultWin.super.ctor(self)
    self.aiName = aiName or ""
    self.result = result or 1
    self.total = total or 0
end

function CChessResultWin:onWinEnter()
    self.backFrame = cc.CSLoader:createNode("chinesechess/result.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    self.backFrame:getChildByName("Panel_Touch"):onTouch(function (event)
    	if event.name == "ended" then
    		CloseWin(self)
    	end
    end)

    local bg = self.backFrame:getChildByName("Panel_Bg")
    bg:getChildByName("Text_1"):setString(WordDictionary[1202])
    bg:getChildByName("Text_2"):setString(self.aiName)

    local result1 = bg:getChildByName("Sprite_1")
    local result2 = bg:getChildByName("Sprite_2")
    if self.result == 1 then
        result1:setSpriteFrame("chinesechess/pic_zhengwu_sheng.png")
        result2:setSpriteFrame("chinesechess/pic_zhengwu_li.png")
    else
        result1:setSpriteFrame("chinesechess/pic_zhengwu_shi.png")
        result2:setSpriteFrame("chinesechess/pic_zhengwu_bai.png")
    end

    result1:setScale(5)
    result1:runAction(cc.ScaleTo:create(0.2, 1))
    result2:setScale(5)
    result2:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ScaleTo:create(0.2, 1)))

    bg:getChildByName("coin"):setString(self.total)

    if self.total > 0 then
        playEffectFunc("pwin_money.wav")
    elseif self.total < 0 then
        playEffectFunc("plose_money.wav")
    end
end

return CChessResultWin