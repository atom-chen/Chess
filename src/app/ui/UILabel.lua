
local OpenFile = OpenFile
local ui = OpenFile("ui")

local UILabel = class("UILabel", function(params)


    local text   = string.utf8trim(tostring(params.text)) or "";
    local font   = params.font or NORMALFONT;
    -- local font   = "res/fonts/HYh3gj.ttf";
    local size   = params.size or 20;
    local color  = params.color or CoreColor.WHITE
    local align  = params.alignX or ui.TEXT_ALIGN_LEFT;
    -- local align  = params.alignX or cc.TEXT_ALIGNMENT_LEFT;
    local valign = params.alignY or ui.TEXT_VALIGN_CENTER;
    -- local valign = params.alignY or cc.TEXT_ALIGNMENT_CENTER;
    local dimensions = params.dimensions or cc.size(0,0);
	-- local label = ui.newTTFLabel({
 --        text   = text,
 --        font   = font,
 --        size   = size,
 --        color  = color,
 --        align  = align,
 --        valign = valign,
 --        dimensions = dimensions
 --    })
    local label = ccui.Text:create(text,font,size)
    label:setTextAreaSize(dimensions)
    label:setTextHorizontalAlignment(align)
    label:setTextVerticalAlignment(valign)
    -- label:enableOutline(color,size)
    -- label:setString(color)
    label:setTextColor(color)
    label:setLineBreakWithoutSpace(true)


    if color == CoreColor.WHITE and not params.back then
        params.back = CoreColor.BLACK
    end
    --描边
    if params.back then
        -- local backWidth = params.backWidth and params.backWidth > 2 and 2 or 2;
        -- label:enableStroke(params.back,backWidth);
        local backWidth = params.backWidth and params.backWidth > 2 and 2 or 1;
        label:enableOutline(params.back,backWidth)

    end

    if params.enableShadowColor then
        label:enableShadow(params.enableShadowColor,cc.size(0,-2))
    end

    return label;
end)

function UILabel:ctor(params)
    self.text = tostring(params.text) or ""
    self.font = params.font or NORMALFONT
    self.size = params.size or 20
    self.color = params.color or display.COLOR_WHITE
    self.alignX = params.x or ui.TEXT_ALIGN_LEFT
    self.alignY = params.y or ui.TEXT_VALIGN_CENTER
end

function UILabel:setText(text)
	self.text = string.utf8trim(tostring(text)) or self.text;
	self:setString(self.text);

end

function UILabel:getText()
    return self:getString()
end

function UILabel:getTextSize()
	return self.size;
end

function UILabel:setTextSize(textSize)
	self.size = textSize or self.size
	self:setFontSize(self.size)
end

function UILabel:setFontColor(color)
	self.color = color or CoreColor.WHITE
	self:enableGlow(self.color)
end


return UILabel




