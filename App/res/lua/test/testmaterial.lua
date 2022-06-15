local pattern = [[
// THIS FILE IS AUTO-GENERATED

Layer0
{
    shader "global_lit_simple.vfx"

    //---- Enable wind ----
    F_ENABLE_WIND 1

    %s

    //---- Specular ----
    F_SPECULAR 1

    //---- Wind that follows object Z ----
    F_TRAVELLING_WIND_OBJECT_Z 1

    //---- Color ----
    g_vColorTint "[1.000000 1.000000 1.000000 0.000000]"
    g_vTexCoordOffset "[0.000 0.000]"
    g_vTexCoordScale "[1.000 1.000]"
    TextureColor "%s"

    %s

    //---- Self Illum ----
    TextureSelfIllumMask "materials/default/default_selfillum.tga"

    //---- Specular ----
    g_flSpecularBloom "0.000"
    g_flSpecularIntensity "1.000"
    TextureBloom "materials/default/default_bloom.tga"
    TextureReflectance "materials/default/default_refl.tga"

    //---- Wind ----
    g_flTravellingWindMagnitude "10.000"
    g_flTravellingWindSpeed "5.000"
    g_flTravellingWindWavelength "20.000"
    g_flWindFlexibility "0.300"
    g_flWindHighFrequencyEffects "1.000"
    g_flWindLinearity "0.000"
    g_flWindLowFrequencyEffects "1.000"
    g_flWindSpeedMultiplier "1.000"
    TextureWindMaskHigh "[1.000000 1.000000 1.000000 0.000000]"
    TextureWindMaskLow "[0.380000 0.380000 0.380000 0.000000]"
    TextureWindRandomNoise "[0.000000 0.000000 0.000000 0.000000]"


    VariableState
    {
        "Color"
        {
        }
        %s
        "Self Illum"
        {
        }
        "Specular"
        {
        }
        "Wind"
        {
        }
    }
}
]]

local pattenNormal = {
    [[//---- Normal Maps ----
    F_NORMAL_MAP 1]],
    [[//---- Normal Map ----
    g_flBumpStrength "1.000"
    TextureNormal "%s"]],
    [[
    "Normal Map"
    {
    }]],
}

local function getNewName(filename)
    local arr = string.split(filename, "_")
    if #arr > 0 then
        local t = {}
        for i = 1, #arr - 1 do
            table.insert(t, arr[i])
        end
        filename = table.concat(t, "_")
    end
    return filename
end

--[[
    批量自动生成材质
    注意：每个项目都有自己的规范，这里只是作为一种思路，并不能通用
]]
local function testMaterialGen(str1, str2, btn)
    local skinpath = str1
    if skinpath == "" then
        skinpath = "D:/gitee/metalmax/content/models/monsters"
    end

    local recordMap = {}
    local totalCnt = 0
    XFolderTools.TraverseFiles(skinpath, function(fullpath)
        local ext = IO.Path.GetExtension(fullpath)
        local realName
        local arrayIndex = 1
        if ext == ".png" and not fullpath:find("_rough.png") then
            local dir = IO.Path.GetDirectoryName(fullpath)
            local filename = IO.Path.GetFileName(fullpath)
            local isNormal = fullpath:find("_nml.png")

            if isNormal then
                filename = filename:gsub("_nml.png", "")
                arrayIndex = 2
            else
                filename = IO.Path.GetFileNameWithoutExtension(filename)
            end
            filename = getNewName(filename)
            realName = IO.Path.Combine(dir, filename)
        elseif ext == ".vmat" then
            local dir = IO.Path.GetDirectoryName(fullpath)
            local filename = IO.Path.GetFileName(fullpath)
            filename = filename:gsub("_m%.vmat", ".vmat")
            filename = getNewName(filename)
            local modelname = IO.Path.GetFileName(dir)
            local modelId = modelname:match("ez(%d*)%a*")
            if modelId then
                filename = filename:gsub("ez(%d*)(%a*)", function (str, p)
                    return string.format("ez%s%s", modelId, p)
                end)
            end

            realName = IO.Path.Combine(dir, filename)
            arrayIndex = 3
        end

        if realName then
            if not recordMap[realName] then
                recordMap[realName] = {}
                totalCnt = totalCnt + 1
            end

            recordMap[realName][arrayIndex] = fullpath
        end
    end, true)

    local cnt = 1
    for k, v in pairs(recordMap) do
        local matpath = v[3]
        if matpath then
            local basecolor = v[1]
            local normal = v[2]

            if basecolor then
                local data
                local r1 = FileUtil.getRelativePath(basecolor)
                if normal then
                    local r2 = FileUtil.getRelativePath(normal)
                    data = string.format(pattern, pattenNormal[1], r1, string.format(pattenNormal[2], r2), pattenNormal[3])
                else
                    data = string.format(pattern, "", r1, "", "", "")
                end
                XFileTools.WriteAllText(matpath, data)
            else
                printWarning(string.format("找不到BaseColor : %s, 需要自己处理", matpath))
            end
        end

        Dispatcher.dispatchEvent(EventType.Progress_Change_Wait, cnt / totalCnt * 100, "根据贴图生成材质")
        cnt = cnt + 1
    end
    print("finish")
end

local function testMaterialEmpty(str1, str2, btn)
    local skinpath = str1
    if skinpath == "" then
        skinpath = "D:/gitee/metalmax/content/models/monsters"
    end

    local recordMap = {}
    local totalCnt = 0
    XFolderTools.TraverseFiles(skinpath, function(fullpath)
        local ext = IO.Path.GetExtension(fullpath)
        if ext == ".vmat" then
            XFileTools.WriteAllText(fullpath, "")
        elseif ext == ".vmdl" then
            XFileTools.Delete(fullpath)
        end
    end, true)
    print("finish")
end


local M = {
    {"清空vmat和vmdl", "input", "", testMaterialEmpty, "test_empty_material"},
    {"根据贴图生成材质", "input", "", testMaterialGen, "test_gen_material"},

}

return M