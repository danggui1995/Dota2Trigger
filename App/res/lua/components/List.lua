local M = class("List", BaseComponent)

function M:ctor()
    self._dataProvider = {}
    self._cachedComponents = {}
    self._dataCompType = {}
    self._dataUpdateFunc = false
    self._class = BaseComponent
    self._isRootList = false
end


-- 设置虚拟列表
function M:setVirtual()
    self.root:SetVirtual()
end



-- 循环列表只支持单行或者单列的布局，不支持流动布局和分页布局。
function M:setLoop()
    self.root:SetVirtualAndLoop()
end

-- 当点击某个item时，如果这个item处于部分显示状态，那么列表将会自动滚动到整个item显示完整。
function M:scrollItemToViewOnClick(bool)
    self.root.scrollItemToViewOnClick = bool
end

-- 自动大小
function M:setAutoResizeItem(bool)
    self.root.autoResizeItem = bool
end

--------------------------------------------------
function M:onClickItem(func, skipSame)
    -- function (context)
    if skipSame then
        self.root.onClickItem:Set(function (...)
            local index = self.root.selectedIndex
            if index ~= self.__lastSelectedIndex then
                self.__lastSelectedIndex = index
                func(...)
            end
        end)
    else
        self.root.onClickItem:Set(func)
    end
end

function M:onRightClickItem(func)
    self.root.onRightClickItem:Set(func)
end

-- 设置多样式虚拟列表
function M:setItemProvider(func)
    -- function (index)
    self.root.itemProvider = function(index)
        local luaIndex = index + 1
        local comp, url = func(self._dataProvider[luaIndex], luaIndex)
        self._dataCompType[luaIndex] = comp
        return url
    end
end

function M:setClass(claType, args)
    self._class = claType
    if args ~= nil then
        self._classArgs = args
    end
end


---@alias GlistHandler fun(data: any,index:number,comp:GComponent,obj:any):void

---@param func GlistHandler
function M:setState(func)
    self.root.itemRenderer = function(index, obj)
        local luaIndex = index + 1
        local comp = self._cachedComponents[obj]
        if comp == nil then
            if self._dataCompType[luaIndex] then
                comp = self._dataCompType[luaIndex].new(obj)
            else
                comp = self._class.new(obj, self._classArgs)
            end

            self._cachedComponents[obj] = comp
        end
        func(self._dataProvider[luaIndex], luaIndex, comp, obj)
    end
end

function M:getDataTemplate()
    return self._cachedComponents
end

