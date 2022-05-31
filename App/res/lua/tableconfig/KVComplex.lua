local M = {
    -------Begin Unit
    Creature = {
    	"kvtree_fix",
        "HPGain",
        "DamageGain",
        "ArmorGain",
        "MagicResistGain",
        "MoveSpeedGain",
        "BountyGain",
        "XPGain",
        "AttachWearables",
    },
    HPGain = {"kvnumber", 1, 0},
    DamageGain = {"kvnumber", 1, 0},
    ArmorGain = {"kvnumber", 1, 0},
    MagicResistGain = {"kvnumber", 1, 0},
    MoveSpeedGain = {"kvnumber", 1, 0},
    BountyGain = {"kvnumber", 1, 0},
    XPGain = {"kvnumber", 1, 0},
    AttachWearables = {"kvarray", "ItemDef"},
    ItemDef = {"kvlink", function (context, callback)
        VPKManager.load_items_game(function(kv, kvMap)
            local id = context.data
            if kvMap[id] and kvMap[id]["model_player"] then
                context.partpath = kvMap[id]["model_player"]
            else
                -- MsgManager.showMsg("items_game.txt中找不到id=%s", id)
                context.partpath = ""
            end
            UIManager.openView("modelselectview", context, callback)
        end)
        
    end, 0},
    ----------End Unit


    -------Begin Ability
    AbilitySound = {"kvlink", function(context, callback)
        UIManager.openView("audioselectview", context.data, function (data)
            callback(data)
            UIManager.closeView("audioselectview")
        end)
    end, ""},
    AbilityTextureName = {"kvlink", function (context, callback)
        UIManager.openView("textureselectview", context.data, function (data)
            callback(data)
            UIManager.closeView("textureselectview")
        end)
    end, ""},

    ----------End Ability

}

KVComplex = M

function M.getDefaultValue(key, ...)
    local info = M[key]
    if not info then
        MsgManager.showMsg("KVComplex找不到key配置：%s", key)
        return
    end
    info = info[3] or "0"
    if type(info) == 'function' then
        return info(...)
    end
    return info
end