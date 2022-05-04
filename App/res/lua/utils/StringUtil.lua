---@class StringUtil
local M = {}

--[[
字符串相关
]]


function M.filterString(s)
    return CSharp.FilterUtil.FilterString(s)
end

function M.containsInvalidChar(s)
    return CSharp.FilterUtil.ContainsInvalidChar(s)
end

-- keepRadix 是否保留小数点
function M.numToString(num, keepRadix, radixNum)
    if not num or type(num) ~= 'number' then
        return ""
    end
    if keepRadix then
        local ext = ""
        radixNum = radixNum or 2
        local radix = (1 / math.pow(10, radixNum))
        if num >= 100000000 then
            num = num / 100000000
            num = num - num % radix
            ext = Language.getString(114)--亿
        elseif num >= 10000 then
            num = num / 10000
            num = num - num % radix
            ext = Language.getString(113)--万
        end
        return num .. ext
    else
        local showText = tostring(num)
        if string.len(showText) >= 9 then
            showText = string.sub(showText, 1, -9)
            showText = showText .. Language.getString(114)
        elseif string.len(showText) >= 5 then
            showText = string.sub(showText, 1, -5)
            showText = showText .. Language.getString(113)
        end
        return showText
    end
end

--[[
    获取数字对应中文字符串(目前可以转换0 ~ 99999)
    @example    getChineseNumString(10034) return  "一万零三十四"
--]]
function M.getChineseNumString(number)
    local zero = 100000
    local ten = 100010
    local result = ""
    if number == 0 then
        result = Language.getString(zero)
        return result
    end
    local i = 1             --数位记录
    local pre0 = false      --上一位是否是0
    local temp0 = false     --缓存字符零
    local temp1 = false     --缓存字符一
    while (number ~= 0) do
        local n = number % 10    --当前位数字
        --个位
        if i == 1 then
            if n ~= 0 then
                result = Language.getString(zero + n)
            else
                pre0 = true
            end
            --十位
        elseif i == 2 then
            if n == 0 then
                if not pre0 then
                    temp0 = Language.getString(zero)
                end
                pre0 = true
            elseif n == 1 then
                temp1 = Language.getString(zero + 1)
                result = string.format("%s%s", Language.getString(ten), result)
                pre0 = false
            else
                result = string.format("%s%s%s", Language.getString(zero + n), Language.getString(ten), result)
                pre0 = false
            end
            --其他位
        else
            if n == 0 then
                if not pre0 then
                    temp0 = Language.getString(zero)
                end
                if temp1 then
                    result = string.format("%s%s", Language.getString(zero + 1), result)
                    temp1 = false
                end
                pre0 = true
            else
                if temp0 then
                    result = string.format("%s%s", Language.getString(zero), result)
                    temp0 = false
                end
                if temp1 then
                    result = string.format("%s%s", Language.getString(zero + 1), result)
                    temp1 = false
                end
                result = string.format("%s%s%s", Language.getString(zero + n), Language.getString(ten + i - 2), result)
                pre0 = false
            end
        end
        number = math.floor(number / 10)
        i = i + 1
    end
    return result
end


--格式化大数值  >=10000 万  100000000 亿
function M.formatLargeNumToSting(value)
    if type(value) ~= "number" then
        return
    end
    local result = 0
    local strResult = value
    if value >= 1000000000000 then
        result = math.floor((value / 1000000000000 * 100)) * 0.01 -- %.2f万亿
        strResult = result .. "万亿"
    elseif value >= 100000000 then
        result = math.floor((value / 100000000 * 100)) * 0.01 -- %.2f亿
        strResult = result .. "亿"
    elseif value >= 10000 then
        result = math.floor((value / 10000 * 100)) * 0.01 -- %.2f万
        strResult = result .. "万"
    end
    return strResult
end

