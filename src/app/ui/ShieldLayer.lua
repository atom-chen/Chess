local function calculateWordRec(node, width, heiht)
	local point = node:convertToWorldSpace(cc.p(0, 0))
	--print("rect origin point :", point.x, point.y)
	local size = cc.size(0, 0)

	if width and heiht then
		size = cc.size(width, heiht)
	else
		size = node:getContentSize()
	end
	local rect = cc.rect(point.x, point.y, size.width * OverallScale, size.height * OverallScale)
	--print("rect tect", rect)
	return rect
end


local ShieldLayer = class("Shieldlayer", function (node, callfunc, color) 
        local layer = nil
        
        if color then 
            layer = cc.LayerColor:create(color)
        else
            layer = cc.LayerColor:create(cc.c4b(10,10,10,204))
        end
        
        return layer
    end)

function ShieldLayer.create(node, callfunc, color)
    local shieldLayer = ShieldLayer.new(node, callfunc, color)
    return shieldLayer
end

function ShieldLayer:ctor(node, callfunc)
   -- self.isClick = false
    self.aboveNode = node

    self.call = callfunc

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        --print("tttttttttttttttttttttttttttttttt", self:isVisible(), self:hasVisibleParents())
        if not self:isVisible() or not self:hasVisibleParents() then 
            --print("ShieldLayer false")
            return false
        end
        return true    -- So we can proceed afterwards
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        local touchPoint = touch:getLocation() 
        local rect = nil
        if self.aboveNode then
            if self.aboveNodeSize then
                rect = calculateWordRec(self.aboveNode, self.aboveNodeSize.width, self.aboveNodeSize.height)
            else
                rect = calculateWordRec(self.aboveNode)
            end

            if self.call and not cc.rectContainsPoint(rect, touchPoint) then 
                --self.isClick = true

                self.call(touchPoint, cc.Handler.EVENT_TOUCH_MOVED)
            end
        end
        return true    -- So we can proceed afterwards
    end, cc.Handler.EVENT_TOUCH_MOVED)

    listener:registerScriptHandler(function(touch, event)
        local touchPoint = touch:getLocation() 
        local rect = nil
        if self.aboveNode then
            if self.aboveNodeSize then
                rect = calculateWordRec(self.aboveNode, self.aboveNodeSize.width, self.aboveNodeSize.height)
            else
                rect = calculateWordRec(self.aboveNode)
            end

            if self.call and not cc.rectContainsPoint(rect, touchPoint) then 
                --self.isClick = true

                self.call(touchPoint, cc.Handler.EVENT_TOUCH_ENDED)
            end
        end
        return true    -- So we can proceed afterwards
    end, cc.Handler.EVENT_TOUCH_ENDED)


    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ShieldLayer:shieldTop()
	self:setLocalZOrder(100)
end

function ShieldLayer:shieldButtom()
	self:setLocalZOrder(-100)
end

function ShieldLayer:setCallFunc(callfunc)
	self.call = callfunc
end

function ShieldLayer:setAboveNode(node, width, height)
	self.aboveNode = node
	if width and height then 
		self:setAboveNodeSize(width, height)
	end
end

function ShieldLayer:setAboveNodeSize(width, height)
	self.aboveNodeSize = cc.size(width, height)
end

function ShieldLayer:hasVisibleParents()
    local  parent = self:getParent()

    while parent ~= nil do
        if not parent:isVisible() then 
            return false
        end

        parent = parent:getParent()
    end  

    return true
end

return ShieldLayer