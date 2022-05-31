local M = class("progressview", BaseView)

function M:ctor()
    self.layerDepth = LayerDepth.Top
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "progressview"
    self.fullScreenType = 1

    self.show = false
    self.progressbar = false
    self.title = false
end

function M:onInit()
    self.progressbar = self.root:GetChild("progressbar")
    self.show = self.root:GetController("show")
    self.title = self.root:GetChild("title")
end

function M:onAddEvent()
    local function onDelayHide()
        self.show.selectedIndex = 0
    end

    self:addEvent(EventType.Progress_Change_Value, function (_, e, value, title)
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

        if self.show.selectedIndex == 0 then
            self.show.selectedIndex = 1
        else
            if value >= 100 then
                Timer.ScheduleOnce(1, onDelayHide)
            end
        end
    end)
end

return M