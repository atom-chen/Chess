
local WinBase = OpenFile("WinBase")
local TouchRegionLayer = OpenFile("TouchRegionLayer")
local UIImageBox = OpenFile("UIImageBox")

local Notice = class("Notice", WinBase)

function Notice:ctor(word, callback)
    Notice.super.ctor(self)
	self.word = word
	self.callback = callback
end

function Notice:onWinEnter()
    self.layer = display.newLayer()

    self.backFrame = cc.CSLoader:createNode("Baccarat/notice.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self.layer:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    local background = self.backFrame:getChildByName("bg")
    self.shield = TouchRegionLayer.new(background,function()
    	CloseWin(self)
    end,cc.c4b(10,10,10,220))
    self.shield:addChild(self.layer)

    self:addChild(self.shield)

    self.backFrame:getChildByName("Text_1"):setString(self.word or "")

	local ok = UIImageBox.new(self.backFrame:getChildByName("ok"), function (me)
		if self.callback then
			self.callback(true)
		end
		CloseWin(self)
	end, {textParams = {text = WordDictionary[1002], size = 24}})

	local cancel = UIImageBox.new(self.backFrame:getChildByName("cancel"), function (me)
		if self.callback then
			self.callback(false)
		end
		CloseWin(self)
	end, {textParams = {text = WordDictionary[1003], size = 24}})
end

return Notice