local M = class("kvtree", kvbase)

function M:ctor(root)
    self.template = false

    self.title = root:GetChild("title")
    self.addBtn = root:GetChild("addBtn")
    
    self.addBtn.onClick:Set(function ()
        local listdata = {}
        local function addCallback(context)
            local key = listdata[context.sender.data + 1].key
            table.insert(self.subkv, key)
            local t = {}
            local allKeys = KVAbility.getFunctionKeys(key, self._context)
            for _, v in ipairs(allKeys) do
                table.insert(t, v)
                table.insert(t, KVAbility.getKeyTypeSelect(v, self._context))
            end

            table.insert(self.subkv, t)
            self.list:setAutoData(true)

            Dispatcher.dispatchEvent(EventType.OnSavePressed)

            self:resizeParentList()
        end

        for _, k in ipairs(allFunctions) do
            table.insert(listdata, {
                text = fgui.GetKeyLang(k),
                callback = addCallback,
                key = k,
            })
        end
        table.sort(listdata, function (a,b)
            return a.key < b.key
        end)
        PopManager.showPop("main", "PopupMenu", self.addBtn, listdata)
    end)
    self.subBtn = root:GetChild("subBtn")
    self.subBtn.onClick:Set(function ()
        --移除
        table.remove(self._parentKV, self._valueIndex)
        table.remove(self._parentKV, self._valueIndex - 1)

        Dispatcher.dispatchEvent(EventType.OnSavePressed)
        
        self:resizeParentList()
    end)
    self.list = fgui.GetComponent(root, "list", List)
    
    self.list:setState(function(data, index, comp, obj)
        comp:setkv(data, self.subkv, self.indexMap[index], self._context)
    end)
    self.list:setItemProvider(function(data, index)
        local compType = data[3]
        return fgui.GetTemplateClass(compType), fgui.GetTemplateUrl("main", compType)
    end)
    self.list:setDataUpdateFunc(function ()
        local listdata = {}
        self.indexMap = {}
        for index = 1, #self.subkv - 1, 2 do
            local k = self.subkv[index]
            local v = self.subkv[index + 1]
            local compType = KVAbility.FunctionKeyType[k]
            if type(compType) == 'function' then
                compType = compType(self._context)
            end
            if compType then
                --Function Key
            else
                --Function
                compType = {"kvtree"}
            end
            local moduleGet = compType[2]
            if k then
                if not moduleGet then
                    moduleGet = "FunctionEvent_" .. k
                end
            else
                printError("格式异常，查看是否有未配置的key : %s", self.subkv)
            end
            
            table.insert(listdata, {k, fgui.GetKeyLang(k), compType[1], moduleGet, compType[3]})
            self.indexMap[#listdata] = index + 1
        end
        return listdata
    end)
end

--这里跟UI设计的层级绑定了 如果层级发生改变 这里的代码也要变化
function M:resizeParentList()
    local list = FguiObjCache.get(self.list:getObj().parent.parent)
    local index = 0
    while list ~= nil do
        index = index + 1
        
        list:setAutoData(true)
        list = FguiObjCache.get(list:getObj().parent.parent)
        if index > 10 then
            printError("列表层次超过10层，可能有bug")
            break 
        end
    end
end

function M:setkv(config, kv, index, context)
    self.title.text = config[1]
    self._parentKV = kv
    self._valueIndex = index
    self._context = clone(context)
    self._context.stackMap[self._parentKV[index - 1]] = true

    self.subkv = kv[index]
    self.list:setAutoData(true)

    local currentKey = kv[index - 1]
    if KVAbility.TreeKeys[currentKey] or KVAbility.isFunction(currentKey, context) then
        self.addBtn.visible = false
    else
        self.addBtn.visible = true
    end

    if KVAbility.isFunctionOrEvent(currentKey, context) then
        self.subBtn.visible = true
    else
        self.subBtn.visible = false
    end
end

kvtree = M