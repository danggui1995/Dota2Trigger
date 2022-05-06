local M = class("modelselectview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "modelselectview"

    self.callback = false
    self.curid = false
    self.filterStr = ""

    self.model = false
    self.list = false
    self.searchComp = false
    self.closeBtn = false
    self.testlist = false

    self.itemIdSlotMap = false
end

function M:getSlot(id)
    if self.itemsKV[id] then
        local item_slot = self.itemsKV[id]["item_slot"]
        local model_player = self.itemsKV[id]["model_player"]
        if not item_slot then
            item_slot = model_player
        end
        return item_slot
    end
    return ""
end

function M:onInit()
    self.model = fgui.GetComponent(self.root, "model", Model)

    self.list = fgui.GetComponent(self.root, "list", List)
    
    self.list:setVirtual()
    self.list:setStencil()
    self.list:setClass(Model)
    self.list:setState(function (data, index, comp, obj)

        comp:setStaticBindPose(true)
        comp:setModel(data[3], 50)
        
        obj.data = data
    end)

    self.list:onClickItem(function (context)
        local config = context.data.data
        local id = config[1]

        if self.AttachWearables then
            local listdata = self.testlist:getDataProvider()

            local isAdd = true
            local sameSlot = false
            local mySlot = self:getSlot(id)
            for _, v in pairs(listdata) do
                if v == id then
                    isAdd = false
                else
                    local item_slot = self:getSlot(v)
                    if mySlot == item_slot then
                        sameSlot = v
                    end
                end
            end

            if sameSlot then
                self:removewear(sameSlot)
            end

            if isAdd then
                table.insert(self.AttachWearables, "1")
            
                local t = {}
                table.insert(t, "ItemDef")
                table.insert(t, tostring(id))
                table.insert(self.AttachWearables, t)
            else
                self:removewear(id)
            end

            self:updatetestlist()

            Dispatcher.dispatchEvent(EventType.KVUpdate_Inform_View)
            Dispatcher.dispatchEvent(EventType.OnSavePressed)
        end
    end)

    local searchObj = self.root:GetChild("search")
    self.searchComp = SearchComponent.new(searchObj, function (text)
        self.filterStr = text
        self:updatemodellist()
    end)

    self.closeBtn = fgui.GetComponent(self.root, "closeBtn", Button)
    self.closeBtn:onClick(function ()
        self:close()
    end)

    local function onTestListClicked(context)
        if not self.AttachWearables then
            return
        end

        self:removewear(context.sender.data)
        Dispatcher.dispatchEvent(EventType.OnSavePressed)
        Dispatcher.dispatchEvent(EventType.KVUpdate_Inform_View)
        self:updatetestlist()
    end
    self.testlist = fgui.GetComponent(self.root, "testlist", List)
    self.testlist:setState(function (data, index, comp, obj)
        local title = obj:GetChild("title")
        local subBtn = obj:GetChild("subBtn")
        subBtn.onClick:Set(onTestListClicked)
        title.text = data
        subBtn.data = data
    end)


    self.animlist = fgui.GetComponent(self.root, "animlist", List)
    self.animlist:setState(function (data, index, comp, obj)
        local title = obj:GetChild("title")
        local str = data[1]
        if data[2] then
            str = str .. "|" ..data[2]
        end
        title.text = str
    end)
    self.animlist:onClickItem(function ()
        local data = self.animlist:getSelectedData()
        self.model:play(data[1])
        MsgManager.copyToClipBorad(data[2])
    end)
    self.animlist:setVirtual()

    local btnShowPrecache = self:getChild("btnShowPrecache", Button)
    btnShowPrecache:onClick(function ()
        local data = self.testlist:getDataProvider()
        local list = {}
        for _, v in ipairs(data) do
            local model_player = self.itemsKV[v]["model_player"]
            if model_player then
                table.insert(list, string.format("\"%s\",\n", model_player))
            end
        end
        MsgManager.copyToClipBorad(table.concat(list, ''))
    end)

    local btnWearId = self:getChild("btnWearId", Button)
    btnWearId:onClick(function ()
        local data = self.testlist:getDataProvider()
        local list = {}
        for i, v in ipairs(data) do
            table.insert(list, string.format("\"%s\"	{\"ItemDef\"	\"%s\"}\n", i, v))
        end
        MsgManager.copyToClipBorad(table.concat(list, ''))
    end)
end

function M:resortAttachWearables()
    local index = 1
    for i = 1, #self.AttachWearables, 2 do
        self.AttachWearables[i] = tostring(index)
        index = index + 1
    end
end

function M:removewear(id)
    id = tonumber(id)
    for index = 1, #self.AttachWearables - 1, 2 do
        local k = self.AttachWearables[index]
        local v = self.AttachWearables[index + 1]

        local vid = math.floor(v[2])
        if vid == id then
            table.remove(self.AttachWearables, index + 1)
            table.remove(self.AttachWearables, index)
            break
        end
    end
end

function M:updatemodellist()

    VPKManager.load_items_game(function(kv, kvMap)
        if not self.itemsKV then
            self.itemsKV = kvMap
        end
        local listdata = {}
        local pointIndex = 1
        
        for _, v in ipairs(kv) do
            if v[3]:find(self.filterStr) then
                table.insert(listdata, v)
                if v[1] == self.curid then
                    pointIndex = #listdata
                end
            end
        end
        self.list:setDataProvider(listdata)
        self.list:scrollToView(pointIndex)
    end)
end

function M:updatetestlist()
    if not self.AttachWearables then
        return
    end
    local listdata = {}
    local oldlist = self.testlist:getDataProvider()
    for index = 1, #self.AttachWearables - 1, 2 do
        local k = self.AttachWearables[index]
        local v = self.AttachWearables[index + 1]
        table.insert(listdata, tostring(math.floor(v[2])))
    end
    table.sort(listdata, function (a, b)
        return a < b
    end)
    self.testlist:setDataProvider(listdata)

    --实际穿戴
    local rc = {}
    for _, id in pairs(listdata) do
        if self.itemsKV[id] then
            rc[id] = true
        end
    end
    for _, id in pairs(oldlist) do
        if self.itemsKV[id] and not rc[id] then
            local item_slot = self:getSlot(id)
            self.model:unloadPart(item_slot)
        end
    end

    for id, _ in pairs(rc) do
        local item_slot = self.itemsKV[id]["item_slot"]
        local model_player = self.itemsKV[id]["model_player"]
        if not item_slot then
            item_slot = model_player
        end
        if model_player then
            self.model:setPart(item_slot, model_player)
        end
    end

    --整理一下 防止key一样
    self:resortAttachWearables()
end

function M:onOpen(context, callback)
    self.callback = callback
    self.curid = context.id

    local bodypath
    if context.view and context.view.unitKv then
        local unitKv = context.view.unitKv
        for index = 1, #unitKv - 1, 2 do
            local k = unitKv[index]
            if k == "Model" then
                bodypath = unitKv[index + 1]
            elseif k == "Creature" then
                local creature = unitKv[index + 1]
                for index = 1, #creature - 1, 2 do
                    local k = creature[index]
                    if k == "AttachWearables" then
                        self.AttachWearables = creature[index + 1]
                        break
                    end
                end
            end
        end
    else
        bodypath = context.bodypath
        self.AttachWearables = {}
    end

    local partpath = context.partpath
    if not partpath then
        partpath = bodypath
    end

    if partpath and partpath ~= "" then
        partpath = Path.GetDirectoryName(partpath)
    end
    self.filterStr = partpath:gsub("\\", "/")
    self.searchComp:setText(self.filterStr)

    self:updatemodellist()

    self.model:setModel(bodypath, 90)
    self.model:onModelLoaded(function (animUpdater)
        local listdata = {}
        local arr = animUpdater:GetAnimationList()
        for index = 0, arr.Length - 1 do
            table.insert(listdata, string.split(arr[index], "|"))
        end
        self.animlist:setDataProvider(listdata)
        animUpdater:PlayDefaultAnimation()
    end)
    self.model:autoBones()
    self:updatetestlist()
end

function M:onClose()
    self.animUpdater = nil
end

return M