extends Node2D

const SERVER = preload("res://hacking/server.tscn")
const CONNECTION = preload("res://hacking/connection.tscn")
const GUARD = preload("res://hacking/Guard.tscn")

@onready var player: Node2D = $Player
@onready var hint: Control = $Tutorial/Hint

var servers:= Array([], TYPE_OBJECT, "Node2D", null)
var connections := Array([], TYPE_OBJECT, "Node2D", null)

func _ready() -> void:
	servers.resize(12)
	load_level()

func load_level() -> void:
	# create servers (nodes) and connections (edges)
	# start node
	add_server(1, Vector2(576,600), [2,3,4])
	# layer 1: +128px up
	add_server(2, Vector2(448,472), [5,3,1])
	add_server(3, Vector2(576,472), [2,6,4])
	add_server(4, Vector2(704,472), [1,3,7])
	# layer 2: +128px up
	add_server(5, Vector2(448,344), [8,2])
	add_server(6, Vector2(576,344), [9,3])
	add_server(7, Vector2(704,344), [10,4])
	# layer 3: +128px again
	add_server(8, Vector2(448,216), [5,9])
	add_server(9, Vector2(576,216), [6,8,11,10])
	add_server(10, Vector2(704,216), [9,7])
	# target layer
	add_server(11, Vector2(576,88), [9])
	var target = servers[11]
	target.is_target = true
	
	for server in servers:
		if server:
			add_connections(server.id, server.edges)
	# setup user (player)
	move_player_to(servers[1])
	
	# add guard
	var guard = GUARD.instantiate()
	add_child(guard)
	var options:Dictionary[int, Node2D] = {}
	for edge in servers[9].edges:
		options[edge] = servers[edge] 
	guard.set_current_server(servers[9], options, player)
	guard.connect("request_move_to_server", _on_guard_request_move)
	
	#add initial hints
	HintManager.queue_hint(&"target_server", target)
	HintManager.queue_hint(&"enemy_guard", guard)
	HintManager.queue_hint(&"hack_move", player)

func add_server(id:int, server_position:Vector2, p_connections:Array[int]) -> void:
	var server = SERVER.instantiate()
	server.id = id
	servers[id] = server
	server.position = server_position
	server.edges = p_connections
	add_child(server)

func add_connections(server_id:int, p_connections:Array[int]) -> void:
	for target_id in p_connections:
		var target:Server = servers[target_id]
		if not target.has_connection(server_id):
			var parent_server:Server = servers[server_id]
			var connection = CONNECTION.instantiate()
			connection.parent = server_id
			connection.child = target_id
			connection.idx = connections.size()
			connections.append(connection)
			connection.position = parent_server.position
			add_child(connection)
			parent_server.connections.append(connection)
			target.connections.append(connection)
			connection.draw_to(target.position)

func move_player_to(server:Server) -> void:
	var options:Dictionary[int, Node2D] = {}
	for edge in server.edges:
		options[edge] = servers[edge] 
	player.set_current_server(server, options)
	
func move_guard_to(guard:Guard, server:Server) -> void:
	var options:Dictionary[int, Node2D] = {}
	for edge in server.edges:
		options[edge] = servers[edge] 
	guard.set_current_server(server, options, player)

func _on_player_move_to_selected_server(key: int) -> void:
	move_player_to(servers[key])

func _on_guard_request_move(guard:Guard, key:int) -> void:
	move_guard_to(guard, servers[key])

func _on_player_run_ended(success:bool) -> void:
	get_tree().paused = true
	# TODO: add sound effects and animation
	# but for now just wait a little and then change scene
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if success:
		tween.tween_callback(func():
			print("run...")
			var fade_opts = SceneManager.create_options()
			var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
			SceneManager.change_scene("run_success_screen", fade_opts , fade_opts, no_click_opts)).set_delay(1)

func _on_hint_hint_accept() -> void:
	player.focus(hint.camera.global_position)

func _on_player_focus_tween_finished() -> void:
	get_tree().paused = false
