local SlideOutAnimation = {}

function SlideOutAnimation:create(time, left, right, value)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o:init(time, left, right, value)
	return o
end

function SlideOutAnimation:init(time, left, right, value)
	self.time = time
	self.leftView = left
	self.rightView = right
	self.slideDistance = 0

	local leftSize = left:getContentSize()
	local rightSize = right:getContentSize()

	if leftSize.width > rightSize.width then 
		self.slideDistance = (rightSize.width + (value or 0)) * ResolutionManager:getMinScale()
		self.leftDis = cc.p(-self.slideDistance / 2, 0)
		self.rightDis = cc.p(self.slideDistance, 0)
	else
		self.slideDistance = (leftSize.width + (value or 0)) * ResolutionManager:getMinScale()
		self.leftDis = cc.p(-self.slideDistance, 0)
		self.rightDis = cc.p(self.slideDistance, 0)
	end
end

function SlideOutAnimation:start()
	local move1 = cc.MoveBy:create(self.time, self.leftDis)
	self.leftView:runAction(move1)

	local move2 = cc.MoveBy:create(self.time, self.rightDis)
	local seq = cc.Sequence:create(move2, cc.CallFunc:create(function ()
		if self.endCall then 
			self.endCall(1)
		end
	end))
	self.rightView:runAction(seq)
end

function SlideOutAnimation:reverse()
	local move1 = cc.MoveBy:create(self.time, cc.p(-self.leftDis.x, self.leftDis.y))
	self.leftView:runAction(move1)

	local move2 = cc.MoveBy:create(self.time, cc.p(-self.rightDis.x, self.rightDis.y))
	local seq = cc.Sequence:create(move2, cc.CallFunc:create(function ()
		if self.endCall then 
			self.endCall(2)
		end
	end))
	self.rightView:runAction(seq)
end

function SlideOutAnimation:setEndCall(callBackFunc)
	self.endCall = callBackFunc
end

return SlideOutAnimation