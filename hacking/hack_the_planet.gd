extends Node2D

const SERVER = preload("res://hacking/server.tscn")
const CONNECTION = preload("res://hacking/connection.tscn")
const GUARD = preload("res://hacking/Guard.tscn")

const GRID_SIZE = 128

@onready var player: Node2D = $Player
@onready var hint: Control = $Tutorial/Hint
@onready var overclock_label: Label = $UI/Layout/Overclock
@onready var hacking_status: Node2D = $HackingStatus
@onready var countdown: Label = $UI/Layout/Countdown
@onready var user_sprite: Sprite2D = $UI/Layout/UserSprite

var servers:= Array([], TYPE_OBJECT, "Node2D", null)
var connections := Array([], TYPE_OBJECT, "Node2D", null)

var seconds_until_alert := 120.0
var connection_seconds_elapsed := 0.0

var blackboard := Blackboard.new()

var levels:= [load_level_zero,
			load_level_one,
			load_level_two,
			load_level_three,
			load_level_four,
			load_level_five ]

var in_game_hints:Dictionary[int, StringName] = {} 

func _ready() -> void:
	load_level()
	_format_clock()
	Orchestra.play_bg_music()

func _process(delta: float) -> void:
	connection_seconds_elapsed += delta
	if connection_seconds_elapsed > seconds_until_alert:
		_on_player_run_ended(false)
	else:
		_format_clock()

func _format_clock() -> void:
	var remaining = seconds_until_alert-connection_seconds_elapsed
	var minutes = str(floori(remaining/60)).pad_zeros(2)
	var seconds = str(fmod(remaining, 60)).pad_zeros(2).pad_decimals(2).replace(".", ":")
	var clock_format = minutes+":"+seconds
	countdown.text = clock_format

func load_level() -> void:
	var level_loader:Callable = levels[Director.current_level]
	#var level_loader:Callable = levels[1]
	level_loader.call()
	var start_server = servers[0]
	# for init, manually set the position as the game is potentially paused
	player.position = start_server.position
	move_player_to(start_server)
	blackboard.set_var(&"servers", servers)

func _add_all_server_connections() -> void:
	for server in servers:
		add_connections(server.id, server.edges)

func _build_tutorial_servers() -> Server:
	var start = Vector2(576,600)
	var y_shift =  Vector2(0, -GRID_SIZE)
	var start_server = add_server(start, [1,2,3])
	var row_one = build_row(Vector2(-GRID_SIZE, 0) + start + y_shift, start_server.id, 3)
	var col_one = build_column(servers[row_one[0]].position + y_shift, servers[row_one[0]].id, 2)
	var col_two = build_column(servers[row_one[1]].position + y_shift, servers[row_one[1]].id, 2)
	var col_three = build_column(servers[row_one[2]].position + y_shift, servers[row_one[2]].id, 2)
	build_edges(col_one[1], col_two[1])
	build_edges(col_two[1], col_three[1])
	var target = add_server(servers[col_two[1]].position + y_shift, [])
	build_edges(col_two[1], target.id)
	target.is_target = true
	return target

func load_level_zero() -> void:
	var target = _build_tutorial_servers()
	_add_all_server_connections()
	HintManager.queue_hint(&"runner", player)
	HintManager.queue_hint(&"target_server", target)
	HintManager.queue_hint(&"how_to", player)
	in_game_hints.set(1, &"hack_move")
	in_game_hints.set(2, &"hack_move")
	in_game_hints.set(3, &"hack_move")

func load_level_one() -> void:
	var target = _build_tutorial_servers()
	_add_all_server_connections()
	HintManager.queue_hint(&"overclock", servers[2])
	HintManager.queue_hint(&"timer", target)
	in_game_hints.set(4, &"cooling")
	in_game_hints.set(5, &"cooling")
	in_game_hints.set(6, &"cooling")

func load_level_two() -> void:
	var target = _build_tutorial_servers()
	_add_all_server_connections()
	var guard = add_guard(target.edges[0])
	HintManager.queue_hint(&"target_server_reminder", target)
	HintManager.queue_hint(&"enemy_guard", guard)
	HintManager.queue_hint(&"push", guard)

