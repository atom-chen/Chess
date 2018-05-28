
local aiConfig = OpenConfig("aiConfig")

local DdzAI = class("DdzAI", function ()
	return cc.CSLoader:createNode("layer/userInfo.csb")
end)

function DdzAI:ctor(id, pos)
	self.config = aiConfig[id]
	self.data = GlobData.aiMgr:_ab_getAI(id)
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
end

function DdzAI:getName()
	return self.config.name
end

function DdzAI:isMale()
	return self.config.sex == 1
end

function DdzAI:onEnter()
	self:getChildByName("head"):loadTexture("public/ico_" .. self.config.id .. ".png", UI_TEX_TYPE_PLIST)
	self.bg:getChildByName("name"):setString(self.config.name)
	self.bg:getChildByName("gold"):setString(self.data.gold)
end

function DdzAI:initCards(cards)
	for i,v in ipairs(self.cardList) do
		v:removeFromParent()
	end

	self.cardList = cards
	self.isDizhu = false
	self:resetPos()
end

function DdzAI:addCards(cards)
	for i,card in ipairs(cards) do
		table.insert(self.cardList, card)
	end

	self:resetPos()
	self.isDizhu = true
end

function DdzAI:resetPos()
	table.sort( self.cardList, function (c1, c2)
		if c1:getPoint() == c2:getPoint() then
			return c1:getColor() < c2:getColor()
		else
			return c1:getPoint() > c2:getPoint()
		end
	end )

	local perY = 10
	local startY = -5 * #self.cardList - 25
	for i,v in ipairs(self.cardList) do
		v:setLocalZOrder(self.pos * 100 + i)
		v:setPositionY(startY + perY * (i - 1))
	end
end

