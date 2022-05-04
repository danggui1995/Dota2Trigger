--命名空间在这边定义
FairyGUI = CS.FairyGUI

fgui = {
	
	EventListener = FairyGUI.EventListener,
	EventDispatcher = FairyGUI.EventDispatcher,
	LuaWindow = FairyGUI.LuaWindow,
	LuaUIHelper = FairyGUI.LuaUIHelper,
	
	GLuaComponent = FairyGUI.GLuaComponent,
	GComponent = FairyGUI.GComponent,
}

function fgui.class(super, cstype)
	local cs_func_tbl = {}

	local class_type = {
		super = super,
		cs_func_tbl = cs_func_tbl
	}

	class_type.new = function(...)
		local obj = {super = super}

		setmetatable(obj, { 
			__index = function(t, k)
				local ret
				local cur_class = class_type
				repeat
					-- 先找本类 和本类的c#函数缓存
					ret = cur_class[k] or cur_class.cs_func_tbl[k]
					if ret then
						return ret
					end

					-- 找父类
					if cur_class.super then
						cur_class = cur_class.super
					else
						-- 没有父类了，找c#类
						local csuserdata = rawget(obj, "csuserdata")
						if csuserdata then
							local csObj = csuserdata[k]
							if csObj and type(csObj) == "function" then
								local f = function(_, ...)
									return csObj(csuserdata, ...)
								end
								cur_class.cs_func_tbl[k] = f
								return f
							end
							return csObj
						end
						return
					end
				until false
			end 
		})
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.ctor then
					c.ctor(obj, ...)
				end
			end

			create(class_type, ...)
		end
		if cstype then
			obj.csuserdata = cstype()
		end
		if cstype then
			if obj.csuserdata and obj.csuserdata.SetLuaTable then
				obj.csuserdata:SetLuaTable(obj)
			end
			return obj.csuserdata
		end

		return obj
	end

	return class_type
end

--[[
用于继承CS.FairyGUI的Window类，例如
WindowBase = fgui.window_class()
同时派生的Window类可以被继续被继承，例如
MyWindow = fgui.window_class(WindowBase)
可以重写的方法有（与Window类里的同名方法含义完全相同）
OnInit
DoHideAnimation
DoShowAnimation
OnShown
OnHide
]]
function fgui.window_class(base)
	return fgui.class(base, fgui.LuaWindow)
end

--[[
注册组件扩展，例如
fgui.register_extension(UIPackage.GetItemURL("包名","组件名"), my_extension)
my_extension的定义方式见fgui.extension_class
]]
function fgui.register_extension(url, extension)
	local base = extension.base
	if base == fgui.GComponent then base = fgui.GLuaComponent
	-- elseif base == fgui.GLabel then base = fgui.GLuaLabel
	-- elseif base == fgui.GButton then base = fgui.GLuaButton
	-- elseif base == fgui.GSlider then base = fgui.GLuaSlider
	-- elseif base == fgui.GProgressBar then base = fgui.GLuaProgressBar
	-- elseif base == fgui.GComboBox then base = fgui.GLuaComboBox
	else
		print("invalid extension base: "..base)
		return
	end
	fgui.LuaUIHelper.SetExtension(url, typeof(base), extension.Extend)
end

--[[
用于继承CS.FairyGUI原来的组件类，例如
MyComponent = fgui.extension_class(GComponent)
function MyComponent:ctor() --当组件构建完成时此方法被调用
	print(self:GetChild("n1"))
end
]]
function fgui.extension_class(base, gcom)
	local o = fgui.class(base)
	o.base = gcom or fgui.GComponent
	o.Extend = function(ins)
		local t = o.new(ins)
		return t
	end

	return o
end

---以下是内部使用的代码---
local fgui_internal = {}

--[[
CS.FairyGUI自带的定时器，有需要可以使用。例如：
每秒回调，无限次数
fgui.add_timer(1, 0, callback)
可以带self参数
fgui.add_timer(1, 0, callback, self)
可以自定义参数
fgui.add_timer(1, 0, callback, self, data)

！！警告，定时器回调函数不要与UI事件回调函数共用
]]
function fgui.add_timer(interval, repeatCount, func, obj, param)
	local callbackParam
	local _func = func;
	if param ~= nil then
		if obj == nil then
			callbackParam = param
		else
			callbackParam = obj
			_func = function(p)
				func(p, param)
			end
		end
	end
	local delegate = fgui_internal.GetDelegate(_func, obj, true, fgui.TimerCallback)
	fgui.Timers.inst:Add(interval, repeatCount, delegate, callbackParam)
end

function fgui.remove_timer(func, obj)
	local delegate = fgui_internal.GetDelegate(func, obj, false, fgui.TimerCallback)
	if delegate ~= nil then
		fgui.Timers.inst:Remove(delegate)
	end
end



