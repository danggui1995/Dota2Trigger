local M = class("InputComponent", BaseComponent)

function M:ctor(root)

end

function M:getText()
    return self.root.text
end

function M:setText(value)
    self.root.text = value
end

InputComponent = M