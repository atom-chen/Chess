local CChessAI = OpenFile("CChessAI")
local CChess = OpenFile("CChess")
local UISprite = OpenFile("UISprite")
local UILabel = OpenFile("UILabel")
local UIImageBox = OpenFile("UIImageBox")
local MoveLabel = OpenFile("MoveLabel")
local SceneBase = OpenFile("SceneBase")
local GoogleAdMobSDK = OpenFile("GoogleAdMobSDK")
local aiConfig = OpenConfig("aiConfig")
local chinesechessConf = OpenConfig("chinesechessConf")
local cjson = require("quickjson")

-- --创建一个类
-- --记录每走一步棋的信息
-- class Step : public CCObject
--     int _moveid;--需要移动的棋子的id
--     int _killid;--通过触摸点的位置判断触摸点上是否有棋子
--     int _xFrom; --棋子当前的位置的x坐标
--     int _yFrom; --棋子当前的位置的y坐标
--     int _xTo;   --棋子移动后的位置的x坐标
--     int _yTo;   --棋子移动后的位置的y坐标
-- };

local CChessScene = class("CChessScene", SceneBase)

function CChessScene:ctor(mode)
	CChessScene.super.ctor(self)
	self.mode = mode or 1 -- 1是简单模式，2是普通模式，3是困难模式
	self.playerChessList = {}
	self.aiChessList = {}
	self.stepList = {}
	self.gridList = {}
	self.red = true
	self.ai = nil
	self.selectedChess = nil
	self.playerMove = true
	self.playTimes = 0
	playBackMusicFunc("floor.mp3")

	CChessEngine:getInstance():setCallback(function (result)
		unLockScreen()
		print_r(result)
		if result.code == 0 then
			local targetChess = self:getChessByPos(9 - result.startX, 10 - result.startY)
			if targetChess then
				self:moveChess(targetChess, 9 - result.endX, 10 - result.endY)
			else
				print("not find ai chess : ", 9 - result.startX, 10 - result.startY)
			end
		end
	end)

	if self.mode == 1 then
		CChessEngine:getInstance():changeEngine(0)
	elseif self.mode == 2 then
		CChessEngine:getInstance():changeEngine(2)
	elseif self.mode == 3 then
		CChessEngine:getInstance():changeEngine(7)
	end
end

