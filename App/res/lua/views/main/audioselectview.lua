local M = class("audioselectview", BaseView)

local tabListData = {
    {"vo", "sounds/vo", true},
    {"music", "sounds/music", true},
    {"addons", "sounds/addons", true},

    {"items", "sounds/items", true},
    {"misc", "sounds/misc", true},
    {"npc", "sounds/npc", true},
    {"physics", "sounds/physics", true},
    {"teamfancontent", "sounds/teamfancontent", true},
    {"test", "sounds/test", true},
    {"ui", "sounds/ui", true},
    {"weapons", "sounds/weapons", true},

    {"custom", "sounds", true, true},
}

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "audioselectview"
    self.fullScreenType = 1
    self.filterStr = ""
end

function M:onInit()
    local menuTb = 
    {
        {
            text = Desc.getText(1000053),
            callback = function (context)
                UIManager.openView("soundeventview", self.contentPath, self.callback)
            end
        },
    }
    
    self.list = self.root:GetChild("list")
    self.list.itemRenderer = (function (index, obj)
        obj.title = Path.GetFileName(self.listdata[index])
        obj.icon = self.listdata[index]
    end)
    self.list.onClickItem:Set(function ()
        local contentPath = self.listdata[self.list.selectedIndex]
        self.contentPath = contentPath
        Main.instance:PlayAudio(contentPath)
    end)
    self.list:SetVirtual()
    self.list.onRightClickItem:Set(function (context)
        local contentPath = self.listdata[self.list.selectedIndex]
        self.contentPath = contentPath
        PopManager.showPop("main", "PopupMenu", context.data, menuTb)
    end)

    
    self.tablist = fgui.GetComponent(self.root, "tablist", List)
    self.tablist:setState(function (data, index, comp, obj)
        obj.title = data[1]
    end)
    self.tablist:onClickItem(function ()
        self:updatelist()
    end)

    self.tablist:setDataProvider(tabListData)

    local closeBtn = fgui.GetComponent(self.root, "closeBtn", Button)
    closeBtn:onClick(function ()
        self:close()
    end)

    self.copyType = self.root:GetController("copyType")

    self.searchComp = SearchComponent.new(self.root:GetChild("search"), function (text)
        self.filterStr = text
        self:updatelist()
    end)

    VPKManager.load_soundevents()
end

function M:updatelist()
    local filter = {}
    local traverse = {}
    local customDir = {}
    for i, v in ipairs(tabListData) do
        local obj = self.tablist:getObjByIndex(i)
        if obj.selected then
            if v[4] then
                table.insert(customDir, VPKManager.getResPath(v[2], nil, true))
            else
                table.insert(filter, v[2])
                table.insert(traverse, v[3])
            end
        end
    end

    VPKManager.loadVPK(function()
        self.listdata = VRFHelper.instance:LoadItemsInDir("vsnd_c", filter, customDir, traverse, self.filterStr)
        self.list.numItems = self.listdata.Length
    end)
end

function M:onOpen(filter, callback)
    self.searchComp:setText(filter)
    self.callback = callback
end

function M:onClose()
    Main.instance:PlayAudio(nil)
end

return M