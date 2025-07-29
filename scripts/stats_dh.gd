extends VBoxContainer

enum FeatureTrigger { ## How the feature is activated (passive, action + stress, action + fear, reaction)
	PASSIVE, 		## Passive trigger
	ACTION_STRESS, 	## Action activated by spending a stress
	ACTION_FEAR, 	## Action activated by spending a stress
	REACTION, 		## Triggered with reaction
}

enum FeatureCost { ## How the feature is activated (passive, action + stress, action + fear, reaction)
	FREE, 			## Passive trigger
	MARK_A_STRESS, 	## Action activated by spending a stress
	MARK_A_FEAR, 	## Action activated by spending a stress
}

var has_psychic_immunity := false
var has_psychic_resistance := false
var has_charmed_immunity := false
var tier: int
var feature: Dictionary = {
	feature_name = "", 			## Like "Relentless"
	amount = 0, 				## Like (4) 
	trigger = FeatureTrigger,	## Like Passive 
	cost = FeatureCost,			## Like Mark a stress
	feature_description = "",	## Description
}

@onready var adversary_name = %Name_DH
@onready var tier_box = %Tier_DH
@onready var difficulty = %Difficulty_DH
@onready var hp = %HP_DH
@onready var stress_box = %Stress_DH
@onready var stress_increase = %Stress_increase
@onready var thresholds = %Thresholds_DH
@onready var attack_mod_box = %AttackModifier_DH
@onready var damage_box = %Damage_DH
@onready var experiences_dh = %Experiences_DH
@onready var features_container = %FeaturesContainer

func _ready():
	hide()

func init(data: Dictionary) -> void:
	_reset_fields()
	
	_set_dh_name(data["monster_name"])
	_set_dh_tier_and_type(data)
	_set_dh_difficulty(data["cr"])
	_set_dh_thresholds(data["cr"])
	_set_dh_attack_mod(data["cr"])
	_set_dh_damage(data["ac"])
	_set_hp(data["hp"])
	_set_stress(data["intelligence"])
	_update_stress_display(data["damage_immunities"], data["damage_resistances"], data["condition_immunities"])
	_set_experiences(data["proficiencies"], data["proficiency_bonus"])
	_classify_monster(data)
	_create_features(data)
	
	show()

func _reset_fields() -> void:
	for child in features_container.get_children():
		child.queue_free()

func _set_dh_name(dnd_name: String) -> void:
	adversary_name.text = "Name: " + dnd_name


func _set_dh_tier_and_type(data: Dictionary) -> void:
	var dnd_cr: float = data["cr"]
	if dnd_cr <= 2.0:
		tier = 1
	elif dnd_cr <= 7.0:
		tier = 2
	elif dnd_cr <= 14.0:
		tier = 3
	else:
		tier = 4
	tier_box.text = "[b][i]Tier " + str(tier) + " " + _classify_monster(data) + "[/i][/b] " 


func _set_dh_difficulty(dnd_cr: float) -> void:
	var diff := ""
	if dnd_cr <= 0.5:
		diff = "10-11"
	elif dnd_cr <= 2.0:
		diff = "11-13"
	elif dnd_cr <= 7.0:
		diff = "14-16"
	elif dnd_cr <= 14.0:
		diff = "17-19"
	else:
		diff = "20"
	difficulty.text = "[b]Difficulty:[/b] " + diff

func _set_dh_thresholds(dnd_cr: float) -> void:
	var thr := ""
	if dnd_cr <= 0.5:
		thr = "7/10"
	elif dnd_cr <= 2.0:
		thr = "10/12"
	elif dnd_cr <= 7.0:
		thr = "10/20"
	elif dnd_cr <= 14.0:
		thr = "20/32"
	else:
		thr = "25/45"
	thresholds.text = "[b]Thresholds:[/b] " + thr

func _set_dh_attack_mod(dnd_cr: float) -> void:
	var mod := ""
	if dnd_cr <= 0.5:
		mod = "+0 to +1"
	elif dnd_cr <= 2.0:
		mod = "+1 to +2"
	elif dnd_cr <= 7.0:
		mod = "+2 to +3"
	elif dnd_cr <= 14.0:
		mod = "+3 to +4"
	else:
		mod = "+4 to +5"
	attack_mod_box.text = "[b]ATK[/b]: " + mod

func _set_dh_damage(dnd_cr: float) -> void:
	var dmg := ""
	if dnd_cr <= 0.5:
		dmg = "1d6+2 to 1d10+3"
	elif dnd_cr <= 2.0:
		dmg = "1d8+3 to 1d12+4"
	elif dnd_cr <= 7.0:
		dmg = "2d6+3 to 2d12+4"
	elif dnd_cr <= 14.0:
		dmg = "3d8+3 to 3d12+5"
	else:
		dmg = "4d8+10 to 4d12+15"
	damage_box.text = dmg

func _set_hp(_value: int) -> void:
	hp.text = "[b]HP:[/b] Type + " + str(tier)

func _set_stress(intelligence: int) -> void:
	var stress := ""
	if intelligence <= 1:		# No intelligence (Beasts, Plants)
		stress = "1-2"
	elif intelligence <= 8:		# Low intelligence
		stress = "3-4"
	elif intelligence <= 11:	# Average intelligence
		stress = "5-6"
	elif intelligence <= 18:	# High intelligence
		stress = "7-8"
	else:						# Exceptional intelligence
		stress = "9-10"
	stress_box.text = "[b]Stress:[/b] " + stress


