extends Node2D
@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func play_bg_music() -> void:
	player.play()
	player.volume_linear = 0.0
	var tween = create_tween()
	tween.tween_property(player, "volume_linear", 1.0, 1)

func stop_bg_music() -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_linear", 0.0, 4)
	tween.tween_callback(func(): player.stop())
