local M = {
    Normal = {
        {"BaseClass", "kvdrop", "module_ability_baseclass", "ability_datadriven"},
        {"AbilityBehavior", "kvdrop", "AbilityBehavior", "DOTA_ABILITY_BEHAVIOR_AOE"},
        {"AbilityCastAnimation", "kvinput", "ACT_DOTA_CAST_ABILITY_1", nil},
        {"AbilityCastGestureSlot", "kvinput", "DEFAULT", nil},
        {"AbilityCastPoint", "kvnumber", nil, 0.3},
        {"AbilityCastRange", "kvnumber", nil, 475},
        {"AbilityCastRangeBuffer", "kvnumber", nil, 600},
        {"AbilityChannelAnimation", "kvinput", "ACT_DOTA_CHANNEL_ABILITY_1", nil},
        {"AbilityChannelTime", "kvnumber", nil, 1},
        {"AbilityChargeRestoreTime", "kvnumber", nil, 10},
        {"AbilityCharges", "kvnumber", nil, 2},
        {"AbilityCooldown", "kvnumber", nil, 30},
        {"AbilityDamage", "kvnumber", nil, 200},
        {"AbilityDraftPreAbility", "kvinput", "earth_spirit_stone_caller", nil},
        {"AbilityDraftScepterAbility", "kvinput", "tiny_tree_channel", nil},
        {"AbilityDraftShardAbility", "kvinput", "bristleback_hairball", nil},
        {"AbilityDraftUltScepterAbility", "kvinput", "earth_spirit_petrify", nil},
        {"AbilityDraftUltScepterPreAbility", "kvinput", "snapfire_spit_creep", nil},
        {"AbilityDraftUltShardAbility", "kvinput", "jakiro_liquid_ice", nil},
        {"AbilityDuration", "kvnumber", nil, 6},
        {"AbilityManaCost", "kvnumber", nil, 75},
        {"AbilityModifierSupportBonus", "kvnumber", nil, 35},
        {"AbilityModifierSupportValue", "kvnumber", nil, 0.1},
        {"AbilitySharedCooldown", "kvinput", "frostivus2018_consumable", nil},
        {"AbilitySound", "kvlink", "Hero_Beastmaster.Call.Boar", nil},
        {"AbilityTextureName", "kvlink", "consumables/seasonal_ti10_soccer_ball", nil},
        {"AbilityType", "kvdrop", "AbilityType", "DOTA_ABILITY_TYPE_ATTRIBUTES"},
        {"AbilityUnitDamageType", "kvdrop", "AbilityUnitDamageType", "DAMAGE_TYPE_COMPOSITE"},
        {"AbilityUnitTargetFlag", "kvinput", "DOTA_UNIT_TARGET_FLAG_INVULNERABLE", nil},
        {"AbilityUnitTargetFlags", "kvinput", "DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES", nil},
        {"AbilityUnitTargetTeam", "kvdrop", "AbilityUnitTargetTeam", "DOTA_UNIT_TARGET_TEAM_BOTH"},
        {"AbilityUnitTargetType", "kvdrop", "AbilityUnitTargetType", "DOTA_UNIT_TARGET_ALL"},
        {"AnimationIgnoresModelScale", "kvnumber", nil, 1},
        {"AnimationPlaybackRate", "kvnumber", nil, 1.2},
        {"AssociatedConsumable", "kvnumber", nil, 17473},
        {"DisplayAdditionalHeroes", "kvnumber", nil, 1},
        {"EventID", "kvnumber", nil, 25},
        {"FightRecapLevel", "kvnumber", nil, 1},
        {"HasScepterUpgrade", "kvnumber", nil, 1},
        {"HasShardUpgrade", "kvnumber", nil, 1},
        {"HotKeyOverride", "kvinput", "T", nil},
        {"ID", "kvnumber", nil, 7230},
        {"IsCastableWhileHidden", "kvbool", nil, 1},
        {"IsGrantedByScepter", "kvbool", nil, 1},
        {"IsGrantedByShard", "kvbool", nil, 1},
        {"IsShardUpgrade", "kvbool", nil, 1},
        {"ItemCombinable", "kvnumber", nil, 1},
        {"ItemCost", "kvnumber", nil, 0},
        {"ItemDeclaresPurchase", "kvnumber", nil, 0},
        {"ItemDisassemblable", "kvnumber", nil, 0},
        {"ItemDroppable", "kvnumber", nil, 1},
        {"ItemInitialCharges", "kvnumber", nil, 0},
        {"ItemIsNeutralDrop", "kvnumber", nil, 0},
        {"ItemKillable", "kvnumber", nil, 1},
        {"ItemPermanent", "kvnumber", nil, 1},
        {"ItemPurchasable", "kvnumber", nil, 1},
        {"ItemRecipe", "kvnumber", nil, 0},
        {"ItemRequiresCharges", "kvnumber", nil, 0},
        {"ItemSellable", "kvnumber", nil, 1},
        {"ItemShareability", "kvdrop", "ItemShareability", "ITEM_FULLY_SHAREABLE"},
        {"ItemStackable", "kvnumber", nil, 0},
        {"LevelsBetweenUpgrades", "kvnumber", nil, 7},
        {"LinkedAbility", "kvinput", "chen_test_of_faith", nil},
        {"MaxLevel", "kvnumber", nil, 1},
        {"Modelscale", "kvnumber", nil, 0.85},
        {"OnCastbar", "kvnumber", nil, 0},
        {"OnLearnbar", "kvnumber", nil, 0},
        {"RequiredLevel", "kvnumber", nil, 4},
        {"SpecialBonusIntrinsicModifier", "kvinput", "modifier_special_bonus_intelligence", nil},
        {"SpellDispellableType", "kvinput", "SPELL_DISPELLABLE_YES", nil},
        {"SpellImmunityType", "kvinput", "SPELL_IMMUNITY_ENEMIES_NO", nil},
        {"UnlockMaxEffectIndex", "kvnumber", nil, 25},
        {"UnlockMinEffectIndex", "kvnumber", nil, 24},
        {"ad_linked_abilities", "kvinput", "terrorblade_reflection", nil},
    },
    --技能事件 非modifier的
    Event = {
       
        OnAbilityPhaseStart = {},
        OnAbilityPhaseInterrupted = {},
        OnProjectileThink = {},
        OnProjectileHit = {},
        OnChannelFinish = {},
        OnChannelInterrupted = {},
        OnChannelSucceeded = {},
        OnEquip = {},
        OnUnequip = {},
        OnOwnerDied = {},
        OnOwnerSpawned = {},
        OnProjectileDodge = {},
        OnProjectileFinish = {},
        OnProjectileHitUnit = {},
        OnSpellStart = {},
        OnToggleOn = {},
        OnToggleOff = {},
        OnUpgrade = {},

    },

    --modifier事件
    ModifierEvent = {
        OnAttack = {},
        OnAttackAllied = {},
        OnAttacked = {},
        OnAttackFailed = {},
        OnAttacklanded = {},
        OnAttackStart = {},
        OnCreated = {},
        OnDealDamage = {},
        OnDeath = {},
        OnDestroy = {},
        OnHealReceived = {},
        OnHealthGained = {},
        OnHeroKilled = {},
        OnIntervalThink = {},
        OnKill = {},
        OnManaGained = {},
        OnOrder = {},
        OnSpentMana = {},
        OnStateChanged = {},
        OnTakeDamage = {},
        OnTeleported = {},
        OnTeleporting = {},
        OnUnitMoved = {},
        OnRespawn = {},
        OnAbilityStart = {},
        OnAbilityEndChannel = {},
        OnAbilityExecuted = {},
    },
    Functions = {
        Heal = {
            "Target", 
            "HealAmount",
        },
        RunScript = {
            "Function", 
        },
        SpawnUnit = {
            "UnitName", 
            "Target", 
            "Duration", 
            "UnitCount", 
            "UnitLimit", 
            "GrantsGold", 
            "GrantsXP", 
            "SpawnRadius", 
            "OnSpawn", 
        },
        ReplaceUnit = {
            "UnitName", 
            "Target", 
        },
        SpendCharge = {},
        SpendMana = {
            "Mana", 
        },
        Stun = 
        {
            "Duration", 
            "Target", 
        },
        ActOnTargets = 
        {
            "Target",
        	"Action",
        },
    },

    TreeKeys = {
        Target = function (context)
            if context.stackMap["Action"] then
                return false
            end
            return {
                "Teams",
                "Types",
                "Flags",
                "Radius",
                "Center",
            }
        end,
    },

    ModifierFunctions = {
        Heal = {
            "Target", 
        },
        RunScript = {
            "Function", 
        },
        ActOnTargets = 
        {
            "Target",
        	"Action",
        }
    },

    FunctionKeyType = {
        --1.默认的命名规则为FunctionEvent_ + Target  可以省略   第二个值为drop类 或者 number的递增值， 第三个为默认值
        Target = function (context)
            if context.stackMap["Action"] then
                return {"kvdrop"}
            end
            return {"kvtree"}
        end,
        Function = {"kvdrop"},
        Duration = {"kvnumber", 0.1, 0},
        UnitCount = {"kvnumber", 0.1, 0},
        UnitLimit = {"kvnumber", 0.1, 0},
        GrantsGold = {"kvnumber", 0.1, 0},
        GrantsXP = {"kvnumber", 0.1, 0},
        SpawnRadius = {"kvnumber", 0.1, 0},
        OnSpawn = {"kvtree"},
        UnitName = {"kvdrop"},
        Mana = {"kvnumber", 0.1, 0},
        Action = {"kvtree"},
        HealAmount = {"kvnumber", 0.1, 0},

        Teams = {"kvflag", "AbilityUnitTargetTeam"},
        Types = {"kvflag", "AbilityUnitTargetType"},
        Flags = {"kvflag", "UnitTargetFlags"},
        Radius = {"kvnumber", 10, 100},
        Center = {"kvdrop", "FunctionEvent_Center"},
    },

    Modifier = {
        {"Passive", "kvbool", nil, 1},
        {"Passive", "kvbool", nil, 1},
        {"Passive", "kvbool", nil, 1},
        {"Passive", "kvbool", nil, 1},
    }
}

