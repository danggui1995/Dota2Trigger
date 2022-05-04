local M = class("soundeventview", BaseView)
local ckv_sound = require "ckv1"
local soundTemplate = {
    {"type", "dota_src1_3d"},
    {"vsnd_files", {}},
    {"volume", "1.000000"},
    {"pitch", "1.000000"},
    {"event_type", "0"},
    {"memory_type", "0"},
    {"mixgroup", "Stingers"},
}

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "soundeventview"
    self.fullScreenType = 0
    self.filterStr = ""
end

function M:updatekvlist()
    local data = self.filelist:getSelectedData()
    local sindex = self.filelist:getSelectedIndex()
    local kvArray = self.allkv[data[1] + 1]
    local listdata = {}
    for i = 1, #kvArray, 2 do
        if type(kvArray[i + 1]) ~= "table" then
            table.insert(listdata, {kvArray[i], kvArray[i + 1], i, data[1]})
        end
    end
    self.kvlist:setDataProvider(listdata)
end

function M:removeElement(keyIndex)
    local tb = self.allkv[keyIndex + 1]
    local hasleft = false
    for i = 1, #tb, 2 do
        if tb[i] == "vsnd_files" then
            --有个__IsArray__
            if #tb[i+1] > 2 then
                hasleft = true
            end
            for j = 1, #tb[i+1] do
                if tb[i+1][j] == self.vsndPath then
                    table.remove(tb[i+1], j)
                    break
                end
            end
        end
    end

    if not hasleft then
        table.remove(self.allkv, keyIndex + 1)
        table.remove(self.allkv, keyIndex)
    end

    VPKManager.removeSoundPathMap(self.vsndPath, self.filelist:getSelectedIndex())
    return hasleft
end

function M:rename()
    if self.isInternal then
        MsgManager.showMsg(1000055, self.evtName)
        return
    end
    UIManager.openView("renameview", self.evtName, function (input)
        local data = self.filelist:getSelectedData()
        local keyIndex = data[1]

        --先移除，再添加（如果有同名的再加进去)
        local hasleft = self:removeElement(keyIndex)
        VPKManager.appendSoundKv(self.evtFullPath, input, self:getTemplateKv(), self.vsndPath)

        self:saveLocalKV()
        self:updateList()
    end)
end

function M:onInit()
    
    self.filelist = fgui.GetComponent(self.root, "filelist", List)
    self.filelist:setVirtual()
    self.filelist:setState(function (data, index, comp, obj)
        local path = obj:GetChild("path")
        local name = obj:GetChild("name")

        if self.isInternal then
            name.text = data[1]
            path.text = data[2]
        else
            name.text = data[3]
            path.text = data[2]
        end
    end)
    self.filelist:onClickItem(function ()
        self:selectEvent()
    end)

    local menuTb = 
    {
        {
            --rename
            text = Desc.getText(1000021),
            callback = function (context)
                self:rename()
            end
        },
        {
            --move
            text = Desc.getText(1000056),
            callback = function (context)
                if self.isInternal then
                    MsgManager.showMsg(1000055, self.evtName)
                    return
                end
                UIManager.openView("renameview", self.evtFullPath, function (input)

                end)
            end
        },
        {
            --delete
            text = Desc.getText(1000014),
            callback = function (context)
                if self.isInternal then
                    MsgManager.showMsg(1000055, self.evtName)
                    return
                end
                local data = self.filelist:getSelectedData()
                local keyIndex = data[1]

                self:removeElement(keyIndex)
                
                self:saveLocalKV()
                self:updateList()
            end
        },
        {
            --copy name
            text = Desc.getText(1000058),
            callback = function (context)
                MsgManager.copyToClipBorad(self.evtName)
            end
        },
        {
            --select
            text = Desc.getText(1000059),
            callback = function (context)
                if self.callback then
                    self.callback(self.evtName)
                    self:close()
                end
            end
        },
    }
    self.filelist:onRightClickItem(function (context)
        self:selectEvent()

        PopManager.showPop("main", "PopupMenu", context.data, menuTb)
    end)

    local function onInputChanged(context)
        local input = context.sender.text
        local data = context.sender.data

        local sindex = data[4] + 1
        local kvindex = data[3] + 1

        self.allkv[sindex][kvindex] = input
        self:saveLocalKV()
    end

    self.kvlist = fgui.GetComponent(self.root, "kvlist", List)
    self.kvlist:setState(function (data, index, comp, obj)
        local title = obj:GetChild("title")
        local input = obj:GetChild("input")
        input.onChanged:Set(onInputChanged)
        input.data = data

        title.text = data[1]
        input.text = data[2]
    end)

    local closeBtn = fgui.GetComponent(self.root, "closeBtn", Button)
    closeBtn:onClick(function ()
        self:close()
    end)

    self.pathLabel = self:getChild("path", Label)

    self.addNewFileBtn = self:getChild("addNewFileBtn", Button)
    self.addNewFileBtn:onClick(function ()
        if self.isInternal then
            MsgManager.showMsg(1000055, self.evtName)
        else
            local soundRootPath = Path.Combine(SettingsManager.getConfig("CONTENT_PATH"), "soundevents")
            local filelist = {}
            XFolderTools.TraverseFilesEX(soundRootPath, function (fullpath)
                table.insert(filelist, fullpath)
            end)

            UIManager.openView("renameview", "输入文件名(不包括目录,仅需文件名)", function (input)
                self:addEmptyKv(input)
            end, filelist)
        end
    end)

    -- self.addToBtn = self:getChild("addToBtn", Button)
    -- self.addToBtn:onClick(function ()
    --     local soundRootPath = Path.Combine(SettingsManager.getConfig("CONTENT_PATH"), "soundevents")
    --     local filelist = {}
    --     XFolderTools.TraverseFilesEX(soundRootPath, function (fullpath)
    --         table.insert(filelist, fullpath)
    --     end)

    --     UIManager.openView("renameview", "", function(input)
    --         self:addEmptyKv(input)
    --         self:updateList()
    --     end, filelist)
    -- end)

    self.hasDataCtrl = self.root:GetController("hasData")
    self.internalCtrl = self.root:GetController("internal")
