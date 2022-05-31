local M = class("abilityview", kvbaseview)

function M:ctor()
    self.packageItem = "abilityview"
    self.kvType = KVManager.Type_Ability
    self.topDataProvider = {
        {Desc[1000026], "Normal"},
        {Desc[1000027], "Event"},
        {Desc[1000028], "Modifier"},
    }
end

function M:onInit()
    self.addEventBtn = self.root:GetChild("addEventBtn")
    self.addEventBtn.onClick:Set(function ()
        PopManager.showPop("main", "PopupMenu", self.addEventBtn, self:getEventList())
    end)
    self.kvTypeCtrl = self.root:GetController("kvType")

    self:super("kvbaseview", "onInit")
end

function M:getEventList()
    if not self.eventList then
        self.eventList = {}

        local function addCallback(context)
            local index = context.sender.data + 1
            local eventList = self:getEventList()
            local key = eventList[index].text
            for index = 1, #self.unitKv - 1, 2 do
                if self.unitKv[index] == key then
                    return
                end
            end
            table.insert(self.unitKv, key)
            table.insert(self.unitKv, {})
            self.kvlist:setAutoData()
            self.kvlist:scrollToBottom()
        end

        for k, v in pairs(self.KVTemplate_Real) do
            table.insert(self.eventList, {
                text = k,
                callback = addCallback
            })
        end
        table.sort(self.eventList, function (a,b)
            return a.text < b.text
        end)
    end
    return self.eventList
end

function M:initkvlist()
    self:super("kvbaseview", "initkvlist")

    self.kvlist:setDataUpdateFunc(function ()
        self.unitKvMap = {}
        local kvListData = {}

        local typeIndex = self.toplist:getSelectedIndex()

        for index = 1, #self.unitKv - 1, 2 do
            local vIndex = index + 1
            local k = self.unitKv[index]
            local v = self.unitKv[vIndex]
            self.unitKvMap[k] = vIndex
            
            if k == "AbilityBehavior" then
                self.skillBehavior = v
            end
            if typeIndex > 1 then
                if self.KVTemplate_Real[k] then
                    local context = {isModifier = (typeIndex == 3), stackMap = {[k] = true}}
                    table.insert(kvListData, {k, context, "kvtree"})
                end
            end
        end
    
        if typeIndex == 1 then
            for _, v in ipairs(self.KVTemplate_Real) do
                local k = v[1]
                if not self.unitKvMap[k] then
                    table.insert(self.unitKv, k)
                    table.insert(self.unitKv, v[4] or "")
                    self.unitKvMap[k] = #self.unitKv
                end

                local context = {isModifier = (typeIndex == 3), stackMap = {[k] = true}}
                table.insert(kvListData, {k, context, v[2]})
            end
        else
            for k, v in pairs(kvListData) do
                v[2].skillBehavior = self.skillBehavior
            end
        end
    
        return kvListData
    end)
end

function M:onNewUnit()
    table.insert(self.allData, "ability_new")
    local t = {}
    for _, v in ipairs(self.KVTemplate.Normal) do
        table.insert(t, v[1])
        table.insert(t, v[5])
    end
    table.insert(self.allData, t)
    local cnt = self:updateunitlist()
    self.unitlist:setSelectedIndex(cnt, true)
end

function M:onTopListClicked(index)
    self.kvTypeCtrl.selectedIndex = index - 1
end

return M