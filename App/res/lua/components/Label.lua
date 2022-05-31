local M = class("Label", BaseComponent)

function M:getText()
    return self.root.text
end

function M:setText(value)
    self.root.text = value
end

Label = M