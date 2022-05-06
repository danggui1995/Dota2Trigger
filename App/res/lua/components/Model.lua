local M = class("Model", Button)
local goWrapPool = {}
local vecPos = Vector3(0,0,-3)
local vecZero = Vector3(0,0,0)
local vecScale = Vector3(1,1,1)
function M:ctor(root)
    self.title = root:GetChild('title')
    self.empty = root:GetController("empty")
    self.holder = root:GetChild("holder")

    self.allparts = {}
    self._autoBone = false
    self._autoBoneComp = false

    self.vecRot = Vector3(0, 0, 0)
    self.scaleRatio = 1

    self._lastX = 0
    self._loadcallback = false
    self.animUpdater = false

    root.onTouchBegin:Set(function (context)
        self._lastX = context.data.x
        if self.wrapTarget then
            self.vecRot.y = self.wrapTarget.transform.localEulerAngles.y
        end
        
        return true
    end)
    root.onTouchMove:Set(function (context)

        local offsetX = context.data.x
        local deltaX = (offsetX - self._lastX) * 0.6
        self._lastX = offsetX
        self.vecRot.y = self.vecRot.y - deltaX

        if self.wrapTarget then
            self.wrapTarget.transform.localEulerAngles = self.vecRot
        end
    end)

    -- root.onTouchEnd:Set(function (context)

    -- end)
    
    self.modelUniqueId = false
end

function M:onExit()
    if self.allparts then
        for p, _ in pairs(self.allparts) do
            self:unloadPart(p)
        end
    end

    self.animUpdater = nil
end

function M:setModel(path, scale)
    self.empty.selectedIndex = 0
    self.title.text = path
    self.scaleRatio = scale
    
    if goWrapPool[self.root] and goWrapPool[self.root].wrapTarget then
        ObjectPool.Despawn(goWrapPool[self.root].wrapTarget)
        goWrapPool[self.root]:CustomClear()
    end

    if self.modelUniqueId then
        ObjectPool.CancelLoad(self.modelUniqueId)
    end

    self.modelUniqueId = ObjectPool.Spawn(path, function (go)
        if self.root.isDisposed then
            ObjectPool.Despawn(go)
            return
        end

        if not go then
            self.empty.selectedIndex = 1
        else
            self.empty.selectedIndex = 2
            local gowrapper = goWrapPool[self.root]
            if not gowrapper then
                gowrapper = FairyGUI.GoWrapper(go)
                self.holder:SetNativeObject(gowrapper)
                gowrapper:SetScale(self.scaleRatio, self.scaleRatio)
                goWrapPool[self.root] = gowrapper
            else
                local oldTarget = gowrapper.wrapTarget
                gowrapper.wrapTarget = go
                if oldTarget then
                    ObjectPool.Despawn(oldTarget)
                end
            end

            go.transform.localPosition = vecPos
            go.transform.localScale = vecScale
            self.wrapTarget = go

            if self._autoBone then
                self._autoBoneComp = go:GetComponent(typeof(AutoBones))
                if not self._autoBoneComp then
                    self._autoBoneComp = go:AddComponent(typeof(AutoBones))
                end
            end

            if self.hasPart then
                self:updatePartModel()
            end

            self:setStaticBindPose(self._bStaticBindPose)
            if not self._bStaticBindPose then
                self.animUpdater = go:GetComponentInChildren(typeof(AnimUpdater))
                if self._loadcallback then
                    self._loadcallback(self.animUpdater)
                end
                self.animUpdater:UpdatePosition(self.scaleRatio)
            end
        end
    end)
end

function M:updatePartModel(go)
    if goWrapPool[self.root] and goWrapPool[self.root].wrapTarget then
        if go then
            go.transform:SetParent(goWrapPool[self.root].wrapTarget.transform)
            go.transform.localPosition = vecZero
            go.transform.localScale = vecScale
            if self._autoBoneComp then
                self._autoBoneComp:RetargetBones(go)
            end
            Tools.SetLayer(go, "UI", true)
        else
            for _, g in pairs(self.allparts) do
                self:updatePartModel(g)
            end
        end
        goWrapPool[self.root]:CacheRenderers()
    end
end

function M:setPart(part, partpath)
    if self.allparts[part] then
        return
    end
    self.hasPart = true
    -- self:unloadPart(part)
    ObjectPool.Spawn(partpath, function (go, key)
        if self.root.isDisposed then
            ObjectPool.Despawn(go)
            return
        end

        if not go then
            MsgManager.showMsg("加载部位出错：%s, url: %s", part, partpath)
        else
            self.allparts[part] = go
            self:updatePartModel(go)
        end
    end)
end

function M:unloadPart(part)
    if self.allparts[part] then
        if self._autoBoneComp then
            self._autoBoneComp:UnshareSkeleton(self.allparts[part])
        end
        ObjectPool.Despawn(self.allparts[part])
        self.allparts[part] = nil
    end
end

function M:autoBones()
    self._autoBone = true
end

function M:play(animName)
    if self.animUpdater then
        self.animUpdater:Play(animName)
    end
end

function M:onModelLoaded(func)
    self._loadcallback = func
end

function M:setScaleAndRotation(scale, rotationY)
    self.vecRot.y = rotationY
    self.scaleRatio = scale

    local gowrapper = goWrapPool[self.root]
    if gowrapper then
        gowrapper:SetScale(self.scaleRatio, self.scaleRatio)
    end
    if self.wrapTarget then
        self.wrapTarget.transform.localEulerAngles = self.vecRot
    end
end

function M:setStaticBindPose(v)
    self._bStaticBindPose = v

    if self.wrapTarget then
        local comp = self.wrapTarget:GetComponent(typeof(CS.CustomAnimation.StaticBindPose))
        if self._bStaticBindPose == true then
            if not comp then
                comp = self.wrapTarget:AddComponent(typeof(CS.CustomAnimation.StaticBindPose))
            end
            comp:AdjustOffsetY()
        else
            if comp then
                CS.UnityEngine.Object.Destroy(comp)
            end
        end
    end
end

Model = M