extends Control

signal hint_accept

@onready var camera: Camera2D = $CameraCentre/Camera2D

func _process(_delta: float) -> void:
	if visible and Input.is_action_just_released("ui_accept"):
		hint_accept.emit()
		
func focus(from_global:Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(camera, "position", camera.position, 4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	camera.global_position = from_global
	camera.make_current()
