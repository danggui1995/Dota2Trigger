local M = class("settingview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "settingview"
end

local config = {
    {Desc[1000007], "ENGINE_PATH", "BaseComponent", "kvinput"},
    {Desc[1000008], "GAME_PATH", "BaseComponent", "kvinput"},
    {Desc[1000009], "CONTENT_PATH", "BaseComponent", "kvinput"},
    {Desc[1000044], "THREAD_COUNT", "NumberComponent", "kvnumber"},
}

function M:onInit()
    self.list = fgui.GetComponent(self.root, "list", List)

    local function onInputChanged(context)
        local conf = config[context.sender.data]
        SettingsManager.setConfig(conf[2], context.sender.text)
        SettingsManager.saveConfig()
    end

    self.list:setState(function (data, index, comp, obj)
        local title = fgui.GetComponent(obj, "title", Label)
        title:setText(config[index][1])

        if data[4] == "kvnumber" then
            comp:setData(index)
            comp:onChanged(onInputChanged)
            comp:setValue(SettingsManager.getConfig(config[index][2]))
        else
            local input = fgui.GetComponent(obj, "input", InputComponent)
            input:setText(SettingsManager.getConfig(config[index][2]))
            input:setData(index)
            input:onChanged(onInputChanged)
        end
    end)

    self.list:setItemProvider(function (data, index)
        return _G[data[3]], fgui.GetTemplateUrl("main", data[4])
    end)
    self.list:setDataProvider(config)

    self.applyBtn = fgui.GetComponent(self.root, "applyBtn", Button)
    self.applyBtn:onClick(function ()
        SettingsManager.saveConfig()
    end)
end

return M