extends Node

var prof_to_exp := {}

var dnd_conditions := [
	"Blinded",
	"Charmed",
	"Deafened",
	"Exhaustion",
	"Frightened",
	"Grappled",
	"Paralyzed",
	"Petrified",
	"Poisoned",
	"Prone",
	"Restrained",
	"Stunned",
]

var dnd_damage := [
	"Acid",
	"Cold",
	"Fire",
	"Force",
	"Lightning",
	"Necrotic",
	"Poison",
	"Psychic",
	"Radiant",
	"Thunder",
	"Bludgeoning",
	"Piercing",
	"Slashing" 
]

var exp_to_prof := {
	# Mind and knowledge
	"Scholar": ["arcana", "history", "religion", "draconic"],
	"Observer": ["investigation", "insight", "perception"],
	"Healer": ["medicine", "herbalism kit"],
	"Wilderness": ["nature", "animal handling", "survival"],
	# Physical ability and interaction
	"Athlete": ["athletics", "acrobatics"],
	"Light Feet": ["stealth", "sleight of hand"],
	"Silver Tongue": ["deception", "intimidation", "persuasion"],
	"Performer": [
		"performance", "bagpipes", "drum", "dulcimer", "flute", "horn",
		"lute", "lyre", "pan flute", "shawm", "viol"
	],
	# Craft and tools
	"Inventor": ["alchemist's supplies", "tinker's tools", "poisoner's kit", "glassblower's tools"],
	"Artisan": [
		"calligrapher's supplies", "painter's supplies", "weaver's tools",
		"carpenter's tools", "mason's tools", "smith's tools",
		"woodcarver's tools", "leatherworker's tools", "cobbler's tools", "jeweler's tools", "potter's tools"
	],
	"Chef": ["cook's utensils", "brewer's supplies"],
	"Con Artist": ["disguise kit", "forgery kit", "thieves' tools"],
	# Travel and navigation
	"Explorer": ["navigator's tools", "cartographer's tools", "land vehicles", "water vehicles"],
	# Games and strategy
	"Gambler": ["dice set", "playing card set", "three-dragon ante set", "dragonchess set"],
	# Combat
	"Thief": ["dagger", "shortsword", "hand crossbow", "thieves' cant"],
	"Swashbuckler": ["rapier", "scimitar", "whip"],
	"Sellsword": [
		"greataxe", "greatsword", "maul", "battleaxe", "mace", "warhammer",
		"morningstar", "flail", "trident", "halberd", "glaive", "pike",
		"club", "greatclub", "quarterstaff", "light hammer", "handaxe",
		"spear", "war pick", "net"
	],
	"Sharpshooter": [
		"longbow", "shortbow", "light crossbow", "heavy crossbow", "blowgun",
		"dart", "sling", "musket", "pistol", "javelin"
	],
	"Armored Fighter": ["lance", "heavy armor", "medium armor", "light armor", "shields"],
	"Brawler": ["unarmed strike", "improvised weapon", "martial weapons", "simple weapon"],
	# Languages
	"Secrets of the Ancients": ["celestial", "abyssal", "deep speech", "infernal", "primordial", "undercommon"],
	"World Traveler": ["common", "dwarvish", "elvish", "gnomish", "giant", "goblin", "halfling", "orc", "common sign language"],
	"Nature's Friend": ["sylvan", "druidic"],
}

