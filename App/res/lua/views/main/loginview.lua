local M = class("loginview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "loginview"
    self.fullScreenType = 1
    -- self.tickInterval = 0
end

function M:onInit()
    self.newBtn = fgui.GetComponent(self.root, "newBtn", Button)
    self.newBtn:onClick(function ()
        UIManager.openView("renameview", Desc.getText(1000024), function (str)
            SettingsManager.addProject(str)

            self.listData = SettingsManager.getProjectList()
            self.list.numItems = #self.listData

            -- UIManager.openView("mainhud")
            -- self:close()
        end)
    end)

    self.listData = SettingsManager.getProjectList()
    self.list = self.root:GetChild("list")
    local function onlistClicked(context)
        local key = context.data.data
        SettingsManager.curProject = key
        local curtime = os.time()
        SettingsManager.setConfig("PROJ_OPEN_TIME", curtime)
        UIManager.openView("mainhud")
        SettingsManager.initSettings()
        self:close()
    end

    self.list.itemRenderer = function (index, obj)
        index = index + 1
        local name = obj:GetChild("name")
        local path = obj:GetChild("path")
        name.text = self.listData[index][1]
        path.text = self.listData[index][2]

        local time = obj:GetChild("time")
        local timestamp = tonumber(self.listData[index][3])
        local timestamp2 = tonumber(self.listData[index][4])
        if not timestamp2 then
            timestamp2 = timestamp
        end
        local dt = os.date("*t", timestamp)
        local timestr1 = string.format("%d-%d-%d %02d:%02d:%02d", dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
        local timestr2 = TimeUtil.getLogoutDtStr(timestamp2)
        time.text = Desc.getText(1000025, timestr2, timestr1)

        obj.data = self.listData[index][1]
    end
    self.list.onClickItem:Set(onlistClicked)

    
    self.list.numItems = #self.listData
end

return M