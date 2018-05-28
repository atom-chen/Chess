
--
-- <pos/> 标签解析
--

return function (self, params, default)
	if not params.x or not params.y then return 
	end

	local pos = self:getPos(cc.p(params.x, params.y), params.imgpath, params.useclick, params.outline)
	if not pos then
		self:printf("<pos> - create pos failde")
		return
	end
	if params.scale then
		pos:setScale(params.scale)
	end
	if params.rotate then
		pos:setRotation(params.rotate)
	end
	if params.visible ~= nil then
		pos:setVisible(params.visible)
	end

	self:addChild(pos)
	local contetSize = pos:getBoundingBox()
	pos:removeFromParent(false)
	self._leftSpaceWidth = self._leftSpaceWidth - contetSize.width

	return {pos}
end