function M.getFunctionList(context)
    local list = {}
    local m
    if context.isModifier then
        m = KVAbility.ModifierFunctions
    else
        m = KVAbility.Functions
    end

    for k, v in pairs(m) do
        if not context.stackMap[k] then
            table.insert(list, k)
        end
    end
    table.sort(list, function (a, b)
        return a < b
    end)
    -- table.insert(list, 1, "None")
    return list
end

function M.getFunctionKeys(key, context)
    local m
    if context.isModifier then
        m = KVAbility.ModifierFunctions
    else
        m = KVAbility.Functions
    end
    return m[key]
end

function M.getKeyTypeSelect(k, context)
    local tp = M.FunctionKeyType[k]
    if type(tp) == 'function' then
        tp = tp(context)
    end
    if not tp then
        printTraceback("Key Not Found In KVAbility.lua : %s", k)
        return k
    end
    local moduleKey = tp[2]
    if not moduleKey then
        moduleKey = "FunctionEvent_" .. k
    end
    if tp[1] == "kvdrop"
    or tp[1] == "kvflag"
    then
        local items = KVModule.getItems(moduleKey, context)
        return items[1] or ""
    elseif tp[1] == "kvtree" then
        local items = M.TreeKeys[k]
        if type(items) == 'function' then
            items = items(context)
        end
        if items then
            local ret = {}
            for _, v in pairs(items) do
                table.insert(ret, v)
                table.insert(ret, M.getKeyTypeSelect(v, context))
            end
            return ret
        else
            printError("no TreeKeys in KVModule.lua : %s", k)
            return {}
        end
    else
        return tp[3]
    end
end

function M.isFunction(key, context)
    if context.isModifier then
        return KVAbility.ModifierFunctions[key]
    end
    return KVAbility.Functions[key]
end

function M.isFunctionOrEvent(key, context)
    if not M.isFunction(key, context) then
        if context.isModifier then
            return KVAbility.ModifierEvent[key]
        end
        return KVAbility.Event[key]
    end
    return true
end

KVAbility = M