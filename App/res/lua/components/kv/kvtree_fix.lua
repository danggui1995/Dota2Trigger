local M = class("kvtree_fix", kvbase)

--固定的tree 不可添加和删除元素
function M:ctor(root)
    self.title = root:GetChild("title")

    self.list = fgui.GetComponent(root, "list", List)
    self.list:setState(function(data, index, comp, obj)
        comp:setkv(data, self.subkv, data[6], self._context)
    end)
    self.list:setItemProvider(function(data, index)
        local compType = data[3]
        return fgui.GetTemplateClass(compType), fgui.GetTemplateUrl("main", compType)
    end)
    self.list:setDataUpdateFunc(function ()
        local listdata = {}
        for index = 1, #self.subkv - 1, 2 do
            local k = self.subkv[index]
            local v = self.subkv[index + 1]
            local subTreeInfo = KVComplex[k]
            table.insert(listdata, {k, fgui.GetKeyLang(k), subTreeInfo[1], subTreeInfo[2], subTreeInfo[3], index + 1})
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

function M:fixSubkv()
    if not self.subkv or #self.subkv == 0 then
        self.subkv = {}
        self._parentKV[self._valueIndex] = self.subkv

        local map = {}
        for index = 1, #self.subkv - 1, 2 do
            map[self.subkv[index]] = true
        end

        local treeInfo = KVComplex[self.curkey]
        if treeInfo then
            for index = 2, #treeInfo do
                local k = treeInfo[index]
                table.insert(self.subkv, k)

                local subInfo = KVComplex[k]
                if subInfo[1] == "kvtree_fix" or subInfo[1] == "kvarray" or subInfo[1] == "kvtree" then
                    table.insert(self.subkv, {})
                else
                    table.insert(self.subkv, subInfo[3])
                end
            end
        end
    end
end

function M:setkv(config, kv, index, context)
    self.curkey = config[1]
    self.title.text = fgui.GetKeyLang(self.curkey)
    self._parentKV = kv
    self._valueIndex = index

    self._context = clone(context)
    self._context.stackMap[self._parentKV[index - 1]] = true

    self.subkv = kv[index]
    self:fixSubkv()
    self.list:setAutoData(true)
end

kvtree_fix = M