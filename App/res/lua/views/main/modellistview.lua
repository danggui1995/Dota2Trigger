local M = class("modellistview", BaseView)

local tabListData = {
    {"heroes", "models/heroes", true},
    {"courier", "models/courier", true},
    {"all", "", true},
}

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "modellistview"
    self.fullScreenType = 1
    self.filterStr = ""
end

function M:onInit()
    self.list = self:getChild("list", List)
    self.list:setState(function (_, index, model, obj)
        local path = self.listdata[index - 1]
        model:setStaticBindPose(true)
        model:setModel(path, 50)
        obj.data = path
    end)

    self.list:setVirtual()
    self.list:setStencil()
    self.list:setClass(Model)

    self.list:onClickItem(function (context)
        UIManager.openView("modelselectview", {bodypath = context.data.data})
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

    self.searchComp = SearchComponent.new(self.root:GetChild("search"), function (text)
        self.filterStr = text
        self:updatelist()
    end)
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
        self.listdata = VRFHelper.instance:LoadItemsInDir("vmdl_c", filter, customDir, traverse, self.filterStr)
        self.list:setNumItems(self.listdata.Length)
    end)
end

function M:onOpen(filter, callback)
    self.searchComp:setText(filter)
    self.callback = callback
end

function M:onClose()

end

return M