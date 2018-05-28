
local aiConfig = OpenConfig("aiConfig")
local DdzAI = OpenFile("DdzAI")

local DdzPlayer = class("DdzPlayer", DdzAI)

function DdzPlayer:ctor(pos)
	self.config = aiConfig[1]
	self.pos = pos

	local function onNodeEvent(eventType)
		if eventType == "enter" then
			self:onEnter()
		elseif eventType == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	self.bg = self:getChildByName("bg")
	if pos == 3 then
		self.bg:setPosition(105, 0)
	end

	self.cardList = {}
	self.isDizhu = false
	self.selectedCards = {}
end

function DdzPlayer:onEnter()
	self:getChildByName("head"):loadTexture("public/ico_" .. self.config.id .. ".png", UI_TEX_TYPE_PLIST)
	self.bg:getChildByName("name"):setString(self.config.name)
	self.bg:getChildByName("gold"):setString(GlobData:_ab_getPlayerInfo().gold)
end

function DdzPlayer:initCards(cards)
	for i,v in ipairs(self.cardList) do
		v:removeFromParent()
	end

	for i, card in ipairs(cards) do
		card:show()
	end

	self.cardList = cards
	self.isDizhu = false
	self:resetPos()
end

function DdzPlayer:addCards(cards)
	for i,card in ipairs(cards) do
		table.insert(self.cardList, card)
		card:show()
	end

	self:resetPos()
	self.isDizhu = true
end

function DdzPlayer:resetPos()
	table.sort( self.cardList, function (c1, c2)
		if c1:getPoint() == c2:getPoint() then
			return c1:getColor() < c2:getColor()
		else
			return c1:getPoint() > c2:getPoint()
		end
	end )

	self.selectedCards = {}
	local perX = 40
	local startX = perX * #self.cardList / -2
	for i,v in ipairs(self.cardList) do
		v:setLocalZOrder(self.pos * 100 + i)
		v:setPositionX(startX + perX * (i - 1))
		if v.selected then
			v:setPositionY(20)
			table.insert(self.selectedCards, v)
		else
			v:setPositionY(0)
		end
	end
end

function DdzPlayer:selectCard(pos)
	for i,v in ipairs(self.cardList) do
		if v:touchTest(pos) then
			if not v.selected then
				v.selected = true
			end
		end
	end

	self:resetPos()
end

function DdzPlayer:playCards()
	local selfType = self:judgeCardType()

	for i,v in ipairs(self.selectedCards) do
		for ii,vv in ipairs(self.cardList) do
			if v.carName == vv.carName then
				table.remove(self.cardList, ii)
				break
			end
		end
	end

	return self.selectedCards, selfType, self.selectedCards[1]:getPoint()
end

function DdzPlayer:canPlay(cardTable, cType, value)
	if #self.selectedCards <= 0 then
		return 1
	end

	if cType == DDZDealType.KING_BOMB then
		return 2
	end

	local selfType = self:judgeCardType()

	--不符合规格
	if selfType == DDZDealType.ERROR_CARD then
		return 3
	end

	if cType == selfType and cardTable[1]:getPoint() < self.selectedCards[1]:getPoint() 
		or (cType ~= DDZDealType.BOMB_CARD and (selfType == DDZDealType.BOMB_CARD or selfType == DDZDealType.KING_BOMB)) then
		return 0
	end

	--牌太小
	return 4
end

function DdzPlayer:reselect()
	self.selectedCards = {}
end

