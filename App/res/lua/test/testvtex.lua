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
local function compileVtex(str1, str2, btn)
    local vtexlist = {}
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
        table.insert(vtexlist, vtexpath)
    end)

    local engineRoot = SettingsManager.getConfig("ENGINE_PATH")
    local exePath = FileUtil.combinePath(engineRoot, "../bin/win64/resourcecompiler.exe")
    os.execute(string.format([[%s -i "%s*.vtex" -game %s]], exePath, str1, engineRoot))

    --删除添加的无用vtex文件
    for _, path in pairs(vtexlist) do
        XFileTools.Delete(path)
    end
    print("gen vtex finished")
end

local M = {
    {"批量编译特效图片", "input", "", compileVtex, "test_gen_vtex"},
}

return M