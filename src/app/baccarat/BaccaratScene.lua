
local BaccaratAI = OpenFile("BaccaratAI")
local UISprite = OpenFile("UISprite")
local UIImageBox = OpenFile("UIImageBox")
local MoveLabel = OpenFile("MoveLabel")
local SceneBase = OpenFile("SceneBase")
local GoogleAdMobSDK = OpenFile("GoogleAdMobSDK")
local aiConfig = OpenConfig("aiConfig")

local btnNameList = {
    "btnXian",
    "btnPing",
    "btnZhuang",
    "btnXiantianwang",
    "btnZhuangtianwang",
    "btnPingtongdian",
    "btnXianduizi",
    "btnZhuangduizi",
}


local BaccaratScene = class("BaccaratScene", SceneBase)

function BaccaratScene:ctor(mode)
	BaccaratScene.super.ctor(self)
	self.mode = mode or 1 -- 1是闲家模式，2是庄家模式
	self.chipList = {}
	self.playerBet = {}
	self.betList = {}
	self.aiList = {}
	self.playTimes = 0
	self.choosedChip = 1
	self.playerCards = {}
	self.bankerCards = {}
	self.actionList = {}
	playBackMusicFunc("ingameBGMMono.mp3")
end

function BaccaratScene:onEnter()
    self.backFrame = cc.CSLoader:createNode("Baccarat/baccarat.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    self.bg = self.backFrame:getChildByName("Panel_Bg")
    --初始化按钮
    local backBut = UIImageBox.new(self.bg:getChildByName("btnClose"),function()
		OpenScene("LoginScene")
    end, {playEffect = "ui/close.mp3"})

    local descBtn = UIImageBox.new(self.bg:getChildByName("btnInfo"),function()
        OpenWin("RulesWin", {tp = RULES_TYPE.Baccarat})
    end)

	self.coinLabel = self.bg:getChildByName("coin")
	self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)

	self.btnList = {}
	for i,v in ipairs(btnNameList) do
		self.btnList[v] = UIImageBox.new(self.bg:getChildByName(v),function(me)
			if self.mode == 2 then
				MoveLabel.create(WordDictionary[100005])
				return
			end

			local cost = 0
			if self.choosedChip == 1 then
				cost = 100
			elseif self.choosedChip == 2 then
				cost = 200
			elseif self.choosedChip == 3 then
				cost = 500
			elseif self.choosedChip == 4 then
				cost = 1000
			end
			if cost <= 0 then
				return
			end

			local playerInfo = GlobData:_ab_getPlayerInfo()
			local total = 0
			for i,v in pairs(self.playerBet) do
				total = total + v
			end
			local last = playerInfo.gold - total
			if last < cost then
				MoveLabel.create(WordDictionary[100001])
				return
			end

			local size = me:getContentSize()
			local x,y = me:getPosition()
			local pos = cc.p(x - size.width / 2 + MyRandom:random(20, size.width - 50), y - size.height / 2 + MyRandom:random(10, size.height - 30))

			self.playerBet[i] = (self.playerBet[i] or 0) + cost

			--计算下注后的钱
			local total = 0
			for i,v in pairs(self.playerBet) do
				total = total + v
			end
			self.coinLabel:setString(last - cost)

			--显示下注的筹码
			local chipPath = "public/" .. cost .. ".png"
			local chip = UISprite.new(chipPath)
			chip:setScaleY(0.8)
			chip:setPosition(self.bg:getChildByName("btnCoin" .. self.choosedChip):getPosition())
			chip:runAction(cc.MoveTo:create(0.5, pos))
			self.bg:addChild(chip)
			table.insert(self.chipList, chip)
	    end, {playEffect = "ui/Bet.WAV"})
	end

	self.selected = self.bg:getChildByName("select")
	self.chipBtnList = {}
	for i = 1, 4 do
		self.chipBtnList[i] = UIImageBox.new(self.bg:getChildByName("btnCoin" .. i), function (me)
			self.chipBtnList[self.choosedChip]:resetShader()
			self.choosedChip = i
			self.selected:setPosition(me:getPosition())
		end)
	end
	self.chipBtnList[1]:setOtherEnable(3)

	self.startBtn = UIImageBox.new(self.bg:getChildByName("btnStart"), function (me)
		if #self.chipList <= 0 then
			MoveLabel.create(WordDictionary[100002])
			return
		end

		if table.nums(self.actionList) > 0 then
			MoveLabel.create(WordDictionary[100004])
			return
		end
		self:startDeal()
	end, {textParams = {text = WordDictionary[1001], size = 24}})

	self.resetBtn = UIImageBox.new(self.bg:getChildByName("btnReset"), function (me)
		if table.nums(self.actionList) > 0 then
			MoveLabel.create(WordDictionary[100004])
			return
		end
		
		self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)
		for i,v in ipairs(self.chipList) do
			v:removeFromParent()
		end
		self.chipList = {}
		self.playerBet = {}
		self.betList = {}

		self:doAIBet()
	end, {textParams = {text = WordDictionary[1005], size = 24}})

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

	self.startPoint = self.bg:getChildByName("startPoint")
	self.playerPoint = self.bg:getChildByName("xianPoint")
	self.bankerPoint = self.bg:getChildByName("zhuangPoint")

	--庄家模式使用3个AI，闲家模式使用2个AI，AI随机选择
	local selectedAI = {}
	local selectCount = 2
	if self.mode == 2 then
		selectCount = 3
		for i,v in ipairs(self.chipBtnList) do
			v:setVisible(false)
		end
		self.selected:setVisible(false)
	end

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
		local ai = BaccaratAI.new(v, i)
		ai:setPosition(self.bg:getChildByName("player" .. i):getPosition())
		self.bg:addChild(ai)
		table.insert(self.aiList, ai)
	end

	self:doAIBet()
