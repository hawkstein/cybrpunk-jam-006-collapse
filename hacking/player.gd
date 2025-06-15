extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var hsm: LimboHSM = $LimboHSM
@onready var selector: Node2D = $Selector
@onready var camera: Camera2D = $Camera2D
@onready var outline: Sprite2D = $OutlineSprite
@onready var overclock_progress_bar: ProgressBar = $OverclockProgressBar

signal move_to_selected_server(key:int)
signal run_ended(success:bool)
signal focus_tween_finished
signal overclock_change(overlock_percentage:float)

var current_server:Server
var options:Dictionary[int, Node2D]
var selection_key:int
var selection_index:int

@export var overclock := 50.0
@export var overclock_maximum := 50.0
@export var burn_rate := 5.0
@export var cool_rate := 1.0
var overclocking := false

var hack_time := 5.0
@export var default_hack_time := 5.0
@export var hack_rate := 2.0
@export var overclock_hack_rate := 4.0

func _ready() -> void:
	_initialise_hsm()

func _initialise_hsm() -> void:
	var select_state := LimboState.new().named("Select").call_on_enter(_on_select_enter).call_on_update(_on_select_update)
	var hack_state := LimboState.new().named("Hack").call_on_enter(_on_hack_enter).call_on_update(_on_hack_update)
	var move_state := LimboState.new().named("Move").call_on_update(_on_move_update)
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

func _on_select_update(delta: float) -> void:
	_check_overclock_toggle()
	_update_overclock(delta)
	if Input.is_action_just_released("left"):
		_update_selection(-1)
	elif Input.is_action_just_released("right"):
		_update_selection(1)
	elif Input.is_action_just_released("select"):
		hsm.dispatch(&"hack_started")

func _on_hack_enter() -> void:
	selector.visible = false
	hack_time = default_hack_time
	
func _on_hack_update(delta:float) -> void:
	_check_overclock_toggle()
	_update_overclock(delta)
	if overclocking:
		hack_time -= overclock_hack_rate * delta
	else:
		hack_time -= hack_rate * delta
	if hack_time < 0:
		hsm.dispatch(&"hack_finished")
		move_to_selected_server.emit(selection_key)

func _on_move_update(delta:float) -> void:
	_check_overclock_toggle()
	_update_overclock(delta)

func _check_overclock_toggle() -> void:
	if Input.is_action_just_released("overclock"):
		overclocking = !overclocking

func _update_overclock(delta:float) -> void:
	var previous = overclock
	if overclocking:
		overclock -= burn_rate * delta
	else:
		overclock += cool_rate * delta
	overclock = clampf(overclock, 0, overclock_maximum)
	if overclock == 0:
		overclocking = false
	if previous != overclock:
		var percentage = 100 - roundi((overclock/overclock_maximum) * 100)
		overclock_progress_bar.value = percentage
		overclock_change.emit(percentage)

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
