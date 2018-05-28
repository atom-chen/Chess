local UIScrollView = class("UIScrollView", function ()
	local scroll = cc.ScrollView:create()
	scroll._onTouchBegan = scroll.onTouchBegan
	scroll._onTouchMoved = scroll.onTouchMoved
	scroll._onTouchEnded = scroll.onTouchEnded
	scroll._onTouchCancelled = scroll.onTouchCancelled

	return scroll
end)

-- UIScrollView.DIRECTION_VERTICAL   = 1 --竖直滑动
-- UIScrollView.DIRECTION_HORIZONTAL = 2 --水平滑动

cc.SCROLLVIEW_DIRECTION_NONE = -1
cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
cc.SCROLLVIEW_DIRECTION_VERTICAL = 1
cc.SCROLLVIEW_DIRECTION_BOTH  = 2

function UIScrollView.create(params)  --{direction, container, containerSize, }
	local scroll = UIScrollView.new(params)

	return scroll
end

function UIScrollView:ctor(params)	
	self.childFocusCancelOffset = 10 * ResolutionManager:getMinScale()

	params = params or {}

	if params.container then 
		self:setContainer(params.container)
	end

	self:setViewSize(params.viewSize or cc.size(0,0))
	self:setContentSize(params.contentSize or params.viewSize or cc.size(0,0))
	self:setContentOffset(cc.p(0, 0))
	self:setTouchEnabled((params.touchEnable == nil) and true or false)
	self:setDirection(params.direction or cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
   	self:setClippingToBounds((params.clipping == nil) and true or false)
   	self:setBounceable((params.bounceable == nil) and true or false)
    self:setDelegate()

    -- 移动监听回调
    self.moveCallback = params.moveCallback or nil
    -- self:jumpToTop()

   --[[ local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
	--注册触摸事件
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)]]
end

function UIScrollView:interceptTouchEvent(type, sender, touch, event)

	local touchPoint = touch:getLocation()

	local touchIn = false

	if not self:isVisible() or not self:hasVisibleParents() then
		return false
	end

	if type == "began" then
		touchIn = self:_onTouchBegan(touch, event)
		self.isGetIntercept = true
	elseif type == "moved" then
		local startPoint = touch:getStartLocation()
		local offset = cc.pGetDistance(startPoint,touchPoint)

		if self.moveCallback and offset > self.childFocusCancelOffset then
			self.moveCallback()
		end

		if offset > self.childFocusCancelOffset then 
			self:_onTouchMoved(touch, event)
			sender:setHighlighted(false)
		end
	elseif type == "ended" then
		self:_onTouchEnded(touch, event)

		if sender:isSwallowTouches() then 
			self.isGetIntercept = false
		end
	elseif type == "cancelled" then 
		self.isGetIntercept = false
	end

	return touchIn
end

function UIScrollView:onTouchBegan(touch, event)
	if not self.isGetIntercept then
		self:_onTouchBegan(touch, event)
	end
end

function UIScrollView:onTouchMoved(touch, event)
	if not self.isGetIntercept then
		self:_onTouchMoved(touch, event)
	end
end

function UIScrollView:onTouchEnded(touch, event)
	if not self.isGetIntercept then
		self:_onTouchEnded(touch, event)
	end

	self.isGetIntercept = false
end

function UIScrollView:onTouchCancelled(touch, event)
	if not self.isGetIntercept then
		self:_onTouchCancelled(touch, event)
	end

	self.isGetIntercept = false
end

function UIScrollView:hasVisibleParents()
    local  parent = self:getParent()

    while parent ~= nil do
        if not parent:isVisible() then 
            return false
        end

        parent = parent:getParent()
    end  

    return true
end

return UIScrollView