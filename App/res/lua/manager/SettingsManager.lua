local M = {
    curProject = false
}
local __settingData = {}
local settingPath = Main.luaPath .. "settings.tx"
local ckv = require"ckv"

SettingGroup = {
    Project = "Project",
    Details = "Details"
}

SettingType = {
    ENGINE_PATH = {"ENGINE_PATH"},
    GAME_PATH = {"GAME_PATH"},
    CONTENT_PATH = {"CONTENT_PATH"},
    INPUT_VRF_PATH = {"INPUT_VRF_PATH"},
    OUTPUT_VRF_PATH = {"OUTPUT_VRF_PATH"},
    PROJ_CREATE_TIME = {"PROJ_CREATE_TIME"},
    PROJ_OPEN_TIME = {"PROJ_OPEN_TIME"},
    THREAD_COUNT = {"THREAD_COUNT", 4},
    LANGUAGE = {"LANGUAGE", "schinese"},
}

local RootName = "Settings"

function M.loadConfig()
    if XFileTools.Exists(settingPath) then
        local text = XFileTools.ReadAllText(settingPath)
        __settingData = ckv.decode(text)
    else
        __settingData[RootName] = {}
    end
    for _, s in pairs(SettingGroup) do
        if not __settingData[RootName][s] then
            __settingData[RootName][s] = {}
        end
    end
end

function M.saveConfig()
    XFileTools.WriteAllText(settingPath, ckv.encode(__settingData))
end

function M.getConfig(key)
    key = tostring(key)
    local value = __settingData[RootName][SettingGroup.Details][M.curProject][key]
    if not value then
        if SettingType[key] then
            return SettingType[key][2]
        end
    else
        return value
    end
end

function M.setConfig(key, value)
    if key == nil then return end
    __settingData[RootName][SettingGroup.Details][M.curProject][tostring(key)] = tostring(value)
    M.saveConfig()
end

function M.addProject(key)
    if not __settingData[RootName][SettingGroup.Project] then
        __settingData[RootName][SettingGroup.Project] = {}
    end
    local cnt = 1
    for _, v in pairs(__settingData[RootName][SettingGroup.Project]) do
        cnt = cnt + 1
        if v == key then
            return
        end
    end
    __settingData[RootName][SettingGroup.Project][tostring(cnt)] = key

    if not __settingData[RootName][SettingGroup.Details][key] then
        __settingData[RootName][SettingGroup.Details][key] = {}
    end

    M.curProject = key
    local curtime = os.time()
    M.setConfig("PROJ_CREATE_TIME", curtime)
end

function M.removeProject(key)
    __settingData[RootName][SettingGroup.Details][key] = nil
end

function M.getProjectList()
    local ret = {}
    local allKey = __settingData[RootName][SettingGroup.Project]
    for _, v in pairs(allKey) do
        local details = __settingData[RootName][SettingGroup.Details][v]
        local path = details["GAME_PATH"]
        local createTime = details["PROJ_CREATE_TIME"]
        local openTime = details["PROJ_OPEN_TIME"]
        table.insert(ret, {v, path, createTime, openTime})
    end
    table.sort(ret, function (a,b)
        if a[4] == b[4] then
            return a[3] > b[3]
        else
            return a[4] > b[4]
        end
    end)
    return ret
end

function M.initSettings()
    local threadCount = M.getConfig("THREAD_COUNT")
    VRFHelper.instance:SetThreadCount(threadCount)
end

SettingsManager = M


M.loadConfig()