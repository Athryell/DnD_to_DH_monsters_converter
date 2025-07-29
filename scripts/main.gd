class_name Main
extends Node

signal new_search

var json_monsters: Dictionary
var json_entry: Dictionary
var matches: Array = []
var db_url := "https://www.dnd5eapi.co/api/monsters/"
var is_http_busy := false
var is_img_http_busy := false

@onready var input_field: LineEdit = %InputField
@onready var button_randomize: Button = %ButtonRandomize
@onready var result_list: ItemList = %ResultList
@onready var http: HTTPRequest = %HTTPRequest
@onready var http_img: HTTPRequest = %HTTPRequestImg
@onready var search_timer: Timer = $SearchTimer
@onready var stats_dnd: BoxContainer = %StatsDnD
@onready var stats_dh: BoxContainer = %StatsDH
@onready var image_display: TextureRect = %ImageDisplay

func _ready():
	http.request_completed.connect(_on_db_response)
	http_img.request_completed.connect(_on_image_response)
	input_field.text_changed.connect(_start_timer)
	search_timer.timeout.connect(_on_search_timeout)
	result_list.item_activated.connect(_on_item_activated)
	button_randomize.button_down.connect(_find_random_monster)

	button_randomize.set_disabled(true)
	result_list.get_parent().hide()
	input_field.grab_focus()

	_request_monsters_list()

func _find_random_monster() -> void:
	new_search.emit()
	var response: Array = json_monsters.get("results", [])
	var random_key = randi() % response.size()
	var rand_monster = response[random_key]
	_request_monster_details(rand_monster["index"])


func _start_timer(_text) -> void:
	search_timer.start()


func _on_search_timeout() -> void:
	var query = input_field.text.to_lower()
	matches.clear()
	
	if query == "":
		result_list.get_parent().hide()
		return

	for item in json_monsters.get("results", []):
		if query in item["name"].to_lower():
			matches.append(item)

	if matches.size() > 0:
		result_list.get_parent().show()
		result_list.clear()
		for item in matches:
			result_list.add_item(item["name"])
	else:
		result_list.get_parent().hide()
		prints("No results for %s" % input_field.text)

# === HTTP REQUESTS ===
func _request_monsters_list():
	if is_http_busy:
		return
	is_http_busy = true
	
	var error = http.request(db_url)
	
	if error != OK:
		is_http_busy = false
		push_error("Error while monsters list request")


func _request_monster_details(monster_index_url: String):
	if is_http_busy:
		return
	is_http_busy = true
	
	var url = db_url + monster_index_url
	var error = http.request(url)
	
	if error != OK:
		is_http_busy = false
		push_error("Error while monster request: %s" % monster_index_url)


func _request_monster_image(url: String):
	if is_img_http_busy:
		return
	is_img_http_busy = true
	
	var error = http_img.request(url)
	
	if error != OK:
		is_img_http_busy = false
		push_error("Error with image request")


# === HANDLE RESPONSES ===
func _on_db_response(_result, response_code: int, _headers, body: PackedByteArray) -> void:
	is_http_busy = false
	if response_code != 200:
		push_error("Error HTTP: %s" % response_code)
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if not parsed:
		push_error("Errore nel parsing del JSON")
		return

	image_display.texture = null
	new_search.emit()
	if parsed.has("results"):
		json_monsters = parsed
		button_randomize.set_disabled(false)
	else:
		json_entry = parsed
		_emit_monster_info(json_entry)

		if parsed.has("image"):
			var img_url = "https://www.dnd5eapi.co" + parsed["image"]
			_request_monster_image(img_url)


func _on_image_response(_result, response_code: int, _headers, body: PackedByteArray) -> void:
	is_img_http_busy = false
	if response_code != 200:
		print("Errore loading image:", response_code)
		return

	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err != OK:
		print("Error image decoding:", err)
		return

	image_display.texture = ImageTexture.create_from_image(image)


# === HANDLE UI INTERACTION ===
func _on_item_activated(item_index: int) -> void:
	result_list.get_parent().hide()
	var monster_index_url = matches[item_index]["index"]
	_request_monster_details(monster_index_url)
	matches.clear()

func _emit_monster_info(info: Dictionary) -> void:
	#print(JSON.stringify(info, "\t")) # DEBUG
	var monster_data: Dictionary = {
		"monster_name": info.get("name", "Unknown"),
		"cr": info.get("challenge_rating", 0.0),
		"hp": info.get("hit_points", 0),
		"ac": info.get("armor_class", [])[0]["value"],
		"attack_bonus": info.get("attack_bonus", 0),
		"intelligence": info.get("intelligence", 0),
		"saving_throws": _get_saving_throws_dict(info),
		"proficiencies": _get_proficiencies_array(info),
		"proficiency_bonus": info.get("proficiency_bonus", 0),
		"special_abilities": info.get("special_abilities", []),
		"actions": info.get("actions", []),
		"legendary_actions": info.get("legendary_actions", []),
		"damage_immunities": info.get("damage_immunities", []),
		"damage_resistances": info.get("damage_resistances", []),
		"damage_vulnerabilities": info.get("damage_vulnerabilities", []),
		"condition_immunities": info.get("condition_immunities", []),
	}
	
	stats_dnd.init(monster_data)
	stats_dh.init(monster_data)


func _get_proficiencies_array(info: Dictionary) -> Array:
	var proficiency_names: Array = []
	var index_name := ""
	var skill := ""
	var proficiencies = info.get("proficiencies", [])
	for entry in proficiencies:
		index_name = entry["proficiency"]["index"]
		if "skill-" in index_name:
			skill = index_name.split("skill-")[1]
			proficiency_names.append(skill)
	
	return proficiency_names


func _get_saving_throws_dict(info: Dictionary) -> Dictionary[String, int]:
	var saving_throws: Dictionary[String, int] = {}
	var index_name := ""
	var saving_throw := ""
	var proficiencies = info.get("proficiencies", [])
	for entry in proficiencies:
		if "saving-throw-" in index_name:
			saving_throw = index_name.split("saving-throw-")[1]
			saving_throws[saving_throw] = int(entry["value"])
	
	return saving_throws
