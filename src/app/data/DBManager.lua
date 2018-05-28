--SQLite数据库相关操作

local DBManager = {}

local sqlite3 = require("lsqlite3")
local dbName = nil
local db

--打开数据库
function DBManager.open()
	if not dbName or dbName == "" then
		local userId = GlobData.playerMgr.playerInfo.userID
		local writablePath = cc.FileUtils:getInstance():getWritablePath()
		local savePath = writablePath.."database/"
		cc.FileUtils:getInstance():createDirectory(savePath)--创建路径
		dbName = savePath.."chatdb_"..userId..".db"
	end

	db = sqlite3.open(dbName)
	if db then
		DBManager.create()
	else
		print("open database failed")
	end
end

--创建表
--chatRec  聊天记录表
function DBManager.create()
	db:exec[[
	  CREATE TABLE IF NOT EXISTS chatRec (
	    id		INTEGER PRIMARY KEY,
	    playerId	VARCHAR(80) NOT NULL,
	    recordId	INTEGER NOT NULL,
	    content	VARCHAR(200) NOT NULL,
	    time	INTEGER NOT NULL,
	    me	INTEGER NOT NULL
	  );
	]]
end

function DBManager.isOpen()
	if db then
		return db:isopen()
	else
		print("not fond database")
		return false
	end
end

--不可用
-- function DBManager.cleanTable()
-- 	db:exec[[
-- 		DROP TABLE chatRec;
-- 	]]
-- 	DBManager.create()
-- end

--插入playerId数据
function DBManager.insert(playerId,data)--recordId,content,time,me
	checkOpen()
	for k,v in pairs(data) do
		local stmt = assert( db:prepare("INSERT INTO chatRec VALUES (NULL, ?, ?, ?, ?, ?)") )
        stmt:bind_values(playerId,v.id,v.text,v.ts,v.me)
		stmt:step()
		stmt:reset()
    end
    DBManager.close()
end

--删除playerId的数据
function DBManager.delete(playerId)
	checkOpen()
	local stmt
	if playerId then
		stmt = assert( db:prepare("DELETE FROM chatRec WHERE playerId=?") )
		stmt:bind_values(playerId)
	else
		stmt = assert( db:prepare("DELETE FROM chatRec") )
	end
	stmt:step()
	stmt:reset()
	DBManager.close()
end

--更新数据库playerId记录
function DBManager.update(playerId,data)--recordId,content,time,me
	checkOpen()
	for k,v in pairs(data) do
		local stmt = assert( db:prepare("UPDATE chatRec SET recordId=?, content=?, time=?, me=? WHERE playerId=?") )
		stmt:bind_values(v.id,v.content,v.time,v.me,playerId)
		stmt:step()
		stmt:reset()
	end
	DBManager.close()
end

function DBManager.getFromChatId(playerId)
	checkOpen()
	local stmt = assert( db:prepare("SELECT recordId FROM chatRec WHERE playerId=? ORDER BY time DESC LIMIT 1") )
	stmt:bind_values(playerId)

	for row in stmt:nrows() do
		DBManager.close()
		return row.recordId or 0
	end
	DBManager.close()
	return 0
end

--查询playerId玩家的最近聊天记录(10条)
function DBManager.selectNearRecById(playerId)
	checkOpen()
	local stmt = assert( db:prepare("SELECT * FROM chatRec WHERE playerId=? ORDER BY time DESC LIMIT 10") )
	stmt:bind_values(playerId)

	return switchToTable(stmt)
end

--查询playerId玩家的聊天记录(默认一次查10条)
function DBManager.selectRecById(playerId,time)
	checkOpen()
	local stmt = assert( db:prepare("SELECT * FROM chatRec WHERE playerId=? and time<? ORDER BY time DESC LIMIT 10") )
	stmt:bind_values(playerId,time)

	return switchToTable(stmt)
end

--查询数据库
function DBManager.search()
	checkOpen()
	local stmt = assert( db:prepare("SELECT * FROM chatRec") )
	return switchToTable(stmt)
end

function checkOpen()
	if not db or (db and not db:isopen()) then
		DBManager.open()
	end
end

function switchToTable(stmt)
	local data = {}
	for row in stmt:nrows() do
		data[#data + 1] = row
  	end
  	--按照时间升级排列
  	table.sort(data,function(a,b)
    	return tonumber(a.time) < tonumber(b.time)
	end)
	DBManager.close()
  	return data
end

--关闭数据库
function DBManager.close()
	if db and db:isopen() then
		db.close(db)
	end
end

return DBManager