
local ELuaEvent = CS.Trigger.ELuaEvent

local excludeReload = {
    ["manager.VPKManager"] = "VPKManager",
}

local includeModule = {
    "views",
    "tableconfig",
    "config",
    "utils",
    "components",
}

local M = {}
local __callback = {
    [ELuaEvent.Event_ReloadLua] = function()
        UIManager.clear()

        Timer.Clear()
        Dispatcher.clear()
        
        -- local luaPath = Main.luaPath
        -- for _, v in ipairs(includeModule) do
        --     local parent = FileUtil.combinePath(luaPath, v)
        --     XFolderTools.TraverseFiles(parent, function (fullpath)
        --         local relativePath = Path.GetRelativePath(parent, fullpath)
        --         local k = relativePath:gsub("\\", ".")
        --         if not excludeReload[k] then
        --             package.loaded[k] = nil
        --         end
        --     end, true)
        -- end

        -- -- package.loaded["main"] = nil
        for k, v in pairs(package.loaded) do
            if not excludeReload[k] then
                package.loaded[k] = nil
            else
                _G[excludeReload[k]].clear()
            end
        end
        
        require "main"
    end,
}
local evtID = 0
function M.init()
    CS.Trigger.LuaEvent.instance.eventHandler = function(evt, param)
        if __callback[evt] then
            __callback[evt](param)
        end
    end
end
--TODO 要传一个key过去再穿回来  不然会错乱
function M.regAsyncEvent(evt, callback, asyncFunc, ...)
    if not __callback[evt] then
        __callback[evt] = {}
    end
    __callback[evt][evtID] = callback
    
    asyncFunc(..., evtID)

    evtID = evtID + 1
end

M.init()

CsEventManager = M