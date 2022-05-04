local ExistClassMap = {}

--用于禁止类实例在构造函数执行完之后再创建类变量
local function errorNewIndex(t, k, v)
	if not __RELOADING_LUA__ then
		printTraceback()
		error(string.format("Error! class '%s' no member variable '%s' is defined at ctor!", t.__cname, tostring(k)))
	end
end

--定义一个类对象
--@param	#string		className	类名
--@param	#table		super		父类
--@param	#table		staticFuns	静态方法表
--@return	#table	类
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

	-- 传入的super必须得是该类方法构建的table
	if type(super) == "table" and type(super.cname) == "string" and super.cname ~= "" then
		cls.super = super
	end

	--储存类的所有方法
	cls.funcs = {}
	--储存类实例的重要方法和属性
	cls.instanceIndexT = {}

	--该类所生成实例用于索引的元表
	local instanceIndexT = cls.instanceIndexT

	--用于访问父级方法
	function instanceIndexT:super(className, method, ...)
		return self.__supers[className][method](self, ...)
	end

	-- 判断自己是否为某个类的实例
	function instanceIndexT:isTypeOf(className)
		return cls.isTypeOf(className)
	end

	-- 存在父类时，将父类的所有方法都浅复制到本类的实例index表里去
	if cls.super then
		-- print(1, "~~~~~~~~~~~~~~~~~", className)
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
		-- print(1, "~~~~~~~~~~~~~~~~~")
	end

	--执行构造函数
	local function runCtor(this, ...)
		local function ctor(c, ...)
			--递归调用父类的构造函数
			if c.super then
				ctor(c.super, ...)
			end

			if c.ctor then
				c.ctor(this, ...)
			end
		end
		ctor(cls, ...)
	end

	--执行构造后的初始化函数
	local function runInit(this, ...)
		local function init(c, ...)
			--递归调用父类的构造函数
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

		--限制只能在构造函数执行完之前定义类变量
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
			-- print(1, "~~~__newindex~~~", cls.cname, t, k, v)
			if "ctor" == k 
				or "init" == k
			then
				rawset(cls, k, v)
			elseif "super" == k then
				error("super方法不能被重新定义！")
			else
				--将各级父类的该方法copy到本类中
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


--定义一个简单的类对象，保留.new()函数，会自动调用:ctor()和:init(). 由于不保存父类的任何东西，所以父类的方法也不会自动调用. 
--成员变量可以直接继承和覆盖
--当方法重写时，如果需要调用父类的方法，可以:
-- local A = simpleClass("A")
--
-- local B = simpleClass("B", A)
-- function B:ctor()
--     if A.ctor then
--         A.ctor(self)  --把B自己传进去，不调用就是纯覆盖。
--     end
--     --do other things...
-- end
--
--如果有继承再继承就建议用class()，因为调用父类函数会更复杂。

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

	--只有simpleClass可以继承，其它的不能保证metatable是.mt
	if type(super) == "table" and super.__type__ == "simple_class" then
        setmetatable(class, super.mt)
    end

	--这里没用到self，其实可以改成.号，保留原来的习惯就还是:号了。
	function class.new(...)
		local instance = {}
		setmetatable(instance, class.mt)

		--执行构造函数
		if instance.ctor then
			instance:ctor(...)
		end

		--执行构造后的初始化函数
		if instance.init then
			instance:init(...)
		end

		return instance
	end

	return class 
end

--实现接口，其实是多继承，把多个父类（类似C++里的纯虚函数类）的函数拷贝过来。
--Usage:
--    local InterfaceA = {}
--    function InterfaceA:func1()
--    end
--
--    local InterfaceB = { funcName = function(self, ...) end, }
--
--    local C = simpleClass("C")
--    C = setImplements(C, InterfaceA, InterfaceB)
--or
--    local C = setImplements(simpleClass("C"), InterfaceA, InterfaceB)

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
