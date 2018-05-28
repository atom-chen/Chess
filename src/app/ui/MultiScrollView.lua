
local MultiScrollView = class("MultiScrollView", function()
	return display.newNode()
end)

local TOUCH_MODE = {
	NONE = 0,
	ONE = 1, -- 单点触控，移动屏幕
	MULTI = 2, -- 多点触控（只支持两个点），缩放
}
local SCROLL_ACTION_TAG = 11

function MultiScrollView:ctor(width, height, callback)
	self.boundWidth = display.width
	self.boundHeight = display.height
	self:setSize(width, height)
	self.validTouches = {}
	self.mode = TOUCH_MODE.NONE
	self.scale = 1
	self.minScale = 0.50
	self.maxScale = 1.43
	self.minReboundScale = 0.58
	self.maxReboundScale = 1.25
	self.scrollSpeed = 1000
	self.moveDis = 20 -- 滑动20以内视为点击
	self.clickPos = nil -- 单点触控时，点击屏幕的坐标
	self.callback = callback
	self.checkPositionFuc = nil

	-- 惯性
	self.autoMoveSpeed = 0
	self.autoMoveDirection = cc.p(0, 0)

	-- 回弹
	self.focusPoint = cc.p(0, 0)
	self.convertPoint = cc.p(0, 0)
	self.scaleDistance = 0
	self.reboundSpeed = 0

	local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(handler(self, self.onTouchesBegan), cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchesMoved), cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchesEnded), cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchesCancelled), cc.Handler.EVENT_TOUCHES_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self:onUpdate(handler(self, self.update))
end

function MultiScrollView:setMinScale(scale)
	self.minScale = scale
end

function MultiScrollView:setMinReboundScale(scale)
	self.minReboundScale = scale
end

function MultiScrollView:setSize(width, height)
	self.width = width
	if self.width < self.boundWidth then
		self.width = self.boundWidth
	end

	self.height = height
	if self.height < self.boundHeight then
		self.height = self.boundHeight
	end	
end

function MultiScrollView:getCurTime()
	local socket = require "socket"
	return socket.gettime()
end

function MultiScrollView:onTouchesBegan(touches, event)
	self:addValidTouches(touches)
	self:stopAutoMove()
	self:stopAutoRebound()
	self.clickPos = nil

	local cnt = table.nums(self.validTouches)
	if cnt == 1 then
		self.mode = TOUCH_MODE.ONE
		local values = table.values(self.validTouches)
		self.clickPos = values[1]:getLocation()
	elseif cnt == 2 then
		self.mode = TOUCH_MODE.MULTI
		local values = table.values(self.validTouches)
		local p1, p2 = values[1]:getLocation(), values[2]:getLocation()
		local point = cc.p((p1.x + p2.x)/2, (p1.y + p2.y)/2)
		self.focusPoint = point
		self.convertPoint = self:convertToNodeSpace(point)
		self.scaleDistance = cc.pGetLength(cc.pSub(p1, p2))
	end

	if self.callback then
		self.callback(MultiScrollEventType.TOUCHES_BEGAN)
	end
end

function MultiScrollView:onTouchesMoved(touches, event)
	self:updateValidTouches(touches)

	if table.nums(self.validTouches) ~= self.mode then
		return
	end

	local values = table.values(self.validTouches)
	if self.mode == TOUCH_MODE.ONE then
		self:movedEvent(values[1])
	elseif self.mode == TOUCH_MODE.MULTI then
		self:multiMovedEvent(values)
	end

	if self.callback then
		self.callback(MultiScrollEventType.TOUCHES_MOVED)
	end
end

function MultiScrollView:onTouchesCancelled(touches, event)
	self:removeValidTouches(touches)
	self.clickPos = nil

	if self.callback then
		self.callback(MultiScrollEventType.TOUCHES_CANCELLED)
	end
end

function MultiScrollView:onTouchesEnded(touches, event)
	if self.clickPos and self.callback then
		self.callback(MultiScrollEventType.CLICK, {pos = self.clickPos, scale = self.scale})
	end

	self:removeValidTouches(touches)
	self.clickPos = nil

	if self.callback then
		self.callback(MultiScrollEventType.TOUCHES_ENDED)
	end
end

function MultiScrollView:movedEvent(touch)
	local delta = touch:getDelta()
	delta = cc.pMul(delta, 0.6) -- 缓动

	if self.clickPos and cc.pGetLength(cc.pSub(touch:getLocation(), self.clickPos)) > 20 then
		self.clickPos = nil
	end

	local x, y = self:getPosition()
	local maxMoveSpeed = 1000

	local moveDis = cc.pGetLength(delta)
	local deltaTime = touch.time - touch.preTime
	if deltaTime < 0.01 then deltaTime = 0.02 end

	self.autoMoveSpeed = moveDis / deltaTime
	if self.autoMoveSpeed > maxMoveSpeed then
		self.autoMoveSpeed = maxMoveSpeed
	end
	self.autoMoveDirection = cc.pNormalize(delta)

	self:updatePosition(x + delta.x, y + delta.y)
