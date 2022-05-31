local M = class("DropDown", BaseComponent)

function M:ctor(obj)
	self._dataProvider = false
	self.buttonCtrl = false

    self.buttonCtrl  = self:getController("button")
	if self.buttonCtrl then
		self:onClosed(function ()
			if self.root.dropdown.isDisposed then return end
			self.buttonCtrl:setSelectedIndex(0)
		end)
	end
end

function M:setList(list)
	self.root.items = list
end

function M:setVirtual()
	self.root.list:SetVirtual()
end

function M:getList()
	return self.root.items
end

function M:getSelectedText(  )
	return self.root.items[self.root.selectedIndex]
end

function M:setSelectedIndex(index, call)
	self.root.selectedIndex = index - 1
	if call then
		self.root.onChanged:Call()
	end
end

function M:getSelectedIndex()
	return self.root.selectedIndex + 1
end

function M:getSelectedData()
	if self._dataProvider then
		local index = self:getSelectedIndex()
		return self._dataProvider[index]
	end
end

function M:setText(text)
	self.root.title = text
end
function M:getText()
	return self.root.title
end

function M:setDataProvider(array)
	self._dataProvider = array
end

function M:getDataProvider()
	return self._dataProvider
end

function M:setVisibleItemCount(count)
	self.root.visibleItemCount = count
end


function M:onClosed(func)
	return self.root.dropdown.onRemovedFromStage:Set(func)
end

--[[
FairyGUI.PopupDirection
Auto
Up
Down
]]
function M:setPopupDirection(dir)
	self.root.popupDirection = dir
end

function M:keepVisibleAfterClick(value)
	self.root.keepVisibleAfterClick = value
end

function M:onItemRendered(func)
	self.root.onItemRendered = function(item)
		local index = item.data + 1
		func(self._dataProvider[index], index, item)
	end
end

DropDown = M
