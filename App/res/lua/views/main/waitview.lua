local M = class("waitview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Top
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "waitview"
    self.fullScreenType = 1

    self.progressbar = false
    self.title = false
end

function M:onInit()
    self.progressbar = self.root:GetChild("progressbar")
    self.title = self.root:GetChild("title")
end

function M:onAddEvent()
    local function onDelayHide()
        self:close()
    end
    
    self:addEvent(EventType.Progress_Change_Wait, function (_, e, value, title)
        if value == 0 then
            if title then
                self.title.text = (title)
            else
                self.title.text = ""
            end
        end

        if value > self.progressbar.value then
            self.progressbar:TweenValue(value, 0.2)
        else
            self.progressbar.value = value
        end

        if value >= 100 then
            Timer.ScheduleOnce(0.5, onDelayHide)
        end
    end)
end

return M