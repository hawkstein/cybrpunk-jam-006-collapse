extends Node2D

@onready var hsm: LimboHSM = $LimboHSM
@onready var selector: Node2D = $Selector
@onready var hack_timer: Timer = $HackTimer

signal move_to_selected_server(key:int)

var current_server:Server
var options:Dictionary[int, Node2D]
var selection_key:int
var selection_index:int

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

func _on_failure_enter() -> void:
	print("You were detected! Run ended.")

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
	position = current_server.position
	selection_key = options.keys().get(selection_index)
	_point_towards_selection()
	if current_server.enemies.size() > 0:
		hsm.dispatch(&"detected")
	if current_server.is_target:
		hsm.dispatch(&"player_succeeded")
	else:
		hsm.dispatch(&"move_finished")
