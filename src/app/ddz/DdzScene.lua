local UIImageBox = OpenFile("UIImageBox")
local DdzAI = OpenFile("DdzAI")
local DdzPlayer = OpenFile("DdzPlayer")
local DdzCard = OpenFile("DdzCard")
local SceneBase = OpenFile("SceneBase")

local aiConfig = OpenConfig("aiConfig")

local DdzScene = class("DdzScene", SceneBase)

local DdzStep = {
	None = 0,
	Deal = 1,			--发牌
	Vote = 2,			--抢地主
	Choose = 3,			--选地主
	Play = 4,			--打牌
	Finish = 5,			--结算
}

--模式：1普通，2一次发够17张，3不洗牌一次发够17张
function DdzScene:ctor(mode)
	DdzScene.super.ctor(self)
	self.mode = mode or 1
	self.lastPlayedCards = {}
	self.lastPlayedType = DDZDealType.None
	self.lastPlayedValue = 0
	self.lastPlayedPlayer = nil
	self.curIndex = 1
	self.dizhuVote = {}
	self.extraCards = {}
	self.multiple = 1
	self.step = DdzStep.None
	self.aiList = {}
    self.startPoint = nil
    self.playTimes = 0
	playBackMusicFunc("BG_" .. MyRandom:random(0, 3)  .. ".mp3")
end

