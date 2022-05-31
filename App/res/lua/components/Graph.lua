local M = class("Graph", BaseComponent)

function M:ctor(root)
    
end

function M:drawRect(width, height, lineSize, lineColor, fillColor)
    self.root:DrawRect(width, height, lineSize, lineColor, fillColor)
end

Graph = M