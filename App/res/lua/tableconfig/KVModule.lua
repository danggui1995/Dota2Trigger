local M = {
    module_AI = function (key, value, tb)
        --TODO 返回所有的AI文件名
        return {}
    end,
    module_Ability = function (key, value, tb)
        --TODO 返回所有的技能名
        return {}
    end,
    module_BaseClass_Unit = {
        "npc_dota_creep",
        "npc_dota_creature",
        "npc_dota_building",
        "npc_dota_base_additive",
        "npc_dota_rotatable_building",
        --有自定义基类的自己在这里添加
    },

    AbilityUnitDamageType = {--（技能伤害类型）
        "DAMAGE_TYPE_COMPOSITE",
        "DAMAGE_TYPE_HP_REMOVAL",
        "DAMAGE_TYPE_MAGICAL",
        "DAMAGE_TYPE_PHYSICAL",
        "DAMAGE_TYPE_PURE",
    },
    ItemDeclarations = {--（物品购买提醒）
        "DECLARE_PURCHASES_IN_SPEECH",
        "DECLARE_PURCHASES_TO_SPECTATORS",
        "DECLARE_PURCHASES_TO_TEAMMATES",
    },
    AbilityBehavior = {--（技能行为）
        "DOTA_ABILITY_BEHAVIOR_AOE",
        "DOTA_ABILITY_BEHAVIOR_ATTACK",
        "DOTA_ABILITY_BEHAVIOR_AURA",
        "DOTA_ABILITY_BEHAVIOR_AUTOCAST",
        "DOTA_ABILITY_BEHAVIOR_CHANNELLED",
        "DOTA_ABILITY_BEHAVIOR_DIRECTIONAL",
        "DOTA_ABILITY_BEHAVIOR_DONT_ALERT_TARGET",
        "DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT",
        "DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK",
        "DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT",
        "DOTA_ABILITY_BEHAVIOR_HIDDEN",
        "DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING",
        "DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL",
        "DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE",
        "DOTA_ABILITY_BEHAVIOR_IGNORE_TURN",
        "DOTA_ABILITY_BEHAVIOR_IMMEDIATE",
        "DOTA_ABILITY_BEHAVIOR_ITEM",
        "DOTA_ABILITY_BEHAVIOR_NO_TARGET",
        "DOTA_ABILITY_BEHAVIOR_NOASSIST",
        "DOTA_ABILITY_BEHAVIOR_NONE",
        "DOTA_ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN",
        "DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE",
        "DOTA_ABILITY_BEHAVIOR_PASSIVE",
        "DOTA_ABILITY_BEHAVIOR_POINT",
        "DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES",
        "DOTA_ABILITY_BEHAVIOR_RUNE_TARGET",
        "DOTA_ABILITY_BEHAVIOR_TOGGLE",
        "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET",
        "DOTA_ABILITY_BEHAVIOR_UNRESTRICTED",
    },
    AbilityType = {--（技能类型）
        "DOTA_ABILITY_TYPE_ATTRIBUTES",
        "DOTA_ABILITY_TYPE_BASIC",
        "DOTA_ABILITY_TYPE_HIDDEN",
        "DOTA_ABILITY_TYPE_ULTIMATE",
    },
    Attributes = {--（属性）
        "DOTA_ATTRIBUTE_AGILITY",
        "DOTA_ATTRIBUTE_INTELLECT",
        "DOTA_ATTRIBUTE_STRENGTH",
    },
    HeroType = {--（英雄类型）
        "DOTA_BOT_GANKER",
        "DOTA_BOT_HARD_CARRY",
        "DOTA_BOT_NUKER",
        "DOTA_BOT_PURE_SUPPORT",
        "DOTA_BOT_PUSH_SUPPORT",
        "DOTA_BOT_SEMI_CARRY",
        "DOTA_BOT_STUN_SUPPORT",
        "DOTA_BOT_TANK",
    },
    CombatClassAttack = {--（攻击战斗类型）
        "DOTA_COMBAT_CLASS_ATTACK_BASIC",
        "DOTA_COMBAT_CLASS_ATTACK_HERO",
        "DOTA_COMBAT_CLASS_ATTACK_LIGHT",
        "DOTA_COMBAT_CLASS_ATTACK_PIERCE",
        "DOTA_COMBAT_CLASS_ATTACK_SIEGE",
    },
    CombatClassDefend = {--（防守战斗类型）
        "DOTA_COMBAT_CLASS_DEFEND_BASIC",
        "DOTA_COMBAT_CLASS_DEFEND_HERO",
        "DOTA_COMBAT_CLASS_DEFEND_SOFT",
        "DOTA_COMBAT_CLASS_DEFEND_STRONG",
        "DOTA_COMBAT_CLASS_DEFEND_STRUCTURE",
        "DOTA_COMBAT_CLASS_DEFEND_WEAK",
    },
    GameRules_States = {--（游戏规则状态）
        "DOTA_GAMERULES_STATE_DISCONNECT",
        "DOTA_GAMERULES_STATE_GAME_IN_PROGRESS",
        "DOTA_GAMERULES_STATE_HERO_SELECTION",
        "DOTA_GAMERULES_STATE_INIT",
        "DOTA_GAMERULES_STATE_LAST",
        "DOTA_GAMERULES_STATE_POST_GAME",
        "DOTA_GAMERULES_STATE_PRE_GAME",
        "DOTA_GAMERULES_STATE_STRATEGY_TIME",
        "DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD",
    },
    GC_Teams = {--（GC 队伍）
        "DOTA_GC_TEAM_BAD_GUYS",--
        "DOTA_GC_TEAM_BROADCASTER",-- 中文定义：DOTA广播员
        "DOTA_GC_TEAM_GOOD_GUYS",--
        "DOTA_GC_TEAM_NOTEAM",--
        "DOTA_GC_TEAM_PLAYER_POOL",--
        "DOTA_GC_TEAM_SPECTATOR",-- 中文定义：DOTA观众
    },
    HeroPick_States = {--（英雄选择状态）
        "DOTA_HEROPICK_STATE_AD_SELECT",
        "DOTA_HEROPICK_STATE_AP_SELECT",
        "DOTA_HEROPICK_STATE_AR_SELECT",
        "DOTA_HEROPICK_STATE_CD_BAN1",
        "DOTA_HEROPICK_STATE_CD_BAN2",
        "DOTA_HEROPICK_STATE_CD_BAN3",
        "DOTA_HEROPICK_STATE_CD_BAN4",
        "DOTA_HEROPICK_STATE_CD_CAPTAINPICK",
        "DOTA_HEROPICK_STATE_CD_INTRO",
        "DOTA_HEROPICK_STATE_CD_PICK",
        "DOTA_HEROPICK_STATE_CD_SELECT1",
        "DOTA_HEROPICK_STATE_CD_SELECT10",
        "DOTA_HEROPICK_STATE_CD_SELECT2",
        "DOTA_HEROPICK_STATE_CD_SELECT3",
        "DOTA_HEROPICK_STATE_CD_SELECT4",
        "DOTA_HEROPICK_STATE_CD_SELECT5",
        "DOTA_HEROPICK_STATE_CD_SELECT6",
        "DOTA_HEROPICK_STATE_CD_SELECT7",
        "DOTA_HEROPICK_STATE_CD_SELECT8",
        "DOTA_HEROPICK_STATE_CD_SELECT9",
        "DOTA_HEROPICK_STATE_CM_BAN1",
        "DOTA_HEROPICK_STATE_CM_BAN10",
        "DOTA_HEROPICK_STATE_CM_BAN2",
        "DOTA_HEROPICK_STATE_CM_BAN3",
        "DOTA_HEROPICK_STATE_CM_BAN4",
        "DOTA_HEROPICK_STATE_CM_BAN5",
        "DOTA_HEROPICK_STATE_CM_BAN6",
        "DOTA_HEROPICK_STATE_CM_BAN7",
        "DOTA_HEROPICK_STATE_CM_BAN8",
        "DOTA_HEROPICK_STATE_CM_BAN9",
        "DOTA_HEROPICK_STATE_CM_CAPTAINPICK",
        "DOTA_HEROPICK_STATE_CM_INTRO",
        "DOTA_HEROPICK_STATE_CM_PICK",
        "DOTA_HEROPICK_STATE_CM_SELECT1",
        "DOTA_HEROPICK_STATE_CM_SELECT10",
        "DOTA_HEROPICK_STATE_CM_SELECT2",
        "DOTA_HEROPICK_STATE_CM_SELECT3",
        "DOTA_HEROPICK_STATE_CM_SELECT4",
        "DOTA_HEROPICK_STATE_CM_SELECT5",
        "DOTA_HEROPICK_STATE_CM_SELECT6",
        "DOTA_HEROPICK_STATE_CM_SELECT7",
        "DOTA_HEROPICK_STATE_CM_SELECT8",
        "DOTA_HEROPICK_STATE_CM_SELECT9",
        "DOTA_HEROPICK_STATE_COUNT",
        "DOTA_HEROPICK_STATE_FH_SELECT",
        "DOTA_HEROPICK_STATE_INTRO_SELECT",
        "DOTA_HEROPICK_STATE_MO_SELECT",
        "DOTA_HEROPICK_STATE_NONE",
        "DOTA_HEROPICK_STATE_RD_SELECT",
        "DOTA_HEROPICK_STATE_SD_SELECT",
    },
    BoundsHullName = {--（边界外壳名）
        "DOTA_HULL_SIZE_BARRACKS",
        "DOTA_HULL_SIZE_BUILDING",
        "DOTA_HULL_SIZE_FILLER",
        "DOTA_HULL_SIZE_HERO",
        "DOTA_HULL_SIZE_HUGE",
        "DOTA_HULL_SIZE_REGULAR",
        "DOTA_HULL_SIZE_SIEGE",
        "DOTA_HULL_SIZE_SMALL",
        "DOTA_HULL_SIZE_TOWER",
},
    Inventory_Options = {--（物品栏选项）
        "DOTA_INVENTORY_ALL_ACCESS",
        "DOTA_INVENTORY_ALLOW_DROP_AT_FOUNTAIN",
        "DOTA_INVENTORY_ALLOW_DROP_ON_GROUND",
        "DOTA_INVENTORY_ALLOW_MAIN",
        "DOTA_INVENTORY_ALLOW_NONE",
        "DOTA_INVENTORY_ALLOW_STASH",
},
    ItemDisassembleRule = {--（物品拆分规则）
        "DOTA_ITEM_DISASSEMBLE_ALWAYS",
        "DOTA_ITEM_DISASSEMBLE_NEVER",
},
    Item_Stuff = {--（物品）
        "DOTA_ITEM_INVENTORY_SIZE",
        "DOTA_ITEM_MAX",
        "DOTA_ITEM_STASH_MAX",
        "DOTA_ITEM_STASH_MIN",
        "DOTA_ITEM_STASH_SIZE",
        "DOTA_ITEM_TRANSIENT_CAST_ITEM",
        "DOTA_ITEM_TRANSIENT_ITEM",
        "DOTA_ITEM_TRANSIENT_RECIPE",
},
    Gold_Modifiers = {--（金币修改器）
        "DOTA_ModifyGold_AbandonedRedistribute",
        "DOTA_ModifyGold_AbilityCost",
        "DOTA_ModifyGold_Buyback",
        "DOTA_ModifyGold_Death",
        "DOTA_ModifyGold_PurchaseConsumable",
        "DOTA_ModifyGold_PurchaseItem",
        "DOTA_ModifyGold_SellItem",
        "DOTA_ModifyGold_Unspecified",
},
    Music_Status = {--（音乐状态）
        "DOTA_MUSIC_STATUS_BATTLE",
        "DOTA_MUSIC_STATUS_DEAD",
        "DOTA_MUSIC_STATUS_EXPLORATION",
        "DOTA_MUSIC_STATUS_NONE",
        "DOTA_MUSIC_STATUS_PRE_GAME_EXPLORATION",
},
    Think_Contexts = {--（计时器环境）
        "DOTA_NPC_MODIFIER_MANAGER_THINK_CONTEXT",
        "DOTA_NPC_STATS_REGEN_THINK_CONTEXT",
        "DOTA_NPC_THINK_CONTEXT",
},
    UnitRelationshipClass = {--（单位关系类）
        "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_BARRACKS",
        "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_BUILDING",
        "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_COURIER",
        "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_DEFAULT",
        "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_HERO",
        "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_SIEGE",
        "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_WARD",
},
    Orb_Labels = {--（法球标签）
        "DOTA_ORB_LABEL_DEFAULT",
        "DOTA_ORB_LABEL_EXCEPTION",
        "DOTA_ORB_LABEL_NONE",
        "DOTA_ORB_LABEL_SKADI",
},
    Orb_Priorities = {--（法球属性）
        "DOTA_ORB_PRIORITY_ABILITY",
        "DOTA_ORB_PRIORITY_DEFAULT",
        "DOTA_ORB_PRIORITY_ITEM",
        "DOTA_ORB_PRIORITY_ITEM_PROC",
        "DOTA_ORB_PRIORITY_NONE",
},
    Precache_Filename = {--（预载文件名）
        "DOTA_PRECACHE_FILENAME",
},
    Projectile_Attatchments = {--（弹道附着物）
        "DOTA_PROJECTILE_ATTACHMENT_ATTACK_1",
        "DOTA_PROJECTILE_ATTACHMENT_ATTACK_2",
        "DOTA_PROJECTILE_ATTACHMENT_ATTACK_3",
        "DOTA_PROJECTILE_ATTACHMENT_ATTACK_4",
        "DOTA_PROJECTILE_ATTACHMENT_HITLOCATION",
        "DOTA_PROJECTILE_ATTACHMENT_NONE",
},
    Pseudo_Random_Types = {--（伪随机类型）
        "DOTA_PSEUDO_RANDOM_BREWMASTER_CRIT",
        "DOTA_PSEUDO_RANDOM_CHAOS_CRIT",
        "DOTA_PSEUDO_RANDOM_FACELESS_BASH",
        "DOTA_PSEUDO_RANDOM_ITEM_ABYSSAL",
        "DOTA_PSEUDO_RANDOM_ITEM_BASHER",
        "DOTA_PSEUDO_RANDOM_ITEM_BUTTERFLY",
        "DOTA_PSEUDO_RANDOM_ITEM_GREATERCRIT",
        "DOTA_PSEUDO_RANDOM_ITEM_HALBRED_MAIM",
        "DOTA_PSEUDO_RANDOM_ITEM_LESSERCRIT",
        "DOTA_PSEUDO_RANDOM_ITEM_MAELSTROM",
        "DOTA_PSEUDO_RANDOM_ITEM_MJOLLNIR",
        "DOTA_PSEUDO_RANDOM_ITEM_MJOLLNIR_STATIC",
        "DOTA_PSEUDO_RANDOM_ITEM_MKB",
        "DOTA_PSEUDO_RANDOM_ITEM_PMS",
        "DOTA_PSEUDO_RANDOM_ITEM_SANGE_MAIM",
        "DOTA_PSEUDO_RANDOM_ITEM_SANGEYASHA_MAIM",
        "DOTA_PSEUDO_RANDOM_ITEM_STOUT",
        "DOTA_PSEUDO_RANDOM_ITEM_VANGUARD",
        "DOTA_PSEUDO_RANDOM_JUGG_CRIT",
        "DOTA_PSEUDO_RANDOM_LYCAN_CRIT",
        "DOTA_PSEUDO_RANDOM_PHANTOMASSASSIN_CRIT",
        "DOTA_PSEUDO_RANDOM_SKELETONKING_CRIT",
        "DOTA_PSEUDO_RANDOM_SLARDAR_BASH",
        "DOTA_PSEUDO_RANDOM_SNIPER_HEADSHOT",
        "DOTA_PSEUDO_RANDOM_TROLL_BASH",
},
    Rune_Types = {--（神符类型）
        "DOTA_RUNE_DOUBLEDAMAGE",
        "DOTA_RUNE_HASTE",
        "DOTA_RUNE_HAUNTED",
        "DOTA_RUNE_ILLUSION",
        "DOTA_RUNE_INVISIBILITY",
        "DOTA_RUNE_MYSTERY",
        "DOTA_RUNE_RAPIER",
        "DOTA_RUNE_REGENERATION",
        "DOTA_RUNE_SPOOKY",
        "DOTA_RUNE_TURBO",
},
    Teams = {--（队伍）
        "DOTA_TEAM_FIRST",	
        "DOTA_TEAM_GOODGUYS",	
        "DOTA_TEAM_BADGUYS",	
        "DOTA_TEAM_NEUTRALS",	
        "DOTA_TEAM_NOTEAM",	
        "DOTA_TEAM_CUSTOM_1",	
        "DOTA_TEAM_CUSTOM_2",	
        "DOTA_TEAM_CUSTOM_3",	
        "DOTA_TEAM_CUSTOM_4",	
        "DOTA_TEAM_CUSTOM_5",	
        "DOTA_TEAM_CUSTOM_6",	
        "DOTA_TEAM_CUSTOM_7",	
        "DOTA_TEAM_CUSTOM_8",	
        "DOTA_TEAM_COUNT",	
        "DOTA_TEAM_CUSTOM_MIN",	
        "DOTA_TEAM_CUSTOM_MAX",	
        "DOTA_TEAM_CUSTOM_COUNT", 
},
    AttackCap= {--（攻击设定）
        "DOTA_UNIT_CAP_MELEE_ATTACK",
        "DOTA_UNIT_CAP_RANGED_ATTACK",
        "DOTA_UNIT_CAP_NO_ATTACK",
},
    MovementCap = {--（移动设定）
        "DOTA_UNIT_CAP_MOVE_GROUND",
        "DOTA_UNIT_CAP_MOVE_FLY",
        "DOTA_UNIT_CAP_MOVE_NONE",
},

    OrderType = {--（单位命令类型）
        "DOTA_UNIT_ORDER_ATTACK_MOVE",
        "DOTA_UNIT_ORDER_ATTACK_TARGET",
        "DOTA_UNIT_ORDER_BUYBACK",
        "DOTA_UNIT_ORDER_CAST_NO_TARGET",
        "DOTA_UNIT_ORDER_CAST_POSITION",
        "DOTA_UNIT_ORDER_CAST_RUNE",
        "DOTA_UNIT_ORDER_CAST_TARGET",
        "DOTA_UNIT_ORDER_CAST_TARGET_TREE",
        "DOTA_UNIT_ORDER_CAST_TOGGLE",
        "DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO",
        "DOTA_UNIT_ORDER_DISASSEMBLE_ITEM",
        "DOTA_UNIT_ORDER_DROP_ITEM",
        "DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH",
        "DOTA_UNIT_ORDER_GIVE_ITEM",
        "DOTA_UNIT_ORDER_GLYPH",
        "DOTA_UNIT_ORDER_HOLD_POSITION",
        "DOTA_UNIT_ORDER_MOVE_ITEM",
        "DOTA_UNIT_ORDER_MOVE_TO_POSITION",
        "DOTA_UNIT_ORDER_MOVE_TO_TARGET",
        "DOTA_UNIT_ORDER_NONE",
        "DOTA_UNIT_ORDER_PICKUP_ITEM",
        "DOTA_UNIT_ORDER_PICKUP_RUNE",
        "DOTA_UNIT_ORDER_PURCHASE_ITEM",
        "DOTA_UNIT_ORDER_SELL_ITEM",
        "DOTA_UNIT_ORDER_STOP",
        "DOTA_UNIT_ORDER_TAUNT",
        "DOTA_UNIT_ORDER_TRAIN_ABILITY",
},
    AbilityUnitTargetType = {--（技能目标单位类型）
        "DOTA_UNIT_TARGET_ALL",
        "DOTA_UNIT_TARGET_BASIC",
        "DOTA_UNIT_TARGET_BUILDING",
        "DOTA_UNIT_TARGET_COURIER",
        "DOTA_UNIT_TARGET_CREEP",
        "DOTA_UNIT_TARGET_CUSTOM",
        "DOTA_UNIT_TARGET_HERO",
        "DOTA_UNIT_TARGET_MECHANICAL",
        "DOTA_UNIT_TARGET_NONE",
        "DOTA_UNIT_TARGET_OTHER",
        "DOTA_UNIT_TARGET_TREE",
},
    UnitTargetFlags = {--（单位目标标签）
        "DOTA_UNIT_TARGET_FLAG_CHECK_DISABLE_HELP",
        "DOTA_UNIT_TARGET_FLAG_DEAD",
        "DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE",
        "DOTA_UNIT_TARGET_FLAG_INVULNERABLE",
        "DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES",
        "DOTA_UNIT_TARGET_FLAG_MANA_ONLY",
        "DOTA_UNIT_TARGET_FLAG_MELEE_ONLY",
        "DOTA_UNIT_TARGET_FLAG_NO_INVIS",
        "DOTA_UNIT_TARGET_FLAG_NONE",
        "DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS",
        "DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE",
        "DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO",
        "DOTA_UNIT_TARGET_FLAG_NOT_DOMINATED",
        "DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS",
        "DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES",
        "DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED",
        "DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED",
        "DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD",
        "DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED",
        "DOTA_UNIT_TARGET_FLAG_RANGED_ONLY",
},
    AbilityUnitTargetTeam = {--（技能可作用的目标单位队伍）
        "DOTA_UNIT_TARGET_TEAM_BOTH",
        "DOTA_UNIT_TARGET_TEAM_CUSTOM",
        "DOTA_UNIT_TARGET_TEAM_ENEMY",
        "DOTA_UNIT_TARGET_TEAM_FRIENDLY",
        "DOTA_UNIT_TARGET_TEAM_NONE",
},
    ConVar_Flags = {--（控制台变量标签）
        "FCVAR_ARCHIVE",
        "FCVAR_CHEAT",
        "FCVAR_DEMO",
        "FCVAR_DEVELOPMENTONLY",
        "FCVAR_DONTRECORD",
        "FCVAR_HIDDEN",
        "FCVAR_NEVER_AS_STRING",
        "FCVAR_NOT_CONNECTED",
        "FCVAR_NOTIFY",
        "FCVAR_PRINTABLEONLY",
        "FCVAR_PROTECTED",
        "FCVAR_REPLICATED",
        "FCVAR_SPONLY",
        "FCVAR_SS",
        "FCVAR_UNLOGGED",
        "FCVAR_UNREGISTERED",
        "FCVAR_USERINFO",
        "FCVAR_VCONSOLE_SET_FOCUS",
},
    Find_Types = {--（寻找类型）
        "FIND_ANY_ORDER",
        "FIND_CLOSEST",
        "FIND_FARTHEST",
        "FIND_UNITS_EVERYWHERE",
},
    ItemShareability = {--（物品的共享属性）
        "ITEM_FULLY_SHAREABLE",
        "ITEM_FULLY_SHAREABLE_STACKING",
        "ITEM_NOT_SHAREABLE",
        "ITEM_PARTIALLY_SHAREABLE",
},
    Item_Types = {--（物品类型）
        "ITEM_CONSUMABLE",
        "ITEM_CORE",
        "ITEM_DERIVED",
        "ITEM_EXTENSION",
        "ITEM_LUXURY",
        "ITEM_SELLABLE",
},
    Item_Flags = {--（物品标签）
        "ITEM_FLAG_DOHITLOCATIONDMG",
        "ITEM_FLAG_EXHAUSTIBLE",
        "ITEM_FLAG_LIMITINWORLD",
        "ITEM_FLAG_NOAMMOPICKUPS",
        "ITEM_FLAG_NOAUTORELOAD",
        "ITEM_FLAG_NOAUTOSWITCHEMPTY",
        "ITEM_FLAG_NOITEMPICKUP",
        "ITEM_FLAG_SELECTONEMPTY",
},
    Modifier_Attributes = {--（修改器属性）
        "MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE",
        "MODIFIER_ATTRIBUTE_MULTIPLE",
        "MODIFIER_ATTRIBUTE_NONE",
        "MODIFIER_ATTRIBUTE_PERMANENT",
},
        Modifier_Events = {--（修改器事件）
        "MODIFIER_EVENT_ON_ABILITY_END_CHANNEL",
        "MODIFIER_EVENT_ON_ABILITY_EXECUTED",
        "MODIFIER_EVENT_ON_ABILITY_START",
        "MODIFIER_EVENT_ON_ATTACK",
        "MODIFIER_EVENT_ON_ATTACK_ALLIED",
        "MODIFIER_EVENT_ON_ATTACK_FAIL",
        "MODIFIER_EVENT_ON_ATTACK_LANDED",
        "MODIFIER_EVENT_ON_ATTACK_START",
        "MODIFIER_EVENT_ON_ATTACKED",
        "MODIFIER_EVENT_ON_BREAK_INVISIBILITY",
        "MODIFIER_EVENT_ON_DEATH",
        "MODIFIER_EVENT_ON_HEALTH_GAINED",
        "MODIFIER_EVENT_ON_MANA_GAINED",
        "MODIFIER_EVENT_ON_ORB_EFFECT",
        "MODIFIER_EVENT_ON_ORDER",
        "MODIFIER_EVENT_ON_PROCESS_UPGRADE",
        "MODIFIER_EVENT_ON_PROJECTILE_DODGE",
        "MODIFIER_EVENT_ON_REFRESH",
        "MODIFIER_EVENT_ON_RESPAWN",
        "MODIFIER_EVENT_ON_SPENT_MANA",
        "MODIFIER_EVENT_ON_STATE_CHANGED",
        "MODIFIER_EVENT_ON_TAKEDAMAGE",
        "MODIFIER_EVENT_ON_TAKEDAMAGE_REAPERSCYTHE",
        "MODIFIER_EVENT_ON_TELEPORTED",
        "MODIFIER_EVENT_ON_TELEPORTING",
        "MODIFIER_EVENT_ON_UNIT_MOVED",
},

    --技能事件
    FunctionEvent_Target = function (context)
        if context.stackMap["ActOnTargets"] then
            return {"TARGET"}
        else
            local ret = {"CASTER", "PROJECTILE"}
            if context.skillBehavior:find("NO_TARGET") then
            else
                if context.skillBehavior:find("POINT") then
                    table.insert(ret, "POINT")
                end
                if context.skillBehavior:find("TARGET") then
                    table.insert(ret, "TARGET")
                    table.insert(ret, "CASTER")
                    table.insert(ret, "UNIT")
                end
            end
            return ret
        end
    end,
    FunctionEvent_Center = function (context)
        local ret = {"CASTER", "PROJECTILE"}

        if context.skillBehavior:find("NO_TARGET") then
        else
            if context.skillBehavior:find("POINT") then
                table.insert(ret, "POINT")
            end
            if context.skillBehavior:find("TARGET") then
                table.insert(ret, "TARGET")
                table.insert(ret, "CASTER")
                table.insert(ret, "UNIT")
            end
        end
        return ret
    end,
    FunctionEvent_Function = {"kvdrop", function ()
        return {}
    end},
    FunctionEvent_OnSpawn = function (context)
        return KVAbility.getFunctionList(context)
    end,
    FunctionEvent_UnitName = function ()
        local all = KVManager.getUnitKV(KVManager.Type_Unit)
        local list = {}
        for index = 1, #all - 1, 2 do
            if type(all[index + 1]) == 'table' then
                table.insert(list, all[index])
            end
        end
        return list
    end,
    FunctionEvent_Action = function (context)
        return KVAbility.getFunctionList(context)
    end,
    FunctionEvent_None = function ()
        --直接返回一个空table
        return {}
    end,
}

function M.getItems(key, context)
    local items = KVModule[key]
    if type(items) == 'function' then
        items = items(context)
    end
    if not items then
        printTraceback("No Modulekey : %s", key)
    end
    return items
end

KVModule = M