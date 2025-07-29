extends VBoxContainer

@onready var monster_name = $Name
@onready var cr = $CR
@onready var hp = $HBoxContainer/HP
@onready var ac = $HBoxContainer/AC
@onready var saving_throws = $SavingThrows
@onready var proficency = $Proficency
@onready var special_abilities = $SpecialAbilities
@onready var actions = $Actions
@onready var legendary_actions = $LegendaryActions
@onready var damage_immunities = $DamageImmunities
@onready var damage_resistances = $DamageResistances
@onready var damage_vulnerabilities = $DamageVulnerabilities
@onready var condition_immunities = $ConditionImmunities

func _ready():
	hide()
	
func init(data: Dictionary) -> void:
	_set_dnd_name(data["monster_name"])
	_set_dnd_cr(data["cr"])
	_set_dnd_hp(data["hp"], data["cr"])
	_set_dnd_ac(data["ac"], data["cr"])
	_set_dnd_proficiency(data["proficiencies"], data["proficiency_bonus"])
	_set_dnd_special_abilities(data["special_abilities"])
	_set_dnd_actions(data["actions"])
	_set_dnd_legendary_actions(data["legendary_actions"])
	_set_dnd_dmg_immunities(data["damage_immunities"])
	_set_dnd_dmg_resistances(data["damage_resistances"])
	_set_dnd_dmg_vulnerabilities(data["damage_vulnerabilities"])
	_set_dnd_condition_immunities(data["condition_immunities"])
	_set_dnd_saving_throws(data["saving_throws"], data["cr"])
	show()


func _set_dnd_name(entry_name: String) -> void:
	monster_name.text = "[b]Name:[/b] " + entry_name

func _set_dnd_cr(value: float) -> void:
	cr.text = "[b]CR:[/b] " + str(value)

func _set_dnd_hp(value_hp: int, value_cr: float) -> void:
	var median_hp = StatsBenchmark.dnd_medians_stats_by_cr[value_cr]["hp"]
	var diff = value_hp - median_hp
	if diff == 0:
		hp.text = "[b]HP:[/b] " + str(value_hp)
	else:
		var diff_sign: String = "+" if sign(diff) > 0 else "-"
		hp.text = "[b]HP:[/b][color=yellow]" + str(value_hp) + " (" + diff_sign + str(abs(diff)) + ")[/color]"

func _set_dnd_ac(value_ac: int, value_cr: float) -> void:
	var median_ac = StatsBenchmark.dnd_medians_stats_by_cr[value_cr]["ac"]
	var diff = value_ac - median_ac
	if diff == 0:
		ac.text = "[b]AC:[/b]" + str(value_ac)
	else:
		var diff_sign: String = "+" if sign(diff) > 0 else "-"
		ac.text = "[b]AC:[/b][color=yellow]" + str(value_ac) + " (" + diff_sign + str(abs(diff)) + ")[/color]"

func _set_dnd_proficiency(names: Array, _bonus: int) -> void:
	if names.is_empty():
		proficency.text = ""
		return
	proficency.text = "[b]Proficency:[/b] "
	for prof in names:
		proficency.text += prof + "\t"

func _set_dnd_saving_throws(saving_throws_dict: Dictionary[String, int], value_cr: float) -> void:
	saving_throws.text = ""
	for entry in saving_throws_dict:
		var saving_to_find = entry + "_save_mod"
		var median_save = StatsBenchmark.dnd_medians_stats_by_cr[value_cr][saving_to_find]
		var value = saving_throws_dict[entry]
		var colored_value: String = str(value)
		var diff = abs(value - median_save)
		if value > median_save:
			colored_value = "[color=red]" + str(value) + " (+" + str(diff) + ")[/color]"
		elif value < median_save:
			colored_value = "[color=green]" + str(value) + " (-" + str(diff) + ")[/color]"
		saving_throws.text += "[b]{entry_upper}[/b] {value} ".format({
			"entry_upper": entry.to_upper(),
			"value": colored_value
		})

func _set_dnd_special_abilities(list: Array) -> void:
	special_abilities.text = "[b]Special abilities:[/b] "
	for element in list:
		special_abilities.text += element["name"] + "\t"

func _set_dnd_actions(list: Array) -> void:
	actions.text = "[b]Actions:[/b] "
	for element in list:
		actions.text += element["name"] + "\t"

func _set_dnd_legendary_actions(list: Array) -> void:
	if list.is_empty():
		legendary_actions.text = ""
		return
	legendary_actions.text = "[b]Legendary actions:[/b] "
	for element in list:
		legendary_actions.text += element["name"] + "\t"

func _set_dnd_dmg_immunities(list: Array) -> void:
	if list.is_empty():
		damage_immunities.text = ""
		return
	damage_immunities.text = "[b]Damage immunities:[/b] "
	for element in list:
		damage_immunities.text += element + "\t"

func _set_dnd_dmg_resistances(list: Array) -> void:
	if list.is_empty():
		damage_resistances.text = ""
		return
	damage_resistances.text = "[b]Damage resistances:[/b] "
	for element in list:
		damage_resistances.text += element + "\t"

func _set_dnd_dmg_vulnerabilities(list: Array) -> void:
	if list.is_empty():
		damage_vulnerabilities.text = ""
		return
	damage_vulnerabilities.text = "[b]Damage vulnerabilities:[/b] "
	for element in list:
		damage_vulnerabilities.text += element + "\t"

func _set_dnd_condition_immunities(list: Array) -> void:
	if list.is_empty():
		condition_immunities.text = ""
		return
	condition_immunities.text = "[b]Condition immunities:[/b] "
	for element in list:
		condition_immunities.text += element["name"] + "\t"
