extends Control

func _ready() -> void:
	Orchestra.stop_bg_music()
	get_tree().paused = false

func _on_start_button_pressed() -> void:
	Director.reset_levels()
	var fade_opts = SceneManager.create_options()
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	SceneManager.change_scene("start_screen", fade_opts , fade_opts, no_click_opts)
