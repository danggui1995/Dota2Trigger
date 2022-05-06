

local M = {}

--根节点
local modelPoolNode
--回收检测间隔
local deltaDespawn = 30
--默认池子大小
local defaultPoolSize = 5
--在池子里的对象
local pooledObjects = {}
--正在使用的对象
local spawnedObjects= {}
--对象和资源的映射
local objOfAssetInfo = {}

local __objId = 0

--取消加载
local __cancelLoadObjs = {}

local tickTimer
function M.init()
    modelPoolNode = Main.instance.PoolModel.transform

    --启动定时卸载检查
    tickTimer = Timer.Schedule(1, M.CheckUpdate)
end


--跳过poolSize，直接强制清除所有pooledObjects，适用于切换场景等操作
function M.ClearPool()
    for _,assetList in pairs(pooledObjects) do
        for _,asset in pairs(assetList) do
            GameObject.Destroy(asset)
        end
    end
    assetPockets = {}
    pooledObjects = {}
end

--定时卸载检查
function M.CheckUpdate()
    for k,assetList in pairs(pooledObjects) do
        local assetCount = #assetList
        local poolSize = defaultPoolSize
        --销毁超出部分
        if assetCount > poolSize then
            for _ = assetCount - poolSize, 1, -1 do
                local removedObj = assetList[#assetList]
                table.remove(assetList)
                GameObject.Destroy(removedObj)
            end
        end
    end
end

--从对象池获取一个对象，callback回调获取到的对象
function M.Spawn(path, callback)
    if spawnedObjects[path] == nil then
        spawnedObjects[path] = {}
    end

    __objId = __objId + 1
    local spawnObjId = __objId

    --查找缓存是否有需要的
    local assetTable = pooledObjects[path]
    if assetTable and #assetTable > 0 then
        local asset = assetTable[#assetTable]
        table.remove(assetTable)
        table.insert(spawnedObjects[path], asset)
        callback(asset)
        return spawnObjId
    end

    VPKManager.load_model(path, path, function (obj)
        if obj == nil then
            if callback then
                callback(nil)
            end
            return
        end

        table.insert(spawnedObjects[path], obj)
        objOfAssetInfo[obj] = path

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
    return spawnObjId
end

function M.CancelLoad(uniqueId)
    __cancelLoadObjs[uniqueId] = true
end

function M.Despawn(obj)
    if IsNull(obj) then
        return
    end

    local key = objOfAssetInfo[obj]
    if key == nil then
        return
    end

    local assetTable = spawnedObjects[key]
    if assetTable == nil then
        return
    end

    local assetIndex = table.indexof(assetTable, obj)
    if assetIndex == false then
        return
    end

    local asset = assetTable[assetIndex]
    -- asset:SetActive(false)
    asset.transform:SetParent(modelPoolNode)

    if pooledObjects[key] == nil then
        pooledObjects[key] = {}
    end

    --把对象移到池子里
    table.insert(pooledObjects[key], asset)
    table.removebyvalue(spawnedObjects[key], asset)
end

--销毁对象
function M.OnDestory(key)
    local assetList = pooledObjects[key];
    for _,asset in pairs(assetList) do
        GameObject.Destroy(asset);
    end
    pooledObjects[key] = {}
end

ObjectPool = M