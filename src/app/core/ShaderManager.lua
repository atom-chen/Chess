--
-- Author: mafei
-- Date: 2015-08-18 15:34:41
--
ShaderType = {}
ShaderType.STONE = 1--MVP
ShaderType.PALSY = 2--MVP
ShaderType.GRAY = 3
ShaderType.HIGHTLIGHT = 4
ShaderType.DARKEN = 5
ShaderType.ANIBUTTONHIGHLIGHT = 6--MVP
-- ShaderType.BLUR = 7
ShaderType.ANIBUTTONDARKEN = 8
ShaderType.EQUIP = 9
ShaderType.ANIBUTTONGRAY = 10
ShaderType.COLORDODGE = 11
ShaderType.HIGHTLIGHT_2 = 12
-- ShaderType.BLUR_WINRT = 13

ShaderType.SHADER_NORMAL = "NormalShader";
ShaderType.SHADER_BANISH = "BanishShader";
-- ShaderType.SHADER_BLUR = "BlurShader";
ShaderType.SHADER_FROZEN = "FrozenShader";
ShaderType.SHADER_GRAY = "GrayShader";
ShaderType.SHADER_ICE = "IceShader";
ShaderType.SHADER_MIRROR = "MirrorShader";
ShaderType.SHADER_POISON = "PoisonShader";
ShaderType.SHADER_STONE = "StoneShader";
ShaderType.SHADER_HIGHTLIGHT = "HighlightShader";
ShaderType.SHADER_DARKEN = "DarkenShader";
ShaderType.SHADER_FIRE = "FireShader";
ShaderType.SHADER_COLORDODGE = "ColorDodge"
ShaderType.SHADER_EQUIP = "EquipFShader"

local ShaderManager = class("ShaderManager")

function ShaderManager:ctor()
    self.isloaded = false
    self.cache = {}
    
    self.cache[ShaderType.STONE] = {}
    self.cache[ShaderType.PALSY] = {}
    self.cache[ShaderType.GRAY] = {}
    self.cache[ShaderType.HIGHTLIGHT] = {}
    self.cache[ShaderType.DARKEN] = {}
    self.cache[ShaderType.ANIBUTTONHIGHLIGHT] = {}
    -- self.cache[ShaderType.BLUR] = {}
    self.cache[ShaderType.ANIBUTTONDARKEN] = {}
    self.cache[ShaderType.EQUIP] = {}
    self.cache[ShaderType.ANIBUTTONGRAY] = {}
    self.cache[ShaderType.COLORDODGE] = {}
    self.cache[ShaderType.HIGHTLIGHT_2] = {}
    -- self.cache[ShaderType.BLUR_WINRT] = {}
    
    self.cache[ShaderType.STONE].vPath = "shader/DefaultMVPShader.vsh"
    self.cache[ShaderType.STONE].fPath = "shader/StoneShader.fsh"
    
    self.cache[ShaderType.PALSY].vPath = "shader/DefaultMVPShader.vsh"
    self.cache[ShaderType.PALSY].fPath = "shader/PoisonShader.fsh"
    
    self.cache[ShaderType.GRAY].vPath = "shader/DefaultShader.vsh"
    self.cache[ShaderType.GRAY].fPath = "shader/GreyScaleShader.fsh"
    
    self.cache[ShaderType.HIGHTLIGHT].vPath = "shader/DefaultShader.vsh"
    self.cache[ShaderType.HIGHTLIGHT].fPath = "shader/HighlightShader.fsh"
    
    self.cache[ShaderType.DARKEN].vPath = "shader/DefaultShader.vsh"
    self.cache[ShaderType.DARKEN].fPath = "shader/DarkenShder.fsh"

    -- self.cache[ShaderType.BLUR].vPath = "shader/DefaultShader.vsh"
    -- self.cache[ShaderType.BLUR].fPath = "shader/BlurShaderUnique.fsh"

    self.cache[ShaderType.ANIBUTTONDARKEN].vPath = "shader/DefaultShader.vsh"
    self.cache[ShaderType.ANIBUTTONDARKEN].fPath = "shader/DarkenShader.fsh"
    
    self.cache[ShaderType.ANIBUTTONHIGHLIGHT].vPath = "shader/DefaultMVPShader.vsh"
    self.cache[ShaderType.ANIBUTTONHIGHLIGHT].fPath = "shader/HighlightShader.fsh"

    self.cache[ShaderType.EQUIP].vPath = "shader/EquipVShader.vsh"
    self.cache[ShaderType.EQUIP].fPath = "shader/EquipFShader.fsh"

    self.cache[ShaderType.ANIBUTTONGRAY].vPath = "shader/DefaultMVPShader.vsh"
    self.cache[ShaderType.ANIBUTTONGRAY].fPath = "shader/GreyScaleShader.fsh"

    self.cache[ShaderType.COLORDODGE].vPath = "shader/DefaultShader.vsh"
    self.cache[ShaderType.COLORDODGE].fPath = "shader/ColorDodge.fsh"

    self.cache[ShaderType.HIGHTLIGHT_2].vPath = "shader/DefaultShader.vsh"
    self.cache[ShaderType.HIGHTLIGHT_2].fPath = "shader/HighlightShader_2.fsh"

    -- self.cache[ShaderType.BLUR_WINRT].vPath = "shader/DefaultShader.vsh"
    -- self.cache[ShaderType.BLUR_WINRT].fPath = "shader/BlurShaderWinrt.fsh"
