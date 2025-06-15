extends Control
const HACK_THE_PLANET = preload("res://hacking/hack_the_planet.tscn")
@onready var start_button: Button = $StartButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_start_button_pressed() -> void:
	start_button.visible = false
	animation_player.play(&"blurb")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"intro":
		start_button.visible = true
	if anim_name == &"blurb":
		get_tree().change_scene_to_packed(HACK_THE_PLANET)
