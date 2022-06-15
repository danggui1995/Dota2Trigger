
local M = {}

--满足与不满足的颜色
function M.toEnoughColor(isEnough,content)
    local color = isEnough and "#00a131" or "#ff0000"
    return string.format("[color=%s]%s[/color]",color,content),color
end

--已读与未读的颜色
function M.toReadColor(isReaded,content)
    local color = isReaded and "#6e6c7f" or "#3a3751"
    return string.format("[color=%s]%s[/color]",color,content),color
end

function M.numEnoughStr(format,have,need)
    local isEnough = have >= need
    local color = isEnough and "#00a131" or "#ff0000"
    return string.format(format,string.format("[color=%s]%s[/color]",color,have),need)
end

ColorUtil = M