function DdzPlayer:judgeCardType()
	table.sort( self.selectedCards, function (c1, c2)
		if c1:getPoint() == c2:getPoint() then
			return c1:getColor() < c2:getColor()
		else
			return c1:getPoint() < c2:getPoint()
		end
	end )

	local count = #self.selectedCards
	if count > 0 and count < 5 then
		local card1 = self.selectedCards[1]
		local cardEnd = self.selectedCards[count]
		if card1:getPoint() == cardEnd:getPoint() then
			if card1:getPoint() == 16 then
				return DDZDealType.KING_BOMB
			else
				return count
			end
		else
			cardEnd = self.selectedCards[count - 1]
			if card1:getPoint() == cardEnd:getPoint() and count == 4 then
				return DDZDealType.THREE_ONE_CARD
			end
		end
	end

	if count > 5 then
		if self:isConnectCard() then
			return DDZDealType.CONNECT_CARD
		end

		if self:isCompanyCard() then
			return DDZDealType.COMPANY_CARD
		end

		return self:judgeAircraft()
	end

	return DDZDealType.ERROR_CARD
end

function DdzPlayer:isConnectCard()
	local lastPoint
	for i,v in ipairs(self.selectedCards) do
		local point = v:getPoint()
		if point >= 15 then
			return false
		end

		if lastPoint then
			if (lastPoint + 1) ~= point then
				return false
			end
		end

		lastPoint = point
	end

	return true
end

function DdzPlayer:isCompanyCard()
	local count = #self.selectedCards
	if count < 6 or (count % 2) ~= 0 then
		return false
	end

	local lastPoint
	for i = 1, count - 1, 2 do
		local point = self.selectedCards[i]:getPoint()
		if point >= 15 then
			return false
		end

		if lastPoint then
			if (lastPoint + 1) ~= point then
				return false
			end
		end

		lastPoint = point
	end

	return true
end

function DdzPlayer:judgeAircraft()
	local bombTable = {}
	local doubleTable = {}
	local planeTable = {}
	local singleTable = {}
	
	--分析牌型
	local temp = {}
	for i, card in ipairs(self.selectedCards) do
		local num = card:getPoint()
		if not temp[num] then
			temp[num]={}
		end
		table.insert(temp[num], i)
	end	

	for k, v in pairs(temp) do
		if #v == 4 then
			table.insert(bombTable, v)
		elseif #v == 3 then
			table.insert(planeTable, v)
		elseif #v == 2 and k ~= 0 then
			table.insert(doubleTable, v)
		else 
			table.insert(singleTable, v)
		end
	end

	local oneCount = table.nums(singleTable)
	local twoCount = table.nums(doubleTable)
	local threeCount = table.nums(planeTable)
	local fourCount = table.nums(bombTable)

	local function IsFeiJiLian(tab)
		local lastNum
		for i,v in ipairs(tab) do
			local point = v[1]:getPoint()
			if point >= 15 then
				return false
			end

			if lastNum then
				if (lastNum + 1) ~= point then
					return false
				end
			end

			lastNum = point
		end
	end

	--判断三带二
	if threeCount * 3 + twoCount * 2 == count and threeCount == 1 and twoCount == 1 then
		return DDZDealType.THREE_TWO_CARD
	end

	--判断飞机
	if threeCount > 1 and fourCount == 0 and IsFeiJiLian(planeTable) then
		--飞机不带
		if threeCount * 3 == count and twoCount + oneCount == 0 then
			return DDZDealType.AIRCRAFT_CARD
		end

		--飞机带单
		if threeCount * 3 + oneCount == lengh and twoCount == 0 then
			return DDZDealType.AIRCRAFT_SINGLE_CARD
		end

		--飞机带对
		if threeCount * 3 + twoCount == lengh and oneCount == 0 then
			return DDZDealType.AIRCRAFT_DOBULE_CARD
		end
	end

	--判断四带
	if threeCount == 0 and fourCount > 0 and lengh % 2 == 0 then
		--四带二
		if fourCount * 4 + oneCount == lengh and fourCount == 1 and oneCount == 2 then
			return DDZDealType.BOMB_TWO_CARD
		end

		--四带对
		if fourCount * 4 + twoCount * 2 == lengh and fourCount == 1 and twoCount == 1 then
			return DDZDealType.BOMB_TWOOO_CARD
		end
	end

	return DDZDealType.ERROR_CARD