function DdzAI:vote()
	local bombTable = {}
	local singleTable = {}

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
			bombTable[k] = v
		elseif #v == 1 then
			singleTable[k] = v
		end
	end

	if table.nums(bombTable) > 0 or (singleTable[16] and #singleTable[16] > 2) or (temp[15] and #temp[15] >= 3) then
		return 3
	elseif (temp[15] and #temp[15] >= 2) and (singleTable[16] and (temp[14] and #temp[14] >= 3)) then
		return 2
	elseif (temp[15] and #temp[15] >= 1) and (temp[14] and #temp[14] >= 2) then
		return 1
	else
		return 0
	end
end

function DdzAI:deal(cardTable, cType, value, lastdz)
	if cType == DDZDealType.KING_BOMB then
		return
	end

	local returnType = DDZDealType.ERROR_CARD
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
				self.bombTable={}
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
	returnType = cType

	--如果没有的话出 有炸弹出炸弹
	if #returnTable <= 0 and self.bombTable and cType ~= DDZDealType.BOMB_CARD then
		local bombTable1 = nil
		for k, v in pairs(self.bombTable) do
			bombTable1 = v
			break
		end
		returnTable = bombTable1
		returnType = BOMB_CARD
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
		table.remove(self.cardList, returnTable[i])
	end

	table.sort( result, function (c1, c2)
		if c1:getPoint() == c2:getPoint() then
			return c1:getColor() < c2:getColor()
		else
			return c1:getPoint() < c2:getPoint()
		end
	end )

	return result, returnType, result[1]:getPoint()
end

--获取单张大牌
function DdzAI:getLargeVal(cardValue,limitValue)
	local returnTable = {}
	--
	limitValue = limitValue or 0
	local cardTable = {}
	for k, v in pairs(self.singleTable) do
		table.insert(cardTable, k)
	end

	table.sort( cardTable, function(a,b) 
		return a < b 
	end)
	
	local index = nil
	for k, v in pairs(cardTable) do
		if v > cardValue  and limitValue ~= v then
			index = v
			break
		end
	end

	if index and self.singleTable[index] then
		local info = self.singleTable[index]
		table.insert(returnTable,info[1])
	end

	--如果没有单张 拆
	if #returnTable <= 0 then
		for k = #self.cardList, 1, -1 do
			local v = self.cardList[k]
			if v:getPoint() > cardValue and limitValue ~= v:getPoint()  then
				returnTable[#returnTable+1] = k
				break
			end
		end
	end

	return returnTable or {}
end

--获取三张牌
function DdzAI:getThreeLargeVal(cardValue, etype, limitValue)
	local value = cardValue
	local currentValue = nil
	limitValue = limitValue or 0
	local outTable = {}
	local cardTable = {}
	for k, v in pairs(self.planeTable1) do
		table.insert(cardTable, k)
	end	
	table.sort(cardTable, function(a, b) 
		return a < b 
	end)
	
	local index = nil
	for k, v in pairs(cardTable) do
		if v > cardValue and v ~= limitValue then
			currentValue = v
			index = v
			break
		end
	end

	if index and self.planeTable1[index] then
		local returnTable = self.planeTable1[index]
		local id = 1
		for k, v in pairs(returnTable) do
			if id <= 3 then
				table.insert(outTable, v)
				id = id + 1
			end
		end
	end

	--取炸弹
	if #outTable <= 0 then
		local returnTable = {}
		for k, v in pairs(self.planeTable) do
			if k > cardValue and k ~= limitValue  then
				currentValue = k
				returnTable = v
				break
			end
		end

		local index = 1
		for k, v in pairs(returnTable) do
			if index <= 3 then
				table.insert(outTable, v)
				index = index + 1
			end
		end	
	end

	--3带
	if #outTable > 0 then
		if etype == 1 then
			local singTabel = self:getLargeVal(2, currentValue)
			for k ,v in pairs(singTabel) do
				table.insert(outTable, v)
			end

			if #outTable < 4 then
				outTable = {}
			end
		elseif etype == 2 then
			local returnTable = self:getTwoLargeVal(2, currentValue)
			local index = 1
			for k, v in ipairs(returnTable) do
				if index <= 2 then
					table.insert(outTable, v)
					index = index + 1
				end
			end

			if #outTable < 5 then
				outTable = {}
			end
		end
	end

	return outTable
end

--两倍
function DdzAI:getTwoLargeVal(cardValue, limitValue)
	local value = cardValue
	limitValue = limitValue or 0
	local outTable = {}
	local cardTable = {}
	for k, v in pairs(self.doubleTable1) do
		table.insert(cardTable, k)
	end
	table.sort(cardTable, function(a, b) 
		return a < b 
	end)
	
	local index = nil
	for k, v in pairs(cardTable) do
		if v > cardValue and v ~= limitValue then
			index = v
			break
		end
	end

	--对子没有拆三
	if index and self.doubleTable1[index] then
		local returnTable = self.doubleTable1[index]
		local id = 1
		for k, v in pairs(returnTable) do
			if id <= 2 then
				table.insert(outTable, v)
				id = id + 1
			end
		end
	else
		local temp = self:getThreeLargeVal(cardValue, nil, limitValue)
		local id = 1
		for k, v in pairs(temp) do
			if id <= 2 then
				table.insert(outTable, v)
				id = id + 1
			end
		end
	end

	return outTable
end

--炸弹
function DdzAI:getBombLargeVal(cardValue)
	local value = cardValue
	local outTable = {}
	if self.bombTable then
		for k, v in pairs(self.bombTable) do
			if k > value then
				outTable = v
				break
			end
		end
	end

	return outTable
end

--顺子
function DdzAI:getShunLargeVal(cardTable, cardValue)
	local value = cardValue
	local shunLeng = #cardTable
	for k = #self.cardList, 1, -1 do
		local v = self.cardList[k]
		if v:getPoint() > value and k > 1 then
			local i = k
			local j = i - 1
			local length = 1
			local outTable = {} 
			outTable[1] = k

			while self.cardList[j]:getPoint() - self.cardList[i]:getPoint() < 2 and j > 1 do
				--连续
				if self.cardList[j]:getPoint() - self.cardList[i]:getPoint() == 1 and self.cardList[j]:getPoint() ~= 15 then
					table.insert(outTable, j)
					i = j
				end
				j = j - 1
			end

			if #outTable >= shunLeng then
				local returnTable = {}
				for k, v in pairs(outTable) do
					if k <= shunLeng then
						table.insert(returnTable, v)
					end
				end

				return returnTable
			end
		end
	end

	return {}
end

--连对
function DdzAI:getLianDui(cardTable)
	local firstValue = cardTable[1]:getPoint()
	local endValue = cardTable[#cardTable]:getPoint()
	local cardLenth = endValue - firstValue + 1

	local cardValue = {}
	for k, v in pairs(self.doubleTable) do
		table.insert(cardValue,k)
	end
	table.sort(cardTable, function(a, b) 
		return a < b 
	end)

	local num = #cardValue
	if num < cardLenth then
		return {}
	end	

	local outTable = {} 
	for k, v in pairs(cardValue) do
		if v > firstValue and k < #cardValue then
			local i = k
			local j = i + 1
			local outTable1 = {}
			outTable1[1] = v
			while j <= #cardValue and (cardValue[j] - cardValue[i]) < 2 do
				--连续
				if (cardValue[j] - cardValue[i]) == 1 then
					table.insert(outTable1, cardValue[j])
					i = j
				end
				j = j + 1
			end

			if #outTable1 >= cardLenth then
		 		outTable = outTable1
				break
			else
				outTable = {}
			end
		end
	end	

	local returnTable = {}
	local id = 1
	for k, v in pairs(outTable) do
		if id > cardLenth then
			break
		end

		if self.doubleTable[v] then
			local index = 1
			for m, n in pairs(self.doubleTable[v]) do
				if index <= 2 then
					table.insert(returnTable, n)
					index = index + 1
				end
			end
		end
		id = id + 1
	end

	return returnTable
end

--获取飞机
function DdzAI:getPlane(cardTable, ctype)
	local firstValue = cardTable[1]:getPoint()
	local cardLenth = #cardTable / 3
	if ctype == 1 then
		cardLenth = #cardTable / 4
	elseif ctype == 2 then
		cardLenth = #cardTable / 5
	end

	local endValue = firstValue + cardLenth - 1
	local cardValue = {}
	for k, v in pairs(self.planeTable) do
		table.insert(cardValue, k)
	end

	if #cardValue < cardLenth then
		return {}
	end

	local outTable = {} 
	for k, v in pairs(cardValue) do
		if v > firstValue and k < #cardValue then
			local i = k
			local j = i + 1
			local outTable = {}
			outTable[1] = v

			while j <= #cardValue and (cardValue[j] - cardValue[i]) < 2 do
				--连续
				if (cardValue[j] - cardValue[i]) == 1 then
					table.insert(outTable, cardValue[j])
					i = j
				end
				j = j + 1
			end

			if #outTable >= cardLenth then
				break
			else
				outTable = {}
			end
		end
	end
	
	local returnTable = {}
	for k, v in pairs(outTable) do
		if self.planeTable[v] then
			local index = 1
			for m, n in pairs(self.planeTable[v]) do
				if index <= 3 then
					table.insert(returnTable, n)
					index = index + 1
				end
			end
		end
	end	
	
	if ctype == 1 then
		if #self.cardList > (cardLenth * 3 + cardLenth) then
			for k = #self.cardList, 1, -1 do
				local v = self.cardList[k]
				if v:getPoint() < firstValue and v:getPoint() > endValue then
					table.insert(returnTable, k)
					break
				end
			end
		else
			returnTable = {}
		end	
	elseif ctype == 2 then
		local temp = {}
		local index = 1
		for k, v in pairs(self.doubleTable) do
			if k < firstValue and k > endValue then
				index = index + 1
				table.insert(temp, v)
			end

			if index >= cardLenth then
				break
			end
		end	
		
		
		if #temp > 0 then
			for k, v in pairs(temp) do
				for m, n in pairs(v) do
					table.insert(returnTable, n)	
				end
			end
		else
			returnTable = {}
		end
	end

	return returnTable
end

--4 带2
function DdzAI:getSiDaiEr(cardTable, cardValue)
	local outTable = {}
	if self.bombTable then
		local value = cardValue
		local length = #cardTable
		local cType = 0
		for k, v in pairs(self.bombTable) do
			if k > value then
				outTable = v
				break
			end
		end

		local value = 0
		local count = 0
		for k, v in pairs(cardTable) do
			if v:getPoint() ~= value then
				count = count + 1
				value = v:getPoint()
			end
		end
		
		local index = 1
		local maxIndex = 1
		local cType = 1
		if length > 6 then
			maxIndex = 2
			cType = 2
		else
			if count < 3 then
				cType = 2
			end
		end
		
		if cType == 2 then
			for k, v in pairs(self.doubleTable) do
				if index <= maxIndex then
					local id = 1
					for m, n in pairs(v) do
						if id <= 2 then
							table.insert(outTable, n)
							id = id + 1
						end
					end
				else
					break
				end	
			end	
		else
			local index = 1
			for k, v in pairs(self.singleTable) do
				if index <= 2 then
					table.insert(outTable, v[1])
					index = index + 1
				end
			end

			if #outTable < 6 then
				local value = 0
				for k, v in pairs(self.cardList) do
					if v:getPoint() ~= value and v:getPoint() ~= cardValue then
						table.insert(outTable, k)
						value = v:getPoint()
						if #outTable >= 6 then
							break
						end
					end
				end
			end	
		end
		
		if #outTable < (4 + maxIndex * 2) then
			outTable = {}
		end
	end

	return outTable
end

function DdzAI:isFinish()
	return #self.cardList <= 0
end

function DdzAI:isGoldEnough(costGold)
	return self.data:_ab_isGoldEnough(costGold)
end

function DdzAI:getGold(gold)
	self.data:_ab_getGold(gold)
	self.bg:getChildByName("gold"):setString(self.data.gold)
end

function DdzAI:onExit()
	-- body
end

return DdzAI