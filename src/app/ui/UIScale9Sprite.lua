local UIScale9Sprite = class("UIScale9Sprite", function(image, x, y, size,destroy) 
	if not destroy then
		return display.newScale9Sprite("#" .. image, x, y, size);
	else
		return display.newScale9Sprite(image, x, y, size);
	end
end)

return UIScale9Sprite