extends Control

@onready var music_volume_slider: HSlider = $LayoutVBoxContainer/VBoxContainer/MusicVolumeSlider

func _ready() -> void:
	music_volume_slider.value = Orchestra.max_bg_volume

func _on_music_volume_slider_value_changed(value: float) -> void:
	Orchestra.max_bg_volume = value

func _on_back_button_pressed() -> void:
	Director.save_game_data()
	var fade_opts = SceneManager.create_options()
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	SceneManager.change_scene("start_screen", fade_opts , fade_opts, no_click_opts)
