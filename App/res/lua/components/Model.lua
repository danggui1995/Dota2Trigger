local M = class("Model", Button)
local goWrapPool = {}
local vecPos = Vector3(0,0,-3)
local vecZero = Vector3(0,0,0)
function M:ctor(root)
    self.title = root:GetChild('title')
    self.empty = root:GetController("empty")
    self.holder = root:GetChild("holder")

    self.allparts = {}
    self._autoBone = false
    self._autoBoneComp = false

    self.vecRot = Vector3(0, 0, 0)
    self.modelScale = Vector3(100, 100, 100)

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

    self:releaseModel()
end

function M:releaseModel()
    if goWrapPool[self.root] and goWrapPool[self.root].wrapTarget then
        local go = goWrapPool[self.root].wrapTarget
        if self._autoBoneComp then
            self._autoBoneComp:UnshareSkeleton(go)
        end

        if self.animUpdater then
            self.animUpdater.animationName = nil
            self.animUpdater = nil
        end

        self.wrapTarget = nil
        ObjectPool.Despawn(go)
        goWrapPool[self.root]:CustomClear()
    end

    if self.modelUniqueId then
        ObjectPool.CancelLoad(self.modelUniqueId)
    end
end

function M:setModel(path, scale)
    self.empty.selectedIndex = 0
    self.title.text = Path.GetFileNameWithoutExtension(path)
    
    self:releaseModel()

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
                goWrapPool[self.root] = gowrapper
            else
                local oldTarget = gowrapper.wrapTarget
                gowrapper.wrapTarget = go
                if oldTarget then
                    ObjectPool.Despawn(oldTarget)
                end
            end

            go.transform.localPosition = vecPos
            
            self.wrapTarget = go
            self:setScale(scale)

            if self._autoBone then
                self._autoBoneComp = go:GetComponent(typeof(AutoBones))
                if not self._autoBoneComp then
                    self._autoBoneComp = go:AddComponent(typeof(AutoBones))
                end
            end

            if self.hasPart then
                self:updatePartModel()
            end

            self.animUpdater = go:GetComponent(typeof(AnimUpdater))
            self.animUpdater:AdjustMaxBounds(100)
            self:setStaticBindPose(self._bStaticBindPose)
        end
    end)
end

function M:updatePartModel(go)
    if goWrapPool[self.root] and goWrapPool[self.root].wrapTarget then
        if go then
            go.transform:SetParent(goWrapPool[self.root].wrapTarget.transform)
            go.transform.localPosition = vecZero
            go.transform.localScale = self.modelScale
            if self._autoBoneComp then
                self._autoBoneComp:RetargetBones(go)
            end
            local animUpdater = go:GetComponent(typeof(AnimUpdater))
            animUpdater:ToggleSkinned(true)
            animUpdater:PlayAct("ACT_DOTA_IDLE")
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
        local go = self.allparts[part]
        if self._autoBoneComp then
            self._autoBoneComp:UnshareSkeleton(go)
        end

        ObjectPool.Despawn(go)
        self.allparts[part] = nil
    end
end

function M:autoBones()
    self._autoBone = true
end

function M:play(animName, animAct)
    if self.animUpdater then
        self.animUpdater:Play(animName)
    end

    for _, go in pairs(self.allparts) do
        local animUpdater = go:GetComponent(typeof(AnimUpdater))
        if animUpdater then
            animUpdater:PlayAct(animAct)
        end
    end
end

function M:onModelLoaded(func)
    self._loadcallback = func
end

function M:setScale(scale)
    self.modelScale:set(scale, scale, scale)

    if self.wrapTarget then
        self.wrapTarget.transform.localScale = self.modelScale
    end
end

function M:setStaticBindPose(v)
    self._bStaticBindPose = v

    if self.wrapTarget then
        self.animUpdater:ToggleSkinned(not self._bStaticBindPose)
        if self._loadcallback then
            self._loadcallback(self.animUpdater)
        end
        goWrapPool[self.root]:CacheRenderers()
    end
end

Model = M