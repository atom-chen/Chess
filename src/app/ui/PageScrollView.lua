local PageScrollView = class("PageScrollView", function ()
	local scroll = cc.ScrollView:create()
	scroll._onTouchBegan = scroll.onTouchBegan
	scroll._onTouchMoved = scroll.onTouchMoved
	scroll._onTouchEnded = scroll.onTouchEnded
	scroll._onTouchCancelled = scroll.onTouchCancelled

	return scroll
end)

cc.SCROLLVIEW_DIRECTION_NONE = -1
cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
cc.SCROLLVIEW_DIRECTION_VERTICAL = 1
cc.SCROLLVIEW_DIRECTION_BOTH  = 2
local scheduleHandle
local FRICTION = 500 --摩擦力
local turnPageTime = 0.2 --翻页速度

local eggErea = {
	cc.rect(0, 0, 100, 100),
	cc.rect(1036, 540, 100, 100),
	cc.rect(1036, 0, 100, 100),
	cc.rect(0, 540, 100, 100),
}

function PageScrollView.create(params)
	local scroll = PageScrollView.new(params)

	return scroll
end
function PageScrollView:ctor(params)	
	self.pageIndex = 1 --当前页码
	self.lastIndex = 0
	self.totolePage = 0
	self.params = params or {}
	self.pageSize = params.pageSize or params.viewSize or cc.size(0,0)
	self:setViewSize(params.viewSize or cc.size(0,0))
	self:setContentSize(params.pageSize)
	self.eggList = {}

	-- self.scheduleHandle = scheduler.scheduleUpdateGlobal(handler(self, self.update));
	
    -- local function onNodeEvent(eventType)
    -- 	print("  eventType ===== ",eventType)
    --     if eventType == "enter" then
    --     	print("   mei  meimiemiemeimeimi  ")
    --         self.scheduleHandle = scheduler.scheduleUpdateGlobal(handler(self, self.update));
    --     elseif eventType == "enterTransitionFinish" then
    --     elseif eventType == "exit" then
    --         if self.scheduleHandle ~= nil then
    --             scheduler.unscheduleGlobal(self.scheduleHandle)
    --             self.scheduleHandle = nil
    --         end
    --     elseif eventType == "cleanup" then
    --     end
    -- end
    -- self:registerScriptHandler(onNodeEvent,0)
	
	

	self.childFocusCancelOffset = 5

	params = params or {}
	self.params = params
	if params.container then 
		self:setContainer(params.container)
	end
	self:setContentOffset(cc.p(0, 0))
	self:setTouchEnabled(false)
	self:setDirection(params.direction or cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
   	self:setClippingToBounds(params.clipping or true)
   	self:setBounceable(params.bounceable or true)
    self:setDelegate()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
  	listener:registerScriptHandler(handler(self,self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self,self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self,self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function PageScrollView:update(dt) --计算摩擦
	if self.startPoint then
		if not self.lengthTime then self.lengthTime = 0 end
		self.lengthTime = self.lengthTime + dt
	end

end

function PageScrollView:getContentRect()
	local x, y = self:getPosition()
	local size = self:getViewSize()
	local anchor = self:getAnchorPoint()

	x = x - anchor.x * size.width
	y = y - anchor.y * size.height

	return cc.rect(x, y, size.width, size.height)
end

function PageScrollView:interceptTouchEvent(type, sender, touch, event)
	local touchPoint = touch:getLocation()
	-- local touchIn = false

	if type == "began" then
		self:onTouchBegan(touch, event)
	elseif type == "moved" then
		self:onTouchMoved(touch, event)
	elseif type == "ended" then
		self:onTouchEnded(touch, event)
	end

	-- return touchIn
	return true
end

function PageScrollView:onTouchBegan(touch, event)
	if not self:isVisible() then
		return false
	end

	local screanPoint = touch:getLocation()
	if #self.eggList < 4 then
		for i,v in ipairs(eggErea) do
			if cc.rectContainsPoint(v, screanPoint) then
				self.eggList[#self.eggList + 1] = i
				break
			end
		end

		if #self.eggList == 4 then
			local showEgg = true
			for i,v in ipairs(self.eggList) do
				if i ~= v then
					showEgg = false
					break
				end
			end

			if showEgg then
		        OpenWin("PopPanel",{title = "ok"}, "Thank you for playing Sandglass Game!")
			end
		end
	end

	local touchPoint = self:getParent():convertToNodeSpace(screanPoint)
	local rect = self:getContentRect()
	if not cc.rectContainsPoint(rect, touchPoint) then
		return false
	end

	self.lengthTime = nil
	-- local touchIn = false

	if not self.scheduleHandle then
	    self.scheduleHandle = scheduler.scheduleUpdateGlobal(handler(self, self.update));
	end
	return true
end

function PageScrollView:onTouchMoved(touch, event)
	if not self:isVisible() then
		return false
	end

	if not self.startPoint then
		self.startPoint = touch:getStartLocation()
	end
	return true
end

function PageScrollView:onTouchEnded(touch, event)
	if not self:isVisible() then
		return false
	end
	
	--print("on touch *****************************************************")
	local touchPoint = touch:getLocation()
	if not self.endPoint and self.startPoint then
		self.endPoint = touchPoint

		if not self.params.bounceable or self.params.bounceable == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then
			local offx = self.endPoint.x - self.startPoint.x
			-- print("  offx ============ ",offx,self.lengthTime)
			-- print("  FRICTION ============ ",FRICTION)
			-- if self.lengthTime then
			-- 	print("  math.abs(offx/self.lengthTime) ============ ",math.abs(offx/self.lengthTime))
			-- end
			if self.lengthTime and self.lengthTime > 0 then
				if offx >= 150 and math.abs(offx/self.lengthTime) > FRICTION then --上一页
					--print("   上一页 ")
					self:perPage()
				elseif offx <= -150 and math.abs(offx/self.lengthTime) > FRICTION then --下一页
					--print("   下一页 ")
					self:nextPage()
				end
			end
		else
			local offy = self.endPoint.y - self.startPoint.y
			if self.lengthTime and self.lengthTime > 0 then
				if offy >= 150 and math.abs(offy/self.lengthTime) > FRICTION then --上一页
					--print(" y  上一页 ")
					self:perPage()
				elseif offy <= -150 and math.abs(offy/self.lengthTime) > FRICTION then --下一页
					--print(" y  下一页 ")
					self:nextPage()
				end
			end
		end
	end
	self:distory()
end

function PageScrollView:onTouchCancelled(touch, event)
	self:distory()
end

function PageScrollView:onTouchCancelled(touch, event)
end

function PageScrollView:distory()
	self.startPoint = nil
	self.endPoint = nil
	self.lengthTime = nil
	if self.scheduleHandle ~= nil then
	    scheduler.unscheduleGlobal(self.scheduleHandle)
	    self.scheduleHandle = nil
	end
end

function PageScrollView:addPage(pageNode,pt)
	if not pageNode then error("   页码Node为空 ") end
	self.totolePage = self.totolePage + 1
	self:setContentSize(cc.size(self.pageSize.width*self.totolePage,self.pageSize.height))
	self:addChild(pageNode)
	display.align(pageNode,pt or display.BOTTOM_LEFT,(self.totolePage-1)*self.pageSize.width,0)
end

function PageScrollView:setPageArea(min,max)
	self.minPage = min or 1
	self.maxPage = max or self.totolePage
end

function PageScrollView:turnPageSchedule()
	if self.waitScheduler then
        cc.Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.waitScheduler)
        self.waitScheduler = nil
    end
	self.waitScheduler = scheduler.performWithDelayGlobal(function()
        self.turnPageCD = false
        if self.params and self.params.afterCallback then
			self.params.afterCallback(self.lastIndex)
		end
    end,turnPageTime)
end

function PageScrollView:setInPage(pageIndex,time)
	if not self.turnPageCD then
		self.turnPageCD = true
		self.pageIndex = pageIndex or 1
		self:setContentOffsetInDuration(cc.p(-(self.pageIndex-1)*self.pageSize.width,0),time or turnPageTime)
		self:distory()
		self:turnPageSchedule()
	end
end

function PageScrollView:nextPage()
	if not self.turnPageCD then
		if (self.maxPage or self.totolePage) <= self.pageIndex then
			return false
		end
		if self.params.beforeCallback then
			self.params.beforeCallback(self.pageIndex + 1)
		end
		self.turnPageCD = true
		self.pageIndex = self.pageIndex + 1
		self:setContentOffsetInDuration(cc.p(-(self.pageIndex-1)*self.pageSize.width,0),turnPageTime)
		self:distory()
		self.lastIndex = self.pageIndex - 1
		self:turnPageSchedule()
		return true
	end
	return false
end

function PageScrollView:perPage()
	if not self.turnPageCD then
		if (self.minPage or 1) >= self.pageIndex then
			return false
		end
		if self.params.beforeCallback then
			self.params.beforeCallback(self.pageIndex - 1)
		end
		self.turnPageCD = true
		self.pageIndex = self.pageIndex - 1
		self:setContentOffsetInDuration(cc.p(-(self.pageIndex-1)*self.pageSize.width,0),turnPageTime)
		self:distory()
		self:turnPageSchedule()
		self.lastIndex = self.pageIndex + 1
		return true
	end
	return false
end

function PageScrollView:contains(point)
    local touchLocation = self:getParent():convertToNodeSpace(point)
    local rect = self:getTouchRect()
	return cc.rectContainsPoint(self:getTouchRect(), touchLocation)
end

return PageScrollView