--[[将str的第一个字符转化为大写字符。成功返回转换后的字符串，失败返回nil和失败信息]]
function M.capitalize(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local ch = string.sub(str, 1, 1)
    local len = string.len(str)
    if ch < 'a' or ch > 'z' then
        return str
    end
    ch = string.char(string.byte(ch) - 32)
    if len == 1 then
        return ch
    else
        return ch .. string.sub(str, 2, len)
    end
end

--[[将str的第一个字符转化为小写字符。成功返回转换后的字符串，失败返回nil和失败信息]]
function M.lowercase(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local ch = string.sub(str, 1, 1)
    local len = string.len(str)
    if ch < 'A' or ch > 'Z' then
        return str
    end
    ch = string.char(string.byte(ch) + 32)
    if len == 1 then
        return ch
    else
        return ch .. string.sub(str, 2, len)
    end
end

local _chnNum
local function getChnNumTb()
    if not _chnNum then
        _chnNum = {
            [0] = Language.getString(100000),
            [1] = Language.getString(100001),
            [2] = Language.getString(100002),
            [3] = Language.getString(100003),
            [4] = Language.getString(100004),
            [5] = Language.getString(100005),
            [6] = Language.getString(100006),
            [7] = Language.getString(100007),
            [8] = Language.getString(100008),
            [9] = Language.getString(100009),
            [10] = Language.getString(100010),
            [100] = Language.getString(100011),
        }
    end
    return _chnNum
end

function M.formatMemory(bitSize, withSuffix)
    local kSize = bitSize / 1024
    if kSize < 1 then
        return string.format("%s%s", tostring(bitSize), (withSuffix and "B" or ""))
    end

    local mSize = kSize / 1024
    if mSize < 1 then
        return string.format("%0.2f%s", kSize, (withSuffix and "K" or ""))
    end

    local gSize = mSize / 1024
    if gSize < 1 then
        return string.format("%0.2f%s", mSize, (withSuffix and "M" or ""))
    end

    return string.format("%0.2f%s", gSize, (withSuffix and "G" or ""))
end

function M.formatMemoryProgress(curBitSize, totalBitSize)
    local kSize0 = curBitSize / 1024
    local kSize1 = totalBitSize / 1024
    if kSize1 < 1 then
        return string.format("%s/%s", tostring(curBitSize), tostring(totalBitSize)) .. "B"
    end

    local mSize0 = kSize0 / 1024
    local mSize1 = kSize1 / 1024
    if mSize1 < 1 then
        return string.format("%0.2f/%0.2f", kSize0, kSize1) .. "K"
    end

    local gSize0 = mSize0 / 1024
    local gSize1 = mSize1 / 1024
    if gSize1 < 1 then
        return string.format("%0.2f/%0.2f", mSize0, mSize1) .. "M"
    end

    return string.format("%0.2f/%0.2f", gSize0, gSize1) .. "G"
end


--[[值的转换， 值达到100万时，显示为100万；当值达到10亿时，显示为10亿
如果firstMarkValue有值，则以firstMarkValue为准
]]
function M.getCoinValue(value, firstMarkValue)
    local head = tonumber(value)
    if not head then
        return "0"
    end
    
    if firstMarkValue and firstMarkValue > value then
        return value
    end
    local tail = ""
    local firstMax = firstMarkValue or 1000000
    local secondMax = 1000000000
    local firstDev = math.ceil(firstMax / 10000)
    if head >= firstMax and head < secondMax then
        tail = Language.getString(100013)
        head = math.floor(head / (firstMax / firstDev))
    elseif head >= secondMax then
        tail = Language.getString(100014)
        head = math.floor(head / (secondMax / 10))
    end
    return tostring(head) .. tostring(tail)
end

-- 字符串 转 字符串
-- 阿拉伯0-99 转换 中文
function M.transNumToChnNum(num)
    if num == nil then
        return ""
    end
    if type(num) == "string" then
        num = tonumber(num)
    end

    local chnNum = getChnNumTb()

    if num >= 0 and num <= 10 then
        return chnNum[num]
    elseif num > 10 and num <= 19 then
        local ge = num % 10
        return chnNum[10] .. chnNum[ge]
    elseif num >= 20 and num < 100 then
        local shi = math.floor(num / 10)
        local shiStr = chnNum[shi]

        local ge = num % 10
        local geStr = ""
        if ge > 0 then
            geStr = chnNum[ge]
        end
        return shiStr .. chnNum[10] .. geStr
    elseif num >= 100 and num < 1000 then
        local bai = math.floor(num / 100)
        local baiStr = chnNum[bai] .. chnNum[100]
        local sub = num % 100
        if sub == 0 then
            return baiStr
        end
        local subStr = ""
        if sub < 20 then
            local shi = math.floor(sub / 10) % 10
            subStr = chnNum[shi]
        end
        return baiStr .. subStr .. transNumToChnNum(sub)
    end
    return ""
end

function M.transWeekDayToChinese(num)
    return GameDefConfig.getWeekday(num)
end

function M.transWeekDayToChineseTwo(num)
    return GameDefConfig.getWeekdayTwo(num)
end

-- 时间 => h:m:s
function M.transTimeStr(time, type)

    local b = math.floor(time / 3600)
    local c = math.floor(time / 60 % 60)
    local d = math.floor(time % 60)

    local bStr = ""
    local cStr = ""
    local dStr = ""

    local tmp = false
    if type == "h" then
        tmp = true
    end

    if tmp or b >= 0 then
        bStr = tostring(b)
        if b < 10 then
            bStr = "0" .. bStr
        end
        bStr = bStr .. ":"
    end

    if c >= 0 then
        cStr = tostring(c)
        if c < 10 then
            cStr = "0" .. cStr
        end
        cStr = cStr .. ":"
    end

    if d >= 0 then
        dStr = tostring(d)
        if d < 10 then
            dStr = "0" .. dStr
        end
        -- dStr = dStr
    end

    local str = bStr .. cStr .. dStr
    return str
end

function M.transExp(exp)
    local res = exp
    if exp >= 1000000000000 then
        res = exp / 1000000000000
        res = Language.getString(100017, res)
    elseif exp >= 100000000 then
        res = exp / 100000000
        res = Language.getString(100016, res)
    elseif exp >= 10000 then
        res = exp / 10000
        res = Language.getString(100015, res)
    end
    return tostring(res)
end

function M.transBigExp(exp)
    local res = math.floor(exp)
    if exp >= 1000000000000 then
        res = exp / 1000000000000
        res = Language.getString(100017, res)
    elseif exp >= 100000000 then
        res = exp / 100000000
        res = Language.getString(100016, res)
    end
    return tostring(res)
end

function M.transHP(value)
    if value >= 1 then
        if value >= 100000000 then
            value = string.format("%.2f%s", value / 100000000, Language.getString(100014))
        elseif value >= 10000 then
            value = string.format("%.2f%s", value / 10000, Language.getString(100013))
        else
            value = string.format("%.0f", value)
        end
    else
        value = 0
    end
    return tostring(value)
end

--解析像456,656#556,45 的字符串成table
--[[
 str 		原字符串
 splitTb 	分隔符列表 
 fields		生成字段名列表
--
 ex:
  conditTb = stringParser(condit,{"#",","},{
					{name = "equipType",isString = true},
					{name = "color"}
				})
]]--
function M.stringSplitParser(str, splitTb, fields)
    local result = {}
    local function loop(str, index)
        local splitWord = splitTb[index]
        if splitWord == "" then
            if fields[1].isString then
                return str
            else
                return tonumber(str)
            end
        end
        local tb = string.split(str, splitWord)
        local result = {}
        if index + 1 <= #splitTb then
            for i, v in ipairs(tb) do
                if v ~= "" then
                    table.insert(result, loop(v, index + 1))
                end
            end
        else
            local fieldCount = math.min(#fields, #tb)
            for i = 1, fieldCount do
                local isString = fields[i].isString
                local fieldName = fields[i].name
                local value = tb[i]
                if not isString then
                    value = tonumber(value)
                end
                result[fieldName] = value
            end
        end
        return result
    end
    return loop(str, 1)
end
---获得10/20的颜色字符串
function M.getColorAmountText(have, need)
    local str = ""
    if have >= need then
        str = Language.getString(212089, have, need)
    else
        str = Language.getString(212090, have, need)
    end
    return str
end

--- 获取字符串中有多少个word(可以找%s和%%)
function M.findWord(str, word)
    if not str then
        return 0
    end
    local amount, init = 0, 0
    -- 防止死循环?
    local i = 0
    while (i < 100) do
        init = string.find(str, word, init, true)
        if init then
            init = init + 1
            amount = amount + 1
        else
            break
        end
        i = i + 1
    end
    return amount
end

function M.emptyFormat(s)
    local amount = StringUtil.findWord(s, "%s")
    if amount == 0 then
        return string.format(s)
    else
        return s
    end
    --local params = {}
    --for i = 1, amount do
    --    params[i] = string.empty
    --end
    --return string.format(s, table.unpack(params))
end

function string.split(str, sep, returnMap)
    local pattern = "[^" .. sep .. "]+"
    local ret = {}
    for s in str:gmatch(pattern) do
        local ss = s
        if sep ~= " " then
            ss = ss:gsub(" ", "")
        end
        if returnMap then
            ret[ss] = true
        else
            table.insert(ret, ss)
        end
    end
    return ret
end

StringUtil = M