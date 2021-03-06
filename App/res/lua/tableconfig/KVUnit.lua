KVUnit = {
    Normal = {

        --字段名                        --注释                                          --控件名                        --控件参数                       --默认值                       --前置
        {"vscripts",                    "AI驱动文件",                                   "kvdrop",                   "module_AI",                    ""},
        {"BaseClass", 		            "模板基类",                                     "kvdrop",                   "module_BaseClass_Unit",         "npc_dota_creature"},
        {"Level",						"单位等级",                                     "kvnumber",                     1,                              1},
        {"ConsideredHero",              "是否作为英雄",    			                    "kvbool",                       nil,                            0},
        {"IsAncient",               	"是否作为远古",				                    "kvbool",                       nil,                            0},
        {"IsBossCreature",              "是否作为Boss生物",                             "kvbool",                       nil,                            0},

        {"IsNeutralUnitType",           "IsNeutralUnitType",                            "kvbool",                       nil},
        {"BountyXP",                    "击杀经验",					                    "kvnumber",                     10,                             0},
        {"BountyGoldMin",				"击杀金币-最小值",                              "kvnumber",                     10,                             0},
        {"BountyGoldMax",				"击杀金币-最大值",                              "kvnumber",                     10,                             0},
        {"RingRadius",				    "选中框半径",                                   "kvnumber",                     5,                              75},
        {"HealthBarOffset", 			"血条偏移",                                     "kvnumber",                     5,                              375},
        {"BoundsHullName",			    "碰撞类型",                                     "kvdrop",                      "BoundsHullName",                 "DOTA_HULL_SIZE_HUGE"},
        {"TeamName",                    "队伍",                                         "kvdrop",                       "Teams",					"DOTA_TEAM_BADGUYS"},
    },
    Ability = {
        {"Ability1",                    "技能1",                                      "kvdrop",                "module_Ability",                nil},
        {"Ability2",                    "技能2",                                      "kvdrop",                "module_Ability",                nil},   
        {"Ability3",                    "技能3",                                      "kvdrop",                "module_Ability",                nil},   
        {"Ability4",                    "技能4",                                      "kvdrop",                "module_Ability",                nil},   
        {"Ability5",                    "技能5",                                      "kvdrop",                "module_Ability",                nil},   
        {"Ability6",                    "技能6",                                      "kvdrop",                "module_Ability",                nil},   
        {"Ability7",                    "技能7",                                      "kvdrop",                "module_Ability",                nil}, 
        {"Ability8",                    "技能8",                                      "kvdrop",                "module_Ability",                nil}, 
    },
    Show = {
        {"Model",						"模型路径",                                     "kvinput",                      nil,                             "models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll_frost.vmdl"},
        {"VoiceFile",					"声音文件路径",                                 "kvinput",                      nil,                             nil},
        {"ModelScale",                  "模型缩放", 				                    "kvnumber",                     0.01,                           1},
        {"GameSoundsFile",					"GameSoundsFile",                                 "kvinput",                      nil,                             nil},
        {"SoundSet",					"声音key",                                      "kvinput",                      nil,                             nil},
        {"IdleSoundLoop",               "声音key.key",				                    "kvinput",                      nil,                             nil},
        {"MinimapIcon",				    "小地图上显示的icon",                           "kvinput",                nil,                            nil},
        {"MinimapIconSize", 			"小地图icon尺寸",                               "kvnumber",                     1,                              100},
        {"Creature",		    "Creature",                             "kvtree_fix",                       nil,                    {}},
    },
    Fight = {
        {"MovementCapabilities",		"移动类型",                                     "kvdrop",                       "MovementCap",              "DOTA_UNIT_CAP_MOVE_GROUND"},
        {"MovementSpeed",               "移动速度",                                     "kvnumber",                     10,     				    450},
        {"MovementTurnRate",            "转身速率",                                     "kvnumber",                     0.01,           			0.5},
        {"ArmorPhysical",               "护甲",                         				"kvnumber",                      1,                              0},
        {"MagicalResistance",           "魔法抗性",                                     "kvnumber",                     1,                 			0},
        {"AttackCapabilities",		    "攻击类型",                                     "kvdrop",                       "AttackCap",             "DOTA_UNIT_CAP_MELEE_ATTACK"},
        {"AttackDamageMin",             "攻击力-最小值",			                    "kvnumber",                     1,                              0,                          "precond_attack"},
        {"AttackDamageMax",             "攻击力-最大值",			                    "kvnumber",                     1,                              0,                          "precond_attack"},
        {"AttackDamageType",            "攻击类型",                         			"kvdrop",                       "AbilityUnitDamageType",            "DAMAGE_TYPE_ArmorPhysical",        "precond_attack"},
        {"AttackRate",                  "攻击速度",				                        "kvnumber",                     0.01,                           1,                          "precond_attack"},
        {"AttackAnimationPoint",        "攻击前摇",                                     "kvnumber",                     0.01,                           0.1,		                "precond_attack"},
        {"AttackAcquisitionRange",      "主动攻击距离",	                                "kvnumber",                     50,                              500,                        "precond_attack"},
        {"AttackRange",                 "攻击距离",                                     "kvnumber",     			    50,                             500,                        "precond_attack"},
        {"StatusHealth",                "生命值",                                       "kvnumber",                     100,                        1000},
        {"StatusHealthRegen",           "生命回复",                                     "kvnumber",                     0.1,            			1},
        {"StatusMana",                  "魔法值",                                       "kvnumber",                     100,                        100},
        {"StatusManaRegen",             "魔法回复",                                     "kvnumber",                     0.1,        			    1},
        {"StatusStartingMana",                    "初始魔法",                                      "kvnumber",                1,                0}, 
        {"CombatClassAttack",			"攻击战斗类型",                                 "kvdrop",                       "CombatClassAttack",          "DOTA_COMBAT_CLASS_ATTACK_BASIC"},
        {"CombatClassDefend",			"防守战斗类型",                                 "kvdrop",                       "CombatClassDefend",         "DOTA_COMBAT_CLASS_DEFEND_BASIC"},
        {"ProjectileModel",             "投射物路径(特效)",			                    "kvinput",                      nil,                            nil,                        "precond_attack_range"},
        {"ProjectileSpeed",             "投射物速度",                       			"kvnumber",                      100,                            800,                        "precond_attack_range"},
        
    },

    Unusual = {
        {"AttributePrimary",                    "AttributePrimary",                                      "kvnumber",                1,                0}, 
        {"AttributeBaseStrength",                    "AttributeBaseStrength",                                      "kvnumber",                1,                0}, 
        {"AttributeStrengthGain",                    "AttributeStrengthGain",                                      "kvnumber",                1,                0}, 
        {"AttributeBaseIntelligence",                    "AttributeBaseIntelligence",                                      "kvnumber",                1,                0}, 
        {"AttributeIntelligenceGain",                    "AttributeIntelligenceGain",                                      "kvnumber",                1,                0}, 
        {"AttributeBaseAgility",                    "AttributeBaseAgility",                                      "kvnumber",                1,                0}, 
        {"AttributeAgilityGain",                    "AttributeAgilityGain",                                      "kvnumber",                1,                0}, 
        {"PathfindingSearchDepthScale",		    "PathfindingSearchDepthScale",                             "kvbool",                       nil,                    0},

        {"UnitRelationshipClass",		"UnitRelationshipClass",                        "kvdrop",                      "UnitRelationshipClass",              "DOTA_NPC_UNIT_RELATIONSHIP_TYPE_DEFAULT"},
        {"VisionDaytimeRange",          "白天视野",                                     "kvnumber",                     100,        		5000},
        {"VisionNighttimeRange",		    "夜晚视野",                                     "kvnumber",                     100,        		5000},
        {"DisableDamageDisplay",		    "禁止伤害展示",                             "kvbool",                       nil,                    0},
        {"ShowCannotBeDisabledHealthBar",              "ShowCannotBeDisabledHealthBar",                             "kvbool",                       nil,                            0},
        {"IdleExpression",			    "vcd文件-idle",                                 "kvinput",                      nil,                           nil}, 

    },
}