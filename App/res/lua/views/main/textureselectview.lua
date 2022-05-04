local M = class("textureselectview", BaseView)

local tabListData = {
    {Desc[1000045], "panorama/images/heroes", false},
    {Desc[1000048], "panorama/images/heroes/icons", false},
    {Desc[1000049], "panorama/images/heroes/selection", false},

    {Desc[1000046], "panorama/images/spellicons", true},
    {Desc[1000047], "panorama/images/items", false},
    {"custom", "panorama/images/custom_game", true, true},
}

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "textureselectview"
    self.fullScreenType = 1
    self.filterStr = ""
end

function M:onInit()
    self.list = self.root:GetChild("list")
    self.list.itemRenderer = (function (index, obj)
        obj.title = Path.GetFileName(self.listdata[index])
        obj.icon = self.listdata[index]
    end)
    self.list.onClickItem:Set(function ()
        local textureName = Tools.GetVTextureName(self.listdata[self.list.selectedIndex])
        if self.callback then
            self.callback(textureName)
        else
            if self.copyType.selectedIndex == 0 then
                MsgManager.copyToClipBorad(textureName)
            else
                MsgManager.copyToClipBorad(self.listdata[self.list.selectedIndex])
            end
        end
    end)
    self.list:SetVirtual()

    
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
        self.listdata = VRFHelper.instance:LoadItemsInDir("vtex_c", filter, customDir, traverse, self.filterStr)
        self.list.numItems = self.listdata.Length
    end)
end

function M:onOpen(filter, callback)
    self.searchComp:setText(filter)
    self.callback = callback
end

return M