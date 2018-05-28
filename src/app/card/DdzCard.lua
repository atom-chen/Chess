local UIImageBox = OpenFile("UIImageBox")
local Card = OpenFile("Card")

local DdzCard = class("DdzCard", Card)

function DdzCard:ctor(carName)
	DdzCard.super.ctor(self, carName)
	self.btn = self.node:getChildByName("btn")
end

function DdzCard:touchTest(point)
	local size = self.btn:getContentSize()
	local x, y = self:getPosition()
	local rect = cc.rect(x - size.width / 2, y - size.height / 2, size.width, size.height)
	return cc.rectContainsPoint( rect, point )
end

function DdzCard:getPoint()
	local point = string.sub(self.carName, 4)
	if point == "1" then
		point = "14"
	elseif point == "2" then
		point = "15"
	elseif point == "A" then
		point = "10"
	elseif point == "B" then
		point = "11"
	elseif point == "C" then
		point = "12"
	elseif point == "D" then
		point = "13"
	elseif point == "E" then
		point = "16"
	elseif point == "F" then
		point = "16"
	end

	return tonumber(point)
end

return DdzCard