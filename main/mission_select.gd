extends Control
@onready var mission_label: Label = $TopAnimatedPanel/Content/MarginContainer/MissionLabel

func _ready() -> void:
	mission_label.text = Director.get_description()

func _process(_delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_Y):
		_on_start_button_pressed()
	elif Input.is_physical_key_pressed(KEY_N):
		_return_to_start()

func _on_start_button_pressed() -> void:
	var fade_opts = SceneManager.create_options()
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	SceneManager.change_scene("hack_the_planet", fade_opts , fade_opts, no_click_opts)

func _return_to_start() -> void:
	var fade_opts = SceneManager.create_options(0.5)
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	SceneManager.change_scene("start_screen", fade_opts , fade_opts, no_click_opts)