end

function M:selectEvent()
    local data = self.filelist:getSelectedData()
    self.evtFullPath = data[2]

    if self.isInternal then
        self.evtName = data[1]
    else
        self.allkv = VPKManager.getLocalKv(self.evtFullPath)
        self.evtName = data[3]
        self:updatekvlist()
    end
end

function M:addEmptyKv(input)
    local fileName = Path.GetFileName(input)
    local soundRootPath = Path.Combine(SettingsManager.getConfig("CONTENT_PATH"), "soundevents")

    local fullpath = Path.Combine(soundRootPath, input)
    local name1 = Path.GetFileName(Path.GetDirectoryName(fullpath))
    local name2 = Path.GetFileNameWithoutExtension(fullpath)
    VPKManager.appendSoundKv(fullpath, string.format("%s.%s", name1, name2), self:getTemplateKv(), self.vsndPath)

    self:updateList()
    self.filelist:setSelectedIndex(#self.filelist:getDataProvider(), true)
end

function M:getTemplateKv()
    local kv = {}
    for _, v in ipairs(soundTemplate) do
        table.insert(kv, v[1])
        if v[1] == "vsnd_files" then
            local t = {"__IsArray__", self.vsndPath}
            table.insert(kv, t)
        else
            table.insert(kv, v[2])
        end
    end
    return kv
end

function M:saveLocalKV()
    if self.isInternal then
        return
    end
    local writeStr = ckv_sound.encode_array(self.allkv)
    XFileTools.WriteAllText(self.evtFullPath, writeStr)
end

function M:setDropByName(name)
    local index = -1
    for i, v in pairs(self.allFiles) do
        if v == name then
            index = i
        end
    end
    if index > 0 then
        self.curEventFileName:setSelectedIndex(index)
    end
end

function M:onOpen(vsndPath, callback)
    self.isInternal = vsndPath:find("vsnd_c")
    self.vsndFullPath = vsndPath
    self.callback = callback
    vsndPath = vsndPath:gsub("\\", "/"):gsub("vsnd_c", "vsnd")

    self.vsndPath = VPKManager.getResPath("sounds", vsndPath, false)

    local ctrlIndex = 0
    if self.isInternal then
        ctrlIndex = 1
    end
    
    self.pathLabel:setText(self.vsndPath)

    self:playAudio()
    self:updateList(true)

    self.internalCtrl.selectedIndex = ctrlIndex
end

function M:updateList(firstEnter)
    VPKManager.getAllSoundList(self.vsndPath, self.isInternal, function (filelistdata)
        if self.root.isDisposed then
            return
        end
        if not filelistdata then
            filelistdata = {}
        end

        self.filelist:setDataProvider(filelistdata)
        if #filelistdata > 0 then
            if firstEnter then
                self.filelist:setSelectedIndex(1, true)
            end
        end

        if #filelistdata > 0 and not self.isInternal then
            self.hasDataCtrl.selectedIndex = 1
        else
            self.hasDataCtrl.selectedIndex = 0
        end
    end)
end

function M:onClose()
    -- Main.instance:PlayAudio(nil)
end

function M:playAudio()
    -- Main.instance:PlayAudio(self.vsndPath)
end

return M