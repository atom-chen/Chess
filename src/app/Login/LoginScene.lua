
local UIImageBox = OpenFile("UIImageBox")
local SceneBase = OpenFile("SceneBase")

local gameConfig = OpenConfig("gameConfig")

local LoginScene = class("LoginScene", SceneBase)

function LoginScene:ctor()
    LoginScene.super.ctor(self)
end

function LoginScene:onEnter()
    self.backFrame = cc.CSLoader:createNode("layer/login.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    local bg = self.backFrame:getChildByName("Panel_Bg")

    --设置
    local setup = UIImageBox.new(bg:getChildByName("setup"),function()
        OpenWin("SetupWin")
    end)

    local list = bg:getChildByName("ScrollView")
    list:setScrollBarEnabled(false)
    local showList = {}
    for i,v in ipairs(gameConfig) do
        if v.show then
            table.insert(showList, v)
        end
    end
    local count = #showList
    local width = 260
    local totalWidth = count * width + 20
    local itemList = {}
    for i,info in ipairs(showList) do
        local item = self:createItem(info)
        item:setPosition(10 + width * (i - 0.5), 170)
        list:addChild(item)
        table.insert(itemList, item)
    end

    local size = list:getInnerContainerSize()
    list:setInnerContainerSize(cc.size(totalWidth, size.height))

    if size.width > totalWidth then
        for i, item in ipairs(itemList) do
            local posX = item:getPositionX()
            item:setPositionX(posX + (size.width - totalWidth) / 2)
        end
    end
end

function LoginScene:createItem(info)
    local node = cc.CSLoader:createNode("layer/gameNode.csb")
    local btn = UIImageBox.new(node:getChildByName("bg"),function()
        OpenScene(info.scene, SceneOpenType.raplace, info.mode)
    end, {_swallowTouches = false})
    btn:setImage(info.icon)
    node:getChildByName("Image_3"):loadTexture(info.name, UI_TEX_TYPE_PLIST)
    if info.corner then
        node:getChildByName("Image_5"):loadTexture(info.corner, UI_TEX_TYPE_PLIST)
    else
        node:getChildByName("Image_5"):setVisible(false)
    end

    return node
end

return LoginScene