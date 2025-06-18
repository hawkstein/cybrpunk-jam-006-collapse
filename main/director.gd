extends Node
# holds game level info as an auto run

var save_path := "user://game_data.json"
var current_level := 0
var max_level := 3

func _ready() -> void:
	SceneManager.process_mode = Node.PROCESS_MODE_ALWAYS
	load_game_data()

func advance_level() -> void:
	if current_level < max_level:
		current_level += 1
		save_game_data()

func save_game_data() -> void:
	var data := { "level": current_level }
	var json_string := JSON.stringify(data)
	var file_access := FileAccess.open(save_path, FileAccess.WRITE)
	if not file_access:
		print(FileAccess.get_open_error())
		return
	
	file_access.store_line(json_string)
	file_access.close()

func load_game_data() -> void:
	if not FileAccess.file_exists(save_path):
		return
	
	var file_access := FileAccess.open(save_path, FileAccess.READ)
	var json_string := file_access.get_line()
	file_access.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print(json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	var data:Dictionary = json.data
	current_level = data.get("level", 0)
