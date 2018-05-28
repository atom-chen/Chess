
local TouchRegionLayer = class("TouchRegionLayer", function(node, callback, color)
	color = color or cc.c4b(10,10,10,204)
	local layer = cc.LayerColor:create(color)
	return layer
end)

function TouchRegionLayer:ctor(node, callback, color)
	self.callback = callback
	self.regionNode = node

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    -- listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.beganEvent), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.movedEvent), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function TouchRegionLayer:beganEvent(touch)
	return true
end
function TouchRegionLayer:movedEvent(touch)

end
-- function TouchRegionLayer:onTouchBegan(touch)
function TouchRegionLayer:onTouchEnded(touch)
	local touchPoint = touch:getLocation()

	local point = self.regionNode:convertToWorldSpace(cc.p(0, 0))
	local size = self.regionNode:getContentSize()
	local rect = cc.rect(point.x, point.y - 100, size.width * OverallScale, size.height * OverallScale + 100)
	local ret = cc.rectContainsPoint(rect, touchPoint)

	if ret == false then
		if self.callback then
			self.callback()
		end
	end

	-- return ret
end

return TouchRegionLayer
