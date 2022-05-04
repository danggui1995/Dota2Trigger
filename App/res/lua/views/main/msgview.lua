local M = class("msgview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Top
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "msgview"

    self.msgQueue = {}
end

function M:onInit()
    local line1 = self.root:GetChild("line1")
    local line2 = self.root:GetChild("line2")

    self.showline1 = self.root:GetTransition("showline1")
    self.showline2 = self.root:GetTransition("showline2")

    self.lineTitle1 = line1:GetChild("title")
    self.lineTitle2 = line2:GetChild("title")
end


function M:onAddEvent()
    local checkToPlay
    local function onTransitionFinished1()
        self.linePlaying1 = false
        checkToPlay()
    end
    local function onTransitionFinished2()
        self.linePlaying2 = false
        checkToPlay()
    end
    checkToPlay = function ()
        local msg
        if #self.msgQueue > 0 then
            msg = self.msgQueue[1]
        else
            return
        end

        if not self.linePlaying2 then
            self.linePlaying2 = true
            self.lineTitle2.text = msg
            table.remove(self.msgQueue, 1)
            self.showline2:Play(onTransitionFinished2)
        elseif not self.linePlaying1 then
            self.linePlaying1 = true
            self.lineTitle1.text = msg
            table.remove(self.msgQueue, 1)
            self.showline1:Play(onTransitionFinished1)
        end
    end
    self:addEvent(EventType.Msg_Show, function (_, e, text)
        table.insert(self.msgQueue, text)
        checkToPlay()
    end)
end

return M