extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var delay := 0.0

func _ready() -> void:
	var content = get_node("Content")
	if is_instance_valid(content):
		content.visible = false
	var timer := Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	timer.autostart = true
	timer.connect("timeout", _play_in_animation)
	add_child(timer)

func _play_in_animation() -> void:
	animation_player.play("in")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var content = get_node("Content")
	if is_instance_valid(content):
		content.visible = true
