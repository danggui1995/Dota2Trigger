

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
function M.Spawn(key, path, callback)
    if spawnedObjects[key] == nil then
        spawnedObjects[key] = {}
    end

    --查找缓存是否有需要的
    local assetTable = pooledObjects[key]
    if assetTable and #assetTable > 0 then
        local asset = assetTable[#assetTable]
        table.remove(assetTable)
        table.insert(spawnedObjects[key], asset)
        callback(asset, key)
        return
    end

    VPKManager.load_model(key, path, function (obj, oldkey)
        if obj == nil then
            if callback then
                callback(nil, key)
            end
            return
        end

        table.insert(spawnedObjects[key], obj)

        local hashCode = obj:GetHashCode()
        objOfAssetInfo[hashCode] = key

        if oldkey ~= key then
            M.Despawn(obj)
            return
        else
            obj.transform.localPosition = Vector3(0,0,0)
            obj.transform.localScale = Vector3(1,1,1)
            if callback then
                callback(obj, key)
            end
        end
    end)
end

function M.Despawn(obj)
    if IsNull(obj) then
        return
    end

    local key = objOfAssetInfo[obj:GetHashCode()]
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