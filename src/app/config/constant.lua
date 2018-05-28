
WinShowType = {
    backGround = 1,
    normal = 2, --普通显示的
    hiddenBack = 4, --隐藏遮挡的
    canNotClose = 8, --不能关闭的
    hasAction = 16, --已有动画的
}

AddWinType = {
    normal = 1, --普通的加到最上面
    raplace = 2, -- 顶替掉最上面的界面
}

WinCoverEventType = {
    cover = 1,
    uncover = 2,
}

WinEventType = {
    WIN_COUNT_CHANGE = 1,--窗口数量变化
    BG_WIN_VISIBLE = 2,--background win显示状态
}

CardColor = {
    RedKing = 1,            --大王
    BlackKing = 2,          --小王
    Spade = 3,              --黑桃
    Heart = 4,              --红桃
    Clu = 5,                --梅花
    Diamond = 6,            --方片
}

RULES_TYPE = {
    Baccarat = 1,           --百家乐
    Doudizhu = 2,           --斗地主
    ChineseChess = 3,       --中国象棋
    Wzq = 4,                --五子棋
}

--Player闲家
--Banker庄家
BJLBetType = {
	PlayerWin = 1,			--闲赢
	Tie = 2,				--平局
	BankerWin = 3,			--庄赢
	PlayerKing = 4,			--闲天王
	BankerKing = 5,			--庄天王
	TieSame = 6,			--平局同点
	PlayerDouble = 7,		--闲对子
	BankerDouble = 8,		--庄对子
}

DDZRound = {
    Player1 = 1,
    Player2 = 2,
    Player3 = 3,
}

DDZDealType = {
    None = 0,               --没人出牌，该当前玩家先出牌
    SINGLE_CARD = 1,            --单牌-
    DOUBLE_CARD = 2,            --对子-
    THREE_CARD = 3,             --3不带-
    BOMB_CARD = 4,              --炸弹
    THREE_ONE_CARD = 5,         --3带1-
    THREE_TWO_CARD = 6,         --3带2-
    BOMB_TWO_CARD = 7,          --四个带2张单牌
    BOMB_TWOOO_CARD = 8,        --四个带2对
    CONNECT_CARD = 9,           --连牌-
    COMPANY_CARD = 10,           --连对-
    AIRCRAFT_CARD = 11,          --飞机不带-
    AIRCRAFT_SINGLE_CARD = 12,   --飞机带单牌-
    AIRCRAFT_DOBULE_CARD = 13,   --飞机带对子-
    KING_BOMB = 14,              --王炸
    ERROR_CARD = 15,              --错误的牌型
}

CChessType = {
    JIANG = 1,      --将
    SHI = 2,        --士
    XIANG = 3,      --象
    MA = 4,         --马
    JU = 5,         --车
    PAO = 6,        --炮
    BING = 7,       --兵
}