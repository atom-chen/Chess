local Card = class("Card", function ()
	return cc.Node:create()
end)

function Card:ctor(carName)
	self.carName = carName
	self:init()
end

function Card:init()
	self.node = cc.CSLoader:createNode("cards/card.csb")
	self:addChild(self.node)

	self.node:getChildByName("front"):loadTexture("cards/" .. self.carName .. ".png", UI_TEX_TYPE_PLIST)
end

function Card:getName()
	return self.carName
end

function Card:getPoint()
	local point = string.sub(self.carName, 4)
	if point == "A" then
		point = "10"
	elseif point == "B" then
		point = "11"
	elseif point == "C" then
		point = "12"
	elseif point == "D" then
		point = "13"
	elseif point == "E" then
		point = "0"
	elseif point == "F" then
		point = "0"
	end

	return tonumber(point)
end

function Card:getColor()
	local color = string.sub(self.carName, 1, 3)
	if color == "0x0" then
		return CardColor.Diamond
	elseif color == "0x1" then
		return CardColor.Clu
	elseif color == "0x2" then
		return CardColor.Heart
	elseif color == "0x3" then
		return CardColor.Spade
	elseif color == "0x4" then
		if self.carName == "0x4E" then
			return CardColor.BlackKing
		else
			return CardColor.RedKing
		end
	end
end

function Card:raise(callback)
	playEffectFunc("ui/raise_card.wav")
	local action = cc.CSLoader:createTimeline("cards/card.csb")
	self.node:runAction(action)
    action:play("raise", false)

    action:setAnimationEndCallFunc("raise", function()
        if callback then
        	callback()
        end
    end)
end

function Card:show()
	self.node:getChildByName("front"):setOpacity(255)
	self.node:getChildByName("back"):setOpacity(0)
	self.node:getChildByName("front"):setScaleX(1)
end

return Card