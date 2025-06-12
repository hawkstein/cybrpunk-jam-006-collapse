class_name Guard
extends Node2D

signal request_move_to_server(guard:Guard, key:int)

var current_server:Server
var options:Dictionary[int, Node2D]

func set_current_server(_current_server:Server, _options:Dictionary[int, Node2D], player:Node2D) -> void:
	if current_server:
		current_server.enemies.erase(self)
	current_server = _current_server
	options = _options
	position = current_server.position
	current_server.enemies.append(self)
	if player.current_server == current_server:
		player.hsm.dispatch(&"detected")
