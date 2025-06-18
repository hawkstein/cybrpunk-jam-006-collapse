extends Control

func _ready() -> void:
	get_tree().paused = false
	Director.advance_level()

func _on_start_button_pressed() -> void:
	var fade_opts = SceneManager.create_options()
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	if Director.current_level > Director.last_tutorial:
		SceneManager.change_scene("mission_select", fade_opts , fade_opts, no_click_opts)
	else:
		SceneManager.change_scene("hack_the_planet", fade_opts , fade_opts, no_click_opts)
