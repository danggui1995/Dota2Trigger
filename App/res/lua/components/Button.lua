local M = class("Button", BaseComponent)

function M:ctor(root)
    
end

function M:getText()
    return self.root.title
end

function M:setText(value)
    self.root.title = value
end


--
function M:setSelected(selected, call)
    self.root.selected = selected
    if call then
        self:call()
    end
end
function M:isSelected()
    return self.root.selected
end

function M:call()
    self.root.onClick:Call()
end

Button = M