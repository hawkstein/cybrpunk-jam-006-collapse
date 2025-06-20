extends Node2D

const SERVER = preload("res://hacking/server.tscn")
const CONNECTION = preload("res://hacking/connection.tscn")
const GUARD = preload("res://hacking/Guard.tscn")

@onready var player: Node2D = $Player
@onready var hint: Control = $Tutorial/Hint
@onready var overclock_label: Label = $UI/Layout/Overclock
@onready var hacking_status: Node2D = $HackingStatus
@onready var countdown: Label = $UI/Layout/Countdown

var servers:= Array([], TYPE_OBJECT, "Node2D", null)
var connections := Array([], TYPE_OBJECT, "Node2D", null)

var seconds_until_alert := 120.0
var connection_seconds_elapsed := 0.0

var blackboard := Blackboard.new()

var levels:= [load_level_zero, load_level_one, load_level_two, load_level_three, load_level_three, load_level_three, load_level_three, load_level_three]

var in_game_hints:Dictionary[int, StringName] = {} 

func _ready() -> void:
	load_level()
	Orchestra.play_bg_music()

func _process(delta: float) -> void:
	connection_seconds_elapsed += delta
	if connection_seconds_elapsed > seconds_until_alert:
		_on_player_run_ended(false)
	else:
		var remaining = seconds_until_alert-connection_seconds_elapsed
		var minutes = str(floori(remaining/60)).pad_zeros(2)
		var seconds = str(fmod(remaining, 60)).pad_decimals(2).replace(".", ":")
		var clock_format = minutes+":"+seconds
		countdown.text = clock_format

func load_level() -> void:
	print("loading level {0}...".format([Director.current_level]))
	var level_loader:Callable = levels[Director.current_level]
	level_loader.call()
	var start_server = servers[0]
	# for init, manually set the position as the game is potentially paused
	player.position = start_server.position
	move_player_to(start_server)
	blackboard.set_var(&"servers", servers)

func load_level_zero() -> void:
	var start = Vector2(576,600)
	var y_shift =  Vector2(0, -128)
	var start_server = add_server(start, [1,2,3])
	var layer_one = build_layer(start + y_shift, start_server.id)
	var col_one_id = build_column(layer_one[0].position + y_shift, layer_one[0].id, 2)
	var col_two_id = build_column(layer_one[1].position + y_shift, layer_one[1].id, 2)
	var col_three_id = build_column(layer_one[2].position + y_shift, layer_one[2].id, 2)
	build_edges(col_one_id, col_two_id)
	build_edges(col_two_id, col_three_id)
	var target = add_server(servers[col_two_id].position + y_shift, [])
	build_edges(col_two_id, target.id)
	target.is_target = true
	
	for server in servers:
		add_connections(server.id, server.edges)
	
	HintManager.queue_hint(&"runner", player)
	HintManager.queue_hint(&"target_server", target)
	HintManager.queue_hint(&"how_to", player)
	
	in_game_hints.set(1, &"hack_move")
	in_game_hints.set(2, &"hack_move")
	in_game_hints.set(3, &"hack_move")

func load_level_one() -> void:
	var start = Vector2(576,600)
	var y_shift =  Vector2(0, -128)
	var start_server = add_server(start, [1,2,3])
	var layer_one = build_layer(start + y_shift, start_server.id)
	var col_one_id = build_column(layer_one[0].position + y_shift, layer_one[0].id, 2)
	var col_two_id = build_column(layer_one[1].position + y_shift, layer_one[1].id, 2)
	var col_three_id = build_column(layer_one[2].position + y_shift, layer_one[2].id, 2)
	build_edges(col_one_id, col_two_id)
	build_edges(col_two_id, col_three_id)
	var target = add_server(servers[col_two_id].position + y_shift, [])
	build_edges(col_two_id, target.id)
	target.is_target = true
	
	for server in servers:
		add_connections(server.id, server.edges)

	HintManager.queue_hint(&"overclock", servers[2])
	in_game_hints.set(4, &"cooling")
	in_game_hints.set(5, &"cooling")
	in_game_hints.set(6, &"cooling")

func load_level_two() -> void:
	var start = Vector2(576,600)
	var y_shift =  Vector2(0, -128)
	var start_server = add_server(start, [1,2,3])
	var layer_one = build_layer(start + y_shift, start_server.id)
	var col_one_id = build_column(layer_one[0].position + y_shift, layer_one[0].id, 2)
	var col_two_id = build_column(layer_one[1].position + y_shift, layer_one[1].id, 2)
	var col_three_id = build_column(layer_one[2].position + y_shift, layer_one[2].id, 2)
	build_edges(col_one_id, col_two_id)
	build_edges(col_two_id, col_three_id)
	var target = add_server(servers[col_two_id].position + y_shift, [])
	build_edges(col_two_id, target.id)
	target.is_target = true
	
	for server in servers:
		add_connections(server.id, server.edges)
	# add guard
	var guard = add_guard(col_two_id)
	
	#add initial hints
	HintManager.queue_hint(&"target_server_reminder", target)
	HintManager.queue_hint(&"enemy_guard", guard)

