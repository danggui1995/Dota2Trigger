local M = {}

local cachedPop = {}
function M.showPop(package, item, sender, dataProvider)
    local url = fgui.GetTemplateUrl(package, item)
    if not cachedPop[url] then
        local popmenu = FairyGUI.PopupMenu(url)
        cachedPop[url] = popmenu
    end

    local popmenu = cachedPop[url]
    popmenu:ClearItems()
    for index, value in ipairs(dataProvider) do
        popmenu:AddItem(value.text, value.callback)
    end
    popmenu.resizeToFit = true
    popmenu:Show(sender)
end

PopManager = M