
local aiConfig = OpenConfig("aiConfig")

local CChessAI = class("CChessAI", function ()
	return cc.CSLoader:createNode("layer/userInfo.csb")
end)

function CChessAI:ctor(id, pos)
	self.config = aiConfig[id]
	self.data = GlobData.aiMgr:_ab_getAI(id)

    local function onNodeEvent(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    self.bg = self:getChildByName("bg")
    if pos == 3 then
    	self.bg:setPosition(105, 0)
    end
end

function CChessAI:onEnter()
	self:getChildByName("head"):loadTexture("public/ico_" .. self.config.id .. ".png", UI_TEX_TYPE_PLIST)
	self.bg:getChildByName("name"):setString(self.config.name)
	self.bg:getChildByName("gold"):setString(self.data.gold)
end

function CChessAI:getName()
    return self.config.name
end

function CChessAI:isGoldEnough(costGold)
    return self.data:_ab_isGoldEnough(costGold)
end

function CChessAI:getGold(gold)
    self.data:_ab_getGold(gold)
	self.bg:getChildByName("gold"):setString(self.data.gold)
end

function CChessAI:onExit()
	-- body
end

return CChessAI