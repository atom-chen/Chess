local WinManager = class("WinManager")

function WinManager:ctor()
	self.winList = {} -- 1为栈底，#self.winList为栈顶
	self.events = {}
end

function WinManager:addWin(win, type, _win, _cname, ...)
	local info = {window = win, _win = _win , cname = _cname, addType = type, other = {...}}
	local cnt = #self.winList
	local idx = (cnt + 1 - win.topOffset)
	if idx < 1 then
		idx = 1
	end
	table.insert(self.winList, idx, info)

	self:updateWindows()

	win:showWin()
end

function WinManager:removeWin(win)
	if bit.band(win.showType, WinShowType.canNotClose) > 0 then
		return
	end

	for idx = 1, #self.winList do
		if self.winList[idx].window == win then
			table.remove(self.winList, idx)
			break
		end
	end

	win:distory()
	self:updateWindows()
	self:handleWinReturnUpdate()
end

function WinManager:closeAllToWin(winName)
	local windows = {}
	for i = #self.winList, 1, -1 do
		table.insert(windows, self.winList[i].window)
	end

    for idx, win in ipairs(windows) do
        local name = win.__cname
        if winName == name then 
            break
        end

        CloseWin(win)
    end
end

function WinManager:closeAllWin()
	local windows = {}
	for i = #self.winList, 1, -1 do
		table.insert(windows, self.winList[i].window)
	end

	for idx, win in ipairs(windows) do
		self:removeWin(win)
	end
end

function WinManager:updateWindows()
	local fullScreen = false
	for idx = #self.winList, 1, -1 do
		local window = self.winList[idx].window
		window:setLocalZOrder(idx)

		if fullScreen then
			window:setVisible(false)
		else
			window:setVisible(true)
			if bit.band(window.showType, WinShowType.hiddenBack) > 0 then
				fullScreen = true
			end
		end
	end
	self:dispatchEventHandler(WinEventType.WIN_COUNT_CHANGE)
	self:dispatchEventHandler(WinEventType.BG_WIN_VISIBLE)
end

function WinManager:handleWinReturnUpdate()
	for i,v in ipairs(self.winList) do
		local win = v.window
		if win and win.returnUpdate and win:isVisible() then
	        win:returnUpdate()
	    end
	end
end

function WinManager:getTopWin()
	local cnt = #self.winList
	return cnt > 0 and self.winList[cnt].window or nil
end

function WinManager:isOpening(winName)
    for k,v in pairs(self.winList) do
        if v.window.__cname == winName then
            return true
        end
    end
    return false
end

function WinManager:isBgWinVisible()
	for i,v in ipairs(self.winList) do
		if bit.band(v.window.showType, WinShowType.backGround) > 0 and v.window:isVisible() then
			return true
		end
	end
	return false
end

function WinManager:findWinByName(winName)
	for k,v in pairs(self.winList) do
        if v.window.__cname == winName then
            return v.window
        end
    end
    return nil
end

function WinManager:registerEventHandler(event, handler)
	self.events[event] = handler
end

function WinManager:unregisterEventHandler(event)
	if event and self.events[event] then
		self.events[event] = nil
	end
end

function WinManager:dispatchEventHandler(event)
	local handler = self.events[event]
	if handler then 
		handler(self.winList)
	end
end

return WinManager
