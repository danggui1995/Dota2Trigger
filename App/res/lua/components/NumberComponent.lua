local M = class("NumberComponent", BaseComponent)

function M:ctor(root)
    self.lerpValue = 1
    self.addBtn = fgui.GetComponent(root, "addBtn", Button)
    self.addBtn:onClick(function ()
        local newValue = tonumber(self.input:getText()) + self.lerpValue
        self.input:setText(newValue)
        if self._onChanged then
            self._onChanged(self.context)
        end
    end)
    self.subBtn = fgui.GetComponent(root, "subBtn", Button)
    self.subBtn:onClick(function ()
        local newValue = tonumber(self.input:getText()) - self.lerpValue
        self.input:setText(newValue)
        if self._onChanged then
            self._onChanged(self.context)
        end
    end)
    self.input = fgui.GetComponent(root, "input", InputComponent)
    self.input:onChanged(function ()
        if self._onChanged then
            self._onChanged(self.context)
        end
    end)
    self.context = {sender = self.input:getObj()}
end

function M:onChanged(func)
    self._onChanged = func
end

function M:setValue(value)
    self.input:setText(value)
end

function M:setData(value)
    self.input:setData(value)
end

NumberComponent = M