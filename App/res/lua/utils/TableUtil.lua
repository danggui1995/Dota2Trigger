local M = {}

local function count(hashtable)
	local count = 0
	for _,_ in pairs(hashtable) do
		count = count + 1
	end
	return count
end

local function length(array)
	if array.n ~= nil then
		return array.n
	end
	
	local count = 0
	for i,_ in pairs(array) do
		if count < i then
			count = i
		end		
	end
	return count
end

local function setlen(array, n)
	array.n = n
end

local function keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

local function values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

local function merge(dest_hashtable, src_hashtable)
	if #dest_hashtable==0 and #src_hashtable>0 then
		return src_hashtable
	end
	if  #dest_hashtable>0 and #src_hashtable==0 then
		return dest_hashtable
	end

    for k, v in pairs(src_hashtable) do
        dest_hashtable[k] = v
    end
end

local function insertto(dest_array, src_array, begin)
	assert(begin == nil or type(begin) == "number")
	if begin == nil or begin <= 0 then
		begin = #dest_array + 1
	end

	local src_len = #src_array
	for i = 0, src_len - 1 do
		dest_array[i + begin] = src_array[i + 1]
	end
end

local function indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then 
			return i 
		end
    end
	return false
end

local function keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then 
			return k 
		end
    end
    return nil
end

function table.removebyvalue(array, value, removeall)
    local remove_count = 0
	for i = #array, 1, -1 do
		if array[i] == value then
			table.remove(array, i)
			remove_count = remove_count + 1
            if not removeall then 
				break 
			end
		end
	end
	return remove_count
end

local function map(tb, func)
    for k, v in pairs(tb) do
        tb[k] = func(k, v)
    end
end

local function walk(tb, func)
    for k,v in pairs(tb) do
        func(k, v)
    end
end

local function walksort(tb, sort_func, walk_func)
	local keys = table.keys(tb)
	table.sort(keys, function(lkey, rkey)
		return sort_func(lkey, rkey)
	end)
	for i = 1, table.length(keys) do
		walk_func(keys[i], tb[keys[i]])
	end
end

local function filter(tb, func)
	local filter = {}
    for k, v in pairs(tb) do
        if not func(k, v) then 
			filter[k] = v
		end
    end
	return filter
end

local function choose(tb, func)
	local choose = {}
    for k, v in pairs(tb) do
        if func(k, v) then 
			choose[k] = v
		end
    end
	return choose
end

local function circulator(array)
	local i = 1
	local iter = function()
		i = i >= #array and 1 or i + 1
		return array[i]
	end
	return iter
end

local function first(tb, remove)
	for k,_ in pairs(tb) do
		local ele = tb[k]
		if remove then
			tb[k] = nil
		end
		return ele
	end

	return nil
end

table.count = count
table.length = length
table.setlen = setlen
table.keys = keys
table.values = values
table.merge = merge
table.insertto = insertto
table.indexof = indexof
table.keyof = keyof
table.map = map
table.walk = walk
table.walksort = walksort
table.filter = filter
table.choose = choose
table.circulator = circulator
table.dump = dump
table.first = first

function dump(tb, dump_metatable, max_level)
	local lookup_table = {}
	local level = 0
	local rep = string.rep
	local dump_metatable = dump_metatable

	local function _dump(tb, level)
		local str = "\n" .. rep("\t", level) .. "{\n"
		for k,v in pairs(tb) do
			local k_is_str = type(k) == "string" and 1 or 0
			local v_is_str = type(v) == "string" and 1 or 0
			str = str..rep("\t", level + 1).."["..rep("\"", k_is_str)..(tostring(k) or type(k))..rep("\"", k_is_str).."]".." = "
			if type(v) == "table" then
				if not lookup_table[v] and ((not max_level) or level < max_level) then
					lookup_table[v] = true
					str = str.._dump(v, level + 1, dump_metatable).."\n"
				else
					str = str..(tostring(v) or type(v))..",\n"
				end
			else 
				str = str..rep("\"", v_is_str)..(tostring(v) or type(v))..rep("\"", v_is_str)..",\n"
			end
		end
		if dump_metatable then
			local mt = getmetatable(tb)
			if mt ~= nil and type(mt) == "table" then
				str = str..rep("\t", level + 1).."[\"__metatable\"]".." = "
				if not lookup_table[mt] and ((not max_level) or level < max_level) then
					lookup_table[mt] = true
					str = str.._dump(mt, level + 1, dump_metatable).."\n"
				else
					str = str..(tostring(v) or type(v))..",\n"
				end
			end
		end
		str = str..rep("\t", level) .. "},"
		return str
	end
	
	print(_dump(tb, level))
end

TableUtil = M