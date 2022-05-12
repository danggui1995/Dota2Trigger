local M = {}
local ckv = require "ckv"

local unitKV = {}
local unitTemplate = {}

M.Type_Unit = "npc_units_custom.txt"
M.Type_Hero = "npc_heroes_custom.txt"
M.Type_Ability = "npc_abilities_custom.txt"
M.Type_Item = "npc_items_custom.txt"
M.Type_Herolist = "herolist.txt"
M.Type_Override = "npc_abilities_override.txt"

local kvLua = {
    [M.Type_Unit] = {"KVUnit", "DOTAUnits"},
    [M.Type_Hero] = {"KVHero", "DOTAHeroes"},
    [M.Type_Ability] = {"KVAbility", "DOTAAbilities"},
    [M.Type_Item] = {"KVItem", "DOTAAbilities"},
    [M.Type_Herolist] = {"KVHerolist", "CustomHeroList"},
    [M.Type_Override] = {"KVOverride", "DOTAAbilities"},
}

local function getKvFilePath(subPath, isRead)
    local gameDir = SettingsManager.getConfig("GAME_PATH")
    if not XFolderTools.Exists(gameDir) then
        printError(Desc.getText(1000011, gameDir))
        return
    end
    local filePath = FileUtil.combinePath(gameDir, subPath)
    if isRead and not XFileTools.Exists(filePath) then
        printError(Desc.getText(1000012, filePath))
        return
    end

    return filePath
end

function M.getRootKey(tp)
    return kvLua[tp][2]
end

--如果编码不对要先改编码
function M.checkEncoder(npcFilePath)
    local encodeType = FileEncoder.GetEncoding(npcFilePath)
    if encodeType ~= Encoding.UTF8 then
        XFileTools.ChangeFileEncodeToUTF8(npcFilePath)
        MsgManager.showMsg("检测到文本编码非utf8，已为您进行修改:%s", npcFilePath)
    end
end

function M.getUnitKV(kvType)
    if not unitKV[kvType] then
        local npcFilePath = getKvFilePath("scripts/npc/" .. kvType, true)
        if npcFilePath then
            M.checkEncoder(npcFilePath)
            unitKV[kvType] = ckv.decode_file_array(npcFilePath)
        end
    end
    return unitKV[kvType]
end

function M.getUnitTemplateMap(kvType, key)
    if not unitTemplate[kvType] then
        unitTemplate[kvType] = {}
        local kvTb = _G[kvLua[kvType][1]]
        for group, tb in pairs(kvTb) do
            for _, v in ipairs(tb) do
                unitTemplate[kvType][v[1]] = v
            end
        end 
    end
    if key then
        return unitTemplate[kvType][key]
    else
        return unitTemplate[kvType]
    end
end

function M.getUnitTemplate(kvType)
    return _G[kvLua[kvType][1]]
end

function M.saveUnitKV(kvType, groupType)
    if unitKV[kvType] and unitKV[kvType][groupType] then
        local npcFilePath = getKvFilePath("scripts/npc/" .. groupType, false)
        local text = ckv.encode2(unitKV[kvType][groupType])
        if kvType == groupType then
            local refTb = {}
            for key, _ in pairs(unitKV[kvType]) do
                if key ~= kvType then
                    table.insert(refTb, string.format("#base \"%s\"\n", key))
                end
            end
            text = table.concat(refTb, '') .. text
        end
        
        XFileTools.WriteAllText(npcFilePath, text)
    end
end

KVManager = M