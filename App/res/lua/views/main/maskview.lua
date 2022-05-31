local M = class("maskview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Bottom
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "maskview"
    self.fullScreenType = 1
    -- self.tickInterval = 0
end

return M