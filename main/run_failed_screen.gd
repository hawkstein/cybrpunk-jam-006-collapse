extends Control

func _ready() -> void:
	get_tree().paused = false

func _process(_delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_Y):
		_retry_level()
	elif Input.is_physical_key_pressed(KEY_N):
		_return_to_start()

func _on_retry_button_pressed() -> void:
	_retry_level()

func _on_no_button_pressed() -> void:
	_return_to_start()

func _retry_level() -> void:
	var fade_opts = SceneManager.create_options(0.5)
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	SceneManager.change_scene("hack_the_planet", fade_opts , fade_opts, no_click_opts)

func _return_to_start() -> void:
	var fade_opts = SceneManager.create_options(0.5)
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	SceneManager.change_scene("start_screen", fade_opts , fade_opts, no_click_opts)
