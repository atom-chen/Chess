local UIImage = class("UIImage", function(img) 
	local temp = nil
	if img then
		temp = display.newSpriteFrame(img) or cc.Sprite:create(img):getSpriteFrame()
	end

	if not temp then
		temp = display.newSpriteFrame("unKnown.png") or cc.Sprite:create("unKnown.png"):getSpriteFrame()
	end

	return temp
end)


function UIImage:ctor(img,scalex,scaley,parms)
	self.img = img or "unKnown.png"
	self.parms = parms or {};
	if type(scalex) == "number" then
		self:setScaleX(scalex)
	end

	if type(scaley) == "number" then
		self:setScaleX(scaley)
	end
end

return UIImage