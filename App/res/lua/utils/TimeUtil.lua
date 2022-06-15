local M = {}

function M.getLogoutDtStr(logout)
    local str = ""

    local second = os.time() - logout
    local min = math.floor(second / 60)
    local hours = math.floor(min / 60)
    local day = math.floor(hours / 24)
    if day < 1 then
        if hours < 1 then
            if min < 3 then
                str = "刚刚"
            else
                str = min .. "分钟前"
            end
        else
            str = hours .. "小时前"
        end
    elseif 7 < day then
        str = "大于7天"
    else
        str = day .. "天前"
    end

    return str
end

function M.getGameTime()
    return CS.UnityEngine.Time.time
end

TimeUtil = M