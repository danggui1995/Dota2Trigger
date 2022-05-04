local M = class("kvarray", kvbase)

function M:ctor(root)
    self.addBtn = fgui.GetComponent(root, "addBtn", Button)
    self.addBtn:onClick(function ()
        local listdata = self.list:getDataProvider()
        table.insert(self.subkv, tostring(#listdata + 1))
        
        local t = {}
        table.insert(t, self.arrayTemplate)
        table.insert(t, KVComplex.getDefaultValue(self.arrayTemplate))
        table.insert(self.subkv, t)

        Dispatcher.dispatchEvent(EventType.OnSavePressed)
        self.list:setAutoData(true)
        self:resizeParentList()
    end)

    self.subBtn = fgui.GetComponent(root, "subBtn", Button)
    self.subBtn:onClick(function ()
        table.remove(self.subkv)
        table.remove(self.subkv)

        Dispatcher.dispatchEvent(EventType.OnSavePressed)
        self:resizeParentList()
    end)

    self.list = fgui.GetComponent(root, "list", List)
    self.list:setState(function(data, index, comp, obj)
        comp:setkv(data, self.subkv, data[4], self._context, true)
    end)
    self.list:setItemProvider(function(data, index)
        local compType = data[3]
        return fgui.GetTemplateClass(compType), fgui.GetTemplateUrl("main", compType)
    end)
    self.list:setDataUpdateFunc(function ()
        local listdata = {}
        local ti = KVComplex[self.arrayTemplate]
        if ti then
            for index = 1, #self.subkv - 1, 2 do
                table.insert(listdata, {self.arrayTemplate, clone(self._context), ti[1], index + 1})
            end
        else
            MsgManager.showMsg("KVComplex缺少key配置：%s", self.arrayTemplate)
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
    self:super("kvbase", "setkv", config, kv, index, context)

    if kv then
        self.subkv = kv[index] or {}
    else
        self.subkv = {}
    end

    if KVComplex[config[1]] then
        self.arrayTemplate = KVComplex[config[1]][2]
    end
    self.list:setAutoData(true)
end

kvarray = M