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

    {"导出itemgame", "", "", function (str1, str2, btn)
        --C:\Games\steamapps\common\dota 2 beta\game\dota\pak01_dir.vpk
        local progress = btn:GetChild("progress")
        local ctrl = btn:GetController("showprogress")

        -- ctrl.selectedIndex = 1
        -- progress.value = 0
        VRFHelper.instance:LoadVPK(str1)
        CsEventManager.regAsyncEvent(ELuaEvent.Event_VPK_Loaded, function (param)
            -- progress:TweenValue(50, 0.2)
            -- CS.Trigger.VRFHelper.instance:ExtractFile("scripts/items/items_game.txt", Main.productPath .. "vpk_export")
            local Entries = VRFHelper.instance.vpkPackage.Entries
            local _, vmesh = Entries:TryGetValue("vmesh_c")
            local _, vmdl = Entries:TryGetValue("vmdl_c")

            local t = {}
            for i = 0, vmesh.Count - 1 do
                table.insert(t, vmesh[i]:GetFullPath())
            end
            XFileTools.WriteAllText("C:\\MyGit\\test_vmesh.txt", table.concat(t, '\n'))

            t = {}
            for i = 0, vmdl.Count - 1 do
                table.insert(t, vmdl[i]:GetFullPath())
            end
            XFileTools.WriteAllText("C:\\MyGit\\test_vmdl.txt", table.concat(t, '\n'))
            -- progress:TweenValue(100, 0.2)
            -- Timer.ScheduleOnce(1, function ()
            --     ctrl.selectedIndex = 0
            -- end)
        end)
        
    end, "test_vpkPath"},

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
    {"批量编译图片", "input", "", function (str1, str2, btn)
        local pattern = [[
<!-- dmx encoding keyvalues2_noids 1 format vtex 1 -->
"CDmeVtex"
{
    "m_inputTextureArray" "element_array" 
    [
        "CDmeInputTexture"
        {
            "m_name" "string" "0"
            "m_fileName" "string" "%s"
            "m_colorSpace" "string" "srgb"
            "m_typeString" "string" "2D"
        }
    ]
    "m_outputTypeString" "string" "2D"
    "m_outputFormat" "string" "DXT5"
    "m_textureOutputChannelArray" "element_array"
    [
        "CDmeTextureOutputChannel"
        {
            "m_inputTextureArray" "string_array"
                [
                    "0"
                ]
            "m_srcChannels" "string" "rgba"
            "m_dstChannels" "string" "rgba"
            "m_mipAlgorithm" "CDmeImageProcessor"
            {
                "m_algorithm" "string" ""
                "m_stringArg" "string" ""
                "m_vFloat4Arg" "vector4" "0 0 0 0"
            }
            "m_outputColorSpace" "string" "srgb"
        }
    ]
}
        ]]
        XFolderTools.TraverseFilesEX(str1, function (fullpath)
            local ext = Path.GetExtension(fullpath)
            if (ext ~= ".png" and ext ~= ".jpg" and ext ~= ".tga") then
                return
            end
            local directory = Path.GetDirectoryName(fullpath)
            local vtexfilename = Path.GetFileNameWithoutExtension(fullpath) .. ".vtex"
            local vtexpath = FileUtil.combinePath(directory, vtexfilename)
            if XFileTools.Exists(vtexpath) then
                return
            end
            local contentRoot = SettingsManager.getConfig("CONTENT_PATH")
            local relativePath = fullpath:gsub(contentRoot, "")
            if relativePath:sub(1,1) == "/" then
                relativePath = relativePath:sub(2)
            end

            local vtexcontent = string.format(pattern, relativePath)
            XFileTools.WriteAllText(vtexpath, vtexcontent)
        end)

        local engineRoot = SettingsManager.getConfig("ENGINE_PATH")
        local exePath = FileUtil.combinePath(engineRoot, "../bin/win64/resourcecompiler.exe")
        os.execute(string.format([[%s -i "%s*.vtex" -game %s]], exePath, str1, engineRoot))
    end, "test_gen_vtex"},
}

function M:onInit()
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