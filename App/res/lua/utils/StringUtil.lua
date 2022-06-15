local M = {}

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