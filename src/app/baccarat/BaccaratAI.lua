
local aiConfig = OpenConfig("aiConfig")

local BaccaratAI = class("BaccaratAI", function ()
	return cc.CSLoader:createNode("layer/userInfo.csb")
end)

function BaccaratAI:ctor(id, pos)
	self.config = aiConfig[id]
	self.data = GlobData.aiMgr:_ab_getAI(id)

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
end

function BaccaratAI:onEnter()
	self:getChildByName("head"):loadTexture("public/ico_" .. self.config.id .. ".png", UI_TEX_TYPE_PLIST)
	self.bg:getChildByName("name"):setString(self.config.name)
	self.bg:getChildByName("gold"):setString(self.data.gold)
end

function BaccaratAI:isGoldEnough(costGold)
    return self.data:_ab_isGoldEnough(costGold)
end

function BaccaratAI:getGold(gold)
    self.data:_ab_getGold(gold)
	self.bg:getChildByName("gold"):setString(self.data.gold)
end

function BaccaratAI:getBetList()
	local chipValue = {100, 200, 500, 1000}
	local chipChance = {
		[1] = 5000 - 500 * self.config.difficulty,
		[2] = 2000 - 200 * self.config.difficulty,
		[3] = 1000 + 200 * self.config.difficulty,
		[4] = 500 + 100 * self.config.difficulty,
	}
	local totalChip = chipChance[1] + chipChance[2] + chipChance[3] + chipChance[4]

	local betChance = {
		[1] = 5000 - 500 * self.config.difficulty,
		[2] = 1000 + 100 * self.config.difficulty,
		[3] = 5000 - 500 * self.config.difficulty,
		[4] = 2000 + 100 * self.config.difficulty,
		[5] = 2000 + 100 * self.config.difficulty,
		[6] = 50 + 10 * self.config.difficulty,
		[7] = 500 + 100 * self.config.difficulty,
		[8] = 500 + 100 * self.config.difficulty,
	}
	local totalBet = betChance[1] + betChance[2] + betChance[3] + betChance[4] + betChance[5] + betChance[6] + betChance[7] + betChance[8]
	local list = {}
	local min = 1 * self.config.difficulty
	local max = 5 * self.config.difficulty
	local betCont = MyRandom:random(min, max)
	local total = 0
	for i = 1, betCont do
		local index = 1
		local indexValue = MyRandom:random(1, totalBet)
		for i, v in ipairs(betChance) do
			if indexValue <= v then
				index = i
				break
			else
				indexValue = indexValue - v
			end
		end

		local chip = 1
		local chipPer = MyRandom:random(1, totalChip)
		local cost = 0
		for i, v in ipairs(chipChance) do
			if chipPer <= v then
				cost = chipValue[i]
				chip = i
				break
			else
				chipPer = chipPer - v
			end
		end

		if not self:isGoldEnough(total + cost) then
			break
		end

		total = total + cost
		table.insert(list, {index = index, chip = chip})
	end

	return list
end

function BaccaratAI:onExit()
	-- body
end

return BaccaratAI