end

function MultiScrollView:multiMovedEvent(touches)
	local p1, p2 = touches[1]:getLocation(), touches[2]:getLocation()
	local distance = cc.pGetLength(cc.pSub(p1, p2))
	local scale = distance / self.scaleDistance
	self.scaleDistance = distance
	self:updateScale(self.scale * scale)

	self.reboundSpeed = 0.5
end

function MultiScrollView:updateScale(scale)
	if scale > self.maxScale then
		scale = self.maxScale
	end
	if scale < self.minScale then
		scale = self.minScale
	end

	self.scale = scale
	self:setScale(self.scale)
	local x = self.focusPoint.x - self.convertPoint.x * self.scale
	local y = self.focusPoint.y - self.convertPoint.y * self.scale

	self:updatePosition(x, y)
end


function MultiScrollView:checkPosition(x, y)
	-- 注册了修正位置方法
	if self.checkPositionFuc then
		return self.checkPositionFuc(x, y)
	end

	return self:fixPosition(x, y)
end

function MultiScrollView:fixPosition(x, y)
	local minX = self.boundWidth - self.width * self.scale
	local maxX = 0
	if x > maxX then
		x = maxX
	end
	if x < minX then
		x = minX
	end

	local minY = self.boundHeight - self.height * self.scale
	local maxY = 0
	if y > maxY then
		y = maxY
	end
	if y < minY then
		y = minY
	end

	return x, y
end

function MultiScrollView:updatePosition(x, y)
	local x, y = self:checkPosition(x, y)
	self:setPosition(x, y)

	if self.callback then
		self.callback(MultiScrollEventType.POSITION, {pos = cc.p(x, y), scale = self.scale, speed = self.autoMoveSpeed})
	end
end

function MultiScrollView:addValidTouches(touches)
	for i, v in ipairs(touches) do
		local time = self:getCurTime()
		v.time = time
		v.preTime = time
        self.validTouches[v:getId()] = v
    end
end

function MultiScrollView:updateValidTouches(touches)
	for i, v in ipairs(touches) do
		local id = v:getId()
		if self.validTouches[id] then
			local preTime = self.validTouches[id].preTime
			local time = self.validTouches[id].time

			v.preTime = time
			v.time = self:getCurTime()
			self.validTouches[id] = v
		end
	end
end

function MultiScrollView:removeValidTouches(touches)
	if touches == nil then
		self.validTouches = {}
	else
		for i, v in ipairs(touches) do
			self.validTouches[v:getId()] = nil
		end
	end

	if table.nums(self.validTouches) == 0 then
		self.mode = TOUCH_MODE.NONE
	end
end

function MultiScrollView:scrollToPosition(x, y, time, callback)
	callback = callback or function()end

	local pos = self:convertToNodeSpace(cc.p(x, y))
	local x, y = self:checkPosition(self.boundWidth / 2 - pos.x * self.scale, self.boundHeight / 2 - pos.y * self.scale)
	local startX, startY = self:getPosition()

	if time == nil then
		time = cc.pGetLength(cc.p(x - startX, y - startY)) / self.scrollSpeed
	end

	self:stopActionByTag(SCROLL_ACTION_TAG)
	local action = cc.Sequence:create(
		cc.MoveTo:create(time, cc.p(x, y)),
		cc.CallFunc:create(callback)
	)
	action:setTag(SCROLL_ACTION_TAG)
	self:runAction(action)
end

function MultiScrollView:stopAutoMove()
	self:stopActionByTag(SCROLL_ACTION_TAG)
	self.autoMoveSpeed = 0
	self.autoMoveDirection = cc.p(0, 0)
end

function MultiScrollView:stopAutoRebound()
	self.reboundSpeed = 0
end

function MultiScrollView:update(ticks)
	if self.mode == TOUCH_MODE.NONE then
		if self.autoMoveSpeed > 1 then
			local x, y = self:getPosition()
			self:updatePosition(x + self.autoMoveDirection.x * self.autoMoveSpeed * ticks, y + self.autoMoveDirection.y * self.autoMoveSpeed * ticks)

			if self.autoMoveSpeed < 200 then
				self.autoMoveSpeed = self.autoMoveSpeed - ticks * self.autoMoveSpeed * 3
			else
				self.autoMoveSpeed = self.autoMoveSpeed - ticks * self.autoMoveSpeed * 1.5
			end
		end

		if self.reboundSpeed > 0 then
			if self.scale >= self.maxReboundScale then
				self:updateScale(self.scale - self.reboundSpeed * ticks)
			end

			if self.scale <= self.minReboundScale then
				self:updateScale(self.scale + self.reboundSpeed * 0.5 * ticks)
			end
		end
	end
end

function MultiScrollView:registerCheckPosFunc(callback)
	self.checkPositionFuc = callback
end

function MultiScrollView:unregisterCheckPosFunc()
	self.checkPositionFuc = nil
end

return MultiScrollView
