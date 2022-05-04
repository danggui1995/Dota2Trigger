local M = class("SearchComponent", BaseComponent)

function M:ctor(root, callback)

    self.delaySearch = function ()
        if callback then
            callback(self.input:getText())
        end
        self.delaySearchHandler = false
    end

    self.input = fgui.GetComponent(root, "input", InputComponent)
    self.input:onChanged(function ()
        self:onInputUpdate()
    end)
    self.btn = fgui.GetComponent(root, "btn", Button)
    self.btn:onClick(function ()
        self.input:setText("")
        if callback then
            callback(self.input:getText())
        end
    end)
end

function M:onInputUpdate()
    if not self.delaySearchHandler then
        self.delaySearchHandler = Timer.ScheduleOnce(0.5, self.delaySearch)
    end
end

function M:setText(v)
    self.input:setText(v)
    self:onInputUpdate()
end

SearchComponent = M