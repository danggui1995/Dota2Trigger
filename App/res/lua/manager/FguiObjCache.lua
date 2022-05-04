local M = {}
local __cache
function M.makeCache()
    __cache = setmetatable({}, {__mode = "kv"})
end

function M.get(key)
    if __cache[key] then
        return __cache[key] 
    end
end

function M.set(k, v)
    __cache[k] = v
end

FguiObjCache = M

M.makeCache()