extends Control

func _on_button_pressed() -> void:
	Director.reset_levels()
	var fade_opts = SceneManager.create_options()
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	SceneManager.change_scene("start_screen", fade_opts , fade_opts, no_click_opts)
