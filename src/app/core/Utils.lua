--工具类
function log(tag, fmt, ...)
    local t = {
        "[",
        tostring(tag),
        "] ",
        string.format(tostring(fmt), ...)
    }
    if tag == "ERROR" then
        table.insert(t, debug.traceback("", 2))
    end
    print(table.concat(t))
end

function loge(fmt, ...)
    log("ERROR", fmt, ...)
end

function logd(fmt, ...)
    if DEBUG < 3 then return end
    log("DEBUG", fmt, ...)
end

function logi(fmt, ...)
    if DEBUG < 2 then return end
    log("INFO", fmt, ...)
end

function logw(fmt, ...)
    if DEBUG < 1 then return end
    log("WARN", fmt, ...)
end

function print_lua_table(sth)

    if DEBUG < 3 then return end

    if type(sth) ~= "table" then
        if sth == nil then
            logd('table->nil')
        else
            logd('table->',sth)
        end
        return
    end

    local space, deep = string.rep(' ', 1), 0
    local function _dump(t)
        local xxx = t.xxx
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)

            if type(v) == "table" then
                deep = deep + 2
                logd(string.format("%s[%s]={%s",string.rep(space, deep - 1),key,string.rep(space, deep))) --print.
                _dump(v)
                logd(string.format("%s}",string.rep(space, deep)))
                deep = deep - 2
            elseif type(v) == 'string' then
                if string.len(v) < 500 then
                    logd(string.format('%s[%s]="%s"',string.rep(space, deep + 1),key,v)) --print.
                else
                    logd(string.format('%s[%s]="%s"',string.rep(space, deep + 1),key,"size > 500")) --print.
                end
            else
                logd(string.format("%s[%s]=%s",string.rep(space, deep + 1),key,tostring(v))) --print.
            end
        end
    end
    logd(string.format("table->{"))
    _dump(sth)
    logd(string.format("}"))
end