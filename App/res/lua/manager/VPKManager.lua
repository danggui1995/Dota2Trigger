local M = {}

local __vpkPackage = false
local __isloadingVPK = false

local __vpkCallbackList = {}
local __itemCallbackList = {}
local __loadedItems = {}
local __loadingItems = {}
local itempath_items_game = "scripts/items/items_game.txt"
local vpk_path = "pak01_dir.vpk"
local extractRootPath = Main.productPath .. "extract"

local ckv = require "ckv"
local ckv_sound = require "ckv1"




local __items_game_map = false
local __items_game_list = false
local __brokenModels = {}
local __internalEventPathMap = false
local __internalEventMap = {}
local __isLoadingEvt = false
local __soundCallback = {}

local __localEventPathInfoMap = false
local __localEventList = {}
local __localEventMap = {}


function M.loadVPK(func)
    local enginePath = SettingsManager.getConfig("ENGINE_PATH")
    if not enginePath or enginePath == "" then
        return
    end
    if not __vpkPackage then
        if func then
            table.insert(__vpkCallbackList, func)
        end
        if not __isloadingVPK then
            __isloadingVPK = true

            local vpkPath = Path.Combine(enginePath, vpk_path)
            Dispatcher.dispatchEvent(EventType.Progress_Change_Value, 0, Desc[1000040])
            VRFHelper.instance:LoadVPK(vpkPath, function(pkg)
                __vpkPackage = pkg
                __isloadingVPK = false

                Dispatcher.dispatchEvent(EventType.Progress_Change_Value, 100)
                for _, cb in ipairs(__vpkCallbackList) do
                    cb()
                end
                __vpkCallbackList = {}
            end)
        end
    elseif func then
        func()
    end
end

function M.extractItem(path, func, fullpath)
    if not __loadedItems[path] then
        if not __itemCallbackList[path] then
            __itemCallbackList[path] = {}
        end
        table.insert(__itemCallbackList[path], func)
        if not __loadingItems[path] then
            __loadingItems[path] = true
            M.loadVPK(function()
                Dispatcher.dispatchEvent(EventType.Progress_Change_Value, 0, Desc.getText(1000042, path))
                VRFHelper.instance:LoadItemAsync(path, extractRootPath, function()
                    __loadedItems[path] = true
                    __loadingItems[path] = nil
                    Dispatcher.dispatchEvent(EventType.Progress_Change_Value, 100)
                    for _, cb in ipairs(__itemCallbackList[path]) do
                        cb(fullpath)
                    end
                    __itemCallbackList[path] = {}
                end)
            end) 
        end
    end
end

--@异步接口，传入回调函数
function M.loadItem(path, func)
    local fullpath = Path.Combine(extractRootPath, path):gsub(".vmdl", ".gltf")
    if not XFileTools.Exists(fullpath) then
        M.extractItem(path, func, fullpath)
    else
        func(fullpath)
    end
end


function M.load_items_game(func)
    if not __items_game_map then
        M.loadVPK(function()
            VRFHelper.instance:LoadKVAsync(itempath_items_game, function(data)
                __items_game_map = ckv.decode(data.ByteArray)["items_game"]["items"]
                __items_game_list = {}
                for id, v in pairs(__items_game_map) do
                    if v["model_player"] then
                        table.insert(__items_game_list, {id, v["name"], v["model_player"], v["item_slot"]})
                    end
                end
                table.sort(__items_game_list, function(a, b)
                    return a[1] < b[1]
                end)
                if func then
                    func(__items_game_list, __items_game_map)
                end
            end, true)
        end)
    else
        if func then
            func(__items_game_list, __items_game_map)
        end
    end
end


function M.load_model(id, path, func)
    if __brokenModels[id] then
        func(nil, id)
        return
    end

    -- M.loadItem(path, function(fullpath)
    --     if XFileTools.Exists(fullpath) then
    --         GltfHelper.LoadGltf(fullpath, function(obj)
    --             func(obj, id)
    --         end)
    --     else
    --         MsgManager.showMsg("无法导出模型：%s，v蛇傻逼", path)
    --         __brokenModels[id] = true
    --         func(nil, id)
    --     end
    -- end)

    M.loadVPK(function()
        GltfHelper.LoadVModelRuntime(path, function(go)
            func(go, id)
        end)
    end)
    
end



function M.load_soundevents(callback)
    if callback then
        table.insert(__soundCallback, callback)
    end
    if __isLoadingEvt then
        return
    end
    if not __internalEventPathMap then
        __isLoadingEvt = true
        __internalEventPathMap = {}

        local allFiles
        local cnt = 0
        local function onkvloaded (data)            
            cnt = cnt + 1
            Dispatcher.dispatchEvent(EventType.Progress_Change_Value, cnt / allFiles * 100)

            if data and data.ByteArray ~= nil then
                local tb = ckv_sound.decode(data.ByteArray)
                for k, v in pairs(tb) do
                    local vsndArr
                    if v["operator_stacks"] then
                        local vv = v["operator_stacks"]["update_stack"]["reference_operator"]["operator_variables"]
                        if vv and vv["vsnd_files"] then
                            vsndArr = vv["vsnd_files"]["value"]
                        end
                    else
                        vsndArr = v["vsnd_files"]
                    end
                    if vsndArr then
                        if type(vsndArr) ~= 'table' then
                            vsndArr = {vsndArr}
                        end
                        for _, vsnd in pairs(vsndArr) do
                            if not __internalEventMap[k] then
                                __internalEventMap[k] = {}
                            end
                            table.insert(__internalEventMap[k], vsnd)
                            if not __internalEventPathMap[vsnd] then
                                __internalEventPathMap[vsnd] = {{k, data.StringValue}}
                            else
                                table.insert(__internalEventPathMap[vsnd], {k, data.StringValue})
                            end
                        end
                    end
                end
                tb = nil
            end

            if cnt == allFiles then
                VRFHelper.instance:ClearCacheStream()
                collectgarbage("collect")
                __isLoadingEvt = false
                for _, cb in pairs(__soundCallback) do
                    cb(__internalEventPathMap)
                end
                __soundCallback = {}
            end
        end

        M.loadVPK(function()
            local listdata = VRFHelper.instance:LoadItemsInDir("vsndevts_c", {"soundevents"}, nil, {true}, "")
            allFiles = listdata.Length
            Dispatcher.dispatchEvent(EventType.Progress_Change_Value, 0, "加载soundevent")
            VRFHelper.instance.enableUseCacheStream = true
            for index = 0, listdata.Length - 1 do
                VRFHelper.instance:LoadKVAsync(listdata[index], onkvloaded)
            end
        end)
    elseif callback then
        callback(__internalEventPathMap)
    end