func load_level_three() -> void:
	var start = Vector2(576,600)
	var y_shift =  Vector2(0, -128)
	var start_server = add_server(start, [1,2,3])
	var layer_one = build_layer(start + y_shift, start_server.id)
	var col_one_id = build_column(layer_one[0].position + y_shift, layer_one[0].id, 4)
	var col_two_id = build_column(layer_one[1].position + y_shift, layer_one[1].id, 4)
	var col_three_id = build_column(layer_one[2].position + y_shift, layer_one[2].id, 4)
	build_edges(col_one_id, col_two_id)
	build_edges(col_two_id, col_three_id)
	var target = add_server(servers[col_two_id].position + y_shift, [])
	build_edges(col_two_id, target.id)
	target.is_target = true
	
	for server in servers:
		add_connections(server.id, server.edges)
	# add guards
	add_guard(col_two_id)
	add_guard(col_three_id)

func build_layer(origin:Vector2, parent:int) -> Array[Server]:
	var x_shift = 128
	var left = add_server(origin + Vector2(-x_shift, 0), [parent])
	var mid = add_server(origin, [parent])
	var right = add_server(origin + Vector2(x_shift, 0), [parent])
	left.edges.append(mid.id)
	mid.edges.append_array([left.id, right.id])
	right.edges.append(mid.id)
	return [left,mid,right]

func build_column(origin:Vector2, parent:int, rows:int) -> int:
	var y_shift = -128
	var edge = parent
	var row
	for i in range(rows):
		row = add_server(origin + Vector2(0, i * y_shift), [edge])
		servers[edge].edges.append(row.id)
		edge = row.id
	return row.id

func build_edges(key_one:int, key_two:int) -> void:
	var server_one:Server = servers[key_one]
	var server_two:Server = servers[key_two]
	server_one.edges.append(key_two)
	server_two.edges.append(key_one)

func add_guard(p_server_key:int) -> Guard:
	var guard = GUARD.instantiate()
	add_child(guard)
	guard.set_blackboard(blackboard)
	var server = servers[p_server_key]
	print("guard server: {0}".format([server.id]))
	guard.set_current_server(server, build_options(server), player)
	guard.connect("request_move_to_server", _on_guard_request_move)
	return guard

func build_options(server:Server) -> Dictionary[int, Node2D]:
	var options:Dictionary[int, Node2D] = {}
	for edge in server.edges:
		options[edge] = servers[edge]
	return options

func add_server(server_position:Vector2, p_connections:Array[int]) -> Server:
	var server = SERVER.instantiate()
	server.id = servers.size()
	servers.append(server)
	server.position = server_position
	server.edges = p_connections
	add_child(server)
	return server

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
	var server = servers[key]
	move_player_to(server)
	server.spawn_traces()
	if in_game_hints.has(key):
		HintManager.queue_hint(in_game_hints.get(key), player)

func _on_guard_request_move(guard:Guard, key:int) -> void:
	move_guard_to(guard, servers[key])

func _on_player_run_ended(success:bool) -> void:
	Orchestra.stop_bg_music()
	get_tree().paused = true
	# TODO: add sound effects and animation
	# but for now just wait a little and then change scene
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var no_click_opts = SceneManager.create_general_options(Color(0,0,0), 0, false)
	var fade_opts = SceneManager.create_options(0.5)
	if success:
		tween.tween_callback(func():
			if Director.current_level == Director.max_level:
				SceneManager.change_scene("thanks_screen", fade_opts , fade_opts, no_click_opts)
			else:
				SceneManager.change_scene("run_success_screen", fade_opts , fade_opts, no_click_opts)).set_delay(1)
	else:
		var slow_fade_opts = SceneManager.create_options(2)
		tween.tween_callback(func():
			SceneManager.change_scene("run_failed_screen", slow_fade_opts , fade_opts, no_click_opts)).set_delay(1)

func _on_hint_hint_accept() -> void:
	player.focus(hint.camera.global_position)

func _on_player_focus_tween_finished() -> void:
	get_tree().paused = false

func _on_player_overclock_change(overclock_percentage: float) -> void:
	overclock_label.text = "Overclock: {0}%".format([overclock_percentage])

func _on_player_hack_started(server_key: int, target_key: int) -> void:
	hacking_status.visible = true
	var server_pos = servers[server_key].position
	var target_pos = servers[target_key].position
	var diff = target_pos - server_pos
	hacking_status.position = target_pos - (diff/2)

func _on_player_hack_ended() -> void:
	hacking_status.visible = false

func _on_player_hack_progress(percentage: float) -> void:
	hacking_status.get_node("ProgressBar").value = ceil(percentage*100)

func _on_player_add_trace(server_key: int) -> void:
	servers[server_key].traces += 1
