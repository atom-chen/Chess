--灰色Shader--
--author lilinfeng --
function darkNode(node,index)
    local index = index or 2
    local typeIndex = ShaderType.STONE
  
    if index == 1 then
        typeIndex = ShaderType.DARKEN
    elseif index == 2 then
        typeIndex = ShaderType.GRAY
    elseif index == 3 then
        typeIndex = ShaderType.HIGHTLIGHT
    elseif index == 4 then
        typeIndex = ShaderType.EQUIP
    elseif index == 5 then
        typeIndex = ShaderType.ANIBUTTONDARKEN
    end
    
    local pProgram = ShaderManager:getShader(typeIndex)
    node:setGLProgram(pProgram)
    -- ShaderManager:showShader(node,pProgram)
end