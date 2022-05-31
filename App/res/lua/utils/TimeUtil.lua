---@class TimeUtil
local M = {}

-- 年月日计算星期几
function M.getWhatDay(y, m, d)
    local w = (d + 2 * m + 3 * (m + 1) / 5 + y + y / 4 - y / 100 + y / 400) % 7
    return w
end

function M.getLogoutDtStr(logout)
    local str = ""

    local second = os.time() - logout
    local min = math.floor(second / 60)
    local hours = math.floor(min / 60)
    local day = math.floor(hours / 24)
    if day < 1 then
        if hours < 1 then
            if min < 3 then
                str = "刚刚" -- Language.getString(150031) -- "刚刚"
            else
                str = min .. "分钟前" -- min..Language.getString(150032) -- "分钟前"
            end
        else
            str = hours .. "小时前" --Language.getString(150033) -- "小时前"
        end
    elseif 7 < day then
        str = "大于7天" -- Language.getString(150034) -- "大于7天"
    else
        str = day .. "天前" -- Language.getString(150035) -- "天前"
    end

    return str
end

-- xx:xx:xx的格式化
function M.formatTime(seconds)
    seconds = math.max(0, seconds)
    local hour = math.floor(seconds / 3600)
    hour = hour < 10 and ("0" .. hour) or hour
    local min = math.floor(seconds % 3600 / 60)
    min = min < 10 and ("0" .. min) or min
    local sec = math.floor(seconds % 60)
    sec = sec < 10 and ("0" .. sec) or sec

    return hour .. ":" .. min .. ":" .. sec
end

--秒转化为时间,天，小时， 分
function M.getTime(value)
    --秒
    local v = tonumber(value)
    local day, hour, min, sec = 0, 0, 0, 0
    if v and v >= 0 then
        day = math.floor(v / 86400)
        hour = math.floor((value - day * 86400) / 3600)
        min = math.floor((value - day * 86400 - hour * 3600) / 60)
        sec = value - day * 86400 - hour * 3600 - min * 60
    end
    return day, hour, min, sec
end

--秒转化为 时-分
function M.getHourTime(value)
    --秒
    local v = tonumber(value)
    local hour, min= 0, 0
    if v and v >= 0 then
        hour = math.floor(v / 3600)
        min = math.floor((v - hour * 3600) / 60)
    end
    return hour, min
end

-- 剩余时间 转换 天-时-分-秒
function M.getChineseTime(value, space, ignoreMin, ignoreSec)
    local day, hour, min, sec = M.getTime(value)
    space = space or string.empty

    local str = ""
    if day > 0 then
        str = str .. day .. Language.getString(100110) .. space
    end
    if hour > 0 then
        str = str .. hour .. Language.getString(100111) .. space
    end
    -- 省略秒的时候,最低一分钟
    if ignoreSec and min < 1 and sec >= 1 then
        min = 1
    end
    if not ignoreMin and min >= 1 then
        str = str .. min .. Language.getString(100112) .. space
    end
    if not ignoreSec and sec >= 1 then
        str = str .. sec .. Language.getString(100113)
    end
    return str
end

function M.transWarehouseTime(value)
    -- 显示 d-h-m
    local day, hour, min, sec = M.getTime(value)

    if day > 3 then
        return string.format("%dday", day)
    elseif day > 0 then
        return string.format("%dh", hour + day * 24)
    elseif hour > 0 then
        return string.format("%dh", hour)
    elseif min > 0 then
        return string.format("%dmin", min)
    else 
        return Language.getString(101006)
    end
    return ""
end


function M.transTime(time)
    local day = math.floor(time / 3600 / 24)
    local hour = math.floor(time / 3600 % 24)
    local min = math.floor(time / 60 % 60)
    local sec = math.floor(time % 60)
    return day, hour, min, sec
end

function M.transTimeText(time)
    local a, b, c, d = M.transTime(time)
    local aText = ""
    local bText = ""
    local cText = ""
    local dText = ""
    if a > 0 then
        aText = a .. "天"
    end
    if b > 0 then
        bText = b .. "小时"
    end
    if c > 0 then
        cText = c .. "分"
    end
    if true or d > 0 then
        dText = d .. "秒"
    end
    return string.format("%s%s%s%s", aText, bText, cText, dText)
end
---09:00:00转换成多少秒
function M.transTimeStrToSeconds(str)
    local tb = string.split(str,":")
    local h = tonumber(tb[1])
    local m = tonumber(tb[2])
    local s = tonumber(tb[3])
    return h*3600 + m*60 + s
end

function M.getGameTime()
    return CS.UnityEngine.Time.time
end

TimeUtil = M