function M:setDataProvider(array)
    if array then
        self._dataProvider = array
    else
        self._dataProvider = {}
    end
    self:setNumItems(#self._dataProvider)
end

function M:getDataProvider()
    return self._dataProvider
end

-- 刷新列表
function M:refreshVirtualList()
    self.root:RefreshVirtualList()
end

-- 重新设置长度大小
function M:resizeToFit(count)
    if count == nil then
        count = self.root.numItems
    end
    return self.root:ResizeToFit(count)
end



--------------------------------------------------

-- 移动scroll
function M:scrollToView(index, action)
    if action == nil then
        action = false
    end
    if index < 1 then
        index = 1
    end
    self.root:ScrollToView(index - 1, action)
end

function M:scrollToTop(action)
    self:scrollToView(1, action)
end

function M:scrollToBottom(action)
    self:scrollToView(#self._dataProvider, action)
end


-- 设置数量
function M:setNumItems(num)
    self.root.numItems = num
end
function M:getNumItems()
    return self.root.numItems
end

-- 获取当前选中的data
function M:getSelectedData()
    -- lua从1开始，底层是从0开始
    local index = self:getSelectedIndex()
    if index then
        return self._dataProvider[index]
    end
end

-- 获取当前选中第几个，list里面的item是单选按钮才生效
function M:getSelectedIndex()
    -- lua从1开始，底层是从0开始
    return self.root.selectedIndex + 1
end

function M:getSelectedComp()
    return self:getCompByIndex(self:getSelectedIndex())
end

---获取视野中的第一个子物体下标
function M:getFirstChildInView()
    if not self.root then
        return 0
    end
    return self.root:GetFirstChildInView() + 1
end

-- //转换项目索引为显示对象索引。
-- int childIndex = aList.ItemIndexToChildIndex(1);
-- //转换显示对象索引为项目索引。
-- int itemIndex = aList.ChildIndexToItemIndex(1);
function M:setSelectedKey(key, click)
    local index = 1
    for k, v in ipairs(self._dataProvider) do
        if v.key == key then
            index = k
        end
    end
    self:setSelectedIndex(index, click)
end

-- 选中第index个，并且触发点击事件，list里面的item是单选按钮才生效
function M:setSelectedIndex(index, click)
    -- lua从1开始，底层是从0开始
    -- self.root.selectedIndex = index - 1

    if self.root.numChildren == 0 then
        return
    end

    local realIndex = index - 1
    if click then
        -- 先判断是否在显示列表
        local childIndex = self.root:ItemIndexToChildIndex(realIndex)
        if childIndex >= 0 and childIndex < self.root.numChildren - 1 then
            -- 如果index在显示列表中，则不需要scrollItToView，最后再点击
            self.root:AddSelection(realIndex, false)
            self.root.onClickItem:Call(self.root:GetChildAt(childIndex))
        else
            -- 如果index不在显示列表中，则需要scrollItToView，才能找对显示对象，最后再点击
            self.root:AddSelection(realIndex, true)
            local curIndex = self.root:ItemIndexToChildIndex(realIndex)
            self.root.onClickItem:Call(self.root:GetChildAt(curIndex))
        end
    else
        self.root:AddSelection(realIndex)
    end
end

function M:addSelection(index, scrollItToView)
    if scrollItToView == nil then
        scrollItToView = false
    end
    self.root:AddSelection(index - 1, scrollItToView)
end

-- 获取全部选中
function M:getSelection()
    return self.root:GetSelection()
end

-- 取消某个选中
function M:removeSelection(index)
    self.root:RemoveSelection()
end

function M:removeChildrenToPool(start, stop)
    self.root:RemoveChildrenToPool(start, stop)
end
-- 取消全部选择
function M:clearSelection()
    return self.root:ClearSelection()
end

-- 反选
function M:selectReverse()
    return self.root:SelectReverse()
end


--强制刷新当前选中的项 这个选择是有bug的 - 待处理 - alonso
function M:forceRefreshSelectedItem(index)
    local selectedIndex
    if index then
        selectedIndex = index - 1
    else
        selectedIndex = self.root.selectedIndex
    end
    local childIndex = self.root:ItemIndexToChildIndex(selectedIndex)
    if childIndex >= 0 and childIndex < self.root.numChildren then
        local item = self.root:GetChildAt(childIndex)
        self.root.itemRenderer(selectedIndex, item)
    end
end

--------------------------------------------------
function M:onPullDownRelease(func)
    self.root.scrollPane.onPullDownRelease:Set(func)
end

function M:onPullUpRelease(func)
    self.root.scrollPane.onPullUpRelease:Set(func)
end

function M:getHeader()
    return self.root.scrollPane.header
end

function M:getScrollStep()
    return self.root.scrollPane.scrollStep
end

function M:getFooter()
    return self.root.scrollPane.footer
end

function M:itemIndexToChildIndex(index)
    -- lua从1开始，底层是从0开始
    return self.root:ItemIndexToChildIndex(index - 1)
end
function M:childIndexToItemIndex(index)
    -- lua从1开始，底层是从0开始
    return self.root:ChildIndexToItemIndex(index - 1)
end

function M:setSelectionMode(mode)
    self.root.selectionMode = mode
end

function M:getSelectionMode()
    return self.root.selectionMode
end

function M:getSelectedNode(index)
    index = index or self:getSelectedIndex()
    local childIndex = self.root:ItemIndexToChildIndex(index - 1)
    if childIndex >= 0 and childIndex < self.root.numChildren then
        local item = self.root:GetChildAt(childIndex)
        return item
    end
end

function M:getSelectionComp(index)
    local item = self:getSelectedNode(index)
    return self._cachedComponents[item]
end

-- 获取某个索引的组件
function M:getCompByIndex(index)
    local childIndex = self.root:ItemIndexToChildIndex(index - 1)
    if childIndex >= 0 and childIndex < self.root.numChildren then
        local obj = self.root:GetChildAt(childIndex)
        return self._cachedComponents[obj]
    end
end

function M:getObjByIndex(index)
    local childIndex = self.root:ItemIndexToChildIndex(index - 1)
    if childIndex >= 0 and childIndex < self.root.numChildren then
        return self.root:GetChildAt(childIndex)
    end
end

-- 返回当前滚动位置是否在最下边
function M:isBottomMost()
    return self.root.scrollPane.isBottomMost
end

function M:isRightMost()
    return self.root.scrollPane.isRightMost
end

-- 在滚动结束时派发该事件。
function M:onScrollEnd(func)
    self.root.scrollPane.onScrollEnd:Set(func)
end

function M:onScroll(func)
    self.root.scrollPane.onScroll:Set(func)
end

function M:removeOnScroll(func)
    self.root.scrollPane.onScroll:Remove(func)
end

function M:setColumnCount(count)
    self.root.columnCount = count
end

function M:setLineCount(count)
    self.root.lineCount = count
end

function M:getColumnGap()
    return self.root.columnGap
end

function M:getLineGap()
    return self.root.lineGap
end

function M:getNumChildren()
    return self.root.numChildren
end

function M:getViewWidth()
    return self.root.viewWidth
end


----- 自增接口 -----

-- 加一层遮罩
function M:setStencil()
    -- self.root:SetVirtual()
    -- 弄一个组件和list一样大
    -- 弄一个shape当做遮罩
    -- 把这个list放入这个组件

    local component = fgui.newComponent({
        xy = self:getXY(),
        -- size = self.root.size,
    })
    local graph = fgui.newGraph({
        xy = Vector2(0, 0),
        size = self.root.size,
        rect = {
            lineSize = 1,
            lineColor = Color.black,
            fillColor = Color.black,
        }
    })
    local parent = self:getParent()
    self:removeFromParent()
    self:setXY(0, 0)
    parent:AddChild(component:getObj())
    component:addChild(graph)
    component:addChild(self)
    graph:addRelation(self.root, FairyGUI.RelationType.Size)
    component.root.mask = graph.root.displayObject
end

function M:setDataUpdateFunc(func)
    self._dataUpdateFunc = func
end

function M:setAutoData(bResize)
    if not self._dataUpdateFunc then
        printError("not setDataUpdateFunc, cannot use this function")
        return
    end

    if bResize then
        self:removeAllChildrenToPool()
    end

    local listdata = self._dataUpdateFunc()
    self:setDataProvider(listdata)

    if bResize and not self._isRootList then
        self:resizeToFit()
    end
end

--是否是最上面的列表，将不执行resize
function M:setIsRootList(value)
    self._isRootList = value
end

function M:removeAllChildrenToPool()
    self.root:RemoveChildrenToPool(0, #self._dataProvider)
end

List = M