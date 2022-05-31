local M = class("kvbaseview", BaseView)

--[[
这里用数组而不是用字典主要是为了省掉排序的消耗，可以实时编辑，实时保存而不卡顿，同时方便版本控制文件的比对。
]]

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"

    self.groupData = false
    self.allData = false
    self.filterStr = ""
    self.kvType = KVManager.Type_Ability
end

function M:onInit()
    self.groupData = KVManager.getUnitKV(self.kvType)
    self.KVTemplate = KVManager.getUnitTemplate(self.kvType)
    
    if not self.groupData then
        return
    end

    self.empty = self.root:GetController("empty")

    self:inittoplist()
    self:initkvlist()
    self:initunitlist()
    self:initGroupList()
end

function M:inittoplist()
    self.toplist = fgui.GetComponent(self.root, "toplist", List)
    local function onTypeListClicked(context)
        local kvType = context.data.data
        if self.lastKvType == kvType then
            return
        end
        self.lastKvType = kvType
        self.KVTemplate_Real = self.KVTemplate[kvType]
        self.kvlist:removeAllChildrenToPool()
        
        self.kvlist:setAutoData()
        self:onTopListClicked(self.toplist:getSelectedIndex())
    end
    self.toplist:setState(function (data, index, comp, obj)
        obj.data = data[2]
        obj.title = data[1]
    end)

    self.toplist:onClickItem(onTypeListClicked)
    self.toplist:setDataProvider(self.topDataProvider)
end

function M:initGroupList()
    self.groupList = fgui.GetComponent(self.root, "grouplist", List)
    self.groupList:setState(function (data, index, comp, obj)
        obj.title = data
    end)
    self.groupList:onClickItem(function ()
        self.allData = self.groupData[self.groupList:getSelectedData()][KVManager.getRootKey(self.kvType)]
        self:updateunitlist()
        self:updateAllUnitNames()
    end)

    local listData = {}
    for group, _ in pairs(self.groupData) do
        table.insert(listData, group)
    end
    table.sort(listData, function (a, b)
        if a == self.kvType then
            return true
        elseif b == self.kvType then
            return false
        else
            return a < b
        end
    end)
    self.groupList:setDataProvider(listData)
    self.groupList:setSelectedIndex(1, true)
end

function M:initkvlist()
    self.kvlist = fgui.GetComponent(self.root, "kvlist", List)
    
    self.kvlist:setState(function (data, index, comp, obj)
        local key = data[1]
        comp:setkv(data, self.unitKv, self.unitKvMap[key], data[2])
    end)

    self.kvlist:setItemProvider(function (data, index)
        return _G[data[3]], fgui.GetTemplateUrl("main", data[3])
    end)

    self.kvlist:setIsRootList(true)
end

function M:updateAllUnitNames()
    self.allUnitNames = {}
    for index = 1, #self.allData / 2 - 1, 2 do
        self.allUnitNames[self.allData[index]] = true
    end
end

function M:updateunitlist()
    local listData = {}
    --列表展示会过滤Version等非table元素
    self.realIndexMap = {}
    local pointIndex = 1
    for index = 1, #self.allData - 1, 2 do
        local key = self.allData[index]
        if (self.filterStr == "" or key:find(self.filterStr)) and type(self.allData[index + 1]) == 'table' then
            table.insert(listData, {key, index})
            if key == self.lastKey then
                pointIndex = #listData
            end
        end
    end
    self.unitlist:setDataProvider(listData)
    self.unitlist:setSelectedIndex(pointIndex, true)
    return #listData
end

function M:initunitlist()
    self.unitlist = fgui.GetComponent(self.root, "unitlist", List)
    self.unitlist:setVirtual()
    self.unitlist:setState(function(data, index, comp, obj)
        local name = data[1]
        obj.title = name
    end)
    self.unitlist:onClickItem(function ()
        local ld = self.unitlist:getSelectedData()
        self.lastKey = ld[1]
        local realIndex = ld[2]
        local data = self.allData[realIndex + 1]
        if type(data) == 'table' then
            self.unitKv = data
            self.empty.selectedIndex = 0
        else
            self.empty.selectedIndex = 1
        end

        local selectedType = self.toplist:getSelectedIndex()
        if selectedType < 1 then
            self.toplist:setSelectedIndex(1, true)
        else
            self.kvlist:setAutoData()
        end

        self:onUnitListClicked()
    end)

    local searchObj = self.root:GetChild("searchComp")
    self.searchComp = SearchComponent.new(searchObj, function (text)
        self.filterStr = text
        self:updateunitlist()
    end)

    local menuTb = {
        {
            text = Desc.getText(1000013),
            callback = function (context)
                local data = self.unitlist:getSelectedData()
                local realIndex = data[2]
                local inc = 1
                local newName
                while true do
                    newName = string.format("%s_clone%d", self.allData[realIndex], inc)
                    if not self.allUnitNames[newName] then
                        break
                    end
                    inc = inc + 1
                end

                self.allUnitNames[newName] = true
                table.insert(self.allData, newName)
                table.insert(self.allData, self.allData[realIndex + 1])

                local cnt = self:updateunitlist()
                self.unitlist:setSelectedIndex(cnt, true)
            end
        },
        {
            text = Desc.getText(1000014),
            callback = function (context)
                local data = self.unitlist:getSelectedData()
                local realIndex = data[2]
                local name = self.allData[realIndex]
                table.remove(self.allData, realIndex + 1)
                table.remove(self.allData, realIndex)
                self.allUnitNames[name] = nil

                local cnt = self:updateunitlist()
                local csIndex = self.unitlist:getSelectedIndex()
                if csIndex < 1 then
                    csIndex = cnt
                end
                self.unitlist:setSelectedIndex(csIndex, true)
            end
        },
        {
            text = Desc.getText(1000021),
            callback = function (context)
                local data = self.unitlist:getSelectedData()
                local realIndex = data[2]
                UIManager.openView("renameview", self.allData[realIndex], function (input)
                    self.allData[realIndex] = input
                    self.unitlist:refreshVirtualList()
                end)
            end
        },
    }

    self.unitlist:onRightClickItem(function (context)
        PopManager.showPop("main", "PopupMenu", context.data, menuTb)
    end)
end

function M:onAddEvent()
    local saveTimer
    local function saveKV()
        if not saveTimer then
            saveTimer = Timer.ScheduleOnce(0.1, function ()
                saveTimer = nil
                KVManager.saveUnitKV(self.kvType, self.groupList:getSelectedData())
            end)
        end
    end

    self:addEvent(EventType.OnSavePressed, saveKV)
    self:addEvent(EventType.ToolBar_New, function ()
        self:onNewUnit()
    end)
    self:addEvent(EventType.ToolBar_Select, function ()
        self.unitlist:scrollToView(self.unitlist:getSelectedIndex(), true)
    end)
    self:addEvent(EventType.ToolBar_Save, saveKV)
    self:addEvent(EventType.KVUpdate_Inform_View, function ()
        self.kvlist:setAutoData()
    end)
end


---tobe override
function M:onUnitListClicked()
    
end

---tobe override
function M:onNewUnit()

end

--override
function M:onTopListClicked(index)
    
end

kvbaseview = M