end

function BaccaratScene:doAIBet()
	local delay = cc.DelayTime:create(2)
	local call = cc.CallFunc:create(function ()
		print("doAIBet : ", table.nums(self.aiList))
		for k,ai in pairs(self.aiList) do
			self.actionList[k] = ai:getBetList()
		end

		local randomWait = MyRandom:random(1, 3)
		local waited = 0
		self.bg:actionScheduleInterval(function ()
			waited = waited + 1
			if waited > randomWait then
				randomWait = MyRandom:random(1, 3)
				waited = 0
				for k, betActionList in pairs(self.actionList) do
					if #betActionList > 0 then
						local bet = betActionList[1]
						table.remove(betActionList, 1)

						local cost = 0
						if bet.chip == 1 then
							cost = 100
						elseif bet.chip == 2 then
							cost = 200
						elseif bet.chip == 3 then
							cost = 500
						elseif bet.chip == 4 then
							cost = 1000
						end
						if cost <= 0 then
							return
						end

						local betBtn = self.bg:getChildByName(btnNameList[bet.index])
						local size = betBtn:getContentSize()
						local x,y = betBtn:getPosition()
						local pos = cc.p(x - size.width / 2 + MyRandom:random(20, size.width - 50), y - size.height / 2 + MyRandom:random(10, size.height - 30))

						if not self.betList[k] then
							self.betList[k] = {}
						end

						if not self.betList[k][bet.index] then
							self.betList[k][bet.index] = 0
						end
						self.betList[k][bet.index] = self.betList[k][bet.index] + cost

						--显示下注的筹码
						local chipPath = "public/" .. cost .. ".png"
						local chip = UISprite.new(chipPath)
						chip:setScaleY(0.8)
						chip:setPosition(self.aiList[k]:getPosition())
						chip:runAction(cc.MoveTo:create(0.5, pos))
						self.bg:addChild(chip)
						table.insert(self.chipList, chip)
					else
						self.actionList[k] = nil
					end
				end

				if table.nums(self.actionList) <= 0 then
					self.bg:stopAllActions()
				end
			end
		end, 0.1)
	end)
	self:runAction(cc.Sequence:create(delay, call))
end

function BaccaratScene:startDeal()
	lockScreen({})
	if CardManager:getLastNum() < 6 then
		CardManager:init(8)
		CardManager:discardJoker()
	end

	for i,v in ipairs(self.playerCards) do
		v:removeFromParent()
	end
	self.playerCards = {}
	
	for i,v in ipairs(self.bankerCards) do
		v:removeFromParent()
	end
	self.bankerCards = {}

	self.bg:stopAllActions()
	local player1 = cc.CallFunc:create(function ()
		self:toPlayer()
	end)
	local delay1 = cc.DelayTime:create(0.5)
	local banker1 = cc.CallFunc:create(function ()
		self:toBanker()
	end)
	local delay2 = cc.DelayTime:create(0.5)
	local player2 = cc.CallFunc:create(function ()
		self:toPlayer()
	end)
	local delay3 = cc.DelayTime:create(0.5)
	local banker2 = cc.CallFunc:create(function ()
		self:toBanker()
	end)
	local delay4 = cc.DelayTime:create(1)
	local result1 = cc.CallFunc:create(function ()
		local delay = cc.DelayTime:create(0.1)
		local result = cc.CallFunc:create(function ()
        	self.bg:stopAllActions()
			self:checkResult()
		end)
		self.backFrame:runAction(cc.Sequence:create(delay, result))
	end)
	local seq = cc.Sequence:create(player1, delay1, banker1, delay2, player2, delay3, banker2, delay4, result1)
	self.bg:runAction(seq)
