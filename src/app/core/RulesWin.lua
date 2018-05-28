--通用规则界面

local OpenFile = OpenFile
-- local ShieldLayer = OpenFile("ShieldLayer")
local TouchRegionLayer = OpenFile("TouchRegionLayer")
local UIImageBox = OpenFile("UIImageBox")

local WinBase = OpenFile("WinBase")
local RulesWin = class("RulesWin", WinBase)

local words = {
	--百家乐
	[RULES_TYPE.Baccarat] = {
		title = 200001,
		content = {
			{200002},
		}
	},
	--斗地主
	[RULES_TYPE.Doudizhu] = {
		title = 200003,
		content = {
			{200004},
		}
	},
	--中国象棋
	[RULES_TYPE.ChineseChess] = {
		title = 200005,
		content = {
			{200006},
		}
	},
	--五子棋
	[RULES_TYPE.Wzq] = {
		title = 200007,
		content = {
			{200008},
		}
	},
}

function RulesWin:ctor(params)
    RulesWin.super.ctor(self)
    self.data = words[params.tp or 0] or {}
end

function RulesWin:onWinEnter()
    self.layer = display.newLayer()

    self.backFrame = cc.CSLoader:createNode("layer/rules.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self.layer:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    -- self.shield = ShieldLayer.create(self.layer)
    -- self.shield:addChild(self.layer)
    local background = self.backFrame:getChildByName("background")
    self.shield = TouchRegionLayer.new(background,function()
    	CloseWin(self)
    end)
    self.shield:addChild(self.layer)

    self:addChild(self.shield)

    --关闭
    local backBut = UIImageBox.new(self.backFrame:getChildByName("backBut"),function()
    	CloseWin(self)
    end)

    self.backFrame:getChildByName("titleText"):setString(WordDictionary[self.data.title] or "")
    self.backFrame:getChildByName("titleText"):enableOutline(CoreColor.BLACK_191)

    local scrollView = self.backFrame:getChildByName("scrollView")
    scrollView:setScrollBarWidth(SCROLLBARWIDTH)
	scrollView:setScrollBarColor(cc.c3b(225,213,199))
	scrollView:setScrollBarPositionFromCornerForVertical(cc.p(20,20))
	local svSize = scrollView:getInnerContainerSize()

	local contentNode = scrollView:getChildByName("contentNode")
	contentNode:removeAllChildren()

	local curY = 0
	local content = self.data.content or {}
	for k,v in ipairs(content) do
		if v[1] then
	        local node = cc.CSLoader:createNode("layer/rulesContentNode.csb")
	        local contentText = node:getChildByName("contentText")
	        local titleText = node:getChildByName("titleText")
	        if v[2] then
	        	titleText:setString(WordDictionary[v[2]] or "")
	        else
	        	titleText:setVisible(false)
	        	contentText:setPositionY(titleText:getPositionY())
	        end
	        
	        contentText:setTextAreaSize(cc.size(410,0))
	        contentText:setString(WordDictionary[v[1]] or "")

	        local lineY = contentText:getPositionY() - contentText:getContentSize().height - 15
	        node:getChildByName("line"):setPositionY(lineY)
	        if k == #content then
	        	node:getChildByName("line"):setVisible(false)
	        end
	        
	        node:setPosition(0,curY)
	        contentNode:addChild(node)

	        curY = curY + lineY - 3
	    end
	end

	local scrollViewHeight = curY < 0 and -curY or curY
	if svSize.height < scrollViewHeight then
		scrollView:setInnerContainerSize(cc.size(svSize.width,scrollViewHeight))
	else
		scrollViewHeight = svSize.height
		scrollView:setInnerContainerSize(cc.size(svSize.width,scrollViewHeight))
	end

	contentNode:setPositionY(scrollViewHeight)

	scrollView:scrollToTop(0.2,true)
end

function RulesWin:onCleanup()

end

return RulesWin