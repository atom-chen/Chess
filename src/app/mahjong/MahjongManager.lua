
local baseCardList = {
	"0x01", "0x02", "0x03", "0x04", "0x05", "0x06", "0x07", "0x08", "0x09", "0x0A", "0x0B", "0x0C", "0x0D",
	"0x11", "0x12", "0x13", "0x14", "0x15", "0x16", "0x17", "0x18", "0x19", "0x1A", "0x1B", "0x1C", "0x1D",
	"0x21", "0x22", "0x23", "0x24", "0x25", "0x26", "0x27", "0x28", "0x29", "0x2A", "0x2B", "0x2C", "0x2D",
	"0x31", "0x32", "0x33", "0x34", "0x35", "0x36", "0x37", "0x38", "0x39", "0x3A", "0x3B", "0x3C", "0x3D",
	"0x4E", "0x4F",
}

local Majong = OpenFile("Majong")
local MajongManager = class("MajongManager")

function MajongManager:ctor()
	self.cardList = {}
end

function MajongManager:init()
	local curCards = clone(baseCardList)
	while #curCards > 0 do
		local index = MyRandom:random(1, #curCards)
		table.insert(self.cardList, curCards[index])
		table.remove(curCards, index)
	end
end

function MajongManager:discardJoker()
	for i = #self.cardList, 1, -1 do
		if self.cardList[i] == "0x4E" or self.cardList[i] == "0x4F" then
			table.remove(self.cardList, i)
		end
	end
end

function MajongManager:getLastNum()
	return #self.cardList
end

function MajongManager:pop()
	local num = self.cardList[1]
	table.remove(self.cardList, 1)
	return Majong.new(num)
end

return MajongManager