end

function BaccaratScene:checkResult()
	local playerPoint = 0
	for i,v in ipairs(self.playerCards) do
		local point = v:getPoint()
		if point >= 10 then
			point = 0
		end
		playerPoint = playerPoint + point
	end
	playerPoint = playerPoint % 10

	local bankerPoint = 0
	for i,v in ipairs(self.bankerCards) do
		local point = v:getPoint()
		if point >= 10 then
			point = 0
		end
		bankerPoint = bankerPoint + point
	end
	bankerPoint = bankerPoint % 10

	local actionList = {}
	if #self.playerCards < 3 and playerPoint < 6 and bankerPoint < 8 then
		local player1 = cc.CallFunc:create(function ()
			self:toPlayer()
		end)
		local delay4 = cc.DelayTime:create(1)
		local result1 = cc.CallFunc:create(function ()
			local delay = cc.DelayTime:create(0.1)
			local result = cc.CallFunc:create(function ()
	        	self.bg:stopAllActions()
				self:checkResult()
			end)
			self.backFrame:runAction(cc.Sequence:create(delay, result))
		end)

		table.insert(actionList, player1)
		table.insert(actionList, delay4)
		table.insert(actionList, result1)
	else
		local addBanker = false
		if #self.bankerCards < 3 then
			if bankerPoint <= 2 then
				addBanker = true
			elseif #self.playerCards < 3 and bankerPoint < 6 then
				addBanker = true
			elseif #self.playerCards >= 3 then
				local playerCard3 = self.playerCards[3]:getPoint()
				if bankerPoint == 3 and playerCard3 ~= 8 then
					addBanker = true
				elseif bankerPoint == 4 and playerCard3 >= 2 and playerCard3 <= 7 then
					addBanker = true
				elseif bankerPoint == 5 and playerCard3 >= 4 and playerCard3 <= 7 then
					addBanker = true
				elseif bankerPoint == 6 and playerCard3 >= 6 and playerCard3 <= 7 then
					addBanker = true
				end
			end
		end

		if addBanker then
			local banker1 = cc.CallFunc:create(function ()
				self:toBanker()
			end)
			local delay4 = cc.DelayTime:create(1)
			local result1 = cc.CallFunc:create(function ()
				local delay = cc.DelayTime:create(0.1)
				local result = cc.CallFunc:create(function ()
		        	self.bg:stopAllActions()
					self:checkResult()
				end)
				self.backFrame:runAction(cc.Sequence:create(delay, result))
			end)

			table.insert(actionList, banker1)
			table.insert(actionList, delay4)
			table.insert(actionList, result1)
		else
			local delay4 = cc.DelayTime:create(1)
			local result1 = cc.CallFunc:create(function ()
				local delay = cc.DelayTime:create(0.1)
				local result = cc.CallFunc:create(function ()
		        	self.bg:stopAllActions()
					self:finish(playerPoint, bankerPoint)
				end)
				self.backFrame:runAction(cc.Sequence:create(delay, result))
			end)

			table.insert(actionList, delay4)
			table.insert(actionList, result1)
		end
	end

	local seq = cc.Sequence:create(actionList)
	self.bg:runAction(seq)
end

function BaccaratScene:calcGold(bet, playerPoint, playerDoubel, bankerPoint, bankerDoubel, sameCards)
	local total = 0

	--闲天王
	if playerPoint >= 8 then
		total = total + (bet[BJLBetType.PlayerKing] or 0) * 2
	else
		total = total - (bet[BJLBetType.PlayerKing] or 0)
	end

	--庄天王
	if bankerPoint >= 8 then
		total = total + (bet[BJLBetType.BankerKing] or 0) * 2
	else
		total = total - (bet[BJLBetType.BankerKing] or 0)
	end

	--闲对子
	if playerDoubel then
		total = total + (bet[BJLBetType.PlayerDouble] or 0) * 11
	else
		total = total - (bet[BJLBetType.PlayerDouble] or 0)
	end

	--庄对子
	if bankerDoubel then
		total = total + (bet[BJLBetType.BankerDouble] or 0) * 11
	else
		total = total - (bet[BJLBetType.BankerDouble] or 0)
	end

	--胜负
	if playerPoint > bankerPoint then
		total = total + (bet[BJLBetType.PlayerWin] or 0) * 1
		total = total - (bet[BJLBetType.BankerWin] or 0)
		total = total - (bet[BJLBetType.Tie] or 0)
		total = total - (bet[BJLBetType.TieSame] or 0)
	elseif playerPoint < bankerPoint then
		total = total - (bet[BJLBetType.PlayerWin] or 0)
		total = total + (bet[BJLBetType.BankerWin] or 0) * 1
		total = total - (bet[BJLBetType.Tie] or 0)
		total = total - (bet[BJLBetType.TieSame] or 0)
	else
		total = total - (bet[BJLBetType.PlayerWin] or 0)
		total = total - (bet[BJLBetType.BankerWin] or 0)
		total = total + (bet[BJLBetType.Tie] or 0) * 8

		if sameCards then
			total = total + (bet[BJLBetType.TieSame] or 0) * 32
		else
			total = total - (bet[BJLBetType.TieSame] or 0)
		end
	end

	return total