function CChessScene:onEnter()
    self.backFrame = cc.CSLoader:createNode("chinesechess/cchess.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    self.bg = self.backFrame:getChildByName("Panel_Bg")
    --初始化按钮
    local backBut = UIImageBox.new(self.bg:getChildByName("btnClose"),function()
		OpenScene("LoginScene")
    end, {playEffect = "ui/close.mp3"})

    local descBtn = UIImageBox.new(self.bg:getChildByName("btnInfo"),function()
        OpenWin("RulesWin", {tp = RULES_TYPE.ChineseChess})
    end)

	self.coinLabel = self.bg:getChildByName("coin")
	self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)

	self.add = UIImageBox.new(self.bg:getChildByName("add"), function (me)
		local playerInfo = GlobData:_ab_getPlayerInfo()
		if playerInfo.freeBuy > 0 then
			playerInfo:_ab_getGold(MyRandom:random(50, 100) * 100)
			playerInfo:_ab_useFreeBuy()
			GlobData:_ab_save()
			self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)
		else
			OpenWin("Notice", WordDictionary[1004], function (result)
				if result then
					pauseBackMusic()
					GoogleAdMobSDK:_ab_showReward(function (ret)
						if ret.code == 0 then
							GlobData:_ab_getGold(10000)
	    					GlobData:_ab_save()
							self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)
						else
							MoveLabel.create(WordDictionary[100003])
						end
						resumeBackMusic()
					end)
				end
			end)
		end
	end)

	self.startBtn = UIImageBox.new(self.bg:getChildByName("btnStart"), function (me)
		self:reset()
	end, {textParams = {text = WordDictionary[1001], size = 24}})

	-- self.regretBtn = UIImageBox.new(self.bg:getChildByName("btnRegret"), function (me)
	-- 	self:regret()
	-- end, {textParams = {text = WordDictionary[1201], size = 24}})

	local board2 = self.bg:getChildByName("board2")
	for x = 1, 9 do
		self.gridList[x] = {}
		for y = 1, 10 do
			local grid = UIImageBox.new(board2:getChildByName(x .. "." .. y), function ()
				self:onClick(x, y)
			end)

			self.gridList[x][y] = grid
		end
	end
	self.selectSprite = board2:getChildByName("select")

	self.board = self.bg:getChildByName("board")
	self.ListView = self.bg:getChildByName("ListView")

	local selectedAI = MyRandom:random(1, #aiConfig)
	while aiConfig[selectedAI].difficulty ~= self.mode do
		selectedAI = MyRandom:random(1, #aiConfig)
	end

	self.ai = CChessAI.new(selectedAI)
	self.ai:setPosition(self.bg:getChildByName("player1"):getPosition())
	self.bg:addChild(self.ai)
end

function CChessScene:reset()
	self.ListView:removeAllItems()
	self.board:removeAllChildren()
	self.playerChessList = {}
	self.aiChessList = {}
	self.stepList = {}
	self.selectedChess = nil
	if MyRandom:random(1, 2) == 1 then
		self.red = true
	else
		self.red = false
	end

	for i, v in ipairs(chinesechessConf) do
		local chess1 = CChess.new(v, self.red)
		chess1:setPosition(self.gridList[chess1.x][chess1.y]:getPosition())
		self.board:addChild(chess1)
		table.insert(self.playerChessList, chess1)

		local chess2 = CChess.new(v, not self.red)
		chess2.y = 11 - chess2.y
		chess2:setPosition(self.gridList[chess2.x][chess2.y]:getPosition())
		self.board:addChild(chess2)
		table.insert(self.aiChessList, chess2)
	end

	self.selectSprite:setVisible(false)
	self.startBtn:setEnabled(false)

	if not self.red then
		self.playerMove = false
		self:doAIMove()
	end
end

function CChessScene:regret()
	if #self.stepList < 2 then
		return false
	end

	lockScreen({})
	for i = 1, 2 do
		local step = self.stepList[#self.stepList]
		local moveChess = self.playerChessList[step.id]
		if not step.isSelf then
			moveChess = self.aiChessList[step.id]
		end

		local killChess
		if self.killid then
			moveChess = self.aiChessList[step.id]
			if not step.isSelf then
				moveChess = self.playerChessList[step.id]
			end
		end

		moveChess.x = step.startX
		moveChess.y = step.startY

		local move = cc.MoveTo:create(0.5, cc.p(self.gridList[step.startX][step.startY]:getPosition()))
		local call = cc.CallFunc:create(function ()
			if killChess then
				killChess:setVisible(true)
				killChess.dead = false
			end

			if i == 2 then
				unLockScreen()
			end
		end)
		moveChess:runAction(cc.Sequence:create(move, call))
		table.remove(self.stepList, #self.stepList)
	end
end

function CChessScene:onClick(x, y)
	if not self.playerMove then
		print("not player move")
		return
	end

	if self.selectedChess then
		if x ~= self.selectedChess.x or y ~= self.selectedChess.y then
			self:moveChess(self.selectedChess, x, y)
		end
	else
		for i, v in ipairs(self.playerChessList) do
			if v.x == x and v.y == y then
				self:selectChess(v)
				break
			end
		end
	end
end

function CChessScene:selectChess(chess)
	self.selectedChess = chess
	self.selectSprite:setVisible(true)
	self.selectSprite:setPosition(chess:getPosition())
end

function CChessScene:getChessByPos(x, y)
	for i, v in ipairs(self.playerChessList) do
		if v.x == x and v.y == y and not v.dead then
			return v
		end
	end

	for i, v in ipairs(self.aiChessList) do
		if v.x == x and v.y == y and not v.dead then
			return v
		end
	end
end

function CChessScene:moveChess(chess, x, y)
	local targetChess = self:getChessByPos(x, y)
	if targetChess and targetChess.red == chess.red then
		self:selectChess(targetChess)
		print("pos has same side chess : ", chess.red, chess.x, chess.y, x, y)
		return false
	end

	if not self:canMove(chess, x, y) then
		print("can not move : ", chess.red, chess.x, chess.y, x , y)
		return false
	end

	local step = {
		isSelf = (chess.red == self.red),
		id = chess.id,
		killid = (targetChess and targetChess.id),
		startX = chess.x,
		startY = chess.y,
		endX = x,
		endY = y,
	}
	table.insert(self.stepList, step)
	chess.x = x
	chess.y = y

	lockScreen({})
	local move = cc.MoveTo:create(0.5, cc.p(self.gridList[x][y]:getPosition()))
	local call = cc.CallFunc:create(function ()
		if targetChess then
			targetChess:setVisible(false)
			targetChess.dead = true
		end

		local str = self:getMoveStr(chess, step.startX, step.startY, step.endX, step.endY)
		self.ListView:pushBackCustomItem(UILabel.new({
            text = str,
            size = 20,
            color = CoreColor.WHITE,
            back = CoreColor.BLACK_191,
            font = SPECIALFONT,
        }))
        self.ListView:jumpToBottom()

		self.selectedChess = nil
		self.selectSprite:setVisible(false)
		local result = self:checkResult(targetChess)
		if result == 0 then
			self.playerMove = not self.playerMove
			print("playerMove : ", self.playerMove)
			if self.playerMove then
				unLockScreen()
			else
				self:doAIMove()
			end
		else
			print("result : ", result)
			local gold = 2000
			if result == 1 then
			else
				gold = -2000
			end
			GlobData:_ab_getGold(gold)
			self.ai:getGold(gold * -1)
			GlobData:_ab_save()
			self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)

			OpenWin("CChessResultWin", self.ai:getName(), result, gold)

			self.playTimes = self.playTimes + 1
			if self.playTimes >= 3 then
				self.playTimes = 0
				pauseBackMusic()
				GoogleAdMobSDK:_ab_showPage(function (ret)
					resumeBackMusic()
				end)
			end

			self.playerMove = false
			self.startBtn:setEnabled(true)
			unLockScreen()
		end
	end)
	chess:runAction(cc.Sequence:create(move, call))
end

function CChessScene:canMove(chess, x, y)
	if chess.cType == CChessType.JIANG then
		return self:canMoveJiang(chess, x, y)
	elseif chess.cType == CChessType.SHI then
		return self:canMoveShi(chess, x, y)
	elseif chess.cType == CChessType.XIANG then
		return self:canMoveXiang(chess, x, y)
	elseif chess.cType == CChessType.MA then
		return self:canMoveMa(chess, x, y)
	elseif chess.cType == CChessType.JU then
		return self:canMoveJu(chess, x, y)
	elseif chess.cType == CChessType.PAO then
		return self:canMovePao(chess, x, y)
	elseif chess.cType == CChessType.BING then
		return self:canMoveBing(chess, x, y)
	end
end

function CChessScene:canMoveJiang(chess, x, y)
    --将的走棋规则：
    --1、一次走一格
    --2、不能出九宫格
    --3、将对杀

	local targetChess = self:getChessByPos(x, y)
	if targetChess and targetChess.cType == CChessType.JIANG and targetChess.red ~= chess.red then
		return self:canMoveJu(chess, x, y)
	end

	if math.abs(x - chess.x) + math.abs(y - chess.y) ~= 1 then
		return false
	end

	local rect1 = cc.rect(4, 1, 2, 2)
	local rect2 = cc.rect(4, 8, 2, 2)
	local endPos = cc.p(x, y)
	if cc.rectContainsPoint(rect1, endPos) or cc.rectContainsPoint(rect2, endPos) then
		return true
	end

	return false
end

function CChessScene:canMoveShi(chess, x, y)
    --士的走棋规则：
    --1、一次走一格
    --2、不能出九宫格
	--3、斜着走

	if math.abs(x - chess.x) ~= 1 or math.abs(y - chess.y) ~= 1 then
		return false
	end

	local rect1 = cc.rect(4, 1, 2, 2)
	local rect2 = cc.rect(4, 8, 2, 2)
	local endPos = cc.p(x, y)
	if cc.rectContainsPoint(rect1, endPos) or cc.rectContainsPoint(rect2, endPos) then
		return true
	end

	return false
end

function CChessScene:canMoveXiang(chess, x, y)
    --相的走棋规则：
    --每走一次x移动2格,y移动2格
    --不能过河

	if math.abs(x - chess.x) ~= 2 or math.abs(y - chess.y) ~= 2 then
		return false
	end

	if chess.red == self.red then
		if y >= 6 then
			return false
		end
	else
		if y <= 5 then
			return false
		end
	end

	return true
end

function CChessScene:canMoveMa(chess, x, y)
    --马有两种情况：
    --第一种情况：马先向前或向后走1步，再向左或向右走2步
    --第二种情况：马先向左或向右走1不，再向前或向后走2步

	if (math.abs(x - chess.x) == 2 and math.abs(y - chess.y) == 1) or (math.abs(x - chess.x) == 1 and math.abs(y - chess.y) == 2) then
		local xm = chess.x
		local ym = chess.y
		if math.abs(x - chess.x) == 1 then
			ym = (y + chess.y) / 2
		elseif math.abs(y - chess.y) == 1 then
			xm = (x + chess.x) / 2
		end

		if not self:getChessByPos(xm, ym) then
			return true
		end
	end

	return false
end

function CChessScene:canMoveJu(chess, x, y)
	--车走直线

	local count = self:getChessCountBetween(chess.x, chess.y, x, y)
	if count == 0 then
		return true
	end

	return false
end

function CChessScene:canMovePao(chess, x, y)
	--炮走直线
    --当触摸点上有一个棋子
    --而且两点之间只有一个棋子的时候
    --炮吃掉触摸点上的棋子

	local targetChess = self:getChessByPos(x, y)
	if targetChess and self:getChessCountBetween(chess.x, chess.y, x, y) == 1 then
		return true
	end

	if targetChess == nil and self:getChessCountBetween(chess.x, chess.y, x, y) == 0 then
		return true
	end

	return false
end

function CChessScene:canMoveBing(chess, x, y)
    --兵的走棋规则：
    --1、一次走一格
    --2、前进一格后不能后退
    --3、过河后才可以左右移动

	if math.abs(x - chess.x) + math.abs(y - chess.y) ~= 1 then
		return false
	end

	if chess.red == self.red then
		if y < chess.y then
			return false
		end

		if y <= 5 and y == chess.y then
			return false
		end
	else
		if y > chess.y then
			return false
		end

		if y >= 6 and y == chess.y then
			return false
		end
	end

	return true
end

function CChessScene:getChessCountBetween(startX, startY, endX, endY)
	local count = -1
	if startX ~= endX and startY ~= endY then
		return count
	end

	if startX == endX and startY == endY then
		return count
	end

	count = 0
	if startX == endX then
		local min = math.min(startY, endY)
		local max = math.max(startY, endY)
		for i = min + 1, max - 1 do
			if self:getChessByPos(startX, i) then
				count = count + 1
			end
		end
	else
		local min = math.min(startX, endX)
		local max = math.max(startX, endX)
		for i = min + 1, max - 1 do
			if self:getChessByPos(i, startY) then
				count = count + 1
			end
		end
	end

	return count
end

function CChessScene:doAIMove()
	local posList = {}
	local addPlayer = 0
	local addAi = 0
	if self.red then
		addPlayer = 7
	else
		addAi = 7
	end

	for i,v in ipairs(self.playerChessList) do
		if not v.dead then
			table.insert(posList, {x = 9 - v.x, y = 10 - v.y, id = v.cType + addPlayer})
		end
	end

	for i,v in ipairs(self.aiChessList) do
		if not v.dead then
			table.insert(posList, {x = 9 - v.x, y = 10 - v.y, id = v.cType + addAi})
		end
	end

	local selfred = 1
	if self.red then
		selfred = 2
	end


	lockScreen({})
	CChessEngine:getInstance():getMove(cjson.encode(posList), selfred)
end

function CChessScene:checkResult(chess)
	local finish = 0
	if chess then
		if chess.cType == CChessType.JIANG then
			if chess.red == self.red then		--输了
				finish = 2
			else
				finish = 1
			end
		end
	end

	return finish
end

function CChessScene:getMoveStr(chess, startX, startY, endX, endY)
    local str = WordDictionary[1203] .. " : "
    if chess.red then
        str = WordDictionary[1204] .. " : "
    end

    if chess.cType == CChessType.JIANG then
        if chess.red then
            str = str .. WordDictionary[1212]
        else
            str = str .. WordDictionary[1205]
        end

        if startY == endY then
            str = str .. startX .. WordDictionary[1216] .. endX
        elseif startY > endY and chess.red == self.red then
            if chess.red == self.red then
                str = str .. startX .. WordDictionary[1217] .. (startY - endY)
            else
                str = str .. startX .. WordDictionary[1218] .. (startY - endY)
            end
        elseif startY < endY and chess.red == self.red then
            if chess.red == self.red then
                str = str .. startX .. WordDictionary[1218] .. (endY - startY)
            else
                str = str .. startX .. WordDictionary[1217] .. (endY - startY)
            end
        end
    elseif chess.cType == CChessType.SHI then
        str = str .. WordDictionary[1206]
    elseif chess.cType == CChessType.XIANG then
        str = str .. WordDictionary[1207]
    elseif chess.cType == CChessType.MA then
        str = str .. WordDictionary[1208]
    elseif chess.cType == CChessType.JU then
        str = str .. WordDictionary[1209]
    elseif chess.cType == CChessType.PAO then
        str = str .. WordDictionary[1210]
    elseif chess.cType == CChessType.BING then
        if chess.red then
            str = str .. WordDictionary[1213]
        else
            str = str .. WordDictionary[1211]
        end
    end
    
    if startY == endY then
        str = str .. startX .. WordDictionary[1216] .. endX
    elseif startY > endY then
        if chess.red ~= self.red then
            str = str .. startX .. WordDictionary[1217] .. (startY - endY)
        else
            str = str .. startX .. WordDictionary[1218] .. (startY - endY)
        end
    elseif startY < endY then
        if chess.red ~= self.red then
            str = str .. startX .. WordDictionary[1218] .. (endY - startY)
        else
            str = str .. startX .. WordDictionary[1217] .. (endY - startY)
        end
    end

    return str
end

function CChessScene:onExit()
	stopBackMusic()
end

return CChessScene