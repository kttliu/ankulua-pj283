--
-- Created by IntelliJ IDEA.
-- User: timothy
-- Date: 23/8/2018
-- Time: 0:10
-- To change this template use File | Settings | File Templates.
--
local mod_logger=  {}

------------------------------------
-- logger mode: Control level of information to log
-- 0 : None
-- 1: Info Only
-- 2: Debug
-- 3: Trace
------------------------------------
local logger_mode = 0
local now = os.time()
local now_str = os.date("%c", now)

local fileName = scriptPath() .. "logger.log"
local file
file = io.open(fileName, "w")
file:write("LOG Start: " .. now_str, "\n")

function mod_logger.set(msg)
    logger_mode = msg
end

function mod_logger.info(msg)
    if logger_mode >= 1 then
        toast(msg)
        write(msg)
    end
end

function mod_logger.debug(msg)
    if logger_mode >= 2 then
        write(msg)
    end
end

function mod_logger.trace(msg)
    if logger_mode >= 3 then
        write(msg)
        file:flush()
    end
end

function write(msg)
    local now = os.time()
    local now_str = os.date("%c", now)

    if(file == Nil) then
        init_log_file()
    end
    file:write(now_str .. " : " .. msg, "\n")
end

return mod_logger


