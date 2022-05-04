local M = {}

local __eventMap__ = {}

local t_ipairs = ipairs
local t_insert = table.insert
local t_remove = table.remove
local t_sort = table.sort

--构造方法
function M.ctor(args)
    __eventMap__ = {}
end

function M.clear()
    __eventMap__ = {}
end

function M.addEvent(name, listenerOrCaller, listenerCaller)
    -- if type(name) == "string" then
    --     -- assert(EventType[listener],"必须在EventType中定义")
    --     local callType = type(listenerOrCaller)
    --     assert(callType == "table" or callType == "userdata", "listenerCaller error " .. callType)
    --     M.__addEventInner(name, listenerOrCaller[name], listenerOrCaller)
    -- else
        M.__addEventInner(name, listenerOrCaller, listenerCaller)
    -- end
end

function M.removeEvent(name, listenerOrCaller)
    -- if type(name) == "string" then
    --     local callType = type(listenerOrCaller)
    --     assert(callType == "table" or callType == "userdata", "listenerCaller error")

    --     M.__removeEventInner(name, listenerOrCaller[name], listenerOrCaller)
    -- else
        M.__removeEventInner(name, listenerOrCaller)
    -- end
end

--[[
添加事件侦听
@name			[string]事件名
@listener		[function]侦听器
@listenerCaller	[Object]侦听函数调用者
--]]
function M.__addEventInner(name, listener, listenerCaller)
    assert(type(name) == "string" or type(name) == "number", string.format("事件没有注册id === Invalid event name of argument 1 (%s), need a string or number!", name))
    assert(type(listener) == "function", "事件没有实现对应的方法 === Invalid listener function!")

    local eventT = __eventMap__[name]
    if eventT == nil then
        eventT = {
            __index__ = 0, --索引值，用于权重值相同的项能按添加顺序进行排序
            __listeners__ = {}, --用于快速判断某事件对应的侦听器是否存在
            __isLocked__ = false, --是否被锁住，用于防止在dispatch事件的过程中，对该事件的侦听器列表进行增减操作导致的异常
            __operations__ = nil    --被锁住时添加或删除的事件列表，与__isLocked__一起使用
        }
        __eventMap__[name] = eventT
    end

    if eventT.__isLocked__ then
        if not eventT.__operations__ then
            eventT.__operations__ = {}
        end
        t_insert(eventT.__operations__, { type = 1, name = name, listener = listener, listenerCaller = listenerCaller })
        return
    end

    eventT.__index__ = eventT.__index__ + 1
    eventT.__listeners__[listener] = true
    t_insert(eventT, { listener = listener, listenerCaller = listenerCaller, index = eventT.__index__ })
end



--[[
移除事件侦听
@name		[string]事件名
@listener	[function]侦听器
--]]
function M.__removeEventInner(name, listener)
    assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
    assert(type(listener) == "function", "Invalid listener function!")

    local eventT = __eventMap__[name]
    if eventT ~= nil then
        if eventT.__isLocked__ then
            if not eventT.__operations__ then
                eventT.__operations__ = {}
            end
            t_insert(eventT.__operations__, { type = 2, name = name, listener = listener })
            return
        end

        eventT.__listeners__[listener] = nil
        for i = #eventT, 1, -1 do
            if eventT[i].listener == listener then
                t_remove(eventT, i)
            end
        end
    end
end

--判断侦听器是否存在
function M._isListenerExist(name, listener)
    local eventT = __eventMap__[name]
    if eventT and eventT.__listeners__[listener] then
        return true
    end
    return false
end

--[[
发布事件
@name		[string]事件名
@...		其它参数
--]]
function M.dispatchEvent(name, ...)
    if type(name) ~= "string" and type(name) ~= "number" then
        assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
    end

    local eventT = __eventMap__[name]
    if eventT ~= nil then

        eventT.__isLocked__ = true
        for k, v in t_ipairs(eventT) do
            if M._isListenerExist(name, v.listener) then
                v.listener(v.listenerCaller, name, ...)
            end
        end
        eventT.__isLocked__ = false

        if eventT.__operations__ then
            for k, v in t_ipairs(eventT.__operations__) do
                if v.type == 1 then
                    -- 增加
                    M.addEvent(v.name, v.listener, v.listenerCaller)
                elseif v.type == 2 then
                    -- 删除
                    M.removeEvent(v.name, v.listener)
                end
            end
            eventT.__operations__ = nil
        end
    end
end

--[[
是否存在该事件侦听
@name	事件名
--]]
function M.hasEvent(name)
    assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
    return __eventMap__[name] ~= nil
end

Dispatcher = M