func load_level_three() -> void:
	var start = Vector2(576,600)
	var y_shift =  Vector2(0, -128)
	var start_server = add_server(start, [1,2,3])
	var row_one = build_row(Vector2(-GRID_SIZE, 0) + start + y_shift, start_server.id, 3)
	var col_one = build_column(servers[row_one[0]].position + y_shift, servers[row_one[0]].id, 4)
	var col_two = build_column(servers[row_one[1]].position + y_shift, servers[row_one[1]].id, 4)
	var col_three = build_column(servers[row_one[2]].position + y_shift, servers[row_one[2]].id, 4)
	
	_translate_server(col_one[3], Vector2(-GRID_SIZE, 0))
	_translate_server(col_one[1], Vector2(-GRID_SIZE, 0))
	
	build_edges(col_two[0], col_three[0])
	build_edges(col_one[2], col_two[2])
	build_edges(col_two[2], col_three[2])
	build_edges(col_one[3], col_two[3])
	build_edges(col_two[3], col_three[3])
	
	remove_edges(col_one[1], col_one[2])
	remove_edges(col_three[2], col_three[3])
	
	var target = add_server(servers[col_two[3]].position + y_shift, [])
	build_edges(col_two[3], target.id)
	target.is_target = true
	
	_add_all_server_connections()
	# add guards
	add_guard(col_one[3])
	add_guard(col_one[1])

func load_level_four() -> void:
	var start = Vector2(576,600)
	var start_server = add_server(start, [])
	var row_one = build_row(start + Vector2(-GRID_SIZE, -GRID_SIZE), start_server.id, 2)
	var row_two = build_row(start + Vector2(GRID_SIZE, -GRID_SIZE), start_server.id, 2)
	start_server.edges.append_array(row_one)
	start_server.edges.append_array(row_two)
	var row_three = build_row(servers[row_one[1]].position + Vector2(-GRID_SIZE*2, -GRID_SIZE), row_one[1], 2)
	servers[row_one[1]].edges.append_array(row_three)
	var row_four = build_row(servers[row_two[0]].position + Vector2(0, -GRID_SIZE), row_two[0], 2)
	servers[row_two[0]].edges.append_array(row_four)
	var col_one = build_column(servers[row_three[1]].position + Vector2(0, -GRID_SIZE), row_three[1], 3)
	var col_two = build_column(servers[row_four[1]].position + Vector2(0, -GRID_SIZE), row_four[1], 2)
	var col_three = build_column(servers[row_three[1]].position + Vector2(GRID_SIZE, -GRID_SIZE), row_three[1], 3)
	var col_four = build_column(servers[col_two[0]].position + Vector2(GRID_SIZE, -GRID_SIZE/2), col_two[0], 2)
	var left_server = add_server(servers[row_three[0]].position + Vector2(0, -GRID_SIZE), [row_three[0]])
	var top_server = add_server(servers[col_three[2]].position + Vector2(GRID_SIZE, -GRID_SIZE), [col_three[1]])
	
	build_edges(row_one[0], row_three[1])
	build_edges(row_three[0], col_one[0])
	build_edges(left_server.id, col_one[1])
	build_edges(col_three[0], row_four[0])
	build_edges(row_four[0], row_two[1])
	build_edges(row_one[1], row_three[1])
	build_edges(col_three[0], col_two[1])
	build_edges(col_three[1], col_two[0])
	build_edges(col_four[1], col_two[1])
	
	servers[col_four[1]].is_target = true
	
	_add_all_server_connections()
	# add guards
	add_guard(left_server.id)
	add_guard(col_four[1])

