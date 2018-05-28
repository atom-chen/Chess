local WzqAI = OpenFile("WzqAI")
local WzqChess = OpenFile("WzqChess")
local UIImageBox = OpenFile("UIImageBox")
local MoveLabel = OpenFile("MoveLabel")
local SceneBase = OpenFile("SceneBase")
local GoogleAdMobSDK = OpenFile("GoogleAdMobSDK")
local aiConfig = OpenConfig("aiConfig")
local cjson = require("quickjson")

local WzqScene = class("WzqScene", SceneBase)

function WzqScene:ctor(mode)
	WzqScene.super.ctor(self)
	self.chessList = {}
	self.gridList = {}
	self.white = true
	self.ai = nil
	self.playerMove = false
	self.playTimes = 0

	WzqEngine:getInstance():setCallback(function (result)
		unLockScreen()
		if result.code == 0 then
			self:doMove(result.x + 1, result.y + 1, not self.white)
		end
	end)

	playBackMusicFunc("floor.mp3")
end

function WzqScene:onEnter()
    self.backFrame = cc.CSLoader:createNode("wzq/wzq.csb")
    display.align(self.backFrame,display.CENTER,display.cx,display.cy)
    self:addChild(self.backFrame)
    self.backFrame:setScale(OverallScale)

    self.bg = self.backFrame:getChildByName("Panel_Bg")
    --初始化按钮
    local backBut = UIImageBox.new(self.bg:getChildByName("btnClose"),function()
		OpenScene("LoginScene")
    end, {playEffect = "ui/close.mp3"})

    local descBtn = UIImageBox.new(self.bg:getChildByName("btnInfo"),function()
        OpenWin("RulesWin", {tp = RULES_TYPE.Wzq})
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

	local board2 = self.bg:getChildByName("board2")
	for x = 1, 15 do
		self.gridList[x] = {}
		for y = 1, 15 do
			local grid = UIImageBox.new(board2:getChildByName(x .. "." .. y), function ()
				self:onClick(x, y)
			end)

			self.gridList[x][y] = grid
		end
	end
	self.selectSprite = board2:getChildByName("select")

	self.board = self.bg:getChildByName("board")

	local selectedAI = MyRandom:random(1, #aiConfig)
	self.ai = WzqAI.new(selectedAI)
	self.ai:setPosition(self.bg:getChildByName("player1"):getPosition())
	self.bg:addChild(self.ai)
end

function WzqScene:reset()
	self.board:removeAllChildren()
	self.chessList = {}
	self.stepList = {}
	self.selectedChess = nil
	if MyRandom:random(1, 2) == 1 then
		self.white = true
	else
		self.white = false
	end

	for i = 1, 15 do
		self.chessList[i] = {}
	end

	self.selectSprite:setVisible(false)
	self.startBtn:setEnabled(false)

	self.playerMove = true
	if not self.white then
		self.playerMove = false
		self:doAIMove()
	end
end

function WzqScene:onClick(x, y)
	if not self.playerMove then
		print("not player move")
		return
	end

	self:doMove(x, y, self.white)
end

function WzqScene:doMove(x, y, white)
	print("doMove : ", x, y, white)
	if self.chessList[x][y] then
		MoveLabel.new(WordDictionary[1301])
		return
	end

	local chess = WzqChess.new(x, y, white)
	chess:setPosition(self.gridList[x][y]:getPosition())
	self.board:addChild(chess)
	self:selectChess(chess)

	self.chessList[x][y] = chess

	lockScreen({})
	local result = self:checkResult(chess)
	if not result then
		self.playerMove = not self.playerMove
		print("playerMove : ", self.playerMove)
		if self.playerMove then
			unLockScreen()
		else
			self:doAIMove()
		end
	else
		local win = true
		if chess.white ~= self.white then
			win = false
		end

		print("result : ", win)
		local gold = 2000
		if win then
		else
			gold = -2000
		end
		GlobData:_ab_getGold(gold)
		self.ai:getGold(gold * -1)
		GlobData:_ab_save()
		self.coinLabel:setString(GlobData:_ab_getPlayerInfo().gold)

		OpenWin("WzqResultWin", self.ai:getName(), win, gold)

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
end

function WzqScene:selectChess(chess)
	self.selectSprite:setVisible(true)
	self.selectSprite:setPosition(chess:getPosition())
end

function WzqScene:doAIMove()
	local posList = {}
	for x = 1, 15 do
		for y = 1, 15 do
			local chess = self.chessList[x][y]
			if chess then
				table.insert(posList, {x = x - 1, y = y - 1, white = chess.white})
			end
		end
	end

	local aiwhite = 1
	if self.white then
		aiwhite = 0
	end


	lockScreen({})
	WzqEngine:getInstance():getMove(cjson.encode(posList), aiwhite)
end

local direction = {
	[1] = {
		[1] = {x = 1, y = 1},
		[2] = {x = -1, y = -1},
	},
	[2] = {
		[1] = {x = 1, y = -1},
		[2] = {x = -1, y = 1},
	},
	[3] = {
		[1] = {x = 0, y = 1},
		[2] = {x = 0, y = -1},
	},
	[4] = {
		[1] = {x = 1, y = 0},
		[2] = {x = -1, y = 0},
	},
}

function WzqScene:checkResult(chess)
	if chess then
		for i = 1, 4 do
			local max = 1
			for j = 1, 2 do
				local tempx = chess.x + direction[i][j].x
				local tempy = chess.y + direction[i][j].y
				while self.chessList[tempx] and self.chessList[tempx][tempy] and self.chessList[tempx][tempy].white == chess.white do
					max = max + 1
					tempx = tempx + direction[i][j].x
					tempy = tempy + direction[i][j].y
				end
			end

			if max >= 5 then
				return true
			end
		end
	end

	return false
end

function WzqScene:onExit()
	stopBackMusic()
end

return WzqScene