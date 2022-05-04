local M = class("renameview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "renameview"
end

function M:onInit()

    self.input = self:getChild("input", InputComponent)
    self.input:onChanged(function ()
        if not self.delaySeachTimer then
            self.delaySeachTimer = Timer.ScheduleOnce(0.3, function ()
                self.delaySeachTimer = false
                self:updatelist()
            end)
        end
    end)
    self.list = self:getChild("list", List)
    self.list:setVirtual()
    self.list:setState(function (data, index, comp, obj)
        obj.title = data
    end)
    self.list:onClickItem(function ()
        self.input:setText(self.list:getSelectedData())
    end)

    self.yesBtn = fgui.GetComponent(self.root, "yesBtn", Button)
    self.noBtn = fgui.GetComponent(self.root, "noBtn", Button)
    
    self.noBtn:onClick(function ()
        self:close()
    end)
end

function M:updatelist()
    if self.listdata and #self.listdata > 0 then
        self.list:setVisible(true)
        local listdata = {}
        local filter = self.input:getText()
        for _, v in ipairs(self.listdata) do
            table.insert(listdata, v)
        end
        self.list:setDataProvider(listdata)
    else
        self.list:setVisible(false)
    end
end

function M:onOpen(inputText, callback, listdata)
    self.listdata = listdata
    self:updatelist()
    if inputText then
        self.input:setText(inputText)
    end

    self.yesBtn:onClick(function ()
        if callback then
            callback(self.input:getText())
        end
        self:close()
    end)
end

return M