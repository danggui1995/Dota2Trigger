local M = {}

local __modelPoolNode
local __deltaDespawn = 5
local __pooledObjects = {}
local __objOfAssetInfo = {}
local __objId = 0
local __loadIdMap = {}
local __cancelLoadObjs = {}
local tickTimer

function M.init()
    __modelPoolNode = Main.instance.PoolModel.transform

    --启动定时卸载检查
    tickTimer = Timer.Schedule(1, M.CheckUpdate)
end

--定时卸载检查
function M.CheckUpdate()
    local curTime = TimeUtil.getGameTime()

    local releaseItem = 0
    for key, list in pairs(__pooledObjects) do
        for i = #list, 1, -1 do
            local obj = list[i]
            local info = __objOfAssetInfo[obj]
            if info and curTime - info[2] > __deltaDespawn then
                table.remove(list, i)
                __objOfAssetInfo[obj] = nil
                GameObject.Destroy(obj)
                releaseItem = releaseItem + 1
            end
        end
        if #list == 0 then
            __pooledObjects[key] = nil
        end
    end

    if releaseItem > 0 then
        Tools.StartGC()
    end
end

--从对象池获取一个对象，callback回调获取到的对象
function M.Spawn(path, callback)
    __objId = __objId + 1
    local spawnObjId = __objId

    --查找缓存是否有需要的
    local assetTable = __pooledObjects[path]
    if assetTable and #assetTable > 0 then
        local asset = assetTable[#assetTable]
        table.remove(assetTable)
        __objOfAssetInfo[asset][2] = TimeUtil.getGameTime()
        callback(asset)
        return spawnObjId
    end

    local loadId
    loadId = VPKManager.load_model(path, function (obj)
        if obj == nil then
            if callback then
                callback(nil)
            end
            return
        end

        __objOfAssetInfo[obj] = {path, TimeUtil.getGameTime()}
        if __cancelLoadObjs[spawnObjId] then
            __cancelLoadObjs[spawnObjId] = nil
            M.Despawn(obj)
            return
        else
            obj.transform.localPosition = Vector3.zero
            obj.transform.localScale = Vector3.one
            if callback then
                callback(obj)
            end
        end
    end)

    __loadIdMap[spawnObjId] = loadId
    
    return spawnObjId
end

function M.CancelLoad(uniqueId)
    __cancelLoadObjs[uniqueId] = true

    if __loadIdMap[uniqueId] then
        VRFHelper.instance:CancelLoad(__loadIdMap[uniqueId])
        __loadIdMap[uniqueId] = nil
    end
end

function M.Despawn(obj)
    if IsNull(obj) then
        return
    end

    local info = __objOfAssetInfo[obj]
    if not info then
        return
    end

    obj.transform:SetParent(__modelPoolNode)

    local key = info[1]
    if not __pooledObjects[key] then
        __pooledObjects[key] = {}
    end

    table.insert(__pooledObjects[key], obj)
end

--销毁对象
function M.OnDestory(key)
    local assetList = __pooledObjects[key];
    for _,asset in pairs(assetList) do
        GameObject.Destroy(asset);
    end
    __pooledObjects[key] = {}
end

ObjectPool = M