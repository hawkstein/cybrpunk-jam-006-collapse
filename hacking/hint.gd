extends Control

signal hint_accept

@onready var camera: Camera2D = $CameraCentre/Camera2D
@onready var hsm: LimboHSM = $LimboHSM
@export var player:Node2D
var tween:Tween
var last_target:Node2D

func _ready() -> void:
	last_target = player
	_initialise_hsm()

func _initialise_hsm() -> void:
	var hidden_state := LimboState.new().named("Hidden").call_on_enter(_on_hidden_enter).call_on_update(_on_hidden_update)
	var focus_state := LimboState.new().named("Focus").call_on_enter(_on_focus_enter)
	var display_state := LimboState.new().named("Display").call_on_update(_on_display_update)
	
	hsm.add_child(hidden_state)
	hsm.add_child(focus_state)
	hsm.add_child(display_state)
	
	hsm.add_transition(hidden_state, focus_state, &"focus")
	hsm.add_transition(focus_state, display_state, &"display")
	hsm.add_transition(display_state, hidden_state, &"hide")
	hsm.add_transition(display_state, focus_state, &"focus")
	
	hsm.initialize(self)
	hsm.initial_state = hidden_state
	hsm.set_active(true)

func _on_hidden_enter() -> void:
	visible = false

func _on_hidden_update(_delta: float) -> void:
	if HintManager.has_hints():
		hsm.dispatch(&"focus")

func _on_focus_enter() -> void:
	var hint = HintManager.pop_hint()
	#print(hint.target.position)
	if hint:
		# adjust hint UI and tween camera to it
		visible = true
		get_node("Label").text = hint.label
		get_tree().paused = true
		tween = create_tween()
		position = hint.target.position
		camera.global_position = last_target.position
		last_target = hint.target
		tween.tween_property(camera, "position", Vector2(0,0), 4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(func(): hsm.dispatch(&"display"))
		camera.make_current()

func _on_display_update(_delta: float) -> void:
	if  Input.is_action_just_released("ui_accept"):
		if HintManager.has_hints():
			hsm.dispatch(&"focus")
		else:
			last_target = player
			hsm.dispatch(&"hide")
			hint_accept.emit()