function DdzScene:onEnter()
    self.backFrame = cc.CSLoader:createNode("ddz/ddz.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    self.bg = self.backFrame:getChildByName("Panel_Bg")
    --初始化按钮
    local backBut = UIImageBox.new(self.bg:getChildByName("btnClose"),function()
		OpenScene("LoginScene")
    end, {playEffect = "ui/close.mp3"})

    local descBtn = UIImageBox.new(self.bg:getChildByName("btnInfo"),function()
        OpenWin("RulesWin", {tp = RULES_TYPE.Doudizhu})
    end)

	self.add = UIImageBox.new(self.bg:getChildByName("add"), function (me)
		local playerInfo = GlobData:_ab_getPlayerInfo()
		if playerInfo.freeBuy > 0 then
			playerInfo:_ab_getGold(MyRandom:random(50, 100) * 100)
			playerInfo:_ab_useFreeBuy()
			GlobData:_ab_save()
			self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)
		else
			OpenWin("Notice", WordDictionary[1004], function (result)
				if result then
					pauseBackMusic()
					GoogleAdMobSDK:_ab_showReward(function (ret)
						if ret.code == 0 then
							GlobData:_ab_getGold(10000)
	    					GlobData:_ab_save()
							self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)
						else
							MoveLabel.create(WordDictionary[100003])
						end
						resumeBackMusic()
					end)
				end
			end)
		end
	end)

    self.extraPanel = self.bg:getChildByName("extra")

    --开始按钮
    self.start = UIImageBox.new(self.bg:getChildByName("btnStart"), function (me)
    	me:setVisible(false)
    	self:doStep(DdzStep.Deal)
    end, {textParams = {text = WordDictionary[1001], size = 22}})

    --抢地主
    self.choosePanel = self.bg:getChildByName("Panel_Choose")
    local giveup = UIImageBox.new(self.choosePanel:getChildByName("giveup"), function ()
    	self.dizhuVote[3] = 0
		self.choosePanel:setVisible(false)
		self.bg:getChildByName("vote3"):setVisible(true)
		self.bg:getChildByName("vote3"):setString(WordDictionary[1100])
    	self:doNext()
    end, {textParams = {text = WordDictionary[1100], size = 22}})

    for i = 1, 3 do
    	UIImageBox.new(self.choosePanel:getChildByName("btn" .. i), function ()
	    	self.dizhuVote[3] = i
			self.choosePanel:setVisible(false)
			self.bg:getChildByName("vote3"):setVisible(true)
			self.bg:getChildByName("vote3"):setString(i .. WordDictionary[1101])
    		self:doNext()
	    end, {textParams = {text = i .. WordDictionary[1101], size = 22}})
    end

    --打牌中
    self.buttonPanel = self.bg:getChildByName("Panel_Btn")
    self.play = UIImageBox.new(self.buttonPanel:getChildByName("btnPlay"), function ()
    	--出牌
    	local err = self.player:canPlay(self.lastPlayedCards, self.lastPlayedType, self.lastPlayedValue)
    	if err == 0 then
    		self.buttonPanel:setVisible(false)
			for i, v in ipairs(self.lastPlayedCards) do
				CardManager:dropCard(v:getName())
				v:removeFromParent()
			end

	    	self.lastPlayedCards, self.lastPlayedType, self.lastPlayedValue = self.player:playCards()
	    	self.lastPlayedPlayer = self.curIndex

	    	if self.lastPlayedType == DDZDealType.BOMB_CARD or self.lastPlayedType == DDZDealType.KING_BOMB then
	    		self.multiple = self.multiple * 2
			    self:freshChip()
	    	end

	    	self.out1:removeAllChildren()
	    	self.out2:removeAllChildren()
	    	self.out3:removeAllChildren()

	    	if self.player:isFinish() then
	    		self:doStep(DdzStep.Finish)
	    	else
	    		self:doNext()
	    	end
	    elseif err == 1 then
			MoveLabel.create(WordDictionary[100101])
	    elseif err == 2 then
			MoveLabel.create(WordDictionary[100102])
	    end
    end, {textParams = {text = WordDictionary[1102], size = 22}})

    self.recommend = UIImageBox.new(self.buttonPanel:getChildByName("btnRecommend"), function ()
    	self.player:recommend(self.lastPlayedCards, self.lastPlayedType, self.lastPlayedValue)
    end, {textParams = {text = WordDictionary[1103], size = 22}})

    self.reselect = UIImageBox.new(self.buttonPanel:getChildByName("btnReselect"), function ()
    	self.player:reselect()
    end, {textParams = {text = WordDictionary[1104], size = 22}})

    self.pass = UIImageBox.new(self.buttonPanel:getChildByName("btnPass"), function ()
    	self:doNext()
    end, {textParams = {text = WordDictionary[1105], size = 22}})

	self.coinLabel = self.bg:getChildByName("coin")
	self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)

	self.out1 = self.bg:getChildByName("out1")
	self.out2 = self.bg:getChildByName("out2")
	self.out3 = self.bg:getChildByName("out3")

	self.start:setVisible(true)
	self.choosePanel:setVisible(false)
	self.buttonPanel:setVisible(false)


	self.player = DdzPlayer.new(1, 3)
	self.player:retain()

	--庄家模式使用3个AI，闲家模式使用2个AI，AI随机选择
	local selectedAI = {}
	local selectCount = 2
	while selectCount > 0 do
		local selected = false
		local index = MyRandom:random(1, #aiConfig)
		for i,v in ipairs(selectedAI) do
			if v == index then
				selected = true
				break
			end
		end

		if not selected then
			table.insert(selectedAI, index)
			selectCount = selectCount - 1
		end
	end

	for i,v in ipairs(selectedAI) do
		local ai = DdzAI.new(v, i)
		ai:setPosition(self.bg:getChildByName("player" .. i):getPosition())
		self.bg:addChild(ai)
		table.insert(self.aiList, ai)
	end

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchesBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchesMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchesEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchesCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function DdzScene:onTouchesBegan(touch, event)
	if self.step == DdzStep.Play then
		print("onTouchesBegan")
		self.startPoint = touch:getLocation()
		self.player:selectCard(self.startPoint)
		return true
	end
end

function DdzScene:onTouchesMoved(touch, event)
	if self.startPoint then
		print("onTouchesMoved")
		local pos = touch:getLocation()
		self.player:selectCard(pos)
	end
end

function DdzScene:onTouchesEnded(touch, event)
	if self.player:canPlay(self.lastPlayedCards, self.lastPlayedType, self.lastPlayedValue) == 0 then
		self.play:setEnabled(true)
	else
		self.play:setEnabled(false)
	end

	self.startPoint = nil
end

function DdzScene:onTouchesCancelled(touch, event)
	self.startPoint = nil
end

function DdzScene:doStep(step)
	if self.step == step then
		return
	end

	self.bg:stopAllActions()
	self.bg:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
		if step == DdzStep.Deal then
			self:doDeal()
		elseif step == DdzStep.Vote then
			self:doVote()
		elseif step == DdzStep.Choose then
			self:doChoose()
		elseif step == DdzStep.Play then
			self:doPlay()
		elseif step == DdzStep.Finish then
			self:doFinish()
		end

		self.step = step
	end)))
end

