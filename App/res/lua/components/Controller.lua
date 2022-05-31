local M = class("Controller")

function M:ctor(obj)
    self.root = obj
end

function M:init(obj)
end

function M:getObj()
    return self.root
end

function M:setSelectedIndex(index)
    self.root.selectedIndex = index
end

function M:getSelectedIndex()
    return self.root.selectedIndex
end

function M:getPreviousIndex()
    return self.root.previsousIndex
end

function M:setSelectedName(name)
    --local id = self.root:GetPageIdByName(name)
    --self.root.selectedIndex = id
    self.root.selectedPage = name
end

function M:getSelectedName()
    local id = self:getSelectedIndex()
    return self.root:GetPageName(id)
end

---获取页面数量
function M:getPageCount()
    return self.root.pageCount
end

function M:addPage(name)
    self.root:AddPage(name)
end

function M:onChanged(func)
    self.root.onChanged:Add(func)
end

function M:clearPages()
    self.root:ClearPages()
end

Controller = M
