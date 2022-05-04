local LogWarning = CS.UnityEngine.Debug.LogWarning
local LogError = CS.UnityEngine.Debug.LogError

function printTraceback(str, ...)
	if not str then
		str = "Traceback: "
	end
	LogError(debug.traceback(string.format(str, ...)))
end

function printWarning(...)
	local t = {...}
	LogWarning(table.concat(t, "   "))
end

function printError(str, ...)
	LogError(debug.traceback(string.format(str, ...)))
end


--浅拷贝  不包括元表, key不要为table（会共享同一个）
function clone( object )
	assert(type(object) == 'table', "cloned object is not table")
	local new_table = {}
	for key, value in pairs( object ) do
		if type(value) == 'table' and not value.__cname then
			new_table[key] = clone( value )
		else
			new_table[key] = value
		end
	end
	return new_table
end

-- expensive function!!!
function deepcopy(orig)
    local lookup_table = {}
    local function _copy(orig)
        if type(orig) ~= "table" then
            return orig
        elseif lookup_table[orig] then
            return lookup_table[orig]
        end
        local newObject = {}
        lookup_table[orig] = newObject
        for key, value in pairs(orig) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(orig))
    end
    return _copy(orig)
end

function IsNull(uobj)
	if uobj == nil then
		return true
	end
	if type(uobj) == "table" then
		return false
	end
	return Tools.IsObjNull(uobj)
end

function safeGetTable(tb, ...)
	local paramList = {...}
	for index = 1, #paramList do
		tb = tb[paramList[index]]
		if not tb then
			return
		end
	end
	return tb
end

__DEBUG__ = false
__PRINT_TRACK__ = false
