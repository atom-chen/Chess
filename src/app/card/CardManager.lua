
local baseCardList = {
	"0x01", "0x02", "0x03", "0x04", "0x05", "0x06", "0x07", "0x08", "0x09", "0x0A", "0x0B", "0x0C", "0x0D",
	"0x11", "0x12", "0x13", "0x14", "0x15", "0x16", "0x17", "0x18", "0x19", "0x1A", "0x1B", "0x1C", "0x1D",
	"0x21", "0x22", "0x23", "0x24", "0x25", "0x26", "0x27", "0x28", "0x29", "0x2A", "0x2B", "0x2C", "0x2D",
	"0x31", "0x32", "0x33", "0x34", "0x35", "0x36", "0x37", "0x38", "0x39", "0x3A", "0x3B", "0x3C", "0x3D",
	"0x4E", "0x4F",
}

local Card = OpenFile("Card")
local DdzCard = OpenFile("DdzCard")
local CardManager = class("CardManager")

function CardManager:ctor()
	self.cardList = {}
	self.dropCardList = {}
end

function CardManager:init(_num)
	local num = _num or 1
	for i = 1, num do
		local curCards = clone(baseCardList)
		while #curCards > 0 do
			local index = MyRandom:random(1, #curCards)
			table.insert(self.cardList, curCards[index])
			table.remove(curCards, index)
		end
	end
end

function CardManager:discardJoker()
	for i = #self.cardList, 1, -1 do
		if self.cardList[i] == "0x4E" or self.cardList[i] == "0x4F" then
			table.remove(self.cardList, i)
		end
	end
end

function CardManager:getLastNum()
	return #self.cardList
end

function CardManager:popCard()
	if not self.cardList[1] then
		print("not enough card")
		return
	end

	local num = self.cardList[1]
	table.remove(self.cardList, 1)
	return Card.new(num)
end

function CardManager:popDdzCard()
	if not self.cardList[1] then
		print("not enough card")
		return
	end

	local num = self.cardList[1]
	table.remove(self.cardList, 1)
	return DdzCard.new(num)
end

function CardManager:dropCard(card)
	self.dropCardList[#self.dropCardList] = card
end

function CardManager:restore()
	self.cardList = self.dropCardList
	self.dropCardList = {}
end

return CardManager