var dnd_medians_stats_by_cr = {
	0.0: {"count": 77, "ac": 12, "hp": 0, "str_save_mod": -1, "dex_save_mod": 1, "con_save_mod": 0, "int_save_mod": -4, "wis_save_mod": 1, "cha_save_mod": -2},
	0.125: {"count": 47, "ac": 12, "hp": 0, "str_save_mod": 0, "dex_save_mod": 1, "con_save_mod": 0, "int_save_mod": -2, "wis_save_mod": 0, "cha_save_mod": -2},
	0.25: {"count": 98, "ac": 12, "hp": 0, "str_save_mod": 1, "dex_save_mod": 1, "con_save_mod": 1, "int_save_mod": -2, "wis_save_mod": 0, "cha_save_mod": -2},
	0.5: {"count": 95, "ac": 13, "hp": 0, "str_save_mod": 1, "dex_save_mod": 1, "con_save_mod": 1, "int_save_mod": -1, "wis_save_mod": 0, "cha_save_mod": -1},
	1.0: {"count": 110, "ac": 13, "hp": 30, "str_save_mod": 1, "dex_save_mod": 2, "con_save_mod": 1, "int_save_mod": 0, "wis_save_mod": 1, "cha_save_mod": 0},
	2.0: {"count": 173, "ac": 14, "hp": 45, "str_save_mod": 2, "dex_save_mod": 1, "con_save_mod": 2, "int_save_mod": 0, "wis_save_mod": 1, "cha_save_mod": 0},
	3.0: {"count": 121, "ac": 14, "hp": 60, "str_save_mod": 3, "dex_save_mod": 2, "con_save_mod": 2, "int_save_mod": 0, "wis_save_mod": 1, "cha_save_mod": 0},
	4.0: {"count": 83, "ac": 14, "hp": 75, "str_save_mod": 3, "dex_save_mod": 2, "con_save_mod": 3, "int_save_mod": 0, "wis_save_mod": 1, "cha_save_mod": 1},
	5.0: {"count": 111, "ac": 15, "hp": 90, "str_save_mod": 3, "dex_save_mod": 2, "con_save_mod": 3, "int_save_mod": 0, "wis_save_mod": 1, "cha_save_mod": 0},
	6.0: {"count": 55, "ac": 15, "hp": 105, "str_save_mod": 4, "dex_save_mod": 2, "con_save_mod": 3, "int_save_mod": 1, "wis_save_mod": 2, "cha_save_mod": 1},
	7.0: {"count": 50, "ac": 15, "hp": 120, "str_save_mod": 4, "dex_save_mod": 2, "con_save_mod": 3, "int_save_mod": 0, "wis_save_mod": 2, "cha_save_mod": 1},
	8.0: {"count": 54, "ac": 15, "hp": 135, "str_save_mod": 4, "dex_save_mod": 2, "con_save_mod": 4, "int_save_mod": 0, "wis_save_mod": 2, "cha_save_mod": 1},
	9.0: {"count": 45, "ac": 16, "hp": 150, "str_save_mod": 4, "dex_save_mod": 2, "con_save_mod": 6, "int_save_mod": 1, "wis_save_mod": 4, "cha_save_mod": 2},
	10.0: {"count": 37, "ac": 17, "hp": 165, "str_save_mod": 4, "dex_save_mod": 2, "con_save_mod": 5, "int_save_mod": 2, "wis_save_mod": 5, "cha_save_mod": 3},
	11.0: {"count": 30, "ac": 17, "hp": 180, "str_save_mod": 5.5, "dex_save_mod": 3, "con_save_mod": 6.5, "int_save_mod": 1.5, "wis_save_mod": 6, "cha_save_mod": 3},
	12.0: {"count": 20, "ac": 17, "hp": 195, "str_save_mod": 4.5, "dex_save_mod": 2, "con_save_mod": 6, "int_save_mod": 2, "wis_save_mod": 6, "cha_save_mod": 3},
	13.0: {"count": 26, "ac": 17, "hp": 210, "str_save_mod": 4.5, "dex_save_mod": 3, "con_save_mod": 7.5, "int_save_mod": 3, "wis_save_mod": 6, "cha_save_mod": 6.5},
	14.0: {"count": 18, "ac": 18, "hp": 225, "str_save_mod": 5, "dex_save_mod": 3, "con_save_mod": 9, "int_save_mod": 2.5, "wis_save_mod": 7, "cha_save_mod": 6.5},
	15.0: {"count": 15, "ac": 18, "hp": 240, "str_save_mod": 6, "dex_save_mod": 3, "con_save_mod": 5, "int_save_mod": 3, "wis_save_mod": 7, "cha_save_mod": 8},
	16.0: {"count": 18, "ac": 18.5, "hp": 255, "str_save_mod": 7, "dex_save_mod": 5, "con_save_mod": 7, "int_save_mod": 2.5, "wis_save_mod": 6.5, "cha_save_mod": 8.5},
	17.0: {"count": 12, "ac": 19, "hp": 270, "str_save_mod": 6.5, "dex_save_mod": 6, "con_save_mod": 10.5, "int_save_mod": 3, "wis_save_mod": 8.5, "cha_save_mod": 10},
	18.0: {"count": 10, "ac": 18.5, "hp": 285, "str_save_mod": 4, "dex_save_mod": 3.5, "con_save_mod": 9.5, "int_save_mod": 3.5, "wis_save_mod": 9, "cha_save_mod": 10},
	19.0: {"count": 6, "ac": 18, "hp": 300, "str_save_mod": 7, "dex_save_mod": 4, "con_save_mod": 10.5, "int_save_mod": 3.5, "wis_save_mod": 7.5, "cha_save_mod": 12},
	20.0: {"count": 7, "ac": 19, "hp": 315, "str_save_mod": 8, "dex_save_mod": 6, "con_save_mod": 13, "int_save_mod": 0, "wis_save_mod": 8, "cha_save_mod": 8},
	21.0: {"count": 11, "ac": 19, "hp": 330, "str_save_mod": 8, "dex_save_mod": 8, "con_save_mod": 13, "int_save_mod": 5, "wis_save_mod": 11, "cha_save_mod": 7},
	22.0: {"count": 8, "ac": 19, "hp": 345, "str_save_mod": 7.5, "dex_save_mod": 4, "con_save_mod": 11, "int_save_mod": 8.5, "wis_save_mod": 10, "cha_save_mod": 11},
	23.0: {"count": 15, "ac": 21, "hp": 360, "str_save_mod": 9, "dex_save_mod": 7, "con_save_mod": 14, "int_save_mod": 4, "wis_save_mod": 11, "cha_save_mod": 8},
	24.0: {"count": 6, "ac": 20.5, "hp": 375, "str_save_mod": 9.5, "dex_save_mod": 8, "con_save_mod": 14, "int_save_mod": 4, "wis_save_mod": 11.5, "cha_save_mod": 13.5},
	25.0: {"count": 6, "ac": 20.5, "hp": 390, "str_save_mod": 10, "dex_save_mod": 8, "con_save_mod": 15.5, "int_save_mod": 5.5, "wis_save_mod": 11, "cha_save_mod": 7.5},
	26.0: {"count": 5, "ac": 22, "hp": 405, "str_save_mod": 9, "dex_save_mod": 7, "con_save_mod": 15, "int_save_mod": 14, "wis_save_mod": 11, "cha_save_mod": 7},
	28.0: {"count": 2, "ac": 23.5, "hp": 420, "str_save_mod": 10.5, "dex_save_mod": 4.5, "con_save_mod": 14, "int_save_mod": 11.5, "wis_save_mod": 14, "cha_save_mod": 15.5},
	30.0: {"count": 2, "ac": 25, "hp": 435, "str_save_mod": 14.5, "dex_save_mod": 4.5, "con_save_mod": 10, "int_save_mod": 6.5, "wis_save_mod": 13, "cha_save_mod": 9}
}


func _ready():
	for experience in exp_to_prof.keys():
		for prof in exp_to_prof[experience]:
			prof_to_exp[prof.strip_edges().to_lower()] = experience
