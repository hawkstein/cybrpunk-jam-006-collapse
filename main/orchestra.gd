extends Node2D
@onready var player: AudioStreamPlayer = $AudioStreamPlayer
@onready var start_stream_player: AudioStreamPlayer = $StartStreamPlayer

var max_bg_volume := 1.0

#func _ready() -> void:
	#player.volume_linear = 0.0
	#start_stream_player.volume_linear = 0.0

func play_menu_music() -> void:
	_fade_in_menu()
	_fade_out_game(0.5)

func _stop_menu_music() -> void:
	_fade_out_menu(2)

func play_bg_music() -> void:
	_fade_in_game()
	_fade_out_menu(0.5)

func stop_bg_music() -> void:
	_fade_out_game(2)
	
func _fade_in_menu() -> void:
	start_stream_player.play()
	start_stream_player.volume_linear = 0.0
	var tween = create_tween()
	tween.tween_property(start_stream_player, "volume_linear", max_bg_volume, 1)

func _fade_out_menu(duration:float) -> void:
	var tween = create_tween()
	tween.tween_property(start_stream_player, "volume_linear", 0.0, duration)
	tween.tween_callback(func(): start_stream_player.stop())

func _fade_in_game() -> void:
	player.play()
	player.volume_linear = 0.0
	var tween = create_tween()
	tween.tween_property(player, "volume_linear", max_bg_volume, 1)

func _fade_out_game(duration:float) -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_linear", 0.0, duration)
	tween.tween_callback(func(): player.stop())
