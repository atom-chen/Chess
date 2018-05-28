local chinesechessConf = OpenConfig("chinesechessConf")

local whiteChessPic = "wzq/white.png"
local blackChessPic = "wzq/black.png"

local WzqChess = class("WzqChess", function ()
	return cc.CSLoader:createNode("wzq/chess.csb")
end)

function WzqChess:ctor(x, y, white)
	self.x = x
	self.y = y
	self.white = white

	local path = blackChessPic
	if white then
		path = whiteChessPic
	end

	self:getChildByName("img"):loadTexture(path, UI_TEX_TYPE_PLIST)
end

return WzqChess