end

function BaccaratScene:finish()
	local playerDoubel = false
	local playerPointList = {}
	local playerPoint = 0
	for i,v in ipairs(self.playerCards) do
		local point = v:getPoint()
		playerPointList[point] = (playerPointList[point] or 0) + 1
		if point >= 10 then
			point = 0
		end
		playerPoint = playerPoint + point
	end
	playerPoint = playerPoint % 10
	for k,v in pairs(playerPointList) do
		if v == 2 then
			playerDoubel = true
			break
		end
	end

	local bankerDoubel = false
	local bankerPointList = {}
	local bankerPoint = 0
	for i,v in ipairs(self.bankerCards) do
		local point = v:getPoint()
		bankerPointList[point] = (bankerPointList[point] or 0) + 1
		if point >= 10 then
			point = 0
		end
		bankerPoint = bankerPoint + point
	end

	bankerPoint = bankerPoint % 10
	for k,v in pairs(bankerPointList) do
		if v == 2 then
			bankerDoubel = true
			break
		end
	end

	local sameCards = true
	if #self.bankerCards == #self.playerCards then
		for i = 1, #self.bankerCards do
			local find = false
			for j = 1, #self.playerCards do
				if not self.playerCards[j].used and self.bankerCards[i]:getPoint() == self.playerCards[j]:getPoint() then
					self.playerCards[j].used = true
					find = true
					break
				end
			end

			if not find then
				sameCards = false
				break
			end
		end
	else
		sameCards = false
	end

	local total = 0
	if self.mode == 1 then
		total = self:calcGold(self.playerBet, playerPoint, playerDoubel, bankerPoint, bankerDoubel, sameCards)
		GlobData:_ab_getGold(total)

		for i,v in pairs(self.betList) do
			local aiGet = self:calcGold(v, playerPoint, playerDoubel, bankerPoint, bankerDoubel, sameCards)
			self.aiList[i]:getGold(aiGet)
		end
	elseif self.mode == 2 then
		for i,v in pairs(self.betList) do
			local aiGet = self:calcGold(v, playerPoint, playerDoubel, bankerPoint, bankerDoubel, sameCards)
			self.aiList[i]:getGold(aiGet)
			total = total - aiGet
		end

		GlobData:_ab_getGold(total)
	end

    GlobData:_ab_save()
	OpenWin("BaccaratResultWin", playerPoint, bankerPoint, total)

	self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)
	for i,v in ipairs(self.chipList) do
		v:removeFromParent()
	end
	self.chipList = {}
	self.playerBet = {}
	self.betList = {}

	unLockScreen()

	self.playTimes = self.playTimes + 1
	if self.playTimes >= 3 then
		self.playTimes = 0
		pauseBackMusic()
		GoogleAdMobSDK:_ab_showPage(function (ret)
			resumeBackMusic()
		end)
	end

	self:doAIBet()
end

function BaccaratScene:toBanker()
	playEffectFunc("ui/send_card.wav")
	local card = CardManager:popCard()
	self.bg:addChild(card)

	card:setPosition(self.startPoint:getPosition())

	local x,y = self.bankerPoint:getPosition()
	transition.moveTo(card, {x = x + 20 * #self.bankerCards, y = y, time = 0.5, easing = "OUT", onComplete = function ()
		card:raise()
	end})

	table.insert(self.bankerCards, card)
end

function BaccaratScene:toPlayer()
	playEffectFunc("ui/send_card.wav")
	local card = CardManager:popCard()
	self.bg:addChild(card)

	card:setPosition(self.startPoint:getPosition())

	local x,y = self.playerPoint:getPosition()
	transition.moveTo(card, {x = x + 20 * #self.playerCards, y = y, time = 0.5, easing = "OUT", onComplete = function ()
		card:raise()
	end})

	table.insert(self.playerCards, card)
end

function BaccaratScene:onExit()
	stopBackMusic()
end

return BaccaratScene