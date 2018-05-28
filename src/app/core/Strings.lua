--字符串拼接效率
--a = os.clock()
--local s = ''
--for i = 1,300000 do
--    s = s .. 'a'
--end
--b = os.clock()
--print(b-a)  --46.834
--a = os.clock()
--local s = ''
--local t = {}
--for i = 1,300000 do
--    t[#t + 1] = 'a'
--end
--s = table.concat( t, '')
--b = os.clock()
--print(b-a)  --0.229
--拼接两个字符串
--s:add("b")
-- function string:add(s)
--     local tb = {}
--     tb[#tb + 1] = self
--     tb[#tb + 1] = s
--     return table.concat(tb, "")
-- end

function string.add(...)
    -- local t = {};
    -- for i = 1, arg['n'] do
    --     t[#t + 1] = arg[i];
    -- end
    local arg = {...};
    local t = {};
    for i = 1, #arg do
        t[#t + 1] = arg[i]
    end
    return table.concat(t, "");
end

-- 是否以某个字符串开头
-- 例子: local s = 'this is a test'
--       Log(s:beginWith('this')) -- 返回true
--       Log(s:beginWith('is')) -- 返回false
function string:beginWith(s)
    return self:sub(1, s:len()) == s
end

-- 是否以某个字符串结尾
-- 例子: local s = 'this is a test'
--       Log(s:endWith('this')) -- 返回false
--       Log(s:endWith('test')) -- 返回true
function string:endWith(tail)
    return self:sub(-tail:len()) == tail
end

-- 第一个字节
-- 例子: local s = 'xyz'
--       Log(s:head()) -- 返回'x'
function string:head()
    return self:sub(1, 1)
end

-- 最后一个字节
-- 例子: local s = 'xyz'
--       Log(s:head()) -- 返回'z'
function string:tail()
    return self:sub(-1)
end

-- 返回去掉第一个字符后的字符串
-- 例子: local s = 'xyz'
--       Log(s:popHead()) -- 返回'yz'
function string:popHead()
    return self:sub(2)
end

-- 返回去掉最后一个字符后的字符串
-- 例子: local s = 'xyz'
--       Log(s:popHead()) -- 返回'xy'
function string:popTail()
    return self:sub(1,self:len()-1)
end

---------------------------
--分割字符串 
--@param str string 目标字符串
--@param reps string 分割字符
--@return 分割后的数组
function string:split(reps)
    local resultStrsList = {}
    self:gsub('[^' .. reps ..']+', function(w) table.insert(resultStrsList, w) end )
    return resultStrsList
end

-- 切割成unicode
-- 返回列表
-- 例子: local s = "a到b中文ok"
--       Log(s:unicodeChars()) -- 返回{'a', '到', 'b', '中', '文', 'o', 'k'}
function string:unicodeChars()
    local tb = {}
    for uchar in self:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
        table.insert(tb,uchar)
    end
    return tb
end

-- 按指定长度插入分隔符
-- 返回列表
-- 例子: local s = "abc123ABC"
--       Log(s:insertPerLen(3, ",")) -- "abc,123,ABC,"
function string:insertPerLen(len, insertStr)
    local s = self
    local arr = {}
    while s:len() >= len do
        table.insert(arr,s:sub(1, len))
        s = s:sub(len + 1)
    end
    return table.concat(arr, insertStr)
end
-- 返回utf8长度
function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end
-- utf8截取字符串
function string.utf8sub(str, startChar, numChars)
    -- 判断utf8字符byte长度
    -- 0xxxxxxx - 1 byte
    -- 110yxxxx - 192, 2 byte
    -- 1110yyyy - 225, 3 byte
    -- 11110zzz - 240, 4 byte
    local function chsize(char)
        if not char then
            print("not char")
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end

    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end