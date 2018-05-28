local chinesechessConf = OpenConfig("chinesechessConf")

local redChessPic = {
    "chinesechess/rshuai.png", --(红色)帅
    "chinesechess/rshi.png",   --(红色)士
    "chinesechess/rxiang.png", --(红色)相
    "chinesechess/rma.png",    --(红色)马
    "chinesechess/rche.png",   --(红色)车
    "chinesechess/rpao.png",   --(红色)炮
    "chinesechess/rbing.png",  --(红色)兵
}

local blackChessPic = {
    "chinesechess/bjiang.png", --(黑色)将
    "chinesechess/bshi.png",   --(黑色)士
    "chinesechess/bxiang.png", --(黑色)相
    "chinesechess/bma.png",    --(黑色)马
    "chinesechess/bche.png",   --(黑色)车
    "chinesechess/bpao.png",   --(黑色)炮
    "chinesechess/bzu.png",    --(黑色)卒
}

local CChess = class("CChess", function ()
	return cc.CSLoader:createNode("chinesechess/chess.csb")
end)

function CChess:ctor(info, red)
	self.id = info.id
	self.x = info.pos.x
	self.y = info.pos.y
	self.cType = info.cType
	self.red = red
	self.dead = false

	local path = ""
	if red then
		path = redChessPic[self.cType]
	else
		path = blackChessPic[self.cType]
	end

	self:setScale(0.8)
	self:getChildByName("img"):loadTexture(path, UI_TEX_TYPE_PLIST)

	self:reset()
end

function CChess:reset()
	self.dead = false
end

return CChess