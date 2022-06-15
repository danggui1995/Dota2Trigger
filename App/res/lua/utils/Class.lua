local ExistClassMap = {}

local function errorNewIndex(t, k, v)
	if not __RELOADING_LUA__ then
		printTraceback()
		error(string.format("Error! class '%s' no member variable '%s' is defined at ctor!", t.__cname, tostring(k)))
	end
end

function class(className, super, staticFuns)
	if ExistClassMap[className] then
		if not __RELOADING_LUA__ then
			error(string.format("Error! class name '%s' is already defined!", className))
		end
	end
	ExistClassMap[className] = true
	

	local cls = {}
	
	if staticFuns then
		for k, v in pairs(staticFuns) do
			cls[k] = v
		end
	end
	
	cls.cname = className

	if type(super) == "table" and type(super.cname) == "string" and super.cname ~= "" then
		cls.super = super
	end

	cls.funcs = {}
	cls.instanceIndexT = {}

	local instanceIndexT = cls.instanceIndexT

	function instanceIndexT:super(className, method, ...)
		return self.__supers[className][method](self, ...)
	end

	function instanceIndexT:isTypeOf(className)
		return cls.isTypeOf(className)
	end

	if cls.super then
		for k, v in pairs(cls.super.instanceIndexT) do
			if k == "__supers" then
				instanceIndexT[k] = deepcopy(v)
			else
				local need = true
				for funcName, _ in pairs(instanceIndexT) do
					if k == funcName then
						need = false
						break
					end
				end
				if need then
					instanceIndexT[k] = v
				end
			end
		end
	end

	local function runCtor(this, ...)
		local function ctor(c, ...)
			if c.super then
				ctor(c.super, ...)
			end

			if c.ctor then
				c.ctor(this, ...)
			end
		end
		ctor(cls, ...)
	end

	local function runInit(this, ...)
		local function init(c, ...)
			if c.super then
				init(c.super, ...)
			end

			if c.init then
				c.init(this, ...)
			end
		end
		init(cls, ...)
	end

	function cls.new(...)
		local instance = { __cname = cls.cname }
		local mt = { __index = instanceIndexT }
		setmetatable(instance, mt)

		runCtor(instance, ...)

		-- mt.__newindex = errorNewIndex

		runInit(instance, ...)

		return instance
	end

	function cls.isTypeOf(className)
		local c = cls
		while c do
			if c.cname == className then
				return true
			end
			c = c.super
		end
		return false
	end

	setmetatable(cls, {
		__newindex = function(t, k, v)
			if "ctor" == k 
				or "init" == k
			then
				rawset(cls, k, v)
			elseif "super" == k then
				error("super方法不能被重新定义！")
			else
				if rawget(instanceIndexT, k) then
					local c = cls.super
					while c do
						if c.funcs[k] then
							if not instanceIndexT.__supers then
								instanceIndexT.__supers = {}
							end
							if not instanceIndexT.__supers[c.cname] then
								instanceIndexT.__supers[c.cname] = {}
							end
							instanceIndexT.__supers[c.cname][k] = c.funcs[k]
						end
						c = c.super
					end
				end
				rawset(instanceIndexT, k, v)

				cls.funcs[k] = v
			end
		end
	})

	return cls
end

local ExistSimpleClassMap = {}

function simpleClass(className, super)
	if ExistSimpleClassMap[className] then
		if not __RELOADING_LUA__ then
			error(string.format("Error! simple class name '%s' was already defined!", className))
		end
	end
	ExistSimpleClassMap[className] = true

	local class = { mt = {} }
	class.mt.__index = class
	class.__type__ = "simple_class"

	if type(super) == "table" and super.__type__ == "simple_class" then
        setmetatable(class, super.mt)
    end

	function class.new(...)
		local instance = {}
		setmetatable(instance, class.mt)

		if instance.ctor then
			instance:ctor(...)
		end

		if instance.init then
			instance:init(...)
		end

		return instance
	end

	return class 
end

function setImplements(class, ...)
    class = class or {}

    local interfaceList = {...}

    for i = 1, #interfaceList do
        local interfaceTable = interfaceList[i] or {}

        for k,v in pairs(interfaceTable) do
            if class[k] then
                printWarning("[setImplements] duplicated function name: ", k)
            else
                class[k] = v
            end
        end
    end

    return class
end
