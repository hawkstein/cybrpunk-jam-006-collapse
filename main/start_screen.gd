extends Control
@onready var start_button: Button = $StartButton
@onready var reset_button: Button = $ResetButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_start_button_pressed() -> void:
	start_button.visible = false
	animation_player.play(&"outro")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"intro":
		start_button.visible = true
		if Director.current_level > 0:
			start_button.text = "Resume"
			reset_button.visible = true
	if anim_name == &"outro":
		animation_player.play(&"blurb")
	if anim_name == &"blurb":
		var fade_opts = SceneManager.create_options()
		var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
		SceneManager.change_scene("hack_the_planet", fade_opts , fade_opts, no_click_opts)

func _on_button_pressed() -> void:
	Director.reset_levels()
	reset_button.visible = false
	start_button.visible = false
	animation_player.play(&"outro")