end

function ShaderManager:load()
    if not self.isloaded then
        for id, info in pairs(self.cache) do
            -- print("@@@l  ShaderManager:load ", id)
            local shader = cc.GLProgram:createWithFilenames(info.vPath, info.fPath)
            shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
            shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
            shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
            shader:link()
            shader:updateUniforms()
            shader:retain()
            self.cache[id].shader = shader
    	end
        
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        local customListener = cc.EventListenerCustom:create("event_renderer_recreated", function (event)
            self:reload()
        end)
        
        eventDispatcher:addEventListenerWithFixedPriority(customListener, 1)

        self.isloaded = true
    end
    
    print("@@@l  ShaderManager:load success")
end

function ShaderManager:onEnterBackground()
	
end

function ShaderManager:reload()
    print("ShaderManager:reload")
    for _, info in pairs(self.cache) do
        local shader = info.shader
        shader:reset()
        shader:initWithFilenames(info.vPath, info.fPath)
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
        shader:link()
        shader:updateUniforms()
    end
    
    print("@@@r  ShaderManager:reload  success")
end

--不要使用这个方法，请使用showShader
function ShaderManager:getShader(typeIndex)
    return self.cache[typeIndex].shader
end

function ShaderManager:getDefaultShader(typeIndex)
    return cc.GLProgramCache:getInstance():getGLProgram(cc.SHADER_POSITION_TEXTURE_COLOR)
end

function ShaderManager:showShader(node, shaderName)
        local nodeArr = {}
        if type(node) == "table" then
            for k,v in pairs(node) do
                table.insert(nodeArr,v)
            end
        else
            table.insert(nodeArr, node)
        end

        local shader = nil;
        if iskindof(nodeArr[1], "cc.DHSkeletonAnimation") then
            shader = self:loadShader(shaderName, false)
        else 
            shader = self:loadShader(shaderName, true)
        end
        for i = 1, table.nums(nodeArr) do
            nodeArr[i]:setGLProgram(shader)
            if nodeArr[i].weaponAnims ~= nil then
                 for i,weaponAnim in ipairs(nodeArr[i].weaponAnims) do
                     weaponAnim:setGLProgram(shader)
                 end
            end
        end

        local skeletonArr = {}
        if iskindof(nodeArr[1], "ccui.Widget") then
            self:setChildrenGLProgram(node, shader, skeletonArr, shaderName)
        end
        if table.nums(skeletonArr) > 0 then
            self:showShader(skeletonArr, shaderName)
        end
end

function ShaderManager:setChildrenGLProgram (node, shader, skeletonArr, shaderName) 
        if iskindof(node, "ccui.Widget") then
            local subChildren = node:getRenderer()
            for k,v in pairs(subChildren) do
                if tolua.type(v) == "ccui.Text" or tolua.type(v) == "ccui.TextField" or tolua.type(v) == "cc.Label" then
                    self:handleText(v, shaderName) 
                else
                    v:setGLProgram(shader)
                end
            end
        end
        local children = node:getChildren()
        for k,v in pairs(children) do
            if tolua.type(v) == "ccui.Text" or tolua.type(v) == "ccui.TextField" or tolua.type(v) == "cc.Label"  then
                self:handleText(v, shaderName)
            elseif iskindof(v, "cc.DHSkeletonAnimation") then
                table.insert(skeletonArr, v)
            else
                v:setGLProgram(shader)
                self:setChildrenGLProgram(v, shader, skeletonArr,shaderName)
            end
        end
end

function ShaderManager:handleText(node,shaderName)
        if shaderName == ShaderType.SHADER_NORMAL then
            local color = node.defaultColor
            if color == nil then
                color = CoreColor.WHITE
            end
            node:setTextColor(color)
        end
        if shaderName == ShaderType.SHADER_DARKEN or shaderName == ShaderType.SHADER_STONE or shaderName == ShaderType.SHADER_GRAY then
            node.defaultColor = node:getTextColor()
            node:setTextColor(CoreColor.GREY)
        end
end

function ShaderManager:loadShader(shaderName, noMVP)
    local keyOfShader = shaderName
    if noMVP == true then
        keyOfShader = keyOfShader.."_noMVP"
    end
    local shader = cc.GLProgramCache:getInstance():getGLProgram(keyOfShader)
    if shader ~= nil then
        return  shader
    end
    local vshFile = "shader/DefaultShader.vsh"
    local fshFile = "shader/"..shaderName..".fsh"
    if noMVP == false then
        vshFile = "shader/DefaultMVPShader.vsh"
    end

    shader = cc.GLProgram:createWithFilenames(vshFile,fshFile)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    shader:link()
    shader:updateUniforms()
    cc.GLProgramCache:getInstance():addGLProgram(shader, keyOfShader)
    return shader
end

return ShaderManager
