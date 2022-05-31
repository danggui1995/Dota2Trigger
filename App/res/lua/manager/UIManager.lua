local M = {}

local __openedViews = {}
local __residentViews = {}
local __viewStack = {}
local __cachedViews = {}
local __loadedPackage = {}
local CACHE_TIME = 10
local tickTimer = false
local layerObj = {}

local function safeShowView(view, ...)
    view:__show(...)
end

function M.openView(viewName, ...)
    if not ViewConfig[viewName] then
        printWarning("ViewConfig缺少配置：" .. viewName)
        return
    end
    if not __openedViews[viewName] then
        local view
        local info = ViewConfig[viewName]
        if __cachedViews[viewName] then
            view = __cachedViews[viewName]
            __cachedViews[viewName] = nil
        else
            view = require(info[1]).new()
            view:initUI()
        end
        
        if info.isResident then
            __residentViews[viewName] = view
        else
            __openedViews[viewName] = view
        end

        if info.layerDepth == LayerDepth.Window then
            table.insert(__viewStack, view)
            view.stackIndex = #__viewStack
        end

        local ok, msg = pcall(safeShowView, view, ...)
        if not ok then
            printError(msg)
            Timer.ScheduleNextFrame(function()
                UIManager.closeView(viewName)
            end)
        end
    else
        printWarning(viewName .. "已经打开了")
    end
end

function M.closeView(viewName)
    local view
    if __openedViews[viewName] then
        view = __openedViews[viewName]
        __openedViews[viewName] = nil

        if view.stackIndex < #__viewStack then
            for index = view.stackIndex + 1, #__viewStack do
                __viewStack[index].stackIndex = __viewStack[index].stackIndex - 1
            end
        end
        table.remove(__viewStack, view.stackIndex)
    elseif __residentViews[viewName] then
        view = __residentViews[viewName]
        __residentViews[viewName] = nil
    end

    if view then
        __cachedViews[viewName] = view
        view:__close()
    end
end

function M.closeAll()
    for name, _ in pairs(__openedViews) do
        M.closeView(name)
    end
    __openedViews = {}

    for name, _ in pairs(__residentViews) do
        M.closeView(name)
    end
    __residentViews = {}
end

--初始化一些常驻的包
function M.init()
    local residentPackage = {
        "public",
        -- "MainUI",
    }

    for key, value in pairs(residentPackage) do
        M.addPackage(value)
    end
    tickTimer = Timer.Schedule(1, function()
        local curTime = TimeUtil.getGameTime()
        for name, view in pairs(__cachedViews) do
            if curTime - view.cacheTime > CACHE_TIME then
                view:onDestroy()
                __cachedViews[name] = nil
            end
        end
    end)

    --初始化层级
    local depthList = {}
    for key, value in pairs(LayerDepth) do
        table.insert(depthList, {key, value})
    end
    table.sort(depthList, function (a,b)
        return a[2] > b[2]
    end)

    GRoot.inst:SetContentScaleFactor(1920, 1080)
    for _, v in ipairs(depthList) do
        local obj = FairyGUI.GComponent()
        obj:MakeFullScreen()
        obj.fairyBatching = true
        obj.gameObjectName = v[1]
        GRoot.inst:AddChild(obj)
        obj.z = v[2]
        layerObj[v[2]] = obj
    end
end

local layerZOrder = {}
function M.addToLayer(layer, obj)
    layerObj[layer]:AddChild(obj)
    if not layerZOrder[layer] then
        layerZOrder[layer] = 0
    else
        layerZOrder[layer] = layerZOrder[layer] - 500
    end
    obj.z = layerZOrder[layer]

    M.adjustZOrder(layer)
end

function M.adjustZOrder(layer)
    --TODO
end

function M.addPackage(name)
    if not __loadedPackage[name] then
        __loadedPackage[name] = FguiUtil.AddPackageInPc(name)
    end
end

--关闭最顶上的一个Window 其他的不走这里
function M.popView()
    local topView = __viewStack[#__viewStack]
    topView:close()
end

function M.clear()
    M.closeAll()

    UIPackage.RemoveAllPackages()
    __openedViews = {}
    __residentViews = {}
    __viewStack = {}
    __loadedPackage = {}

    if tickTimer then
        Timer.Unschedule(tickTimer)
        tickTimer = nil
    end

    for name, view in pairs(__cachedViews) do
        view:onDestroy()
    end
    __cachedViews = nil

    for _, layer in pairs(layerObj) do
        layer:Dispose()
    end
    layerObj = nil
end

UIManager = M

M.init()