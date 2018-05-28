
local ResolutionManager = class("ResolutionManager")

function ResolutionManager:ctor()
    self.logical = {width = 1136, height = 640}

    self.physical = {}
    -- local size = cc.Director:getInstance():getOpenGLView():getFrameSize()

    self.physical.width = cc.Director:getInstance():getWinSize().width
    self.physical.height = cc.Director:getInstance():getWinSize().height


    -- self.scaleX = self.physical.width / self.logical.width;
    -- self.scaleY = self.physical.height / self.logical.height;
    -- self.minScale = (self.scaleX < self.scaleY and self.scaleX) or self.scaleY

    self.scaleX = 1
    self.scaleY = 1
    self.minScale = 1
end

function ResolutionManager:init()
    
end

function ResolutionManager:getMinScale()
	return self.minScale
end

function ResolutionManager:getScaleX()
    return self.scaleX 
end

function ResolutionManager:getScaleY()
    return self.scaleY 
end

function ResolutionManager:getLogicalSize()
    return self.logical
end

function ResolutionManager:getPhysicalPositon(sx, sy)
    return {x = self.physical.width * sx, y = self.physical.height * sy}
end

function ResolutionManager:getLogicalPositon(sx, sy)
    return {x = self.logical.width * sx, y = self.logical.height * sy}
end

function ResolutionManager:getPhysicalSize()
    return self.physical
end

function ResolutionManager:scalePoint(point)
    return {x = point.x * self:getScaleX(), y = point.y * self:getScaleY()}
end

return ResolutionManager