function DdzScene:doNext()
	self.bg:stopAllActions()
	self.bg:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
		if self.step == DdzStep.Vote then
			if self.curIndex == 1 then
				self.dizhuVote[1] = self.aiList[1]:vote()
				self.curIndex = 2
				self.bg:getChildByName("vote1"):setVisible(true)
				if self.dizhuVote[1] == 0 then
					self.bg:getChildByName("vote1"):setString(WordDictionary[1100])
				else
					self.bg:getChildByName("vote1"):setString(self.dizhuVote[1] .. WordDictionary[1101])
				end
			elseif self.curIndex == 2 then
				self.dizhuVote[2] = self.aiList[2]:vote()
				self.curIndex = 3
				self.bg:getChildByName("vote2"):setVisible(true)
				if self.dizhuVote[2] == 0 then
					self.bg:getChildByName("vote1"):setString(WordDictionary[1100])
				else
					self.bg:getChildByName("vote1"):setString(self.dizhuVote[2] .. WordDictionary[1101])
				end
				self.choosePanel:setVisible(true)
			elseif self.curIndex == 3 then
				self.curIndex = 1
			end

			if table.nums(self.dizhuVote) >= 3 then
				self:doStep(DdzStep.Choose)
			else
				self:doNext()
			end
		elseif self.step == DdzStep.Play then
			if self.curIndex == 1 then
				self.curIndex = 2
				self:doNext()
			elseif self.curIndex == 2 then
				self.curIndex = 3
				self:doNext()
				self.buttonPanel:setVisible(true)
				if self.lastPlayedPlayer == 0 or self.lastPlayedPlayer == 3 then
					self.pass:setEnabled(false)
				else
					self.pass:setEnabled(true)
				end
			elseif self.curIndex == 3 then
				self.curIndex = 1
				self:doNext()
			end

			local ai = self.aiList[self.curIndex]
			if ai then
				local idDizhu = false
				if self.lastPlayedPlayer == 3 then
					idDizhu = self.player.isDizhu
				else
					idDizhu = self.aiList[self.lastPlayedPlayer].isDizhu
				end

				local cards, eType, Value = ai:deal(self.lastPlayedCards, self.lastPlayedType, self.lastPlayedValue, idDizhu)
				if #cards > 0 then
					for i, v in ipairs(self.lastPlayedCards) do
						CardManager:dropCard(v:getName())
						v:removeFromParent()
					end

			    	self.lastPlayedCards = cards
			    	self.lastPlayedType = eType
			    	self.lastPlayedValue = Value
			    	self.lastPlayedPlayer = self.curIndex

			    	if eType == DDZDealType.BOMB_CARD or eType == DDZDealType.KING_BOMB then
			    		self.multiple = self.multiple * 2
			    		self:freshChip()
			    	end

			    	if ai:isFinish() then
			    		self:doStep(DdzStep.Finish)
			    	else
			    		self:doNext()
			    	end
				end
			end
		end
	end)))
end

function DdzScene:doDeal()
	local cardMap = {{}, {}, {}}
	
	--模式：1普通，2一次发够17张，3不洗牌一次发够17张
	if self.mode == 1 then
		CardManager:init(1)
		local index = 1
		while CardManager:getLastNum() > 3 do
			local card = CardManager:popDdzCard()
			table.insert(cardMap[index], card)
			index = index + 1
			if index > 3 then
				index = 1
			end
		end
	elseif self.mode == 2 then
		CardManager:init(1)
		for i = 1, 3 do
			for j = 1, 17 do
				local card = CardManager:popDdzCard()
				table.insert(cardMap[i], card)
			end
		end
	elseif self.mode == 3 then
		CardManager:restore()
		for i = 1, 3 do
			for j = 1, 17 do
				local card = CardManager:popDdzCard()
				table.insert(cardMap[i], card)
			end
		end
	end

	for i = 1, 3 do
		table.insert(self.extraCards, CardManager:popDdzCard())
	end

	self.extraPanel:removeAllChildren()
	for i,card in ipairs(self.extraCards) do
		card:setPositionX(75 * (i - 2))
		self.extraPanel:addChild(card)
	end

	for i = 1, 3 do
		for j, card in ipairs(cardMap[i]) do
			self.bg:getChildByName("card" .. i):addChild(card)
		end
	end

	self.aiList[1]:initCards(cardMap[1])
	self.aiList[2]:initCards(cardMap[2])
	self.player:initCards(cardMap[3])
	self.bg:getChildByName("dizhu"):setVisible(false)

	self:doStep(DdzStep.Vote)
end

function DdzScene:doVote()
	if self.curIndex == 3 then
		self.choosePanel:setVisible(true)
	else
		self:doNext()
	end