--这里建立一个c# delegate到lua函数的映射，是为了支持self参数，和方便地进行remove操作
fgui_internal.EventDelegates = {}
setmetatable(fgui_internal.EventDelegates, {__mode = "k"})
function fgui_internal.GetDelegate(func, obj, createIfNone, delegateType)
	local mapping
	if obj ~= nil then
		mapping = obj.EventDelegates
		if mapping == nil then
			mapping = {}
			setmetatable(mapping, {__mode = "k"})
			obj.EventDelegates = mapping
		end
	else
		mapping = fgui_internal.EventDelegates
	end

	local delegate = mapping[func]

	if createIfNone and delegate == nil then
		local realFunc
		if obj ~= nil then
			realFunc = function(context)
				return func(obj, context)
			end
		else
			realFunc = func
		end
		delegateType = delegateType or fgui.EventCallback1
		delegate = delegateType(realFunc)
		mapping[func] = delegate
	end

	return delegate
end

function fgui.Init()
	--将EventListener.Add和EventListener.Remove重新进行定义，以适应lua的使用习惯
	local EventListener_mt = getmetatable(fgui.EventListener)
	local oldListenerAdd = rawget(EventListener_mt, 'Add')
	local oldListenerRemove = rawget(EventListener_mt, 'Remove')
	local oldListenerSet = rawget(EventListener_mt, 'Set')
	local oldListenerAddCapture = rawget(EventListener_mt, 'AddCapture')
	local oldListenerRemoveCapture = rawget(EventListener_mt, 'RemoveCapture')
	local function ListenerAdd(listener, func, obj)
		local delegate = fgui_internal.GetDelegate(func, obj, true)
		oldListenerAdd(listener, delegate)
	end

	local function ListenerRemove(listener, func, obj)
		local delegate = fgui_internal.GetDelegate(func, obj, false)
		if delegate ~= nil then
			oldListenerRemove(listener, delegate)
		end
	end

	local function ListenerSet(listener, func, obj)
		if func == nil then
			oldListenerSet(listener, nil)
		else
			local delegate = fgui_internal.GetDelegate(func, obj, true)
			oldListenerSet(listener, delegate)
		end
	end

	local function ListenerAddCapture(listener, func, obj)
		local delegate = fgui_internal.GetDelegate(func, obj, true)
		oldListenerAddCapture(listener, delegate)
	end

	local function ListenerRemoveCapture(listener, func, obj)
		local delegate = fgui_internal.GetDelegate(func, obj, false)
		if delegate ~= nil then
			oldListenerRemoveCapture(listener, delegate)
		end
	end

	rawset(EventListener_mt, 'Add', ListenerAdd)
	rawset(EventListener_mt, 'Remove', ListenerRemove)
	rawset(EventListener_mt, 'Set', ListenerSet)
	rawset(EventListener_mt, 'AddCapture', ListenerAddCapture)
	rawset(EventListener_mt, 'RemoveCapture', ListenerRemoveCapture)

	--将EventDispatcher.AddEventListener和EventDispatcher.RemoveEventListener重新进行定义，以适应lua的使用习惯
	local EventDispatcher_mt = getmetatable(fgui.EventDispatcher)
	local oldAddEventListener = rawget(EventDispatcher_mt, 'AddEventListener')
	local oldRemoveEventListener = rawget(EventDispatcher_mt, 'RemoveEventListener')

	local function AddEventListener(dispatcher, name, func, obj)
		local delegate = fgui_internal.GetDelegate(func, obj, true)
		oldAddEventListener(dispatcher, name, delegate)
	end

	local function RemoveEventListener(dispatcher, name, func, obj)
		local delegate = fgui_internal.GetDelegate(func, obj, false)
		if delegate ~= nil then
			oldRemoveEventListener(dispatcher, name, delegate)
		end
	end

	rawset(EventDispatcher_mt, 'AddEventListener', AddEventListener)
	rawset(EventDispatcher_mt, 'RemoveEventListener', RemoveEventListener)
end

fgui.Init()

--@return wrapComp
function fgui.GetComponent(parent, childName, wrapComp)
	local child = parent:GetChild(childName)
	if not child then
		print(parent, childName, wrapComp)
		printTraceback()
		local num = parent.numChildren
		local t = {}
		for index = 0, num - 1 do
			local obj = parent:GetChildAt(index)
			table.insert(t, obj.name)
		end
		printError(table.concat(t, ','))
	end
	local component = wrapComp.new(child)
	FguiObjCache.set(child, component)
	return component
end

function fgui.GetTemplateUrl(package, item)
	return string.format("ui://%s/%s", package, item)
end

function fgui.newComponent(params)
	local component = BaseComponent.new(FairyGUI.GComponent())
	component:setBaseAttr(params)
	return component
end

function fgui.newGraph(params)
	local graph = Graph.new(FairyGUI.GGraph())
	graph:setBaseAttr(params)
	if params.rect then
		local lineSize = params.rect.lineSize
		local lineColor = params.rect.lineColor
		local fillColor = params.rect.fillColor
		graph:drawRect(params.size.x, params.size.y, lineSize, lineColor, fillColor)
	end
	return graph 
end

local UIConfig = FairyGUI.UIConfig
UIConfig.verticalScrollBar = "ui://main/ScrollBar_VT";
UIConfig.horizontalScrollBar = "ui://main/ScrollBar_HZ";
-- UIConfig.popupMenu = "ui://Basics/PopupMenu";
-- UIConfig.buttonSound = (NAudioClip)UIPackage.GetItemAsset("Basics", "click");


function fgui.GetTemplateClass(name)
	return _G[name]
end

function fgui.GetKeyLang(key)
	--TODO 本地化
	return key
end