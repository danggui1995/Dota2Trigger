local M = class("mainhud", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.MainHud
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "mainhud"
    self.fullScreenType = 1
    -- self.tickInterval = 0
end

local tabConfig = {
    {"settingview", Desc[1000006], true},
    {"toolview", Desc[1000001], true},
    -- {"unitview", Desc[1000005]},
    -- {"heroview", Desc[1000015]},
    -- {"abilityview", Desc[1000016]},
    -- {"itemview", Desc[1000017]},
    -- {"herolistview", Desc[1000022]},
    -- {"overrideview", Desc[1000023]},
    -- {"triggerview", Desc[1000018]},
    -- {"timelineview", Desc[1000019]},
    -- {"aiview", Desc[1000020]},
    {"textureselectview", Desc[1000050]},
    {"audioselectview", Desc[1000051]},
    {"modellistview", "模型列表"},
    -- {"soundeventview", Desc[1000052]},
}

function M:onInit()
    self.tabList = self:getChild("tabList", List)

    local function onTabListClicked(context)
        if self.lastView then
            UIManager.closeView(self.lastView)
        end
        self.lastView = context.data.data
        UIManager.openView(self.lastView)
    end

    self.tabList:setState(function (data, index, comp, obj)
        obj.title = data[2]
        obj.data = data[1]
    end)
    self.tabList:onClickItem(onTabListClicked)

    self.tabList:setDataProvider(tabConfig)
    self.tabList:setSelectedIndex(1, true)

    VPKManager.loadVPK()
    VPKManager.load_items_game()
end

function M:onAddEvent()

end

return M