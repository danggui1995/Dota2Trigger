local M = class("toolview", BaseView)
local ckv = require "ckv"

function M:ctor()
    self.layerDepth = LayerDepth.Window
    self.sortingOrder = 0
    self.package = "main"
    self.packageItem = "toolview"
end

local toolConfig = {
    {Desc[1000002], Desc[1000003], Desc[1000004], function (str1, str2, btn)
        XFolderTools.TraverseFilesEX(str1, function (fullPath)
            local ext = Path.GetExtension(fullPath):lower()
            if ext == ".tga" then
                Tools.ConvertTGA2PNG(fullPath, str2)
            end
        end)
    end},

    {"收集所有的key", "", "", function (str1, str2, btn)
        --C:\Users\1\Desktop\todolist\allkv\scripts\npc\npc_abilities.txt
        local text = XFileTools.ReadAllText(str1)
        -- local tb = ckv.decode(text)["DOTAHeroes"]
        local tb = ckv.decode(text)[KVManager.getRootKey(KVManager.Type_Ability)]
        local r = {}
        
        for _, v in pairs(tb) do
            if type(v) == 'table' then
                for key, vv in pairs(v) do
                    if not r[key] then
                        if type(vv) == 'string' then
                            local vvv = vv:gsub(" ", "")
                            local num = tonumber(vvv)
                            if num then
                                if (num == 1 or num ==0 ) and key:find("Is") == 1 then
                                    r[key] = string.format("{\"%s\", \"%s\", \"%s\", nil, %s},", key, key, "kvnumber", vv)
                                else
                                    r[key] = string.format("{\"%s\", \"%s\", \"%s\", nil, %s},", key, key, "kvnumber", vv)
                                end
                            else
                                if KVModule[key] then
                                    r[key] = string.format("{\"%s\", \"%s\", \"%s\", \"%s\", \"%s\"},", key, key, "kvdrop", key, KVModule[key][1])
                                else
                                    r[key] = string.format("{\"%s\", \"%s\", \"%s\", \"%s\", nil},", key, key, "kvinput", vv)
                                end
                            end
                        end

                    end
                end
            end
        end
        local list = {}
        for k, v in pairs(r) do
            table.insert(list, v)
        end
        table.sort(list, function (a,b)
            return a < b
        end)

        XFileTools.WriteAllText(str1 .. "22", table.concat(list, '\n'))
    end, "test_collect_kv_key"},

    {"批量去前缀", "输入路径", "分隔符", function (str1, str2, btn)
        XFolderTools.TraverseFilesEX(str1, function (fullPath)
            local fileName = Path.GetFileName(fullPath)
            local dirName = Path.GetDirectoryName(fullPath)
            local index = fileName:find(str2)
            if index then
                fileName = fileName:sub(index + 1)
            end
            local destPath = FileUtil.combinePath(dirName, fileName)
            XFileTools.MoveEx(fullPath, destPath)
        end)
    end, "INPUT_VRF_PATH", "OUTPUT_VRF_PATH"},

    {"遍历文件夹", "input", "", function (str1, str2, btn)
        local t = {}
        XFolderTools.TraverseFilesEX(str1, function (fullPath)
            local fileName = Path.GetFileNameWithoutExtension(fullPath)
            if fileName:find("on") == 1 or fileName:find("On") == 1 then
                table.insert(t, string.format("%s = {}", fileName))
            end
            
        end)
        print(table.concat(t, "\n"))
    end, "find"},
    {"测试编码", "input", "", function (str1, str2, btn)
        local path = "D:/gitfiles/dota2rpg_humansTD/game/humans/resource/addon_schinese.txt"
        local encodeType = FileEncoder.GetEncoding(path)
        if encodeType ~= Encoding.UTF8 then
            XFileTools.ChangeFileEncodeToUTF8(path)
            MsgManager.showMsg("检测到文本编码非utf8，实际为：%s, 已为您进行修改:%s", encodeType, path)
        end
    end, "find"},

    {"文件名小写", "input", "output", function (str1, str2, btn)
        XFolderTools.TraverseFilesEX(str1, function (fullpath)
            local filename = Path.GetFileName(fullpath):lower()
            local newfullpath = FileUtil.combinePath(str2, filename)
            XFileTools.Copy(fullpath, newfullpath)
        end)
    end, "test_gltf"},
    {"测试赏金动画读写", "input", "output", function (str1, str2, btn)
        VRFHelper.instance:LoadKVAsync("models/heroes/bounty_hunter/bounty_hunter_base_c13108d2.vagrp_c", function ()
            print("success")
        end)
    end, "test_gltf"},

    {"批量覆盖Music", "input", "output", function (str1, str2, btn)
        local allEvts = {}
        table.insert(allEvts, [[
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->
{
        ]])
        local pattern = [[
            
    %s = 
    {
        type = "dota_src1_2d"
		vsnd_files = "sounds/null.vsnd"
    }]]
        VPKManager.load_soundevents(function (pathMap)
            for k, v in pairs(pathMap) do
                for kk, vv in pairs(v) do
                    if vv[1]:find("music%.") then
                        table.insert(allEvts, string.format(pattern, vv[1]))
                    end
                end
            end
        end)
        table.insert(allEvts, "\n}")

        if str2 == "" then
            str2 = "E:/gitee/metalmax/content/soundevents/override.vsndevts"
        end
        XFileTools.WriteAllText(str2, table.concat(allEvts, ""))
    end, "test_override_music"},
}

local submodule = {
    "test.testmaterial",
    "test.testvtex",
    "test.testmodel",
}

function M:onInit()
    for _, moduleName in ipairs(submodule) do
        local m = require(moduleName)
        for _, v in ipairs(m) do
            table.insert(toolConfig, v)
        end
    end
   
    self.toollist = self.root:GetChild("toollist")

    local function ontoollistClicked(context)
        UIManager.openView(toolConfig[index + 1])
    end

    local function onInputChanged(context)
        SettingsManager.setConfig(context.sender.data, context.sender.text)
        SettingsManager.saveConfig()
    end

    self.toollist.itemRenderer = function (index, obj)
        index = index + 1

        local input1 = obj:GetChild("input1"):GetChild("title")
        local input2 = obj:GetChild("input2"):GetChild("title")

        input1.onChanged:Set(onInputChanged)
        input2.onChanged:Set(onInputChanged)

        local info = toolConfig[index]
        if info[5] then
            input1.data = info[5]
            input1.text = SettingsManager.getConfig(info[5])
        end
        if info[6] then
            input2.data = info[6]
            input2.text = SettingsManager.getConfig(info[6])
        end

        input1.promptText = info[2]
        input2.promptText = info[3]

        local btn = obj:GetChild("btn")

        btn.title = info[1]
        btn.onClick:Set(function ()
            info[4](input1.text, input2.text, btn)
        end)
    end
    self.toollist.numItems = #toolConfig
end

function M:onAddEvent()
    self:addEvent(EventType.OnSavePressed, function ()
        SettingsManager.saveConfig()
    end)
end

return M