local M = class("BaseView")

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = ""
    self.packageItem = ""
    self.fullScreenType = 0 --0非全屏 1全屏
    self.tickInterval = 0
    self.timerHandlers = {}
    self.events = {}
    self.stackIndex = 1
    self.cacheTime = 0
end

function M:initUI()
    FguiUtil.AddPackageInPc(self.package)
    self.root = UIPackage.CreateObject(self.package, self.packageItem)
    if self.fullScreenType == 1 then
        self.root:MakeFullScreen()
    else
        self.root:Center()
    end

    self:onInit()
end

--请勿调用
function M:__show(...)
    self.cacheTime = TimeUtil.getGameTime()
    self:onOpen(...)
    if self.tickInterval and self.tickInterval > 0 then
        local handler = Timer.Schedule(self.tickInterval, self.onTick, self)
        table.insert(self.timerIndex, handler)
    end

    UIManager.addToLayer(self.layerDepth, self.root)
    self:onAddEvent()
end

function M:addEvent(name, func, listener)
    Dispatcher.addEvent(name, func, listener)
    self.events[name] = func
end

--请勿调用 关闭 可能只是隐藏，还会在池里保留一段时间
function M:__close()
    for _, handler in pairs(self.timerHandlers) do
        Timer.Unschedule(handler)
    end
    self.timerHandlers = {}
    self:onClose()

    for name, func in pairs(self.events) do
        Dispatcher.removeEvent(name, func)
    end
    self.events = {}

    self.root:RemoveFromParent()
end

function M:close()
    UIManager.closeView(self.__cname)
end

--真正销毁
function M:onDestroy()
    --TODO 检测所有成员变量 全部置空 防止内存泄漏
    self.root:Dispose()

    self.root = nil
    self.timerHandlers = nil
    self.events = nil
end

function M:getChild(name, template)
    return fgui.GetComponent(self.root, name, template)
end

--override
function M:onOpen(...)

end

--override
function M:onClose()
    
end

--override
function M:onTick()
    
end

--override
function M:onInit()
    
end

--override
function M:onAddEvent()
    
end

BaseView = M