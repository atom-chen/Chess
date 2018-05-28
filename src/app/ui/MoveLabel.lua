local curLabel = nil
local OpenFile = OpenFile
local UIScale9Sprite = OpenFile("UIScale9Sprite")
local UIRichLabel = OpenFile("UIRichLabel")

local MoveLabel = class("MoveLabel")

function MoveLabel.create(str,params)
	return MoveLabel.new(str,params)
end

function MoveLabel:ctor(str,params)
	local params = params or {}
    if curLabel and not tolua.isnull(curLabel) then
		curLabel:removeFromParent()
		curLabel = nil
	end

	local bg = UIScale9Sprite.new("public/public_slat_070.png",nil,nil,nil)
	bg:setScale(OverallScale)

	local word = UIRichLabel.new {
        fontName = NORMALFONT,
        fontSize = 25,
        fontColor = params.color
    }

	-- local word = ccui.Text:create(str,NORMALFONT,25)
	-- word:enableOutline(CoreColor.BLACK,1)
	-- if params.color then
	-- 	word:setTextColor(params.color)
	-- end
	--word:setAnchorPoint(cc.p(0, 0))
	word:setString("<div fontcolor=#FFFFFF outline=1,#000000>"..str.."</div>")
	local bSize = bg:getPreferredSize()
	local size = word:getContentSize()

	bg:setPreferredSize(cc.size(size.width + 200, size.height + 8))

	-- local point = ResolutionManager:getCenter(bg)
	local bgSize = bg:getContentSize()
	word:setPosition((bgSize.width - size.width) * 0.5, (bgSize.height + size.height) * 0.5)
	bg:addChild(word)
	self.word = word

	local scene = display:getRunningScene()
	if params and params.pos then
		bg:setPosition(ResolutionManager:scalePoint(params.pos))
	else
		bg:setPosition(ResolutionManager:scalePoint(cc.p(display.cx,display.cy)))
	end
	
	scene:addChild(bg, SceneNodeTag_MoveLabel)
	self.bg = bg
	curLabel = bg
	self:runWord()
	curLabel = bg
end

function MoveLabel:runWord()
--	transition.moveBy(self.bg, {time = 0.5, x = 0, y = 50, easing = "SINEOUT", onComplete = function ()
		--	self.bg:removeFromParent()
		--	curLabel = nil
	--	end})
	transition.fadeOut(self.bg, {time = 2})
	transition.fadeOut(self.word, {time = 2, onComplete = function ()
			self.bg:removeFromParent()
			curLabel = nil
		end})
	-- self.bg:setOpacity(0)
	-- transition.fadeIn()
end

return MoveLabel