end

function DdzScene:doChoose()
	for i = 1, 3 do
		self.bg:getChildByName("vote" .. i):setVisible(false)
	end
	
	local max = 0
	local selected = 0
	for k,v in pairs(self.dizhuVote) do
		if v >= max then
			max = v
			selected = k
		end
	end

	if max == 0 then
		self:doStep(DdzStep.Deal)
	else
		if max == 1 then
			self.multiple = 1
		elseif max == 2 then
			self.multiple = 2
		elseif max == 3 then
			self.multiple = 3
		end
		self:freshChip()

		local extra = {}
		for i,v in ipairs(self.extraCards) do
			table.insert(extra, DdzCard.new(v:getName()))
		end

		self.curIndex = selected
		local dizhuIcon = self.bg:getChildByName("dizhu")
		dizhuIcon:setVisible(true)
		if selected == 3 then
			self.player:addCards(extra)
			dizhuIcon:loadTexture("ddz/lord_1.png", UI_TEX_TYPE_LOCAL)
			dizhuIcon:setPosition(1010, 100)
		else
			self.aiList[selected]:addCards(extra)
			if self.aiList[selected]:isMale() then
				dizhuIcon:loadTexture("ddz/lord_1.png", UI_TEX_TYPE_LOCAL)
			else
				dizhuIcon:loadTexture("ddz/lord_0.png", UI_TEX_TYPE_LOCAL)
			end

			dizhuIcon:setPosition(self.aiList[selected]:getPositionX(), 340)
		end
		self.extraCards = {}

		for i, v in ipairs(self.extraPanel:getChildren()) do
			v:show()
			self.bg:getChildByName("card" .. selected):addChild(extra[i])
		end

		self:doStep(DdzStep.Play)
	end
end

function DdzScene:doPlay()
	if self.curIndex == 3 then
		self.buttonPanel:setVisible(true)
		self.pass:setEnabled(false)
	else
		self:doNext()
	end
end

function DdzScene:doFinish()
	self.start:setVisible(true)
	self.choosePanel:setVisible(false)
	self.buttonPanel:setVisible(false)

	local result = 1000 * self.multiple
	local finishIndex = 0
	if self.aiList[1]:isFinish() then
		if self.aiList[1].isDizhu then
			self.aiList[1]:getGold(result)
			self.aiList[2]:getGold(result / -2)
			self.player:getGold(result / -2)
		elseif self.aiList[2].isDizhu then
			self.aiList[1]:getGold(result / 2)
			self.aiList[2]:getGold(result * -1)
			self.player:getGold(result / 2)
		else
			self.aiList[1]:getGold(result / 2)
			self.aiList[2]:getGold(result / 2)
			self.player:getGold(result * -1)
		end
	elseif self.aiList[2]:isFinish() then
		if self.aiList[1].isDizhu then
			self.aiList[1]:getGold(result * -1)
			self.aiList[2]:getGold(result / 2)
			self.player:getGold(result / 2)
		elseif self.aiList[2].isDizhu then
			self.aiList[1]:getGold(result / -2)
			self.aiList[2]:getGold(result)
			self.player:getGold(result / -2)
		else
			self.aiList[1]:getGold(result / 2)
			self.aiList[2]:getGold(result / 2)
			self.player:getGold(result * -1)
		end
	elseif self.player:isFinish() then
		if self.aiList[1].isDizhu then
			self.aiList[1]:getGold(result * -1)
			self.aiList[2]:getGold(result / 2)
			self.player:getGold(result / 2)
		elseif self.aiList[2].isDizhu then
			self.aiList[1]:getGold(result / 2)
			self.aiList[2]:getGold(result * -1)
			self.player:getGold(result / 2)
		else
			self.aiList[1]:getGold(result / -2)
			self.aiList[2]:getGold(result / -2)
			self.player:getGold(result)
		end
	end

	self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)

	self.playTimes = self.playTimes + 1
	if self.playTimes >= 3 then
		self.playTimes = 0
		pauseBackMusic()
		GoogleAdMobSDK:_ab_showPage(function (ret)
			resumeBackMusic()
		end)
	end

	-- OpenWin("DdzResultWin", result, self.aiList[1], self.aiList[2], self.player)
end

function DdzScene:freshChip()
	self.bg:getChildByName("score"):setString(1000 * self.multiple)
end

function DdzScene:onExit()
	self.player:release()
	stopBackMusic()
end

return DdzScene