
local PlayerConfig = class("PlayerConfig")

local configFileName = "NormalConfig.lua"
local writablePath = cc.FileUtils:getInstance():getWritablePath()

function PlayerConfig:ctor()
    self.setting = {}
    if cc.FileUtils:getInstance():isFileExist(writablePath .. configFileName) then
        local file = dofile(writablePath .. configFileName)
        if file then
            for key, var in pairs(file) do
            	self.setting[key] = var
            end
        end
    end
end

local serialize = serialize
if not serialize then
    serialize = function (o)  
        local str_serialize = ""  
        if o == nil then  
            return "nil"
        end  
        if type(o) == "number" then  
            str_serialize = str_serialize..o  
        elseif type(o) == "string" then  
            str_serialize = str_serialize..string.format("%q", o)  
        elseif type(o) == "table" then  
            str_serialize = str_serialize.."{"  
            for k,v in pairs(o) do  
                str_serialize = str_serialize.." ["  
                str_serialize = str_serialize .. serialize(k)
                str_serialize = str_serialize.."] = "  
                str_serialize = str_serialize .. serialize(v)  
                str_serialize = str_serialize..","  
            end  
            str_serialize = str_serialize.."}"  
        elseif type(o) == "boolean" then  
            str_serialize = str_serialize..(o and "true" or "false")  
        elseif type(o) == "function" then  
            str_serialize = str_serialize.."function"  
        else  
            error("cannot serialize a " .. type(o))  
        end  
        return str_serialize
    end
end

function PlayerConfig:writeFile()
    local file = io.open(writablePath .. configFileName, "w+")
    if file then
        local content = "return " .. serialize(self.setting)
        file:write(content)
        file:close()
    end
end

function PlayerConfig:setSetting(name, value)
    self.setting[name] = value
    self:writeFile()
end

function PlayerConfig:getSetting(name,default)
    local data = self.setting[name]
    if data == nil or data == "" then data = default end
    return data
end

return PlayerConfig