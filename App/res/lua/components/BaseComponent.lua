local M = class("BaseComponent")

function M:ctor(root)
    self.root = root
    self._controllers = {}
    self._children = {}

    root.onAddedToStage:Set(function()
        self:onEnter()
    end)

    root.onRemovedFromStage:Set(function()
        self:onExit()
    end)
end

function M:init()

end

function M:onClick(func)
    self.root.onClick:Set(func)
end


function M:setBaseAttr(params)
    params = params or {}

    if params.sortingOrder then
        self.root.sortingOrder = params.sortingOrder
    end

    if params.xy then
        self.root.xy = params.xy
    end
    if params.size then
        self.root.size = params.size
    end
    if params.pivot then
        self.root.pivot = params.pivot
    end
    if params.pivotAsAnchor then
        self.root.pivotAsAnchor = params.pivotAsAnchor
    end

    if params.parent then
        params.parent:addChild(self)
    end
    if params.center then
        self.root:Center()
    end
end

function M:getChildObj(name)
    return self.root:GetChild(name)
end

function M:getChildrenObj()
    return self.root:GetChildren()
end

function M:getObj()
    return self.root
end

function M:addChild(comp)
    self.root:AddChild(comp:getObj())
    -- bug在addChild后setName不会改变父节点的children
    self._children[comp:getName()] = comp
end
function M:addChildAt(comp, idx)
    self.root:AddChildAt(comp:getObj(), idx)
end

function M:removeChild(comp, isDisposed)
    if isDisposed == nil then
        isDisposed = false
    end
    self.root:RemoveChild(comp:getObj(), isDisposed)
end
function M:removeChildren()
    self.root:RemoveChildren()
end

function M:removeFromParent()
    self.root:RemoveFromParent()
end

function M:setChildIndex( child, index )
    self.root:SetChildIndex(child, index)
end

function M:getChildIndex( child )
    return self.root:GetChildIndex(child)
end


function M:setText(text)
    if text then
        self.root.text = text
    else
        self.root.text = ""
    end
end

function M:getTransition(name)
    return self.root:GetTransition(name)
end

-- 接收拖放之后的【放】
function M:onDrop(func)
    self.root.onDrop:Set(func)
end

function M:removeAllChildren(isDisposed)
    self.root:RemoveChildren(0, -1, isDisposed)
end


function M:setZIndex(index)
    local oldIndex = self:getZIndex()
    if oldIndex >= index then
        self.root.parent:SetChildIndexBefore(self.root, index)
    else
        self.root.parent:SetChildIndex(self.root, index)
    end
end

function M:getZIndex(comp)
    return self.root.parent:GetChildIndex(self.root)
end


function M:setChildBefore(child)
    local childIndex = self.root.parent:GetChildIndex(child:getObj())
    self.root.parent:SetChildIndexBefore(self.root, childIndex)
end


function M:swapChildren(child1, child2)
    self.root:SwapChildren(child, child2)
end

------------------

-- x
function M:setX(x)
    self.root.x = x
end
function M:getX()
    return self.root.x
end
-- y
function M:setY(y)
    self.root.y = y
end
function M:getY()
    return self.root.y
end

-- x, y
function M:setXY(x, y)
    self.root.xy = Vector2(x, y)
end
function M:getXY()
    return Vector2(self.root.x, self.root.y)
end

function M:setZ(z)
    self.root.z = z
end

function M:setXYZ(x, y, z)
    self.root.x = x
    self.root.y = y
    self.root.z = z
end
function M:getXYZ()
    return Vector3(self.root.x, self.root.y, self.root.z)
end

function M:shiftX(x)
    self.root.x = self.root.x + x
end

function M:shiftY(y)
    self.root.y = self.root.y + y
end

-- 锚点在左上角的时候
function M:getCenter()
    local size = self:getSize()
    return Vector2(self.root.x + size.x / 2, self.root.y + size.y / 2)
end

-- 大小
function M:setWidth(width)
    self.root.width = width
end
function M:getWidth()
    return self.root.width
end
function M:setHeight(height)
    self.root.height = height
end
function M:getHeight()
    return self.root.height
end

function M:setMaxWidth(width)
    self.root.maxWidth = width
end
function M:setMaxHeight(height)
    self.root.maxHeight = height
end
function M:setMinWidth(width)
    self.root.minWidth = width
end
function M:setMinHeight(height)
    self.root.minHeight = height
end
function M:setInitWidth()
    self.root.width = self.root.initWidth
end
function M:getInitWidth()
    return self.root.initWidth
end
function M:setInitHeight()
    self.root.height = self.root.initHeight
end
function M:getInitHeight()
    return self.root.initHeight
end

function M:setViewHeight(height)
    self.root.viewHeight = height
end
function M:getViewHeight()
    return self.root.viewHeight
end

function M:getSize()
    return Vector2(self.root.width, self.root.height)
end

function M:setSize(width, height)
    self.root:SetSize(width, height)
end

function M:getSourceSize()
    return Vector2(self.root.sourceWidth, self.root.sourceHeight)
end

-- 轴心
function M:setPivot(x, y, asAnchor)
    self.root:SetPivot(x, y, asAnchor)
end
function M:getPivot()
    return self.root.pivot
end


-- 数据
function M:setData(data)
    self.root.data = data
end
function M:getData(data)
    return self.root.data
end

-- 设置拖拽
function M:setDraggable(able)
    self.root.draggable = able
end
function M:getDraggable()
    return self.root.draggable
end

function M:isOnStage()
    return self.root.onStage
end

-- 显示
function M:setVisible(visible)
    if visible == self:isVisible() then
        return
    end
    self.root.visible = visible
end
function M:isVisible()
    return self.root.visible
end

