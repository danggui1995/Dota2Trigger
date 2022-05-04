local M = class("toolbarview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Float
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "toolbarview"
end

function M:onInit()
    self.newBtn = fgui.GetComponent(self.root, "newBtn", Button)
    self.selectBtn = fgui.GetComponent(self.root, "selectBtn", Button)
    self.saveBtn = fgui.GetComponent(self.root, "saveBtn", Button)
    
    self.newBtn:onClick(function ()
        Dispatcher.dispatchEvent(EventType.ToolBar_New)
    end)
    self.selectBtn:onClick(function ()
        Dispatcher.dispatchEvent(EventType.ToolBar_Select)
    end)
    self.saveBtn:onClick(function ()
        Dispatcher.dispatchEvent(EventType.ToolBar_Save)
    end)
end

return M