end

function M.loadLocalSoundEventFile(fullpath)
    local text = XFileTools.ReadAllText(fullpath)
    local tb = ckv_sound.decode_array(text)

    if type(tb[1]) == 'table' then
        tb = tb[1]
    end
    __localEventList[fullpath] = tb
    for i = 1, #tb, 2 do
        local info = tb[i + 1]
        local name = tb[i]
        
        for j = 1, #info, 2 do
            local k = info[j]
            local v = info[j + 1]
            if k == "vsnd_files" then
                for l = 1, #v do
                    if not __localEventPathInfoMap[v[l]] then
                        __localEventPathInfoMap[v[l]] = {{i, fullpath, name}}
                    else
                        table.insert(__localEventPathInfoMap[v[l]], {i, fullpath, name})
                    end

                    if not __localEventMap[name] then
                        __localEventMap[name] = {}
                    end
                    table.insert(__localEventMap[name], v[l])
                end
                break
            end
        end
    end
end

function M.getLocalSoundEventFiles(path)
    if not __localEventPathInfoMap then
        __localEventPathInfoMap = {}

        local soundRootPath = Path.Combine(SettingsManager.getConfig("CONTENT_PATH"), "soundevents")
        XFolderTools.TraverseFilesEX(soundRootPath, function (fullpath)
            local ext = Path.GetExtension(fullpath)
            if ext ~= ".vsndevts" then
                return
            end
            M.loadLocalSoundEventFile(fullpath)
        end)
    end
    if path then
        return __localEventPathInfoMap[path]
    else
        return __localEventPathInfoMap
    end
end

function M.appendSoundKv(fullpath, name, kv, vsndPath)
    if not XFileTools.Exists(fullpath) then
        local t = {name, kv}
        XFileTools.WriteAllText(fullpath, ckv_sound.encode_array(t))
        M.loadLocalSoundEventFile(fullpath)
        return false
    else
        local hasSameKey = false
        local nameIndex
        for i = 1, #__localEventList[fullpath], 2 do
            if __localEventList[fullpath][i] == name then
                nameIndex = i
                local tb = __localEventList[fullpath][i + 1]
                for j = 1, #tb, 2 do
                    if tb[j] == "vsnd_files" then
                        table.insert(tb[j+1], vsndPath)
                        break
                    end
                end
                hasSameKey = true
                break
            end
        end

        if not hasSameKey then
            table.insert(__localEventList[fullpath], name)
            nameIndex = #__localEventList[fullpath] 

            table.insert(__localEventList[fullpath], kv)
        end
        if __localEventPathInfoMap[vsndPath] then
            table.insert(__localEventPathInfoMap[vsndPath], {nameIndex, fullpath, name})
        else
            __localEventPathInfoMap[vsndPath] = {{nameIndex, fullpath, name}}
        end
        XFileTools.WriteAllText(fullpath, ckv_sound.encode_array(__localEventList[fullpath]))
        return hasSameKey
    end
end

function M.getLocalKv(fullpath)
    return __localEventList[fullpath]
end

function M.getAllSoundList(vsndPath, isInternal, callback)
    if not isInternal then
        M.getLocalSoundEventFiles()
        callback(__localEventPathInfoMap[vsndPath])
    else
        M.load_soundevents(function()
            callback(__internalEventPathMap[vsndPath])
        end)
    end
end

function M.getEventSoundMap(eventName, callback)
    M.getLocalSoundEventFiles()
    if __localEventMap[eventName] then
        callback(__localEventMap[eventName], true)
    else
        M.load_soundevents(function()
            callback(__internalEventMap[eventName], false)
        end)
    end
end

function M.getResPath(resType, path, bFull)
    local contentRoot = SettingsManager.getConfig("CONTENT_PATH")
    local rootPath = Path.Combine(contentRoot, resType)
    local resPath
    if bFull then
        if path then
            resPath = Path.Combine(rootPath, path):gsub("\\", "/")
        else
            resPath = rootPath:gsub("\\", "/")
        end
    else
        resPath = path:gsub(contentRoot, ""):gsub("\\", "/"):gsub("/" .. resType, resType)
    end
    return resPath
end

function M.renameVsnd(vsndPath, index, newValue)
    __localEventPathInfoMap[vsndPath][index][3] = newValue
end

function M.removeSoundPathMap(vsndPath, index)
    table.remove(__localEventPathInfoMap[vsndPath], index)
end

function M.clear()
    __vpkCallbackList = {}
    __itemCallbackList = {}
    __soundCallback = {}
end

VPKManager = M