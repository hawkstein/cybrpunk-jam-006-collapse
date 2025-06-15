extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var hsm: LimboHSM = $LimboHSM
@onready var selector: Node2D = $Selector
@onready var hack_timer: Timer = $HackTimer
@onready var camera: Camera2D = $Camera2D
@onready var outline: Sprite2D = $OutlineSprite

signal move_to_selected_server(key:int)
signal run_ended(success:bool)
signal focus_tween_finished

var current_server:Server
var options:Dictionary[int, Node2D]
var selection_key:int
var selection_index:int

@export var overclock := 100

func _ready() -> void:
	_initialise_hsm()

func _initialise_hsm() -> void:
	var select_state := LimboState.new().named("Select").call_on_enter(_on_select_enter).call_on_update(_on_select_update)
	var hack_state := LimboState.new().named("Hack").call_on_enter(_on_hack_enter)
	var move_state := LimboState.new().named("Move")
	var success_state := LimboState.new().named("Success").call_on_enter(_on_success_enter)
	var failure_state := LimboState.new().named("Failure").call_on_enter(_on_failure_enter)
	
	hsm.add_child(select_state)
	hsm.add_child(hack_state)
	hsm.add_child(move_state)
	hsm.add_child(success_state)
	hsm.add_child(failure_state)
	
	hsm.add_transition(select_state, hack_state, &"hack_started")
	hsm.add_transition(hack_state, move_state, &"hack_finished")
	hsm.add_transition(move_state, select_state, &"move_finished")
	hsm.add_transition(move_state, success_state, &"player_succeeded")
	hsm.add_transition(hsm.ANYSTATE, failure_state, &"detected")
	
	hsm.initialize(self)
	hsm.initial_state = select_state
	hsm.set_active(true)

func _on_select_enter() -> void:
	selector.visible = true

func _on_select_update(_delta: float) -> void:
	if Input.is_action_just_released("left"):
		_update_selection(-1)
	elif Input.is_action_just_released("right"):
		_update_selection(1)
	elif Input.is_action_just_released("select"):
		hsm.dispatch(&"hack_started")

func _on_hack_enter() -> void:
	selector.visible = false
	hack_timer.start()

func _on_success_enter() -> void:
	print("You have succeeded! Run ended.")
	run_ended.emit(true)

func _on_failure_enter() -> void:
	print("You were detected! Run ended.")
	run_ended.emit(false)

func _update_selection(amount:int) -> void:
	selection_index += amount
	var size = options.keys().size()
	if selection_index >= size:
		selection_index = 0
	elif selection_index < 0:
		selection_index = size - 1
	selection_key = options.keys().get(selection_index)
	_point_towards_selection()

func _on_hack_timer_timeout() -> void:
	if hsm.get_active_state().name == "Hack":
		hsm.dispatch(&"hack_finished")
		move_to_selected_server.emit(selection_key)

func _point_towards_selection() -> void:
	var vector_towards = current_server.position - options[selection_key].position
	var angle = vector_towards.angle()
	selector.rotation =  angle

func set_current_server(_current_server:Server, _options:Dictionary[int, Node2D]) -> void:
	current_server = _current_server
	options = _options
	selection_index = 0
	selection_key = options.keys().get(selection_index)
	_point_towards_selection()
	
	var tween = create_tween()
	tween.tween_property(outline, "modulate:a", 0, 0.1)
	tween.tween_property(self, "position", current_server.position, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(outline, "modulate:a", 1, 0.2)
	tween.tween_callback(_check_status)

func _check_status() -> void:
	if current_server.enemies.size() > 0:
		hsm.dispatch(&"detected")
	if current_server.is_target:
		hsm.dispatch(&"player_succeeded")
	else:
		hsm.dispatch(&"move_finished")

func focus(from_global:Vector2) -> void:
	camera.global_position = from_global
	var time = clampf(camera.position.length()/2, 0, 300) / 100
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "position", Vector2(0,0), time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): focus_tween_finished.emit())
	camera.make_current()