func load_level_five() -> void:
	var start = Vector2(576,600)
	var row_one = build_row(start + Vector2(-GRID_SIZE, 0), -1, 3)
	var row_two = build_row(servers[row_one[1]].position + Vector2(0, -GRID_SIZE), -1, 3)
	var row_three = build_row(start + Vector2(-GRID_SIZE, -GRID_SIZE*2), -1, 5)
	var col_one = build_column(servers[row_three[0]].position + Vector2(0, -GRID_SIZE), row_three[0], 2)
	var col_two = build_column(servers[row_three[1]].position + Vector2(0, -GRID_SIZE), row_three[1], 7)
	var col_three = build_column(servers[row_three[2]].position + Vector2(0, -GRID_SIZE), row_three[2], 6)
	var col_four = build_column(servers[row_three[3]].position + Vector2(0, -GRID_SIZE), row_three[3], 7)
	var col_five = build_column(servers[row_three[4]].position + Vector2(0, -GRID_SIZE), row_three[4], 2)
	
	var lower_left = add_server(servers[col_one[0]].position + Vector2(-GRID_SIZE, -GRID_SIZE), [col_one[0]])
	var lower_right = add_server(servers[col_five[0]].position + Vector2(GRID_SIZE, GRID_SIZE), [col_five[0]])
	
	build_edges(row_one[0], row_two[0])
	build_edges(row_one[1], row_two[0])
	build_edges(row_one[2], row_two[1])
	build_edges(row_one[2], row_two[2])
	build_edges(row_two[1], row_three[2])
	build_edges(row_two[2], row_three[3])
	build_edges(row_two[2], row_three[4])
	
	_cross_edges([col_one, col_two, col_three, col_four, col_five], 0)
	_cross_edges([col_one, col_two, col_three, col_four, col_five], 1)
	
	_translate_server(row_one[0], Vector2(-GRID_SIZE, 0))
	
	build_edges(col_two[2], col_three[3])
	build_edges(col_two[3], col_three[4])
	build_edges(col_four[2], col_three[3])
	build_edges(col_four[3], col_three[4])
	
	var top_node = add_server(servers[col_two[5]].position + Vector2(-GRID_SIZE, 0), [])
	build_edges(col_two[4], top_node.id)
	var top_left = add_server(top_node.position + Vector2(-GRID_SIZE, GRID_SIZE), [])
	build_edges(top_left.id, top_node.id)
	
	var target = add_server(servers[col_four[4]].position + Vector2(GRID_SIZE, -GRID_SIZE), [])
	build_edges(col_four[4], target.id)
	target.is_target = true
	
	_add_all_server_connections()
	
	add_guard(col_two[0])
	add_guard(top_left.id)
	add_guard(target.id)

func _cross_edges(p_arrays:Array, p_index:int) -> void:
	for i in range(p_arrays.size()):
		var previous = i - 1
		if previous >= 0:
			build_edges(p_arrays[previous][p_index], p_arrays[i][p_index])

func build_row(origin:Vector2, parent:int, num_columns:int) -> Array[int]:
	var left_server = null
	var row_ids:Array[int] = []
	for i in range(num_columns):
		var edges:Array[int] = []
		if parent >= 0:
			edges.append(parent)
		var server = add_server(origin + Vector2(GRID_SIZE * i, 0), edges)
		if left_server != null:
			edges.append(left_server)
			if parent < 0:
				servers[left_server].edges.append(server.id)
		left_server = server.id
		row_ids.append(server.id)
	return row_ids

func _translate_server(p_key:int, t_vector:Vector2) -> void:
	servers[p_key].position += t_vector

func build_column(origin:Vector2, parent:int, rows:int) -> Array[int]:
	var y_shift = -128
	var edge = parent
	var row_ids:Array[int] = []
	for i in range(rows):
		var server = add_server(origin + Vector2(0, i * y_shift), [edge])
		servers[edge].edges.append(server.id)
		row_ids.append(server.id)
		edge = server.id
	return row_ids

func build_edges(key_one:int, key_two:int) -> void:
	var server_one:Server = servers[key_one]
	var server_two:Server = servers[key_two]
	server_one.edges.append(key_two)
	server_two.edges.append(key_one)

func remove_edges(key_one:int, key_two:int) -> void:
	var server_one:Server = servers[key_one]
	var server_two:Server = servers[key_two]
	server_one.edges.erase(key_two)
	server_two.edges.erase(key_one)

func add_guard(p_server_key:int) -> Guard:
	var guard = GUARD.instantiate()
	add_child(guard)
	guard.set_blackboard(blackboard)
	var server = servers[p_server_key]
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
	user_sprite.update_overclock(overclock_percentage)

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