function M:setSortingOrder(order)
    self.root.sortingOrder = order
end


-- 是否灰显
function M:setGrayed(grayed)
    self.root.grayed = grayed
end
function M:getGrayed()
    return self.root.grayed
end

-- 是否可点击
function M:setTouchable(able)
    self.root.touchable = able
end

function M:getTouchable(value)
    return self.root.touchable
end

-- 是否可用，变灰、不可触摸
function M:setEnabled(enable)
    self.root.grayed = not enable
    self.root.touchable = enable
end

function M:isEnabled()
    return self.root.touchable
end

---------- 点击 -----------
function M:onClick(func)
    if __DEBUG__ and __PRINT_TRACK__ then
        local trace = getTraceback("", 1)
        local f = function(context)
            printStack(func, trace)
            func(context)
        end
        -- 这个只是方便看堆栈，真实情况不会跑这里，在setSate不能用Add，只能set
        self.root.onClick:Set(f)
    else
        -- 在setState里面的onCLick方法必须不匿名
        -- 正确使用：btn:onClick(callback)，callback在前面已经定义
        -- 错误示范：btn:onClick(function() end) 
        self.root.onClick:Set(func)
    end
end

function M:removeClick(func)
    self.root.onClick:Remove(func)
end

function M:clearClick()
    self.root.onClick:Clear()
end

function M:onClickLink(func)
    self.root.onClickLink:Set(func)
end



function M:call()
    self.root.onClick:Call()
end



---------- 触摸 -----------
function M:onTouchBeginCapture(func)
    self.root.onTouchBegin:AddCapture(func)
end

function M:onTouchMoveCapture(func)
    self.root.onTouchMove:AddCapture(func)
end

function M:onTouchEndCapture(func)
    self.root.onTouchEnd:AddCapture(func)
end

---------- 触摸 -----------
function M:onTouchBegin(func)
    self.root.onTouchBegin:Set(func)
end

function M:onTouchMove(func)
    self.root.onTouchMove:Set(func)
end

function M:onTouchEnd(func)
    self.root.onTouchEnd:Set(func)
end

---------- 拖拽 -----------
function M:onDragStart(func)
    self.root.onDragStart:Set(func)
end

function M:onDragMove(func)
    self.root.onDragMove:Set(func)
end

function M:onDragEnd(func)
    self.root.onDragEnd:Set(func)
end

---------- enter - exit -----------
function M:onAddedToStage(func)
    self.root.onAddedToStage:Set(func)
end
function M:onRemovedFromStage(func)
    self.root.onRemovedFromStage:Set(func)
end
function M:setOnRemovedFromStage(func)
    self.root.onRemovedFromStage:Set(func)
end

---------- 改变事件 -----------
function M:onSizeChanged(func)
    self.root.onSizeChanged:Set(func)
end
function M:onPositionChanged(func)
    self.root.onPositionChanged:Set(func)
end


-- 关联
function M:addRelation(...)
    self.root:AddRelation(...)
end


---------- 坐标转换 ----------
-- Transforms a point from the local coordinate system to global (Stage) coordinates.
function M:localToGlobal(Vector2)
    return self.root:LocalToGlobal(Vector2)
end

-- Transforms a point from global (Stage) coordinates to the local coordinate system.
function M:globalToLocal(Vector2)
    return self.root:GlobalToLocal(Vector2)
end

-- 如果要转换任意两个UI对象间的坐标，例如需要知道A里面的坐标(10,10)在B里面的位置，可以用：
function M:transformPoint(Vector2, comp)
    return self.root:TransformPoint(Vector2, comp:getObj())
end


-- 透明度
function M:setAlpha(alpha)
    self.root.alpha = alpha
end

function M:getAlpha()
    return self.root.alpha
end

-- 缩放
function M:setScale(a, b)
    if b then
        self.root:SetScale(a, b)
    else
        self.root:SetScale(a, a)
    end
end

--旋转
function M:setRotation(rotation)
    self.root.rotation = rotation
end
function M:getRotation()
    return self.root.rotation
end

function M:setScaleX(scaleX)
    self.root.scaleX = scaleX
end

function M:getScale()
    return self.root.scaleX, self.root.scaleY
end

function M:getScaleX()
    return self.root.scaleX
end

function M:getScaleY()
    return self.root.scaleY
end

-- 设置动作
function M:setTweener(tweener)
    self._tweener = tweener
end

function M:getTweener()
    return self._tweener
end

function M:stopAction()
    if self._tweener then
        self._tweener:stopAction()
    end
end

function M:dispose()
    if self.root then
        self.root:Dispose()
        self.root = false
    end
end

function M:startDrag(id)
    self.root:StartDrag(id)
end

function M:setHome(obj)
    self.root:SetHome(obj)
end

-- bug在addChild后setName不会改变父节点的children
function M:setName(name)
    self.root.name = name
end

function M:getName()
    return self.root.name
end

-- 获取parent
function M:hasParent()
    return self.root.parent
end

function M:isDisposed()
    if self.root == false then
        return true
    end
    return self.root.isDisposed
end

function M:center()
    self.root:Center()
end

function M:invalidateBatchingState()
    self.root:InvalidateBatchingState()
end



function M:getResourceURL()
    return self.root.resourceURL
end

function M:getController(name)
    if self._controllers[name] then
        return self._controllers[name]
    end

    local ctrlObj = self.root:GetController(name)
    local ctrl = Controller.new(ctrlObj)
    self._controllers[name] = ctrl
    return ctrl
end


function M:onChanged(func)
    self.root.onChanged:Set(func)
end

function M:getParent()
    return self.root.parent
end

--override
function M:onEnter()

end

--override
function M:onExit()

end

BaseComponent = M