func _update_stress_display(dmg_imm: Array, dmg_res: Array, cond_imm: Array) -> void:
	if "psychic" in dmg_imm or "psychic" in dmg_res or "charmed" in cond_imm:
		stress_increase.show()
	else:
		stress_increase.hide()


func _set_experiences(dnd_profs: Array, dnd_prof_bonus: int) -> void:
	if dnd_profs.is_empty():
		experiences_dh.text = ""
		return
	
	var experiences: Array[String] = []

	for prof in dnd_profs:
		var key = prof.strip_edges().to_lower()
		if StatsBenchmark.prof_to_exp.has(key):
			var exp_name = StatsBenchmark.prof_to_exp[key]
			var exp_string = exp_name + " +" + str(dnd_prof_bonus)
			if not experiences.has(exp_string):
				experiences.append(exp_string)
	
	experiences_dh.text = "[b]Experience:[/b] " + ", ".join(experiences)

func _create_features(monster_data: Dictionary) -> void:
	var multiattack_amount = _get_multiattack_count(monster_data)
	if multiattack_amount == 0:
		return
	_compose_feature({
		feature_name = "Relentless",
		amount = multiattack_amount,
		trigger = FeatureTrigger.PASSIVE,
		cost = FeatureCost.FREE,			## Like Mark a stress
		description = "The {monster_name} can be spotlighted up to {amount} ".format({
							"monster_name": monster_data.monster_name, 
							"amount": multiattack_amount}) +
					"times per GM turn. Spend Fear as usual to spotlight them."
		})

func _compose_feature(feat: Dictionary) -> void:
	var new_feature: RichTextLabel = RichTextLabel.new()
	new_feature.bbcode_enabled = true
	new_feature.fit_content = true

	var feature_amount: String = " (" + str(feat.amount) + ")" if feat.amount > 0 else ""
	var feature_cost := ""
	var trigger := ""
	if not feat.cost == FeatureCost.FREE:
		match feat.cost:
			FeatureCost.MARK_A_STRESS:
				feature_cost = "Mark a Stress"
			FeatureCost.MARK_A_FEAR:
				feature_cost = "Spend a Fear"
	
	
	new_feature.text = "[b][i]{feature_name}{amount} - {trigger}: {cost}[/i][/b] {description}".format({
		"feature_name": feat.feature_name,
		"amount": feature_amount,
		"trigger": FeatureTrigger.keys()[feat.trigger].to_pascal_case(),
		"cost": feature_cost,
		"description": feat.description
	})
	
	features_container.add_child(new_feature)
	

func _classify_monster(monster_data: Dictionary) -> String:
	var ref = StatsBenchmark.dnd_medians_stats_by_cr[monster_data["cr"]]

	var delta_hp = monster_data.get("hp", 0) / float(ref.hp)
	var delta_ac = monster_data.get("ac", 0) / float(ref.ac)
	#var delta_dpr = monster_data.get("dpr", 0) / float(ref.dpr)
	#var delta_att = monster_data.get("attack_bonus", 0) /# float(ref.attack_bonus)

	#var dex = monster_data.get("dexterity", 10)
	#var cha = monster_data.get("charisma", 10)
	var skills = []
	for prof in monster_data.get("proficiencies", []):
		skills.append(prof.to_lower())
		
	var special_abilities = []
	for spec_ab in monster_data.get("special_abilities", []):
		special_abilities.append(spec_ab.name.to_lower())
		

	var legendary_actions = monster_data.get("legendary_actions", []).size() > 0
	var multiattack_count = _get_multiattack_count(monster_data)

	var is_ranged = _has_ranged_attack(monster_data)
	var has_stealth = "stealth" in skills
	var is_swarm = "swarm" in special_abilities
	#var has_buff_or_debuff = false # Placeholder
	#var can_command = false        # Placeholder
	#var can_summon = false         # Placeholder
	#var has_social_spells = false  # Placeholder

	if delta_hp > 1.4 and multiattack_count >= 3 or legendary_actions:
		return "Solo"
	#elif delta_hp > 1.2 and delta_dpr > 1.2:
		#return  "Bruiser"
	#elif is_ranged and delta_dpr > 1.2:
		#return  "Ranged"
	#elif dex >= 16 and has_stealth:
		#return  "Skulk"
	#elif has_buff_or_debuff:
		#return  "Support"
	#elif can_command or can_summon:
		#return  "Leader"
	#elif cha >= 16 and has_social_spells:
		#return  "Social"
	elif delta_hp < 0.3:
		return  "Minion"
	elif delta_hp < 0.5 or is_swarm:
		return  "Horde"
	else:
		return  "Standard"

func _get_multiattack_count(monster_data: Dictionary) -> int:
	for action in monster_data.get("actions", []):
		if action.get("name") == "Multiattack":
			var total = 0
			for sub_action in action.get("actions", []):
				total += int(sub_action.get("count", 1))
			return total
	return 0

func _has_ranged_attack(monster_data: Dictionary) -> bool:
	for action in monster_data.get("actions", []):
		if action.get("desc", "").to_lower().find("ranged weapon attack") >= 0:
			return true
	return false