end

function DdzPlayer:recommend(cardTable, cType, value)
	if cType == DDZDealType.KING_BOMB then
		return {}
	end

	local returnTable = {}
	self.bombTable = nil
	self.doubleTable = {}
	self.planeTable = {}
	self.singleTable = {}
	self.doubleTable1 = {}
	self.planeTable1 = {}
	
	--分析牌型
	local temp = {}
	for i, card in ipairs(self.cardList) do
		local num = card:getPoint()
		if not temp[num] then
			temp[num] = {}
		end
		table.insert(temp[num], i)
	end	

	for k, v in pairs(temp) do
		if #v == 4 then
			if not self.bombTable then
				self.bombTable = {}
			end
			self.bombTable[k] = v
			self.planeTable[k] = v
			
		elseif #v == 3 then
			self.planeTable[k] = v
			self.planeTable1[k] = v
			self.doubleTable[k] = v
		elseif #v == 2 and k ~= 16 then
			self.doubleTable[k] = v
			self.doubleTable1[k] = v
		else 
			self.singleTable[k] = v
		end
	end

	if cType == DDZDealType.SINGLE_CARD then
		returnTable = self:getLargeVal(value)
	elseif cType == DDZDealType.DOUBLE_CARD then
		returnTable = self:getTwoLargeVal(value)
	elseif cType == DDZDealType.THREE_CARD then
		returnTable = self:getThreeLargeVal(value)
	elseif cType == DDZDealType.THREE_ONE_CARD then
		returnTable = self:getThreeLargeVal(value,1)
	elseif cType == DDZDealType.THREE_TWO_CARD then
		returnTable = self:getThreeLargeVal(value,2)
	elseif cType == DDZDealType.BOMB_CARD then
		returnTable = self:getBombLargeVal(value,2)
	elseif cType == DDZDealType.CONNECT_CARD then
		returnTable = self:getShunLargeVal(cardTable,value)
	elseif cType == DDZDealType.BOMB_TWO_CARD then
		returnTable = self:getSiDaiEr(cardTable,value)
	elseif cType == DDZDealType.COMPANY_CARD then
		returnTable = self:getLianDui(cardTable)
	elseif cType == DDZDealType.AIRCRAFT_CARD then
		returnTable = self:getPlane(cardTable)
	elseif cType == DDZDealType.AIRCRAFT_SINGLE_CARD then
		returnTable = self:getPlane(cardTable,1)
	elseif cType == DDZDealType.AIRCRAFT_DOBULE_CARD then
		returnTable = self:getPlane(cardTable,2)
	end

	--如果没有的话出 有炸弹出炸弹
	if #returnTable <= 0 and self.bombTable and cType ~= DDZDealType.BOMB_CARD then
		local bombTable1 = nil
		for k, v in pairs(self.bombTable) do
			bombTable1 = v
			break
		end
		returnTable = bombTable1
	end

	--王炸
	if #returnTable <= 0 and self.singleTable and self.singleTable[16] and #self.singleTable[16] > 2 then
		table.insert(returnTable,self.singleTable[16][1])
		table.insert(returnTable,self.singleTable[16][2])
	end

	table.sort(returnTable, function (a, b)
		return a < b
	end)

	local result = {}
	for i = #returnTable, 1, -1 do
		table.insert(result, self.cardList[returnTable[i]])
	end

	table.sort( result, function (c1, c2)
		if c1:getPoint() == c2:getPoint() then
			return c1:getColor() < c2:getColor()
		else
			return c1:getPoint() < c2:getPoint()
		end
	end )

	return result
end

function DdzPlayer:getGold(gold)
	GlobData:_ab_getGold(gold)
	GlobData:_ab_save()
	self.bg:getChildByName("gold"):setString(GlobData:_ab_getPlayerInfo().gold)
end

return DdzPlayer